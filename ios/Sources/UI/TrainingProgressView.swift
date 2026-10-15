//
//  TrainingProgressView.swift
//  GaussianLIC
//
//  SwiftUI view for the Train tab.
//  Provides two training paths:
//    1. On-device training via MLX Swift (Apple's Metal-backed ML framework)
//    2. Offline export to win_lic format for training on a Mac/CUDA server
//

import SwiftUI

struct TrainingProgressView: View {

    @EnvironmentObject var appState: AppState
    @StateObject private var historyStore = TrainingHistoryStore()
    @StateObject private var trainer = OnDeviceTrainer()

    @State private var selectedDataset: URL?
    @State private var datasets: [CapturedDataset] = []
    @State private var trainingMethod: TrainingMethod = .onDevice
    @State private var showExportSheet = false
    @State private var exportURL: URL?

    // Training parameter presets.
    @State private var iterationPreset: Int = 500

    var body: some View {
        NavigationStack {
            List {
                // Section: Training method selection.
                Section("Training Method") {
                    Picker("Method", selection: $trainingMethod) {
                        ForEach(TrainingMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Section: Dataset selection.
                Section("Dataset") {
                    if datasets.isEmpty {
                        Text("No captured datasets. Use the Capture tab to record sensor data first.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(datasets) { dataset in
                            Button {
                                selectedDataset = dataset.url
                            } label: {
                                HStack {
                                    Image(systemName: selectedDataset == dataset.url
                                          ? "checkmark.circle.fill" : "folder")
                                        .foregroundColor(selectedDataset == dataset.url ? .blue : .secondary)
                                    VStack(alignment: .leading) {
                                        Text(dataset.name)
                                            .font(.body)
                                        Text("\(dataset.frameCount) frames · \(dataset.sizeDescription)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Section: Parameters (on-device only).
                if trainingMethod == .onDevice {
                    Section("Training Parameters") {
                        Picker("Iterations", selection: $iterationPreset) {
                            Text("300 (Quick)").tag(300)
                            Text("500 (Recommended)").tag(500)
                            Text("1000 (High Quality)").tag(1000)
                        }
                        .pickerStyle(.segmented)

                        HStack {
                            Text("Max Gaussians")
                            Spacer()
                            Text(appState.deviceProfile.maxRecommendedGaussians.formatted())
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Section: Action button.
                Section {
                    Button {
                        startTraining()
                    } label: {
                        HStack {
                            Image(systemName: trainingMethod == .onDevice
                                  ? "play.fill" : "square.and.arrow.up")
                            Text(trainingMethod == .onDevice ? "Start On-Device Training" : "Export for Offline Training")
                        }
                    }
                    .disabled(selectedDataset == nil)
                    .buttonStyle(.borderedProminent)
                }

                // Section: Live training progress.
                if trainer.isActive {
                    Section("Training Progress") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Iteration")
                                Spacer()
                                Text("\(trainer.currentIteration) / \(trainer.totalIterations)")
                                    .monospacedDigit()
                            }
                            HStack {
                                Text("Loss")
                                Spacer()
                                Text(String(format: "%.6f", trainer.currentLoss))
                                    .monospacedDigit()
                            }
                            HStack {
                                Text("Gaussians")
                                Spacer()
                                Text(trainer.gaussianCount.formatted())
                                    .monospacedDigit()
                            }
                            ProgressView(value: Double(trainer.currentIteration),
                                         total: Double(trainer.totalIterations))

                            if trainer.estimatedTimeRemaining > 0 {
                                HStack {
                                    Text("ETA")
                                    Spacer()
                                    Text(formatDuration(trainer.estimatedTimeRemaining))
                                        .foregroundColor(.secondary)
                                }
                            }

                            Button("Cancel") {
                                trainer.cancel()
                            }
                            .foregroundColor(.red)
                        }
                    }
                }

                // Section: Training history.
                Section("History") {
                    if historyStore.records.isEmpty {
                        Text("No training sessions yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(historyStore.records) { record in
                            TrainingRecordRow(record: record)
                        }
                        .onDelete { indices in
                            for i in indices { historyStore.remove(at: i) }
                        }
                    }
                }
            }
            .navigationTitle("Train")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                refreshDatasets()
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    // MARK: - Actions

    private func refreshDatasets() {
        datasets = DatasetExporter.listDatasets()
    }

    private func startTraining() {
        guard let dataset = selectedDataset else { return }

        switch trainingMethod {
        case .onDevice:
            Task {
                let record = TrainingRecord(
                    datasetName: dataset.lastPathComponent,
                    method: .onDevice
                )
                historyStore.add(record)
                var activeRecord = record

                await trainer.train(
                    datasetURL: dataset,
                    iterations: iterationPreset,
                    maxGaussians: appState.deviceProfile.maxRecommendedGaussians,
                    onProgress: { iteration, loss, gaussianCount in
                        activeRecord.iterations = iteration
                        activeRecord.finalLoss = loss
                        activeRecord.gaussianCount = gaussianCount
                        activeRecord.status = .running
                        historyStore.update(activeRecord)
                    },
                    onComplete: { plyURL in
                        activeRecord.status = .completed
                        activeRecord.durationSeconds = trainer.elapsedSeconds
                        activeRecord.outputURL = plyURL
                        historyStore.update(activeRecord)

                        // Auto-load the trained PLY into the renderer.
                        if let plyURL {
                            Task { await appState.sceneManager.loadScene(from: plyURL) }
                        }
                    }
                )
            }

        case .offline:
            // Generate training config and package the dataset.
            if let configURL = DatasetExporter.generateTrainingConfig(datasetURL: dataset) {
                let validation = DatasetExporter.verifyIntegrity(datasetURL: dataset)
                if validation.isValid {
                    if let zipURL = DatasetExporter.packageAsZip(datasetURL: dataset) {
                        exportURL = zipURL
                        showExportSheet = true
                    }
                } else {
                    // Validation issues — still allow export but warn.
                    exportURL = configURL
                    showExportSheet = true
                }

                let record = TrainingRecord(
                    datasetName: dataset.lastPathComponent,
                    method: .offline,
                    status: .completed,
                    outputURL: exportURL
                )
                historyStore.add(record)
            }
        }
    }

    private func formatDuration(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%dm %02ds", mins, secs)
    }
}

// MARK: - Training Record Row

struct TrainingRecordRow: View {
    let record: TrainingRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: record.method == .onDevice ? "iphone" : "macmini")
                    .foregroundColor(.blue)
                Text(record.datasetName)
                    .font(.body)
                Spacer()
                StatusBadge(status: record.status)
            }
            HStack(spacing: 12) {
                Text("\(record.iterations) iters")
                    .font(.caption)
                Text(record.gaussianCount.formatted() + " splats")
                    .font(.caption)
                Text(record.durationDescription)
                    .font(.caption)
                if record.finalLoss > 0 {
                    Text("loss: \(String(format: "%.4f", record.finalLoss))")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
        }
    }
}

struct StatusBadge: View {
    let status: TrainingStatus

    var color: Color {
        switch status {
        case .pending: return .gray
        case .running: return .blue
        case .completed: return .green
        case .cancelled: return .orange
        case .failed: return .red
        }
    }

    var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
