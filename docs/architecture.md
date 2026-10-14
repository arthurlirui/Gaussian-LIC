# Architecture Overview

This document describes the system-level architecture of Gaussian-LIC2, the data flow between modules, and the design decisions that shape the codebase.

---

## 1. Project Vision

Gaussian-LIC2 is a **real-time, photo-realistic SLAM system** that fuses LiDAR, inertial (IMU), and camera data to simultaneously estimate poses and build a 3D Gaussian Splatting map. It extends the original [Gaussian-LIC](https://arxiv.org/pdf/2404.06926) (ICRA 2025) with depth completion, incremental map extension, sparse-Adam optimization, and cross-platform deployment support.

**Published as:** Gaussian-LIC2, IJRR 2026.

---

## 2. Two Build Targets

The repository contains two parallel executables that share the same algorithmic core (CUDA rasterizer, Gaussian model, optimizer) but differ in their I/O and platform layer:

| | `src/` (gs_mapping) | `win_lic/` (winlic) |
|---|---|---|
| **Platform** | Linux (Ubuntu 20.04), x86 + Jetson | Windows (MSVC) and Linux |
| **Build system** | catkin / CMake (ROS Noetic) | Pure CMake (no ROS) |
| **Data input** | Live ROS topics from Coco-LIC odometry | Offline files (TUM/KITTI/EuRoC) or live Orbbec camera |
| **Sensor interface** | `sensor_msgs` (PointCloud2, Image, PoseStamped) | `ISensorSource` abstract interface |
| **Depth fusion** | SPNet depth completion only | Multi-modal fusion (LiDAR + iToF + stereo) + SPNet |
| **Runtime model** | Real-time streaming (multi-threaded ROS spin) | Sequential offline pipeline |
| **Use case** | Online SLAM with a LiDAR-inertial-camera rig | Offline reconstruction, Windows development, multi-modal research |

Both targets compile against the same CUDA kernels (rasterizer forward/backward, fused SSIM, simple-KNN, sparse Adam) — these are duplicated across `src/` and `win_lic/cuda/` to keep each target self-contained.

---

## 3. System Data Flow (ROS Pipeline)

```
┌─────────────────────┐
│   Physical Sensors   │
│  (LiDAR, IMU, Cam)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Livox ROS Driver   │
│  (raw point clouds)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐         ┌──────────────────────┐
│     Coco-LIC Odom    │────────▶│   Gaussian-LIC Node   │
│  (LIO pose estimate)  │  ROS    │   (gs_mapping)        │
│                       │  topics │                        │
│  Publishes:           │         │  Subscribes:           │
│  /points_for_gs       │────────▶│  /points_for_gs       │
│  /pose_for_gs         │────────▶│  /pose_for_gs         │
│  /image_for_gs        │────────▶│  /image_for_gs        │
│  /depth_for_gs        │────────▶│  /depth_for_gs        │
└──────────────────────┘         └───────────┬───────────┘
                                              │
                                              ▼
                                    ┌──────────────────────┐
                                    │  Mapping Pipeline     │
                                    │                        │
                                    │  1. Timestamp align    │
                                    │  2. addFrame           │
                                    │  3. Depth completion   │
                                    │     (SPNet/TensorRT)   │
                                    │  4. Keyframe?          │
                                    │     ├─ Y: init/extend  │
                                    │     └─ N: test camera  │
                                    │  5. optimize (100 it)  │
                                    │  6. Evaluate + save    │
                                    └──────────┬─────────────┘
                                               │
                                               ▼
                                    ┌──────────────────────┐
                                    │  result/               │
                                    │  ├── point_cloud.ply  │
                                    │  ├── render/          │
                                    │  ├── render_depth/    │
                                    │  └── gt/              │
                                    └──────────────────────┘
```

### ROS Topic Synchronization

The `mapping.cpp` node uses a timestamp-based alignment strategy (not exact-time sync). The LiDAR point cloud timestamp is the anchor; pose/image/depth messages within ±10 ms are matched. Four separate subscriber callbacks push messages into thread-safe queues; a background `mapping()` thread pops aligned data for processing.

### Watchdog Shutdown

A monitor thread detects when the upstream data stream has ended (no point messages for 5 seconds after initialization) and triggers a graceful shutdown — running final evaluation and saving the map.

---

## 4. System Data Flow (WinLIC Offline Pipeline)

```
┌─────────────────────┐
│   ISensorSource      │
│   (abstract)          │
│                       │
│  ┌─ DatasetReader    │  ← offline files (images, depth, PLY, poses)
│  └─ OrbbecSource     │  ← live Orbbec camera (iToF + RGB + IR)
└──────────┬──────────┘
           │ AlignedFrame
           ▼
┌─────────────────────┐
│   DepthFusion         │
│                       │
│  LiDAR depth (proj)   │
│  + iToF depth         │
│  + Stereo depth (SGBM)│
│  → Confidence-weighted│
│    fused depth        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Pipeline.run()      │
│                       │
│  for each frame:      │
│    1. Project LiDAR   │
│    2. Fuse depths     │
│    3. Dataset.addFrame│
│       (SPNet complete)│
│    4. Keyframe?       │
│       ├─ Y: init/extend│
│       └─ N: skip      │
│    5. optimize        │
│  finalize:            │
│    evaluate + save    │
└──────────┬──────────┘
           │
           ▼
    result/ (same as ROS)
```

---

## 5. Core Algorithm: Incremental Gaussian Splatting SLAM

The heart of both pipelines is a streaming, incremental 3D Gaussian Splatting mapper. The algorithm has five stages:

### 5.1 Map Initialization (First Keyframe)

On the first keyframe, the Gaussian map is seeded from the accumulated LiDAR point cloud:
- Each LiDAR point becomes a Gaussian with position = point, SH DC color = RGB2SH(point color), scale = `log(scaling_scale × depth / focal)` (depth-proportional initial footprint), rotation = identity, opacity = 0.1.
- Optionally, skybox points are placed on a sphere for outdoor scenes.

### 5.2 Depth Completion (SPNet via TensorRT)

Sparse LiDAR depth is completed to dense depth using SPNet — a ConvNeXt-style encoder-decoder deployed as a TensorRT FP16 engine:
- Input: RGB image + sparse depth + validity mask
- Output: dense metric depth
- Purpose: identify new Gaussian sample positions in texture-less regions where LiDAR has no returns

The `selectFromDepthCompletion` helper partitions the image into grid cells and picks one new sample per cell where the original depth had no data, ensuring spatially uniform densification.

### 5.3 Map Extension (Subsequent Keyframes)

For each new keyframe, `extend()`:
1. Renders the current map from the keyframe viewpoint (color-suppressed, alpha-only pass).
2. Projects new LiDAR points to pixels, deduplicates by pixel (keep nearest depth).
3. Filters to visible, in-image, under-reconstructed regions (`rendered_alpha < 0.99`).
4. Creates new Gaussians and appends them via `densificationPostfix`, which migrates the sparse-Adam optimizer state to include the new parameters.

### 5.4 Map Optimization

`optimize()` runs a fixed number of gradient steps (default 100) per keyframe:
- Samples up to 100 training views (random subset; with trajectory-length-based decay for large-scale scenes).
- Per view: renders image + depth, computes loss = `(1-λ_dssim)·L1 + λ_dssim·(1-SSIM) + λ_depth·L1_depth`.
- Backward pass uses a **per-Gaussian bucketed backward** (StopThePop-style) with forward-pass transmittance checkpoints for efficient gradient computation.
- **Sparse Adam**: only Gaussians visible in the current render are updated — the visibility mask comes from the rasterizer's radii buffer. This is critical for scaling to large maps without wasting computation on invisible Gaussians.

### 5.5 Evaluation and Export

At shutdown:
- Renders all training and test (novel-view) cameras.
- Computes PSNR, SSIM (fused CUDA kernel), and LPIPS (JIT-traced AlexNet).
- Saves rendered RGB, GT RGB, and JET-colormapped depth images.
- Exports the final map to `point_cloud.ply` (standard 3DGS PLY format, excluding skybox).

---

## 6. Modified 3DGS Rasterizer

The CUDA rasterizer in `src/rasterizer/` (and `win_lic/cuda/rasterizer/`) is a heavily modified version of the original 3DGS rasterizer with several key extensions:

| Extension | Purpose |
|---|---|
| **Tile-based opacity culling** | Skips tiles where a Gaussian's max contribution power is below threshold — reduces overdraw |
| **Asymmetric FOV NDC clamping** | Supports non-square images and off-center principal points via `limx/limy` limits |
| **Depth rendering + depth loss** | Rasterizes per-pixel depth for the depth-supervised loss term |
| **Erank regularization** | Penalizes extreme anisotropy via an effective-rank loss on scale components |
| **Per-Gaussian bucketed backward** | Checkpoints transmittance every 32 Gaussians during forward; backward computes per-Gaussian gradients in one pass (vs. per-pixel in original 3DGS) |
| **`no_color` fast path** | Skip SH evaluation for visibility-only passes (used in `extend()`) |

---

## 7. SPNet Depth Completion Model

SPNet is a self-supervised depth completion network that fills sparse LiDAR depth using RGB guidance. It is trained separately (under `ckpt/SPNet/`) and deployed via TensorRT for real-time inference.

- **Architecture**: ConvNeXt-style hierarchical encoder-decoder with custom "SP-Normalization" (CNX: `conv(norm(x)) × x`)
- **Sizes**: Tiny, Small, Base, Large (default: Large, 300 epochs)
- **Deployment**: PyTorch → ONNX (opset 17, dynamic axes) → TensorRT FP16 engine
- **Inference resolutions**: 512×640 and 480×640 (separate engines)

See [modules/ckpt.md](modules/ckpt.md) for details.

---

## 8. Platform Adaptation: Jetson Orin Nano

The project supports deployment on Jetson Orin Nano 8GB (shared CPU+GPU memory). Key adaptations:

- **CMake auto-detection**: `aarch64` triggers Jetson build profile (sm_87 CUDA arch, no `-msse4.2`, system library paths)
- **Memory safety**: `max_gaussians` config cap (default 300K on Jetson vs. unlimited on desktop), reduced SH degree (2 vs. 3), larger keyframe stride (10 vs. 5)
- **LibTorch bootstrap**: `install_libtorch_jetson.sh` extracts the C++ frontend from NVIDIA's Jetson PyTorch wheel
- **End-to-end launch**: `jetson_system.launch` starts Livox driver + Coco-LIC + Gaussian-LIC in one command

See [modules/jetson.md](modules/jetson.md) for the full porting guide.

---

## 9. Build System

### Root CMakeLists.txt (ROS/catkin)

```
catkin_make  →  gs_mapping executable
                 links: catkin, OpenCV, LibTorch, yaml-cpp, CUDA, TensorRT
```

### win_lic/CMakeLists.txt (Pure CMake)

```
cmake --build  →  winlic executable
                  links: OpenCV, LibTorch, yaml-cpp, CUDA, TensorRT
                  optional: OrbbecSDK (USE_ORBBEC_SDK)
```

Both use platform-conditional logic (x86 vs. aarch64) for CUDA architecture, compiler flags, and library paths.

---

## 10. Third-Party Dependencies

| Dependency | Version | Purpose |
|---|---|---|
| CUDA | 11.7 (x86) / 11.4 (Jetson) | GPU compute |
| LibTorch | 2.0.1 (x86) / 2.0.0 (Jetson) | PyTorch C++ frontend |
| TensorRT | 8.6.1 (x86) / 8.5.2 (Jetson) | SPNet inference |
| OpenCV | 4.7.0 (built with CUDA + contrib) | Image I/O, stereo SGBM |
| yaml-cpp | ≥0.5 | Config parsing |
| ROS Noetic | (src/ only) | catkin, message types |
| Eigen3 | (system) | Linear algebra |
| PCL | (src/ only) | Point cloud I/O |
| OrbbecSDK v2 | (win_lic/, optional) | Live Orbbec camera |
| MetalSplatter | (submodule) | Metal-based 3DGS viewer (macOS/iOS) |

---

## 11. Design Decisions and Rationale

### Why duplicate CUDA kernels across `src/` and `win_lic/`?

Each build target is self-contained — you can build `win_lic/` on Windows without the ROS-dependent `src/`. The algorithmic kernels are identical; only the I/O layer differs. This avoids forcing a Windows developer to install ROS.

### Why a custom sparse Adam optimizer?

Standard PyTorch Adam updates all parameters every step. In incremental SLAM, most Gaussians are not visible in the current frame. The custom `SparseGaussianAdam` uses a visibility mask (from the rasterizer's radii buffer) to skip invisible Gaussians, reducing per-step GPU work from O(total Gaussians) to O(visible Gaussians).

### Why depth-proportional initial Gaussian scale?

LiDAR points carry depth information. Setting each Gaussian's initial scale to `log(scaling_scale × depth / focal)` makes its 2D footprint proportional to the pixel area it covers — larger for distant points, smaller for near points. This gives a better visual starting point than a fixed scale.

### Why timestamp-based alignment instead of exact-time sync?

The upstream odometry (Coco-LIC) publishes at its own rate. Exact-time message filters would drop messages when any topic has timing jitter. The ±10 ms window approach is more robust and matches the real-time requirements.

### Why per-Gaussian bucketed backward?

The original 3DGS backward pass iterates per-pixel, re-traversing all Gaussians per pixel. The bucketed approach (from StopThePop) groups 32 consecutive Gaussians per bucket and computes each Gaussian's gradient across all pixels it touches in one warp-cooperative pass. This reduces redundant computation and improves memory access patterns.
