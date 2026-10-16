//
//  CaptureSession.swift
//  GaussianLIC
//
//  Manages the capture state machine: idle → previewing → recording → stopped.
//  Owns the ARKitSensorSource and dispatches SensorFrames to the FrameRecorder
//  (when recording) and to the UI (for live preview).
//
//  Corresponds to the main loop in win_lic/core/pipeline.cpp, but event-driven
//  (ARKit pushes frames via callback) rather than a pull-based loop.
//

import Foundation
import ARKit
import Combine
import SwiftUI

/// Capture session state.
enum CaptureState: Equatable {
    case idle
    case previewing
    case recording
    case stopped
    case error(String)
}

/// Statistics about the current capture session.
struct CaptureStats {
    var totalFrames: Int = 0
    var keyframes: Int = 0
    var elapsedSeconds: Double = 0
    var estimatedDiskMB: Double = 0
    var fps: Double = 0
}

/// Main capture session controller.
/// ObservableObject so SwiftUI views can react to state and stats changes.
@MainActor
final class CaptureSession: ObservableObject {

    // MARK: - Published State

    @Published private(set) var state: CaptureState = .idle
    @Published private(set) var stats = CaptureStats()
    @Published private(set) var lastFrame: SensorFrame?
    @Published var config: CaptureConfig = .defaultConfig
    @Published var showDepthOverlay: Bool = true
    @Published var thermalState: ProcessInfo.ThermalState = .nominal

    // MARK: - Components

    /// The ARKit sensor source.
    private var sensorSource: ARKitSensorSource?

    /// Expose the sensor source's ARSession for sharing with ARCameraPreview.
    /// This prevents two competing ARKit sessions on the same device.
    var sharedARSession: ARSession? {
        sensorSource?.session
    }

    /// Frame recorder (activated when recording).
    private var recorder: FrameRecorder?

    /// Current dataset output directory.
    private(set) var datasetURL: URL?

    /// Timer for updating elapsed time.
    private var timer: Timer?
    private var recordingStartTime: Date?

    // MARK: - Public API

    /// Start the ARKit session for live preview (no recording).
    func startPreview() {
        guard state == .idle || state == .stopped else { return }

        let source = ARKitSensorSource(config: config)
        sensorSource = source

        source.onFrame = { [weak self] frame in
            Task { @MainActor in
                self?.handleFrame(frame)
            }
        }
        source.onError = { [weak self] error in
            Task { @MainActor in
                self?.state = .error(error.localizedDescription)
            }
        }

        guard source.open(config: config) else {
            state = .error("Failed to open sensor source (LiDAR not supported?)")
            return
        }
        source.start()
        state = .previewing

        // Start thermal monitoring.
        NotificationCenter.default.addObserver(
            forName: ProcessInfo.thermalStateDidChangeNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.thermalState = ProcessInfo.processInfo.thermalState
            }
        }
    }

    /// Begin recording frames to disk.
    func startRecording() {
        guard state == .previewing else { return }

        let datasetDir = FileStorage.shared.createDatasetDirectory()
        datasetURL = datasetDir

        recorder = FrameRecorder(outputDirectory: datasetDir, config: config)
        recorder?.start()

        recordingStartTime = Date()
        stats = CaptureStats()
        state = .recording

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateStats()
            }
        }
    }

    /// Stop recording and finalize the dataset.
    func stopRecording() {
        guard state == .recording else { return }
        timer?.invalidate()
        timer = nil

        recorder?.stop()
        recorder = nil
        state = .stopped
    }

    /// Stop everything and release resources.
    func stop() {
        if state == .recording {
            stopRecording()
        }
        sensorSource?.stop()
        sensorSource?.close()
        sensorSource = nil
        state = .idle
    }

    // MARK: - Private

    private func handleFrame(_ frame: SensorFrame) {
        lastFrame = frame
        stats.totalFrames = frame.frameIndex + 1
        if frame.isKeyframe {
            stats.keyframes += 1
        }

        // Record if in recording state.
        if state == .recording {
            recorder?.record(frame)
        }
    }

    private func updateStats() {
        guard let start = recordingStartTime else { return }
        stats.elapsedSeconds = Date().timeIntervalSince(start)

        // Estimate FPS from frame timing.
        if stats.elapsedSeconds > 0 {
            stats.fps = Double(stats.totalFrames) / stats.elapsedSeconds
        }

        // Estimate disk usage.
        // Per keyframe: ~200KB JPEG + ~200KB depth + ~50KB conf ≈ 450KB
        // Non-keyframes: same (we record all frames for training)
        stats.estimatedDiskMB = Double(stats.totalFrames) * 0.45

        // Thermal throttle check.
        if thermalState == .serious || thermalState == .critical {
            // Auto-pause recording to protect device.
            if state == .recording {
                stopRecording()
            }
        }
    }
}
