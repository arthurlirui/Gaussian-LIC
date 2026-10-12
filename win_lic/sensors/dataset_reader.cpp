/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * DatasetReader implementation.
 */

#include "dataset_reader.h"

#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>

#include <algorithm>
#include <fstream>
#include <iostream>
#include <sstream>

namespace fs = std::filesystem;
namespace winlic {

// ---------------------------------------------------------------------------
// open — parse config, load poses, scan directories
// ---------------------------------------------------------------------------
bool DatasetReader::open(const YAML::Node& config)
{
    const auto& ds = config["dataset"];
    if (!ds)
    {
        std::cerr << "[DatasetReader] Missing 'dataset' section in config\n";
        return false;
    }

    base_path_    = ds["base_path"].as<std::string>("");
    image_dir_    = ds["image_dir"].as<std::string>("images");
    depth_dir_    = ds["depth_dir"].as<std::string>("depth");
    cloud_dir_    = ds["cloud_dir"].as<std::string>("pointclouds");
    pose_file_    = ds["pose_file"].as<std::string>("trajectory.txt");
    imu_file_     = ds["imu_file"].as<std::string>("imu.csv");
    pose_format_  = ds["pose_format"].as<std::string>("tum");

    // Camera intrinsics (optional here — used for depth projection)
    if (config["camera"])
    {
        const auto& c = config["camera"];
        width_  = c["width"].as<int>();
        height_ = c["height"].as<int>();
        fx_ = c["fx"].as<double>();
        fy_ = c["fy"].as<double>();
        cx_ = c["cx"].as<double>();
        cy_ = c["cy"].as<double>();
    }

    // Load poses
    if (!loadPoses())
    {
        std::cerr << "[DatasetReader] Failed to load poses from "
                  << (base_path_ / pose_file_).string() << "\n";
        return false;
    }

    // Scan directories for images, depth maps, and point clouds
    fs::path img_dir = base_path_ / image_dir_;
    fs::path dep_dir = base_path_ / depth_dir_;
    fs::path cld_dir = base_path_ / cloud_dir_;

    if (!scanDirectory(img_dir, ".jpg", image_files_) &&
        !scanDirectory(img_dir, ".png", image_files_))
    {
        std::cerr << "[DatasetReader] No images found in " << img_dir.string() << "\n";
        return false;
    }

    scanDirectory(dep_dir, ".png", depth_files_);
    scanDirectory(dep_dir, ".exr", depth_files_);
    scanDirectory(cld_dir, ".ply", cloud_files_);

    // Sort by filename (assumes zero-padded numeric names)
    auto sortByName = [](std::vector<std::string>& v) {
        std::sort(v.begin(), v.end());
    };
    sortByName(image_files_);
    sortByName(depth_files_);
    sortByName(cloud_files_);

    current_idx_ = 0;

    std::cout << "[DatasetReader] Opened: " << base_path_.string() << "\n"
              << "  Images:      " << image_files_.size() << "\n"
              << "  Depth maps:  " << depth_files_.size() << "\n"
              << "  Point clouds:" << cloud_files_.size() << "\n"
              << "  Poses:       " << poses_.size() << "\n";

    return true;
}

// ---------------------------------------------------------------------------
// hasNext / nextFrame
// ---------------------------------------------------------------------------
bool DatasetReader::hasNext()
{
    return current_idx_ < image_files_.size() &&
           current_idx_ < poses_.size();
}

AlignedFrame DatasetReader::nextFrame()
{
    AlignedFrame frame = buildFrame(current_idx_);
    ++current_idx_;
    return frame;
}

void DatasetReader::close()
{
    image_files_.clear();
    depth_files_.clear();
    cloud_files_.clear();
    poses_.clear();
    current_idx_ = 0;
}

// ---------------------------------------------------------------------------
// loadPoses — TUM / KITTI / EuRoC
// ---------------------------------------------------------------------------
bool DatasetReader::loadPoses()
{
    fs::path pose_path = base_path_ / pose_file_;
    std::ifstream fin(pose_path);
    if (!fin.is_open()) return false;

    std::string line;
    while (std::getline(fin, line))
    {
        // Skip comments and empty lines
        if (line.empty() || line[0] == '#') continue;

        std::istringstream iss(line);
        if (pose_format_ == "tum")
        {
            // timestamp tx ty tz qx qy qz qw
            double ts, tx, ty, tz, qx, qy, qz, qw;
            if (!(iss >> ts >> tx >> ty >> tz >> qx >> qy >> qz >> qw)) continue;
            PoseEntry pe;
            pe.timestamp = ts;
            pe.t = Eigen::Vector3d(tx, ty, tz);
            pe.q = Eigen::Quaterniond(qw, qx, qy, qz).normalized();
            poses_.push_back(pe);
        }
        else if (pose_format_ == "kitti")
        {
            // 12 numbers: 3x4 row-major projection [R|t] (no timestamp)
            double R[12];
            for (int i = 0; i < 12; ++i)
            {
                if (!(iss >> R[i])) { R[i] = 0; }
            }
            PoseEntry pe;
            pe.timestamp = static_cast<double>(poses_.size());
            Eigen::Matrix3d Rot;
            Rot << R[0], R[1], R[2],
                   R[4], R[5], R[6],
                   R[8], R[9], R[10];
            pe.q = Eigen::Quaterniond(Rot).normalized();
            pe.t = Eigen::Vector3d(R[3], R[7], R[11]);
            poses_.push_back(pe);
        }
        else if (pose_format_ == "euroc")
        {
            // CSV: timestamp,px,py,pz,qw,qx,qy,qz (skip header)
            std::string token;
            std::vector<double> vals;
            while (std::getline(iss, token, ',')) {
                try { vals.push_back(std::stod(token)); }
                catch (...) { continue; }
            }
            if (vals.size() < 8) continue;
            PoseEntry pe;
            pe.timestamp = vals[0] * 1e-9;  // ns -> s
            pe.t = Eigen::Vector3d(vals[1], vals[2], vals[3]);
            pe.q = Eigen::Quaterniond(vals[4], vals[5], vals[6], vals[7]).normalized();
            poses_.push_back(pe);
        }
    }

    return !poses_.empty();
}

// ---------------------------------------------------------------------------
// scanDirectory — list files with a given extension
// ---------------------------------------------------------------------------
bool DatasetReader::scanDirectory(const fs::path& dir,
                                   const std::string& extension,
                                   std::vector<std::string>& out_files)
{
    if (!fs::exists(dir) || !fs::is_directory(dir)) return false;

    bool found = false;
    for (const auto& entry : fs::directory_iterator(dir))
    {
        if (entry.is_regular_file() && entry.path().extension() == extension)
        {
            out_files.push_back(entry.path().string());
            found = true;
        }
    }
    return found;
}

// ---------------------------------------------------------------------------
// loadDepth — supports .png (16-bit mm) and .exr (float metres)
// ---------------------------------------------------------------------------
cv::Mat DatasetReader::loadDepth(const std::string& path) const
{
    fs::path p(path);
    if (p.extension() == ".exr")
    {
        cv::Mat depth = cv::imread(path, cv::IMREAD_UNCHANGED | cv::IMREAD_ANYDEPTH);
        // EXR stores metric depth as float32
        return depth;
    }
    else
    {
        // PNG 16-bit: depth in millimetres → convert to metres (float32)
        cv::Mat raw = cv::imread(path, cv::IMREAD_UNCHANGED | cv::IMREAD_ANYDEPTH);
        if (raw.empty()) return cv::Mat();
        if (raw.type() == CV_16U)
        {
            cv::Mat depth_f;
            raw.convertTo(depth_f, CV_32F, 1.0 / 1000.0);  // mm → m
            return depth_f;
        }
        return raw;  // already float
    }
}

// ---------------------------------------------------------------------------
// loadPly — minimal PLY reader for XYZRGB point clouds
// ---------------------------------------------------------------------------
std::vector<PointXYZRGB> DatasetReader::loadPly(const std::string& path) const
{
    std::vector<PointXYZRGB> cloud;

    std::ifstream fin(path, std::ios::binary);
    if (!fin.is_open()) return cloud;

    // Parse header
    std::string line;
    int vertex_count = 0;
    bool binary = false;
    bool has_color = false;
    std::vector<std::string> props;

    while (std::getline(fin, line))
    {
        if (line.find("format binary_little_endian") != std::string::npos)
            binary = true;
        if (line.find("element vertex") != std::string::npos)
        {
            std::istringstream iss(line);
            std::string tmp1, tmp2;
            iss >> tmp1 >> tmp2 >> vertex_count;
        }
        if (line.find("property") != std::string::npos && line.find("uchar") != std::string::npos)
        {
            has_color = true;
        }
        if (line == "end_header") break;
    }

    cloud.reserve(vertex_count);

    if (binary)
    {
        for (int i = 0; i < vertex_count; ++i)
        {
            PointXYZRGB pt;
            fin.read(reinterpret_cast<char*>(&pt.x), sizeof(float));
            fin.read(reinterpret_cast<char*>(&pt.y), sizeof(float));
            fin.read(reinterpret_cast<char*>(&pt.z), sizeof(float));
            if (has_color)
            {
                fin.read(reinterpret_cast<char*>(&pt.r), sizeof(uint8_t));
                fin.read(reinterpret_cast<char*>(&pt.g), sizeof(uint8_t));
                fin.read(reinterpret_cast<char*>(&pt.b), sizeof(uint8_t));
            }
            cloud.push_back(pt);
        }
    }
    else
    {
        // ASCII PLY
        for (int i = 0; i < vertex_count; ++i)
        {
            std::getline(fin, line);
            std::istringstream iss(line);
            PointXYZRGB pt;
            iss >> pt.x >> pt.y >> pt.z;
            if (has_color) iss >> pt.r >> pt.g >> pt.b;
            cloud.push_back(pt);
        }
    }

    return cloud;
}

// ---------------------------------------------------------------------------
// buildFrame — assemble an AlignedFrame from the file set at index idx
// ---------------------------------------------------------------------------
AlignedFrame DatasetReader::buildFrame(size_t idx)
{
    AlignedFrame frame;
    frame.frame_index = static_cast<int>(idx);
    frame.timestamp = poses_[idx].timestamp;
    frame.pose.timestamp = poses_[idx].timestamp;
    frame.pose.q = poses_[idx].q;
    frame.pose.t = poses_[idx].t;

    // Load RGB image
    if (idx < image_files_.size())
    {
        frame.image = cv::imread(image_files_[idx], cv::IMREAD_COLOR);  // BGR8
    }

    // Load depth (LiDAR-projected or sensor depth)
    if (idx < depth_files_.size())
    {
        frame.lidar_depth = loadDepth(depth_files_[idx]);
    }

    // Load LiDAR point cloud
    if (idx < cloud_files_.size())
    {
        frame.pointcloud = loadPly(cloud_files_[idx]);
    }

    return frame;
}

}  // namespace winlic
