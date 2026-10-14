//
//  SensorFrame.swift
//  GaussianLIC
//
//  Swift equivalent of win_lic/core/types.h::AlignedFrame.
//  Represents a single frame of aligned multi-modal sensor data from ARKit.
//
//  The C++ AlignedFrame uses cv::Mat for images; here we use CVPixelBuffer
//  which is the native ARKit output type and can be directly wrapped as a
//  Metal texture without copies.
//

import Foundation
import ARKit
import CoreVideo
import simd

/// A single IMU measurement (accelerometer + gyroscope) at a point in time.
/// Corresponds to win_lic::ImuMeasurement.
struct IMUSample: Codable {
    var timestamp: Double          // seconds since reference epoch
    var accel: SIMD3<Double>       // m/s^2
    var gyro: SIMD3<Double>        // rad/s

    init(timestamp: Double, accel: SIMD3<Double>, gyro: SIMD3<Double>) {
        self.timestamp = timestamp
        self.accel = accel
        self.gyro = gyro
    }
}

/// Camera pose stored as a 4×4 transform (camera-to-world).
/// Corresponds to win_lic::CameraPose (which uses Eigen quaternion + translation).
/// On iOS, simd_float4x4 is the native ARKit pose representation.
struct CameraPose {
    var timestamp: Double
    var transform: simd_float4x4    // camera-to-world

    /// Extract translation (column 3).
    var translation: SIMD3<Float> {
        SIMD3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }

    /// Extract rotation as a quaternion.
    var rotation: simd_quatf {
        simd_quatf(transform)
    }

    /// World-to-camera (inverse) transform.
    var viewMatrix: simd_float4x4 {
        transform.inverse
    }
}

/// Camera intrinsics extracted from ARCamera.
/// Corresponds to the fx/fy/cx/cy fields used throughout win_lic::Params and Dataset.
struct CameraIntrinsics: Codable {
    var fx: Float
    var fy: Float
    var cx: Float
    var cy: Float
    var width: Int
    var height: Int

    /// Build from ARCamera.intrinsics (3×3 matrix) and image dimensions.
    init(from intrinsics: simd_float3x3, width: Int, height: Int) {
        self.fx = intrinsics.columns.0.x
        self.fy = intrinsics.columns.1.y
        self.cx = intrinsics.columns.2.x
        self.cy = intrinsics.columns.2.y
        self.width = width
        self.height = height
    }

    init(fx: Float, fy: Float, cx: Float, cy: Float, width: Int, height: Int) {
        self.fx = fx
        self.fy = fy
        self.cx = cx
        self.cy = cy
        self.width = width
        self.height = height
    }
}

/// Depth source identifier, mirroring win_lic::DepthSource.
enum DepthSource: Int, Codable {
    case none = 0
    case lidar = 1      // dense, from ARKit LiDAR scanner
    case smoothed = 2   // smoothedSceneDepth (temporally filtered)
    case completed = 5  // after any post-processing
}

/// A single frame of aligned multi-modal data from ARKit.
///
/// This is the Swift counterpart of `winlic::AlignedFrame` (win_lic/core/types.h).
/// Key differences from the C++ version:
/// - Uses `CVPixelBuffer` instead of `cv::Mat` for images (no copy needed from ARKit)
/// - Pose is `simd_float4x4` instead of `Eigen::Quaterniond + Vector3d`
/// - Depth is dense from ARKit LiDAR (no separate sparse/fused/completed stages)
/// - LiDAR point cloud is optional (can be derived from depth + intrinsics on demand)
struct SensorFrame {
    // -- Timestamp --
    let timestamp: Double

    // -- RGB image --
    // ARKit provides capturedImage as a CVPixelBuffer in YUV 420f (kCVPixelFormatType_420YpCbCr8BiPlanarFullRange).
    // For rendering we convert to a Metal texture; for recording we JPEG-encode.
    let image: CVPixelBuffer

    // -- Depth maps (metric, Float32, metres) --
    // ARKit LiDAR provides a dense depth map at 256×192 (iPhone 14 Pro+).
    let depthMap: CVPixelBuffer
    let confidenceMap: CVPixelBuffer?

    // -- Depth source --
    let depthSource: DepthSource

    // -- Camera pose (camera-to-world) --
    let pose: CameraPose

    // -- Camera intrinsics --
    let intrinsics: CameraIntrinsics

    // -- IMU sample closest to this frame's timestamp --
    let imuData: IMUSample?

    // -- Metadata --
    let frameIndex: Int
    var isKeyframe: Bool

    /// Image dimensions.
    var imageWidth: Int { CVPixelBufferGetWidth(image) }
    var imageHeight: Int { CVPixelBufferGetHeight(image) }

    /// Depth map dimensions.
    var depthWidth: Int { CVPixelBufferGetWidth(depthMap) }
    var depthHeight: Int { CVPixelBufferGetHeight(depthMap) }
}

/// A 3D point with colour, corresponding to win_lic::PointXYZRGB.
/// Used when back-projecting LiDAR depth to a point cloud.
struct PointXYZRGB {
    var x: Float
    var y: Float
    var z: Float
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

/// Configuration for the capture session.
/// Mirrors key fields from win_lic::Params (win_lic/core/params.h)
/// that are relevant to the iOS sensor path.
struct CaptureConfig {
    // Keyframe selection
    var keyframeInterval: Int = 5         // select every N-th frame as keyframe
    var keyframeMinTranslation: Float = 0.05  // metres of motion to force a keyframe

    // Depth
    var useSmoothedDepth: Bool = true     // use smoothedSceneDepth instead of raw sceneDepth
    var depthConfidenceThreshold: Int = 2 // 0=low, 1=medium, 2=high

    // Recording
    var maxDiskUsageGB: Double = 2.0      // warn when captured data exceeds this
    var jpegQuality: Float = 0.85

    // Rendering
    var maxGaussians: Int = 300_000       // memory-safety cap, similar to Jetson config
    var renderDownsample: Int = 1         // 1 = full res, 2 = half, 4 = quarter

    // Training bridge (Phase 2)
    var trainingServerURL: String = ""    // e.g. "http://192.168.1.100:8080"

    static let defaultConfig = CaptureConfig()
}
