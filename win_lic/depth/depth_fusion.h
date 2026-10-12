/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * Multi-modal depth fusion — combines sparse LiDAR depth, dense iToF depth,
 * and stereo SGM depth into a single confidence-weighted depth map.
 *
 * Fusion strategy:
 *   1. LiDAR depth is treated as high-confidence sparse ground truth.
 *   2. iToF depth is dense but noisy, especially at depth discontinuities.
 *   3. Stereo depth is dense but fails in textureless regions.
 *   4. For each pixel, select the depth from the highest-confidence available source.
 *   5. Where multiple sources agree (within a tolerance), average them.
 *   6. The fused depth map is then optionally passed to the SPNet depth completer.
 */

#pragma once

#include "core/types.h"
#include "core/params.h"
#include <opencv2/core.hpp>

namespace winlic {

class DepthFusion
{
public:
    explicit DepthFusion(const DepthFusionConfig& cfg);

    /// Project a LiDAR point cloud into a sparse depth map.
    /// @param cloud      Point cloud in camera frame (or world frame with pose).
    /// @param pose       Camera pose (camera-to-world).
    /// @param fx, fy, cx, cy  Camera intrinsics.
    /// @param width, height   Image dimensions.
    /// @return Sparse float32 depth map (metric, metres). Zero = no LiDAR hit.
    static cv::Mat projectLidarDepth(const std::vector<PointXYZRGB>& cloud,
                                     const CameraPose& pose,
                                     double fx, double fy,
                                     double cx, double cy,
                                     int width, int height);

    /// Compute stereo depth via Semi-Global Matching (SGM).
    /// @param left, right  Rectified stereo pair (BGR8 or grayscale).
    /// @param baseline     Stereo baseline in metres.
    /// @param fx           Focal length in pixels.
    /// @return Dense float32 depth map (metric, metres).
    cv::Mat computeStereoDepth(const cv::Mat& left, const cv::Mat& right,
                                double baseline, double fx) const;

    /// Fuse multiple depth sources into a single depth map.
    /// Priority: LiDAR > iToF > Stereo. Where sources overlap and agree
    /// (within tolerance), the weighted average is used.
    /// @param lidar_depth   Sparse LiDAR depth (CV_32F, metres). May be empty.
    /// @param itof_depth    Dense iToF depth (CV_32F, metres). May be empty.
    /// @param stereo_depth  Dense stereo depth (CV_32F, metres). May be empty.
    /// @return Fused depth map (CV_32F, metres).
    cv::Mat fuse(const cv::Mat& lidar_depth,
                 const cv::Mat& itof_depth,
                 const cv::Mat& stereo_depth) const;

    /// Compute a confidence map for a depth source.
    /// LiDAR: binary (1.0 at hit pixels, 0 elsewhere).
    /// iToF: edge-based confidence (lower near depth discontinuities).
    /// Stereo: texture-based confidence (lower in textureless regions).
    static cv::Mat computeConfidence(const cv::Mat& depth, DepthSource source);

private:
    DepthFusionConfig cfg_;

    /// Tolerance for considering two depth measurements as "agreeing" (metres).
    double agreement_tolerance_ = 0.15;
};

}  // namespace winlic
