/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * Data aligner — timestamp-based multi-modal data synchronization.
 *
 * In the original ROS system, alignment was implicit: ROS subscribers pushed
 * messages into four queues and getAlignedData() matched them by timestamp.
 * In the offline framework, the DatasetReader pre-aligns data by frame index
 * (since all modalities share the same frame numbering). This class provides
 * an optional timestamp-based alignment utility for cases where modalities
 * arrive at different rates (e.g. live Orbbec streaming).
 */

#pragma once

#include "core/types.h"
#include <deque>
#include <mutex>

namespace winlic {

class DataAligner
{
public:
    /// Tolerance for timestamp matching (seconds).
    explicit DataAligner(double tolerance = 0.01) : tolerance_(tolerance) {}

    /// Push a LiDAR point cloud frame.
    void pushLidar(const AlignedFrame& frame) { push(lidar_buf_, frame); }

    /// Push an RGB image frame.
    void pushImage(const AlignedFrame& frame) { push(image_buf_, frame); }

    /// Push a depth frame.
    void pushDepth(const AlignedFrame& frame) { push(depth_buf_, frame); }

    /// Push a pose.
    void pushPose(const CameraPose& pose);

    /// Try to extract one set of aligned data.
    /// Returns true if a complete aligned frame is available.
    bool getAligned(AlignedFrame& out);

private:
    template <typename T>
    void push(std::deque<T>& buf, const T& item)
    {
        std::lock_guard<std::mutex> lock(mtx_);
        buf.push_back(item);
    }

    double tolerance_;
    std::mutex mtx_;
    std::deque<AlignedFrame> lidar_buf_;
    std::deque<AlignedFrame> image_buf_;
    std::deque<AlignedFrame> depth_buf_;
    std::deque<CameraPose>   pose_buf_;
};

}  // namespace winlic
