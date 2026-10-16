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
//    4. For each pixel, evaluate Gaussian influence and accumulate alpha-blended
//       color AND depth (for depth supervision, matching win_lic's render pkg)
//
//  All operations use MLXArray so that MLX's automatic differentiation
//  (valueAndGrad) can compute gradients w.r.t. positions, SH coefficients,
//  scales, rotations, and opacities.
//
//  API notes: MLX Swift's valueAndGrad only accepts [MLXArray] -> MLXArray
//  (or MLXArray -> MLXArray), NOT custom structs. Callers must pack/unpack
//  GaussianParams to/from [MLXArray] when calling valueAndGrad.
//
//  References:
//    - Kerbl et al., "3D Gaussian Splatting for Real-Time Radiance Field Rendering"
//      (SIGGRAPH 2023), Section 4 for the projection/covariance math
//    - win_lic/gaussians/gaussian_model.cpp::optimize() for the loss formulation
//      including depth supervision: (1-λ)·L1 + λ·(1-SSIM) + λ_depth·L1_depth
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

    /// Pack GaussianParams into [MLXArray] for valueAndGrad.
    /// Order MUST be consistent with unpackParams.
    static func packParams(_ p: GaussianParams) -> [MLXArray] {
        return [p.positions, p.shDC, p.shRest, p.scales, p.rotations, p.opacity]
    }

    /// Unpack [MLXArray] back into GaussianParams.
    static func unpackParams(_ arrays: [MLXArray]) -> GaussianParams {
        return GaussianParams(
            positions: arrays[0],
            shDC: arrays[1],
            shRest: arrays[2],
            scales: arrays[3],
            rotations: arrays[4],
            opacity: arrays[5]
        )
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

    /// Render output containing both RGB and depth (matching win_lic's render package).
    struct RenderOutput {
        let rgb: MLXArray     // [H, W, 3]
        let depth: MLXArray   // [H, W, 1] — alpha-weighted depth
        let alpha: MLXArray   // [H, W, 1] — accumulated opacity (1 - transmittance)
    }

    // MARK: - Forward Render

    /// Render the Gaussians from the given camera viewpoint.
    /// Returns RGB image [H, W, 3], depth [H, W, 1], and alpha [H, W, 1].
    ///
    /// This function is differentiable w.r.t. `params` when called inside
    /// `MLX.valueAndGrad` (use packParams/unpackParams for the [MLXArray] bridge).
    static func render(params: GaussianParams, camera: CameraParams) -> RenderOutput {
        let N = params.count
        let H = camera.height
        let W = camera.width

        // --- Step 1: Transform Gaussian means to camera space ---
        let ones = MLXArray(repeating: 1.0, [N, 1])
        let posHom = concatenated([params.positions, ones], axis: 1) // [N, 4]

        let posCam = matmul(camera.viewMatrix, posHom.transposed(1, 0)).transposed(1, 0) // [N, 4]
        let posCamXYZ = posCam[0..., 0..<3] // [N, 3]

        // Depth (z in camera space)
        let depths = posCam[0..., 2] // [N]

        // Skip Gaussians behind the camera.
        let inFront = depths .> 0.1 // [N] boolean mask

        // --- Step 2: Project to screen space ---
        let zSafe = maximum(depths, MLXArray(0.1)) // [N]
        let xScreen = (posCam[0..., 0] / zSafe) * camera.fx + camera.cx // [N]
        let yScreen = (posCam[0..., 1] / zSafe) * camera.fy + camera.cy // [N]
        let means2D = stacked([xScreen, yScreen], axis: -1) // [N, 2]

        // --- Step 3: Compute 2D covariance ---
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
        let opacityMasked = opacityLin.squeezed(axis: -1) * inFront.asType(.float32) // [N]

        // --- Step 5: Evaluate SH color (degree 0 only for on-device) ---
        let C0: Float = 0.28209479177387814
        let colors = params.shDC * C0 + 0.5 // [N, 3]
        let colorsClamped = minimum(maximum(colors, MLXArray(0.0)), MLXArray(1.0)) // [N, 3]

        // --- Step 6: Sort by depth (front-to-back) ---
        let sortedIndices = argSort(depths) // [N]

        // --- Step 7: Per-pixel alpha blending (color + depth) ---
        let blended = alphaBlend(
            means2D: means2D,
            cov2D: cov2D,
            colors: colorsClamped,
            opacities: opacityMasked,
            depths: zSafe,
            sortedIndices: sortedIndices,
            width: W,
            height: H
        )

        return RenderOutput(rgb: blended.rgb, depth: blended.depth, alpha: blended.alpha)
    }

    // MARK: - 2D Covariance

    /// Compute the 2D screen-space covariance matrix for each Gaussian.
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
        let scaleLin = exp(scales) // [N, 3]
        let rotMat = quaternionToMatrix(rotations) // [N, 3, 3]
        let scaleMat = diagMatrix(scaleLin) // [N, 3, 3]
        let RS = matmul(rotMat, scaleMat)
        let sigma3D = matmul(RS, transposed(RS, -1, -2)) // [N, 3, 3]

        // Projection Jacobian J: [N, 2, 3]
        let z = depths
        let x = positions[0..., 0]
        let y = positions[0..., 1]
        let z2 = z * z

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

    // MARK: - Alpha Blending (Color + Depth)

    /// Per-pixel front-to-back alpha blending for both color and depth.
    ///
    /// Matches win_lic/gaussians/gaussian_model.cpp::render() which returns
    /// (image, depth, final_T, ...). Here:
    ///   C = Σ α_i · T_i · color_i     (accumulated color)
    ///   D = Σ α_i · T_i · depth_i      (accumulated depth)
    ///   α_total = 1 - T_final           (total opacity)
    static func alphaBlend(
        means2D: MLXArray,       // [N, 2]
        cov2D: MLXArray,         // [N, 2, 2]
        colors: MLXArray,        // [N, 3]
        opacities: MLXArray,     // [N]
        depths: MLXArray,        // [N]
        sortedIndices: MLXArray, // [N]
        width: Int,
        height: Int,
        maxGaussiansPerPixel: Int = 32
    ) -> (rgb: MLXArray, depth: MLXArray, alpha: MLXArray) {
        let N = means2D.dim(0)
        let K = min(maxGaussiansPerPixel, N)

        // Use only the first K sorted Gaussians (closest to camera).
        let topKIndices = sortedIndices[0..<K] // [K]
        let meansSorted = takeAlong(axis: 0, indices: topKIndices, array: means2D) // [K, 2]
        let covSorted = cov2D[topKIndices] // [K, 2, 2]
        let colorsSorted = takeAlong(axis: 0, indices: topKIndices.expandedDimensions(axis: -1).broadcast(to: [K, 3]), array: colors) // [K, 3]
        let opacitySorted = takeAlong(axis: 0, indices: topKIndices, array: opacities) // [K]
        let depthsSorted = takeAlong(axis: 0, indices: topKIndices, array: depths) // [K]

        // Create pixel coordinate grid: [H, W, 2]
        let ys = MLXArray(Int32(0)..<Int32(height)).asType(.float32) // [H]
        let xs = MLXArray(Int32(0)..<Int32(width)).asType(.float32)  // [W]
        let pixelY = broadcast(ys.expandedDimensions(axis: 1), to: [height, width])  // [H, W]
        let pixelX = broadcast(xs.expandedDimensions(axis: 0), to: [height, width])  // [H, W]
        let pixels = stacked([pixelX, pixelY], axis: -1) // [H, W, 2]

        // Difference: pixels - means → [H, W, K, 2]
        let pixelsExp = broadcast(pixels.expandedDimensions(axis: 2), to: [height, width, K, 2])
        let meansExp = broadcast(meansSorted.expandedDimensions(axis: 0).expandedDimensions(axis: 1), to: [height, width, K, 2])
        let diff = pixelsExp - meansExp // [H, W, K, 2]

        // Compute Gaussian power: d^T · Σ^{-1} · d
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

        let invAExp = broadcast(invA.expandedDimensions(axis: 0).expandedDimensions(axis: 1), to: [height, width, K])
        let invBExp = broadcast(invB.expandedDimensions(axis: 0).expandedDimensions(axis: 1), to: [height, width, K])
        let invCExp = broadcast(invC.expandedDimensions(axis: 0).expandedDimensions(axis: 1), to: [height, width, K])

        let power = invAExp * dx * dx + 2.0 * invCExp * dx * dy + invBExp * dy * dy // [H, W, K]

        // Gaussian influence: exp(-0.5 * power)
        let influence = exp(-0.5 * power) // [H, W, K]

        // Alpha for each Gaussian: opacity * influence
        let opacityExp = broadcast(opacitySorted.expandedDimensions(axis: 0).expandedDimensions(axis: 1), to: [height, width, K])
        let alpha = opacityExp * influence // [H, W, K]

        // Front-to-back alpha blending with loop over K (small, ≤32).
        var transmittance = MLXArray(repeating: 1.0, [height, width, 1])
        var blendedColor = MLXArray(repeating: 0.0, [height, width, 3])
        var blendedDepth = MLXArray(repeating: 0.0, [height, width, 1])

        let oneMinusAlpha = 1.0 - alpha // [H, W, K]

        for k in 0..<K {
            let alphaK = alpha[0..., 0..., k].expandedDimensions(axis: -1) // [H, W, 1]
            let colorK = broadcast(colorsSorted[k].expandedDimensions(axis: 0).expandedDimensions(axis: 1), to: [height, width, 3]) // [H, W, 3]
            let depthK = depthsSorted[k].expandedDimensions(axis: 0).expandedDimensions(axis: 1) // [1, 1, 1] → broadcast
            let depthKBroadcast = broadcast(depthK, to: [height, width, 1]) // [H, W, 1]
            let transK = transmittance // [H, W, 1]

            blendedColor = blendedColor + alphaK * transK * colorK // [H, W, 3]
            blendedDepth = blendedDepth + alphaK * transK * depthKBroadcast // [H, W, 1]
            transmittance = transK.squeezed(axis: -1) * oneMinusAlpha[0..., 0..., k] // [H, W]
            transmittance = transmittance.expandedDimensions(axis: -1) // [H, W, 1]
        }

        // Alpha = 1 - final transmittance
        let renderedAlpha = 1.0 - transmittance // [H, W, 1]

        return (rgb: blendedColor, depth: blendedDepth, alpha: renderedAlpha)
    }

    // MARK: - Loss Functions

    /// L1 loss between predicted and target images.
    /// Both are [H, W, 3] float arrays.
    static func l1Loss(predicted: MLXArray, target: MLXArray) -> MLXArray {
        abs(predicted - target).mean()
    }

    /// Depth L1 loss with masking (matching win_lic).
    /// Only computes loss where both gt_depth > 0 AND rendered_depth > 0.
    /// Both depth arrays are [H, W, 1].
    static func depthLoss(predicted: MLXArray, target: MLXArray) -> MLXArray {
        // Mask: both gt and rendered depth must be positive.
        let mask = (target .> 0) .&& (predicted .> 0) // [H, W, 1] bool

        // If no valid pixels, return zero loss.
        let maskFloat = mask.asType(.float32)
        let maskSum = maskFloat.sum()

        // Apply mask: only compute L1 where mask is true.
        let diff = abs(predicted - target) * maskFloat // [H, W, 1]
        // Mean over valid pixels (avoid division by zero with safe denom).
        let safeCount = maximum(maskSum, MLXArray(1.0))
        return diff.sum() / safeCount
    }

    /// SSIM loss (1 - SSIM) using a 3×3 mean filter approximation.
    /// Both are [H, W, 3] float arrays.
    static func ssimLoss(predicted: MLXArray, target: MLXArray) -> MLXArray {
        let C1: Float = 0.01 * 0.01
        let C2: Float = 0.03 * 0.03

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

    /// Combined loss matching win_lic/gaussians/gaussian_model.cpp::optimize():
    ///   loss = (1 - λ_dssim) * L1 + λ_dssim * (1 - SSIM) + λ_depth * L1_depth
    ///
    /// - Parameters:
    ///   - predictedRGB: [H, W, 3] rendered color
    ///   - targetRGB: [H, W, 3] ground truth color
    ///   - predictedDepth: [H, W, 1] rendered depth (optional)
    ///   - targetDepth: [H, W, 1] ground truth depth (optional)
    static func combinedLoss(
        predictedRGB: MLXArray,
        targetRGB: MLXArray,
        predictedDepth: MLXArray? = nil,
        targetDepth: MLXArray? = nil,
        ssimWeight: Float = 0.2,
        depthWeight: Float = 0.005
    ) -> MLXArray {
        let l1 = l1Loss(predicted: predictedRGB, target: targetRGB)
        let ssim = ssimLoss(predicted: predictedRGB, target: targetRGB)
        var loss = (1.0 - ssimWeight) * l1 + ssimWeight * ssim

        if let predDepth = predictedDepth, let gtDepth = targetDepth {
            let dLoss = depthLoss(predicted: predDepth, target: gtDepth)
            loss = loss + depthWeight * dLoss
        }

        return loss
    }

    // MARK: - Helpers

    /// Convert quaternion array to rotation matrices.
    /// Input: [N, 4] (w, x, y, z)
    /// Output: [N, 3, 3]
    static func quaternionToMatrix(_ quats: MLXArray) -> MLXArray {
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

        let r00 = 1.0 - 2.0 * (yy + zz)
        let r01 = 2.0 * (xy - wz)
        let r02 = 2.0 * (xz + wy)
        let r10 = 2.0 * (xy + wz)
        let r11 = 1.0 - 2.0 * (xx + zz)
        let r12 = 2.0 * (yz - wx)
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
        let diagExp = diagonal.expandedDimensions(axis: 1) // [N, 1, D]
        let eyeExp = eyeMat.expandedDimensions(axis: 0)    // [1, D, D]
        return diagExp * broadcast(eyeExp, to: [N, D, D])
    }

    /// Simple 3×3 mean filter for SSIM computation.
    /// Input: [H, W, C] → Output: [H, W, C]
    static func meanFilter3x3(_ image: MLXArray) -> MLXArray {
        let H = image.dim(0)
        let W = image.dim(1)
        let C = image.dim(2)

        // Build padded image using concatenated (functional, not in-place).
        // Pad with zeros on all sides → [H+2, W+2, C]
        let zeroRow = MLXArray(repeating: 0.0, [1, W, C])
        let zeroCol = MLXArray(repeating: 0.0, [H + 2, 1, C])

        let paddedRows = concatenated([zeroRow, image, zeroRow], axis: 0) // [H+2, W, C]
        let padded = concatenated([zeroCol, paddedRows, zeroCol], axis: 1) // [H+2, W+2, C]

        // Sum 3×3 window.
        var sum = MLXArray(repeating: 0.0, [H, W, C])
        for dy in 0..<3 {
            for dx in 0..<3 {
                sum = sum + padded[dy..<(dy + H), dx..<(dx + W), 0...]
            }
        }
        return sum / 9.0
    }

    /// Take along an axis with indices (helper for MLX gather).
    static func takeAlong(axis: Int, indices: MLXArray, array: MLXArray) -> MLXArray {
        if axis == 0 && indices.ndim == 1 {
            return array[indices]
        }
        return takeAlong(array, indices, axis: axis)
    }
}
