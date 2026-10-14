//
//  TrainingRecord.swift
//  GaussianLIC
//
//  Tracks completed training sessions (on-device or off-device export).
//  Persisted to a JSON file in the app's Documents directory so the
//  training history survives app restarts.
//

import Foundation

/// Training method identifier.
enum TrainingMethod: String, Codable, CaseIterable {
    case onDevice = "On-Device (Metal)"
    case offline = "Offline Export"
}

/// A completed or in-progress training session record.
struct TrainingRecord: Identifiable, Codable {
    let id: UUID
    let datasetName: String
    let startTime: Date
    var durationSeconds: Double
    var iterations: Int
    var finalLoss: Double
    var gaussianCount: Int
    var outputURL: URL?
    var method: TrainingMethod
    var status: TrainingStatus

    init(id: UUID = UUID(),
         datasetName: String,
         startTime: Date = Date(),
         durationSeconds: Double = 0,
         iterations: Int = 0,
         finalLoss: Double = 0,
         gaussianCount: Int = 0,
         outputURL: URL? = nil,
         method: TrainingMethod,
         status: TrainingStatus = .pending) {
        self.id = id
        self.datasetName = datasetName
        self.startTime = startTime
        self.durationSeconds = durationSeconds
        self.iterations = iterations
        self.finalLoss = finalLoss
        self.gaussianCount = gaussianCount
        self.outputURL = outputURL
        self.method = method
        self.status = status
    }

    var durationDescription: String {
        let mins = Int(durationSeconds) / 60
        let secs = Int(durationSeconds) % 60
        return String(format: "%dm %02ds", mins, secs)
    }
}

enum TrainingStatus: String, Codable {
    case pending = "Pending"
    case running = "Running"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case failed = "Failed"
}

/// Manages persistence of training history.
@MainActor
final class TrainingHistoryStore: ObservableObject {

    @Published private(set) var records: [TrainingRecord] = []

    private let storageURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.storageURL = docs.appendingPathComponent("training_history.json")
        load()
    }

    func add(_ record: TrainingRecord) {
        records.insert(record, at: 0)
        save()
    }

    func update(_ record: TrainingRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            save()
        }
    }

    func remove(at index: Int) {
        guard index < records.count else { return }
        records.remove(at: index)
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: storageURL),
              let decoded = try? JSONDecoder().decode([TrainingRecord].self, from: data) else {
            return
        }
        records = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        try? data.write(to: storageURL)
    }
}
