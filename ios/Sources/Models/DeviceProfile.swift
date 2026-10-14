//
//  DeviceProfile.swift
//  GaussianLIC
//
//  Detects the iPhone model and its sensor capabilities.
//  Gaussian-LIC requires a LiDAR-equipped device (iPhone Pro series).
//  This module queries ARKit and the hardware to determine what
//  sensors are available and their characteristics.
//

import Foundation
import ARKit
import UIKit
import Metal

/// Describes the capabilities of the current device for Gaussian Splatting capture.
struct DeviceProfile: Identifiable {
    let id = UUID()

    // Device identification
    let modelIdentifier: String    // e.g. "iPhone15,2" (iPhone 14 Pro)
    let modelName: String          // e.g. "iPhone 14 Pro"
    let chipName: String           // e.g. "A16 Bionic"

    // Sensor capabilities
    let hasLiDAR: Bool
    let supportsSceneDepth: Bool
    let supportsSmoothedSceneDepth: Bool
    let supportsSceneReconstruction: Bool
    let hasTrueDepthFront: Bool

    // Depth characteristics (LiDAR)
    let depthResolution: (width: Int, height: Int)  // typically 256×192
    let lidarRange: Float         // metres, typically ~5.0
    let depthAccuracy: Float      // metres, typically ~0.01–0.02

    // RGB camera
    let rgbResolution: (width: Int, height: Int)

    // GPU / Metal
    let gpuName: String
    let recommendedMaxWorkingSetSize: UInt64  // bytes

    // Memory
    let totalMemory: UInt64  // bytes (physical RAM)

    // Compute
    let supportsMetal3: Bool
    let maxThreadgroupMemorySize: Int

    /// True if the device can run the full capture pipeline.
    var isCapable: Bool {
        hasLiDAR && supportsSceneDepth
    }

    /// Maximum recommended Gaussian count for rendering (memory-safety cap).
    /// Derived from the Jetson Orin Nano config pattern in win_lic: we cap
    /// based on available GPU working set size, targeting ~1 GB for splat data.
    /// Each splat in MetalSplatter's EncodedSplatPoint format is ~32 bytes,
    /// so 300K splats ≈ 9.6 MB — well within budget. The real constraint is
    /// the sort buffer and chunk overhead, so we use 300K as a safe default.
    var maxRecommendedGaussians: Int {
        // Scale based on device memory tier.
        // iPhone 14-15 Pro (6 GB RAM): 200K
        // iPhone 16 Pro (8 GB RAM): 400K
        // iPhone 17-18 Pro (8+ GB RAM): 500K
        switch totalMemory {
        case ..<(6 * 1024 * 1024 * 1024):
            return 150_000
        case ..<(8 * 1024 * 1024 * 1024):
            return 300_000
        default:
            return 500_000
        }
    }

    // MARK: - Detection

    /// Detect the current device's capabilities.
    static func detect() -> DeviceProfile {
        let identifier = machineIdentifier()
        let name = modelName(for: identifier)
        let chip = chipName(for: identifier)

        let supportsDepth = ARWorldTrackingConfiguration.supportsFrameSemantics([.sceneDepth])
        let supportsSmoothed = ARWorldTrackingConfiguration.supportsFrameSemantics([.smoothedSceneDepth])
        let supportsReconstruction = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)

        // LiDAR is available if scene depth is supported.
        let hasLiDAR = supportsDepth

        // TrueDepth front camera (for face scanning mode).
        let hasTrueDepth = ARFaceTrackingConfiguration.isSupported

        // GPU info.
        let device = MTLCreateSystemDefaultDevice()
        let gpuName = device?.name ?? "Unknown GPU"
        let workingSetSize = device?.recommendedMaxWorkingSetSize ?? 0
        let maxThreadgroupMem = device?.maxThreadgroupMemoryLength ?? 0
        let supportsMetal3 = device?.supportsFamily(.apple5) ?? false

        // Physical memory (use ProcessInfo on iOS 14+).
        let totalMem = ProcessInfo.processInfo.physicalMemory

        return DeviceProfile(
            modelIdentifier: identifier,
            modelName: name,
            chipName: chip,
            hasLiDAR: hasLiDAR,
            supportsSceneDepth: supportsDepth,
            supportsSmoothedSceneDepth: supportsSmoothed,
            supportsSceneReconstruction: supportsReconstruction,
            hasTrueDepthFront: hasTrueDepth,
            depthResolution: (256, 192),
            lidarRange: 5.0,
            depthAccuracy: 0.015,
            rgbResolution: (1920, 1440),
            gpuName: gpuName,
            recommendedMaxWorkingSetSize: workingSetSize,
            totalMemory: totalMem,
            supportsMetal3: supportsMetal3,
            maxThreadgroupMemorySize: maxThreadgroupMem
        )
    }

    // MARK: - Hardware Identification

    /// Get the machine hardware identifier (e.g. "iPhone15,2").
    private static func machineIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    /// Map hardware identifier to human-readable model name.
    /// Covers iPhone 14 Pro through iPhone 18 Pro.
    private static func modelName(for identifier: String) -> String {
        switch identifier {
        // iPhone 14 Pro / Pro Max
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        // iPhone 15 Pro / Pro Max
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        // iPhone 16 Pro / Pro Max
        case "iPhone17,1": return "iPhone 16 Pro"
        case "iPhone17,2": return "iPhone 16 Pro Max"
        // iPhone 17 Pro / Pro Max (projected identifiers)
        case "iPhone18,1": return "iPhone 17 Pro"
        case "iPhone18,2": return "iPhone 17 Pro Max"
        // iPhone 18 Pro / Pro Max (projected identifiers)
        case "iPhone19,1": return "iPhone 18 Pro"
        case "iPhone19,2": return "iPhone 18 Pro Max"
        // Non-Pro models (no LiDAR)
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone17,3": return "iPhone 16"
        case "iPhone17,4": return "iPhone 16 Plus"
        // Simulator
        case "x86_64", "arm64":
            return "Simulator (no LiDAR)"
        default:
            return "Unknown (\(identifier))"
        }
    }

    /// Map hardware identifier to chip name.
    private static func chipName(for identifier: String) -> String {
        switch identifier {
        case "iPhone15,2", "iPhone15,3": return "A16 Bionic"
        case "iPhone16,1", "iPhone16,2": return "A17 Pro"
        case "iPhone17,1", "iPhone17,2": return "A18 Pro"
        case "iPhone18,1", "iPhone18,2": return "A19 Pro"
        case "iPhone19,1", "iPhone19,2": return "A20 Pro"
        default: return "Unknown"
        }
    }
}
