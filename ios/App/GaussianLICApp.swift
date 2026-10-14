//
//  GaussianLICApp.swift
//  GaussianLIC — iOS Gaussian Splatting Capture, Training & Rendering
//
//  Created by arthurlirui, 2026.
//  Ported from the win_lic (Windows-compatible) branch of Gaussian-LIC2.
//
//  Architecture:
//    - Capture tab: ARKit RGB/LiDAR/Depth/IMU sensor capture → disk dataset
//    - Render tab: RealityKit GaussianSplatComponent for PLY scene viewing
//    - Train tab: On-device msplat Metal training or offline dataset export
//    - Device tab: Hardware capability detection (iPhone 14 Pro – 18 Pro)
//

import SwiftUI

@main
struct GaussianLICApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

/// Global app state shared across all tabs.
@MainActor
final class AppState: ObservableObject {
    /// The active capture session (shared so any view can start/stop it).
    @Published var captureSession = CaptureSession()

    /// The active splat scene manager for rendering.
    @Published var sceneManager = SplatSceneManager()

    /// Detected device capabilities (LiDAR, chipset, etc.).
    @Published var deviceProfile = DeviceProfile.detect()

    /// Currently selected tab.
    @Published var selectedTab: AppTab = .capture

    /// Paths to captured datasets awaiting training.
    @Published var capturedDatasets: [URL] = []

    func refreshCapturedDatasets() {
        capturedDatasets = FileStorage.shared.listCapturedDatasets()
    }
}

enum AppTab: Hashable {
    case capture
    case render
    case training
    case settings
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            CaptureView()
                .tabItem {
                    Label("Capture", systemImage: "camera.viewfinder")
                }
                .tag(AppTab.capture)

            RenderView()
                .tabItem {
                    Label("Render", systemImage: "cube.transparent")
                }
                .tag(AppTab.render)

            TrainingProgressView()
                .tabItem {
                    Label("Train", systemImage: "gearshape.2")
                }
                .tag(AppTab.training)

            DeviceCapabilityView()
                .tabItem {
                    Label("Device", systemImage: "cpu")
                }
                .tag(AppTab.settings)
        }
        .onAppear {
            appState.refreshCapturedDatasets()
        }
    }
}
