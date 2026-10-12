/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * Orbbec SDK sensor source — live multi-modal data from Orbbec 3D cameras
 * (Femto Mega, Gemini 2, etc.) that provide LiDAR point clouds, iToF depth,
 * stereo RGB, and IMU streams.
 *
 * This file is compiled in two modes:
 *   1. USE_ORBBEC_SDK defined → links against OrbbecSDK v2 and reads live data.
 *   2. USE_ORBBEC_SDK undefined → stub that prints an error at runtime.
 *
 * To enable: define USE_ORBBEC_SDK and set OrbbecSDK_DIR in CMake.
 */

#pragma once

#include "isensor_source.h"
#include <string>

namespace winlic {

class OrbbecSource : public ISensorSource
{
public:
    OrbbecSource() = default;
    ~OrbbecSource() override = default;

    bool open(const YAML::Node& config) override;
    bool hasNext() override;
    AlignedFrame nextFrame() override;
    void close() override;
    std::string name() const override { return "OrbbecSource"; }

private:
#ifndef USE_ORBBEC_SDK
    bool opened_ = false;
#else
    // --- Orbbec SDK handles (populated when SDK is available) ---
    void* device_ = nullptr;        // ob_device*
    void* pipeline_ = nullptr;      // ob_pipeline*
    void* config_ = nullptr;        // ob_config*
    bool  streaming_ = false;
    int   frame_counter_ = 0;
#endif

    // Common config
    int width_ = 640;
    int height_ = 512;
    double fx_ = 0, fy_ = 0, cx_ = 0, cy_ = 0;
    std::string serial_number_;     ///< empty = first available device
};

}  // namespace winlic
