//
//  IMURecorder.swift
//  GaussianLIC
//
//  Records raw IMU data (accelerometer + gyroscope) via CoreMotion.
//  ARKit's VIO already fuses IMU into the camera pose, but we also
//  capture raw accel/gyro for offline SLAM pipelines (matching win_lic's
//  imu.csv format) and for potential on-device training.
//
//  Corresponds to win_lic/sensors/imu_io.h/.cpp (the reader side),
//  but here we are the producer.
//

import Foundation
import CoreMotion

/// Records raw IMU data from CoreMotion at a fixed rate.
/// Uses a lock-free ring buffer so the ARKit frame delegate can snapshot
/// the most recent sample without blocking.
final class IMURecorder: @unchecked Sendable {

    /// IMU update rate in Hz. 100 Hz matches typical SLAM IMU configs.
    static let updateRate: Double = 100.0

    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()

    /// Lock-protected latest sample for quick snapshot.
    private let lock = NSLock()
    private var _latestSample: IMUSample?

    /// Ring buffer of recent samples for recording.
    private let bufferLock = NSLock()
    private var buffer: [IMUSample] = []
    private let maxBufferSize = 6000  // 60 seconds at 100 Hz

    /// Whether recording is active.
    private(set) var isRecording = false

    /// Timestamp offset between CFAbsoluteTime and ARKit timestamp domain.
    /// ARKit frame timestamps are in seconds since the device boot.
    /// CMMotion timestamps are in seconds since the device boot (referenceTimestamp).
    /// We store both in the device-boot timebase for alignment.
    private var timeOffset: Double = 0

    init() {
        queue.qualityOfService = .userInteractive
        queue.name = "com.gaussianlic.imu"
    }

    /// Start recording IMU data.
    func start() {
        guard !isRecording else { return }

        motionManager.accelerometerUpdateInterval = 1.0 / Self.updateRate
        motionManager.gyroUpdateInterval = 1.0 / Self.updateRate

        // Use deviceMotion for fused accel+gyro (gravity removed from userAcceleration).
        // For raw accelerometer (including gravity), use accelerometerUpdates.
        // SLAM pipelines typically want raw accel including gravity for proper
        // motion model integration, so we use the raw sensors.
        motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, _ in
            guard let self, let data = data else { return }
            self.onAccelerometerUpdate(data)
        }

        motionManager.startGyroUpdates(to: queue) { [weak self] data, _ in
            guard let self, let data = data else { return }
            self.onGyroUpdate(data)
        }

        isRecording = true
    }

    /// Stop recording and return all buffered samples.
    func stop() -> [IMUSample] {
        guard isRecording else { return [] }
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        isRecording = false

        bufferLock.lock()
        let samples = buffer
        buffer.removeAll()
        bufferLock.unlock()

        return samples
    }

    /// Snapshot the most recent IMU sample for tagging onto an ARFrame.
    func latestSample() -> IMUSample? {
        lock.lock()
        defer { lock.unlock() }
        return _latestSample
    }

    /// Drain and return all buffered samples without stopping.
    func drainBuffer() -> [IMUSample] {
        bufferLock.lock()
        let samples = buffer
        buffer.removeAll()
        bufferLock.unlock()
        return samples
    }

    // MARK: - Private

    private var lastAccel: CMAcceleration?
    private var lastGyro: CMRotationRate?

    private func onAccelerometerUpdate(_ data: CMAccelerometerData) {
        lastAccel = data.acceleration
        mergeIfReady(timestamp: data.timestamp)
    }

    private func onGyroUpdate(_ data: CMGyroData) {
        lastGyro = data.rotationRate
        mergeIfReady(timestamp: data.timestamp)
    }

    /// Merge accel+gyro into a single IMUSample when both are available.
    private func mergeIfReady(timestamp: Double) {
        guard let accel = lastAccel, let gyro = lastGyro else { return }

        // CMAccelerometerData.timestamp is in seconds since device boot
        // (same timebase as ARFrame.timestamp on iOS).
        let sample = IMUSample(
            timestamp: timestamp,
            accel: SIMD3(Double(accel.x), Double(accel.y), Double(accel.z)),
            gyro: SIMD3(Double(gyro.x), Double(gyro.y), Double(gyro.z))
        )

        lock.lock()
        _latestSample = sample
        lock.unlock()

        bufferLock.lock()
        buffer.append(sample)
        if buffer.count > maxBufferSize {
            buffer.removeFirst(buffer.count - maxBufferSize)
        }
        bufferLock.unlock()
    }
}
