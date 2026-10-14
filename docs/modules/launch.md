# Module Reference: `launch/` — ROS Launch Files

The `launch/` directory contains ROS launch files for starting the Gaussian-LIC mapping node, either standalone (per-dataset) or as part of the full Jetson pipeline.

---

## Files

### Per-Dataset Launch Files

| File | Config Used | Description |
|---|---|---|
| `fastlivo.launch` | `config/fastlivo.yaml` | FAST-LIVO dataset |
| `fastlivo2.launch` | `config/fastlivo2.yaml` | FAST-LIVO2 dataset |
| `m2dgr.launch` | `config/m2dgr.yaml` | M2DGR dataset |
| `mcd.launch` | `config/mcd.yaml` | MCD dataset |
| `r3live.launch` | `config/r3live.yaml` | R3LIVE dataset |

All five per-dataset launch files are structurally identical. Each:
- Launches a single ROS node: package `gaussian_lic`, node type `gs_mapping`, anonymized name `gs_mapping`
- Exposes a `config_path` arg defaulting to the matching config YAML
- Sets three private params: `config_path`, `result_path` → `<pkg>/result`, `lpips_path` → `<pkg>/src/lpips`
- Outputs to screen

The only difference between them is the default `config_path` value.

### `jetson_system.launch` — Full Jetson Pipeline

A comprehensive launch file (~77 lines) that starts the complete end-to-end pipeline on a Jetson Orin Nano:

1. **Livox LiDAR driver** — includes `livox_ros_driver2`'s launch file (default: `msg_MID360.launch`, overridable via `lidar_launch` arg)
2. **Coco-LIC odometry** — includes `cocolic/launch/odometry.launch` with configurable `cocolic_config` (default: `ct_odometry_fastlivo2.yaml`). This node publishes the four topics Gaussian-LIC consumes: `/points_for_gs`, `/pose_for_gs`, `/image_for_gs`, `/depth_for_gs`
3. **Gaussian-LIC map builder** — the `gs_mapping` node using `config/fastlivo2_jetson.yaml` by default (overridable via `gaussian_config`)
4. **Optional RViz** — disabled by default (`rviz` arg false) to save GPU memory on Jetson; when enabled, loads `jetson/jetson.rviz`

All sensor/odometry/Gaussian config paths are exposed as args for easy customization.

**Prerequisites:** All three packages (livox_ros_driver2, Coco-LIC, Gaussian-LIC) must be in one catkin workspace. Livox-SDK2 must be installed. The SPNet TensorRT engine must be built on-device.

---

## Usage

### Standalone (Desktop)

```bash
# Terminal 1: Coco-LIC odometry
cd ~/catkin_coco
source devel/setup.bash
roslaunch cocolic odometry.launch config_path:=config/ct_odometry_fastlivo2.yaml

# Terminal 2: Gaussian-LIC mapping
cd ~/catkin_gaussian
source devel/setup.bash
roslaunch gaussian_lic fastlivo2.launch
```

### Full Pipeline (Jetson)

```bash
cd ~/catkin_gaussian
source devel/setup.bash
roslaunch gaussian_lic jetson_system.launch
```

### With Custom Config

```bash
roslaunch gaussian_lic fastlivo2.launch config_path:=config/my_custom_config.yaml
```
