# Module Reference: `config/` — Per-Dataset YAML Configuration

The `config/` directory contains YAML configuration files, one per supported dataset. Each file defines camera intrinsics, frame sampling rate, depth-completion settings, Gaussian model hyperparameters, and optimizer parameters for a specific sensor/dataset combination.

---

## Files

| File | Dataset | Resolution | Key Characteristics |
|---|---|---|---|
| `fastlivo.yaml` | FAST-LIVO | 640×512 | fx/fy≈431.8, standard params |
| `fastlivo2.yaml` | FAST-LIVO2 | 640×512 | fx/fy≈646.8, standard params |
| `fastlivo2_jetson.yaml` | FAST-LIVO2 (Jetson) | 640×512 | Memory-conservative variant (see below) |
| `m2dgr.yaml` | M2DGR | 640×480 | fx/fy≈617.97/616.45, lower `feature_lr` (0.0025) |
| `mcd.yaml` | MCD | 640×480 | fx/fy≈385.5, lower `feature_lr` (0.0025) |
| `r3live.yaml` | R3LIVE | 640×512 | `scaling_scale: 2`, higher `scaling_lr: 0.015`, `iteration_decay: true` |

---

## Configuration Schema

All config files share the same schema, parsed by the `Params` class in `src/mapping.h` (or `win_lic/core/params.h`):

### Camera Intrinsics

```yaml
width: 640
height: 512
fx: 646.8429559294912
fy: 646.8429559294912
cx: 313.5783179918794
cy: 261.4454929384664
```

### Frame Selection and Depth Completion

```yaml
select_every_k_frame: 5      # Keyframe stride (10 on Jetson)
depth_completion: true        # Enable SPNet depth completion
patch_size: 10                # Grid cell size for sample extraction
max_depth: 20                 # Maximum valid depth (meters)
```

The `engine_path` is auto-derived from resolution:
- 512×640 → `ckpt/spnet_512_640.engine`
- 480×640 → `ckpt/spnet_480_640.engine`

### Gaussian Model

```yaml
sh_degree: 3                  # Spherical harmonics degree (2 on Jetson)
white_background: false
random_background: false
convert_SHs_python: false
compute_cov3D_python: false
lambda_erank: 0               # Erank regularization weight (0.01 on Jetson)
scaling_scale: 1              # Initial Gaussian scale multiplier (2 on Jetson/R3LIVE)
```

### Optimizer Learning Rates

```yaml
position_lr: 0.00016
feature_lr: 0.0050            # 0.0025 for M2DGR/MCD
opacity_lr: 0.05
scaling_lr: 0.005             # 0.015 for R3LIVE
rotation_lr: 0.001
```

### Loss Weights

```yaml
lambda_dssim: 0.2             # D-SSIM loss weight
optimize_depth: true          # Enable depth-supervised loss
lambda_depth: 0.005           # Depth loss weight
iteration_decay: false        # True for R3LIVE (large-scale trajectory)
```

### Exposure and Skybox

```yaml
apply_exposure: false
exposure_lr: 0.001
skybox_points_num: 0          # 0 = no skybox
skybox_radius: 1000
```

### Jetson Memory Safety (optional)

```yaml
max_gaussians: 300000         # Hard cap; 0 = unlimited (desktop default)
```

---

## Jetson-Specific Configuration (`fastlivo2_jetson.yaml`)

The Jetson variant makes six memory-saving changes compared to the desktop config:

| Parameter | Desktop | Jetson | Rationale |
|---|---|---|---|
| `sh_degree` | 3 | 2 | Fewer SH coefficients → less GPU memory per Gaussian |
| `scaling_scale` | 1 | 2 | Larger initial Gaussians → fewer total Gaussians needed |
| `select_every_k_frame` | 5 | 10 | Fewer keyframes → fewer training cameras |
| `lambda_erank` | 0 | 0.01 | Regularize toward isotropic Gaussians → less anisotropic sprawl |
| `max_gaussians` | 0 (unlimited) | 300000 | Hard OOM cap (~200-300 bytes/Gaussian) |
| `feature_lr` | 0.0050 | 0.0050 | (unchanged) |

These values are tuned for the Jetson Orin Nano 8GB's shared CPU+GPU memory.
