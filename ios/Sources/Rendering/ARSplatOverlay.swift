//
//  ARSplatOverlay.swift
//  GaussianLIC
//
//  AR mode: renders a RealityKit ARView as the background (providing the
//  live camera feed and ARKit session), with MetalSplatter's splat rendering
//  overlaid on top via a transparent MTKView.
//
//  The ARView's session provides camera matrices (projection + view) that
//  are passed to the SplatRenderCoordinator each frame, so the splats are
//  rendered from the same viewpoint as the real-world camera.
//
//  Users can tap to place the splat scene's origin at a real-world location,
//  anchoring the virtual splat scene in AR space.
//

import SwiftUI
import RealityKit
import ARKit
import simd

/// AR overlay mode view: ARView background + splat rendering overlay.
struct ARSplatOverlay: UIViewRepresentable {

    @ObservedObject var sceneManager: SplatSceneManager
    @ObservedObject var captureSession: CaptureSession

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .ar
        arView.debugOptions = []

        // Configure the AR session for world tracking with LiDAR.
        let config = ARWorldTrackingConfiguration()
        config.frameSemantics = [.sceneDepth]
        config.worldAlignment = .gravity
        arView.session.run(config)

        // Set the coordinator as the session delegate for camera updates.
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator

        // Add tap gesture for placing the splat origin.
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Update coordinator references.
        context.coordinator.sceneManager = sceneManager
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(sceneManager: sceneManager)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, ARSessionDelegate {

        var sceneManager: SplatSceneManager
        weak var arView: ARView?

        /// The splat scene's world-space transform (set by tap-to-place).
        var sceneTransform: simd_float4x4 = matrix_identity_float4x4

        init(sceneManager: SplatSceneManager) {
            self.sceneManager = sceneManager
        }

        // MARK: - ARSessionDelegate

        nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
            Task { @MainActor in
                // Extract camera matrices from the AR frame.
                let projection = frame.camera.projectionMatrix(
                    for: .portrait,
                    viewportSize: arView?.bounds.size ?? CGSize(width: 1920, height: 1440),
                    zNear: 0.001,
                    zFar: 100.0
                )

                let viewMatrix = frame.camera.viewMatrix(for: .portrait)
                let cameraPosition = frame.camera.transform.translation

                // Update the scene manager with AR camera matrices.
                // The SplatRenderCoordinator reads these for AR live mode.
                sceneManager.updateARCamera(
                    projection: projection,
                    view: viewMatrix,
                    position: cameraPosition
                )

                // Store for the coordinator to pass to the render view.
                self.arProjection = projection
                self.arViewMatrix = viewMatrix
                self.arCameraPosition = cameraPosition
            }
        }

        // Cached AR camera state (read by SplatRenderCoordinator).
        var arProjection: simd_float4x4 = matrix_identity_float4x4
        var arViewMatrix: simd_float4x4 = matrix_identity_float4x4
        var arCameraPosition: SIMD3<Float> = .zero

        // MARK: - Tap to Place

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = gesture.location(in: arView)

            // Raycast to find a real-world surface.
            let results = arView.makeRaycastQuery(
                from: location,
                allowing: .estimatedPlane,
                alignment: .any
            )

            if let result = results {
                let transform = result.worldTransform
                sceneTransform = transform
                // Apply the transform to the loaded splat scene.
                if let index = sceneManager.currentSceneIndex {
                    sceneManager.setTransform(transform, forSceneAt: index)
                }
            }
        }
    }
}
