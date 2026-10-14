//
//  SplatSceneManager.swift
//  GaussianLIC
//
//  Manages loading and lifecycle of Gaussian Splat scenes (PLY files)
//  using Apple's native RealityKit GaussianSplatComponent (iOS 27+).
//
//  Replaces the previous MetalSplatter-based implementation with the
//  built-in RealityKit API: PLY → GaussianSplatBuffers →
//  GaussianSplatResource.BufferResource → GaussianSplatResource →
//  GaussianSplatComponent → Entity.
//
//  Corresponds to win_lic/gaussians/gaussian_model.h's scene management
//  responsibilities (initialize, load from PLY, save to PLY), but only
//  the rendering/viewing side — training is handled by OnDeviceTrainer
//  or the off-device pipeline.
//

import Foundation
import RealityKit
import simd
import Combine

/// Represents a loaded Gaussian Splat scene.
struct LoadedScene: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let splatCount: Int
    var entity: Entity?
    var transform: simd_float4x4 = matrix_identity_float4x4  // scene-to-world
    var visible: Bool = true
}

/// Manages one or more loaded splat scenes using RealityKit's
/// GaussianSplatComponent for native GPU rendering.
@MainActor
final class SplatSceneManager: ObservableObject {

    // MARK: - Published

    @Published private(set) var loadedScenes: [LoadedScene] = []
    @Published private(set) var currentSceneIndex: Int? = nil
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var loadProgress: Double = 0
    @Published var maxGaussians: Int = 200_000
    @Published var renderError: String? = nil

    // MARK: - State

    /// Whether any scene has been loaded.
    var isInitialized: Bool { !loadedScenes.isEmpty }

    // MARK: - Scene Loading

    /// Load a PLY file and create a RealityKit Entity with GaussianSplatComponent.
    ///
    /// The loaded entity is stored in the LoadedScene but NOT automatically added
    /// to a RealityView — the caller (SplatRealityView) is responsible for adding
    /// the entity to its content.
    func loadScene(from url: URL) async {
        isLoading = true
        loadProgress = 0
        renderError = nil

        defer {
            isLoading = false
        }

        do {
            loadProgress = 0.2

            // Parse the PLY file into deinterleaved GPU buffers.
            let buffers = try PLYLoader.load(url, maxSplatCount: maxGaussians)

            loadProgress = 0.5

            // Build the GaussianSplatResource from the buffers.
            let component = try buildSplatComponent(from: buffers)

            loadProgress = 0.8

            // Create a RealityKit Entity and attach the splat component.
            let entity = Entity()
            entity.name = url.lastPathComponent
            entity.components.set(component)

            loadProgress = 1.0

            let scene = LoadedScene(
                url: url,
                name: url.lastPathComponent,
                splatCount: Int(buffers.splatCount),
                entity: entity
            )

            loadedScenes.append(scene)
            currentSceneIndex = loadedScenes.count - 1

        } catch {
            renderError = "Failed to load PLY: \(error.localizedDescription)"
        }
    }

    /// Remove a scene and release its entity.
    func removeScene(at index: Int) {
        guard index < loadedScenes.count else { return }
        loadedScenes.remove(at: index)

        if currentSceneIndex == index {
            currentSceneIndex = loadedScenes.isEmpty ? nil : max(0, index - 1)
        } else if let curr = currentSceneIndex, curr > index {
            currentSceneIndex = curr - 1
        }
    }

    /// Remove all loaded scenes.
    func removeAllScenes() {
        loadedScenes.removeAll()
        currentSceneIndex = nil
    }

    /// Set scene transform (for AR anchoring or manual placement).
    func setTransform(_ transform: simd_float4x4, forSceneAt index: Int) {
        guard index < loadedScenes.count else { return }
        loadedScenes[index].transform = transform
        loadedScenes[index].entity?.transform = Transform(matrix: transform)
    }

    /// Toggle visibility of a scene.
    func toggleVisibility(forSceneAt index: Int) {
        guard index < loadedScenes.count else { return }
        loadedScenes[index].visible.toggle()
        loadedScenes[index].entity?.isEnabled = loadedScenes[index].visible
    }

    /// Get the entity for the current scene (for adding to a RealityView).
    func currentEntity() -> Entity? {
        guard let index = currentSceneIndex, index < loadedScenes.count else {
            return nil
        }
        return loadedScenes[index].entity
    }

    // MARK: - List Models

    /// List available PLY files in the app's models directory.
    func availableModels() -> [URL] {
        FileStorage.shared.listModels()
    }

    // MARK: - Private: Build GaussianSplatComponent

    /// Assemble a GaussianSplatComponent from deinterleaved buffers.
    /// Follows the pattern from Apple's "Rendering Gaussian splats with RealityKit" sample.
    private func buildSplatComponent(from buffers: GaussianSplatBuffers) throws -> GaussianSplatComponent {
        guard let pos = buffers.positionBuffer,
              let scale = buffers.scaleBuffer,
              let rotation = buffers.rotationBuffer,
              let opacity = buffers.opacityBuffer,
              let shBuf = buffers.shBuffer else {
            throw PLYLoaderError.noVertexElement
        }

        let degree = GaussianSplatResource.SphericalHarmonicDegree(rawValue: buffers.degreeSH) ?? .zero

        // Create buffer descriptors matching the strides used in PLYLoader.
        let positionDesc = GaussianSplatResource.BufferDescriptor(
            buffer: pos, format: .float3, stride: 3 * 4)
        let scaleDesc = GaussianSplatResource.BufferDescriptor(
            buffer: scale, format: .float3, stride: 3 * 4)
        let rotationDesc = GaussianSplatResource.BufferDescriptor(
            buffer: rotation, format: .float4, stride: 4 * 4)
        let opacityDesc = GaussianSplatResource.BufferDescriptor(
            buffer: opacity, format: .float, stride: 1 * 4)

        // SH descriptor: the SH buffer contains f_dc (3) + f_rest (N) floats per splat,
        // stored contiguously. The descriptor stride covers all SH coefficients.
        let shCoeffsPerSplat = buffers.degreeSH == 0 ? 3 : (3 + (buffers.degreeSH * buffers.degreeSH + 2 * buffers.degreeSH))
        let shDesc = GaussianSplatResource.BufferDescriptor(
            buffer: shBuf, format: .float, stride: shCoeffsPerSplat * 4)

        let bufferResource = try GaussianSplatResource.BufferResource(
            count: Int(buffers.splatCount),
            position: positionDesc,
            scale: scaleDesc,
            rotation: rotationDesc,
            opacity: opacityDesc,
            sphericalHarmonics: (shDesc, degree)
        )

        let splatResource = GaussianSplatResource(bufferResource)

        // Standard 3DGS PLY uses log-space scale and logit opacity.
        // RealityKit applies exp() and sigmoid() respectively with these defaults.
        splatResource.scaleActivation = .exponential
        splatResource.opacityActivation = .sigmoid

        return GaussianSplatComponent(splatResource)
    }
}
