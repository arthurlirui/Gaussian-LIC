# Changelog

All notable changes to the Gaussian-LIC2 project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/) (see [VERSIONING.md](VERSIONING.md)).

---

## [1.0.0] — 2026-10-13

### Added
- **Documentation infrastructure** (`docs/`): comprehensive technical documentation for the entire project
  - `docs/README.md` — documentation index and navigation
  - `docs/architecture.md` — system-level architecture, data flow diagrams, design rationale
  - `docs/modules/src.md` — core ROS-based mapping node reference (all files in `src/`)
  - `docs/modules/win_lic.md` — Windows-compatible offline framework reference (all files in `win_lic/`)
  - `docs/modules/ckpt.md` — SPNet depth-completion model reference (training, ONNX export, TensorRT)
  - `docs/modules/config.md` — per-dataset YAML configuration reference
  - `docs/modules/launch.md` — ROS launch files reference
  - `docs/modules/jetson.md` — Jetson Orin Nano porting guide reference
  - `docs/modules/scripts.md` — utility scripts reference
  - `docs/modules/third_party.md` — third-party submodules reference
  - `docs/modules/latex.md` — research papers and design documents reference
  - `docs/VERSIONING.md` — semantic versioning policy and release workflow
  - `docs/CHANGELOG.md` — this changelog
  - `docs/CONTRIBUTING.md` — contribution guide with documentation-update protocol
- **Version tracking**: `VERSION` file at repository root
- **Documentation-update protocol**: all future code changes must be accompanied by corresponding doc updates

### Documentation
- Documented the complete system architecture including the two build targets (`src/` ROS node and `win_lic/` offline framework), the incremental Gaussian Splatting SLAM algorithm, the modified 3DGS rasterizer extensions, and the SPNet depth-completion pipeline
- Documented all 236 tracked files across 9 modules with per-file descriptions, key classes/functions, and inter-module relationships
- Documented the Jetson Orin Nano porting process including CMake auto-detection, memory-safety configurations, and LibTorch bootstrap
- Established versioning and changelog conventions for ongoing project maintenance

---

## [Unreleased]

### Notes
- This is the initial documentation release. Prior to v1.0.0, the project did not use semantic versioning. The git history (commits prior to 2026-10-13) represents the pre-versioning development period.

---

## Pre-Versioning History

The following significant milestones were achieved before the versioning system was established. They are recorded here for historical context but do not have formal version numbers.

| Date | Commit | Summary |
|---|---|---|
| 2026-10-13 | `4fb198e` | Added SwiftMap (MobiSys 2026) drone mapping paper analysis |
| 2026-10-13 | `b73ce83` | Added MetalSplatter submodule (third_party/MetalSplatter) |
| 2026-10-13 | `8bbb9de` | Fixed Jetson TensorRT paths, libtorch symlinks, and sensor launch params |
| 2026-10-13 | `47ffb81` | Implemented data alignment logic and refactored renderer namespace |
| 2026-09-01 | `d6a5157` | Added Windows offline multi-modal GS framework and paper draft |
