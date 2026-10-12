/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * Parameters — YAML-driven configuration, no ros::package dependency.
 * Replaces the Params class from src/mapping.h.
 */

#pragma once

#include <yaml-cpp/yaml.h>
#include <string>
#include "types.h"

namespace winlic {

class Params
{
public:
    Params() = default;

    /// Construct from a YAML config node.
    /// The node must contain the top-level keys: camera, gaussian, and
    /// optionally dataset and depth_fusion sections.
    explicit Params(const YAML::Node& node)
    {
        // ---- Camera intrinsics ----
        const auto& cam = node["camera"];
        height = cam["height"].as<int>();
        width  = cam["width"].as<int>();
        fx = cam["fx"].as<double>();
        fy = cam["fy"].as<double>();
        cx = cam["cx"].as<double>();
        cy = cam["cy"].as<double>();

        // ---- Frame selection / depth completion ----
        select_every_k_frame = node["select_every_k_frame"].as<int>();
        depth_completion     = node["depth_completion"].as<bool>();
        patch_size           = node["patch_size"].as<int>();
        max_depth            = node["max_depth"].as<double>();

        // ---- SPNet engine path (depth completer) ----
        // On the original ROS build this used ros::package::getPath().
        // Here we read the path directly from YAML or derive from base_path.
        if (node["engine_path"])
        {
            engine_path = node["engine_path"].as<std::string>();
        }
        else if (node["base_path"])
        {
            std::string base = node["base_path"].as<std::string>();
            if (height == 512 && width == 640)
                engine_path = base + "/ckpt/spnet_512_640.engine";
            else if (height == 480 && width == 640)
                engine_path = base + "/ckpt/spnet_480_640.engine";
        }

        // ---- Gaussian model parameters ----
        sh_degree             = node["sh_degree"].as<int>();
        white_background      = node["white_background"].as<bool>();
        random_background     = node["random_background"].as<bool>();
        convert_SHs_python    = node["convert_SHs_python"].as<bool>();
        compute_cov3D_python  = node["compute_cov3D_python"].as<bool>();
        lambda_erank          = node["lambda_erank"].as<double>();
        scaling_scale         = node["scaling_scale"].as<double>();

        position_lr  = node["position_lr"].as<double>();
        feature_lr   = node["feature_lr"].as<double>();
        opacity_lr   = node["opacity_lr"].as<double>();
        scaling_lr   = node["scaling_lr"].as<double>();
        rotation_lr  = node["rotation_lr"].as<double>();
        lambda_dssim = node["lambda_dssim"].as<double>();
        optimize_depth  = node["optimize_depth"].as<bool>();
        lambda_depth    = node["lambda_depth"].as<double>();
        iteration_decay = node["iteration_decay"].as<bool>();

        apply_exposure  = node["apply_exposure"].as<bool>();
        exposure_lr     = node["exposure_lr"].as<double>();
        skybox_points_num = node["skybox_points_num"].as<int>();
        skybox_radius     = node["skybox_radius"].as<int>();

        // ---- Memory safety cap (0 = unlimited) ----
        max_gaussians = node["max_gaussians"] ? node["max_gaussians"].as<int>() : 0;

        // ---- Depth fusion config ----
        if (node["depth_fusion"])
        {
            const auto& df = node["depth_fusion"];
            depth_fusion_cfg.enable_itof           = df["enable_itof"].as<bool>();
            depth_fusion_cfg.enable_stereo         = df["enable_stereo"].as<bool>();
            depth_fusion_cfg.stereo_baseline       = df["stereo_baseline"].as<double>();
            depth_fusion_cfg.confidence_threshold  = df["confidence_threshold"].as<double>();
        }
    }

    // ---- Dataset / camera ----
    int    height{};
    int    width{};
    double fx{};
    double fy{};
    double cx{};
    double cy{};

    int    select_every_k_frame{};
    bool   depth_completion{};
    int    patch_size{};
    double max_depth{};
    std::string engine_path;

    // ---- Gaussian model ----
    int    sh_degree{};
    bool   white_background{};
    bool   random_background{};
    bool   convert_SHs_python{};
    bool   compute_cov3D_python{};
    double lambda_erank{};
    double scaling_scale{};

    double position_lr{};
    double feature_lr{};
    double opacity_lr{};
    double scaling_lr{};
    double rotation_lr{};
    double lambda_dssim{};
    bool   optimize_depth{};
    double lambda_depth{};
    bool   iteration_decay{};

    bool   apply_exposure{};
    double exposure_lr{};
    int    skybox_points_num{};
    int    skybox_radius{};
    int    max_gaussians{};

    // ---- Depth fusion ----
    DepthFusionConfig depth_fusion_cfg;
};

}  // namespace winlic
