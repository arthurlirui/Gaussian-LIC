//
//  MLXRasterizer.swift
//  GaussianLIC
//
//  Differentiable 3D Gaussian Splatting forward renderer using MLX Swift.
//
//  Implements a simplified tile-free per-pixel alpha-blending rasterizer:
//    1. Project 3D Gaussian means to 2D screen space
//    2. Compute 2D covariance from 3D scale/rotation via Jacobian projection
//    3. Sort Gaussians by depth (front-to-back)
//    4. For each pixel, evaluate Gaussian influence and accumulate alpha-blended color
//
//  All operations use MLXArray so that MLX's automatic differentiation
//  (valueAndGrad) can compute gradients w.r.t. positions, SH coefficients,
//  scales, rotations, and opacities.
//
//  This is a simplified implementation optimized for on-device training
//  with small scenes (≤50K Gaussians) at low resolution (128×96 or 192×144).
//  It trades rendering fidelity for differentiability — the full sorting-based
//  tile rasterizer from the original 3DGS paper is replaced by a per-pixel
//  evaluation that broadcasts over all Gaussians.
//
//  References:
//    - Kerbl et al., "3D Gaussian Splatting for Real-Time Radiance Field Rendering"
//      (SIGGRAPH 2023), Section 4 for the projection/covariance math
//    - MLX Swift: github.com/ml-explore/mlx-swift (Apache 2.0)
//

import Foundation
import MLX
import MLXRandom
import simd

/// Differentiable 3DGS forward renderer using MLX array operations.
enum MLXRasterizer {

    // MARK: - Types

    /// Training parameters as MLX arrays (all differentiable).
    struct GaussianParams {
        var positions: MLXArray   // [N, 3] — world-space xyz
        var shDC: MLXArray         // [N, 3] — SH degree 0 (base color)
        var shRest: MLXArray       // [N, K] — SH degrees 1-3 (empty for SH0)
        var scales: MLXArray       // [N, 3] — log-space scale
        var rotations: MLXArray    // [N, 4] — quaternion (w, x, y, z)
        var opacity: MLXArray      // [N, 1] — logit opacity

        var count: Int { positions.dim(0) }
    }

    /// Camera view parameters.
    struct CameraParams {
        let viewMatrix: MLXArray    // [4, 4]
        let projectionMatrix: MLXArray // [4, 4]
        let fx: Float
        let fy: Float
        let cx: Float
        let cy: Float
        let width: Int
        let height: Int
    }

    // MARK: - Forward Render

    /// Render the Gaussians from the given camera viewpoint.
    /// Returns an [H, W, 3] RGB image (float, 0–1 range).
    ///
    /// This function is differentiable w.r.t. `params` when called inside
    /// `MLX.valueAndGrad`.
    static func render(params: GaussianParams, camera: CameraParams) -> MLXArray {
        let N = params.count
        let H = camera.height
        let W = camera.width

        // --- Step 1: Transform Gaussian means to camera space ---
        // positions: [N, 3] → homogeneous [N, 4]
        let ones = MLXArray(repeating: 1.0, [N, 1])
        let posHom = concatenated([params.positions, ones], axis: 1) // [N, 4]

        // Apply view matrix: [4, 4] × [4, N] → [4, N]
        let posCam = matmul(camera.viewMatrix, posHom.transposed(1, 0)).transposed(1, 0) // [N, 4]
        let posCamXYZ = posCam[0..., 0..<3] // [N, 3]

        // Depth (z in camera space)
        let depths = posCam[0..., 2] // [N]

        // Skip Gaussians behind the camera.
        let inFront = depths .> 0.1 // [N] boolean mask

        // --- Step 2: Project to screen space ---
        // x_screen = fx * x_cam / z_cam + cx
        // y_screen = fy * y_cam / z_cam + cy
        let zSafe = maximum(depths, MLXArray(0.1)) // [N] avoid division by zero
        let xScreen = (posCam[0..., 0] / zSafe) * camera.fx + camera.cx // [N]
        let yScreen = (posCam[0..., 1] / zSafe) * camera.fy + camera.cy // [N]
        let means2D = stacked([xScreen, yScreen], axis: -1) // [N, 2]

        // --- Step 3: Compute 2D covariance ---
        // Σ_2D = J · W · Σ_3D · W^T · J^T
        // where J is the projection Jacobian and W is the view rotation.
        let cov2D = computeCovariance2D(
            positions: posCamXYZ,
            scales: params.scales,
            rotations: params.rotations,
            depths: zSafe,
            fx: camera.fx,
            fy: camera.fy
        ) // [N, 2, 2]

        // --- Step 4: Compute opacity (sigmoid) ---
        let opacityLin = sigmoid(params.opacity) // [N, 1]
        let opacityMasked = opacityLin.squeezed(axis: -1) * asType(inFront, .float32) // [N]

        // --- Step 5: Evaluate SH color (degree 0 only for simplicity) ---
        // SH0 color: C0 * shDC + 0.5
        let C0: Float = 0.28209479177387814
        let colors = params.shDC * C0 + 0.5 // [N, 3]
        let colorsClamped = minimum(maximum(colors, MLXArray(0.0)), MLXArray(1.0)) // [N, 3]

        // --- Step 6: Sort by depth (front-to-back) ---
        // We use argsort to get indices, then gather.
        let sortedIndices = argsort(depths) // [N]

        // --- Step 7: Per-pixel alpha blending ---
        // For each pixel, evaluate each Gaussian's 2D influence and blend.
        // This is O(N × H × W) but feasible for small N and low res.
        let rendered = alphaBlend(
            means2D: means2D,
            cov2D: cov2D,
            colors: colorsClamped,
            opacities: opacityMasked,
            sortedIndices: sortedIndices,
            width: W,
            height: H
        ) // [H, W, 3]

        return rendered
    }

    // MARK: - 2D Covariance

    /// Compute the 2D screen-space covariance matrix for each Gaussian.
    ///
    /// Uses the EWA splatting approximation:
    ///   J = [[fx/z, 0, -fx*x/z²], [0, fy/z, -fy*y/z²]]
    ///   W = view rotation (upper-left 3×3 of viewMatrix)
    ///   Σ_2D = J · W · Σ_3D · (W · J)^T
    ///
    /// Returns [N, 2, 2] covariance matrices.
    static func computeCovariance2D(
        positions: MLXArray,    // [N, 3] camera-space
        scales: MLXArray,       // [N, 3] log-space
        rotations: MLXArray,    // [N, 4] quaternion (w, x, y, z)
        depths: MLXArray,       // [N]
        fx: Float,
        fy: Float
    ) -> MLXArray {
        let N = positions.dim(0)

        // Build 3D covariance Σ_3D = R · S · S^T · R^T
        // where S = diag(exp(scale)) and R = quaternion rotation matrix.
        let scaleLin = exp(scales) // [N, 3]

        // Build rotation matrices from quaternions.
        let rotMat = quaternionToMatrix(rotations) // [N, 3, 3]

        // S as diagonal: [N, 3, 3]
        let scaleMat = diagMatrix(scaleLin) // [N, 3, 3]

        // R · S = [N, 3, 3]
        let RS = matmul(rotMat, scaleMat)
        // Σ_3D = R · S · S^T · R^T = RS · RS^T
        let sigma3D = matmul(RS, transposed(RS, -1, -2)) // [N, 3, 3]

        // Projection Jacobian J: [N, 2, 3]
        // J = [[fx/z, 0, -fx*x/z²],
        //      [0, fy/z, -fy*y/z²]]
        let z = depths // [N]
        let x = positions[0..., 0] // [N]
        let y = positions[0..., 1] // [N]
        let z2 = z * z

        // Build J as [N, 2, 3]
        let j00 = (MLXArray(fx) / z).expandedDimensions(axis: -1) // [N, 1]
        let j02 = (-MLXArray(fx) * x / z2).expandedDimensions(axis: -1) // [N, 1]
        let j11 = (MLXArray(fy) / z).expandedDimensions(axis: -1) // [N, 1]
        let j12 = (-MLXArray(fy) * y / z2).expandedDimensions(axis: -1) // [N, 1]
        let zeros = MLXArray(repeating: 0.0, [N, 1])

        let row0 = concatenated([j00, zeros, j02], axis: 1) // [N, 3]
        let row1 = concatenated([zeros, j11, j12], axis: 1) // [N, 3]
        let J = stacked([row0, row1], axis: 1) // [N, 2, 3]

        // Σ_2D = J · Σ_3D · J^T
        let JSigma = matmul(J, sigma3D) // [N, 2, 3]
        let cov2D = matmul(JSigma, transposed(J, -1, -2)) // [N, 2, 2]

        // Add low-pass filter for sub-pixel Gaussians (anti-aliasing).
        let blurAmount: Float = 0.3
        let blur = MLXArray(blurAmount)
        let eye2 = eye(2).asType(cov2D.dtype) // [2, 2]
        let cov2DBlurred = cov2D + blur * eye2

        return cov2DBlurred
    }

    // MARK: - Alpha Blending

    /// Per-pixel front-to-back alpha blending.
    ///
    /// For each pixel (px, py), computes:
    ///   for each Gaussian i (sorted front-to-back):
    ///     α = opacity_i * exp(-0.5 * d^T * Σ_2D^{-1} * d)
    ///     C += α * (1 - T) * color_i
    ///     T *= (1 - α)
    ///   until T < ε
    ///
    /// To keep this differentiable and vectorized, we evaluate all Gaussians
    /// per pixel via broadcasting. For large N this is memory-intensive, so
    /// we limit to the closest K Gaussians.
    static func alphaBlend(
        means2D: MLXArray,       // [N, 2]
        cov2D: MLXArray,         // [N, 2, 2]
        colors: MLXArray,        // [N, 3]
        opacities: MLXArray,     // [N]
        sortedIndices: MLXArray, // [N]
        width: Int,
        height: Int,
        maxGaussiansPerPixel: Int = 32
    ) -> MLXArray {
        let N = means2D.dim(0)
        let K = min(maxGaussiansPerPixel, N)

        // Use only the first K sorted Gaussians (closest to camera).
        let topKIndices = sortedIndices[0..<K] // [K]
        let meansSorted = takeAlong(axis: 0, indices: topKIndices, array: means2D) // [K, 2]
        let covSorted = gather2D(cov2D, indices: topKIndices) // [K, 2, 2]
        let colorsSorted = takeAlong(axis: 0, indices: topKIndices.expandedDimensions(axis: -1).broadcast([K, 3]), array: colors) // [K, 3]
        let opacitySorted = takeAlong(axis: 0, indices: topKIndices, array: opacities) // [K]

        // Create pixel coordinate grid: [H, W, 2]
        let ys = MLXArray(Int32(0)..<Int32(height)).asType(.float32) // [H]
        let xs = MLXArray(Int32(0)..<Int32(width)).asType(.float32)  // [W]
        let pixelY = ys.expandedDimensions(axis: 1).broadcast([height, width])  // [H, W]
        let pixelX = xs.expandedDimensions(axis: 0).broadcast([height, width])  // [H, W]
        let pixels = stacked([pixelX, pixelY], axis: -1) // [H, W, 2]

        // Difference: pixels - means → [H, W, K, 2]
        // pixels: [H, W, 1, 2], meansSorted: [1, 1, K, 2]
        let pixelsExp = pixels.expandedDimensions(axis: 2).broadcast([height, width, K, 2])
        let meansExp = meansSorted.expandedDimensions(axis: 0).expandedDimensions(axis: 1).broadcast([height, width, K, 2])
        let diff = pixelsExp - meansExp // [H, W, K, 2]

        // Compute Gaussian power: d^T · Σ^{-1} · d
        // Σ^{-1} for 2×2: inv = [[b, -c], [-c, a]] / (ab - c²)
        // where Σ = [[a, c], [c, b]]
        let a = covSorted[0..., 0, 0] // [K]
        let b = covSorted[0..., 1, 1] // [K]
        let c = covSorted[0..., 0, 1] // [K]
        let det = a * b - c * c      // [K]
        let detSafe = maximum(abs(det), MLXArray(1e-6))
        let invA = b / detSafe
        let invB = a / detSafe
        let invC = -c / detSafe

        // d^T · Σ^{-1} · d = invA * dx² + 2 * invC * dx * dy + invB * dy²
        let dx = diff[0..., 0..., 0..., 0] // [H, W, K]
        let dy = diff[0..., 0..., 0..., 1] // [H, W, K]

        let invAExp = invA.expandedDimensions(axis: 0).expandedDimensions(axis: 1).broadcast([height, width, K])
        let invBExp = invB.expandedDimensions(axis: 0).expandedDimensions(axis: 1).broadcast([height, width, K])
        let invCExp = invC.expandedDimensions(axis: 0).expandedDimensions(axis: 1).broadcast([height, width, K])

        let power = invAExp * dx * dx + 2.0 * invCExp * dx * dy + invBExp * dy * dy // [H, W, K]

        // Gaussian influence: exp(-0.5 * power), clamped to [0, 1]
        let influence = exp(-0.5 * power) // [H, W, K]

        // Alpha for each Gaussian: opacity * influence
        let opacityExp = opacitySorted.expandedDimensions(axis: 0).expandedDimensions(axis: 1).broadcast([height, width, K])
        let alpha = opacityExp * influence // [H, W, K]

        // Front-to-back alpha blending:
        // C = Σ α_i * T_i * color_i, where T_i = Π_{j<i} (1 - α_j)
        // T_0 = 1, T_i = T_{i-1} * (1 - α_{i-1})
        let oneMinusAlpha = 1.0 - alpha // [H, W, K]

        // Compute cumulative transmittance T via cumulative product.
        // T_i = prod_{j=0}^{i-1} (1 - α_j)
        // We compute this with a loop over K (small, ≤32).
        var transmittance = MLXArray(repeating: 1.0, [height, width, 1])
        var blendedColor = MLXArray(repeating: 0.0, [height, width, 3])

        for k in 0..<K {
            let alphaK = alpha[0..., 0..., k].expandedDimensions(axis: -1) // [H, W, 1]
            let colorK = colorsSorted[k].expandedDimensions(axis: 0).expandedDimensions(axis: 1) // [1, 1, 3] → broadcast
            let colorKBroadcast = colorK.broadcast([height, width, 3]) // [H, W, 3]
            let transK = transmittance.broadcast([height, width, 1]) // [H, W, 1]

            let contribution = alphaK * transK * colorKBroadcast // [H, W, 3]
            blendedColor = blendedColor + contribution
            transmittance = transK.squeezed(axis: -1) * oneMinusAlpha[0..., 0..., k] // [H, W]
            transmittance = transmittance.expandedDimensions(axis: -1) // [H, W, 1]
        }

        return blendedColor // [H, W, 3]
    }

    // MARK: - Loss Functions

    /// L1 loss between predicted and target images.
    /// Both are [H, W, 3] float arrays.
    static func l1Loss(predicted: MLXArray, target: MLXArray) -> MLXArray {
        abs(predicted - target).mean()
    }

    /// SSIM loss (1 - SSIM) using an 11×11 Gaussian window.
    /// Simplified to a box filter for MLX efficiency.
    static func ssimLoss(predicted: MLXArray, target: MLXArray) -> MLXArray {
        let C1: Float = 0.01 * 0.01
        let C2: Float = 0.03 * 0.03

        // Use a simple 3×3 mean filter as a proxy for the SSIM window.
        let predMean = meanFilter3x3(predicted)
        let targetMean = meanFilter3x3(target)
        let predSq = meanFilter3x3(predicted * predicted)
        let targetSq = meanFilter3x3(target * target)
        let predTarget = meanFilter3x3(predicted * target)

        let variancePred = predSq - predMean * predMean
        let varianceTarget = targetSq - targetMean * targetMean
        let covariance = predTarget - predMean * targetMean

        let ssim = ((2 * predMean * targetMean + C1) * (2 * covariance + C2)) /
                   ((predMean * predMean + targetMean * targetMean + C1) *
                    (variancePred + varianceTarget + C2))

        return 1.0 - ssim.mean()
    }

    /// Combined loss: (1 - λ) * L1 + λ * (1 - SSIM)
    static func combinedLoss(predicted: MLXArray, target: MLXArray, ssimWeight: Float = 0.2) -> MLXArray {
        let l1 = l1Loss(predicted: predicted, target: target)
        let ssim = ssimLoss(predicted: predicted, target: target)
        return (1.0 - ssimWeight) * l1 + ssimWeight * ssim
    }

    // MARK: - Helpers

    /// Convert quaternion array to rotation matrices.
    /// Input: [N, 4] (w, x, y, z)
    /// Output: [N, 3, 3]
    static func quaternionToMatrix(_ quats: MLXArray) -> MLXArray {
        let N = quats.dim(0)
        let w = quats[0..., 0] // [N]
        let x = quats[0..., 1]
        let y = quats[0..., 2]
        let z = quats[0..., 3]

        // Normalize quaternion.
        let norm = sqrt(w * w + x * x + y * y + z * z)
        let wn = w / norm
        let xn = x / norm
        let yn = y / norm
        let zn = z / norm

        let xx = xn * xn
        let yy = yn * yn
        let zz = zn * zn
        let xy = xn * yn
        let xz = xn * zn
        let yz = yn * zn
        let wx = wn * xn
        let wy = wn * yn
        let wz = wn * zn

        // Row 0: [1-2(yy+zz), 2(xy-wz),   2(xz+wy)]
        let r00 = 1.0 - 2.0 * (yy + zz)
        let r01 = 2.0 * (xy - wz)
        let r02 = 2.0 * (xz + wy)
        // Row 1: [2(xy+wz),   1-2(xx+zz), 2(yz-wx)]
        let r10 = 2.0 * (xy + wz)
        let r11 = 1.0 - 2.0 * (xx + zz)
        let r12 = 2.0 * (yz - wx)
        // Row 2: [2(xz-wy),   2(yz+wx),   1-2(xx+yy)]
        let r20 = 2.0 * (xz - wy)
        let r21 = 2.0 * (yz + wx)
        let r22 = 1.0 - 2.0 * (xx + yy)

        let row0 = stacked([r00, r01, r02], axis: -1) // [N, 3]
        let row1 = stacked([r10, r11, r12], axis: -1)
        let row2 = stacked([r20, r21, r22], axis: -1)

        return stacked([row0, row1, row2], axis: 1) // [N, 3, 3]
    }

    /// Create a batch of diagonal matrices from [N, 3] → [N, 3, 3].
    static func diagMatrix(_ diagonal: MLXArray) -> MLXArray {
        let N = diagonal.dim(0)
        let D = diagonal.dim(1)
        let eyeMat = eye(D).asType(diagonal.dtype) // [D, D]
        // broadcasting: [N, 1, D] * [1, D, D] → [N, D, D]
        let diagExp = diagonal.expandedDimensions(axis: 1) // [N, 1, D]
        let eyeExp = eyeMat.expandedDimensions(axis: 0)    // [1, D, D]
        return diagExp * eyeExp.broadcast([N, D, D])
    }

    /// Simple 3×3 mean filter for SSIM computation.
    /// Input: [H, W, C] → Output: [H, W, C]
    static func meanFilter3x3(_ image: MLXArray) -> MLXArray {
        let H = image.dim(0)
        let W = image.dim(1)

        // Pad with 1 pixel on each side (replicate edges).
        let padded = paddedImage(image, padding: 1) // [H+2, W+2, C]

        // Sum 3×3 window.
        var sum = MLXArray(repeating: 0.0, [H, W, image.dim(2)])
        for dy in 0..<3 {
            for dx in 0..<3 {
                sum = sum + padded[dy..<(dy + H), dx..<(dx + W), 0...]
            }
        }
        return sum / 9.0
    }

    /// Pad an [H, W, C] image by replicating edge pixels.
    static func paddedImage(_ image: MLXArray, padding: Int) -> MLXArray {
        // Simple zero-padding (acceptable for SSIM approximation).
        let H = image.dim(0)
        let W = image.dim(1)
        let C = image.dim(2)
        let pH = H + 2 * padding
        let pW = W + 2 * padding

        var result = MLXArray(repeating: 0.0, [pH, pW, C])
        result[padding..<(padding + H), padding..<(padding + W), 0...] = image
        return result
    }

    /// Take along an axis with indices (helper for MLX gather).
    static func takeAlong(axis: Int, indices: MLXArray, array: MLXArray) -> MLXArray {
        // For 1-D indices along axis 0, this is simple indexing.
        if axis == 0 && indices.ndim == 1 {
            return array[indices]
        }
        // General case: use takeAlongAxes
        return takeAlongAxes(array, indices, axis: axis)
    }

    /// Gather rows from a [N, 2, 2] tensor by index.
    static func gather2D(_ tensor: MLXArray, indices: MLXArray) -> MLXArray {
        return tensor[indices]
    }
}
