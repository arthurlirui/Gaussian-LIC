//
//  SplatSceneManager.swift
//  GaussianLIC
//
//  Manages loading and lifecycle of Gaussian Splat scenes (PLY/SPZ/.splat files)
//  using MetalSplatter's SplatRenderer for Metal-based GPU rendering (iOS 18+).
//
//  Loading: AutodetectSceneReader → [SplatPoint] → SplatChunk → SplatRenderer.addChunk
//  Rendering: SplatRenderer.render(viewports:...) called per-frame by SplatRealityView
//
//  Replaces the previous RealityKit GaussianSplatComponent implementation
//  (which required unreleased iOS 27 APIs).
//
//  Corresponds to win_lic/gaussians/gaussian_model.h's scene management
//  responsibilities (initialize, load from PLY, save to PLY), but only
//  the rendering/viewing side — training is handled by OnDeviceTrainer
//  or the off-device pipeline.
//

import Foundation
import Metal
import MetalSplatter
import SplatIO
import simd
import Combine

/// Represents a loaded Gaussian Splat scene.
struct LoadedScene: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let splatCount: Int
    var chunkID: ChunkID?
    var transform: simd_float4x4 = matrix_identity_float4x4  // scene-to-world
    var visible: Bool = true
}

/// Manages one or more loaded splat scenes using MetalSplatter's
/// SplatRenderer for native Metal GPU rendering.
@MainActor
final class SplatSceneManager: ObservableObject {

    // MARK: - Published

    @Published private(set) var loadedScenes: [LoadedScene] = []
    @Published private(set) var currentSceneIndex: Int? = nil
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var loadProgress: Double = 0
    @Published var maxGaussians: Int = 500_000
    @Published var renderError: String? = nil

    // MARK: - State

    /// Whether any scene has been loaded.
    var isInitialized: Bool { !loadedScenes.isEmpty }

    /// The shared SplatRenderer instance — one renderer for all loaded chunks.
    private var splatRenderer: SplatRenderer?

    /// Latest ARKit camera transform (set by ARKitSensorSource in AR Live mode).
    var currentARCameraTransform: simd_float4x4 = matrix_identity_float4x4

    // MARK: - Renderer Access

    /// Get the shared SplatRenderer for the current scene (for SplatRealityView).
    func currentRenderer() -> SplatRenderer? {
        guard loadedScenes.contains(where: { $0.chunkID != nil }) else { return nil }
        return splatRenderer
    }

    // MARK: - Scene Loading

    /// Load a PLY/SPZ/.splat file and add it to the shared SplatRenderer.
    func loadScene(from url: URL) async {
        isLoading = true
        loadProgress = 0
        renderError = nil

        defer {
            isLoading = false
        }

        do {
            // Lazily create the SplatRenderer on first load.
            if splatRenderer == nil {
                guard let device = MetalHelpers.device else {
                    renderError = "Metal device not available"
                    return
                }
                splatRenderer = try SplatRenderer(
                    device: device,
                    colorFormat: .bgra8Unorm_srgb,
                    depthFormat: .depth32Float,
                    sampleCount: 1,
                    maxViewCount: 1,
                    maxSimultaneousRenders: 3
                )
            }

            loadProgress = 0.2

            // Auto-detect file format (PLY, SPZ, .splat) and read all splats.
            let reader = try AutodetectSceneReader(url)
            let points = try await reader.readAll()

            guard !points.isEmpty else {
                renderError = "No splats found in file"
                return
            }

            loadProgress = 0.6

            // Cap splat count to the configured maximum.
            let trimmedPoints = points.count > maxGaussians
                ? Array(points.shuffled().prefix(maxGaussians))
                : points

            // Build a SplatChunk and add it to the renderer.
            guard let device = MetalHelpers.device else {
                renderError = "Metal device not available"
                return
            }
            let chunk = try SplatChunk(device: device, from: trimmedPoints)
            let chunkID = await splatRenderer!.addChunk(chunk)

            loadProgress = 1.0

            let scene = LoadedScene(
                url: url,
                name: url.lastPathComponent,
                splatCount: trimmedPoints.count,
                chunkID: chunkID
            )

            loadedScenes.append(scene)
            currentSceneIndex = loadedScenes.count - 1

        } catch {
            renderError = "Failed to load splat file: \(error.localizedDescription)"
        }
    }

    /// Remove a scene and release its chunk from the renderer.
    func removeScene(at index: Int) {
        guard index < loadedScenes.count else { return }

        if let chunkID = loadedScenes[index].chunkID, let renderer = splatRenderer {
            Task { await renderer.removeChunk(chunkID) }
        }

        loadedScenes.remove(at: index)

        if currentSceneIndex == index {
            currentSceneIndex = loadedScenes.isEmpty ? nil : max(0, index - 1)
        } else if let curr = currentSceneIndex, curr > index {
            currentSceneIndex = curr - 1
        }
    }

    /// Remove all loaded scenes.
    func removeAllScenes() {
        if let renderer = splatRenderer {
            Task { await renderer.removeAllChunks() }
        }
        loadedScenes.removeAll()
        currentSceneIndex = nil
    }

    /// Set scene transform (for AR anchoring or manual placement).
    func setTransform(_ transform: simd_float4x4, forSceneAt index: Int) {
        guard index < loadedScenes.count else { return }
        loadedScenes[index].transform = transform
    }

    /// Toggle visibility of a scene.
    func toggleVisibility(forSceneAt index: Int) {
        guard index < loadedScenes.count else { return }
        let newValue = !loadedScenes[index].visible
        loadedScenes[index].visible = newValue

        if let chunkID = loadedScenes[index].chunkID, let renderer = splatRenderer {
            Task { await renderer.setChunkEnabled(chunkID, enabled: newValue) }
        }
    }

    /// Get the splat count for the current scene.
    var currentSplatCount: Int {
        guard let index = currentSceneIndex, index < loadedScenes.count else { return 0 }
        return loadedScenes[index].splatCount
    }

    /// Get the name for the current scene.
    var currentSceneName: String {
        guard let index = currentSceneIndex, index < loadedScenes.count else { return "" }
        return loadedScenes[index].name
    }

    // MARK: - List Models

    /// List available PLY files in the app's models directory.
    func availableModels() -> [URL] {
        FileStorage.shared.listModels()
    }

    // MARK: - AR Camera Update

    /// Called by ARKitSensorSource to update the camera transform for AR Live rendering.
    func updateARCameraTransform(_ transform: simd_float4x4) {
        currentARCameraTransform = transform
    }
}
