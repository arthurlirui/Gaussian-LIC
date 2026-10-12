/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * Pipeline — orchestrates the full offline reconstruction process.
 * Replaces the ROS spin loop from src/mapping.cpp with a sequential
 * offline processing loop driven by ISensorSource.
 */

#pragma once

#include "core/params.h"
#include "sensors/isensor_source.h"
#include "depth/depth_fusion.h"
#include "gaussians/gaussian_model.h"

#include <memory>
#include <string>

namespace winlic {

class Pipeline
{
public:
    Pipeline(const Params& params,
             const std::string& result_path,
             const std::string& lpips_path);

    /// Run the full reconstruction pipeline.
    /// @param source  Sensor data source (already opened) — offline reader or live camera.
    void run(ISensorSource& source);

private:
    /// Process a single aligned frame: fuse depth, add to dataset, extend/optimize map.
    void processFrame(AlignedFrame& frame);

    /// Final evaluation and map export.
    void finalize();

    Params params_;
    std::string result_path_;
    std::string lpips_path_;

    std::shared_ptr<GaussianModel> gaussians_;
    std::shared_ptr<Dataset> dataset_;
    std::unique_ptr<DepthFusion> depth_fusion_;

    double total_mapping_time_ = 0;
    double total_adding_time_ = 0;
    double total_extending_time_ = 0;
};

}  // namespace winlic
