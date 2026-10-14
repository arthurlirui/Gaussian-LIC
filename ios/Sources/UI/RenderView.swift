//
//  RenderView.swift
//  GaussianLIC
//
//  SwiftUI view for the Render tab.
//  Provides a PLY file picker and a RealityKit splat renderer with
//  free-view and AR-live camera modes.
//

import SwiftUI
import RealityKit

struct RenderView: View {

    @EnvironmentObject var appState: AppState
    @State private var showFilePicker = false
    @State private var cameraMode: SplatCameraMode = .freeView

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if appState.sceneManager.isLoading {
                    LoadingProgressView(progress: appState.sceneManager.loadProgress)
                } else if appState.sceneManager.isInitialized {
                    // Splat renderer.
                    SplatRealityView(
                        sceneManager: appState.sceneManager,
                        captureSession: appState.captureSession,
                        cameraMode: cameraMode
                    )
                    .ignoresSafeArea()

                    // Camera mode picker + scene info.
                    RenderInfoBar(
                        sceneManager: appState.sceneManager,
                        cameraMode: $cameraMode
                    )
                } else if let error = appState.sceneManager.renderError {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Try Again") { showFilePicker = true }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    EmptyStateView(onLoad: { showFilePicker = true })
                }
            }
            .navigationTitle("Render")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilePicker = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showFilePicker) {
                ModelPickerView(sceneManager: appState.sceneManager)
            }
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let onLoad: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("No Scene Loaded")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Load a .ply file to render a Gaussian Splat scene.\nCapture data first, then train on-device or export for offline training.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button(action: onLoad) {
                Label("Load PLY File", systemImage: "doc")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Loading Progress

struct LoadingProgressView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress)
                .progressViewStyle(.circular)
            Text("Loading splat scene… \(Int(progress * 100))%")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Model Picker

struct ModelPickerView: View {
    @ObservedObject var sceneManager: SplatSceneManager
    @Environment(\.dismiss) var dismiss
    @State private var models: [URL] = []

    var body: some View {
        NavigationStack {
            List {
                if models.isEmpty {
                    Text("No PLY files found. Train a scene first or copy .ply files to the app's Documents/models/ directory.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(models, id: \.self) { url in
                        Button {
                            Task {
                                await sceneManager.loadScene(from: url)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "cube.transparent")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text(url.lastPathComponent)
                                        .font(.body)
                                    Text(url.deletingPathExtension().lastPathComponent)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Select PLY File")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                models = sceneManager.availableModels()
            }
        }
    }
}

// MARK: - Render Info Bar

struct RenderInfoBar: View {
    @ObservedObject var sceneManager: SplatSceneManager
    @Binding var cameraMode: SplatCameraMode

    var body: some View {
        VStack(spacing: 8) {
            Picker("Camera Mode", selection: $cameraMode) {
                ForEach(SplatCameraMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if let index = sceneManager.currentSceneIndex,
               index < sceneManager.loadedScenes.count {
                let scene = sceneManager.loadedScenes[index]
                HStack(spacing: 16) {
                    Label(scene.name, systemImage: "doc.fill")
                        .font(.caption)
                    Spacer()
                    Text("\(scene.splatCount.formatted()) splats")
                        .font(.caption.monospaced())
                    Text("\(Int(Double(scene.splatCount) / Double(sceneManager.maxGaussians) * 100))% budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}
