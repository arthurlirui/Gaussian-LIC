/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * Pipeline implementation — the offline processing loop.
 */

#include "pipeline.h"

#include <torch/torch.h>
#include <torch/script.h>
#include <c10/cuda/CUDACachingAllocator.h>

#include <iostream>
#include <iomanip>
#include <chrono>

namespace winlic {

Pipeline::Pipeline(const Params& params,
                   const std::string& result_path,
                   const std::string& lpips_path)
    : params_(params),
      result_path_(result_path),
      lpips_path_(lpips_path)
{
    torch::jit::setGraphExecutorOptimize(false);
    gaussians_ = std::make_shared<GaussianModel>(params_);
    dataset_   = std::make_shared<Dataset>(params_);
    depth_fusion_ = std::make_unique<DepthFusion>(params_.depth_fusion_cfg);
}

void Pipeline::run(ISensorSource& source)
{
    std::cout << "\n=== WinLIC Pipeline Started ===\n";
    std::cout << "  Data source: " << source.name() << "\n";

    AlignedFrame frame;
    while (source.hasNext())
    {
        frame = source.nextFrame();
        if (frame.image.empty()) continue;
        processFrame(frame);
    }

    finalize();
    source.close();
    std::cout << "\n=== WinLIC Pipeline Complete ===\n";
}

void Pipeline::processFrame(AlignedFrame& frame)
{
    // -- [1] Multi-modal depth fusion --
    // Project LiDAR into sparse depth if not already provided
    cv::Mat lidar_depth = frame.lidar_depth;
    if (lidar_depth.empty() && !frame.pointcloud.empty())
    {
        lidar_depth = DepthFusion::projectLidarDepth(
            frame.pointcloud, frame.pose,
            params_.fx, params_.fy, params_.cx, params_.cy,
            params_.width, params_.height);
    }

    // Fuse available depth sources
    cv::Mat fused_depth = depth_fusion_->fuse(
        lidar_depth,
        frame.itof_depth,
        frame.stereo_depth);

    // If no fusion happened, use whatever depth we have
    cv::Mat final_depth;
    if (!fused_depth.empty())
        final_depth = fused_depth;
    else if (!lidar_depth.empty())
        final_depth = lidar_depth;
    else if (!frame.itof_depth.empty())
        final_depth = frame.itof_depth;
    else
        final_depth = frame.lidar_depth;  // may be empty — depth completion will handle

    frame.final_depth = final_depth;

    // -- [2] Add frame to dataset (handles depth completion internally) --
    auto t_start = std::chrono::steady_clock::now();
    dataset_->addFrame(frame.image,
                       final_depth,
                       frame.pose.q,
                       frame.pose.t,
                       frame.pointcloud);
    torch::cuda::synchronize();
    auto t_end = std::chrono::steady_clock::now();

    if (dataset_->is_keyframe_current_)
    {
        total_adding_time_ += std::chrono::duration_cast<std::chrono::duration<double>>(t_end - t_start).count();
        std::cout << "     Cur Frame " << dataset_->all_frame_num_ - 1 << ",";
    }
    else
    {
        return;
    }

    // -- [3] Initialize or extend map --
    if (!gaussians_->is_init_)
    {
        gaussians_->is_init_ = true;
        gaussians_->initialize(dataset_);
        gaussians_->trainingSetup();
    }
    else
    {
        t_start = std::chrono::steady_clock::now();
        extend(dataset_, gaussians_);
        torch::cuda::synchronize();
        t_end = std::chrono::steady_clock::now();
        total_extending_time_ += std::chrono::duration_cast<std::chrono::duration<double>>(t_end - t_start).count();
    }

    // -- [4] Optimize map --
    t_start = std::chrono::steady_clock::now();
    double updated_num = optimize(dataset_, gaussians_);
    torch::cuda::synchronize();
    t_end = std::chrono::steady_clock::now();
    total_mapping_time_ += std::chrono::duration_cast<std::chrono::duration<double>>(t_end - t_start).count();
    std::cout << std::fixed << std::setprecision(2)
              << " Update " << updated_num / 10000 << "w GS per Iter" << std::endl;
}

void Pipeline::finalize()
{
    // -- [5] Runtime statistics --
    std::cout << "\n     === Runtime Statistics ===\n";
    std::cout << std::fixed << std::setprecision(2)
              << "        [Total Mapping Time] " << total_mapping_time_ << "s\n"
              << "         1) Forward " << gaussians_->t_forward_ << "s\n"
              << "         2) Backward " << gaussians_->t_backward_ << "s\n"
              << "         3) Step " << gaussians_->t_step_ << "s\n"
              << "         4) CPU2GPU " << gaussians_->t_tocuda_ << "s\n"
              << "        [Total Adding Time] " << total_adding_time_ << "s\n"
              << "        [Total Extending Time] " << total_extending_time_ << "s\n";

    // -- [6] Evaluation and export --
    torch::NoGradGuard no_grad;
    evaluateVisualQuality(dataset_, gaussians_, result_path_, lpips_path_);
    gaussians_->saveMap(result_path_);

    std::cout << "\n  WinLIC Done!\n";
}

}  // namespace winlic
