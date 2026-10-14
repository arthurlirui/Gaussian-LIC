//
//  ARKitSensorSource.swift
//  GaussianLIC
//
//  Swift implementation of the ISensorSource interface (win_lic/sensors/isensor_source.h).
//  Uses ARKit's ARWorldTrackingConfiguration to provide:
//    - RGB camera frames (capturedImage)
//    - LiDAR depth maps (sceneDepth / smoothedSceneDepth)
//    - Depth confidence maps
//    - Camera pose (VIO-fused transform)
//    - Camera intrinsics
//    - Raw IMU data (via IMURecorder / CoreMotion)
//
//  This is the iOS equivalent of DatasetReader or OrbbecSource in win_lic.
//  The downstream pipeline (CaptureSession, FrameRecorder) consumes SensorFrame
//  objects from this source, just as the C++ pipeline consumes AlignedFrame
//  from ISensorSource::nextFrame().
//

import Foundation
import ARKit
import Combine
import CoreVideo

/// Protocol mirroring win_lic::ISensorSource.
/// Any sensor source — ARKit live, offline file reader, or future SDK — implements this.
protocol SensorSource: AnyObject {
    func open(config: CaptureConfig) -> Bool
    func start()
    func stop()
    func close()
    var isRunning: Bool { get }
    var name: String { get }
}

/// Live sensor source backed by ARKit on LiDAR-equipped iPhones (14 Pro+).
///
/// ARWorldTrackingConfiguration with .sceneDepth provides:
///   - ARFrame.capturedImage      → RGB (YUV 420f CVPixelBuffer, 1920×1440 on iPhone 14 Pro)
///   - ARFrame.sceneDepth.depthMap → Float32 depth in metres (256×192)
///   - ARFrame.sceneDepth.confidenceMap → UInt8 confidence (0=low, 1=medium, 2=high)
///   - ARFrame.camera.transform   → simd_float4x4 camera-to-world pose (VIO-fused)
///   - ARFrame.camera.intrinsics  → simd_float3x3 camera intrinsics (pixel units)
///
/// The LiDAR depth is already dense (no sparse-to-dense completion needed),
/// unlike win_lic which requires SPNet/TensorRT for depth completion.
final class ARKitSensorSource: NSObject, SensorSource {

    // MARK: - Public Properties

    let name = "ARKitSensorSource"
    private(set) var isRunning = false

    /// Current configuration.
    private(set) var config: CaptureConfig

    /// The ARKit session.
    let session = ARSession()

    /// IMU recorder for raw accelerometer/gyroscope data.
    let imuRecorder = IMURecorder()

    /// Frame counter.
    private(set) var frameIndex: Int = 0

    // MARK: - Callbacks

    /// Called on each new ARFrame with the constructed SensorFrame.
    /// This is the primary output of the sensor source, equivalent to
    /// ISensorSource::nextFrame() but push-based (ARKit is callback-driven).
    var onFrame: ((SensorFrame) -> Void)?

    /// Called when the AR session fails to start or encounters an error.
    var onError: ((Error) -> Void)?

    /// Called when the AR session is interrupted (e.g. app backgrounded).
    var onInterruption: (() -> Void)?

    /// Called when the AR session resumes after an interruption.
    var onInterruptionEnded: (() -> Void)?

    // MARK: - Private

    private var lastKeyframePosition: SIMD3<Float> = .zero
    private let arConfiguration = ARWorldTrackingConfiguration()

    // MARK: - Init

    init(config: CaptureConfig = .defaultConfig) {
        self.config = config
        super.init()
    }

    // MARK: - SensorSource Protocol

    func open(config: CaptureConfig) -> Bool {
        self.config = config

        // Verify LiDAR / scene depth support.
        guard ARWorldTrackingConfiguration.supportsFrameSemantics([.sceneDepth]) else {
            onError?(SensorError.lidarNotSupported)
            return false
        }

        // Configure ARKit.
        arConfiguration.frameSemantics = [.sceneDepth]
        if config.useSmoothedDepth {
            arConfiguration.frameSemantics.insert(.smoothedSceneDepth)
        }

        // World tracking with automatic alignment.
        arConfiguration.worldAlignment = .gravity
        arConfiguration.providesAudioData = false

        // Set ourselves as the session delegate.
        session.delegate = self
        session.delegateQueue = .main

        return true
    }

    func start() {
        guard !isRunning else { return }

        session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
        imuRecorder.start()
        frameIndex = 0
        lastKeyframePosition = .zero
        isRunning = true
    }

    func stop() {
        guard isRunning else { return }
        session.pause()
        _ = imuRecorder.stop()
        isRunning = false
    }

    func close() {
        stop()
        session.delegate = nil
    }

    // MARK: - Keyframe Selection

    /// Determine if the current frame should be a keyframe based on the
    /// configured interval and minimum translation threshold.
    /// Mirrors the keyframe logic in win_lic/core/pipeline.cpp::processFrame().
    private func shouldSelectKeyframe(currentPosition: SIMD3<Float>) -> Bool {
        // Interval-based: every N-th frame
        if frameIndex > 0 && frameIndex % config.keyframeInterval == 0 {
            return true
        }
        // Motion-based: if moved far enough since last keyframe
        let distance = simd_distance(currentPosition, lastKeyframePosition)
        if distance >= config.keyframeMinTranslation {
            lastKeyframePosition = currentPosition
            return true
        }
        return false
    }
}

// MARK: - ARSessionDelegate

extension ARKitSensorSource: ARSessionDelegate {

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Extract depth data. Prefer smoothed depth if configured and available.
        let sceneDepth: ARSceneDepth?
        if config.useSmoothedDepth, let smoothed = frame.smoothedSceneDepth {
            sceneDepth = smoothed
        } else {
            sceneDepth = frame.sceneDepth
        }

        guard let depth = sceneDepth else { return }

        // Build camera pose.
        let pose = CameraPose(
            timestamp: frame.timestamp,
            transform: frame.camera.transform
        )

        // Build intrinsics from the captured image dimensions.
        let imageWidth = CVPixelBufferGetWidth(frame.capturedImage)
        let imageHeight = CVPixelBufferGetHeight(frame.capturedImage)
        let intrinsics = CameraIntrinsics(
            from: frame.camera.intrinsics,
            width: imageWidth,
            height: imageHeight
        )

        // Snapshot IMU data closest to this frame.
        let imuSample = imuRecorder.latestSample()

        // Keyframe selection.
        let currentPosition = pose.translation
        let isKeyframe = shouldSelectKeyframe(currentPosition: currentPosition)

        // Determine depth source.
        let depthSource: DepthSource = config.useSmoothedDepth ? .smoothed : .lidar

        // Construct the SensorFrame.
        let sensorFrame = SensorFrame(
            timestamp: frame.timestamp,
            image: frame.capturedImage,
            depthMap: depth.depthMap,
            confidenceMap: depth.confidenceMap,
            depthSource: depthSource,
            pose: pose,
            intrinsics: intrinsics,
            imuData: imuSample,
            frameIndex: frameIndex,
            isKeyframe: isKeyframe
        )

        frameIndex += 1
        onFrame?(sensorFrame)
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        onError?(error)
    }

    func sessionWasInterrupted(_ session: ARSession) {
        onInterruption?()
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        onInterruptionEnded?()
    }
}

// MARK: - Errors

enum SensorError: LocalizedError {
    case lidarNotSupported
    case sessionFailed(String)

    var errorDescription: String? {
        switch self {
        case .lidarNotSupported:
            return "This device does not support LiDAR scene depth. An iPhone Pro model (14 Pro or later) is required."
        case .sessionFailed(let message):
            return "ARKit session failed: \(message)"
        }
    }
}
