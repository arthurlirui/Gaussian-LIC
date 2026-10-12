/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * IMU reader — loads IMU data from CSV files and provides basic integration.
 */

#pragma once

#include "core/types.h"
#include <string>
#include <vector>

namespace winlic {

class ImuReader
{
public:
    /// Load IMU data from a CSV file.
    /// Expected format: timestamp,ax,ay,az,gx,gy,gz  (timestamp in seconds)
    bool load(const std::string& csv_path);

    /// Get all IMU measurements between [t_start, t_end].
    std::vector<ImuMeasurement> getRange(double t_start, double t_end) const;

    /// Simple trapezoidal integration of accelerometer to estimate velocity
    /// over a time range (for coarse motion estimation without a full IMU frontend).
    Eigen::Vector3d integrateVelocity(double t_start, double t_end) const;

    bool empty() const { return data_.empty(); }
    size_t size() const { return data_.size(); }

private:
    std::vector<ImuMeasurement> data_;
};

}  // namespace winlic
