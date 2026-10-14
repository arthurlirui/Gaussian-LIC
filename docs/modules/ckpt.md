# Module Reference: `ckpt/` — SPNet Depth Completion Model

The `ckpt/` directory contains the SPNet depth-completion network: its Python training/testing source code and the deployment scripts for exporting to ONNX and building TensorRT engines for real-time inference.

**What SPNet does:** Takes an RGB image, a sparse depth map, and a validity mask, and predicts a dense depth map. It fills in missing depth samples — from dense-but-noisy inputs down to pure monocular depth estimation (no input depth).

---

## Directory Structure

```
ckpt/
├── SPNet/                      # Python training/testing source
│   ├── config.py               # Hyperparameters and model configs
│   ├── train.py                # DDP training entry point
│   ├── test.py                 # Inference/benchmark entry point
│   ├── test_utils.py           # Test data reader and metrics
│   └── src/
│       ├── _init_.py           # Package marker
│       ├── networks.py         # V2Net — top-level network
│       ├── modules.py          # Encoder and Decoder
│       ├── custom_blocks.py    # CNBlock, NormLayer, GRN, LayerNorm
│       ├── losses.py           # WeightedDataLoss, WeightedMSGradLoss
│       ├── data_tools.py       # Dataset, augmentation, dataloader
│       ├── utils.py            # StandardizeData, DDP utils, visualization
│       └── src_main.py         # SPNet trainer class
├── setup_spnet.sh              # Conda env setup (Python 3.8, PyTorch 2.0.1)
├── export_onnx.sh              # Runs both ONNX export scripts
├── export_onnx_512_640.py      # Export ONNX at 512×640
├── export_onnx_480_640.py      # Export ONNX at 480×640
├── build_trt.sh                # Build TensorRT FP16 engines (x86/Linux)
└── build_trt_jetson.sh         # Build TensorRT FP16 engines (Jetson/aarch64)
```

---

## Python Source (`SPNet/`)

### Architecture: V2Net (`src/networks.py`)

A ConvNeXt-style hierarchical encoder-decoder:
- **Input**: 5 channels (RGB 3 + raw depth 1 + hole mask 1)
- **Encoder** (`src/modules.py`): stem 3×3 conv → 5 stride-2 downsample stages → `CNBlock` residual blocks at 4 resolution levels → 6 feature maps for skip connections
- **Decoder**: 5 ConvTranspose2d upsampling stages with 1×1 skip-connection fusion → 3 `CNBlock` refinement stages → 3×3 conv head → 1-channel depth output

### Building Blocks (`src/custom_blocks.py`)

| Block | Description |
|---|---|
| `LayerNorm` | Channels-first LayerNorm over channel dimension |
| `NormLayer` | Dispatcher for SP-Norm family: LN, BN, IN, RZ (ReZero), **CNX** (default: `conv(norm(x)) × x`), CN+X, GRN, NX, CX |
| `CNBlock` | ConvNeXt residual block: 7×7 depthwise conv → NormLayer → 1×1 expand 4× → ReLU → optional GRN → 1×1 project; with stochastic depth drop-path |
| `GRN` | Global Response Normalization (L2 norm over spatial dims, scaled by learnable γ/β) |

### Model Sizes (`config.py`)

| Type | Dims | Depths | Drop-path rate |
|---|---|---|---|
| Tiny | [96, 192, 384, 768] | [3, 3, 9, 3] | 0.1 |
| Small | [96, 192, 384, 768] | [3, 3, 27, 3] | 0.2 |
| Base | [128, 256, 512, 1024] | [3, 3, 27, 3] | 0.2 |
| **Large** (default) | [192, 384, 768, 1536] | [3, 3, 27, 3] | 0.2 |

### Training (`src/src_main.py`, `train.py`)

- **Optimizer**: AdamW (lr 2e-4, weight decay 0.05)
- **Scheduler**: Cosine with 5% warmup, 300 epochs
- **Loss**: absolute-domain hole-weighted L1 + relative-domain (standardized) hole-weighted L1 + 0.5 × multi-scale Sobel-gradient L1
- **Data augmentation** (`src/data_tools.py`): joint RGBD random resized crop, random depth scaling, random flips, color jitter; `trans_raw` synthesizes sparse/noisy "raw" input from ground truth at varying sparsity levels (10%, 1%, 0.1%, or pure depth estimation)
- **Distributed**: DDP over NCCL (2 GPUs default, port 6003)
- **Checkpoint**: saves `{model_type}_epoch_{N}.pth` every `checkpoint_epoch` epochs

### Testing (`test.py`, `test_utils.py`)

- Loads a checkpoint into `V2Net` (Large by default)
- Evaluates at three sparsity levels: 10%, 1%, 0.1% raw depth
- Metrics: RMSE and REL, averaged across all three sparsity levels
- Optionally saves predicted depth as int32 PNGs (scaled by 65535)

---

## Deployment Scripts

### 1. Environment Setup (`setup_spnet.sh`)

Creates a conda env `spnet` with:
- Python 3.8
- PyTorch 2.0.1 + torchvision 0.15.2 + torchaudio 2.0.2
- `onnx` and `onnxruntime`

### 2. ONNX Export (`export_onnx.sh`, `export_onnx_*.py`)

Exports the Large V2Net model to ONNX (opset 17):
- Input names: `["rgb", "depth", "mask"]`
- Output name: `["pred"]`
- **Dynamic axes** on batch/height/width — the exported ONNX accepts variable resolution
- Two resolutions: 512×640 and 480×640
- Requires `Large_300.pth` checkpoint (downloaded separately from Google Drive)

### 3. TensorRT Engine Build

| Script | Platform | Notes |
|---|---|---|
| `build_trt.sh` | x86/Linux | Uses TensorRT 8.6.1.6, `trtexec` with FP16, `--optShapes` matching export |
| `build_trt_jetson.sh` | Jetson/aarch64 | Auto-locates `trtexec`, reduced workspace (512 MB), **must be built on the target Jetson device** |

Both produce:
- `spnet_512_640.engine`
- `spnet_480_640.engine`

---

## Integration with the Main Pipeline

The TensorRT engines are loaded by `DepthCompleter` (in `src/depth_completer.cpp` or `win_lic/depth/depth_completer.cpp`):

1. Engine path is determined by image resolution (512×640 or 480×640)
2. Input: RGB (HWC→CHW float) + sparse depth (÷200) + validity mask (depth > 0)
3. Synchronous `executeV2` inference
4. Output: dense depth (×200 to recover metric scale)

The completed depth is used by `Dataset::addFrame()` to extract new Gaussian sample positions in regions where LiDAR has no returns, via `selectFromDepthCompletion()`.
