# WinLIC: Windows-Compatible Offline Multi-Modal Gaussian Splatting Framework

A standalone, ROS-free reconstruction of the Gaussian-LIC2 mapping pipeline that runs on **Windows (MSVC)** and **Linux (GCC)**. It fuses LiDAR point clouds, iToF depth, stereo vision, and IMU data to produce high-quality initialization point clouds and RGB data for 3D Gaussian Splatting reconstruction.

The original ROS-based code in `../src/` is preserved untouched. This directory contains a complete refactored version with no ROS dependencies.

---

## Architecture

```
win_lic/
├── main.cpp                 CLI entry point
├── CMakeLists.txt           Build system (no catkin)
├── config/default.yaml      Unified configuration
├── core/                    Pipeline orchestration + data types
│   ├── types.h              ROS-free sensor/frame structs
│   ├── params.h             YAML-driven parameters
│   ├── pipeline.h/.cpp      Main processing loop
│   └── data_aligner.h       Timestamp-based alignment
├── sensors/                 Pluggable sensor source layer
│   ├── isensor_source.h     Abstract ISensorSource interface
│   ├── dataset_reader.*     Offline file reader (TUM/KITTI/EuRoC)
│   ├── orbbec_source.*      Orbbec SDK live camera (compile-gated)
│   └── imu_io.*             IMU CSV reader + integration
├── depth/                   Multi-modal depth fusion
│   ├── depth_fusion.*       LiDAR + iToF + stereo → fused depth
│   ├── depth_completer.*    SPNet TensorRT depth completion
│   └── depth_completer_wrap.h
├── gaussians/               3D Gaussian Splatting model
│   ├── gaussian_model.*     Ported from src/gaussian.* (ROS removed)
│   └── camera.h             Camera intrinsics/pose (unchanged)
├── utils/                   Utility headers (copied from src/)
│   ├── eigen_utils.h, tensor_utils.h, general_utils.h
│   ├── loss_utils.h, optim_utils.h, yaml_utils.h
│   └── tinyply.h/.cpp
├── cuda/                    CUDA kernels (copied from src/)
│   ├── rasterizer/          Gaussian rasterizer (forward/backward/adam)
│   ├── simple-knn/          KNN for scale initialization
│   └── fused-ssim/          Fused SSIM loss
└── third_party/             Optional SDK stubs
```

## Key Differences from the Original

| Aspect | Original (src/) | WinLIC (win_lic/) |
|--------|-----------------|-------------------|
| OS | Linux only | Windows + Linux |
| Build | catkin/CMake | Pure CMake |
| Data I/O | ROS subscribers + cv_bridge + PCL | Direct file I/O (cv::imread, PLY reader) |
| Poses | geometry_msgs::PoseStamped | Eigen::Quaterniond + Vector3d from file |
| Sensor | ROS topics | ISensorSource plugin interface |
| Runtime | ros::spin() event loop | Sequential offline loop |
| POSIX | termios.h, unistd.h | Removed (portable) |

## Building

### Prerequisites

1. **CUDA Toolkit** 11.7+ (Windows or Linux)
2. **LibTorch** 2.0+ (matching CUDA version)
3. **OpenCV** 4.7+ (built with CUDA + opencv_contrib)
4. **TensorRT** 8.6+ (for SPNet depth completion)
5. **yaml-cpp** 0.6+
6. **CMake** 3.18+
7. **MSVC** 2019/2022 (Windows) or **GCC** 9+ (Linux)

### Windows (MSVC)

```powershell
cd win_lic
mkdir build && cd build
cmake -G "Visual Studio 17 2022" -A x64 ^
  -DTorch_DIR="C:/path/to/libtorch/share/cmake/Torch" ^
  -DOPENCV_DIR="C:/path/to/opencv/build" ^
  -DTENSORRT_ROOT="C:/Program Files/NVIDIA GPU Computing/TensorRT" ^
  ..
cmake --build . --config Release
```

### Linux (GCC)

```bash
cd win_lic
mkdir build && cd build
cmake -DTorch_DIR="$HOME/Software/libtorch/share/cmake/Torch" \
      -DOPENCV_DIR="$HOME/Software/opencv/opencv-4.7.0/build" \
      -DTENSORRT_ROOT="$HOME/Software/TensorRT-8.6.1.6" \
      ..
make -j$(nproc)
```

### With Orbbec SDK (optional)

```bash
cmake -DUSE_ORBBEC_SDK=ON -DOrbbecSDK_DIR="/path/to/orbbec_sdk" ..
```

## Usage

### Offline Data Processing

```bash
winlic --config config/default.yaml --result ./result --lpips ./lpips
```

### Dataset Directory Structure

```
data/scene1/
├── images/           000000.jpg, 000001.jpg, ...
├── depth/            000000.png (16-bit mm) or .exr (float metres)
├── pointclouds/      000000.ply, 000001.ply, ...
├── trajectory.txt    timestamp tx ty tz qx qy qz qw (TUM format)
└── imu.csv           timestamp,ax,ay,az,gx,gy,gz (optional)
```

### Pose Formats

- **TUM**: `timestamp tx ty tz qx qy qz qw`
- **KITTI**: `R[0:3] R[4:7] R[8:11]` (3×4 row-major, no timestamp)
- **EuRoC**: `timestamp_ns,px,py,pz,qw,qx,qy,qz` (CSV)

## Multi-Modal Depth Fusion

The framework fuses three depth sources:

1. **LiDAR** — sparse but highly accurate; projected from 3D point cloud via camera intrinsics. Treated as ground truth.
2. **iToF** — dense but noisy; confidence reduced near depth discontinuities (edge-based weighting).
3. **Stereo** — dense via Semi-Global Matching (SGM); confidence based on local texture variance.

Fusion strategy: confidence-weighted averaging with LiDAR override. The fused depth then feeds into the SPNet TensorRT engine for hole completion.

## Output

- `result/point_cloud.ply` — Final 3D Gaussian map (PLY format, compatible with 3DGS viewers)
- `result/render/` — Rendered images from training viewpoints
- `result/render_depth/` — Rendered depth maps (colour-mapped)
- `result/gt/` — Ground-truth images for comparison
- Console output: PSNR, SSIM, LPIPS metrics for training and novel views
