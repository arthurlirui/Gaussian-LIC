/*
 * WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework
 * Copyright (C) 2026 arthurlirui
 *
 * GaussianModel + Dataset implementation — ported from src/gaussian.cpp.
 * All ROS dependencies removed. Core algorithm preserved.
 */

#include "gaussian_model.h"
#include "utils/loss_utils.h"

#include <sstream>
#include <iomanip>
#include <random>
#include <algorithm>
#include <iterator>
#include <filesystem>
#include <chrono>
#include <limits>
#include <torch/script.h>
#include <memory>

namespace fs = std::filesystem;
namespace winlic {

struct PixelPosition
{
    int u, v;
};

// ---------------------------------------------------------------------------
// selectFromDepthCompletion — same as original
// ---------------------------------------------------------------------------
static std::vector<PixelPosition> selectFromDepthCompletion(
    const cv::Mat& depth_A, const cv::Mat& depth_B, int patch_size = 20)
{
    CV_Assert(depth_A.size() == depth_B.size());
    CV_Assert(depth_A.type() == depth_B.type());

    int H = depth_A.rows;
    int W = depth_A.cols;
    std::vector<PixelPosition> result;
    result.reserve((H / patch_size) * (W / patch_size));

    for (int i = 0; i < H; i += patch_size)
    {
        for (int j = 0; j < W; j += patch_size)
        {
            int h_end = std::min(i + patch_size, H);
            int w_end = std::min(j + patch_size, W);

            bool has_valid_A = false;
            bool has_valid_B = false;
            float min_val = std::numeric_limits<float>::max();
            PixelPosition min_pos;

            for (int y = i; y < h_end; ++y)
            {
                const float* ptr_A = depth_A.ptr<float>(y);
                const float* ptr_B = depth_B.ptr<float>(y);

                for (int x = j; x < w_end; ++x)
                {
                    if (ptr_A[x] > 0)
                    {
                        has_valid_A = true;
                        y = h_end;
                        break;
                    }
                    if (ptr_B[x] > 0)
                    {
                        has_valid_B = true;
                        if (ptr_B[x] < min_val)
                        {
                            min_val = ptr_B[x];
                            min_pos = {x, y};
                        }
                    }
                }
            }

            if (has_valid_A || !has_valid_B) continue;
            result.push_back(min_pos);
        }
    }
    return result;
}

// ---------------------------------------------------------------------------
// Dataset::addFrame — ROS-free version
// Replaces cv_bridge::toCvCopy, tf::quaternionMsgToEigen, pcl::fromROSMsg
// with direct cv::Mat and Eigen operations.
// ---------------------------------------------------------------------------
void Dataset::addFrame(const cv::Mat& image_bgr,
                       const cv::Mat& depth_map,
                       const Eigen::Quaterniond& q_wc,
                       const Eigen::Vector3d& t_wc,
                       const std::vector<PointXYZRGB>& cloud)
{
    // -- Image: BGR8 (0-255) → RGB float32 (0-1) --
    cv::Mat image_rgb;
    cv::cvtColor(image_bgr, image_rgb, cv::COLOR_BGR2RGB);
    image_rgb.convertTo(image_rgb, CV_32FC3, 1.0f / 255.0f);

    // -- Pose --
    R_wc_.push_back(q_wc.toRotationMatrix());
    t_wc_.push_back(t_wc);

    // -- Point cloud: world frame → compute camera-frame depth --
    Eigen::Matrix3d R_cw = q_wc.toRotationMatrix().transpose();
    Eigen::Vector3d t_cw = -R_cw * t_wc;
    for (const auto& pt : cloud)
    {
        pointcloud_.emplace_back(Eigen::Vector3d(pt.x, pt.y, pt.z));
        pointcolor_.emplace_back(Eigen::Vector3d(pt.r, pt.g, pt.b) / 255.0);
        Eigen::Vector3d pt_c = R_cw * pointcloud_.back() + t_cw;
        assert(pt_c(2) > 0);
        pointdepth_.push_back(static_cast<float>(pt_c(2)));
    }

    // -- Train / test split --
    int width = image_rgb.cols, height = image_rgb.rows;
    if ((all_frame_num_ + 1) % select_every_k_frame_ == 0)
    {
        is_keyframe_current_ = true;
        std::shared_ptr<Camera> cam = std::make_shared<Camera>();

        if (depth_completion_)
        {
            cv::Mat completed_depth = depth_completer_.complete(image_rgb, depth_map);

            cv::Mat mask_known = depth_map > 0;
            cv::Mat completed_depth_known;
            completed_depth.copyTo(completed_depth_known, mask_known);
            cv::Mat depth_difference = completed_depth_known - depth_map;
            double mean_depth_difference = cv::mean(depth_difference, mask_known)[0];

            if (std::abs(mean_depth_difference) < 0.1)
            {
                cv::Mat depth_gradient_x, depth_gradient_y;
                cv::Sobel(completed_depth, depth_gradient_x, CV_32F, 1, 0, 3);
                cv::Sobel(completed_depth, depth_gradient_y, CV_32F, 0, 1, 3);
                cv::Mat depth_edges;
                cv::magnitude(depth_gradient_x, depth_gradient_y, depth_edges);
                double edge_threshold = 0.1;
                cv::Mat mask_not_edges = depth_edges < edge_threshold;
                completed_depth -= mean_depth_difference;
                cv::Mat mask = (completed_depth > 0) & mask_not_edges;
                cv::Mat wanted_depth;
                completed_depth.copyTo(wanted_depth, mask);

                std::vector<PixelPosition> new_positions =
                    selectFromDepthCompletion(depth_map, wanted_depth, patch_size_);
                for (const auto& pt : new_positions)
                {
                    int u = pt.u, v = pt.v;
                    float depth = wanted_depth.at<float>(v, u);
                    assert(depth > 0);
                    if (depth > max_depth_) continue;

                    cv::Vec3f color = image_rgb.at<cv::Vec3f>(v, u);
                    Eigen::Vector3d eigen_color(color[0], color[1], color[2]);

                    Eigen::Vector3d cam_point((u - cx_) * depth / fx_,
                                              (v - cy_) * depth / fy_,
                                              depth);
                    Eigen::Vector3d world_point = q_wc * cam_point + t_wc;

                    pointcloud_.emplace_back(world_point);
                    pointcolor_.emplace_back(eigen_color);
                    pointdepth_.emplace_back(static_cast<float>(depth));
                }
            }
        }

        cam->original_image_ = tensor_utils::cvMat2TorchTensor_Float32(image_rgb, torch::kCPU, true);
        cam->original_depth_ = tensor_utils::cvMat2TorchTensor_Float32(depth_map, torch::kCPU, true);

        std::stringstream ss;
        ss << std::setw(4) << std::setfill('0') << all_frame_num_;
        cam->image_name_ = "train_" + ss.str() + ".jpg";

        cam->setIntrinsic(width, height, fx_, fy_, cx_, cy_);
        cam->setPose(q_wc.toRotationMatrix(), t_wc);
        train_cameras_.emplace_back(cam);
    }
    else
    {
        is_keyframe_current_ = false;
        std::shared_ptr<Camera> cam = std::make_shared<Camera>();

        cam->original_image_ = tensor_utils::cvMat2TorchTensor_Float32(image_rgb, torch::kCPU);
        cam->original_depth_ = tensor_utils::cvMat2TorchTensor_Float32(depth_map, torch::kCPU);

        std::stringstream ss;
        ss << std::setw(4) << std::setfill('0') << all_frame_num_;
        cam->image_name_ = "test_" + ss.str() + ".jpg";

        cam->setIntrinsic(width, height, fx_, fy_, cx_, cy_);
        cam->setPose(q_wc.toRotationMatrix(), t_wc);
        test_cameras_.emplace_back(cam);
    }

    all_frame_num_ += 1;
}

// ---------------------------------------------------------------------------
// GaussianModel constructor — identical to original
// ---------------------------------------------------------------------------
GaussianModel::GaussianModel(const Params& prm)
{
    sh_degree_ = prm.sh_degree;
    white_background_ = prm.white_background;
    random_background_ = prm.random_background;
    convert_SHs_python_ = prm.convert_SHs_python;
    compute_cov3D_python_ = prm.compute_cov3D_python;
    lambda_erank_ = static_cast<float>(prm.lambda_erank);
    scaling_scale_ = prm.scaling_scale;

    position_lr_ = prm.position_lr;
    feature_lr_ = prm.feature_lr;
    opacity_lr_ = prm.opacity_lr;
    scaling_lr_ = prm.scaling_lr;
    rotation_lr_ = prm.rotation_lr;
    lambda_dssim_ = prm.lambda_dssim;
    optimize_depth_ = prm.optimize_depth;
    lambda_depth_ = prm.lambda_depth;
    iteration_decay_ = prm.iteration_decay;

    apply_exposure_ = prm.apply_exposure;
    exposure_lr_ = prm.exposure_lr;
    skybox_points_num_ = prm.skybox_points_num;
    skybox_radius_ = prm.skybox_radius;
    max_gaussians_ = prm.max_gaussians;

    auto device_type = torch::kCUDA;
    GAUSSIAN_MODEL_INIT_TENSORS(device_type)

    is_init_ = false;
    t_forward_ = 0; t_backward_ = 0; t_step_ = 0; t_optlist_ = 0; t_tocuda_ = 0;
}

torch::Tensor GaussianModel::getScaling() { return torch::exp(scaling_); }
torch::Tensor GaussianModel::getRotation() { return torch::nn::functional::normalize(rotation_); }
torch::Tensor GaussianModel::getXYZ() { return xyz_; }
torch::Tensor GaussianModel::getFeaturesDc() { return features_dc_; }
torch::Tensor GaussianModel::getFeaturesRest() { return features_rest_; }
torch::Tensor GaussianModel::getOpacity() { return torch::sigmoid(opacity_); }
torch::Tensor GaussianModel::getExposure() { return exposure_; }

torch::Tensor GaussianModel::getCovariance(int scaling_modifier)
{
    auto r = this->rotation_;
    auto R = general_utils::build_rotation(r);
    auto s = scaling_modifier * this->getScaling();
    auto L = torch::zeros({s.size(0), 3, 3}, torch::TensorOptions().dtype(torch::kFloat).device(torch::kCUDA));
    L.select(1, 0).select(1, 0).copy_(s.index({torch::indexing::Slice(), 0}));
    L.select(1, 1).select(1, 1).copy_(s.index({torch::indexing::Slice(), 1}));
    L.select(1, 2).select(1, 2).copy_(s.index({torch::indexing::Slice(), 2}));
    L = R.matmul(L);
    auto actual_covariance = L.matmul(L.transpose(1, 2));
    auto symm_uncertainty = torch::zeros({actual_covariance.size(0), 6}, torch::TensorOptions().dtype(torch::kFloat).device(torch::kCUDA));
    symm_uncertainty.select(1, 0).copy_(actual_covariance.index({torch::indexing::Slice(), 0, 0}));
    symm_uncertainty.select(1, 1).copy_(actual_covariance.index({torch::indexing::Slice(), 0, 1}));
    symm_uncertainty.select(1, 2).copy_(actual_covariance.index({torch::indexing::Slice(), 0, 2}));
    symm_uncertainty.select(1, 3).copy_(actual_covariance.index({torch::indexing::Slice(), 1, 1}));
    symm_uncertainty.select(1, 4).copy_(actual_covariance.index({torch::indexing::Slice(), 1, 2}));
    symm_uncertainty.select(1, 5).copy_(actual_covariance.index({torch::indexing::Slice(), 2, 2}));
    return symm_uncertainty;
}

// ---------------------------------------------------------------------------
// initialize — identical algorithm to src/gaussian.cpp
// ---------------------------------------------------------------------------
void GaussianModel::initialize(const std::shared_ptr<Dataset>& dataset)
{
    int num = static_cast<int>(dataset->pointcloud_.size());
    assert(num > 0);
    torch::Tensor fused_point_cloud = torch::zeros({num, 3}, torch::kFloat32).cuda();
    int deg_2 = (sh_degree_ + 1) * (sh_degree_ + 1);
    torch::Tensor features = torch::zeros({num, 3, deg_2}, torch::kFloat32).cuda();
    torch::Tensor scales = torch::zeros({num}, torch::kFloat32).cuda();

    double f = (dataset->fx_ + dataset->fy_) / 2;
    for (int i = 0; i < num; ++i)
    {
        auto& pt_w = dataset->pointcloud_[i];
        auto& color = dataset->pointcolor_[i];
        fused_point_cloud.index({i, 0}) = pt_w.x();
        fused_point_cloud.index({i, 1}) = pt_w.y();
        fused_point_cloud.index({i, 2}) = pt_w.z();
        features.index({i, 0, 0}) = RGB2SH(color.x());
        features.index({i, 1, 0}) = RGB2SH(color.y());
        features.index({i, 2, 0}) = RGB2SH(color.z());

        double d = dataset->pointdepth_[i];
        scales.index({i}) = std::log(scaling_scale_ * d / f);
    }
    scales = scales.unsqueeze(1).repeat({1, 3});
    torch::Tensor rots = torch::zeros({num, 4}, torch::kFloat32).cuda();
    rots.index({torch::indexing::Slice(), 0}) = 1;
    torch::Tensor opacities = general_utils::inverse_sigmoid(0.1f * torch::ones({num, 1}, torch::kFloat32).cuda());

    // Sky
    if (skybox_points_num_ > 0)
    {
        int num_sky = skybox_points_num_;
        double radius = skybox_radius_;
        torch::Tensor pi = torch::acos(torch::tensor(-1.0, torch::kFloat32).cuda());
        torch::Tensor theta = 2.0 * pi * torch::rand({num_sky}, torch::kFloat32).cuda();
        torch::Tensor phi = torch::acos(1.0 - 1.4 * torch::rand({num_sky}, torch::kFloat32).cuda());
        torch::Tensor sky_pts = torch::zeros({num_sky, 3}, torch::kFloat32).cuda();
        sky_pts.index({torch::indexing::Slice(), 0}) = radius * 10 * torch::cos(theta) * torch::sin(phi);
        sky_pts.index({torch::indexing::Slice(), 1}) = radius * 10 * torch::sin(theta) * torch::sin(phi);
        sky_pts.index({torch::indexing::Slice(), 2}) = radius * 10 * torch::cos(phi);

        torch::Tensor sky_feat = torch::zeros({num_sky, 3, deg_2}, torch::kFloat32).cuda();
        sky_feat.index({torch::indexing::Slice(), 0, 0}) = 0.7;
        sky_feat.index({torch::indexing::Slice(), 1, 0}) = 0.8;
        sky_feat.index({torch::indexing::Slice(), 2, 0}) = 0.95;

        torch::Tensor dist2 = torch::clamp_min(distCUDA2(sky_pts.clone()), 0.0000001);
        torch::Tensor sky_scales = torch::log(torch::sqrt(dist2)).unsqueeze(1).repeat({1, 3});
        torch::Tensor sky_rots = torch::zeros({num_sky, 4}, torch::kFloat32).cuda();
        sky_rots.index({torch::indexing::Slice(), 0}) = 1;
        torch::Tensor sky_opc = general_utils::inverse_sigmoid(0.7f * torch::ones({num_sky, 1}, torch::kFloat32).cuda());

        fused_point_cloud = torch::cat({sky_pts, fused_point_cloud}, 0);
        features = torch::cat({sky_feat, features}, 0);
        scales = torch::cat({sky_scales, scales}, 0);
        rots = torch::cat({sky_rots, rots}, 0);
        opacities = torch::cat({sky_opc, opacities}, 0);
    }

    this->xyz_ = fused_point_cloud.requires_grad_();
    this->features_dc_ = features.index({torch::indexing::Slice(), torch::indexing::Slice(), torch::indexing::Slice(0, 1)}).transpose(1, 2).contiguous().requires_grad_();
    this->features_rest_ = features.index({torch::indexing::Slice(), torch::indexing::Slice(), torch::indexing::Slice(1, features.size(2))}).transpose(1, 2).contiguous().requires_grad_();
    this->scaling_ = scales.requires_grad_();
    this->rotation_ = rots.requires_grad_();
    this->opacity_ = opacities.requires_grad_();

    if (apply_exposure_)
    {
        torch::Tensor exposure = torch::eye(3, torch::kFloat32).cuda();
        exposure = torch::cat({exposure, torch::zeros({3, 1}, torch::kFloat32).cuda()}, 1);
        this->exposure_ = exposure.requires_grad_();
    }

    GAUSSIAN_MODEL_TENSORS_TO_VEC

    std::cout << std::fixed << std::setprecision(2)
              << " Init Map with " << double(fused_point_cloud.size(0)) / 10000 << "w GS,";

    dataset->pointcloud_.clear();
    dataset->pointcolor_.clear();
    dataset->pointdepth_.clear();
}

// ---------------------------------------------------------------------------
// saveMap — identical algorithm to original
// ---------------------------------------------------------------------------
void GaussianModel::saveMap(const std::string& result_path)
{
    std::string pc_path = result_path + "/point_cloud.ply";

    torch::Tensor xyz = this->xyz_.index({torch::indexing::Slice(skybox_points_num_)}).detach().cpu();
    torch::Tensor f_dc = this->features_dc_.index({torch::indexing::Slice(skybox_points_num_)}).detach().transpose(1, 2).flatten(1).contiguous().cpu();
    torch::Tensor f_rest = this->features_rest_.index({torch::indexing::Slice(skybox_points_num_)}).detach().transpose(1, 2).flatten(1).contiguous().cpu();
    torch::Tensor opacities = this->opacity_.index({torch::indexing::Slice(skybox_points_num_)}).detach().cpu();
    torch::Tensor scale = this->scaling_.index({torch::indexing::Slice(skybox_points_num_)}).detach().cpu();
    torch::Tensor rotation = this->rotation_.index({torch::indexing::Slice(skybox_points_num_)}).detach().cpu();

    std::filebuf fb_binary;
    fb_binary.open(pc_path, std::ios::out | std::ios::binary);
    std::ostream outstream_binary(&fb_binary);

    tinyply::PlyFile result_file;

    result_file.add_properties_to_element("vertex", {"x", "y", "z"},
        tinyply::Type::FLOAT32, xyz.size(0),
        reinterpret_cast<uint8_t*>(xyz.data_ptr<float>()), tinyply::Type::INVALID, 0);

    std::size_t n_f_dc = this->features_dc_.size(1) * this->features_dc_.size(2);
    std::vector<std::string> names_f_dc(n_f_dc);
    for (std::size_t i = 0; i < n_f_dc; ++i) names_f_dc[i] = "f_dc_" + std::to_string(i);
    result_file.add_properties_to_element("vertex", names_f_dc,
        tinyply::Type::FLOAT32, this->features_dc_.size(0),
        reinterpret_cast<uint8_t*>(f_dc.data_ptr<float>()), tinyply::Type::INVALID, 0);

    std::size_t n_f_rest = this->features_rest_.size(1) * this->features_rest_.size(2);
    std::vector<std::string> names_f_rest(n_f_rest);
    for (std::size_t i = 0; i < n_f_rest; ++i) names_f_rest[i] = "f_rest_" + std::to_string(i);
    result_file.add_properties_to_element("vertex", names_f_rest,
        tinyply::Type::FLOAT32, this->features_rest_.size(0),
        reinterpret_cast<uint8_t*>(f_rest.data_ptr<float>()), tinyply::Type::INVALID, 0);

    result_file.add_properties_to_element("vertex", {"opacity"},
        tinyply::Type::FLOAT32, opacities.size(0),
        reinterpret_cast<uint8_t*>(opacities.data_ptr<float>()), tinyply::Type::INVALID, 0);

    std::size_t n_scale = scale.size(1);
    std::vector<std::string> names_scale(n_scale);
    for (std::size_t i = 0; i < n_scale; ++i) names_scale[i] = "scale_" + std::to_string(i);
    result_file.add_properties_to_element("vertex", names_scale,
        tinyply::Type::FLOAT32, scale.size(0),
        reinterpret_cast<uint8_t*>(scale.data_ptr<float>()), tinyply::Type::INVALID, 0);

    std::size_t n_rot = rotation.size(1);
    std::vector<std::string> names_rot(n_rot);
    for (std::size_t i = 0; i < n_rot; ++i) names_rot[i] = "rot_" + std::to_string(i);
    result_file.add_properties_to_element("vertex", names_rot,
        tinyply::Type::FLOAT32, rotation.size(0),
        reinterpret_cast<uint8_t*>(rotation.data_ptr<float>()), tinyply::Type::INVALID, 0);

    result_file.write(outstream_binary, true);
    fb_binary.close();
}

// ---------------------------------------------------------------------------
// trainingSetup — identical to original
// ---------------------------------------------------------------------------
void GaussianModel::trainingSetup()
{
    this->sparse_optimizer_.reset(new SparseGaussianAdam(Tensor_vec_xyz_, 0.0, 1e-15));
    sparse_optimizer_->param_groups()[0].options().set_lr(position_lr_);
    sparse_optimizer_->add_param_group(Tensor_vec_feature_dc_);
    sparse_optimizer_->param_groups()[1].options().set_lr(feature_lr_);
    sparse_optimizer_->add_param_group(Tensor_vec_feature_rest_);
    sparse_optimizer_->param_groups()[2].options().set_lr(feature_lr_ / 20.0);
    sparse_optimizer_->add_param_group(Tensor_vec_opacity_);
    sparse_optimizer_->param_groups()[3].options().set_lr(opacity_lr_);
    sparse_optimizer_->add_param_group(Tensor_vec_scaling_);
    sparse_optimizer_->param_groups()[4].options().set_lr(scaling_lr_);
    sparse_optimizer_->add_param_group(Tensor_vec_rotation_);
    sparse_optimizer_->param_groups()[5].options().set_lr(rotation_lr_);

    if (apply_exposure_)
    {
        this->exposure_optimizer_.reset(new torch::optim::Adam(Tensor_vec_exposure_, {}));
        exposure_optimizer_->param_groups()[0].options().set_lr(exposure_lr_);
    }
}

// ---------------------------------------------------------------------------
// densificationPostfix — identical to original
// ---------------------------------------------------------------------------
void GaussianModel::densificationPostfix(
    torch::Tensor& new_xyz,
    torch::Tensor& new_features_dc,
    torch::Tensor& new_features_rest,
    torch::Tensor& new_opacities,
    torch::Tensor& new_scaling,
    torch::Tensor& new_rotation)
{
    std::vector<torch::Tensor> optimizable_tensors(6);
    std::vector<torch::Tensor> tensors_dict = {new_xyz, new_features_dc, new_features_rest,
                                                new_opacities, new_scaling, new_rotation};
    auto& param_groups = this->sparse_optimizer_->param_groups();
    auto& optimizer_state = this->sparse_optimizer_->get_state();

    for (int group_idx = 0; group_idx < 6; ++group_idx)
    {
        auto& group = param_groups[group_idx];
        assert(group.params().size() == 1);
        auto& extension_tensor = tensors_dict[group_idx];
        auto& param = group.params()[0];
        auto old_param_impl = param.unsafeGetTensorImpl();

        param = torch::cat({param, extension_tensor}, 0).requires_grad_();
        group.params()[0] = param;
        auto new_param_impl = param.unsafeGetTensorImpl();

        auto state_it = optimizer_state.find(old_param_impl);
        if (state_it != optimizer_state.end())
        {
            auto stored_state = state_it->second;
            stored_state.exp_avg = torch::cat({stored_state.exp_avg.clone(), torch::zeros_like(extension_tensor)}, 0);
            stored_state.exp_avg_sq = torch::cat({stored_state.exp_avg_sq.clone(), torch::zeros_like(extension_tensor)}, 0);
            optimizer_state.erase(state_it);
            optimizer_state[new_param_impl] = stored_state;
        }
        else
        {
            State new_state;
            new_state.step = 0;
            new_state.exp_avg = torch::zeros_like(param, torch::MemoryFormat::Preserve);
            new_state.exp_avg_sq = torch::zeros_like(param, torch::MemoryFormat::Preserve);
            new_state.initialized = true;
            optimizer_state[new_param_impl] = new_state;
        }
        optimizable_tensors[group_idx] = param;
    }

    this->xyz_ = optimizable_tensors[0];
    this->features_dc_ = optimizable_tensors[1];
    this->features_rest_ = optimizable_tensors[2];
    this->opacity_ = optimizable_tensors[3];
    this->scaling_ = optimizable_tensors[4];
    this->rotation_ = optimizable_tensors[5];
    GAUSSIAN_MODEL_TENSORS_TO_VEC
}

// ---------------------------------------------------------------------------
// extend — identical algorithm to original
// ---------------------------------------------------------------------------
void extend(const std::shared_ptr<Dataset>& dataset, std::shared_ptr<GaussianModel>& pc)
{
    torch::NoGradGuard no_grad;
    torch::Tensor bg;
    if (pc->white_background_) bg = torch::ones({3}, torch::kFloat32).cuda();
    else bg = torch::zeros({3}, torch::kFloat32).cuda();
    std::shared_ptr<Camera> viewpoint_cam = dataset->train_cameras_.back();
    auto render_pkg = render(viewpoint_cam, pc, bg, pc->apply_exposure_, true);
    auto rendered_alpha = 1 - std::get<2>(render_pkg).squeeze(0);

    int n = dataset->pointcloud_.size();
    std::vector<float> float_point(n * 3);
    std::vector<float> float_color(n * 3);
    for (size_t i = 0; i < n; ++i)
    {
        float_point[3*i+0] = static_cast<float>(dataset->pointcloud_[i][0]);
        float_point[3*i+1] = static_cast<float>(dataset->pointcloud_[i][1]);
        float_point[3*i+2] = static_cast<float>(dataset->pointcloud_[i][2]);
        float_color[3*i+0] = static_cast<float>(dataset->pointcolor_[i][0]);
        float_color[3*i+1] = static_cast<float>(dataset->pointcolor_[i][1]);
        float_color[3*i+2] = static_cast<float>(dataset->pointcolor_[i][2]);
    }
    torch::Tensor points = torch::from_blob(float_point.data(), {n, 3}).to(torch::kFloat32).cuda();
    torch::Tensor colors = torch::from_blob(float_color.data(), {n, 3}).to(torch::kFloat32).cuda();
    torch::Tensor depths_in_rsp_frame = torch::from_blob(dataset->pointdepth_.data(), {n}).to(torch::kFloat32).cuda();

    auto R_wc = dataset->R_wc_.back();
    auto t_wc = dataset->t_wc_.back();
    auto R_cw = R_wc.transpose();
    auto t_cw = -R_cw * t_wc;
    std::vector<float> float_R_cw(9), float_t_cw(3);
    for (size_t i = 0; i < 3; ++i)
    {
        float_R_cw[3*i+0] = static_cast<float>(R_cw(i, 0));
        float_R_cw[3*i+1] = static_cast<float>(R_cw(i, 1));
        float_R_cw[3*i+2] = static_cast<float>(R_cw(i, 2));
        float_t_cw[i] = static_cast<float>(t_cw[i]);
    }
    torch::Tensor R_cw_tensor = torch::from_blob(float_R_cw.data(), {3, 3}).to(torch::kFloat32).cuda();
    torch::Tensor t_cw_tensor = torch::from_blob(float_t_cw.data(), {3, 1}).to(torch::kFloat32).cuda();
    auto points_camera = torch::matmul(points, R_cw_tensor.t()) + t_cw_tensor.view({1, 3});
    auto depths = points_camera.index({torch::indexing::Slice(), 2});
    float fx = static_cast<float>(viewpoint_cam->fx_);
    float fy = static_cast<float>(viewpoint_cam->fy_);
    float cx = static_cast<float>(viewpoint_cam->cx_);
    float cy = static_cast<float>(viewpoint_cam->cy_);
    float focal = (fx + fy) / 2.0f;
    torch::Tensor x_pixel = (points_camera.index({torch::indexing::Slice(), 0}) * fx) / depths + cx;
    torch::Tensor y_pixel = (points_camera.index({torch::indexing::Slice(), 1}) * fy) / depths + cy;
    auto pixels = torch::stack({x_pixel, y_pixel}, 1).floor().to(torch::kInt32);
    auto pixels_float = pixels.to(torch::kFloat32);
    auto pixels_with_depth = torch::cat({pixels_float, depths.unsqueeze(1)}, 1).to(torch::kCPU);
    auto pixels_depth_a = pixels_with_depth.accessor<float, 2>();

    std::unordered_map<std::string, std::pair<int, float>> pixel_depth_map;
    for (int i = 0; i < pixels_with_depth.size(0); ++i)
    {
        int x = static_cast<int>(pixels_depth_a[i][0]);
        int y = static_cast<int>(pixels_depth_a[i][1]);
        float d = pixels_depth_a[i][2];
        std::string key = std::to_string(x) + "_" + std::to_string(y);
        if (!pixel_depth_map.count(key) || d < pixel_depth_map[key].second)
            pixel_depth_map[key] = {i, d};
    }

    std::vector<int64_t> keep_indices;
    for (const auto& item : pixel_depth_map)
        keep_indices.push_back(item.second.first);

    auto keep_tensor = torch::from_blob(keep_indices.data(), {static_cast<int64_t>(keep_indices.size())}, torch::kInt64).to(points.device());
    auto filtered_points = points.index_select(0, keep_tensor);
    auto filtered_colors = colors.index_select(0, keep_tensor);
    auto filtered_depths = depths_in_rsp_frame.index_select(0, keep_tensor);
    auto filtered_pixels = pixels.index_select(0, keep_tensor);

    int H = viewpoint_cam->image_height_, W = viewpoint_cam->image_width_;
    auto filter = [H, W, &rendered_alpha](const torch::Tensor& pts, const torch::Tensor& cols,
                                          const torch::Tensor& dpts, const torch::Tensor& pxls)
    {
        auto in_image = (pxls.index({torch::indexing::Slice(), 0}) >= 0) & (pxls.index({torch::indexing::Slice(), 0}) < W) &
                        (pxls.index({torch::indexing::Slice(), 1}) >= 0) & (pxls.index({torch::indexing::Slice(), 1}) < H);
        auto positive_depth = dpts > 0;
        auto x_c = pxls.index({torch::indexing::Slice(), 0}).clamp(0, W - 1);
        auto y_c = pxls.index({torch::indexing::Slice(), 1}).clamp(0, H - 1);
        auto opaque = rendered_alpha.index({y_c, x_c}) < 0.99;
        auto valid = torch::logical_and(torch::logical_and(in_image, positive_depth), opaque);
        return std::make_tuple(pts.index({valid, torch::indexing::Slice()}),
                               cols.index({valid, torch::indexing::Slice()}),
                               dpts.index({valid}));
    };

    auto filtered_pkg = filter(filtered_points, filtered_colors, filtered_depths, filtered_pixels);

    torch::Tensor fused_point_cloud = std::get<0>(filtered_pkg);
    torch::Tensor fused_color = RGB2SH(std::get<1>(filtered_pkg));
    int num = fused_point_cloud.size(0);

    if (pc->max_gaussians_ > 0)
    {
        int64_t current = pc->xyz_.size(0);
        int64_t budget = static_cast<int64_t>(pc->max_gaussians_) - current;
        if (budget <= 0)
        {
            dataset->pointcloud_.clear(); dataset->pointcolor_.clear(); dataset->pointdepth_.clear();
            return;
        }
        if (num > budget)
        {
            auto idx = torch::randperm(num, torch::kLong).narrow(0, 0, budget).to(fused_point_cloud.device());
            fused_point_cloud = fused_point_cloud.index_select(0, idx);
            fused_color = fused_color.index_select(0, idx);
            auto fd = std::get<2>(filtered_pkg).index_select(0, idx);
            filtered_pkg = std::make_tuple(fused_point_cloud, std::get<1>(filtered_pkg).index_select(0, idx), fd);
            num = static_cast<int>(budget);
        }
    }

    int deg_2 = (pc->sh_degree_ + 1) * (pc->sh_degree_ + 1);
    torch::Tensor features = torch::zeros({num, 3, deg_2}, torch::kFloat32).cuda();
    features.index({torch::indexing::Slice(), torch::indexing::Slice(0, 3), 0}) = fused_color;
    torch::Tensor features_dc = features.index({torch::indexing::Slice(), torch::indexing::Slice(), torch::indexing::Slice(0, 1)}).transpose(1, 2).contiguous();
    torch::Tensor features_rest = features.index({torch::indexing::Slice(), torch::indexing::Slice(), torch::indexing::Slice(1, features.size(2))}).transpose(1, 2).contiguous();
    torch::Tensor scales = torch::log(pc->scaling_scale_ * std::get<2>(filtered_pkg) / focal).unsqueeze(1).repeat({1, 3});
    torch::Tensor rots = torch::zeros({num, 4}, torch::kFloat32).cuda();
    rots.index({torch::indexing::Slice(), 0}) = 1;
    torch::Tensor opacities = general_utils::inverse_sigmoid(0.1f * torch::ones({num, 1}, torch::kFloat32).cuda());

    pc->densificationPostfix(fused_point_cloud, features_dc, features_rest, opacities, scales, rots);

    std::cout << std::fixed << std::setprecision(2)
              << " Insert " << double(fused_point_cloud.size(0)) / 1000 << "k GS,";

    dataset->pointcloud_.clear();
    dataset->pointcolor_.clear();
    dataset->pointdepth_.clear();
}

// ---------------------------------------------------------------------------
// optimize — identical algorithm to original
// ---------------------------------------------------------------------------
static void decayOptList(int max_iters, int train_camera_num,
                         const std::shared_ptr<Dataset>& dataset,
                         const std::vector<int>& all_list, std::vector<int>& opt_list)
{
    Eigen::Vector3d t0 = dataset->t_wc_[0];
    double dist = (dataset->t_wc_.back() - t0).norm();
    if (dist > 120)
    {
        max_iters /= 2;
        opt_list.clear();
        std::random_device rd;
        std::mt19937 gen(rd());
        int split = train_camera_num * 2 / 3;
        int half = max_iters / 2;
        std::sample(all_list.begin(), all_list.begin() + split, std::back_inserter(opt_list), std::min(half, split), gen);
        std::sample(all_list.begin() + split, all_list.end(), std::back_inserter(opt_list), std::min(half, train_camera_num - split), gen);
    }
}

double optimize(const std::shared_ptr<Dataset>& dataset, std::shared_ptr<GaussianModel>& pc)
{
    pc->t_start_ = std::chrono::steady_clock::now();
    int updated_num = 0;
    std::vector<int> opt_list;
    int max_iters = 100;

    int train_camera_num = dataset->train_cameras_.size();
    std::vector<int> all_list(train_camera_num);
    std::iota(all_list.begin(), all_list.end(), 0);

    std::random_device rd;
    std::mt19937 gen(rd());
    if (train_camera_num <= max_iters) opt_list = all_list;
    else std::sample(all_list.begin(), all_list.end(), std::back_inserter(opt_list), max_iters, gen);
    if (pc->iteration_decay_) decayOptList(max_iters, train_camera_num, dataset, all_list, opt_list);
    std::shuffle(opt_list.begin(), opt_list.end(), gen);
    torch::cuda::synchronize();
    pc->t_end_ = std::chrono::steady_clock::now();
    pc->t_optlist_ += std::chrono::duration_cast<std::chrono::duration<double>>(pc->t_end_ - pc->t_start_).count();

    pc->t_start_ = std::chrono::steady_clock::now();
    torch::Tensor bg;
    if (pc->white_background_) bg = torch::ones({3}, torch::kFloat32).cuda();
    else bg = torch::zeros({3}, torch::kFloat32).cuda();
    torch::cuda::synchronize();
    pc->t_end_ = std::chrono::steady_clock::now();
    pc->t_tocuda_ += std::chrono::duration_cast<std::chrono::duration<double>>(pc->t_end_ - pc->t_start_).count();

    for (int idx : opt_list)
    {
        pc->t_start_ = std::chrono::steady_clock::now();
        const std::shared_ptr<Camera>& viewpoint_cam = dataset->train_cameras_[idx];
        auto gt_image = viewpoint_cam->original_image_.to(torch::kCUDA, true);
        auto gt_depth = viewpoint_cam->original_depth_.to(torch::kCUDA, true);
        torch::cuda::synchronize();
        pc->t_end_ = std::chrono::steady_clock::now();
        pc->t_tocuda_ += std::chrono::duration_cast<std::chrono::duration<double>>(pc->t_end_ - pc->t_start_).count();

        pc->t_start_ = std::chrono::steady_clock::now();
        auto render_pkg = render(viewpoint_cam, pc, bg, pc->apply_exposure_);
        auto rendered_image = std::get<0>(render_pkg);
        auto rendered_depth = std::get<1>(render_pkg);
        auto mask = (gt_depth > 0) & (rendered_depth > 0);
        auto Ll1 = loss_utils::l1_loss(rendered_image, gt_image);
        auto Ll1_depth = torch::abs(rendered_depth.masked_select(mask) - gt_depth.masked_select(mask)).mean();
        float lambda_dssim = static_cast<float>(pc->lambda_dssim_);
        float lambda_depth = static_cast<float>(pc->lambda_depth_);
        torch::Tensor ssim_value;
        torch::Tensor rendered_image_unsq = rendered_image.unsqueeze(0);
        torch::Tensor gt_image_unsq = gt_image.unsqueeze(0);
        ssim_value = loss_utils::fused_ssim(rendered_image_unsq, gt_image_unsq);
        auto loss = (1.0 - lambda_dssim) * Ll1 + lambda_dssim * (1.0 - ssim_value);
        if (pc->optimize_depth_) loss += lambda_depth * Ll1_depth;
        torch::cuda::synchronize();
        pc->t_end_ = std::chrono::steady_clock::now();
        pc->t_forward_ += std::chrono::duration_cast<std::chrono::duration<double>>(pc->t_end_ - pc->t_start_).count();

        pc->t_start_ = std::chrono::steady_clock::now();
        loss.backward();
        torch::cuda::synchronize();
        pc->t_end_ = std::chrono::steady_clock::now();
        pc->t_backward_ += std::chrono::duration_cast<std::chrono::duration<double>>(pc->t_end_ - pc->t_start_).count();

        pc->t_start_ = std::chrono::steady_clock::now();
        auto visible = std::get<4>(render_pkg);
        updated_num += visible.sum().item<int>();
        pc->sparse_optimizer_->set_visibility_and_N(visible, pc->getXYZ().size(0));
        pc->sparse_optimizer_->step();
        pc->sparse_optimizer_->zero_grad(true);
        if (pc->apply_exposure_)
        {
            pc->exposure_optimizer_->step();
            pc->exposure_optimizer_->zero_grad(true);
        }
        torch::cuda::synchronize();
        pc->t_end_ = std::chrono::steady_clock::now();
        pc->t_step_ += std::chrono::duration_cast<std::chrono::duration<double>>(pc->t_end_ - pc->t_start_).count();
    }

    return updated_num / opt_list.size();
}

// ---------------------------------------------------------------------------
// evaluateVisualQuality — identical algorithm to original
// ---------------------------------------------------------------------------
void evaluateVisualQuality(const std::shared_ptr<Dataset>& dataset,
                           std::shared_ptr<GaussianModel>& pc,
                           const std::string& result_path,
                           const std::string& lpips_path)
{
    std::cout << "\n     Evaluate Visual Quality\n";
    std::cout << "\n        [Number of Final Gaussians] " << pc->getXYZ().size(0) << std::endl;

    if (fs::exists(result_path)) fs::remove_all(result_path);
    fs::create_directories(result_path);

    std::string render_dir = result_path + "/render";
    fs::create_directories(render_dir);
    std::string depth_dir = result_path + "/render_depth";
    fs::create_directories(depth_dir);
    std::string gt_dir = result_path + "/gt";
    fs::create_directories(gt_dir);

    torch::Tensor bg;
    if (pc->white_background_) bg = torch::ones({3}, torch::kFloat32).cuda();
    else bg = torch::zeros({3}, torch::kFloat32).cuda();

    torch::jit::script::Module m_lpips;
    try
    {
        m_lpips = torch::jit::load(lpips_path + "/lpips_alex.pt");
        m_lpips.to(torch::kCUDA);
    }
    catch (const c10::Error& e)
    {
        std::cerr << "lpips model loading failed: " << e.what() << std::endl;
    }

    auto eval_set = [&](const std::vector<std::shared_ptr<Camera>>& cameras, const std::string& label)
    {
        if (cameras.empty()) return;
        double psnrs = 0, ssims = 0, lpipss = 0;
        for (const auto& cam : cameras)
        {
            auto render_pkg = render(cam, pc, bg, pc->apply_exposure_);
            auto rendered_image = std::get<0>(render_pkg).clamp(0, 1);
            auto rendered_depth = std::get<1>(render_pkg);
            auto gt_image = cam->original_image_.cuda().clamp(0, 1);
            double psnr = loss_utils::psnr(rendered_image, gt_image).mean().item<double>();
            double ssim = loss_utils::ssim(rendered_image, gt_image).item<double>();
            std::vector<torch::jit::IValue> inputs;
            inputs.push_back(rendered_image.unsqueeze(0));
            inputs.push_back(gt_image.unsqueeze(0));
            double lpips_val = m_lpips.forward(inputs).toTensor().item<double>();
            psnrs += psnr; ssims += ssim; lpipss += lpips_val;

            int H = rendered_image.size(1), W = rendered_image.size(2);
            torch::Tensor a_cpu = rendered_image.to(torch::kCPU).permute({1, 2, 0}).contiguous();
            a_cpu = a_cpu.mul(255).clamp(0, 255).to(torch::kU8);
            cv::Mat a_img(H, W, CV_8UC3, a_cpu.data_ptr<uint8_t>());
            cv::cvtColor(a_img, a_img, cv::COLOR_RGB2BGR);
            cv::imwrite(render_dir + "/" + cam->image_name_, a_img);

            torch::Tensor b_cpu = gt_image.to(torch::kCPU).permute({1, 2, 0}).contiguous();
            b_cpu = b_cpu.mul(255).clamp(0, 255).to(torch::kU8);
            cv::Mat b_img(H, W, CV_8UC3, b_cpu.data_ptr<uint8_t>());
            cv::cvtColor(b_img, b_img, cv::COLOR_RGB2BGR);
            cv::imwrite(gt_dir + "/" + cam->image_name_, b_img);

            torch::Tensor dn = (rendered_depth - rendered_depth.min()) /
                               (rendered_depth.max() - rendered_depth.min()) * 255;
            torch::Tensor c_cpu = dn.to(torch::kCPU);
            cv::Mat c_img(H, W, CV_32FC1, c_cpu.data_ptr<float>());
            c_img.convertTo(c_img, CV_8UC1);
            cv::applyColorMap(c_img, c_img, cv::COLORMAP_JET);
            cv::imwrite(depth_dir + "/" + cam->image_name_, c_img);
        }
        psnrs /= cameras.size(); ssims /= cameras.size(); lpipss /= cameras.size();
        std::cout << std::fixed << std::setprecision(2)
                  << "        [" << label << " PSNR] " << psnrs << std::endl;
        std::cout << std::fixed << std::setprecision(3)
                  << "        [" << label << " SSIM] " << ssims << std::endl
                  << "        [" << label << " LPIPS] " << lpipss << std::endl;
    };

    eval_set(dataset->train_cameras_, "Training View");
    eval_set(dataset->test_cameras_, "Novel View");
}

}  // namespace winlic
