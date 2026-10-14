//
//  GaussianLICTests.swift
//  GaussianLIC
//
//  Minimal test target placeholder. Real tests require LiDAR hardware.
//

import XCTest
@testable import GaussianLIC

final class GaussianLICTests: XCTestCase {

    func testDeviceProfileDetectionDoesNotCrash() {
        // DeviceProfile.detect() uses ARKit + Metal APIs that only work
        // on physical devices, but it should not crash on the simulator.
        let profile = DeviceProfile.detect()
        XCTAssertFalse(profile.modelName.isEmpty)
        XCTAssertFalse(profile.chipName.isEmpty)
    }

    func testFileStorageDirectoriesExist() {
        let storage = FileStorage.shared
        XCTAssertTrue(FileManager.default.fileExists(atPath: storage.datasetsDirectory.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: storage.modelsDirectory.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: storage.exportsDirectory.path))
    }

    func testTrainingRecordCodable() throws {
        let record = TrainingRecord(
            datasetName: "test_dataset",
            iterations: 500,
            finalLoss: 0.0123,
            gaussianCount: 50000,
            outputURL: nil,
            method: .onDevice
        )
        let data = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(TrainingRecord.self, from: data)
        XCTAssertEqual(record.datasetName, decoded.datasetName)
        XCTAssertEqual(record.iterations, decoded.iterations)
    }
}
