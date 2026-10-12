/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * Renderer — adapted from src/rasterizer/renderer.h.
 * Includes fixed for win_lic directory layout; render() moved to winlic::
 * namespace to match the ported GaussianModel.
 *
 * Note: We use a forward declaration of GaussianModel instead of including
 * gaussian_model.h to avoid a circular include (gaussian_model.h → renderer.h
 * → gaussian_model.h). Camera is included directly because it has no
 * dependency on GaussianModel.
 */

#pragma once

#include <tuple>
#include <torch/torch.h>

#include "gaussians/camera.h"
#include "rasterizer.h"

namespace winlic {

class GaussianModel;  // forward declaration

std::tuple<torch::Tensor, torch::Tensor, torch::Tensor, torch::Tensor, torch::Tensor, torch::Tensor>
render(const std::shared_ptr<Camera>& viewpoint_camera,
       std::shared_ptr<GaussianModel> pc,
       torch::Tensor& bg_color,
       bool use_trained_exposure = false,
       bool no_color = false,
       float scaling_modifier = 1.0);

}  // namespace winlic
