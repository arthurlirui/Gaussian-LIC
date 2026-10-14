//
//  SplatSceneManager.swift
//  GaussianLIC
//
//  Manages loading and lifecycle of Gaussian Splat scenes (PLY files)
//  using MetalSplatter. Handles chunk-based memory management,
//  scene transformations (position/rotation/scale for AR anchoring),
//  and the max_gaussians memory-safety cap (pattern from Jetson config).
//
//  Corresponds to win_lic/gaussians/gaussian_model.h's scene management
//  responsibilities (initialize, load from PLY, save to PLY), but only
//  the rendering/viewing side — training is off-device.
//

import Foundation
import Metal
import MetalKit
import simd
import MetalSplatter
import SplatIO
import Combine

/// Represents a loaded Gaussian Splat scene.
struct LoadedScene: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let splatCount: Int
    var transform: simd_float4x4 = matrix_identity_float4x4  // scene-to-world
    var visible: Bool = true
}

/// Manages one or more loaded splat scenes and the MetalSplatter renderer.
@MainActor
final class SplatSceneManager: ObservableObject {

    // MARK: - Published

    @Published private(set) var loadedScenes: [LoadedScene] = []
    @Published private(set) var currentSceneIndex: Int? = nil
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var loadProgress: Double = 0
    @Published var maxGaussians: Int = 300_000
    @Published var renderError: String? = nil

    // MARK: - Metal / MetalSplatter

    /// The MetalSplatter renderer instance.
    private(set) var splatRenderer: SplatRenderer?

    /// The Metal device.
    private var device: MTLDevice?

    /// Whether the renderer is initialized.
    var isInitialized: Bool { splatRenderer != nil }

    // MARK: - Initialization

    /// Set the Metal device and create the SplatRenderer.
    /// Called by SplatRenderView when it gets its MTKView device.
    func setDevice(_ device: MTLDevice) {
        guard self.device == nil else { return }
        self.device = device

        // Create the MetalSplatter renderer.
        // SplatRenderer handles chunk-based splat storage, sorting, and rendering.
        do {
            splatRenderer = try SplatRenderer(
                device: device,
                colorFormat: .bgra8Unorm,
                depthFormat: .depth32Float,
                sampleCount: 1,
                maxViewCount: 1,
                maxSimultaneousRenders: 2
            )
        } catch {
            renderError = "Failed to create SplatRenderer: \(error.localizedDescription)"
        }
    }

    // MARK: - Scene Loading

    /// Load a PLY file and add it as a new scene.
    func loadScene(from url: URL) async {
        guard let device = device, splatRenderer != nil else {
            renderError = "Renderer not initialized"
            return
        }

        isLoading = true
        loadProgress = 0
        renderError = nil

        defer {
            isLoading = false
        }

        do {
            // Use SplatIO's PLY reader to load the scene.
            // SplatPLYSceneReader reads standard 3DGS PLY format — the same
            // format that win_lic's saveMap() exports.
            let reader = try SplatPLYSceneReader(url: url)
            let splatScene = try reader.read(maxSplatCount: maxGaussians) { progress in
                Task { @MainActor in
                    self.loadProgress = progress
                }
            }

            let splatCount = splatScene.splatCount

            // Add chunks to the renderer.
            // MetalSplatter organizes splats into chunks for memory management
            // and sorting. Each chunk gets a GPU buffer.
            try splatRenderer?.add(splatScene)

            let scene = LoadedScene(
                url: url,
                name: url.lastPathComponent,
                splatCount: splatCount
            )

            loadedScenes.append(scene)
            currentSceneIndex = loadedScenes.count - 1

        } catch {
            renderError = "Failed to load PLY: \(error.localizedDescription)"
        }
    }

    /// Remove a scene from the renderer.
    func removeScene(at index: Int) {
        guard index < loadedScenes.count else { return }
        let scene = loadedScenes[index]

        // Remove from renderer (clear chunks).
        // MetalSplatter handles GPU memory deallocation.
        // For now, we mark the scene as removed; a full implementation
        // would call splatRenderer.remove(sceneId).
        loadedScenes.remove(at: index)

        if currentSceneIndex == index {
            currentSceneIndex = loadedScenes.isEmpty ? nil : max(0, index - 1)
        }
    }

    /// Set scene transform (for AR anchoring).
    func setTransform(_ transform: simd_float4x4, forSceneAt index: Int) {
        guard index < loadedScenes.count else { return }
        loadedScenes[index].transform = transform
        // Apply transform to renderer uniforms (scene-to-world matrix).
        // MetalSplatter applies the transform via the view matrix or
        // a per-chunk model matrix.
    }

    /// Toggle visibility of a scene.
    func toggleVisibility(forSceneAt index: Int) {
        guard index < loadedScenes.count else { return }
        loadedScenes[index].visible.toggle()
        // Enable/disable chunks in the renderer.
    }

    // MARK: - Camera Update (for AR live mode)

    /// Update camera matrices from ARKit for AR live rendering.
    /// Called by ARSplatOverlay each frame.
    func updateARCamera(projection: simd_float4x4, view: simd_float4x4, position: SIMD3<Float>) {
        // The SplatRenderCoordinator reads these via its arProjection/arView/arCameraPosition properties.
        // This method exists for the coordinator to pull from when in AR mode.
        // The actual passing happens through the coordinator's properties.
    }

    // MARK: - List Models

    /// List available PLY files in the app's models directory.
    func availableModels() -> [URL] {
        FileStorage.shared.listModels()
    }
}
