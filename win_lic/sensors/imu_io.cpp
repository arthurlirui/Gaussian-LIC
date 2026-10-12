/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * ImuReader implementation.
 */

#include "imu_io.h"

#include <fstream>
#include <iostream>
#include <sstream>
#include <algorithm>

namespace winlic {

bool ImuReader::load(const std::string& csv_path)
{
    std::ifstream fin(csv_path);
    if (!fin.is_open())
    {
        std::cerr << "[ImuReader] Cannot open: " << csv_path << "\n";
        return false;
    }

    std::string line;
    // Skip header line if present
    std::getline(fin, line);
    if (line.find("timestamp") != std::string::npos)
    {
        // It's a header, skip it
    }
    else
    {
        // Not a header — process this line
        std::istringstream iss(line);
        std::string token;
        std::vector<double> v;
        while (std::getline(iss, token, ',')) {
            try { v.push_back(std::stod(token)); } catch (...) {}
        }
        if (v.size() >= 7)
        {
            ImuMeasurement m;
            m.timestamp = v[0];
            m.accel = Eigen::Vector3d(v[1], v[2], v[3]);
            m.gyro  = Eigen::Vector3d(v[4], v[5], v[6]);
            data_.push_back(m);
        }
    }

    while (std::getline(fin, line))
    {
        if (line.empty()) continue;
        std::istringstream iss(line);
        std::string token;
        std::vector<double> v;
        while (std::getline(iss, token, ',')) {
            try { v.push_back(std::stod(token)); } catch (...) {}
        }
        if (v.size() >= 7)
        {
            ImuMeasurement m;
            m.timestamp = v[0];
            m.accel = Eigen::Vector3d(v[1], v[2], v[3]);
            m.gyro  = Eigen::Vector3d(v[4], v[5], v[6]);
            data_.push_back(m);
        }
    }

    // Sort by timestamp
    std::sort(data_.begin(), data_.end(),
              [](const ImuMeasurement& a, const ImuMeasurement& b) {
                  return a.timestamp < b.timestamp;
              });

    std::cout << "[ImuReader] Loaded " << data_.size() << " IMU measurements from "
              << csv_path << "\n";
    return !data_.empty();
}

std::vector<ImuMeasurement> ImuReader::getRange(double t_start, double t_end) const
{
    std::vector<ImuMeasurement> result;
    for (const auto& m : data_)
    {
        if (m.timestamp >= t_start && m.timestamp <= t_end)
            result.push_back(m);
    }
    return result;
}

Eigen::Vector3d ImuReader::integrateVelocity(double t_start, double t_end) const
{
    Eigen::Vector3d vel = Eigen::Vector3d::Zero();
    auto range = getRange(t_start, t_end);
    for (size_t i = 1; i < range.size(); ++i)
    {
        double dt = range[i].timestamp - range[i - 1].timestamp;
        if (dt <= 0) continue;
        // Trapezoidal integration: v += 0.5 * (a_{i-1} + a_i) * dt
        vel += 0.5 * (range[i - 1].accel + range[i].accel) * dt;
    }
    return vel;
}

}  // namespace winlic
