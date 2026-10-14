# Module Reference: `src/` — Core ROS-Based Mapping Node

The `src/` directory contains the primary Gaussian-LIC2 mapping node, built as a ROS catkin package. It subscribes to LiDAR point clouds, camera poses, RGB images, and depth maps from an upstream odometry node (Coco-LIC), then incrementally builds, optimizes, and evaluates a 3D Gaussian Splatting map.

**Build target:** `gs_mapping` executable (via root `CMakeLists.txt` + `package.xml`)
**Language:** C++17, CUDA, LibTorch C++ frontend
**Dependencies:** ROS Noetic, OpenCV 4.7 (CUDA), LibTorch 2.0.1, TensorRT 8.6, yaml-cpp, Eigen3, PCL

---

## File Inventory

### Entry Point and Orchestration

| File | Description |
|---|---|
| `mapping.cpp` | `main()` — ROS node entry point; creates subscribers, spawns the mapping and watchdog threads, and manages lifecycle |
| `mapping.h` | `Params` class (YAML-driven configuration) and `Frame` struct (aligned sensor messages) |

### Gaussian Model and Dataset

| File | Description |
|---|---|
| `gaussian.h` | `Dataset` class (frame accumulation, keyframe selection), `GaussianModel` class (3DGS map representation), and free function declarations (`extend`, `optimize`, `evaluateVisualQuality`) |
| `gaussian.cpp` | Implementations of all the above — map initialization, depth-completion-based densification, incremental extension, optimization loop, evaluation, and PLY export |
| `camera.h` | `Camera` class — intrinsics, pose, precomputed transform matrices (world-view, projection, full-projection, camera center) as CUDA tensors |

### Depth Completion

| File | Description |
|---|---|
| `depth_completer.h` | `DepthCompleter` class declaration — wraps a TensorRT engine for SPNet inference |
| `depth_completer.cpp` | TensorRT engine loading, input preparation (RGB + sparse depth + mask), synchronous inference, and output extraction |

### Rasterizer (CUDA)

| File | Description |
|---|---|
| `rasterizer/renderer.h` / `.cpp` | Top-level `render()` function and `GaussianRasterizer` (autograd `Function` + `nn::Module` wrapper) |
| `rasterizer/rasterizer.h` / `.cpp` | `GaussianRasterizationSettings` struct and `GaussianRasterizerFunction` (torch::autograd::Function) |
| `rasterizer/rasterize_points.h` / `.cu` | `RasterizeGaussiansCUDA()` and `RasterizeGaussiansBackwardCUDA()` — C++/CUDA entry points; also `adamUpdate()` host wrapper |
| `rasterizer/cuda_rasterizer/rasterizer.h` | `CudaRasterizer::Rasterizer` class — `forward()` and `backward()` static methods |
| `rasterizer/cuda_rasterizer/rasterizer_impl.h` / `.cu` | Implementation — buffer arena allocation, preprocessing, tile sorting, bucket counting, render dispatch |
| `rasterizer/cuda_rasterizer/forward.h` / `.cu` | `FORWARD::preprocess` (projection, covariance, SH, tile culling) and `FORWARD::render` (alpha-blending with transmittance checkpoints) |
| `rasterizer/cuda_rasterizer/backward.h` / `.cu` | `BACKWARD::render` (per-Gaussian bucketed backward) and `BACKWARD::preprocess` (covariance, SH, erank gradients) |
| `rasterizer/cuda_rasterizer/adam.h` / `.cu` | `ADAM::adamUpdate` — CUDA kernel for visibility-gated sparse Adam updates |
| `rasterizer/cuda_rasterizer/auxiliary.h` | Shared device helpers (covariance building, SH evaluation, projection) |
| `rasterizer/cuda_rasterizer/config.h` | Constants: `NUM_CHANNELS=3`, `BLOCK_X=BLOCK_Y=16` (tile size) |

### Simple KNN (Scale Initialization)

| File | Description |
|---|---|
| `simple-knn/simple_knn.h` / `.cu` | `SimpleKNN::knn()` — K-nearest-neighbor distances via Morton-code spatial sort |
| `simple-knn/spatial.h` / `.cu` | `distCUDA2()` — LibTorch-callable entry point wrapping `SimpleKNN::knn` |

### Fused SSIM (Differentiable Loss)

| File | Description |
|---|---|
| `fused-ssim/ssim.h` / `.cu` | `fusedssim()` and `fusedssim_backward()` — CUDA SSIM with separable Gaussian convolutions and analytic backward |

### LPIPS (Perceptual Quality Metric)

| File | Description |
|---|---|
| `lpips/lpipsPyTorch/__init__.py` | `lpips(x, y, net_type, version)` convenience function |
| `lpips/lpipsPyTorch/modules/lpips.py` | `LPIPS(nn.Module)` — multi-scale feature difference with linear calibration |
| `lpips/lpipsPyTorch/modules/networks.py` | `AlexNet`, `SqueezeNet`, `VGG16` backbone wrappers |
| `lpips/lpipsPyTorch/modules/utils.py` | Weight download and normalization utilities |
| `lpips/save_alex.py` / `save_vgg.py` | Offline scripts to export JIT-traced LPIPS models (`lpips_alex.pt`, `lpips_vgg.pt`) |
| `lpips/lpips_alex.pt` | Pre-exported JIT-traced AlexNet LPIPS model (loaded by `evaluateVisualQuality`) |

### Utility Headers

| File | Description |
|---|---|
| `eigen_utils.h` | Eigen-aligned STL containers and geometry helpers (Basalt, BSD-3) |
| `general_utils.h` | `inverse_sigmoid()` and `build_rotation()` (quaternion → rotation matrix on CUDA) (Photo-SLAM, GPL) |
| `loss_utils.h` | L1 loss, PSNR, SSIM, `FusedSSIMMap` autograd function (GPL) |
| `optim_utils.h` | `SparseGaussianAdam` custom optimizer with visibility-gated updates (GPL) |
| `tensor_utils.h` | cv::Mat ↔ torch::Tensor and Eigen ↔ torch::Tensor conversions (GPL) |
| `yaml_utils.h` | Tolerant YAML getters (`GetValue`, `GetValues`, `GetString`, `GetBool`) (Coco-LIC, GPL) |
| `tinyply.h` / `tinyply.cpp` | tinyply 2.3.4 — zero-dependency PLY reader/writer (public domain) |

---

## Key Classes and Functions

### `Params` (mapping.h)

Constructs from a `YAML::Node`. Holds all configuration: camera intrinsics (`fx`, `fy`, `cx`, `cy`, `width`, `height`), frame sampling (`select_every_k_frame`), depth completion (`depth_completion`, `patch_size`, `max_depth`, `engine_path`), Gaussian model hyperparameters (SH degree, learning rates, loss weights, exposure/skybox settings), and the Jetson memory cap (`max_gaussians`).

### `Dataset` (gaussian.h)

Accumulates frames from the ROS subscriber. `addFrame(Frame&)` decodes the RGB image, depth map, and pose; appends to the colored point cloud; on keyframes, optionally runs SPNet depth completion and extracts additional sample positions from completed depth; creates `Camera` objects for train (keyframes) or test (non-keyframes) sets.

### `GaussianModel` (gaussian.h)

The 3DGS map representation. Holds all learnable tensors on CUDA: `xyz_`, `features_dc_`, `features_rest_`, `scaling_`, `rotation_`, `opacity_`, `exposure_`. Key methods:
- `initialize()` — seeds the map from the LiDAR point cloud
- `trainingSetup()` — configures the sparse Adam optimizer
- `densificationPostfix()` — appends new Gaussians and migrates optimizer state
- `saveMap()` — exports to `point_cloud.ply` (excluding skybox)

### Free Functions (gaussian.h / gaussian.cpp)

- `extend(dataset, pc)` — incremental map extension from new keyframe
- `optimize(dataset, pc)` — gradient optimization over sampled training views
- `evaluateVisualQuality(dataset, pc, result_path, lpips_path)` — PSNR/SSIM/LPIPS evaluation and image export

### `DepthCompleter` (depth_completer.h)

Wraps a TensorRT engine for SPNet inference. Input: RGB (3ch) + sparse depth (1ch, scaled by 1/200) + validity mask (1ch). Output: dense depth (scaled back by 200). Synchronous `executeV2` inference.

### `render()` (rasterizer/renderer.h)

Top-level rendering function. Takes a camera viewpoint, Gaussian model, background color, and options. Returns a 6-tuple: rendered color, final transmittance, rendered depth, visibility mask, radii, and num_rendered. Used by `extend()` (alpha-only), `optimize()` (full render), and `evaluateVisualQuality()`.

---

## ROS Interface

### Subscribed Topics

| Topic | Type | Description |
|---|---|---|
| `/points_for_gs` | `sensor_msgs::PointCloud2` | Colored LiDAR point cloud (world frame) |
| `/pose_for_gs` | `geometry_msgs::PoseStamped` | Camera pose from Coco-LIC odometry |
| `/image_for_gs` | `sensor_msgs::Image` | RGB camera frame |
| `/depth_for_gs` | `sensor_msgs::Image` | Sparse/completed depth map |

### Parameters

| Param | Default | Description |
|---|---|---|
| `config_path` | (required) | Path to dataset YAML config |
| `result_path` | `<pkg>/result` | Output directory for map and renders |
| `lpips_path` | `<pkg>/src/lpips` | Path to LPIPS model directory |

### Output

All outputs are written to `result_path`:
- `point_cloud.ply` — final Gaussian map (standard 3DGS PLY format)
- `render/` — rendered RGB images (training + novel views)
- `render_depth/` — JET-colormapped rendered depth
- `gt/` — ground truth RGB images

Console output includes per-iteration timing (forward, backward, step, CPU→GPU) and final metrics (PSNR, SSIM, LPIPS for training and novel views).
