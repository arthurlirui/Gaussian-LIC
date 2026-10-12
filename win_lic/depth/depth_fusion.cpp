/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * DepthFusion implementation.
 */

#include "depth_fusion.h"

#include <opencv2/imgproc.hpp>
#include <opencv2/calib3d.hpp>
#include <opencv2/imgcodecs.hpp>

#include <iostream>
#include <cmath>

namespace winlic {

// ---------------------------------------------------------------------------
// Constructor
// ---------------------------------------------------------------------------
DepthFusion::DepthFusion(const DepthFusionConfig& cfg)
    : cfg_(cfg)
{
}

// ---------------------------------------------------------------------------
// projectLidarDepth — project a 3D point cloud into a sparse depth image
// ---------------------------------------------------------------------------
cv::Mat DepthFusion::projectLidarDepth(const std::vector<PointXYZRGB>& cloud,
                                        const CameraPose& pose,
                                        double fx, double fy,
                                        double cx, double cy,
                                        int width, int height)
{
    cv::Mat depth = cv::Mat::zeros(height, width, CV_32F);

    // World-to-camera transform
    Eigen::Matrix3d R_cw = pose.q.toRotationMatrix().transpose();
    Eigen::Vector3d t_cw = -R_cw * pose.t;

    for (const auto& pt : cloud)
    {
        Eigen::Vector3d pw(pt.x, pt.y, pt.z);
        Eigen::Vector3d pc = R_cw * pw + t_cw;

        if (pc.z() <= 0.0) continue;  // behind camera

        double u = fx * pc.x() / pc.z() + cx;
        double v = fy * pc.y() / pc.z() + cy;

        int iu = static_cast<int>(std::round(u));
        int iv = static_cast<int>(std::round(v));

        if (iu < 0 || iu >= width || iv < 0 || iv >= height) continue;

        float d = static_cast<float>(pc.z());

        // Z-buffer: keep nearest depth at each pixel
        float& existing = depth.at<float>(iv, iu);
        if (existing <= 0.f || d < existing)
        {
            existing = d;
        }
    }

    return depth;
}

// ---------------------------------------------------------------------------
// computeStereoDepth — SGM stereo matching → metric depth
// ---------------------------------------------------------------------------
cv::Mat DepthFusion::computeStereoDepth(const cv::Mat& left, const cv::Mat& right,
                                         double baseline, double fx) const
{
    if (left.empty() || right.empty()) return cv::Mat();

    cv::Mat left_gray, right_gray;
    if (left.channels() == 3)
        cv::cvtColor(left, left_gray, cv::COLOR_BGR2GRAY);
    else
        left_gray = left.clone();
    if (right.channels() == 3)
        cv::cvtColor(right, right_gray, cv::COLOR_BGR2GRAY);
    else
        right_gray = right.clone();

    // Semi-Global Block Matching
    cv::Ptr<cv::StereoSGBM> sgbm = cv::StereoSGBM::create(
        0,                              // minDisparity
        cfg_.sgm_num_disparities,       // numDisparities
        cfg_.sgm_block_size,            // blockSize
        cfg_.sgm_p1,                    // P1
        cfg_.sgm_p2,                    // P2
        1,                              // disp12MaxDiff
        10,                             // preFilterCap
        5,                              // uniquenessRatio
        50,                             // speckleWindowSize
        2,                              // speckleRange
        cv::StereoSGBM::MODE_SGBM_3WAY
    );

    cv::Mat disparity;
    sgbm->compute(left_gray, right_gray, disparity);

    // disparity is CV_16S, scale = 16
    cv::Mat disparity_f;
    disparity.convertTo(disparity_f, CV_32F, 1.0 / 16.0);

    // depth = baseline * fx / disparity
    cv::Mat depth = cv::Mat::zeros(disparity_f.size(), CV_32F);
    for (int y = 0; y < disparity_f.rows; ++y)
    {
        const float* dptr = disparity_f.ptr<float>(y);
        float* zptr = depth.ptr<float>(y);
        for (int x = 0; x < disparity_f.cols; ++x)
        {
            if (dptr[x] > 0.1f)
            {
                zptr[x] = static_cast<float>(baseline * fx / dptr[x]);
            }
        }
    }

    return depth;
}

// ---------------------------------------------------------------------------
// fuse — confidence-weighted multi-source depth fusion
// ---------------------------------------------------------------------------
cv::Mat DepthFusion::fuse(const cv::Mat& lidar_depth,
                           const cv::Mat& itof_depth,
                           const cv::Mat& stereo_depth) const
{
    // Determine output size from the first available input
    int h = 0, w = 0;
    if (!lidar_depth.empty())  { h = lidar_depth.rows;  w = lidar_depth.cols; }
    else if (!itof_depth.empty())   { h = itof_depth.rows;   w = itof_depth.cols; }
    else if (!stereo_depth.empty()) { h = stereo_depth.rows; w = stereo_depth.cols; }
    else return cv::Mat();

    cv::Mat fused = cv::Mat::zeros(h, w, CV_32F);
    cv::Mat confidence_sum = cv::Mat::zeros(h, w, CV_32F);
    cv::Mat weighted_depth = cv::Mat::zeros(h, w, CV_32F);

    // Helper lambda: accumulate a depth source with its confidence
    auto accumulate = [&](const cv::Mat& depth, double conf_value)
    {
        if (depth.empty() || conf_value <= 0.0) return;
        for (int y = 0; y < h; ++y)
        {
            const float* dptr = depth.ptr<float>(y);
            float* cptr = confidence_sum.ptr<float>(y);
            float* wptr = weighted_depth.ptr<float>(y);
            for (int x = 0; x < w; ++x)
            {
                float d = dptr[x];
                if (d > 0.f)
                {
                    cptr[x] += static_cast<float>(conf_value);
                    wptr[x] += static_cast<float>(conf_value) * d;
                }
            }
        }
    };

    // Accumulate in priority order (LiDAR highest confidence)
    accumulate(lidar_depth,  cfg_.lidar_confidence);
    accumulate(itof_depth,   cfg_.itof_confidence);
    accumulate(stereo_depth, cfg_.stereo_confidence);

    // Normalise: fused = weighted_depth / confidence_sum
    for (int y = 0; y < h; ++y)
    {
        const float* cptr = confidence_sum.ptr<float>(y);
        const float* wptr = weighted_depth.ptr<float>(y);
        float* fptr = fused.ptr<float>(y);
        for (int x = 0; x < w; ++x)
        {
            if (cptr[x] > 0.f)
            {
                fptr[x] = wptr[x] / cptr[x];
            }
        }
    }

    // Enforce LiDAR as ground truth: overwrite fused with LiDAR where available
    if (!lidar_depth.empty())
    {
        for (int y = 0; y < h; ++y)
        {
            const float* lptr = lidar_depth.ptr<float>(y);
            float* fptr = fused.ptr<float>(y);
            for (int x = 0; x < w; ++x)
            {
                if (lptr[x] > 0.f) fptr[x] = lptr[x];
            }
        }
    }

    return fused;
}

// ---------------------------------------------------------------------------
// computeConfidence — estimate per-pixel confidence for a depth source
// ---------------------------------------------------------------------------
cv::Mat DepthFusion::computeConfidence(const cv::Mat& depth, DepthSource source)
{
    if (depth.empty()) return cv::Mat();

    int h = depth.rows, w = depth.cols;
    cv::Mat conf = cv::Mat::ones(h, w, CV_32F);

    switch (source)
    {
    case DepthSource::LiDAR:
        // Binary: 1.0 where depth exists, 0 elsewhere
        conf = cv::Mat::zeros(h, w, CV_32F);
        for (int y = 0; y < h; ++y)
        {
            const float* dptr = depth.ptr<float>(y);
            float* cptr = conf.ptr<float>(y);
            for (int x = 0; x < w; ++x)
                cptr[x] = (dptr[x] > 0.f) ? 1.0f : 0.0f;
        }
        break;

    case DepthSource::IToF:
    {
        // Edge-based confidence: lower near depth discontinuities
        cv::Mat grad_x, grad_y;
        cv::Sobel(depth, grad_x, CV_32F, 1, 0, 3);
        cv::Sobel(depth, grad_y, CV_32F, 0, 1, 3);
        cv::Mat grad_mag;
        cv::magnitude(grad_x, grad_y, grad_mag);

        double max_grad;
        cv::minMaxLoc(grad_mag, nullptr, &max_grad);
        if (max_grad > 0)
            conf = 1.0f - (grad_mag / static_cast<float>(max_grad));
        break;
    }

    case DepthSource::Stereo:
    {
        // Texture-based confidence (approximate via local variance)
        cv::Mat mean, sq, var;
        cv::boxFilter(depth, mean, CV_32F, cv::Size(9, 9));
        cv::boxFilter(depth.mul(depth), sq, CV_32F, cv::Size(9, 9));
        var = sq - mean.mul(mean);
        double max_var;
        cv::minMaxLoc(var, nullptr, &max_var);
        if (max_var > 0)
            conf = var / static_cast<float>(max_var);
        break;
    }

    default:
        break;
    }

    return conf;
}

}  // namespace winlic
