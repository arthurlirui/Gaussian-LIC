//
//  SplatRenderView.swift
//  GaussianLIC
//
//  UIViewRepresentable wrapper around MTKView that renders Gaussian Splats
//  using MetalSplatter's SplatRenderer. This is the iOS rendering surface
//  for trained PLY scenes.
//
//  Two camera modes:
//    - Free View: virtual orbit camera controlled by gestures
//    - AR Live: camera matrices driven by ARKit session (via ARSplatOverlay)
//
//  The SplatRenderer expects Uniforms (projection, view, camera position, focal
//  length, tan-FOV, chunk/splat counts) which we compute each frame. The Metal
//  shaders in MetalSplatter handle SH evaluation, 2D covariance projection,
//  and front-to-back alpha blending — all 1:1 ports of the CUDA rasterizer
//  in win_lic/cuda/rasterizer/.
//

import SwiftUI
import MetalKit
import simd
import MetalSplatter
import SplatIO

/// Camera mode for the splat renderer.
enum SplatCameraMode {
    case freeView       // Gesture-controlled virtual camera
    case arLive         // ARKit-driven camera (for AR overlay mode)
}

/// UIViewRepresentable that wraps MTKView for Gaussian Splat rendering.
struct SplatRenderView: UIViewRepresentable {

    @ObservedObject var sceneManager: SplatSceneManager

    /// Camera mode (free view or AR live).
    var cameraMode: SplatCameraMode = .freeView

    /// Downsample factor (1 = full res, 2 = half, 4 = quarter).
    var downsample: Int = 1

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MetalHelpers.device
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.sampleCount = 1
        mtkView.clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        mtkView.isOpaque = true
        mtkView.framebufferOnly = true
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false

        // Set up the coordinator as the MTKViewDelegate.
        let coordinator = context.coordinator
        mtkView.delegate = coordinator

        // Attach the Metal device to the scene manager.
        if let device = mtkView.device {
            sceneManager.setDevice(device)
        }

        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        let coordinator = context.coordinator
        coordinator.cameraMode = cameraMode
        coordinator.downsample = downsample

        // Update drawable size if downsample changed.
        if let bounds = uiView.window?.bounds {
            let scaledWidth = Int(bounds.width) / downsample
            let scaledHeight = Int(bounds.height) / downsample
            coordinator.drawableSize = SIMD2<Int>(scaledWidth, scaledHeight)
        }
    }

    func makeCoordinator() -> SplatRenderCoordinator {
        SplatRenderCoordinator(sceneManager: sceneManager)
    }
}

// MARK: - Render Coordinator (MTKViewDelegate)

/// Coordinates between MTKView's draw cycle and MetalSplatter's SplatRenderer.
final class SplatRenderCoordinator: NSObject, MTKViewDelegate {

    let sceneManager: SplatSceneManager

    var cameraMode: SplatCameraMode = .freeView
    var downsample: Int = 1
    var drawableSize: SIMD2<Int> = SIMD2(1920, 1080)

    // Free-view camera state.
    private var orbitAngle: SIMD2<Float> = .zero      // (azimuth, elevation)
    private var orbitDistance: Float = 3.0
    private var panOffset: SIMD3<Float> = .zero

    // AR live camera state (set externally by ARSplatOverlay).
    var arProjectionMatrix: simd_float4x4 = matrix_identity_float4x4
    var arViewMatrix: simd_float4x4 = matrix_identity_float4x4
    var arCameraPosition: SIMD3<Float> = .zero

    // Command queue for rendering.
    private var commandQueue: MTLCommandQueue?

    init(sceneManager: SplatSceneManager) {
        self.sceneManager = sceneManager
        super.init()
        if let device = MetalHelpers.device {
            self.commandQueue = device.makeCommandQueue()
        }
    }

    // MARK: - MTKViewDelegate

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let scaledWidth = Int(size.width) / downsample
        let scaledHeight = Int(size.height) / downsample
        drawableSize = SIMD2<Int>(scaledWidth, scaledHeight)
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderer = sceneManager.splatRenderer,
              let commandBuffer = commandQueue?.makeCommandBuffer() else {
            return
        }

        // Compute camera matrices for this frame.
        let (projection, viewMatrix, cameraPosition) = computeCameraMatrices(view)

        // Build viewport descriptor for MetalSplatter.
        let viewport = MTLViewport(
            originX: 0, originY: 0,
            width: Double(drawableSize.x), height: Double(drawableSize.y),
            znear: 0.001, zfar: 100.0
        )

        let screenSize = SIMD2<UInt32>(UInt32(drawableSize.x), UInt32(drawableSize.y))

        // Compute focal length and tan-FOV from projection matrix.
        // MetalSplatter expects:
        //   focalX = screenSize.x * projectionMatrix[0][0] / 2
        //   focalY = screenSize.y * projectionMatrix[1][1] / 2
        //   tanHalfFovX = 1 / projectionMatrix[0][0]
        //   tanHalfFovY = 1 / projectionMatrix[1][1]
        let focalX = Float(drawableSize.x) * projection.columns.0.x / 2.0
        let focalY = Float(drawableSize.y) * projection.columns.1.y / 2.0
        let tanHalfFovX = 1.0 / projection.columns.0.x
        let tanHalfFovY = 1.0 / projection.columns.1.y

        // Update uniforms for the renderer.
        renderer.updateViewports([
            SplatRenderer.ViewportDescriptor(
                viewport: viewport,
                projectionMatrix: projection,
                viewMatrix: viewMatrix,
                screenSize: SIMD2<Int>(Int(drawableSize.x), Int(drawableSize.y))
            )
        ])

        // Render splats.
        renderer.render(
            to: drawable,
            with: commandBuffer,
            renderPassDescriptor: renderPassDescriptor,
            clearColour: view.clearColor
        )

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    // MARK: - Camera Matrix Computation

    private func computeCameraMatrices(_ view: MTKView) -> (simd_float4x4, simd_float4x4, SIMD3<Float>) {
        switch cameraMode {
        case .freeView:
            return computeFreeViewMatrices()
        case .arLive:
            return (arProjectionMatrix, arViewMatrix, arCameraPosition)
        }
    }

    /// Compute orbit camera matrices for free-view mode.
    private func computeFreeViewMatrices() -> (simd_float4x4, simd_float4x4, SIMD3<Float>) {
        let aspect = Float(drawableSize.x) / Float(drawableSize.y)
        let fov: Float = .pi / 3  // 60 degrees
        let near: Float = 0.001
        let far: Float = 100.0

        let projection = makePerspective(fov: fov, aspect: aspect, near: near, far: far)

        // Spherical orbit camera.
        let az = orbitAngle.x
        let el = orbitAngle.y
        let r = orbitDistance

        let camPos = SIMD3<Float>(
            r * cos(el) * sin(az) + panOffset.x,
            r * sin(el) + panOffset.y,
            r * cos(el) * cos(az) + panOffset.z
        )

        let target = panOffset
        let up = SIMD3<Float>(0, 1, 0)

        let viewMatrix = makeLookAt(eye: camPos, target: target, up: up)

        return (projection, viewMatrix, camPos)
    }

    // MARK: - Gesture Handling

    /// Handle one-finger drag (orbit).
    func onDrag(_ gesture: DragGesture.Value) {
        let sensitivity: Float = 0.005
        orbitAngle.x += Float(gesture.translation.width) * sensitivity
        orbitAngle.y -= Float(gesture.translation.height) * sensitivity
        // Clamp elevation.
        orbitAngle.y = max(-Float.pi / 2 + 0.1, min(Float.pi / 2 - 0.1, orbitAngle.y))
    }

    /// Handle pinch (zoom).
    func onMagnify(_ scale: CGFloat) {
        orbitDistance /= Float(scale)
        orbitDistance = max(0.1, min(50.0, orbitDistance))
    }

    /// Handle two-finger pan.
    func onPan(_ gesture: DragGesture.Value) {
        let sensitivity: Float = 0.002 * orbitDistance
        panOffset.x -= Float(gesture.translation.width) * sensitivity
        panOffset.y += Float(gesture.translation.height) * sensitivity
    }

    /// Reset camera to default position.
    func resetCamera() {
        orbitAngle = .zero
        orbitDistance = 3.0
        panOffset = .zero
    }

    // MARK: - Matrix Helpers

    private func makePerspective(fov: Float, aspect: Float, near: Float, far: Float) -> simd_float4x4 {
        let f = 1.0 / tan(fov / 2.0)
        return simd_float4x4(
            SIMD4<Float>(f / aspect, 0, 0, 0),
            SIMD4<Float>(0, f, 0, 0),
            SIMD4<Float>(0, 0, far / (near - far), -1),
            SIMD4<Float>(0, 0, near * far / (near - far), 0)
        )
    }

    private func makeLookAt(eye: SIMD3<Float>, target: SIMD3<Float>, up: SIMD3<Float>) -> simd_float4x4 {
        let f = simd_normalize(target - eye)
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
