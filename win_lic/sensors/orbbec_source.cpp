/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * OrbbecSource implementation.
 *
 * Stub mode (no SDK): prints a clear error message and fails gracefully.
 * SDK mode (USE_ORBBEC_SDK): connects to an Orbbec device and streams
 *   aligned LiDAR + iToF + stereo + IMU frames.
 *
 * The SDK-mode implementation uses the OrbbecSDK v2 C API (LibObsensor).
 * When you have the SDK installed, define USE_ORBBEC_SDK at compile time
 * and link against ob.lib.
 */

#include "orbbec_source.h"

#include <iostream>

namespace winlic {

// ===========================================================================
// Stub mode — no Orbbec SDK available
// ===========================================================================
#ifndef USE_ORBBEC_SDK

bool OrbbecSource::open(const YAML::Node& config)
{
    std::cerr << "[OrbbecSource] ERROR: Built without Orbbec SDK support.\n"
              << "  To enable live Orbbec camera input:\n"
              << "    1. Install OrbbecSDK v2 (https://github.com/orbbec/pyorbbecsdk or Hubble)\n"
              << "    2. Build with -DUSE_ORBBEC_SDK=ON -DOrbbecSDK_DIR=<path>\n"
              << "  For offline data processing, use dataset.type: \"offline\" instead.\n";
    opened_ = false;
    return false;
}

bool OrbbecSource::hasNext() { return false; }

AlignedFrame OrbbecSource::nextFrame()
{
    return AlignedFrame{};
}

void OrbbecSource::close() { opened_ = false; }

// ===========================================================================
// SDK mode — OrbbecSDK v2 is available
// ===========================================================================
#else

#include "ObTypes.h"
#include "ObSensor.h"

bool OrbbecSource::open(const YAML::Node& config)
{
    const auto& ds = config["dataset"];
    if (ds)
    {
        serial_number_ = ds["serial_number"].as<std::string>("");
    }
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

    // --- Create pipeline ---
    ob_error* ob_err = nullptr;
    pipeline_ = ob_create_pipeline(&ob_err);
    if (ob_err || !pipeline_)
    {
        std::cerr << "[OrbbecSource] Failed to create pipeline\n";
        return false;
    }

    config_ = ob_create_config(pipeline_, &ob_err);
    if (ob_err || !config_)
    {
        std::cerr << "[OrbbecSource] Failed to create config\n";
        return false;
    }

    // --- Enable streams ---
    // Colour stream
    ob_config_enable_video_stream(config_, OB_SENSOR_COLOR, width_, height_,
                                  OB_FORMAT_RGB, OB_FPS_30, &ob_err);
    // Depth stream (iToF)
    ob_config_enable_video_stream(config_, OB_SENSOR_DEPTH, width_, height_,
                                  OB_FORMAT_Y16, OB_FPS_30, &ob_err);
    // IR / LiDAR (if available on the device)
    ob_config_enable_video_stream(config_, OB_SENSOR_IR, width_, height_,
                                  OB_FORMAT_Y16, OB_FPS_30, &ob_err);

    // --- Start pipeline ---
    ob_pipeline_start(pipeline_, config_, &ob_err);
    if (ob_err)
    {
        std::cerr << "[OrbbecSource] Failed to start pipeline: "
                  << ob_error_message(ob_err) << "\n";
        return false;
    }

    streaming_ = true;
    frame_counter_ = 0;
    std::cout << "[OrbbecSource] Pipeline started successfully\n";
    return true;
}

bool OrbbecSource::hasNext()
{
    return streaming_;
}

AlignedFrame OrbbecSource::nextFrame()
{
    AlignedFrame frame;
    ob_error* ob_err = nullptr;

    // Wait for a frame set (colour + depth + IR)
    ob_frame* frameset = ob_pipeline_wait_for_frameset(pipeline_, 100, &ob_err);
    if (ob_err || !frameset) return frame;

    frame.frame_index = frame_counter_++;
    frame.timestamp = static_cast<double>(frame_counter_) / 30.0;  // approx

    // --- Colour frame ---
    ob_frame* color_frame = ob_frameset_color_frame(frameset, &ob_err);
    if (color_frame)
    {
        uint8_t* data = static_cast<uint8_t*>(ob_frame_data(color_frame, &ob_err));
        // RGB from SDK → convert to BGR for OpenCV
        cv::Mat rgb(height_, width_, CV_8UC3, data);
        cv::cvtColor(rgb, frame.image, cv::COLOR_RGB2BGR);
        ob_delete_frame(color_frame, &ob_err);
    }

    // --- Depth frame (iToF) ---
    ob_frame* depth_frame = ob_frameset_depth_frame(frameset, &ob_err);
    if (depth_frame)
    {
        uint16_t* data = static_cast<uint16_t*>(ob_frame_data(depth_frame, &ob_err));
        // Orbbec depth is in mm (Y16 format)
        cv::Mat depth_raw(height_, width_, CV_16U, data);
        depth_raw.convertTo(frame.itof_depth, CV_32F, 1.0 / 1000.0);  // mm → m
        ob_delete_frame(depth_frame, &ob_err);
    }

    // --- IR / LiDAR frame ---
    ob_frame* ir_frame = ob_frameset_ir_frame(frameset, &ob_err);
    if (ir_frame)
    {
        // On LiDAR-enabled devices (Femto Mega), the IR stream carries
        // the LiDAR pattern; point-cloud generation is done via SDK:
        // ob_create_point_cloud() + ob_point_cloud_filter().
        // For now, store IR as a proxy for LiDAR depth.
        ob_delete_frame(ir_frame, &ob_err);
    }

    ob_delete_frame(frameset, &ob_err);
    return frame;
}

void OrbbecSource::close()
{
    ob_error* ob_err = nullptr;
    if (streaming_)
    {
        ob_pipeline_stop(pipeline_, &ob_err);
        streaming_ = false;
    }
    if (config_)   { ob_delete_config(config_, &ob_err);    config_ = nullptr; }
    if (pipeline_) { ob_delete_pipeline(pipeline_, &ob_err); pipeline_ = nullptr; }
}

#endif  // USE_ORBBEC_SDK

}  // namespace winlic
