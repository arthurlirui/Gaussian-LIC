# Module Reference: `win_lic/` — Windows-Compatible Offline Framework

WinLIC is a standalone, ROS-free reconstruction of the Gaussian-LIC2 mapping pipeline. It replaces the ROS-based I/O layer with a pure CMake build and a pluggable sensor-source abstraction, enabling offline reconstruction on Windows (MSVC) and Linux. The algorithmic core (rasterizer, Gaussian model, optimizer, SSIM, KNN) is preserved verbatim from `src/`.

**Build target:** `winlic` executable (via `win_lic/CMakeLists.txt`)
**Language:** C++17, CUDA, LibTorch C++ frontend
**Dependencies:** OpenCV 4, LibTorch, yaml-cpp, CUDA, TensorRT; optional OrbbecSDK v2

---

## File Inventory

### Top-Level

| File | Description |
|---|---|
| `main.cpp` | CLI entry point — parses `--config`, `--result`, `--lpips` flags; creates sensor source, pipeline, and runs it |
| `CMakeLists.txt` | Pure CMake build (no catkin). Cross-compiler (MSVC/GCC), cross-platform (x86/aarch64). Optional OrbbecSDK |
| `README.md` | Architecture description, build prerequisites, usage, dataset layout, pose formats, depth fusion strategy |
| `config/default.yaml` | Unified configuration: dataset, camera, frame selection, depth completion, depth fusion, Gaussian model params |

### `core/` — Pipeline Orchestration

| File | Description |
|---|---|
| `types.h` | ROS-free sensor/frame structs: `PointXYZRGB`, `ImuMeasurement`, `CameraPose`, `DepthSource` enum, `AlignedFrame` (the central self-contained frame), `DepthFusionConfig` |
| `params.h` | `winlic::Params` class — YAML-driven config holder (replaces the ROS `Params` from `src/mapping.h`) |
| `pipeline.h` / `pipeline.cpp` | `winlic::Pipeline` — sequential processing loop: `run()` → `processFrame()` per frame → `finalize()`. Replaces ROS `spin()` |
| `data_aligner.h` | `winlic::DataAligner` — thread-safe timestamp-based multi-modal synchronization (optional; mainly for live streaming) |

### `sensors/` — Pluggable Sensor Source Layer

| File | Description |
|---|---|
| `isensor_source.h` / `.cpp` | `ISensorSource` abstract interface (`open` → `hasNext` → `nextFrame` → `close`) + `createSensorSource()` factory |
| `dataset_reader.h` / `.cpp` | `DatasetReader` — offline file reader supporting TUM, KITTI, and EuRoC pose formats; reads images, depth (.exr/.png), PLY clouds |
| `orbbec_source.h` / `.cpp` | `OrbbecSource` — live Orbbec camera (iToF depth + RGB + IR). Compile-gated by `USE_ORBBEC_SDK`; stub mode by default |
| `imu_io.h` / `.cpp` | `ImuReader` — IMU CSV reader and trapezoidal velocity integration |

### `depth/` — Multi-Modal Depth Fusion

| File | Description |
|---|---|
| `depth_fusion.h` / `.cpp` | `winlic::DepthFusion` — confidence-weighted fusion of LiDAR (1.0), iToF (0.6), and stereo (0.5) depth; LiDAR overwrites as ground truth. Also: `projectLidarDepth()`, `computeStereoDepth()` (StereoSGBM), `computeConfidence()` |
| `depth_completer.h` / `.cpp` | `DepthCompleter` — SPNet TensorRT wrapper (identical to `src/depth_completer`) |
| `depth_completer_wrap.h` | `winlic::DepthCompleterWrapper` — thin namespace adapter |

### `gaussians/` — 3D Gaussian Splatting Model

| File | Description |
|---|---|
| `gaussian_model.h` / `.cpp` | `Dataset` + `GaussianModel` + free functions (`extend`, `optimize`, `evaluateVisualQuality`) — ported from `src/gaussian.h/.cpp` with ROS deps removed |
| `camera.h` | `Camera` class — identical to `src/camera.h` |

### `cuda/` — CUDA Kernels (copied from `src/`)

| Subdirectory | Contents |
|---|---|
| `cuda/rasterizer/` | Full rasterizer pipeline (forward, backward, adam, config, auxiliary) — identical to `src/rasterizer/` |
| `cuda/simple-knn/` | KNN for scale initialization — identical to `src/simple-knn/` |
| `cuda/fused-ssim/` | Fused differentiable SSIM — identical to `src/fused-ssim/` |

### `utils/` — Utility Headers (ported from `src/`)

| File | Source |
|---|---|
| `eigen_utils.h` | From Basalt (BSD-3) |
| `general_utils.h` | From Photo-SLAM (GPL) |
| `loss_utils.h` | From Gaussian-LIC (GPL) |
| `optim_utils.h` | From Gaussian-LIC (GPL) |
| `tensor_utils.h` | From Gaussian-LIC (GPL) |
| `yaml_utils.h` | From Coco-LIC (GPL) |
| `tinyply.h` / `tinyply.cpp` | Public domain |

---

## Key Design Differences from `src/`

| Aspect | `src/` (ROS) | `win_lic/` (Offline) |
|---|---|---|
| Build | catkin / CMake | Pure CMake |
| Data input | Live ROS topics | Files or Orbbec SDK |
| Sensor interface | `sensor_msgs` | `ISensorSource` abstract class |
| Frame struct | `Frame` (ROS message pointers) | `AlignedFrame` (self-contained cv::Mat, vectors, Eigen) |
| Pose format | `geometry_msgs::PoseStamped` | TUM / KITTI / EuRoC file formats |
| Depth fusion | SPNet only | Multi-modal (LiDAR + iToF + stereo) + SPNet |
| Runtime | Multi-threaded ROS spin | Sequential `Pipeline::run()` loop |
| Platform | Linux only | Windows + Linux |
| POSIX deps | `termios.h`, `unistd.h` | None |

---

## Data Flow

```
CLI args → Params (from YAML)
         → createSensorSource(config)
              ├─ "offline" → DatasetReader
              └─ "orbbec"  → OrbbecSource
         → Pipeline(params, result, lpips)
              run(source):
                while source.hasNext():
                  frame = source.nextFrame()
                  processFrame(frame):
                    1. projectLidarDepth (if needed)
                    2. DepthFusion::fuse (LiDAR + iToF + stereo)
                    3. Dataset::addFrame (SPNet depth completion)
                    4. Keyframe? → initialize | extend
                    5. optimize (100 iterations)
                finalize():
                    evaluateVisualQuality + saveMap
```

---

## Configuration (`config/default.yaml`)

The config has six sections:
1. **`dataset`** — type (`offline`/`orbbec`), base path, subdirectories, pose file, pose format
2. **`camera`** — intrinsics (default 640×512)
3. **Frame selection** — `select_every_k_frame: 5`, depth completion settings
4. **`depth_fusion`** — `enable_itof`, `enable_stereo`, baseline, confidence thresholds
5. **Gaussian model** — SH degree, learning rates, loss weights, exposure/skybox
6. **Memory safety** — `max_gaussians: 0` (unlimited by default)

---

## Pose Format Support

| Format | File layout | Timestamp |
|---|---|---|
| **TUM** | `ts tx ty tz qx qy qz qw` (space-delimited) | Per-line float (seconds) |
| **KITTI** | 3×4 row-major `[R\|t]` (12 numbers per line) | None (uses line index) |
| **EuRoC** | CSV: `ts_ns,px,py,pz,qw,qx,qy,qz` | Nanoseconds → seconds |

---

## Output

Same as `src/`: `point_cloud.ply`, `render/`, `render_depth/`, `gt/`, plus console metrics (PSNR/SSIM/LPIPS for training and novel views).
