//
//  GaussianSplat.swift
//  GaussianLIC
//
//  Swift model representing a single Gaussian Splat's parameters.
//  This mirrors the 6-field representation in win_lic/gaussians/gaussian_model.h:
//    xyz, SH dc, SH rest, scaling (log), rotation (quat), opacity (logit).
//
//  Used for:
//    - Constructing splats from LiDAR point clouds (on-device initialization)
//    - Converting between win_lic PLY format and MetalSplatter's
//      EncodedSplatPoint format
//    - Phase 5 on-device training (parameter storage)
//

import Foundation
import simd

/// A single 3D Gaussian Splat with full SH parameters.
/// Matches the PLY export format from win_lic/gaussians/gaussian_model.cpp::saveMap().
struct GaussianSplat {
    // Position (world space)
    var position: SIMD3<Float>

    // Spherical harmonics color
    var shDC: SIMD3<Float>       // SH degree 0 (3 coefficients)
    var shRest: [SIMD3<Float>]   // SH degrees 1-3 (15 coefficients for sh_degree=3)

    // Scale (log space, like win_lic: exp'd on use)
    var scaleLog: SIMD3<Float>

    // Rotation (quaternion, normalized on use)
    var rotation: simd_quatf

    // Opacity (logit, like win_lic: sigmoid'd on use)
    var opacityLogit: Float

    /// Initialize a Gaussian from a LiDAR point with colour.
    /// Matches win_lic/gaussians/gaussian_model.cpp::initialize():
    ///   position = point position
    ///   shDC = RGB2SH(color)
    ///   scale = log(scaling_scale × depth / focal)
    ///   rotation = identity quaternion
    ///   opacity = logit(0.1)
    init(fromPoint point: PointXYZRGB, depth: Float, focal: Float, scalingScale: Float = 0.01) {
        self.position = SIMD3<Float>(point.x, point.y, point.z)

        // RGB2SH: (color - 0.5) / C0, where C0 = 0.28209479177387814
        let c0: Float = 0.28209479177387814
        let r = Float(point.r) / 255.0
        let g = Float(point.g) / 255.0
        let b = Float(point.b) / 255.0
        self.shDC = SIMD3<Float>((r - 0.5) / c0, (g - 0.5) / c0, (b - 0.5) / c0)
        self.shRest = []

        // Scale from depth (closer = smaller splat)
        let s = scalingScale * depth / focal
        self.scaleLog = SIMD3<Float>(log(s), log(s), log(s))

        // Identity rotation
        self.rotation = simd_quatf(identity: ())

        // Opacity = logit(0.1) = ln(0.1 / 0.9)
        self.opacityLogit = log(0.1 / 0.9)
    }

    /// Linear opacity (sigmoid of logit).
    var opacity: Float {
        1.0 / (1.0 + exp(-opacityLogit))
    }

    /// Linear scale (exp of log).
    var scale: SIMD3<Float> {
        simd_exp(scaleLog)
    }

    /// 3D covariance matrix Σ = (R·S)(R·S)^T
    /// This is pre-computed on CPU in MetalSplatter's EncodedSplatPoint.
    var covariance3D: simd_float3x3 {
        let s = scale
        let rs = simd_float3x3(rotation) * simd_float3x3(diagonal: s)
        return rs * rs.transpose
    }
}

/// A collection of Gaussian Splats representing a scene.
struct GaussianSplatScene {
    var splats: [GaussianSplat]

    var count: Int { splats.count }

    /// Back-project an ARKit LiDAR depth map to a point cloud.
    /// Each depth pixel → a 3D point in camera space, then transformed to world.
    static func backprojectDepth(
        depthMap: CVPixelBuffer,
        intrinsics: CameraIntrinsics,
        cameraTransform: simd_float4x4,
        confidenceMap: CVPixelBuffer? = nil,
        confidenceThreshold: Int = 1
    ) -> [PointXYZRGB] {
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }

        var confPtr: UnsafeBufferPointer<UInt8>?
        if let conf = confidenceMap {
            CVPixelBufferLockBaseAddress(conf, .readOnly)
            let confBase = CVPixelBufferGetBaseAddress(conf)!.assumingMemoryBound(to: UInt8.self)
            let confWidth = CVPixelBufferGetWidth(conf)
            confPtr = UnsafeBufferPointer(start: confBase, count: confWidth * CVPixelBufferGetHeight(conf))
            defer { CVPixelBufferUnlockBaseAddress(conf, .readOnly) }
        }

        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)
        let baseAddress = CVPixelBufferGetBaseAddress(depthMap)!.assumingMemoryBound(to: Float.self)

        // Scale intrinsics from RGB resolution to depth resolution.
        let scaleX = Float(width) / Float(intrinsics.width)
        let scaleY = Float(height) / Float(intrinsics.height)
        let fx = intrinsics.fx * scaleX
        let fy = intrinsics.fy * scaleY
        let cx = intrinsics.cx * scaleX
        let cy = intrinsics.cy * scaleY

        var points: [PointXYZRGB] = []
        points.reserveCapacity(width * height / 4)  // estimate ~25% valid pixels

        for y in 0..<height {
            for x in 0..<width {
                let depth = baseAddress[y * (bytesPerRow / MemoryLayout<Float>.size) + x]

                // Skip invalid depth (0 or NaN).
                guard depth > 0, depth.isFinite, depth < 5.0 else { continue }

                // Confidence check.
                if let confPtr, y * width + x < confPtr.count {
                    let conf = confPtr[y * width + x]
                    if Int(conf) < confidenceThreshold { continue }
                }

                // Back-project: pixel → 3D point in camera space.
                let xCam = (Float(x) - cx) * depth / fx
                let yCam = (Float(y) - cy) * depth / fy
                let zCam = depth

                // Transform to world space.
                let camPoint = SIMD4<Float>(xCam, yCam, zCam, 1.0)
                let worldPoint = cameraTransform * camPoint

                // Assign a greyish colour (will be refined during training).
                points.append(PointXYZRGB(
                    x: worldPoint.x, y: worldPoint.y, z: worldPoint.z,
                    r: 128, g: 128, b: 128
                ))
            }
        }

        return points
    }
}
