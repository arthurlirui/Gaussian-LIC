//
//  FileStorage.swift
//  GaussianLIC
//
//  Manages app sandbox file system layout for captured datasets,
//  trained PLY models, and exported files.
//

import Foundation

/// Centralized file system management for GaussianLIC.
final class FileStorage: @unchecked Sendable {

    static let shared = FileStorage()

    /// Root documents directory (App Sandbox).
    let documentsDirectory: URL

    /// Directory for captured datasets (each subdirectory = one dataset).
    let datasetsDirectory: URL

    /// Directory for downloaded/trained PLY models.
    let modelsDirectory: URL

    /// Directory for exported files (zip archives, etc.).
    let exportsDirectory: URL

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.documentsDirectory = docs
        self.datasetsDirectory = docs.appendingPathComponent("datasets", isDirectory: true)
        self.modelsDirectory = docs.appendingPathComponent("models", isDirectory: true)
        self.exportsDirectory = docs.appendingPathComponent("exports", isDirectory: true)

        try? FileManager.default.createDirectory(at: datasetsDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: exportsDirectory, withIntermediateDirectories: true)
    }

    /// Create a new dataset directory with a timestamped name.
    func createDatasetDirectory() -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let name = "dataset_\(formatter.string(from: Date()))"
        let dir = datasetsDirectory.appendingPathComponent(name, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// List all captured dataset directories.
    func listCapturedDatasets() -> [URL] {
        guard let entries = try? FileManager.default.contentsOfDirectory(
            at: datasetsDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        return entries.filter { url in
            var isDir: ObjCBool = false
            return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
        }.sorted { $0.lastPathComponent > $1.lastPathComponent }
    }

    /// List all PLY/splat model files.
    func listModels() -> [URL] {
        guard let entries = try? FileManager.default.contentsOfDirectory(
            at: modelsDirectory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        let validExtensions: Set<String> = ["ply", "splat", "spz"]
        return entries.filter { validExtensions.contains($0.pathExtension.lowercased()) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    /// Save a PLY file from Data.
    func saveModel(_ data: Data, named name: String) -> URL? {
        let url = modelsDirectory.appendingPathComponent(name)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    /// Delete a dataset directory.
    func deleteDataset(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    /// Get available free disk space in bytes.
    func availableDiskSpace() -> Int64 {
        let url = documentsDirectory
        do {
            let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            return values.volumeAvailableCapacityForImportantUsage ?? 0
        } catch {
            return 0
        }
    }

    /// Get total disk space in bytes.
    func totalDiskSpace() -> Int64 {
        let url = documentsDirectory
        do {
            let values = try url.resourceValues(forKeys: [.volumeTotalCapacityKey])
            return values.volumeTotalCapacity ?? 0
        } catch {
            return 0
        }
    }
}
