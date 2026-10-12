/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * Core data types — replaces ROS sensor_msgs / geometry_msgs with plain structs.
 * This file is ROS-free and portable to Windows (MSVC) and Linux (GCC).
 */

#pragma once

#include <Eigen/Eigen>
#include <opencv2/core.hpp>
#include <cstdint>
#include <string>
#include <vector>

namespace winlic {

/// A single LiDAR point with colour (world or sensor frame, depending on context).
struct PointXYZRGB
{
    float x = 0.f;
    float y = 0.f;
    float z = 0.f;
    uint8_t r = 0;
    uint8_t g = 0;
    uint8_t b = 0;
};

/// IMU measurement (accelerometer + gyroscope) at a single timestamp.
struct ImuMeasurement
{
    double timestamp = 0.0;          ///< seconds
    Eigen::Vector3d accel = Eigen::Vector3d::Zero();   ///< m/s^2
    Eigen::Vector3d gyro = Eigen::Vector3d::Zero();    ///< rad/s
};

/// Camera pose parameterised as quaternion + translation (world-to-camera or camera-to-world).
struct CameraPose
{
    double timestamp = 0.0;
    Eigen::Quaterniond q = Eigen::Quaterniond::Identity();
    Eigen::Vector3d t = Eigen::Vector3d::Zero();

    Eigen::Matrix3d R() const { return q.toRotationMatrix(); }
};

/// Depth source identifier for multi-modal fusion.
enum class DepthSource : int
{
    None     = 0,
    LiDAR    = 1,   ///< sparse, projected from point cloud
    IToF     = 2,   ///< dense, from iToF sensor
    Stereo   = 3,   ///< dense, from SGM stereo matching
    Fused    = 4,   ///< confidence-weighted combination
    Completed = 5   ///< SPNet / depth-completer output
};

/// A single frame of aligned multi-modal data.
/// Unlike the ROS version (which stored sensor_msgs pointers), this holds
/// concrete cv::Mat / vectors so it is self-contained after reading.
struct AlignedFrame
{
    double timestamp = 0.0;

    // -- RGB image (BGR8, 0-255) --
    cv::Mat image;

    // -- Depth maps (metric, float32, metres) --
    cv::Mat lidar_depth;     ///< sparse, from LiDAR projection
    cv::Mat itof_depth;      ///< dense, from iToF (may be empty)
    cv::Mat stereo_depth;    ///< dense, from stereo SGM (may be empty)
    cv::Mat fused_depth;     ///< confidence-weighted fusion (may be empty)
    cv::Mat final_depth;     ///< after depth completion (or fused if no completion)

    // -- LiDAR point cloud (sensor frame, uncoloured or coloured) --
    std::vector<PointXYZRGB> pointcloud;
    std::vector<float> pointdepth;   ///< per-point depth in camera frame

    // -- Camera pose (camera-to-world) --
    CameraPose pose;

    // -- Metadata --
    int frame_index = -1;
    bool is_keyframe = false;
};

/// Configuration for the depth-fusion stage.
struct DepthFusionConfig
{
    bool enable_itof = true;
    bool enable_stereo = false;
    double stereo_baseline = 0.12;       ///< metres
    int sgm_p1 = 200;                     ///< SGM smoothness penalty 1
    int sgm_p2 = 800;                     ///< SGM smoothness penalty 2
    int sgm_num_disparities = 128;
    int sgm_block_size = 9;
    double confidence_threshold = 0.5;
    double lidar_confidence = 1.0;        ///< LiDAR depth is treated as ground truth
    double itof_confidence = 0.6;
    double stereo_confidence = 0.5;
};

}  // namespace winlic
