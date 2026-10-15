//
//  SplatRealityView.swift
//  GaussianLIC
//
//  SwiftUI view that renders Gaussian Splat scenes using MetalSplatter's
//  SplatRenderer (Metal-based 3DGS rasterizer, iOS 18+).
//
//  Two camera modes:
//    - Free View: virtual orbit camera controlled by gestures
//    - AR Live: camera matrices driven by the shared ARKitSensorSource session
//
//  Replaces the previous RealityKit GaussianSplatComponent implementation
//  (which required unreleased iOS 27 APIs) with MetalSplatter's MTKView-based
//  rendering pipeline, following the pattern from MetalSplatter's SampleApp
//  (MetalKitSceneRenderer.swift).
//

import SwiftUI
import Metal
import MetalKit
import MetalSplatter
import simd

/// Camera mode for the splat renderer.
enum SplatCameraMode: String, CaseIterable {
    case freeView = "Free View"
    case arLive = "AR Live"
}

/// SwiftUI wrapper that renders Gaussian Splat scenes in an MTKView
/// using MetalSplatter's SplatRenderer.
struct SplatRealityView: UIViewRepresentable {

    @ObservedObject var sceneManager: SplatSceneManager
    @ObservedObject var captureSession: CaptureSession

    var cameraMode: SplatCameraMode = .freeView

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView(frame: .zero, device: MetalHelpers.device)

        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.sampleCount = 1
        mtkView.clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        mtkView.isOpaque = true
        mtkView.framebufferOnly = true
        mtkView.preferredFramesPerSecond = 60

        let coordinator = context.coordinator
        coordinator.configure(view: mtkView, sceneManager: sceneManager, cameraMode: cameraMode)

        // Gesture recognizers for free-view orbit control.
        if cameraMode == .freeView {
            let panGesture = UIPanGestureRecognizer(target: coordinator,
                                                     action: #selector(Coordinator.handlePan(_:)))
            let pinchGesture = UIPinchGestureRecognizer(target: coordinator,
                                                         action: #selector(Coordinator.handlePinch(_:)))
            mtkView.addGestureRecognizer(panGesture)
            mtkView.addGestureRecognizer(pinchGesture)
        }

        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        let coordinator = context.coordinator
        coordinator.cameraMode = cameraMode
        coordinator.sceneManager = sceneManager
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: - Coordinator (MTKViewDelegate)

    final class Coordinator: NSObject, MTKViewDelegate {

        weak var mtkView: MTKView?
        var sceneManager: SplatSceneManager?
        var cameraMode: SplatCameraMode = .freeView

        private var device: MTLDevice?
        private var commandQueue: MTLCommandQueue?
        private let inFlightSemaphore = DispatchSemaphore(value: 3)

        // Free-view orbit camera state.
        private var orbitAngle: SIMD2<Float> = .zero      // (azimuth, elevation)
        private var orbitDistance: Float = 3.0
        private var panOffset: SIMD3<Float> = .zero

        private var drawableSize: CGSize = .zero

        private static let fovy: Float = 60.0 * .pi / 180.0
        private static let nearZ: Float = 0.05
        private static let farZ: Float = 100.0

        func configure(view: MTKView, sceneManager: SplatSceneManager, cameraMode: SplatCameraMode) {
            self.mtkView = view
            self.sceneManager = sceneManager
            self.cameraMode = cameraMode
            self.device = view.device
            self.commandQueue = view.device?.makeCommandQueue()
            view.delegate = self
        }

        // MARK: - MTKViewDelegate

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            drawableSize = size
        }

        func draw(in view: MTKView) {
            guard let sceneManager else { return }
            guard let renderer = sceneManager.currentRenderer() else { return }
            guard renderer.isReadyToRender else { return }
            guard let drawable = view.currentDrawable else { return }
            guard let commandQueue, let commandBuffer = commandQueue.makeCommandBuffer() else { return }

            _ = inFlightSemaphore.wait(timeout: .distantFuture)
            let semaphore = inFlightSemaphore
            commandBuffer.addCompletedHandler { _ in
                semaphore.signal()
            }

            let viewport = makeViewportDescriptor(view: view)

            let didRender: Bool
            do {
                didRender = try renderer.render(
                    viewports: [viewport],
                    colorTexture: view.multisampleColorTexture ?? drawable.texture,
                    colorStoreAction: view.multisampleColorTexture == nil ? .store : .multisampleResolve,
                    depthTexture: view.depthStencilTexture,
                    rasterizationRateMap: nil,
                    renderTargetArrayLength: 0,
                    to: commandBuffer
                )
            } catch {
                didRender = false
            }

            if didRender {
                commandBuffer.present(drawable)
            }
            commandBuffer.commit()
        }

        // MARK: - Viewport

        private func makeViewportDescriptor(view: MTKView) -> SplatRenderer.ViewportDescriptor {
            let aspect = Float(drawableSize.width / max(drawableSize.height, 1))
            let projection = perspective(fovy: Self.fovy, aspect: aspect, near: Self.nearZ, far: Self.farZ)

            let viewMatrix: simd_float4x4
            switch cameraMode {
            case .freeView:
                viewMatrix = freeViewMatrix()
            case .arLive:
                // Use the latest ARKit camera pose if available.
                if let arPose = sceneManager?.currentARCameraTransform {
                    viewMatrix = arPose.inverse
                } else {
                    viewMatrix = freeViewMatrix()
                }
            }

            // Common 3DGS PLY files are often Z-up; rotate to Y-up for display.
            let zUpCorrection = simd_float4x4(
                SIMD4<Float>(1, 0, 0, 0),
                SIMD4<Float>(0, 0, 1, 0),
                SIMD4<Float>(0, -1, 0, 0),
                SIMD4<Float>(0, 0, 0, 1)
            )

            let viewport = MTLViewport(originX: 0, originY: 0,
                                       width: drawableSize.width,
                                       height: drawableSize.height,
                                       znear: 0, zfar: 1)

            return SplatRenderer.ViewportDescriptor(
                viewport: viewport,
                projectionMatrix: projection,
                viewMatrix: viewMatrix * zUpCorrection,
                screenSize: SIMD2(x: Int(drawableSize.width), y: Int(drawableSize.height))
            )
        }

        private func freeViewMatrix() -> simd_float4x4 {
            let az = orbitAngle.x
            let el = orbitAngle.y
            let r = orbitDistance

            let camPos = SIMD3<Float>(
                r * cos(el) * sin(az) + panOffset.x,
                r * sin(el) + panOffset.y,
                r * cos(el) * cos(az) + panOffset.z
            )

            let target = panOffset
            return lookAt(eye: camPos, center: target, up: SIMD3<Float>(0, 1, 0))
        }

        // MARK: - Gesture Handlers (Free View)

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard cameraMode == .freeView else { return }
            let translation = gesture.translation(in: gesture.view)

            switch gesture.numberOfTouches {
            case 1:
                let sensitivity: Float = 0.005
                orbitAngle.x += Float(translation.width) * sensitivity
                orbitAngle.y -= Float(translation.height) * sensitivity
                orbitAngle.y = max(-Float.pi / 2 + 0.1, min(Float.pi / 2 - 0.1, orbitAngle.y))
            case 2:
                let sensitivity: Float = 0.002 * orbitDistance
                panOffset.x -= Float(translation.width) * sensitivity
                panOffset.y += Float(translation.height) * sensitivity
            default:
                break
            }

            if gesture.state == .changed {
                gesture.setTranslation(.zero, in: gesture.view)
            }
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard cameraMode == .freeView else { return }
            orbitDistance /= Float(gesture.scale)
            orbitDistance = max(0.1, min(50.0, orbitDistance))
            gesture.scale = 1.0
        }

        /// Reset the orbit camera to default position.
        func resetCamera() {
            orbitAngle = .zero
            orbitDistance = 3.0
            panOffset = .zero
        }

        // MARK: - Matrix Helpers

        private func perspective(fovy: Float, aspect: Float, near: Float, far: Float) -> simd_float4x4 {
            let f = 1.0 / tan(fovy / 2.0)
            return simd_float4x4(
                SIMD4<Float>(f / aspect, 0, 0, 0),
                SIMD4<Float>(0, f, 0, 0),
                SIMD4<Float>(0, 0, far / (near - far), -1),
                SIMD4<Float>(0, 0, near * far / (near - far), 0)
            )
        }

        private func lookAt(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> simd_float4x4 {
            let f = simd_normalize(center - eye)
            let s = simd_normalize(simd_cross(f, up))
            let u = simd_cross(s, f)
            return simd_float4x4(
                SIMD4<Float>(s.x, u.x, -f.x, 0),
                SIMD4<Float>(s.y, u.y, -f.y, 0),
                SIMD4<Float>(s.z, u.z, -f.z, 0),
                SIMD4<Float>(-simd_dot(s, eye), -simd_dot(u, eye), simd_dot(f, eye), 1)
            )
        }
    }
}
