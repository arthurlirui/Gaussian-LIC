# iOS Module (ios/)

Gaussian-LIC 的 iOS 移植，运行在 iPhone 14 Pro 到 iPhone 18 Pro 上。

## 构建目标

| | `ios/` (GaussianLIC) |
|---|---|
| **平台** | iOS 27+ (iPhone Pro with LiDAR) |
| **构建系统** | Swift Package Manager (swift-tools 6.1, Swift 6) |
| **数据输入** | ARKit 实时采集 (RGB + LiDAR + IMU) |
| **传感器接口** | `SensorSource` protocol → `ARKitSensorSource` |
| **渲染** | RealityKit `GaussianSplatComponent` (原生 GS 渲染) |
| **训练** | msplat Metal 引擎 (端上) 或离线导出 |

## 模块架构

### 传感器层 (Sources/Sensors/)

- `ARKitSensorSource.swift` — 实现 `SensorSource` protocol，使用 `ARWorldTrackingConfiguration` + `.sceneDepth` 采集 RGB (YUV 420f)、LiDAR 深度 (Float32, 256×192)、置信度 (UInt8)、VIO 位姿 (`simd_float4x4`) 和相机内参。推送式回调模型（对应 `win_lic` 的拉取式 `nextFrame()`）。
- `IMURecorder.swift` — CoreMotion `CMMotionManager`，100 Hz 加速度计 + 陀螺仪，环形缓冲区保存 60 秒数据。
- `SensorFrame.swift` — 数据模型，对应 `win_lic::AlignedFrame`。使用 `CVPixelBuffer` 替代 `cv::Mat`（ARKit 原生类型，零拷贝到 Metal）。

### 采集层 (Sources/Capture/)

- `CaptureSession.swift` — 状态机：idle → previewing → recording → stopped。热状态监控自动暂停录制。
- `FrameRecorder.swift` — 磁盘写入，输出 `win_lic` DatasetReader 兼容格式（JPEG + Float32 深度 + TUM 轨迹 + IMU CSV）。
- `DatasetExporter.swift` — 数据集列表/验证/YAML 配置生成/zip 打包。

### 渲染层 (Sources/Rendering/)

- `SplatSceneManager.swift` — 管理 PLY 加载和 RealityKit Entity 生命周期。PLY → `PLYLoader` → `GaussianSplatResource.BufferResource` → `GaussianSplatComponent` → `Entity`。
- `SplatRealityView.swift` — `UIViewRepresentable` 包装 RealityKit `ARView`，支持 Free View（手势轨道相机）和 AR Live（ARKit 位姿驱动）两种模式。

### 训练层 (Sources/Training/)

- `OnDeviceTrainer.swift` — msplat Metal 端上训练管线：加载数据集 → LiDAR 反投影初始化点云 → 高斯初始化（RGB2SH + log-scale + identity rotation + logit(0.1)）→ 迭代优化（L1 + DSSIM loss + Adam）→ 内存受限致密化 → PLY 导出。内存安全：`os_proc_available_memory()` 检测 jetsam headroom，按设备 RAM 分级高斯上限。
- `OffDeviceTrainingBridge.swift` — 离线导出：生成 `win_lic` YAML 配置 + nerfstudio `transforms.json` + 数据集 zip 打包。

### UI 层 (Sources/UI/)

4 个 SwiftUI tab：
1. **CaptureView** — ARKit 实时预览 + 录制控制 + 深度可视化叠加
2. **RenderView** — PLY 文件选择 + RealityKit 渲染 + Free/AR 模式切换
3. **TrainingProgressView** — 端上/离线训练切换 + 实时进度 + 训练历史
4. **DeviceCapabilityView** — 设备硬件能力展示（型号/LiDAR/GPU/内存/高斯预算）

## 关键设计决策

### 为什么用 RealityKit GaussianSplatComponent 而非 MetalSplatter？

Apple 在 iOS 27 (WWDC26) 原生支持 `GaussianSplatComponent`，直接集成到 RealityKit 渲染管线中。这比第三方 MetalSplatter 更轻量（无额外依赖），自动处理 SH/scale/opacity 激活函数，与 ARKit 原生协作。代价是需要 iOS 27+，但目标设备（iPhone 14 Pro–18 Pro）均可升级。

### 为什么用 msplat 做端上训练？

msplat (github.com/rayanht/msplat, Apache 2.0) 是目前唯一成熟的 Metal 后端 3DGS 训练引擎，提供可微光栅化器 + Adam 优化器 + 致密化。学术验证（PocketGS, arXiv:2601.17354）表明 iPhone 15 上 500 迭代可在 4 分钟内完成，LPIPS 达 0.108。`apple_spatial_capture` Flutter 插件已验证 msplat 在 iPhone 上的可行性。

### 数据格式兼容性

iOS 采集的数据集与 `win_lic/sensors/dataset_reader.h::DatasetReader` 格式完全兼容，可直接用于 Mac/CUDA 服务器上的离线训练。训练生成的 PLY 文件是标准 3DGS 格式，可在任意 3DGS 查看器中打开。

## 依赖

| 库 | 许可证 | 用途 |
|---|---|---|
| msplat | Apache 2.0 | Metal GS 训练引擎 |
| RealityKit | Apple framework | GaussianSplatComponent 渲染 |
| ARKit | Apple framework | RGB/LiDAR/Depth/Pose 采集 |
| CoreMotion | Apple framework | IMU 加速度计/陀螺仪 |

> 之前使用的 MetalSplatter 子模块已移除，改用 RealityKit 原生 GS 支持。

## 参考

- [ios/README.md](../../ios/README.md) — 完整构建和使用说明
- [win_lic](win_lic.md) — 数据格式的来源
- Apple, "Rendering Gaussian splats with RealityKit" (WWDC26)
- msplat: github.com/rayanht/msplat
- PocketGS: arXiv:2601.17354
