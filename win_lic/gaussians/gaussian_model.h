/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * GaussianModel + Dataset — ported from src/gaussian.h and src/gaussian.cpp.
 * All ROS dependencies (tf, cv_bridge, pcl_conversions, sensor_msgs) removed.
 * Core algorithm (initialize, extend, optimize, densificationPostfix, saveMap,
 * evaluateVisualQuality) is preserved verbatim from the original.
 */

#pragma once

#include <memory>
#include <string>
#include <filesystem>
#include <fstream>
#include <algorithm>
#include <cmath>
#include <unordered_map>
#include <chrono>

#include <torch/torch.h>
#include <c10/cuda/CUDACachingAllocator.h>

#include <opencv2/core.hpp>
#include <opencv2/opencv.hpp>

#include "core/types.h"
#include "core/params.h"
#include "gaussians/camera.h"
#include "utils/eigen_utils.h"
#include "utils/general_utils.h"
#include "utils/optim_utils.h"
#include "utils/tensor_utils.h"
#include "utils/tinyply.h"

#include "cuda/simple-knn/spatial.h"
#include "cuda/rasterizer/renderer.h"

#include "depth/depth_completer.h"

namespace winlic {

const double C0 = 0.28209479177387814;
inline double RGB2SH(double color) { return (color - 0.5) / C0; }
inline torch::Tensor RGB2SH(torch::Tensor& rgb) { return (rgb - 0.5f) / C0; }

// ---------------------------------------------------------------------------
// Dataset — accumulates frames and manages train/test camera sets.
// Replaces the ROS-based Dataset class from src/gaussian.h.
// ---------------------------------------------------------------------------
class Dataset
{
public:
    Dataset(const Params& prm)
      : fx_(prm.fx), fy_(prm.fy), cx_(prm.cx), cy_(prm.cy),
        select_every_k_frame_(prm.select_every_k_frame),
        depth_completion_(prm.depth_completion),
        patch_size_(prm.patch_size), max_depth_(prm.max_depth),
        all_frame_num_(0), is_keyframe_current_(false),
        depth_completer_(prm.engine_path, prm.width, prm.height) {}

    /// Add a frame from the offline pipeline.
    /// @param image      BGR8 image (0-255), will be converted to RGB float.
    /// @param depth_map  Metric depth map (CV_32FC1, metres).
    /// @param q_wc       Camera-to-world rotation quaternion.
    /// @param t_wc       Camera-to-world translation.
    /// @param cloud      LiDAR point cloud (world frame) with colour.
    void addFrame(const cv::Mat& image,
                  const cv::Mat& depth_map,
                  const Eigen::Quaterniond& q_wc,
                  const Eigen::Vector3d& t_wc,
                  const std::vector<PointXYZRGB>& cloud);

public:
    double fx_;
    double fy_;
    double cx_;
    double cy_;

    int select_every_k_frame_;
    bool depth_completion_;
    int patch_size_;
    double max_depth_;

    int all_frame_num_;
    bool is_keyframe_current_;

    Eigen::aligned_vector<Eigen::Matrix3d> R_wc_;
    Eigen::aligned_vector<Eigen::Vector3d> t_wc_;

    Eigen::aligned_vector<Eigen::Vector3d> pointcloud_;
    Eigen::aligned_vector<Eigen::Vector3d> pointcolor_;
    std::vector<float> pointdepth_;

    std::vector<std::shared_ptr<Camera>> train_cameras_;
    std::vector<std::shared_ptr<Camera>> test_cameras_;

    ::DepthCompleter depth_completer_;  ///< SPNet TensorRT depth completion
};

// ---------------------------------------------------------------------------
// GaussianModel — 3D Gaussian Splatting map representation.
// Ported from src/gaussian.h, identical algorithm.
// ---------------------------------------------------------------------------
#define GAUSSIAN_MODEL_TENSORS_TO_VEC                        \
    this->Tensor_vec_xyz_ = {this->xyz_};                    \
    this->Tensor_vec_feature_dc_ = {this->features_dc_};     \
    this->Tensor_vec_feature_rest_ = {this->features_rest_}; \
    this->Tensor_vec_opacity_ = {this->opacity_};            \
    this->Tensor_vec_scaling_ = {this->scaling_};            \
    this->Tensor_vec_rotation_ = {this->rotation_};          \
    this->Tensor_vec_exposure_ = {this->exposure_};

#define GAUSSIAN_MODEL_INIT_TENSORS(device_type)                                             \
    this->xyz_ = torch::empty(0, torch::TensorOptions().device(device_type));                \
    this->features_dc_ = torch::empty(0, torch::TensorOptions().device(device_type));        \
    this->features_rest_ = torch::empty(0, torch::TensorOptions().device(device_type));      \
    this->scaling_ = torch::empty(0, torch::TensorOptions().device(device_type));            \
    this->rotation_ = torch::empty(0, torch::TensorOptions().device(device_type));           \
    this->opacity_ = torch::empty(0, torch::TensorOptions().device(device_type));            \
    this->exposure_ = torch::empty(0, torch::TensorOptions().device(device_type));           \
    GAUSSIAN_MODEL_TENSORS_TO_VEC

class GaussianModel
{
public:
    explicit GaussianModel(const Params& prm);

    torch::Tensor getScaling();
    torch::Tensor getRotation();
    torch::Tensor getXYZ();
    torch::Tensor getFeaturesDc();
    torch::Tensor getFeaturesRest();
    torch::Tensor getOpacity();
    torch::Tensor getCovariance(int scaling_modifier);
    torch::Tensor getExposure();

    void initialize(const std::shared_ptr<Dataset>& dataset);
    void saveMap(const std::string& result_path);
    void trainingSetup();

    void densificationPostfix(
        torch::Tensor& new_xyz,
        torch::Tensor& new_features_dc,
        torch::Tensor& new_features_rest,
        torch::Tensor& new_opacities,
        torch::Tensor& new_scaling,
        torch::Tensor& new_rotation);

public:
    int sh_degree_;
    bool white_background_;
    bool random_background_;
    bool convert_SHs_python_;
    bool compute_cov3D_python_;
    float lambda_erank_;
    double scaling_scale_;

    double position_lr_;
    double feature_lr_;
    double opacity_lr_;
    double scaling_lr_;
    double rotation_lr_;
    double lambda_dssim_;
    bool optimize_depth_;
    double lambda_depth_;
    bool iteration_decay_;

    bool apply_exposure_;
    double exposure_lr_;
    int skybox_points_num_;
    int skybox_radius_;
    int max_gaussians_;

    torch::Tensor xyz_;
    torch::Tensor features_dc_;
    torch::Tensor features_rest_;
    torch::Tensor scaling_;
    torch::Tensor rotation_;
    torch::Tensor opacity_;
    torch::Tensor exposure_;

    std::vector<torch::Tensor> Tensor_vec_xyz_,
                               Tensor_vec_feature_dc_,
                               Tensor_vec_feature_rest_,
                               Tensor_vec_opacity_,
                               Tensor_vec_scaling_,
                               Tensor_vec_rotation_,
                               Tensor_vec_exposure_;

    std::shared_ptr<SparseGaussianAdam> optimizer_;
    std::shared_ptr<torch::optim::Adam> exposure_optimizer_;
    bool is_init_;

    torch::Tensor bg_;

    std::chrono::steady_clock::time_point t_start_, t_end_;
    double t_forward_;
    double t_backward_;
    double t_step_;
    double t_optlist_;
    double t_tocuda_;
};

// ---- Map operations (ported from src/gaussian.cpp) ----
void extend(const std::shared_ptr<Dataset>& dataset, std::shared_ptr<GaussianModel>& pc);
double optimize(const std::shared_ptr<Dataset>& dataset, std::shared_ptr<GaussianModel>& pc);
void evaluateVisualQuality(const std::shared_ptr<Dataset>& dataset,
                           std::shared_ptr<GaussianModel>& pc,
                           const std::string& result_path,
                           const std::string& lpips_path);

}  // namespace winlic
