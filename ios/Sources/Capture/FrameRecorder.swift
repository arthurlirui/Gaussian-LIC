//
//  FrameRecorder.swift
//  GaussianLIC
//
//  Writes SensorFrame data to disk in a format compatible with
//  win_lic/sensors/dataset_reader.h::DatasetReader.
//
//  Output directory structure:
//    dataset_YYYYMMDD_HHMMSS/
//      images/000001.jpg          — RGB JPEG
//      depth/000001.bin            — Float32 raw depth (256×192)
//      depth_conf/000001.bin       — UInt8 confidence (256×192)
//      trajectory.txt              — TUM format: timestamp tx ty tz qx qy qz qw
//      imu.csv                     — timestamp,ax,ay,az,gx,gy,gz
//      intrinsics.txt              — fx fy cx cy width height
//      config.json                 — capture metadata
//
//  This format matches what DatasetReader expects, so the captured data
//  can be fed directly into the win_lic training pipeline on a Mac/CUDA server.
//

import Foundation
import ARKit
import CoreVideo
import ImageIO
import UniformTypeIdentifiers

/// Records SensorFrame data to disk in win_lic DatasetReader format.
final class FrameRecorder: @unchecked Sendable {

    private let outputDirectory: URL
    private let config: CaptureConfig

    // Subdirectories
    private let imageDir: URL
    private let depthDir: URL
    private let confDir: URL

    // Trajectory file handle (TUM format)
    private var trajectoryFileHandle: FileHandle?
    private let trajectoryQueue = DispatchQueue(label: "com.gaussianlic.trajectory")
    private let imuQueue = DispatchQueue(label: "com.gaussianlic.imu")

    // Counters
    private var frameCount = 0
    private var isRecording = false

    // Cached intrinsics (written once)
    private var intrinsicsWritten = false

    init(outputDirectory: URL, config: CaptureConfig) {
        self.outputDirectory = outputDirectory
        self.config = config

        self.imageDir = outputDirectory.appendingPathComponent("images")
        self.depthDir = outputDirectory.appendingPathComponent("depth")
        self.confDir = outputDirectory.appendingPathComponent("depth_conf")

        // Create subdirectories.
        try? FileManager.default.createDirectory(at: imageDir, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: depthDir, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: confDir, withIntermediateDirectories: true)
    }

    /// Start recording. Opens trajectory and IMU files.
    func start() {
        guard !isRecording else { return }
        isRecording = true
        frameCount = 0

        // Create trajectory.txt with TUM header.
        let trajectoryURL = outputDirectory.appendingPathComponent("trajectory.txt")
        let header = "# timestamp tx ty tz qx qy qz qw\n"
        FileManager.default.createFile(atPath: trajectoryURL.path, contents: header.data(using: .utf8))
        trajectoryFileHandle = try? FileHandle(forWritingTo: trajectoryURL)
        trajectoryFileHandle?.seekToEndOfFile()

        // Write IMU CSV header.
        let imuURL = outputDirectory.appendingPathComponent("imu.csv")
        let imuHeader = "timestamp,ax,ay,az,gx,gy,gz\n"
        try? imuHeader.write(to: imuURL, atomically: true, encoding: .utf8)
    }

    /// Stop recording and close files.
    func stop() {
        isRecording = false
        trajectoryQueue.sync {
            try? trajectoryFileHandle?.close()
            trajectoryFileHandle = nil
        }
    }

    /// Record a single sensor frame to disk.
    /// Called from the ARKit frame callback on the main thread.
    func record(_ frame: SensorFrame) {
        guard isRecording else { return }

        frameCount += 1
        let indexStr = String(format: "%06d", frame.frameIndex + 1)

        // Write intrinsics once (from first frame).
        if !intrinsicsWritten {
            writeIntrinsics(frame.intrinsics)
            writeMetadata(frame)
            intrinsicsWritten = true
        }

        // Write RGB image as JPEG.
        writeJPEG(from: frame.image, to: imageDir.appendingPathComponent("\(indexStr).jpg"))

        // Write depth map as raw Float32.
        writeDepth(from: frame.depthMap, to: depthDir.appendingPathComponent("\(indexStr).bin"))

        // Write confidence map as raw UInt8 (if present).
        if let conf = frame.confidenceMap {
            writeConfidence(from: conf, to: confDir.appendingPathComponent("\(indexStr).bin"))
        }

        // Append trajectory line (TUM format).
        writeTrajectory(frame)

        // Append IMU data.
        if let imu = frame.imuData {
            writeIMU(imu)
        }
    }

    // MARK: - Writers

    private func writeJPEG(from pixelBuffer: CVPixelBuffer, to url: URL) {
        // Convert YUV CVPixelBuffer to JPEG via CIImage.
        let ciContext = CIContext()
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        guard let colorSpace = ciImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB) else { return }

        _ = try? ciContext.writeJPEGRepresentation(
            of: ciImage,
            to: url,
            colorSpace: colorSpace,
            options: [CGImageDestinationOption(kCGImageDestinationLossyCompressionQuality as String): config.jpegQuality]
        )
    }

    private func writeDepth(from pixelBuffer: CVPixelBuffer, to url: URL) {
        // Depth map is Float32 (kCVPixelFormatType_DepthFloat32).
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

        // If bytesPerRow == width * 4, we can write directly.
        // Otherwise we need to handle row padding.
        if bytesPerRow == width * MemoryLayout<Float>.size {
            let totalBytes = width * height * MemoryLayout<Float>.size
            let data = Data(bytes: baseAddress, count: totalBytes)
            try? data.write(to: url)
        } else {
            // Handle row padding by copying row by row.
            var data = Data(capacity: width * height * MemoryLayout<Float>.size)
            for row in 0..<height {
                let rowPtr = baseAddress.advanced(by: row * bytesPerRow)
                let rowData = Data(bytes: rowPtr, count: width * MemoryLayout<Float>.size)
                data.append(rowData)
            }
            try? data.write(to: url)
        }
    }

    private func writeConfidence(from pixelBuffer: CVPixelBuffer, to url: URL) {
        // Confidence map is UInt8 (kCVPixelFormatType_OneComponent8).
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

        if bytesPerRow == width {
            let totalBytes = width * height
            let data = Data(bytes: baseAddress, count: totalBytes)
            try? data.write(to: url)
        } else {
            var data = Data(capacity: width * height)
            for row in 0..<height {
                let rowPtr = baseAddress.advanced(by: row * bytesPerRow)
                let rowData = Data(bytes: rowPtr, count: width)
                data.append(rowData)
            }
            try? data.write(to: url)
        }
    }

    private func writeTrajectory(_ frame: SensorFrame) {
        // TUM format: timestamp tx ty tz qx qy qz qw
        let t = frame.pose.translation
        let q = frame.pose.rotation

        let line = String(format: "%.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f\n",
                          frame.timestamp,
                          t.x, t.y, t.z,
                          q.vector.x, q.vector.y, q.vector.z, q.real)

        guard let data = line.data(using: .utf8) else { return }

        trajectoryQueue.async { [weak self] in
            try? self?.trajectoryFileHandle?.write(contentsOf: data)
        }
    }

    private func writeIMU(_ imu: IMUSample) {
        let line = String(format: "%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n",
                          imu.timestamp,
                          imu.accel.x, imu.accel.y, imu.accel.z,
                          imu.gyro.x, imu.gyro.y, imu.gyro.z)

        guard let data = line.data(using: .utf8) else { return }

        let imuURL = outputDirectory.appendingPathComponent("imu.csv")
        imuQueue.async {
            if let handle = try? FileHandle(forWritingTo: imuURL) {
                handle.seekToEndOfFile()
                try? handle.write(contentsOf: data)
                try? handle.close()
            }
        }
    }

    private func writeIntrinsics(_ intrinsics: CameraIntrinsics) {
        let line = "\(intrinsics.fx) \(intrinsics.fy) \(intrinsics.cx) \(intrinsics.cy) \(intrinsics.width) \(intrinsics.height)\n"
        let url = outputDirectory.appendingPathComponent("intrinsics.txt")
        try? line.write(to: url, atomically: true, encoding: .utf8)
    }

    private func writeMetadata(_ frame: SensorFrame) {
        let metadata: [String: Any] = [
            "depth_width": frame.depthWidth,
            "depth_height": frame.depthHeight,
            "image_width": frame.imageWidth,
            "image_height": frame.imageHeight,
            "depth_source": frame.depthSource.rawValue,
            "lidar_range": 5.0,
            "capture_date": ISO8601DateFormatter().string(from: Date()),
            "keyframe_interval": config.keyframeInterval,
            "use_smoothed_depth": config.useSmoothedDepth
        ]

        let url = outputDirectory.appendingPathComponent("config.json")
        if let data = try? JSONSerialization.data(withJSONObject: metadata, options: .prettyPrinted) {
            try? data.write(to: url)
        }
    }
}
