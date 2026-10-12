/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * Renderer implementation — adapted from src/rasterizer/renderer.cpp.
 * Wrapped in winlic:: namespace.
 */

#include "renderer.h"
#include "gaussians/gaussian_model.h"

namespace winlic {

std::tuple<torch::Tensor, torch::Tensor, torch::Tensor, torch::Tensor, torch::Tensor, torch::Tensor>
render(const std::shared_ptr<Camera>& viewpoint_camera,
       std::shared_ptr<GaussianModel> pc,
       torch::Tensor& bg_color,
       bool use_trained_exposure,
       bool no_color,
       float scaling_modifier)
{
    auto screenspace_points = torch::zeros_like(pc->getXYZ(), torch::TensorOptions().dtype(pc->getXYZ().dtype()).requires_grad(true).device(torch::kCUDA));

    float tanfovx = std::tan(viewpoint_camera->FoVx_ * 0.5f);
    float tanfovy = std::tan(viewpoint_camera->FoVy_ * 0.5f);
    bool prefiltered = false;
    bool debug = false;
    GaussianRasterizationSettings raster_settings(
        viewpoint_camera->image_height_,
        viewpoint_camera->image_width_,
        tanfovx,
        tanfovy,
        viewpoint_camera->limx_neg_,
        viewpoint_camera->limx_pos_,
        viewpoint_camera->limy_neg_,
        viewpoint_camera->limy_pos_,
        bg_color,
        scaling_modifier,
        viewpoint_camera->world_view_transform_,
        viewpoint_camera->full_proj_transform_,
        pc->sh_degree_,
        viewpoint_camera->camera_center_,
        prefiltered,
        debug,
        no_color,
        pc->lambda_erank_
    );
    GaussianRasterizer rasterizer(raster_settings);

    auto means3D = pc->getXYZ();
    auto means2D = screenspace_points;
    auto opacity = pc->getOpacity();
    auto scales = pc->getScaling();
    auto rotations = pc->getRotation();
    torch::Tensor dc = pc->getFeaturesDc();
    torch::Tensor shs = pc->getFeaturesRest();
    torch::Tensor colors_precomp;
    torch::Tensor cov3D_precomp;

    auto rasterizer_result = rasterizer.forward(
                                    means3D,
                                    means2D,
                                    opacity,
                                    dc,
                                    shs,
                                    colors_precomp,
                                    scales,
                                    rotations,
                                    cov3D_precomp);
    auto rendered_image = std::get<0>(rasterizer_result);
    auto radii = std::get<1>(rasterizer_result);
    auto rendered_depth = std::get<2>(rasterizer_result);
    auto rendered_final_T = std::get<3>(rasterizer_result);

    return std::make_tuple(
        rendered_image,
        rendered_depth,
        rendered_final_T,
        screenspace_points,
        radii > 0,
        radii
    );
}

}  // namespace winlic
