# Module Reference: `third_party/` — Third-Party Submodules

The `third_party/` directory contains Git submodules for external dependencies that are integrated directly into the project rather than installed system-wide.

---

## Submodules

### msplat

| Field | Value |
|---|---|
| **Path** | `third_party/msplat` |
| **URL** | https://github.com/rayanht/msplat.git |
| **Purpose** | Metal-based 3D Gaussian Splatting training engine for on-device optimization (iOS/macOS) |

msplat provides a Metal-backed differentiable rasterizer, Adam optimizer, and densification primitives for training 3DGS models directly on Apple Silicon. The iOS app (`ios/`) uses it for on-device training: a captured dataset (images + LiDAR depth + ARKit poses) is optimized in ~500 iterations (~4 minutes on iPhone 15 Pro) and exported as a standard `.ply` file.

**Configuration** (`.gitmodules`):
```ini
[submodule "third_party/msplat"]
    path = third_party/msplat
    url = https://github.com/rayanht/msplat.git
```

> **Note:** The previous MetalSplatter submodule (rendering-only viewer) has been removed. Rendering is now handled by Apple's native `GaussianSplatComponent` in RealityKit (iOS 27+). See [ios.md](ios.md) for details.

---

## Managing Submodules

### Initial Clone with Submodules

```bash
git clone --recursive <repo-url>
```

### Updating Submodules After Pull

```bash
git submodule update --init --recursive
```

### Adding a New Submodule

```bash
git submodule add <url> third_party/<name>
git commit -m "build: add <name> submodule (third_party/<name>)"
```

When adding a new submodule, update this document and [`README.md`](../README.md) to register it.
