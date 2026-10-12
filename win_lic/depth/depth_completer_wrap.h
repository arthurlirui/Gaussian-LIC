/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * DepthCompleter wrapper — adapts the original TensorRT-based SPNet depth
 * completer (from src/depth_completer.h) to the winlic namespace.
 *
 * The original DepthCompleter class is already ROS-free (uses only NvInfer,
 * CUDA, and OpenCV), so this wrapper is a thin convenience layer.
 */

#pragma once

#include "depth_completer.h"  // original class (copied to win_lic/depth/)
#include <opencv2/core.hpp>
#include <memory>
#include <string>

namespace winlic {

class DepthCompleterWrapper
{
public:
    DepthCompleterWrapper(const std::string& engine_path,
                           int input_width, int input_height)
        : completer_(engine_path, input_width, input_height) {}

    /// Complete a sparse depth map using the SPNet TensorRT engine.
    /// @param rgb_image   RGB float32 image, 0-1, HWC (CV_32FC3)
    /// @param depth_map   Sparse metric depth map, float32 (CV_32FC1)
    /// @return Dense completed metric depth map (CV_32FC1)
    cv::Mat complete(const cv::Mat& rgb_image, const cv::Mat& depth_map)
    {
        return completer_.complete(rgb_image, depth_map);
    }

    bool isAvailable() const { return true; }

private:
    ::DepthCompleter completer_;
};

}  // namespace winlic
