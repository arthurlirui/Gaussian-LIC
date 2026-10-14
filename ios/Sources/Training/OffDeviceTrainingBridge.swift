//
//  OffDeviceTrainingBridge.swift
//  GaussianLIC
//
//  Handles exporting captured datasets for training on a Mac/CUDA server
//  running the win_lic pipeline. Generates the win_lic-compatible YAML
//  config and packages the dataset directory into a zip for AirDrop.
//

import Foundation
import Compression

enum OffDeviceTrainingBridge {

    /// Export a captured dataset for offline training.
    /// Returns the URL of the packaged file (zip) or config file.
    static func export(datasetURL: URL) -> URL? {
        // 1. Generate the win_lic YAML training config.
        guard let configURL = DatasetExporter.generateTrainingConfig(datasetURL: datasetURL) else {
            return nil
        }

        // 2. Verify dataset integrity.
        let validation = DatasetExporter.verifyIntegrity(datasetURL: datasetURL)
        if !validation.isValid {
            // Log issues but still allow export — the user may want to proceed.
            print("Dataset validation issues: \(validation.issues.joined(separator: ", "))")
        }

        // 3. Package as zip.
        guard let zipURL = DatasetExporter.packageAsZip(datasetURL: datasetURL) else {
            return configURL
        }

        return zipURL
    }

    /// Generate a nerfstudio-format transforms.json from the captured dataset.
    /// This allows the dataset to be used with nerfstudio, gsplat, Brush,
    /// and other transforms.json-compatible Gaussian splatting trainers.
    static func generateTransformsJSON(datasetURL: URL) -> URL? {
        // Read intrinsics.
        let intrinsicsURL = datasetURL.appendingPathComponent("intrinsics.txt")
        guard let intrinsicsStr = try? String(contentsOf: intrinsicsURL, encoding: .utf8) else { return nil }
        let parts = intrinsicsStr.split(separator: " ").compactMap { Float($0) }
        guard parts.count >= 6 else { return nil }

        let fx = parts[0], fy = parts[1]
        let cx = parts[2], cy = parts[3]
        let width = Int(parts[4]), height = Int(parts[5])

        // Read trajectory (TUM format).
        let trajURL = datasetURL.appendingPathComponent("trajectory.txt")
        guard let trajStr = try? String(contentsOf: trajURL, encoding: .utf8) else { return nil }

        var frames: [[String: Any]] = []
        var imageIndex = 0

        for line in trajStr.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("#") { continue }
            let comps = trimmed.split(separator: " ").compactMap { Double($0) }
            guard comps.count >= 8 else { continue }

            let tx = comps[1], ty = comps[2], tz = comps[3]
            let qx = comps[4], qy = comps[5], qz = comps[6], qw = comps[7]

            let imageName = String(format: "%06d.jpg", imageIndex + 1)

            // Build 4x4 transform matrix (camera-to-world) as nested array.
            // nerfstudio expects row-major [R|t] with the last row being [0,0,0,1].
            let q = simd_quatf(vector: SIMD3<Float>(Float(qx), Float(qy), Float(qz)), real: Float(qw))
            let rotation = simd_float3x3(q)
            let transform: [[Double]] = [
                [Double(rotation.columns.0.x), Double(rotation.columns.1.x), Double(rotation.columns.2.x), tx],
                [Double(rotation.columns.0.y), Double(rotation.columns.1.y), Double(rotation.columns.2.y), ty],
                [Double(rotation.columns.0.z), Double(rotation.columns.1.z), Double(rotation.columns.2.z), tz],
                [0, 0, 0, 1]
            ]

            frames.append([
                "file_path": imageName,
                "transform_matrix": transform
            ])
            imageIndex += 1
        }

        let transforms: [String: Any] = [
            "camera_model": "OPENCV",
            "fl_x": Double(fx),
            "fl_y": Double(fy),
            "cx": Double(cx),
            "cy": Double(cy),
            "w": width,
            "h": height,
            "frames": frames,
            "applied_transform": [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
        ]

        let jsonURL = datasetURL.appendingPathComponent("transforms.json")
        guard let data = try? JSONSerialization.data(withJSONObject: transforms, options: [.prettyPrinted, .sortedKeys]) else {
            return nil
        }
        try? data.write(to: jsonURL)
        return jsonURL
    }
}
