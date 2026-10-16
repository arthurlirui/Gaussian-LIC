//
//  CaptureView.swift
//  GaussianLIC
//
//  SwiftUI view for the Capture tab.
//  Shows a live ARKit camera preview with recording controls,
//  depth overlay toggle, and capture statistics.
//

import SwiftUI
import ARKit
import RealityKit

struct CaptureView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                // AR camera preview.
                ARCameraPreview(captureSession: appState.captureSession)
                    .ignoresSafeArea()

                // Depth overlay (if enabled and available).
                if appState.captureSession.showDepthOverlay,
                   let frame = appState.captureSession.lastFrame {
                    DepthOverlayView(frame: frame)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }

                // Controls overlay.
                VStack {
                    Spacer()

                    // Stats bar.
                    CaptureStatsBar(stats: appState.captureSession.stats,
                                     state: appState.captureSession.state,
                                     thermalState: appState.captureSession.thermalState)

                    // Recording controls.
                    CaptureControlsBar(
                        state: appState.captureSession.state,
                        onStart: { appState.captureSession.startPreview() },
                        onRecord: { appState.captureSession.startRecording() },
                        onStop: { appState.captureSession.stopRecording() },
                        onClose: { appState.captureSession.stop() }
                    )
                    .padding(.bottom, 30)
                }

                // Error banner.
                if case .error(let message) = appState.captureSession.state {
                    VStack {
                        ErrorBanner(message: message)
                            .padding(.top, 60)
                        Spacer()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle("Depth", isOn: $appState.captureSession.showDepthOverlay)
                        .toggleStyle(.button)
                        .tint(.blue)
                }
            }
            .navigationTitle("Capture")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - AR Camera Preview

/// Renders the ARKit camera feed using a shared ARSession.
///
/// IMPORTANT: This view does NOT create its own ARSession. On a real iPhone,
/// running two ARKit sessions simultaneously causes camera conflicts and
/// frame delivery failures. Instead, it attaches a RealityKit ARView to the
/// ARSession owned by CaptureSession's ARKitSensorSource. The preview starts
/// passively (no recording); when the user taps "Start Preview", the
/// CaptureSession opens its ARKitSensorSource and this view connects to
/// that session.
struct ARCameraPreview: UIViewRepresentable {

    let captureSession: CaptureSession

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .ar
        arView.debugOptions = []

        // If the capture session already has a running ARSession, attach to it.
        // Otherwise, the view will be updated once the session starts.
        if let sharedSession = captureSession.sharedARSession {
            // Don't re-run the config — the sensor source already started it.
            // Just point the ARView at the existing session for rendering.
            arView.session = sharedSession
        } else {
            // No active session yet — run a minimal preview config.
            // This is replaced when the user taps "Start Preview".
            let config = ARWorldTrackingConfiguration()
            config.frameSemantics = [.sceneDepth]
            config.worldAlignment = .gravity
            arView.session.run(config)
        }

        context.coordinator.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // If the capture session now has a shared session and we're still
        // using our own, switch to the shared one.
        if let sharedSession = captureSession.sharedARSession,
           uiView.session !== sharedSession {
            uiView.session = sharedSession
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        weak var arView: ARView?
    }
}

// MARK: - Depth Overlay

/// Shows a colourized depth map overlaid on the camera feed.
struct DepthOverlayView: View {
    let frame: SensorFrame

    var body: some View {
        if let depthImage = DepthVisualization.colourize(depthMap: frame.depthMap) {
            Image(uiImage: depthImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.35)
        }
    }
}

// MARK: - Stats Bar

struct CaptureStatsBar: View {
    let stats: CaptureStats
    let state: CaptureState
    let thermalState: ProcessInfo.ThermalState

    var body: some View {
        HStack(spacing: 16) {
            StatChip(label: "FPS", value: String(format: "%.1f", stats.fps))
            StatChip(label: "Frames", value: "\(stats.totalFrames)")
            StatChip(label: "Keyframes", value: "\(stats.keyframes)")
            StatChip(label: "Disk", value: String(format: "%.1f MB", stats.estimatedDiskMB))

            if thermalState != .nominal {
                Image(systemName: "thermometer.medium")
                    .foregroundColor(thermalState == .critical ? .red : .orange)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.bottom, 8)
    }
}

struct StatChip: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.subheadline, design: .monospaced).bold())
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Controls

struct CaptureControlsBar: View {
    let state: CaptureState
    let onStart: () -> Void
    let onRecord: () -> Void
    let onStop: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 24) {
            switch state {
            case .idle, .stopped:
                Button(action: onStart) {
                    Label("Start Preview", systemImage: "camera.viewfinder")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)

            case .previewing:
                Button(action: onRecord) {
                    Image(systemName: "record.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                }
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }

            case .recording:
                Button(action: onStop) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                }

            case .error:
                Button(action: onStart) {
                    Label("Retry", systemImage: "arrow.clockwise")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(12)
        .background(Color.red.opacity(0.8))
        .cornerRadius(12)
    }
}
