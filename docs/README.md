# Gaussian-LIC2 Documentation

This directory contains the complete technical documentation for the **Gaussian-LIC2** project — a real-time, photo-realistic LiDAR-Inertial-Camera Gaussian Splatting SLAM system.

> **Current version:** See [`../VERSION`](../VERSION) · **Changelog:** [`CHANGELOG.md`](CHANGELOG.md)

---

## 📖 Documentation Index

| Document | Description |
|---|---|
| [**Architecture Overview**](architecture.md) | System-level architecture, data flow, and design rationale |
| [**Module Reference**](modules/) | File-by-file documentation for every source module |
| [**Versioning Policy**](VERSIONING.md) | Semantic versioning rules and release workflow |
| [**Changelog**](CHANGELOG.md) | Versioned history of notable changes |
| [**Contributing Guide**](CONTRIBUTING.md) | How to contribute, including the documentation-update protocol |

### Module Reference Documents

| Module | Document | What it covers |
|---|---|---|
| `src/` | [modules/src.md](modules/src.md) | Core ROS-based Gaussian mapping node (C++/CUDA/LibTorch) |
| `win_lic/` | [modules/win_lic.md](modules/win_lic.md) | Windows-compatible offline multi-modal GS framework |
| `ckpt/` | [modules/ckpt.md](modules/ckpt.md) | SPNet depth-completion model (training, ONNX export, TensorRT) |
| `config/` | [modules/config.md](modules/config.md) | Per-dataset YAML configuration files |
| `launch/` | [modules/launch.md](modules/launch.md) | ROS launch files |
| `jetson/` | [modules/jetson.md](modules/jetson.md) | Jetson Orin Nano porting guide and scripts |
| `scripts/` | [modules/scripts.md](modules/scripts.md) | Utility scripts |
| `third_party/` | [modules/third_party.md](modules/third_party.md) | Third-party submodules |
| `latex/` | [modules/latex.md](modules/latex.md) | Research papers, survey, and design documents |

---

## 🗂️ Repository Structure at a Glance

```
Gaussian-LIC/
├── src/                 # Core ROS-based mapping node (C++/CUDA)
├── win_lic/             # Windows-compatible offline framework (C++/CUDA, no ROS)
├── ckpt/                # SPNet depth-completion model + TensorRT deployment
├── config/              # Per-dataset YAML configs (FAST-LIVO, M2DGR, MCD, R3LIVE)
├── launch/              # ROS launch files
├── jetson/              # Jetson Orin Nano setup guide and scripts
├── scripts/             # Utility scripts (arxiv bibliography fetcher)
├── third_party/         # Git submodules (MetalSplatter)
├── latex/               # Research papers, survey, design docs
├── pdf/                 # Reference paper PDFs and analysis notes
├── docs/                # ← You are here
├── CMakeLists.txt       # Root CMake build (catkin, x86 + Jetson)
├── package.xml          # ROS package manifest
├── VERSION              # Current semantic version
└── README.md            # Project README
```

---

## 🔄 Keeping Documentation Up to Date

All contributors must follow the [documentation-update protocol](CONTRIBUTING.md#documentation-update-protocol) when modifying source code. In summary:

1. **Any code change that alters a module's public API, file structure, or behavior** must be accompanied by a corresponding update to the relevant `docs/modules/*.md` file.
2. **Every release** must bump [`../VERSION`](../VERSION) and add an entry to [`CHANGELOG.md`](CHANGELOG.md).
3. **New files or modules** must be registered in this index and in the relevant module document.

---

## 📜 License

The Gaussian-LIC2 source code is released under the [GNU General Public License v3 (GPL-3)](https://www.gnu.org/licenses/gpl-3.0.txt). Third-party components retain their original licenses (documented per-file in the module references).
