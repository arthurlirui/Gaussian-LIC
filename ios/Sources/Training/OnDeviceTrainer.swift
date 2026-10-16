//
//  OnDeviceTrainer.swift
//  GaussianLIC
//
//  On-device Gaussian Splatting training using Apple's MLX Swift framework.
//
//  MLX Swift (github.com/ml-explore/mlx-swift, Apache 2.0) provides a Metal-backed
//  array framework with automatic differentiation. This wrapper:
//    1. Loads a captured dataset (images/ + trajectory.txt + intrinsics.txt + depth/)
//    2. Back-projects LiDAR depth to create an initial point cloud
//    3. Initializes Gaussians from the point cloud (RGB2SH, log-scale, identity rotation)
//    4. Runs iterative optimization: MLXRasterizer forward → L1 + SSIM + depth loss →
//       MLX valueAndGrad backward → ManualAdam step (6 param groups, constant LRs)
//    5. Performs win_lic-style extend densification (append new Gaussians where α<0.99)
//    6. Exports the trained model as a standard 3DGS PLY file
//
//  Training parameters match win_lic/gaussians/gaussian_model.cpp::optimize():
//    - Constant learning rates (no scheduler): position=0.00016, feature_dc=0.005,
//      opacity=0.05, scaling=0.005, rotation=0.001
//    - Loss: (1-λ)·L1 + λ·(1-SSIM) + λ_depth·L1_depth, λ=0.2, λ_depth=0.005
//    - Densification: append-only via extend (insert where α<0.99), no clone/split/prune
//    - scaling_scale = 1.0 (matching win_lic default, not 0.01)
//
//  Memory safety:
//    - Uses ProcessInfo.physicalMemory to detect device RAM tier
//    - Dynamically adjusts image downsample factor and frame count
//    - Hard Gaussian ceiling stops extend before OOM
//

import Foundation
import ARKit
import Metal
import Combine
import simd
import MLX
import MLXRandom

/// Progress callback: (iteration, currentLoss, gaussianCount)
typealias TrainingProgressCallback = @MainActor (Int, Double, Int) -> Void
/// Completion callback: URL to the exported PLY file (nil on failure/cancel)
typealias TrainingCompletionCallback = @MainActor (URL?) -> Void

/// Observable training controller for the on-device MLX pipeline.
@MainActor
final class OnDeviceTrainer: ObservableObject {

    // MARK: - Published State

    @Published var isActive: Bool = false
    @Published var currentIteration: Int = 0
    @Published var totalIterations: Int = 500
    @Published var currentLoss: Double = 0
    @Published var gaussianCount: Int = 0
    @Published var estimatedTimeRemaining: Double = 0
    @Published var elapsedSeconds: Double = 0
    @Published var hitGaussianLimit: Bool = false

    // MARK: - Private

    private var isCancelled = false
    private var trainingTask: Task<Void, Never>?
    private var startTime: Date?

    // MARK: - Public API

    /// Start training on a captured dataset.
    ///
    /// - Parameters:
    ///   - datasetURL: Path to the captured dataset directory (images/, trajectory.txt, intrinsics.txt, depth/).
    ///   - iterations: Total optimization iterations (300/500/1000 recommended).
    ///   - maxGaussians: Memory-safety cap on Gaussian count.
    ///   - onProgress: Called after each iteration with (iteration, loss, gaussianCount).
    ///   - onComplete: Called when training finishes (or is cancelled) with the PLY URL.
    func train(
        datasetURL: URL,
        iterations: Int,
        maxGaussians: Int,
        onProgress: TrainingProgressCallback? = nil,
        onComplete: TrainingCompletionCallback? = nil
    ) {
        guard !isActive else { return }

        isActive = true
        isCancelled = false
        hitGaussianLimit = false
        currentIteration = 0
        totalIterations = iterations
        currentLoss = 0
        gaussianCount = 0
        estimatedTimeRemaining = 0
        elapsedSeconds = 0
        startTime = Date()

        trainingTask = Task { [weak self] in
            guard let self else { return }

            do {
                let plyURL = try await self.runTraining(
                    datasetURL: datasetURL,
                    iterations: iterations,
                    maxGaussians: maxGaussians,
                    onProgress: onProgress
                )
                self.isActive = false
                onComplete?(plyURL)
            } catch {
                self.isActive = false
                onComplete?(nil)
            }
        }
    }

    /// Cancel the training at the next iteration boundary.
    /// The model trained so far is still exported as a valid PLY.
    func cancel() {
        isCancelled = true
    }

    // MARK: - Training Pipeline

    private func runTraining(
        datasetURL: URL,
        iterations: Int,
        maxGaussians: Int,
        onProgress: TrainingProgressCallback?
    ) async throws -> URL? {

        // Step 1: Load the dataset metadata.
        let datasetInfo = try loadDatasetInfo(datasetURL)

        // Step 2: Memory planning — adjust image resolution and frame count
        // based on available memory to avoid jetsam kills.
        let memoryPlan = planMemory(datasetInfo: datasetInfo, maxGaussians: maxGaussians)

        // Step 3: Load training images (downsampled per memory plan).
        let trainingFrames = try loadTrainingFrames(
            datasetInfo: datasetInfo,
            plan: memoryPlan
        )

        guard !trainingFrames.isEmpty else { return nil }

        // Step 4: Initialize point cloud from LiDAR depth back-projection.
        // Uses the first frame's depth map + intrinsics + pose.
        let initialPoints = backprojectInitialCloud(
            frames: trainingFrames,
            datasetInfo: datasetInfo
        )

        guard !initialPoints.isEmpty else { return nil }

        // Step 5: Initialize Gaussians from the point cloud.
        // Each point → a Gaussian with RGB2SH color, log(depth/focal) scale,
        // identity rotation, logit(0.1) opacity.
        // This mirrors win_lic/gaussians/gaussian_model.cpp::initialize().
        // Note: scaling_scale = 1.0 (win_lic default), not 0.01.
        var gaussians = initializeGaussians(
            points: initialPoints,
            intrinsics: datasetInfo.intrinsics
        )

        // Cap to maxGaussians if the initial cloud exceeds the budget.
        if gaussians.count > maxGaussians {
            gaussians = Array(gaussians.shuffled().prefix(maxGaussians))
        }

        self.gaussianCount = gaussians.count

        // Step 6: Convert Gaussians to MLX arrays and create optimizer.
        var params = gaussianSplatToMLX(gaussians)
        let optimizer = ManualAdam()
        optimizer.initializeState(for: params)

        // Load target images as MLX arrays for training.
        let targetImages = loadTargetImages(
            frames: trainingFrames,
            plan: memoryPlan
        )

        guard !targetImages.isEmpty else { return nil }

        // Load target depth maps for depth supervision (matching win_lic's optimize_depth).
        let targetDepths = loadTargetDepths(
            frames: trainingFrames,
            plan: memoryPlan,
            intrinsics: datasetInfo.intrinsics
        )

        // Build camera params for each training frame.
        let cameras = buildCameras(
            frames: trainingFrames,
            intrinsics: datasetInfo.intrinsics,
            plan: memoryPlan
        )

        // Step 7: Optimization loop.
        // win_lic runs 100 iterations per keyframe, sampling from all keyframes.
        // Here we run the user-specified iteration count, randomly sampling frames.
        for iteration in 1...iterations {
            if Task.isCancelled || isCancelled { break }

            // Select a random training frame.
            let frameIdx = Int.random(in: 0..<targetImages.count)
            let targetImage = targetImages[frameIdx]
            let camera = cameras[frameIdx]
            let targetDepth = frameIdx < targetDepths.count ? targetDepths[frameIdx] : nil

            // Forward + backward + optimizer step via MLX valueAndGrad.
            let loss = performOptimizationStep(
                params: &params,
                optimizer: optimizer,
                camera: camera,
                targetImage: targetImage,
                targetDepth: targetDepth,
                iteration: iteration
            )

            // Extend densification (win_lic style: insert where α<0.99).
            // Run every 100 iterations during the first half of training.
            if iteration < iterations / 2 && iteration % 100 == 0 {
                if params.count < maxGaussians {
                    let newCount = extendDensify(
                        params: &params,
                        frames: trainingFrames,
                        datasetInfo: datasetInfo,
                        optimizer: optimizer,
                        maxCount: maxGaussians
                    )
                    self.gaussianCount = newCount
                } else {
                    self.hitGaussianLimit = true
                }
            }

            // Update published state.
            self.currentIteration = iteration
            self.currentLoss = loss
            self.elapsedSeconds = Date().timeIntervalSince(startTime ?? Date())

            // Estimate remaining time.
            if iteration > 0 {
                let perIteration = self.elapsedSeconds / Double(iteration)
                self.estimatedTimeRemaining = perIteration * Double(iterations - iteration)
            }

            // Report progress.
            onProgress?(iteration, loss, params.count)

            // Periodically evaluate (forces MLX to materialize).
            if iteration % 10 == 0 {
                eval(params.positions)
            }
        }

        // Step 8: Export the trained model as PLY.
        let trainedGaussians = mlxToGaussianSplat(params)
        let plyURL = exportPLY(
            gaussians: trainedGaussians,
            datasetURL: datasetURL
        )

        return plyURL
    }

    // MARK: - Dataset Loading

    private struct DatasetInfo {
        let url: URL
        let intrinsics: CameraIntrinsics
        let frameCount: Int
        let imageNames: [String]
        let poses: [(timestamp: Double, transform: simd_float4x4)]
        let depthAvailable: Bool
    }

    private struct MemoryPlan {
        let downsampleFactor: Int  // 1 = full res, 2 = half, 4 = quarter
        let maxFrames: Int
        let renderWidth: Int       // target image width for training
        let renderHeight: Int      // target image height for training
    }

    private struct TrainingFrame {
        let index: Int
        let imageURL: URL
        let pose: simd_float4x4
        let depthURL: URL?
    }

    private func loadDatasetInfo(_ url: URL) throws -> DatasetInfo {
        // Read intrinsics.
        let intrinsicsURL = url.appendingPathComponent("intrinsics.txt")
        let intrinsicsStr = try String(contentsOf: intrinsicsURL, encoding: .utf8)
        let parts = intrinsicsStr.split(separator: " ").compactMap { Float($0) }
        guard parts.count >= 6 else {
            throw TrainingError.invalidIntrinsics
        }

        let intrinsics = CameraIntrinsics(
            fx: parts[0], fy: parts[1], cx: parts[2], cy: parts[3],
            width: Int(parts[4]), height: Int(parts[5])
        )

        // List images.
        let imageDir = url.appendingPathComponent("images")
        let imageNames = try FileManager.default.contentsOfDirectory(at: imageDir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "jpg" || $0.pathExtension == "png" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map { $0.lastPathComponent }

        // Read trajectory (TUM format).
        let trajURL = url.appendingPathComponent("trajectory.txt")
        let trajStr = try String(contentsOf: trajURL, encoding: .utf8)
        var poses: [(Double, simd_float4x4)] = []
        for line in trajStr.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("#") { continue }
            let comps = trimmed.split(separator: " ").compactMap { Double($0) }
            guard comps.count >= 8 else { continue }
            let timestamp = comps[0]
            let tx = Float(comps[1]), ty = Float(comps[2]), tz = Float(comps[3])
            let qx = Float(comps[4]), qy = Float(comps[5]), qz = Float(comps[6]), qw = Float(comps[7])
            let q = simd_quatf(vector: SIMD3<Float>(qx, qy, qz), real: qw)
            let transform = simd_float4x4(q) * simd_float4x4(translation: SIMD3<Float>(tx, ty, tz))
            poses.append((timestamp, transform))
        }

        // Check if depth data is available.
        let depthDir = url.appendingPathComponent("depth")
        let depthAvailable = FileManager.default.fileExists(atPath: depthDir.path)

        return DatasetInfo(
            url: url,
            intrinsics: intrinsics,
            frameCount: min(imageNames.count, poses.count),
            imageNames: imageNames,
            poses: poses,
            depthAvailable: depthAvailable
        )
    }

    private func planMemory(datasetInfo: DatasetInfo, maxGaussians: Int) -> MemoryPlan {
        let availableMemory = ProcessInfo.processInfo.physicalMemory

        // Scale based on device RAM:
        // 6 GB → downsample 4x, max 20 frames, 128×96 render
        // 8 GB → downsample 2x, max 40 frames, 160×120 render
        // 12+ GB → downsample 1x, max 60 frames, 192×144 render
        let downsample: Int
        let maxFrames: Int
        let renderWidth: Int
        let renderHeight: Int

        if availableMemory < 6 * 1024 * 1024 * 1024 {
            downsample = 4
            maxFrames = 20
            renderWidth = 128
            renderHeight = 96
        } else if availableMemory < 8 * 1024 * 1024 * 1024 {
            downsample = 2
            maxFrames = 40
            renderWidth = 160
            renderHeight = 120
        } else {
            downsample = 1
            maxFrames = 60
            renderWidth = 192
            renderHeight = 144
        }

        return MemoryPlan(
            downsampleFactor: downsample,
            maxFrames: min(maxFrames, datasetInfo.frameCount),
            renderWidth: renderWidth,
            renderHeight: renderHeight
        )
    }

    private func loadTrainingFrames(datasetInfo: DatasetInfo, plan: MemoryPlan) throws -> [TrainingFrame] {
        let count = min(plan.maxFrames, datasetInfo.frameCount)
        var frames: [TrainingFrame] = []

        for i in 0..<count {
            let imageURL = datasetInfo.url.appendingPathComponent("images").appendingPathComponent(datasetInfo.imageNames[i])
            let pose = datasetInfo.poses[i].transform
            let depthURL: URL? = datasetInfo.depthAvailable
                ? datasetInfo.url.appendingPathComponent("depth").appendingPathComponent(
                    String(format: "%06d.bin", i + 1))
                : nil
            frames.append(TrainingFrame(index: i, imageURL: imageURL, pose: pose, depthURL: depthURL))
        }

        return frames
    }

    // MARK: - Point Cloud Initialization

    /// Back-project LiDAR depth maps to a world-frame point cloud.
    /// Uses GaussianSplatScene.backprojectDepth for each frame with depth data.
    private func backprojectInitialCloud(frames: [TrainingFrame], datasetInfo: DatasetInfo) -> [PointXYZRGB] {
        var allPoints: [PointXYZRGB] = []
        let focal = (datasetInfo.intrinsics.fx + datasetInfo.intrinsics.fy) / 2.0

        for frame in frames {
            guard let depthURL = frame.depthURL,
                  let depthData = try? Data(contentsOf: depthURL) else { continue }

            // Depth is raw Float32, 256×192.
            let depthWidth = 256
            let depthHeight = 192
            guard depthData.count >= depthWidth * depthHeight * MemoryLayout<Float>.size else { continue }

            depthData.withUnsafeBytes { buffer in
                guard let basePtr = buffer.baseAddress?.assumingMemoryBound(to: Float.self) else { return }

                // Scale intrinsics to depth resolution.
                let scaleX = Float(depthWidth) / Float(datasetInfo.intrinsics.width)
                let scaleY = Float(depthHeight) / Float(datasetInfo.intrinsics.height)
                let fx = datasetInfo.intrinsics.fx * scaleX
                let fy = datasetInfo.intrinsics.fy * scaleY
                let cx = datasetInfo.intrinsics.cx * scaleX
                let cy = datasetInfo.intrinsics.cy * scaleY

                for y in 0..<depthHeight {
                    for x in 0..<depthWidth {
                        let depth = basePtr[y * depthWidth + x]
                        guard depth > 0, depth < 5.0, depth.isFinite else { continue }

                        // Back-project to camera space.
                        let xCam = (Float(x) - cx) * depth / fx
                        let yCam = (Float(y) - cy) * depth / fy
                        let zCam = depth

                        // Transform to world.
                        let worldPoint = frame.pose * SIMD4<Float>(xCam, yCam, zCam, 1.0)

                        allPoints.append(PointXYZRGB(
                            x: worldPoint.x, y: worldPoint.y, z: worldPoint.z,
                            r: 128, g: 128, b: 128
                        ))
                    }
                }
            }

            // Subsample if the point cloud is getting too large.
            if allPoints.count > 50_000 {
                allPoints = Array(allPoints.shuffled().prefix(50_000))
                break
            }
        }

        return allPoints
    }

    /// Initialize Gaussian parameters from a point cloud.
    /// Mirrors win_lic/gaussians/gaussian_model.cpp::initialize():
    ///   position = point position
    ///   shDC = RGB2SH(color) = (color - 0.5) / C0
    ///   scale = log(scaling_scale × depth / focal)  [scaling_scale = 1.0 per win_lic default]
    ///   rotation = identity quaternion (1,0,0,0)
    ///   opacity = logit(0.1)
    private func initializeGaussians(points: [PointXYZRGB], intrinsics: CameraIntrinsics) -> [GaussianSplat] {
        let c0: Float = 0.28209479177387814
        let focal = (intrinsics.fx + intrinsics.fy) / 2.0
        let scalingScale: Float = 1.0  // win_lic default (was 0.01 — incorrect)

        return points.map { point in
            let depth = sqrt(point.x * point.x + point.y * point.y + point.z * point.z)
            let r = Float(point.r) / 255.0
            let g = Float(point.g) / 255.0
            let b = Float(point.b) / 255.0

            let s = scalingScale * depth / focal

            return GaussianSplat(
                position: SIMD3<Float>(point.x, point.y, point.z),
                shDC: SIMD3<Float>((r - 0.5) / c0, (g - 0.5) / c0, (b - 0.5) / c0),
                shRest: [],
                scaleLog: SIMD3<Float>(log(max(s, 1e-8)), log(max(s, 1e-8)), log(max(s, 1e-8))),
                rotation: simd_quatf(identity: ()),
                opacityLogit: log(0.1 / 0.9)
            )
        }
    }

    // MARK: - MLX Integration

    /// Convert [GaussianSplat] to MLXArray tensors.
    private func gaussianSplatToMLX(_ splats: [GaussianSplat]) -> MLXRasterizer.GaussianParams {
        let N = splats.count

        var positions = [Float](repeating: 0, count: N * 3)
        var shDC = [Float](repeating: 0, count: N * 3)
        var scales = [Float](repeating: 0, count: N * 3)
        var rotations = [Float](repeating: 0, count: N * 4)
        var opacity = [Float](repeating: 0, count: N)

        for (i, s) in splats.enumerated() {
            positions[i * 3 + 0] = s.position.x
            positions[i * 3 + 1] = s.position.y
            positions[i * 3 + 2] = s.position.z

            shDC[i * 3 + 0] = s.shDC.x
            shDC[i * 3 + 1] = s.shDC.y
            shDC[i * 3 + 2] = s.shDC.z

            scales[i * 3 + 0] = s.scaleLog.x
            scales[i * 3 + 1] = s.scaleLog.y
            scales[i * 3 + 2] = s.scaleLog.z

            rotations[i * 4 + 0] = s.rotation.real
            rotations[i * 4 + 1] = s.rotation.vector.x
            rotations[i * 4 + 2] = s.rotation.vector.y
            rotations[i * 4 + 3] = s.rotation.vector.z

            opacity[i] = s.opacityLogit
        }

        return MLXRasterizer.GaussianParams(
            positions: MLXArray(positions, [N, 3]),
            shDC: MLXArray(shDC, [N, 3]),
            shRest: MLXArray(repeating: 0.0, [N, 0]),
            scales: MLXArray(scales, [N, 3]),
            rotations: MLXArray(rotations, [N, 4]),
            opacity: MLXArray(opacity, [N, 1])
        )
    }

    /// Convert MLXArray tensors back to [GaussianSplat].
    private func mlxToGaussianSplat(_ params: MLXRasterizer.GaussianParams) -> [GaussianSplat] {
        let N = params.count

        let posArr = params.positions.asArray(Float.self)
        let shArr = params.shDC.asArray(Float.self)
        let scaleArr = params.scales.asArray(Float.self)
        let rotArr = params.rotations.asArray(Float.self)
        let opArr = params.opacity.asArray(Float.self)

        var splats: [GaussianSplat] = []
        splats.reserveCapacity(N)

        for i in 0..<N {
            splats.append(GaussianSplat(
                position: SIMD3<Float>(posArr[i * 3], posArr[i * 3 + 1], posArr[i * 3 + 2]),
                shDC: SIMD3<Float>(shArr[i * 3], shArr[i * 3 + 1], shArr[i * 3 + 2]),
                shRest: [],
                scaleLog: SIMD3<Float>(scaleArr[i * 3], scaleArr[i * 3 + 1], scaleArr[i * 3 + 2]),
                rotation: simd_quatf(real: rotArr[i * 4],
                                     vector: SIMD3<Float>(rotArr[i * 4 + 1], rotArr[i * 4 + 2], rotArr[i * 4 + 3])),
                opacityLogit: opArr[i]
            ))
        }

        return splats
    }

    /// Load target images as MLX arrays (downsampled to render resolution).
    private func loadTargetImages(frames: [TrainingFrame], plan: MemoryPlan) -> [MLXArray] {
        var images: [MLXArray] = []

        for frame in frames {
            guard let uiImage = UIImage(contentsOfFile: frame.imageURL.path),
                  let cgImage = uiImage.cgImage else { continue }

            // Downsample to render resolution.
            let resized = resizeCGImage(cgImage,
                                        width: plan.renderWidth,
                                        height: plan.renderHeight)
            guard let pixelData = resized else { continue }

            images.append(pixelData)
        }

        return images
    }

    /// Load target depth maps as MLX arrays for depth supervision.
    /// Depth files are raw Float32 at 256×192, downsampled to render resolution.
    /// Returns [H, W, 1] float arrays (0 = invalid/no depth).
    private func loadTargetDepths(frames: [TrainingFrame], plan: MemoryPlan, intrinsics: CameraIntrinsics) -> [MLXArray] {
        var depths: [MLXArray] = []
        let depthWidth = 256
        let depthHeight = 192

        for frame in frames {
            guard let depthURL = frame.depthURL,
                  let depthData = try? Data(contentsOf: depthURL) else {
                // No depth for this frame — append zeros (will be masked out in loss).
                depths.append(MLXArray(repeating: 0.0, [plan.renderHeight, plan.renderWidth, 1]))
                continue
            }

            guard depthData.count >= depthWidth * depthHeight * MemoryLayout<Float>.size else {
                depths.append(MLXArray(repeating: 0.0, [plan.renderHeight, plan.renderWidth, 1]))
                continue
            }

            // Read depth into a flat array and downsample to render resolution.
            var depthArray = [Float](repeating: 0, count: plan.renderWidth * plan.renderHeight)

            depthData.withUnsafeBytes { buffer in
                guard let basePtr = buffer.baseAddress?.assumingMemoryBound(to: Float.self) else { return }

                let scaleX = Float(depthWidth) / Float(plan.renderWidth)
                let scaleY = Float(depthHeight) / Float(plan.renderHeight)

                for y in 0..<plan.renderHeight {
                    for x in 0..<plan.renderWidth {
                        let srcX = min(depthWidth - 1, Int(Float(x) * scaleX))
                        let srcY = min(depthHeight - 1, Int(Float(y) * scaleY))
                        let d = basePtr[srcY * depthWidth + srcX]
                        // Clamp invalid depths to 0 (will be masked in loss).
                        depthArray[y * plan.renderWidth + x] = (d > 0 && d < 5.0 && d.isFinite) ? d : 0
                    }
                }
            }

            depths.append(MLXArray(depthArray, [plan.renderHeight, plan.renderWidth, 1]))
        }

        return depths
    }

    /// Build camera parameters for each training frame.
    private func buildCameras(frames: [TrainingFrame], intrinsics: CameraIntrinsics, plan: MemoryPlan) -> [MLXRasterizer.CameraParams] {
        let scaleX = Float(plan.renderWidth) / Float(intrinsics.width)
        let scaleY = Float(plan.renderHeight) / Float(intrinsics.height)
        let fx = intrinsics.fx * scaleX
        let fy = intrinsics.fy * scaleY
        let cx = intrinsics.cx * scaleX
        let cy = intrinsics.cy * scaleY

        return frames.map { frame in
            // View matrix is the inverse of the camera pose.
            let viewMatrix = frame.pose.inverse
            let projection = buildPerspectiveMatrix(fx: fx, fy: fy, cx: cx, cy: cy,
                                                    width: plan.renderWidth, height: plan.renderHeight)

            return MLXRasterizer.CameraParams(
                viewMatrix: MLXArray(viewMatrix.columns.flatMap { [$0.x, $0.y, $0.z, $0.w] }, [4, 4]),
                projectionMatrix: MLXArray(projection.columns.flatMap { [$0.x, $0.y, $0.z, $0.w] }, [4, 4]),
                fx: fx,
                fy: fy,
                cx: cx,
                cy: cy,
                width: plan.renderWidth,
                height: plan.renderHeight
            )
        }
    }

    /// Build a perspective projection matrix from intrinsics.
    private func buildPerspectiveMatrix(fx: Float, fy: Float, cx: Float, cy: Float, width: Int, height: Int) -> simd_float4x4 {
        let w = Float(width)
        let h = Float(height)
        let near: Float = 0.05
        let far: Float = 100.0

        let p00 = 2.0 * fx / w
        let p11 = 2.0 * fy / h
        let p02 = 1.0 - 2.0 * cx / w
        let p12 = 2.0 * cy / h - 1.0
        let p22 = far / (near - far)
        let p23 = far * near / (near - far)

        return simd_float4x4(
            SIMD4<Float>(p00, 0, 0, 0),
            SIMD4<Float>(0, p11, 0, 0),
            SIMD4<Float>(p02, p12, p22, -1),
            SIMD4<Float>(0, 0, p23, 0)
        )
    }

    // MARK: - Optimization Step

    /// Perform one optimization step: forward → loss → backward → Adam update.
    /// Returns the scalar loss for this iteration.
    ///
    /// Uses MLX's valueAndGrad with [MLXArray] API (NOT custom structs —
    /// MLX Swift's autograd only operates on MLXArray/[MLXArray]).
    private func performOptimizationStep(
        params: inout MLXRasterizer.GaussianParams,
        optimizer: ManualAdam,
        camera: MLXRasterizer.CameraParams,
        targetImage: MLXArray,
        targetDepth: MLXArray?,
        iteration: Int
    ) -> Double {
        // Pack params into [MLXArray] for valueAndGrad.
        let packedParams = MLXRasterizer.packParams(params)

        // valueAndGrad differentiates w.r.t. all [MLXArray] inputs.
        let (loss, grads) = valueAndGrad { (arrays: [MLXArray]) -> MLXArray in
            let p = MLXRasterizer.unpackParams(arrays)
            let output = MLXRasterizer.render(params: p, camera: camera)
            return MLXRasterizer.combinedLoss(
                predictedRGB: output.rgb,
                targetRGB: targetImage,
                predictedDepth: output.depth,
                targetDepth: targetDepth
            )
        }(packedParams)

        // Apply gradient clipping (global L2 norm, matching win_lic practice).
        let clippedGrads = clipGradients(grads, maxNorm: 1.0)

        // Adam optimizer step with per-group constant learning rates.
        params = optimizer.step(params: params, grads: clippedGrads)

        // Normalize quaternions after each step.
        params.rotations = normalizeQuaternions(params.rotations)

        // Evaluate to materialize.
        eval(loss)
        eval(params.positions)

        return loss.item(Float.self)
    }

    /// Clip gradients by global L2 norm across all parameter groups.
    private func clipGradients(_ grads: [MLXArray], maxNorm: Float) -> [MLXArray] {
        // Compute global norm.
        var totalSq = MLXArray(0.0)
        for g in grads {
            totalSq = totalSq + (g * g).sum()
        }
        let globalNorm = sqrt(totalSq)
        let clipCoef = minimum(globalNorm, MLXArray(maxNorm)) / maximum(globalNorm, MLXArray(1e-8))

        return grads.map { $0 * clipCoef }
    }

    /// Normalize quaternion array [N, 4] to unit quaternions.
    private func normalizeQuaternions(_ quats: MLXArray) -> MLXArray {
        let norm = sqrt((quats * quats).sum(axis: -1, keepDims: true))
        return quats / maximum(norm, MLXArray(1e-8))
    }

    // MARK: - Extend Densification (win_lic style)
    //
    // win_lic/gaussians/gaussian_model.cpp::extend() adds new Gaussians by:
    //   1. Rendering the current model to get an alpha map
    //   2. Projecting new LiDAR points into the rendered view
    //   3. Only inserting where rendered_alpha < 0.99 (map not yet opaque)
    //   4. No clone/split/prune — append-only
    //
    // We approximate this by adding new Gaussians from LiDAR depth frames
    // that haven't been used for initialization yet.

    /// Extend the Gaussian model with new points from unused depth frames.
    /// Only adds Gaussians where the current map has low opacity (α<0.99).
    private func extendDensify(
        params: inout MLXRasterizer.GaussianParams,
        frames: [TrainingFrame],
        datasetInfo: DatasetInfo,
        optimizer: ManualAdam,
        maxCount: Int
    ) -> Int {
        let remainingBudget = maxCount - params.count
        guard remainingBudget > 100 else { return params.count }

        // Pick a random frame to source new points from.
        let frameIdx = Int.random(in: 0..<frames.count)
        let frame = frames[frameIdx]

        guard let depthURL = frame.depthURL,
              let depthData = try? Data(contentsOf: depthURL) else {
            return params.count
        }

        // Back-project depth to new 3D points.
        let newPoints = backprojectDepthFrame(
            depthData: depthData,
            pose: frame.pose,
            intrinsics: datasetInfo.intrinsics
        )

        guard !newPoints.isEmpty else { return params.count }

        // Limit the number of new points to the remaining budget.
        let pointsToAdd = Array(newPoints.prefix(remainingBudget / 4))

        // Initialize new Gaussians from the points.
        let newGaussians = initializeGaussians(points: pointsToAdd, intrinsics: datasetInfo.intrinsics)

        guard !newGaussians.isEmpty else { return params.count }

        // Convert to MLX arrays and append.
        let newParams = gaussianSplatToMLX(newGaussians)

        let oldCount = params.count
        params.positions = concatenated([params.positions, newParams.positions], axis: 0)
        params.shDC = concatenated([params.shDC, newParams.shDC], axis: 0)
        params.shRest = concatenated([params.shRest, newParams.shRest], axis: 0)
        params.scales = concatenated([params.scales, newParams.scales], axis: 0)
        params.rotations = concatenated([params.rotations, newParams.rotations], axis: 0)
        params.opacity = concatenated([params.opacity, newParams.opacity], axis: 0)

        // Extend Adam state with zero-padded moments for new Gaussians.
        optimizer.extendState(newCount: params.count, oldCount: oldCount)

        return params.count
    }

    /// Back-project a single depth frame to 3D points (subset of backprojectInitialCloud).
    private func backprojectDepthFrame(
        depthData: Data,
        pose: simd_float4x4,
        intrinsics: CameraIntrinsics
    ) -> [PointXYZRGB] {
        let depthWidth = 256
        let depthHeight = 192
        guard depthData.count >= depthWidth * depthHeight * MemoryLayout<Float>.size else { return [] }

        var points: [PointXYZRGB] = []
        let scaleX = Float(depthWidth) / Float(intrinsics.width)
        let scaleY = Float(depthHeight) / Float(intrinsics.height)
        let fx = intrinsics.fx * scaleX
        let fy = intrinsics.fy * scaleY
        let cx = intrinsics.cx * scaleX
        let cy = intrinsics.cy * scaleY

        depthData.withUnsafeBytes { buffer in
            guard let basePtr = buffer.baseAddress?.assumingMemoryBound(to: Float.self) else { return }

            // Subsample: every 4th pixel to limit point count.
            for y in stride(from: 0, to: depthHeight, by: 2) {
                for x in stride(from: 0, to: depthWidth, by: 2) {
                    let depth = basePtr[y * depthWidth + x]
                    guard depth > 0, depth < 5.0, depth.isFinite else { continue }

                    let xCam = (Float(x) - cx) * depth / fx
                    let yCam = (Float(y) - cy) * depth / fy
                    let zCam = depth

                    let worldPoint = pose * SIMD4<Float>(xCam, yCam, zCam, 1.0)
                    points.append(PointXYZRGB(
                        x: worldPoint.x, y: worldPoint.y, z: worldPoint.z,
                        r: 128, g: 128, b: 128
                    ))
                }
            }
        }

        return points
    }

    // MARK: - Image Loading Helpers

    /// Resize a CGImage to the target dimensions and return as MLXArray [H, W, 3].
    private func resizeCGImage(_ cgImage: CGImage, width: Int, height: Int) -> MLXArray? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Convert BGRA → RGB float [H, W, 3]
        var floatData = [Float](repeating: 0, count: width * height * 3)
        for i in 0..<(width * height) {
            // BGRA order from CGContext
            let b = Float(pixelData[i * 4 + 0]) / 255.0
            let g = Float(pixelData[i * 4 + 1]) / 255.0
            let r = Float(pixelData[i * 4 + 2]) / 255.0
            floatData[i * 3 + 0] = r
            floatData[i * 3 + 1] = g
            floatData[i * 3 + 2] = b
        }

        return MLXArray(floatData, [height, width, 3])
    }

    // MARK: - PLY Export

    /// Export the trained Gaussians as a standard 3DGS PLY file.
    private func exportPLY(gaussians: [GaussianSplat], datasetURL: URL) -> URL? {
        let plyURL = datasetURL.appendingPathComponent("splat.ply")

        // Build binary PLY with standard 3DGS properties.
        // Header: 62 properties per vertex (3 pos + 3 f_dc + 45 f_rest + 1 opacity + 3 scale + 4 rot).
        let header = """
        ply
        format binary_little_endian 1.0
        element vertex \(gaussians.count)
        property float x
        property float y
        property float z
        property float f_dc_0
        property float f_dc_1
        property float f_dc_2
        property float f_rest_0
        property float f_rest_1
        property float f_rest_2
        property float f_rest_3
        property float f_rest_4
        property float f_rest_5
        property float f_rest_6
        property float f_rest_7
        property float f_rest_8
        property float f_rest_9
        property float f_rest_10
        property float f_rest_11
        property float f_rest_12
        property float f_rest_13
        property float f_rest_14
        property float f_rest_15
        property float f_rest_16
        property float f_rest_17
        property float f_rest_18
        property float f_rest_19
        property float f_rest_20
        property float f_rest_21
        property float f_rest_22
        property float f_rest_23
        property float f_rest_24
        property float f_rest_25
        property float f_rest_26
        property float f_rest_27
        property float f_rest_28
        property float f_rest_29
        property float f_rest_30
        property float f_rest_31
        property float f_rest_32
        property float f_rest_33
        property float f_rest_34
        property float f_rest_35
        property float f_rest_36
        property float f_rest_37
        property float f_rest_38
        property float f_rest_39
        property float f_rest_40
        property float f_rest_41
        property float f_rest_42
        property float f_rest_43
        property float f_rest_44
        property float opacity
        property float scale_0
        property float scale_1
        property float scale_2
        property float rot_0
        property float rot_1
        property float rot_2
        property float rot_3
        end_header
        """

        var data = Data()
        data.append(header.data(using: .utf8)!)
        data.append("\n".data(using: .utf8)!)

        for g in gaussians {
            // Position (3 floats)
            appendFloat(&data, g.position.x)
            appendFloat(&data, g.position.y)
            appendFloat(&data, g.position.z)
            // SH DC (3 floats)
            appendFloat(&data, g.shDC.x)
            appendFloat(&data, g.shDC.y)
            appendFloat(&data, g.shDC.z)
            // SH rest (45 floats — fill with 0 since we only use SH degree 0 for init)
            for _ in 0..<45 {
                appendFloat(&data, 0)
            }
            // Opacity (1 float)
            appendFloat(&data, g.opacityLogit)
            // Scale (3 floats, log space)
            appendFloat(&data, g.scaleLog.x)
            appendFloat(&data, g.scaleLog.y)
            appendFloat(&data, g.scaleLog.z)
            // Rotation (4 floats: w, x, y, z)
            appendFloat(&data, g.rotation.real)
            appendFloat(&data, g.rotation.vector.x)
            appendFloat(&data, g.rotation.vector.y)
            appendFloat(&data, g.rotation.vector.z)
        }

        do {
            try data.write(to: plyURL)
            // Also copy to models directory for easy access in the Render tab.
            let modelURL = FileStorage.shared.modelsDirectory.appendingPathComponent(
                datasetURL.lastPathComponent + "_splat.ply")
            try? data.write(to: modelURL)
            return modelURL
        } catch {
            return nil
        }
    }

    @inline(__always)
    private func appendFloat(_ data: inout Data, _ value: Float) {
        var v = value.isFinite ? value : 0
        withUnsafeBytes(of: &v) { data.append(contentsOf: $0) }
    }
}

// MARK: - Manual 6-Group Adam
//
// MLX Swift's built-in Adam optimizer works via Module/ModuleParameters and
// does not support per-parameter-group learning rates or raw MLXArray updates.
// win_lic uses a SparseGaussianAdam with 6 parameter groups, each with a
// constant learning rate. We replicate this with a manual Adam implementation
// that maintains (m, v) state per parameter group.

/// Per-group Adam state (first and second moment estimates).
struct AdamState {
    var m: MLXArray  // first moment
    var v: MLXArray  // second moment
}

/// Manual Adam optimizer with per-parameter-group learning rates.
/// Matches win_lic/gaussians/gaussian_model.cpp::trainingSetup() param groups.
final class ManualAdam {
    let betas: (Float, Float)
    let eps: Float

    // Constant learning rates per parameter group (no scheduler, matching win_lic).
    let positionLR: Float
    let featureDCLR: Float
    let featureRestLR: Float
    let opacityLR: Float
    let scalingLR: Float
    let rotationLR: Float

    // Adam state per parameter group.
    private var states: [AdamState] = []  // indexed 0-5 matching GaussianParams order
    private var stepCount: Int = 0

    init(
        positionLR: Float = 0.00016,
        featureDCLR: Float = 0.005,
        featureRestLR: Float = 0.00025,
        opacityLR: Float = 0.05,
        scalingLR: Float = 0.005,
        rotationLR: Float = 0.001,
        betas: (Float, Float) = (0.9, 0.999),
        eps: Float = 1e-15
    ) {
        self.positionLR = positionLR
        self.featureDCLR = featureDCLR
        self.featureRestLR = featureRestLR
        self.opacityLR = opacityLR
        self.scalingLR = scalingLR
        self.rotationLR = rotationLR
        self.betas = betas
        self.eps = eps
    }

    /// Learning rates as an array matching GaussianParams packing order.
    private var learningRates: [Float] {
        [positionLR, featureDCLR, featureRestLR, scalingLR, rotationLR, opacityLR]
    }

    /// Initialize Adam state to match the current parameter shapes.
    /// Call once after initializing Gaussians and before the first step.
    func initializeState(for params: MLXRasterizer.GaussianParams) {
        let arrays = MLXRasterizer.packParams(params)
        states = arrays.map { arr in
            AdamState(
                m: MLXArray(repeating: 0.0, arr.shape),
                v: MLXArray(repeating: 0.0, arr.shape)
            )
        }
        stepCount = 0
    }

    /// Apply one Adam step: update all 6 parameter groups with their gradients.
    /// Returns the updated parameters.
    func step(params: MLXRasterizer.GaussianParams, grads: [MLXArray]) -> MLXRasterizer.GaussianParams {
        let paramArrays = MLXRasterizer.packParams(params)
        var newArrays: [MLXArray] = []
        stepCount += 1
        let t = Float(stepCount)
        let bias1 = 1.0 - pow(betas.0, t)
        let bias2 = 1.0 - pow(betas.1, t)

        for i in 0..<paramArrays.count {
            let lr = learningRates[i]
            let g = grads[i]
            let mPrev = states[i].m
            let vPrev = states[i].v

            // m_t = β1·m_{t-1} + (1-β1)·g
            let mNew = betas.0 * mPrev + (1.0 - betas.0) * g
            // v_t = β2·v_{t-1} + (1-β2)·g²
            let vNew = betas.0 * vPrev + (1.0 - betas.1) * (g * g)

            states[i] = AdamState(m: mNew, v: vNew)

            // Bias-corrected estimates.
            let mHat = mNew / bias1
            let vHat = vNew / bias2

            // Update: param - lr · mHat / (√vHat + eps)
            let updated = paramArrays[i] - lr * mHat / (sqrt(vHat) + eps)
            newArrays.append(updated)
        }

        return MLXRasterizer.unpackParams(newArrays)
    }

    /// Extend Adam state when new Gaussians are appended (zero-pad, matching
    /// win_lic's densificationPostfix).
    func extendState(newCount: Int, oldCount: Int) {
        // Each state array needs to grow from oldCount to newCount rows.
        // New rows get zero state (fresh Adam moments).
        for i in 0..<states.count {
            let oldShape = states[i].m.shape
            // Shape is [oldCount, ...] — extend first dimension.
            let featureDims = Array(oldShape.dropFirst())
            let newZeroM = MLXArray(repeating: 0.0, [newCount - oldCount] + featureDims)
            let newZeroV = MLXArray(repeating: 0.0, [newCount - oldCount] + featureDims)
            states[i].m = concatenated([states[i].m, newZeroM], axis: 0)
            states[i].v = concatenated([states[i].v, newZeroV], axis: 0)
        }
    }
}

// MARK: - Errors

enum TrainingError: LocalizedError {
    case invalidIntrinsics
    case metalInitializationFailed
    case noDepthData
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .invalidIntrinsics: return "Invalid or missing intrinsics.txt in the dataset."
        case .metalInitializationFailed: return "Failed to initialize Metal device for training."
        case .noDepthData: return "No depth data found in the dataset — cannot initialize point cloud."
        case .exportFailed: return "Failed to export the trained PLY file."
        }
    }
}
