# GaussianLIC iOS

Gaussian Splatting 实时采集、端上训练与渲染平台，基于 MetalSplatter + MLX Swift。

## 概述

GaussianLIC iOS 将 Gaussian-LIC2 的多模态传感器采集与高斯泼溅（3DGS）重建管线移植到 iPhone Pro 平台。它利用 iPhone 14 Pro 到 iPhone 18 Pro 的 LiDAR、RGB 相机、深度传感器和 IMU 作为实时数据来源，在设备上完成从采集到训练到渲染的完整流程。

### 三层架构

| 层 | 模块 | 技术 |
|---|---|---|
| **传感器层** | ARKit RGB/LiDAR/Depth + CoreMotion IMU → 磁盘数据集 | ARKit `ARWorldTrackingConfiguration`, `.sceneDepth` |
| **渲染层** | PLY/SPZ/.splat → MetalSplatter `SplatRenderer` (Metal) → GPU 渲染 | MetalSplatter (MIT, iOS 18+) |
| **训练层** | 端上 MLX Swift 可微分渲染训练 或 离线 win_lic 导出 | MLX Swift (Apache 2.0) + 自定义 ManualAdam |

### 工作流程

```
Capture Tab          Train Tab              Render Tab
┌──────────┐    ┌──────────────────┐    ┌──────────────┐
│ ARKit    │    │ On-Device (MLX)  │    │ MetalSplatter │
│ RGB +    │───▶│ 500 iters        │───▶│ SplatRenderer │
│ LiDAR +  │    │ → splat.ply      │    │ Free/AR View  │
│ IMU      │    │                  │    └──────────────┘
└──────────┘    │ OR               │
                │ Offline Export   │
                │ → win_lic YAML   │
                │ → AirDrop to Mac │
                └──────────────────┘
```

## 构建要求

- **Xcode 16+** (iOS 18 SDK)
- **Swift 6.1** (swift-tools-version: 6.1)
- **iOS 18.0+** 部署目标 (MetalSplatter 的最低要求)
- **iPhone 14 Pro 或更高** (需要 LiDAR 扫描仪)
- 模拟器不支持 LiDAR / `sceneDepth`，必须在真机上测试

## 构建步骤

```bash
# 1. 克隆仓库（含子模块）
git clone --recursive https://github.com/arthurlirui/Gaussian-LIC.git
cd Gaussian-LIC

# 2. 如果已克隆但没有子模块
git submodule update --init --recursive

# 3. 在 Xcode 中打开
open ios/Package.swift
```

在 Xcode 中：
1. 选择目标设备为连接的 iPhone Pro
2. `Cmd+R` 构建并运行
3. 首次运行需要授予相机和运动权限

## 使用说明

### 1. 采集（Capture Tab）

1. 点击 **Start Preview** 启动 ARKit 预览
2. 手持 iPhone 环绕目标场景缓慢移动
3. 点击红色录制按钮开始采集（RGB + LiDAR 深度 + 置信度 + IMU + VIO 位姿）
4. 采集的数据以 `win_lic` DatasetReader 格式写入磁盘：
   ```
   Documents/datasets/dataset_YYYYMMDD_HHMMSS/
     images/000001.jpg         — RGB JPEG
     depth/000001.bin          — Float32 深度 (256×192)
     depth_conf/000001.bin     — UInt8 置信度
     trajectory.txt            — TUM 格式位姿
     imu.csv                   — IMU 数据
     intrinsics.txt            — 相机内参
     config.json               — 采集元数据
   ```

### 2. 训练（Train Tab）

**端上训练（MLX Swift）：**
1. 选择已采集的数据集
2. 选择迭代数（300/500/1000）
3. 点击 **Start On-Device Training**
4. MLX Swift 可微分渲染引擎在 iPhone 上运行优化：
   - 前向渲染 → L1 + SSIM + 深度 L1 损失
   - `valueAndGrad` 自动微分 → ManualAdam 更新（6 参数组，恒定学习率）
   - win_lic 风格的 extend 致密化（在 α<0.99 区域插入新高斯）
5. 训练完成后自动生成 `splat.ply` 并加载到渲染页

**离线导出：**
1. 选择已采集的数据集
2. 选择 **Offline Export**
3. 点击导出 — 生成 `win_lic` YAML 配置 + nerfstudio `transforms.json` + 数据集 zip 打包
4. 通过 AirDrop 传输到 Mac/CUDA 服务器进行训练

### 3. 渲染（Render Tab）

1. 点击右上角文件夹图标选择 `.ply` / `.splat` / `.spz` 文件
2. MetalSplatter 的 `AutodetectSceneReader` 自动识别格式 → `SplatChunk` → `SplatRenderer` GPU 渲染
3. **Free View** 模式：单指拖拽旋转、双指平移、捏合缩放
4. **AR Live** 模式：使用 ARKit 相机位姿实时对齐虚拟场景

## 训练参数（匹配 win_lic）

| 参数 | 值 | 说明 |
|------|-----|------|
| position_lr | 0.00016 | 位置学习率（恒定） |
| feature_dc_lr | 0.005 | SH DC 系数学习率 |
| feature_rest_lr | 0.00025 | SH rest 学习率 (feature_lr / 20) |
| opacity_lr | 0.05 | 不透明度学习率 |
| scaling_lr | 0.005 | 缩放学习率 |
| rotation_lr | 0.001 | 旋转学习率 |
| Adam betas | (0.9, 0.999) | Adam 一阶/二阶矩衰减 |
| Adam eps | 1e-15 | Adam epsilon |
| λ_dssim | 0.2 | SSIM 损失权重 |
| λ_depth | 0.005 | 深度 L1 损失权重 |
| scaling_scale | 1.0 | 初始尺度因子 |
| 致密化 | extend (α<0.99) | 仅追加，无 clone/split/prune |

## 设备支持

| 设备 | 标识符 | 芯片 | LiDAR | 建议高斯数 |
|------|--------|------|-------|-----------|
| iPhone 14 Pro | iPhone15,2 | A16 | ✅ | 200K |
| iPhone 14 Pro Max | iPhone15,3 | A16 | ✅ | 200K |
| iPhone 15 Pro | iPhone16,1 | A17 Pro | ✅ | 300K |
| iPhone 15 Pro Max | iPhone16,2 | A17 Pro | ✅ | 300K |
| iPhone 16 Pro | iPhone17,1 | A18 Pro | ✅ | 400K |
| iPhone 16 Pro Max | iPhone17,2 | A18 Pro | ✅ | 400K |
| iPhone 17 Pro | iPhone18,1 | A19 Pro | ✅ | 500K |
| iPhone 18 Pro | iPhone19,1 | A20 Pro | ✅ | 500K |

## 源码结构

```
ios/
├── App/
│   ├── GaussianLICApp.swift       — @main 入口, 4-tab SwiftUI app
│   └── Info.plist                 — 权限声明 (相机/运动/文件)
├── Package.swift                  — SwiftPM (iOS 18, MetalSplatter + MLX Swift)
├── Sources/
│   ├── Capture/
│   │   ├── CaptureSession.swift   — 采集状态机 (idle→preview→record→stop)
│   │   ├── DatasetExporter.swift  — 数据集导出/验证/YAML 生成/zip 打包
│   │   └── FrameRecorder.swift    — 磁盘写入 (JPEG/depth/conf/trajectory/IMU)
│   ├── Models/
│   │   ├── DeviceProfile.swift    — iPhone 14-18 Pro 硬件检测
│   │   ├── GaussianSplat.swift    — 单高斯参数模型 + LiDAR 反投影
│   │   └── TrainingRecord.swift   — 训练记录 + JSON 持久化
│   ├── Rendering/
│   │   ├── SplatRealityView.swift — MetalSplatter MTKView 渲染 (Free/AR 模式)
│   │   └── SplatSceneManager.swift— PLY/SPZ/.splat → SplatRenderer 管理
│   ├── Sensors/
│   │   ├── ARKitSensorSource.swift— ARKit RGB/LiDAR/Depth/Pose 采集
│   │   ├── IMURecorder.swift      — CoreMotion 加速度计+陀螺仪
│   │   └── SensorFrame.swift      — 数据模型 (AlignedFrame Swift 版)
│   ├── Training/
│   │   ├── MLXRasterizer.swift    — MLX 可微分 3DGS 前向渲染器 (RGB+深度)
│   │   ├── OnDeviceTrainer.swift  — MLX 端上训练管线 + ManualAdam 优化器
│   │   └── OffDeviceTrainingBridge.swift — 离线导出 + nerfstudio transforms.json
│   ├── UI/
│   │   ├── CaptureView.swift      — 采集 UI (AR 预览 + 录制控制)
│   │   ├── RenderView.swift       — 渲染 UI (PLY 选择器 + MetalSplatter)
│   │   ├── TrainingProgressView.swift — 训练 UI (端上/离线切换 + 进度)
│   │   └── DeviceCapabilityView.swift — 设备能力展示
│   └── Utilities/
│       ├── DepthVisualization.swift — 深度/置信度彩色可视化
│       ├── FileStorage.swift      — 沙盒文件管理
│       └── MetalHelpers.swift     — Metal 设备 + simd 矩阵工具
└── Tests/
    └── GaussianLICTests.swift     — 单元测试
```

## 第三方依赖

| 库 | 许可证 | 用途 |
|---|---|---|
| [MetalSplatter](https://github.com/scier/MetalSplatter) | MIT | Metal 后端 3DGS 渲染引擎（PLY/SPZ/.splat 加载 + SH0-SH3 光栅化） |
| [MLX Swift](https://github.com/ml-explore/mlx-swift) | Apache 2.0 | Apple Metal 加速数组框架（autograd 自动微分 + 端上训练） |

## 技术参考

- MetalSplatter: github.com/scier/MetalSplatter — Swift/Metal 3DGS 渲染器
- MLX Swift: github.com/ml-explore/mlx-swift — Apple Metal ML 框架
- MLX3D: github.com/Amirhossein-Razlighi/mlx3D — MLX 3DGS 训练参考
- PocketGS: arXiv:2601.17354 — 端上 3DGS 训练 (iPhone 15, 500 iters / 4 min)
- win_lic: Gaussian-LIC2 的 Windows 兼容离线分支（本项目的数据格式与训练参数来源）
