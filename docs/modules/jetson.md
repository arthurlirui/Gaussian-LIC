# Module Reference: `jetson/` — Jetson Orin Nano Porting Guide

The `jetson/` directory contains everything needed to deploy Gaussian-LIC2 on a Jetson Orin Nano 8GB development kit, from sensor drivers through 3D Gaussian mapping.

---

## Files

| File | Description |
|---|---|
| `SETUP_JETSON.md` | Complete Chinese-language porting guide (~478 lines, 12 sections) |
| `install_libtorch_jetson.sh` | Bootstrap script to create a LibTorch installation from the Jetson PyTorch wheel |
| `jetson_env.sh` | Environment setup script (to be `source`d before building/running) |

---

## `SETUP_JETSON.md` — Porting Guide

The guide covers the full deployment workflow in 12 sections:

1. **Hardware list** — Jetson Orin Nano 8GB, Livox Mid-360/Avia LiDAR (Ethernet), USB3/CSI global-shutter camera, Mid-360 built-in IMU (200 Hz), NVMe SSD ≥128 GB, DC 5V/4A. Notes the shared 8 GB CPU+GPU memory as the main bottleneck.

2. **System flashing (JetPack 5.1.x)** — Recommends JetPack 5.1.1/5.1.2/5.1.3 (L4T 35.3.x) because it bundles Ubuntu 20.04 (native ROS 1 Noetic), CUDA 11.4, cuDNN 8.6, TensorRT 8.5.2, and an official aarch64 PyTorch wheel. Covers SDK Manager flashing, version verification, `nvpmodel -m 0` + `jetson_clocks` for MAXN power mode, and 4 GB swap to avoid compile OOM.

3. **Software dependencies** — ROS Noetic desktop-full, base libs (cmake, yaml-cpp, eigen3, pcl, opencv, python3), TensorRT (preinstalled via JetPack), LibTorch (via `install_libtorch_jetson.sh`), environment variables (via `jetson_env.sh`).

4. **Sensor drivers** — Build Livox-SDK2 from source, clone `livox_ros_driver2` into the catkin workspace, configure the LiDAR IP in `MID360_config.json`, set the Jetson's static Ethernet IP (192.168.1.50), test with `rostopic hz` (~10 Hz lidar, ~200 Hz IMU).

5. **Coco-LIC odometry** — Clone `APRIL-ZJU/Coco-LIC`, `catkin_make` with whitelisting; notes Mid-360 vs Avia config differences.

6. **Compile Gaussian-LIC (Jetson)** — CMake auto-detects aarch64: skips `-msse4.2`, sets CUDA arch to `sm_87` (Orin), uses JetPack system paths. Build SPNet TensorRT engine on-device: `setup_spnet.sh` → download `Large_300.pth` → `export_onnx.sh` → `build_trt_jetson.sh` (FP16).

7. **Run the full system** — One-command `roslaunch gaussian_lic jetson_system.launch`; or launch the three nodes separately for debugging; or replay a rosbag.

8. **Memory-optimization parameter table** — Desktop vs Jetson comparison for 5 key parameters (see `config/fastlivo2_jetson.yaml`).

9. **Performance tuning** — Power/thermal management, GPU memory monitoring via `tegrastats` (no `nvidia-smi` on Jetson), disabling desktop environment to free 500 MB–1 GB.

10. **Troubleshooting** — CUDA arch mismatch (sm_87), LibTorch symbol mismatch, TensorRT engine version mismatch, runtime OOM mitigations, compile OOM (`-j2` or swap).

11. **File manifest** — Lists all added/modified files for the port.

12. **x86 backward compatibility** — Confirms desktop builds are unaffected.

---

## `install_libtorch_jetson.sh`

Since NVIDIA ships no official LibTorch zip for aarch64, this script bootstraps one from the Jetson PyTorch pip wheel:

1. Downloads `torch-2.0.0+nv23.05-cp38-cp38-linux_aarch64.whl` (matched to JetPack 5.1.x / CUDA 11.4)
2. Treats the `.whl` as a zip and extracts the `torch/` tree
3. Copies `torch/` to `~/Software/libtorch`, dereferences and copies all `*.so*`/`*.a*` libs to `~/Software/libtorch/lib/`
4. Replicates the CMake config layout at `~/Software/libtorch/share/cmake/`
5. Prints usage: `cmake .. -DTorch_DIR=~/Software/libtorch/share/cmake/Torch` and the runtime `LD_LIBRARY_PATH` export

Uses `set -e` and cleans up its temp dir on exit.

---

## `jetson_env.sh`

A script to be `source`d (not executed) before building or running:

```bash
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
export Torch_DIR=~/Software/libtorch/share/cmake/Torch
export LD_LIBRARY_PATH=~/Software/libtorch/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128
```

The `PYTORCH_CUDA_ALLOC_CONF` setting reduces CUDA allocator fragmentation on the shared 8 GB memory.

---

## CMake Auto-Detection

The root `CMakeLists.txt` automatically detects the platform:

```cmake
if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
  set(JETSON ON)
  set(GAUSSIAN_LIC_CUDA_ARCH "87")  # sm_87 = Orin
  # Uses system paths for OpenCV, TensorRT, CUDA
else()
  set(JETSON OFF)
  # Uses ~/Software/... paths, default nvcc arch
endif()
```

This means the same `CMakeLists.txt` works on both x86 and Jetson without manual configuration — just `source jetson_env.sh` first on Jetson.
