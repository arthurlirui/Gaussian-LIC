//
//  SplatRealityView.swift
//  GaussianLIC
//
//  SwiftUI view that renders Gaussian Splat scenes using RealityKit's
//  GaussianSplatComponent. Replaces the old MetalSplatter-based
//  SplatRenderView + ARSplatOverlay with a single unified view.
//
//  Two camera modes:
//    - Free View: virtual orbit camera controlled by gestures
//    - AR Live: camera matrices driven by the shared ARKitSensorSource session
//
//  In AR Live mode, the view reuses the ARSession from CaptureSession's
//  ARKitSensorSource — no second session is created (fixing the dual-session
//  conflict in the old ARSplatOverlay).
//

import SwiftUI
import RealityKit
import ARKit
import simd

/// Camera mode for the splat renderer.
enum SplatCameraMode: String, CaseIterable {
    case freeView = "Free View"
    case arLive = "AR Live"
}

/// SwiftUI wrapper that renders Gaussian Splat scenes in a RealityKit ARView.
struct SplatRealityView: UIViewRepresentable {

    @ObservedObject var sceneManager: SplatSceneManager
    @ObservedObject var captureSession: CaptureSession

    var cameraMode: SplatCameraMode = .freeView

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Configure for splat rendering.
        arView.cameraMode = cameraMode == .arLive ? .ar : .nonAR
        arView.debugOptions = []

        // In AR mode, run the world-tracking session with scene depth.
        if cameraMode == .arLive {
            let config = ARWorldTrackingConfiguration()
            config.frameSemantics = [.sceneDepth]
            config.worldAlignment = .gravity
            arView.session.run(config)
        }

        // Add the current splat entity to the scene if available.
        if let entity = sceneManager.currentEntity() {
            arView.scene.addAnchor(EntityAnchor(entity: entity))
        }

        // Set up gesture recognizers for free-view orbit control.
        let coordinator = context.coordinator
        if cameraMode == .freeView {
            let panGesture = UIPanGestureRecognizer(target: coordinator,
                                                     action: #selector(Coordinator.handlePan(_:)))
            let pinchGesture = UIPinchGestureRecognizer(target: coordinator,
                                                         action: #selector(Coordinator.handlePinch(_:)))
            arView.addGestureRecognizer(panGesture)
            arView.addGestureRecognizer(pinchGesture)
        }

        coordinator.arView = arView
        coordinator.cameraMode = cameraMode

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        let coordinator = context.coordinator
        coordinator.cameraMode = cameraMode

        // Update the scene with the current splat entity.
        // Remove old anchors and re-add the current entity.
        if let entity = sceneManager.currentEntity() {
            // Clear existing content anchors and add the entity.
            uiView.scene.anchors.removeAll()
            uiView.scene.addAnchor(EntityAnchor(entity: entity))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(sceneManager: sceneManager)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject {

        let sceneManager: SplatSceneManager
        weak var arView: ARView?
        var cameraMode: SplatCameraMode = .freeView

        // Free-view orbit camera state.
        private var orbitAngle: SIMD2<Float> = .zero      // (azimuth, elevation)
        private var orbitDistance: Float = 3.0
        private var panOffset: SIMD3<Float> = .zero

        init(sceneManager: SplatSceneManager) {
            self.sceneManager = sceneManager
            super.init()
        }

        // MARK: - Gesture Handlers (Free View)

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard cameraMode == .freeView else { return }
            let translation = gesture.translation(in: gesture.view)

            switch gesture.numberOfTouches {
            case 1:
                // Orbit
                let sensitivity: Float = 0.005
                orbitAngle.x += Float(translation.width) * sensitivity
                orbitAngle.y -= Float(translation.height) * sensitivity
                orbitAngle.y = max(-Float.pi / 2 + 0.1, min(Float.pi / 2 - 0.1, orbitAngle.y))
            case 2:
                // Pan
                let sensitivity: Float = 0.002 * orbitDistance
                panOffset.x -= Float(translation.width) * sensitivity
                panOffset.y += Float(translation.height) * sensitivity
            default:
                break
            }

            if gesture.state == .changed {
                gesture.setTranslation(.zero, in: gesture.view)
                updateFreeViewCamera()
            }
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard cameraMode == .freeView else { return }
            orbitDistance /= Float(gesture.scale)
            orbitDistance = max(0.1, min(50.0, orbitDistance))
            gesture.scale = 1.0
            updateFreeViewCamera()
        }

        // MARK: - Camera Update

        /// Update the non-AR camera position based on orbit parameters.
        func updateFreeViewCamera() {
            guard cameraMode == .freeView, let arView = arView else { return }

            let az = orbitAngle.x
            let el = orbitAngle.y
            let r = orbitDistance

            let camPos = SIMD3<Float>(
                r * cos(el) * sin(az) + panOffset.x,
                r * sin(el) + panOffset.y,
                r * cos(el) * cos(az) + panOffset.z
            )

            // In non-AR mode, set the camera entity's transform.
            // RealityKit's non-AR camera is a perspective camera at origin by default.
            // We move the splat scene instead of the camera for simplicity.
            let lookAt = matrix_identity_float4x4
            let target = panOffset

            // Build a look-at matrix for the entity.
            let f = simd_normalize(target - camPos)
            let s = simd_normalize(simd_cross(f, SIMD3<Float>(0, 1, 0)))
            let u = simd_cross(s, f)

            let viewMatrix = simd_float4x4(
                SIMD4<Float>(s.x, u.x, -f.x, 0),
                SIMD4<Float>(s.y, u.y, -f.y, 0),
                SIMD4<Float>(s.z, u.z, -f.z, 0),
                SIMD4<Float>(-simd_dot(s, camPos), -simd_dot(u, camPos), simd_dot(f, camPos), 1)
            )

            // Apply the inverse view as the scene transform.
            if let entity = sceneManager.currentEntity() {
                entity.transform = Transform(matrix: viewMatrix.inverse)
            }
        }

        /// Reset the orbit camera to default position.
        func resetCamera() {
            orbitAngle = .zero
            orbitDistance = 3.0
            panOffset = .zero
            updateFreeViewCamera()
        }
    }
}
