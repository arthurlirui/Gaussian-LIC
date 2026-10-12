/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * Offline dataset reader — reads pre-recorded multi-modal data from disk.
 *
 * Expected directory layout (configurable via YAML):
 *   base_path/
 *     images/         — RGB frames (000000.jpg, 000001.jpg, ...)
 *     depth/          — depth maps (000000.png [16-bit mm] or .exr [float metres])
 *     pointclouds/    — LiDAR PLY files (000000.ply, 000001.ply, ...)
 *     trajectory.txt  — camera poses in TUM format:
 *                         timestamp tx ty tz qx qy qz qw
 *     imu.csv         — (optional) IMU data: timestamp,ax,ay,az,gx,gy,gz
 *
 * Pose formats supported: TUM, KITTI, EuRoC.
 */

#pragma once

#include "isensor_source.h"
#include <filesystem>
#include <map>
#include <string>
#include <vector>

namespace winlic {

class DatasetReader : public ISensorSource
{
public:
    DatasetReader() = default;
    ~DatasetReader() override = default;

    bool open(const YAML::Node& config) override;
    bool hasNext() override;
    AlignedFrame nextFrame() override;
    void close() override;
    std::string name() const override { return "DatasetReader"; }

private:
    // ---- Config ----
    std::filesystem::path base_path_;
    std::string image_dir_      = "images";
    std::string depth_dir_      = "depth";
    std::string cloud_dir_      = "pointclouds";
    std::string pose_file_      = "trajectory.txt";
    std::string imu_file_       = "imu.csv";
    std::string pose_format_    = "tum";   // tum | kitti | euroc
    int width_  = 640;
    int height_ = 512;
    double fx_ = 0, fy_ = 0, cx_ = 0, cy_ = 0;

    // ---- Internal state ----
    struct PoseEntry
    {
        double timestamp;
        Eigen::Vector3d t;
        Eigen::Quaterniond q;
    };
    std::vector<PoseEntry> poses_;
    std::vector<std::string> image_files_;
    std::vector<std::string> depth_files_;
    std::vector<std::string> cloud_files_;
    size_t current_idx_ = 0;

    // ---- Helpers ----
    bool loadPoses();
    bool scanDirectory(const std::filesystem::path& dir,
                       const std::string& extension,
                       std::vector<std::string>& out_files);
    cv::Mat loadDepth(const std::string& path) const;
    std::vector<PointXYZRGB> loadPly(const std::string& path) const;
    AlignedFrame buildFrame(size_t idx);
};

}  // namespace winlic
