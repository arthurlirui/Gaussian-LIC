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
    void pushLidar(const AlignedFrame& frame)
    {
        std::lock_guard<std::mutex> lock(mtx_);
        lidar_buf_.push_back(frame);
    }

    /// Push an RGB image frame.
    void pushImage(const AlignedFrame& frame)
    {
        std::lock_guard<std::mutex> lock(mtx_);
        image_buf_.push_back(frame);
    }

    /// Push a depth frame.
    void pushDepth(const AlignedFrame& frame)
    {
        std::lock_guard<std::mutex> lock(mtx_);
        depth_buf_.push_back(frame);
    }

    /// Push a pose.
    void pushPose(const CameraPose& pose)
    {
        std::lock_guard<std::mutex> lock(mtx_);
        pose_buf_.push_back(pose);
    }

    /// Try to extract one set of aligned data.
    /// The LiDAR buffer defines the reference timestamps. For each LiDAR
    /// frame, we search the other buffers for the closest match within
    /// tolerance_ and merge them into a single AlignedFrame.
    /// Returns true if a complete aligned frame is available.
    bool getAligned(AlignedFrame& out)
    {
        std::lock_guard<std::mutex> lock(mtx_);

        if (lidar_buf_.empty() || image_buf_.empty() || pose_buf_.empty())
            return false;

        double ref_time = lidar_buf_.front().timestamp;

        // Find matching image
        while (!image_buf_.empty() &&
               image_buf_.front().timestamp < ref_time - tolerance_)
        {
            image_buf_.pop_front();
        }
        if (image_buf_.empty() ||
            std::abs(image_buf_.front().timestamp - ref_time) > tolerance_)
            return false;

        // Find matching pose
        while (!pose_buf_.empty() &&
               pose_buf_.front().timestamp < ref_time - tolerance_)
        {
            pose_buf_.pop_front();
        }
        if (pose_buf_.empty() ||
            std::abs(pose_buf_.front().timestamp - ref_time) > tolerance_)
            return false;

        // Find matching depth (optional)
        if (!depth_buf_.empty())
        {
            while (!depth_buf_.empty() &&
                   depth_buf_.front().timestamp < ref_time - tolerance_)
            {
                depth_buf_.pop_front();
            }
            if (!depth_buf_.empty() &&
                std::abs(depth_buf_.front().timestamp - ref_time) <= tolerance_)
            {
                out.lidar_depth = depth_buf_.front().lidar_depth;
                depth_buf_.pop_front();
            }
        }

        // Merge
        out = lidar_buf_.front();
        out.image = image_buf_.front().image;
        out.pose = pose_buf_.front();
        out.is_keyframe = false;  // decided by pipeline later

        lidar_buf_.pop_front();
        image_buf_.pop_front();
        pose_buf_.pop_front();

        return true;
    }

private:
    double tolerance_;
    std::mutex mtx_;
    std::deque<AlignedFrame> lidar_buf_;
    std::deque<AlignedFrame> image_buf_;
    std::deque<AlignedFrame> depth_buf_;
    std::deque<CameraPose>   pose_buf_;
};

}  // namespace winlic
