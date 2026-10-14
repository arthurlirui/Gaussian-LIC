//
//  DeviceCapabilityView.swift
//  GaussianLIC
//
//  Displays the detected device capabilities: model, chip, LiDAR,
//  GPU, memory, and the recommended Gaussian splat budget.
//

import SwiftUI

struct DeviceCapabilityView: View {

    @EnvironmentObject var appState: AppState

    private var profile: DeviceProfile { appState.deviceProfile }

    var body: some View {
        NavigationStack {
            List {
                // Device identity.
                Section("Device") {
                    InfoRow(label: "Model", value: profile.modelName)
                    InfoRow(label: "Identifier", value: profile.modelIdentifier)
                    InfoRow(label: "Chip", value: profile.chipName)
                }

                // Sensor capabilities.
                Section("Sensors") {
                    CapabilityRow(label: "LiDAR Scanner", enabled: profile.hasLiDAR)
                    CapabilityRow(label: "Scene Depth", enabled: profile.supportsSceneDepth)
                    CapabilityRow(label: "Smoothed Scene Depth", enabled: profile.supportsSmoothedSceneDepth)
                    CapabilityRow(label: "Scene Reconstruction", enabled: profile.supportsSceneReconstruction)
                    CapabilityRow(label: "TrueDepth (Front)", enabled: profile.hasTrueDepthFront)
                }

                // Depth characteristics.
                Section("LiDAR Depth") {
                    InfoRow(label: "Resolution", value: "\(profile.depthResolution.width)×\(profile.depthResolution.height)")
                    InfoRow(label: "Range", value: String(format: "%.1f m", profile.lidarRange))
                    InfoRow(label: "Accuracy", value: String(format: "%.3f m", profile.depthAccuracy))
                }

                // RGB camera.
                Section("RGB Camera") {
                    InfoRow(label: "Resolution", value: "\(profile.rgbResolution.width)×\(profile.rgbResolution.height)")
                }

                // GPU.
                Section("GPU") {
                    InfoRow(label: "GPU", value: profile.gpuName)
                    InfoRow(label: "Metal 3", value: profile.supportsMetal3 ? "Supported" : "Not Supported")
                    InfoRow(label: "Max Threadgroup Memory",
                            value: ByteCountFormatter.string(fromByteCount: Int64(profile.maxThreadgroupMemorySize),
                                                              countStyle: .memory))
                    InfoRow(label: "Working Set",
                            value: ByteCountFormatter.string(fromByteCount: Int64(profile.recommendedMaxWorkingSetSize),
                                                              countStyle: .memory))
                }

                // Memory.
                Section("Memory") {
                    InfoRow(label: "Physical RAM",
                            value: ByteCountFormatter.string(fromByteCount: Int64(profile.totalMemory),
                                                              countStyle: .memory))
                    InfoRow(label: "Splat Budget",
                            value: "\(profile.maxRecommendedGaussians.formatted()) splats")
                }

                // Overall readiness.
                Section {
                    HStack {
                        Image(systemName: profile.isCapable ? "checkmark.seal.fill" : "xmark.seal.fill")
                            .foregroundColor(profile.isCapable ? .green : .red)
                        VStack(alignment: .leading) {
                            Text(profile.isCapable ? "Device Ready" : "Device Not Supported")
                                .font(.headline)
                            Text(profile.isCapable
                                 ? "This device can run the full Gaussian-LIC capture and training pipeline."
                                 : "An iPhone Pro model (14 Pro or later) with LiDAR is required.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Device")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helper Views

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .font(.body.monospaced())
        }
    }
}

struct CapabilityRow: View {
    let label: String
    let enabled: Bool

    var body: some View {
        HStack {
            Image(systemName: enabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(enabled ? .green : .red)
            Text(label)
        }
    }
}
