# Jetson Orin Nano 移植指南

本文档指导在 **Jetson Orin Nano (8GB)** 上完整部署 Gaussian-LIC2 系统，包括连接 Livox 激光雷达、IMU 和相机传感器，实现从传感器驱动到 3D Gaussian 建图的端到端管线。

> **原 x86 开发机完全不受影响** — 所有改动均通过 CMake 平台自动检测隔离。在 x86_64 上 `catkin_make` 行为与移植前一致。

---

## 1. 硬件清单

| 组件 | 型号 | 连接方式 |
|------|------|----------|
| 计算平台 | Jetson Orin Nano 8GB (Dev Kit) | — |
| 激光雷达 | Livox Mid-360 或 Avia | 以太网 (192.168.1.x) |
| 相机 | 任意 USB3 / MIPI CSI 全局快门相机 | USB / CSI |
| IMU | Mid-360 内置 IMU (200Hz) | 与雷达共用网线 |
| 存储 | NVMe SSD (≥128GB) | M.2 Key M |
| 电源 | DC 5V/4A (Dev Kit) | — |

> Orin Nano 8GB 共享 8GB LPDDR5 内存（CPU+GPU），是主要瓶颈。本指南的 Jetson 配置文件已针对此优化。

---

## 2. 系统刷写 (JetPack 5.1.x)

Orin Nano 推荐使用 **JetPack 5.1.1 / 5.1.2 / 5.1.3**（对应 L4T 35.3.x），理由：

- 自带 **Ubuntu 20.04** → 原生支持 **ROS 1 Noetic**（与原代码一致，无需 ROS 2 移植）
- CUDA 11.4、cuDNN 8.6、TensorRT 8.5.2 均由 JetPack apt 仓库直接安装
- PyTorch 有 NVIDIA 官方 aarch64 wheel（`torch-2.0.0+nv23.05`）

### 2.1 刷写

使用 NVIDIA SDK Manager 从 Ubuntu 20.04 主机刷写，或下载 SD Card 镜像：
```bash
# 在 Jetson 上确认版本
cat /etc/nv_tegra_release
# 应显示 R35 release (JetPack 5.1.x)

nvcc --version
# 应显示 CUDA 11.4

apt show nvidia-jetpack
# 应显示 5.1.x
```

### 2.2 安装 JetPack 组件

```bash
sudo apt update
sudo apt install -y nvidia-jetpack
```

### 2.3 配置电源模式

Orin Nano Dev Kit 默认 15W，建议切到最高功率模式（MAXN）：
```bash
sudo nvpmodel -m 0   # 0 = MAXN (15W)
sudo jetson_clocks   # 锁定最高频率
```

### 2.4 增加 Swap（编译时防 OOM）

8GB 内存编译 CUDA 代码可能不够，建议加 4GB swap：
```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## 3. 软件依赖安装

### 3.1 ROS 1 Noetic

```bash
sudo apt install -y ros-noetic-desktop-full
sudo apt install -y \
  ros-noetic-cv-bridge ros-noetic-image-transport \
  ros-noetic-pcl-conversions ros-noetic-pcl-ros \
  ros-noetic-tf ros-noetic-eigen-conversions \
  ros-noetic-geometry-msgs ros-noetic-sensor-msgs \
  ros-noetic-nav-msgs ros-noetic-std-msgs
echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### 3.2 基础库

```bash
sudo apt install -y \
  cmake build-essential git wget unzip \
  libyaml-cpp-dev libffi-dev \
  libeigen3-dev libpcl-dev \
  python3-dev python3-numpy python3-pip \
  libopencv-dev
```

> JetPack 的 `libopencv-dev` 已含 CUDA 支持，无需像 x86 那样从源码编译 OpenCV 4.7。

### 3.3 TensorRT

JetPack 已通过 `nvidia-jetpack` 安装 TensorRT。确认：
```bash
dpkg -l | grep tensorrt
# 应有 libnvinfer8, libnvinfer-dev, libnvonnxparsers8, libnvinfer-plugin8 等
which trtexec || ls /usr/src/tensorrt/bin/trtexec
```

### 3.4 LibTorch (C++ PyTorch)

Jetson 上没有官方 libtorch zip 包，需要从 NVIDIA 的 Jetson PyTorch wheel 中提取。使用本仓库提供的脚本：

```bash
cd ~/catkin_gaussian/src/Gaussian-LIC/jetson
chmod +x install_libtorch_jetson.sh
./install_libtorch_jetson.sh
# 安装到 ~/Software/libtorch
```

该脚本会：
1. 下载 `torch-2.0.0+nv23.05-cp38-cp38-linux_aarch64.whl`（匹配 JetPack 5.1 / CUDA 11.4）
2. 解包提取 `libtorch.so` 等库文件到 `~/Software/libtorch`
3. 生成 CMake 配置供 `find_package(Torch)` 使用

### 3.5 环境变量

每次编译和运行前 source 环境：
```bash
source ~/catkin_gaussian/src/Gaussian-LIC/jetson/jetson_env.sh
```

或加到 `~/.bashrc`（在 ROS source 之后）：
```bash
echo 'source ~/catkin_gaussian/src/Gaussian-LIC/jetson/jetson_env.sh' >> ~/.bashrc
```

---

## 4. 传感器驱动安装

### 4.1 Livox-SDK2

```bash
cd ~
git clone https://github.com/Livox-SDK/Livox-SDK2.git
cd Livox-SDK2
mkdir build && cd build
cmake .. && make -j4
sudo make install
```

### 4.2 livox_ros_driver2

放入与 Gaussian-LIC 相同的 catkin 工作空间：
```bash
cd ~/catkin_gaussian/src
git clone https://github.com/Livox-SDK/livox_ros_driver2.git
cd livox_ros_driver2
# ROS1 编译
./build.sh ROS1
```

### 4.3 配置雷达 IP

编辑雷达配置文件：
```bash
nano ~/catkin_gaussian/src/livox_ros_driver2/config/MID360_config.json
```

设置关键参数：
```json
{
  "host_net_info": {
    "cmd_data_port": 56100,
    "push_msg_port": 56101,
    "point_data_port": 56102,
    "imu_data_port": 56103,
    "host_ip": "192.168.1.50"     // ← Jetson 的 IP
  },
  "lidar_configs": [
    {
      "ip": "192.168.1.1XX",      // ← 雷达 IP (序列号后两位)
      ...
    }
  ]
}
```

配置 Jetson 网口静态 IP：
```bash
sudo nmcli con modify "Wired connection 1" \
  ipv4.addresses 192.168.1.50/24 ipv4.method manual
sudo nmcli con up "Wired connection 1"
ping 192.168.1.1XX   # 确认能 ping 通雷达
```

### 4.4 测试雷达驱动

```bash
roslaunch livox_ros_driver2 msg_MID360.launch
# 另一终端
rostopic hz /livox/lidar   # 应 ≈10 Hz
rostopic hz /livox/imu     # 应 ≈200 Hz
```

---

## 5. Coco-LIC 里程计安装

Coco-LIC 是 LiDAR-Inertial-Camera 里程计节点，负责处理原始传感器数据并发布 Gaussian-LIC 所需的四个话题。

```bash
cd ~/catkin_gaussian/src
git clone https://github.com/APRIL-ZJU/Coco-LIC.git
cd ~/catkin_gaussian
catkin_make -DCATKIN_WHITELIST_PACKAGES="cocolic"
```

> 如果使用 Mid-360 而非 Avia，需在 Coco-LIC 的配置中修改 lidar 类型和话题名。参考 Coco-LIC 仓库的 README。

---

## 6. 编译 Gaussian-LIC (Jetson)

### 6.1 编译

```bash
source /opt/ros/noetic/setup.bash
source ~/catkin_gaussian/src/Gaussian-LIC/jetson/jetson_env.sh

cd ~/catkin_gaussian
catkin_make -DCATKIN_WHITELIST_PACKAGES="gaussian_lic"
```

CMake 会自动检测 aarch64 并：
- 跳过 `-msse4.2`（x86-only）
- 设置 CUDA 架构为 `sm_87`（Orin）
- 使用 JetPack 系统路径（`/usr/local/cuda`, `/usr/lib/aarch64-linux-gnu`）

### 6.2 构建 SPNet TensorRT 引擎

TensorRT 引擎与架构绑定，**必须在 Jetson 上构建**（x86 构建的引擎无法加载）。

```bash
cd ~/catkin_gaussian/src/Gaussian-LIC/ckpt

# a. 安装 SPNet Python 环境（用于 ONNX 导出）
chmod +x setup_spnet.sh
./setup_spnet.sh
conda activate spnet   # 如果用 conda

# b. 下载 SPNet 权重 Large_300.pth 到 ckpt/ 目录
# (从 Google Drive 下载，如网络受限可用代理)

# c. 导出 ONNX
chmod +x export_onnx.sh
./export_onnx.sh

# d. 在 Jetson 上构建 TensorRT 引擎（FP16）
chmod +x build_trt_jetson.sh
./build_trt_jetson.sh
# 生成 spnet_512_640.engine 和 spnet_480_640.engine
```

---

## 7. 运行完整系统

### 7.1 一键启动

```bash
source ~/catkin_gaussian/devel/setup.bash
roslaunch gaussian_lic jetson_system.launch
```

该 launch 文件会依次启动：
1. `livox_ros_driver2` — 雷达驱动
2. `cocolic` — LIC 里程计
3. `gaussian_lic` — Gaussian 建图（使用 `fastlivo2_jetson.yaml` 配置）

### 7.2 分别启动（调试用）

```bash
# 终端 1: 雷达驱动
roslaunch livox_ros_driver2 msg_MID360.launch

# 终端 2: Coco-LIC 里程计
roslaunch cocolic odometry.launch config_path:=config/ct_odometry_fastlivo2.yaml

# 终端 3: Gaussian-LIC 建图
roslaunch gaussian_lic fastlivo2.launch config_path:=config/fastlivo2_jetson.yaml
```

### 7.3 使用 bag 数据回放

无需传感器，用预录数据测试：
```bash
# 终端 1: 回放 bag
rosbag play your_data.bag

# 终端 2: Coco-LIC
roslaunch cocolic odometry.launch config_path:=config/ct_odometry_fastlivo2.yaml

# 终端 3: Gaussian-LIC (Jetson 配置)
roslaunch gaussian_lic fastlivo2.launch config_path:=config/fastlivo2_jetson.yaml
```

---

## 8. Jetson 内存优化参数说明

Jetson 配置文件 `config/fastlivo2_jetson.yaml` 相比桌面版的关键调整：

| 参数 | 桌面 (x86) | Jetson | 说明 |
|------|-----------|--------|------|
| `sh_degree` | 3 | 2 | SH 阶数降低 → 每个高斯点少存 ~40% 系数 |
| `scaling_scale` | 1 | 2 | 初始尺度更大 → 总高斯数更少 |
| `select_every_k_frame` | 5 | 10 | 帧插入频率减半 |
| `skybox_points_num` | 0 | 0 | 不生成天空盒点 |
| `lambda_erank` | 0 | 0.01 | Taming-3DGS 正则化，限制高斯增长 |
| `max_gaussians` | 0 (无限) | 300000 | **硬性上限**，防止 OOM |

### 8.1 调整 `max_gaussians`

这是 Jetson 上最重要的安全参数。每个高斯点约占 200-300 字节 GPU 显存（取决于 SH 阶数），30 万个约需 60-90 MB 显存；但光栅化中间缓冲区和优化器状态会使实际占用翻数倍。

如果运行时出现 OOM：
```bash
# 降低上限
# 编辑 config/fastlivo2_jetson.yaml
max_gaussians: 150000   # 从 300000 降到 150000
```

如果效果不够好且内存有余量：
```bash
max_gaussians: 500000
sh_degree: 3            # 可恢复完整 SH
```

---

## 9. 性能调优

### 9.1 功率与散热

```bash
# 查看当前功率模式
sudo nvpmodel -q

# MAXN 模式（15W，最高性能）
sudo nvpmodel -m 0
sudo jetson_clocks

# 监控温度
watch -n 1 cat /sys/class/thermal/thermal_zone*/temp
```

> 长时间运行建议加主动散热风扇。

### 9.2 GPU 显存监控

```bash
# Jetson 不支持 nvidia-smi，用 tegrastats
sudo tegrastats --interval 1000
# 关注 RAM 和 GR3D_FREQ 行
```

### 9.3 关闭桌面环境释放内存

如果不需要图形界面：
```bash
sudo systemctl set-default multi-user.target
sudo reboot
# 恢复: sudo systemctl set-default graphical.target
```

可释放约 500MB-1GB 内存。

---

## 10. 故障排查

### 10.1 CUDA 架构不匹配

```
CUDA error: no kernel image is available for execution on the device
```

原因：CUDA 代码未编译为 sm_87。确认 CMake 输出包含：
```
[Gaussian-LIC] CUDA arch: sm_87
```

如果没看到，手动指定：
```bash
catkin_make --cmake-args -DGAUSSIAN_LIC_CUDA_ARCH=87
```

### 10.2 LibTorch 版本不匹配

```
undefined symbol: _ZN3c106Tensor...
```

原因：LibTorch 与 JetPack CUDA 版本不对应。确认 `install_libtorch_jetson.sh` 下载的 wheel 匹配你的 JetPack 版本。JetPack 5.1.x 对应 `torch-2.0.0+nv23.05`。

### 10.3 TensorRT 引擎加载失败

```
[TRT] ... engine was built with a different version of TensorRT
```

原因：引擎在其他设备/版本上构建。**必须在目标 Jetson 上重新运行 `build_trt_jetson.sh`**。

### 10.4 OOM (Out of Memory)

```
CUDA error: out of memory
```

措施（按优先级）：
1. 降低 `max_gaussians`（如 150000）
2. 降低 `sh_degree`（如 1）
3. 增大 `scaling_scale`（如 3）
4. 增大 `select_every_k_frame`（如 15）
5. 关闭桌面环境释放内存

### 10.5 编译 OOM

CUDA 编译消耗大量内存。如果 `catkin_make` 时 OOM：
```bash
# 限制并行数
catkin_make -j2

# 或用 swap（见 2.4 节）
```

---

## 11. 文件清单

移植新增/修改的文件：

```
Gaussian-LIC/
├── CMakeLists.txt                      # [修改] 平台自动检测 + 路径变量化
├── config/
│   └── fastlivo2_jetson.yaml           # [新增] Jetson 内存优化配置
├── launch/
│   └── jetson_system.launch            # [新增] 全系统一键启动
├── jetson/
│   ├── SETUP_JETSON.md                 # [新增] 本文档
│   ├── jetson_env.sh                   # [新增] 环境变量脚本
│   └── install_libtorch_jetson.sh      # [新增] LibTorch 提取脚本
├── ckpt/
│   └── build_trt_jetson.sh             # [新增] Jetson TensorRT 引擎构建
└── src/
    ├── mapping.h                        # [修改] 新增 max_gaussians 参数
    ├── gaussian.h                       # [修改] 新增 max_gaussians_ 成员
    └── gaussian.cpp                     # [修改] densification 中加入内存安全上限
```

---

## 12. x86 向后兼容性验证

在 x86 开发机上编译确认无影响：
```bash
cd ~/catkin_gaussian
catkin_make
# CMake 应输出: [Gaussian-LIC] aarch64 NOT detected — x86_64 build
# 行为与移植前完全一致: -msse4.2, 默认 CUDA arch, ~/Software 路径
```
