# Gaussian-LIC2 — Related Work Survey (2026-09-08, updated 2026-10-08)

This directory collects **recent related work** surveyed via Doubao web search,
along with their original PDFs and a consolidated BibTeX file.

## Directory structure

```
latex/
├── README.md                ← this file
├── bib/
│   └── references.bib       ← consolidated BibTeX (58 entries: 56 + 2 addendum-7)
└── papers/                  ← 54 PDFs (52 + 2 addendum-7)
    ├── Lang2026_GaussianLIC2.pdf     ← this project (IJRR 2026, arXiv:2507.04004)
    ├── Lang2023_CocoLIC.pdf          ← odometry backend (RA-L 2023, arXiv:2309.09808)
    ├── Xie2024_GSLIVM.pdf            ← GS-LIVM (ICCV 2025, arXiv:2410.17084)
    ├── Park2026_LIVEGS.pdf           ← LIVE-GS / GSFusion (arXiv:2507.23273)
    ├── Tak2026_RealTimeLiDARGS.pdf   ← pure-LiDAR GS-SLAM (arXiv:2607.04127)
    ├── Shi2026_LITGS.pdf             ← LIT-GS, thermal (IROS 2026, arXiv:2606.20424)
    ├── Luu2026_GeometryAwareMapping.pdf  ← IROS 2026 (arXiv:2608.14902)
    ├── DeAmbrogi2026_CGSSLAM.pdf     ← multi-agent (arXiv:2608.26868)
    ├── Thirgood2026_FeatureSLAM.pdf  ← semantic (arXiv:2601.05738)
    ├── Hu2026_SGADSLAM.pdf           ← CVPR 2026 (arXiv:2603.21055)
    ├── Wang2026_RoSeSLAM.pdf         ← dynamic scenes (arXiv:2608.29003)
    ├── Hu2026_MotionGSSLAM.pdf       ← event-modulated GS (ICRA 2026, arXiv:2608.15024)  [NEW 09-09]
    ├── Pu2026_MoonSplat.pdf          ← monocular Sim(3) GS (SIGGRAPH 2026, arXiv:2606.17935)  [NEW 09-09]
    ├── Zhu2026_MyGOSplat.pdf         ← closed-loop RGB-only GS (IROS 2026, arXiv:2606.29738)  [NEW 09-09]
    │
    │  ── Addendum 2: foundations & baselines (downloaded 2026-09-09) ──
    ├── Kerbl2023_3DGS.pdf            ← 3D Gaussian Splatting (SIGGRAPH 2023, arXiv:2308.04079)
    ├── Yu2024_MipSplatting.pdf       ← Mip-Splatting (SIGGRAPH 2024, arXiv:2311.16493)
    ├── Lu2024_ScaffoldGS.pdf         ← Scaffold-GS (CVPR 2024, arXiv:2312.00109)
    ├── Radl2024_StopThePop.pdf       ← StopThePop (SIGGRAPH 2024, arXiv:2402.00525)
    ├── Mallick2024_Taming3DGS.pdf    ← Taming-3DGS (SIGGRAPH Asia 2024, arXiv:2406.04347)
    ├── Sucar2021_iMAP.pdf            ← iMAP (ICCV 2021, arXiv:2104.05603)
    ├── Zhu2022_NICESLAM.pdf          ← NICE-SLAM (CVPR 2022, arXiv:2112.12130)
    ├── Wang2023_CoSLAM.pdf           ← Co-SLAM (CVPR 2023, arXiv:2304.14377)
    ├── Sandstrom2023_PointSLAM.pdf   ← Point-SLAM (ICCV 2023, arXiv:2304.04278)
    ├── Zhang2023_GOSLAM.pdf          ← GO-SLAM (ICCV 2023, arXiv:2309.05271)
    ├── Rosinol2023_NeRFSLAM.pdf      ← NeRF-SLAM (IROS 2023, arXiv:2210.13641)
    ├── Xu2022_FASTLIO2.pdf           ← FAST-LIO2 (TRO 2022, arXiv:2206.06321)
    ├── Zheng2024_FASTLIVO2.pdf       ← FAST-LIVO2 (TRO 2024, arXiv:2408.14035)
    ├── Lin2024_R3LIVE.pdf            ← R3LIVE (TRO 2022, arXiv:2109.07982)
    ├── Keetha2024_SplaTAM.pdf        ← SplaTAM (CVPR 2024, arXiv:2312.02126)
    ├── Yan2024_GSSLAM.pdf            ← GS-SLAM (CVPR 2024, arXiv:2311.11700)
    ├── Huang2024_PhotoSLAM.pdf       ← Photo-SLAM (CVPR 2024, arXiv:2311.16728)
    ├── Matsuki2024_MonoGS.pdf        ← MonoGS / Gaussian Splatting SLAM (CVPR 2024, arXiv:2312.06741)
    ├── Zhu2024_LoopSplat.pdf         ← LoopSplat (WACV 2025, arXiv:2408.10154)
    │
    │  ── Addendum 2: continuous-time B-spline estimation (downloaded 2026-09-09) ──
    ├── Lang2022_CtrlVIO.pdf          ← Ctrl-VIO, CT-B-spline VIO for RS cameras (RA-L 2022, arXiv:2208.12008)
    ├── Ramezani2022_Wildcat.pdf      ← Wildcat, online CT LiDAR-inertial SLAM (arXiv 2022, arXiv:2205.12595)
    ├── Cao2025_RESPLE.pdf            ← RESPLE, recursive B-spline LiDAR odometry (RA-L 2025, arXiv:2504.11580)
    └── Zhao2026_CTVoxelMap.pdf       ← CT-VoxelMap, CT-LIO with Lie-group B-spline (arXiv 2026, arXiv:2604.03747)
```

(LIV-GS and RP-SLAM are IEEE-published; only their BibTeX entries are included.)

## Recent code update review (last 24 h)

**No commits in the last 24 hours** (re-checked 2026-10-04). The most recent commits are:

| commit   | date       | author    | change |
|----------|------------|-----------|--------|
| 793b9bc  | 2026-08-08 | jerry     | README: fix project-page link, IJRR news wording |
| b40ce7a  | 2026-08-06 | icameling | README: IJRR acceptance badge, title line break |
| cd4c122  | 2026-02-22 | jerry     | README: checklist update |
| 5e71af3  | 2026-02-21 | jerry     | TensorRT deployment guide + SPNet source code (1311 insertions) |
| da521d8  | 2026-02-21 | jerry     | **Gaussian-LIC → Gaussian-LIC2**: depth_completer, new configs (fastlivo2, m2dgr, mcd), rasterizer updates (724 insertions) |

The substantive code update happened on **2026-02-21** with the Gaussian-LIC2
release: a new `depth_completer` module (zero-shot depth completion for
LiDAR-blind areas), new dataset configs (FAST-LIVO2, M2DGR, MCD), CUDA
rasterizer forward/backward extensions, and TensorRT/ONNX export scripts.

## Surveyed related work — grouped by theme

### A. LiDAR(-Inertial)-Visual Gaussian Splatting SLAM (directly competing)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|-----------------------------|
| **GS-LIVM** (Xie et al.) | ICCV 2025 | LIV | Gaussian Process Regression densifies sparse LiDAR; covariance-centered init | Same problem class; uses GPR instead of a depth-completion net for LiDAR blind spots; no continuous-time odometry |
| **LIVE-GS / GSFusion** (Park et al.) | arXiv 2026 | LIV | Dual surfel+Gaussian map, surfel-to-surfel BA, bounded-sigmoid scale, loop closure | Addresses global consistency + uncontrolled Gaussian growth; no depth completion |
| **LIV-GS** (Xiao et al.) | RA-L 2025 | LiDAR+Vision (no IMU) | Registers LiDAR scans **directly against the Gaussian map** (point-to-Gaussian ICP); CGC propagates LiDAR geometry to blind spots | Closest in "use Gaussian map for tracking"; no IMU, no depth completion, ~8 FPS |
| **Real-Time LiDAR GS-SLAM** (Tak et al.) | arXiv 2026 | LiDAR only | G-ICP + spherical rasterization; covariance-derived geometry score for pruning/densification | Pure-LiDAR (no camera); relevant for the LiDAR-supervision + densification design |
| **LIT-GS** (Shi et al.) | IROS 2026 | LiDAR-Inertial-Thermal | Replaces RGB with thermal for illumination robustness; LiDAR plane regularization in BA + splatting | Shows the photometric-robustness alternative; same FAST-LIVO2 anchor idea |

### B. RGB-D / monocular 3DGS-SLAM (indoor baselines)

| paper | venue | key idea |
|-------|-------|----------|
| **Geometry-Aware Online Mapping** (Luu et al.) | IROS 2026 | Transmittance-preserving densification, camera-aware scale init, error-guided densification — fixes offline 3DGS heuristics for online SLAM |
| **FeatureSLAM** (Thirgood et al.) | arXiv 2026 | SAM2 feature rasterization for open-set semantic SLAM; 9% lower ATE, 8% better mapping |
| **SGAD-SLAM** (Hu et al.) | CVPR 2026 | Pixel-aligned Gaussians adjustable along rays; depth-distribution tracking; scalable to large scenes |
| **RP-SLAM** (Bai et al.) | TVCG 2026 | Adaptive sampling + Gaussian filtering, dynamic-window optimization, monocular init from sparse points |

### C. Collaborative / dynamic-scene 3DGS-SLAM

| paper | venue | key idea |
|-------|-------|----------|
| **CGS-SLAM** (de Ambrogi et al.) | arXiv 2026 | Multi-agent VI-SLAM, metric monocular depth (Depth Pro), VGGT submap alignment, low-bandwidth collaboration |
| **RoSe-SLAM** (Wang et al.) | arXiv 2026 | Dynamic monocular SLAM; semantic Gaussian field, spatial-temporal motion mask, occlusion-aware keyframe selection |

## Key takeaways for Gaussian-LIC2 positioning

1. **Depth completion vs. GPR/monocular-depth.** Gaussian-LIC2's lightweight
   zero-shot depth-completion net (fusing RGB + sparse LiDAR) is the
   distinguishing design versus GS-LIVM (GPR) and CGS-SLAM (metric monocular
   depth). The recent trend (LIVE-GS, LIV-GS) is to add **geometric
   regularization** (LiDAR plane / surfel constraints) rather than densify
   depth — worth comparing experimentally.

2. **Gaussian map feeding back into odometry.** Gaussian-LIC2's photometric
   factor in the continuous-time graph is still relatively unique. LIV-GS
   goes further by using the Gaussian map *as the registration target* for
   LiDAR; LIVE-GS uses surfel-to-surfel BA. This "map-aided tracking" axis
   is the active research direction.

3. **Online densification heuristics.** Geometry-Aware Online Mapping (IROS
   2026) directly critiques the offline ADC heuristics that Gaussian-LIC2
   also inherits; its transmittance-preserving + error-guided densification
   could improve Gaussian-LIC2's incremental mapping under tight iteration
   budgets.

4. **Global consistency / loop closure.** LIVE-GS and RP-SLAM emphasize loop
   closure + global Gaussian refinement — currently a gap in Gaussian-LIC2's
   checklist ("Support fast post-optimization" is unchecked).

5. **Thermal / multi-modal robustness.** LIT-GS shows the sensor-fusion axis
   beyond RGB+LiDAR, targeting the same illumination-robustness motivation
   that Gaussian-LIC2 addresses via exposure modeling.

## Reproducing the survey

Searches were run on 2026-09-08 via Doubao web search with queries:
- "Gaussian Splatting SLAM 2025 2026 LiDAR inertial camera fusion"
- "Gaussian-LIC2 related work Gaussian Splatting SLAM recent 2026"
- "3D Gaussian Splatting SLAM real-time dense mapping arxiv 2026"
- "LIV-Gaussian GS-LIVM MoD-SLAM RGBD GS-ICP SLAM 2025 2026 arxiv"
- "photo-realistic SLAM gaussian splatting depth completion LiDAR 2026"
- "LoopSplat gaussian splatting SLAM loop closure 2025 2026 arxiv"
- "Coco-LIC continuous-time LiDAR inertial camera odometry arxiv"

arXiv abstract pages were fetched to confirm author lists, venues, and DOIs.

---

## Update 2026-09-09 — newly surveyed related work

A follow-up Doubao search (queries targeting the last month / September 2026
arXiv listings) surfaced three additional 3DGS-SLAM works not in the
2026-09-08 set. Their PDFs were downloaded into `papers/` and BibTeX entries
appended to `bib/references.bib` under a new "Addendum" section.

### D. Event / monocular-global-optimization 3DGS-SLAM (addendum)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **MotionGS-SLAM** (Hu et al.) | ICRA 2026 | RGB + Event | Forward-models motion blur inside the rasterizer via an event-modulated Gaussian kernel (spatial anisotropy + temporal exposure sampling); joint optimization of intra-exposure trajectory & map | Orthogonal robustness axis to Gaussian-LIC2's exposure modeling: events handle aggressive-motion blur rather than photometric exposure gain; same "physics in the renderer" philosophy |
| **MoonSplat** (Pu et al.) | SIGGRAPH 2026 | Monocular RGB | Voxelized 3DGS + global **Sim(3)** optimization with loop closure; color-residual learning for faster convergence; deployed on a UAV active-reconstruction system | Directly addresses two of Gaussian-LIC2's open gaps — global loop closure and uncontrolled primitive growth (via voxelized Scaffold-GS) — but in a monocular-only, non-LiDAR setting |
| **MyGO-Splat** (Zhu et al.) | IROS 2026 | Monocular RGB | Closed-loop geometric feedback: analytically rasterizes Gaussians into depth+normals to *supervise* tracking; scale-aware alignment projects foundation-model depth into the globally optimized Gaussian space | Shares Gaussian-LIC2's "map feeds back into odometry" thesis, but uses rasterized depth/normals instead of a photometric factor, and monocular depth priors instead of LiDAR; relevant baseline for the closed-loop design |

### Why these matter for Gaussian-LIC2 positioning

6. **Motion-robust rendering.** MotionGS-SLAM shows that modeling image
   formation physics (blur) *inside* the splat is more tractable than
   deblurring as a preprocessing step — a design principle that could extend
   Gaussian-LIC2's exposure-aware photometric factor to motion-blur regimes
   where LiDAR-inertial continuity alone cannot disambiguate pose.

7. **Sim(3) loop closure for 3DGS.** MoonSplat's factor-graph Sim(3)
   optimization jointly refines poses *and* voxelized Gaussians on loop
   closure, which is currently the most concrete recipe for the unchecked
   "fast post-optimization" item on Gaussian-LIC2's roadmap; the voxelized
   representation also bounds memory, addressing the uncontrolled-growth
   issue noted for LIVE-GS and Geometry-Aware Mapping.

8. **Closed-loop map→tracking feedback.** MyGO-Splat formalizes the idea
   that the refined Gaussian map should actively regulate the frontend
   (rasterized depth/normals re-injected into tracking). Gaussian-LIC2's
   photometric factor is already a step in this direction, but MyGO-Splat's
   analytic depth+normal rasterization is a stronger geometric feedback
   signal worth comparing against.

### Reproducing the addendum survey

Follow-up searches were run on 2026-09-09 via Doubao web search with queries:
- "Gaussian Splatting SLAM 2026 LiDAR inertial camera fusion arxiv new" (OneMonth)
- "3D Gaussian Splatting SLAM real-time dense mapping arxiv 2026 September" (OneMonth)
- "photo-realistic SLAM gaussian splatting depth completion LiDAR 2026" (OneMonth)
- "LoopSplat gaussian splatting SLAM loop closure global consistency 2026" (OneYear)
- "MotionGS-SLAM event-modulated gaussian splatting arxiv 2608.15024"
- "MoonSplat monocular online gaussian splatting Sim(3) SIGGRAPH 2026 arxiv"
- "gaussian splatting SLAM arxiv September 2026 new LiDAR visual inertial" (OneWeek)

---

## Addendum 2 (2026-09-09, continued) — foundations & baselines

A second round of Doubao searches targeted the **foundational and baseline
works** that Gaussian-LIC2 cites as prior art but that were not yet captured
as standalone entries in `references.bib`. These are not "recent competitors"
(Sections A–D above) but rather the **methodological ancestry** needed for a
self-contained related-work section: the 3DGS representation itself, the
NeRF-SLAM lineage it displaced, the LIO/LIVO front-ends Gaussian-LIC2 builds
on, and the first wave of RGB-D/monocular 3DGS-SLAM systems that established
the tracking-by-differentiation paradigm.

PDFs were downloaded into `papers/` for all open-access (arXiv) papers.
IEEE-published front-ends (FAST-LIO2, FAST-LIVO2, R3LIVE) are also on arXiv
and were downloaded. `references.bib` now holds **36 entries** (17 original +
19 new); the original 17 entries are unchanged.

### E. 3DGS foundations (the representation Gaussian-LIC2 builds on)

| paper | venue | key idea | relation to Gaussian-LIC2 |
|-------|-------|----------|----------------------------|
| **3D Gaussian Splatting** (Kerbl et al.) | SIGGRAPH 2023 / ACM TOG | Anisotropic 3D Gaussian primitives with differentiable splatting; real-time radiance field rendering | The core map representation Gaussian-LIC2 instantiates and extends |
| **Mip-Splatting** (Yu et al.) | SIGGRAPH 2024 / ACM TOG | Anti-aliasing via 2D Mip filter + 3D smoothing filter; scale-consistent splats | Addresses the multi-scale aliasing that matters for SLAM keyframes at varying baselines |
| **Scaffold-GS** (Lu et al.) | CVPR 2024 | Anchor-driven MLP-decoded Gaussians; view-adaptive attributes | A structured-growth alternative Gaussian-LIC2's densification heuristics could adopt |
| **StopThePop** (Radl et al.) | SIGGRAPH 2024 / ACM TOG | Per-pixel hierarchical sorting eliminates popping artifacts | Rendering-quality fix relevant to Gaussian-LIC2's photometric factor stability |
| **Taming-3DGS** (Mallick et al.) | SIGGRAPH Asia 2024 | Predictable, steerable model growth under memory budgets | Directly relevant to bounding Gaussian count in long SLAM runs |

### F. NeRF-SLAM baselines (pre-3DGS dense neural SLAM, compared as prior art)

| paper | venue | key idea | relation to Gaussian-LIC2 |
|-------|-------|----------|----------------------------|
| **iMAP** (Sucar et al.) | ICCV 2021 | First real-time NeRF-SLAM; single MLP for joint mapping & tracking | The lineage origin; 3DGS-SLAM's explicit primitives solve its scaling/catastrophic-forgetting issues |
| **NICE-SLAM** (Zhu et al.) | CVPR 2022 | Hierarchical feature-grid neural implicit SLAM; scalable indoor reconstruction | The scalable NeRF-SLAM baseline that 3DGS-SLAM works benchmark against |
| **Co-SLAM** (Wang et al.) | CVPR 2023 | Joint coordinate + sparse parametric encodings; fast per-step optimization | Speed baseline for the tracking-by-differentiation paradigm |
| **Point-SLAM** (Sandström et al.) | ICCV 2023 | Data-adaptive neural point cloud; memory grows with scene complexity | Closest "explicit primitive" precursor to 3DGS within the NeRF-SLAM family |
| **GO-SLAM** (Zhang et al.) | ICCV 2023 | Global bundle adjustment over a NeRF; full-trajectory optimization for consistency | The "global optimization" NeRF-SLAM baseline; relevant to loop-closure comparisons |
| **NeRF-SLAM** (Rosinol et al.) | IROS 2023 | Real-time dense monocular SLAM with uncertainty-aware NeRF | Uncertainty modeling that 3DGS-SLAM generally lacks; comparison point for robustness |

### G. LiDAR-Inertial(-Visual) odometry front-ends (Gaussian-LIC2's backend baselines)

| paper | venue | key idea | relation to Gaussian-LIC2 |
|-------|-------|----------|----------------------------|
| **FAST-LIO2** (Xu et al.) | TRO 2022 | Direct LiDAR-inertial odometry with ikd-tree; iterated EKF | The LIO backbone Gaussian-LIC2's continuous-time graph augments |
| **FAST-LIVO2** (Zheng et al.) | TRO 2024 | Unified voxel-map LIVO; photometric + geometric fusion via ESIKF | The direct LIVO predecessor; Gaussian-LIC2 adds a Gaussian photometric factor on top of the same ESIKF lineage |
| **R3LIVE** (Lin & Zhang) | TRO 2022 | Real-time LiDAR-inertial-visual radiance reconstruction; point colorization | The "radiance" LIVO baseline; Gaussian-LIC2 replaces point-colorization with full 3DGS rendering |

### H. Classic RGB-D / monocular 3DGS-SLAM (preceding the 2026 wave)

| paper | venue | key idea | relation to Gaussian-LIC2 |
|-------|-------|----------|----------------------------|
| **SplaTAM** (Keetha et al.) | CVPR 2024 | Splat-track-map; silhouette-guided densification; skybox init for unbounded scenes | Canonical RGB-D 3DGS-SLAM baseline; no LiDAR, no inertial |
| **GS-SLAM** (Yan et al.) | CVPR 2024 | Adaptive Gaussian expansion + differentiable rasterization rendering loss; coarse-to-fine tracking | The "render-and-compare" tracking paradigm Gaussian-LIC2's photometric factor inherits |
| **Photo-SLAM** (Huang et al.) | CVPR 2024 | Hyper-primitive ORB features + Gaussian photorealistic mapping; real-time on mono/stereo/RGB-D | Shows the feature-tracking + Gaussian-mapping split; Gaussian-LIC2 instead folds photometry into the CT graph |
| **MonoGS / Gaussian Splatting SLAM** (Matsuki et al.) | CVPR 2024 | Monocular dense SLAM with 3DGS; analytical Jacobians for bundle adjustment | Analytic-Jacobian BA is the closest "Gaussian-native tracking" design; Gaussian-LIC2 keeps an ESIKF front-end |
| **LoopSplat** (Zhu et al.) | WACV 2025 | Loop closure by registering 3D Gaussian submaps; submap PGO with Gaussian alignment | The concrete loop-closure-for-3DGS recipe; addresses Gaussian-LIC2's open "fast post-optimization" item |

### I. Continuous-time B-spline trajectory estimation (methodological root of Coco-LIC / Gaussian-LIC2)

| paper | venue | key idea | relation to Gaussian-LIC2 |
|-------|-------|----------|----------------------------|
| **Ctrl-VIO** (Lang et al.) | RA-L 2022 | Continuous-time B-spline VIO for rolling-shutter cameras; probabilistic marginalization of spline control points in a sliding window | Same lab (APRIL-ZJU) as Coco-LIC; establishes the B-spline sliding-window + marginalization framework that Coco-LIC extends to LiDAR-Inertial-Camera fusion |
| **Wildcat** (Ramezani et al.) | arXiv 2022 | Online continuous-time 3D LiDAR-inertial SLAM using B-spline trajectory; lidar-only (no camera) | The continuous-time LiDAR-inertial SLAM baseline; Coco-LIC adds the camera photometric factor and non-uniform B-spline adaptive control-point placement |
| **RESPLE** (Cao et al.) | RA-L 2025 | Recursive Bayesian B-spline estimation via modified iterated EKF; control-point increments on Lie groups; multi-LiDAR + IMU | A filter-based (not optimization) B-spline estimator; shows the recursive alternative to Coco-LIC's sliding-window optimization for real-time CT trajectory estimation |
| **CT-VoxelMap** (Zhao et al.) | arXiv 2026 | CT-LIO with cumulative-form cubic B-spline on matrix Lie groups; online spline-fitting-error estimation via IMU; hybrid-feature voxel map | The latest CT-LIO with explicit spline-fitting-error modeling — a limitation Coco-LIC/Gaussian-LIC2 also face but do not explicitly address |

### Why these matter for Gaussian-LIC2 positioning

9. **Representation lineage.** 3DGS → Mip-Splatting/Scaffold-GS/Taming-3DGS
   establishes the representation-quality axis (aliasing, growth control) that
   Gaussian-LIC2's online densification must respect; the 2026 trend toward
   structured/bounded representations (Scaffold-GS, Taming-3DGS) is the most
   direct path to fixing uncontrolled primitive growth in long runs.

10. **Front-end lineage.** FAST-LIO2 → R3LIVE → FAST-LIVO2 is the ESIKF-based
    LIO/LIVO family Gaussian-LIC2 descends from; its continuous-time
    photometric factor is an additive contribution on top of this lineage, so
    direct comparison against FAST-LIVO2 (the strongest discrete-time member)
    is the key ablation.

11. **Tracking paradigm.** SplaTAM / GS-SLAM / MonoGS define the
    "render-and-compare" 3DGS-SLAM tracking paradigm; Gaussian-LIC2 differs by
    keeping an ESIKF/LIO front-end and adding the Gaussian photometric factor
    as a *correction* term rather than driving tracking purely from rendering
    residuals. LoopSplat then shows how to bring global consistency back.

12. **Continuous-time B-spline lineage.** Ctrl-VIO → Coco-LIC → Gaussian-LIC2
    is the direct methodological chain: Ctrl-VIO established the B-spline
    sliding-window + probabilistic marginalization framework for VIO, Coco-LIC
    extended it to LiDAR-Inertial-Camera fusion with non-uniform B-splines, and
    Gaussian-LIC2 adds the 3DGS photometric factor. Wildcat and CT-VoxelMap
    represent the parallel LiDAR-inertial CT line, with CT-VoxelMap's explicit
    spline-fitting-error modeling being a limitation Gaussian-LIC2 currently
    inherits without addressing.

### Reproducing the Addendum 2 survey

Searches run on 2026-09-09 via Doubao web search:
- "3D Gaussian Splatting Kerbl SIGGRAPH 2023 arxiv"
- "Scaffold-GS Mip-Splatting gaussian splatting 2024 arxiv"
- "StopThePop Taming-3DGS gaussian splatting aliasing"
- "NeRF SLAM iMAP NICE-SLAM real-time dense"
- "Point-SLAM GO-SLAM neural point SLAM 2023 2024"
- "FAST-LIO2 FAST-LIVO2 LiDAR inertial visual odometry arxiv"
- "Faster-LIO Point-LIO R3LIVE LiDAR inertial odometry"
- "LoopSplat gaussian splatting SLAM loop closure 2025 2026 arxiv"
- "Photo-SLAM Gaussian Splatting SLAM real-time CVPR 2024"
- "SplaTAM Gaussian Splatting SLAM monocular RGBD CVPR 2024"
- "GS-SLAM MonoGS Gaussian Splatting SLAM CVPR 2024 arxiv"
- "continuous-time B-spline SLAM LiDAR inertial camera odometry arxiv"
- "B-spline visual inertial odometry continuous time trajectory estimation"

arXiv abstract pages were fetched to confirm author lists, venues, and DOIs.
IEEE Transactions on Robotics papers (FAST-LIO2, FAST-LIVO2, R3LIVE) have
arXiv preprints and were downloaded from arXiv.

### Updated `papers/` inventory (37 PDFs)

Original 14 (Sections A–D) plus 23 new (Sections E–I): Kerbl2023_3DGS,
Yu2024_MipSplatting, Lu2024_ScaffoldGS, Radl2024_StopThePop,
Mallick2024_Taming3DGS, Sucar2021_iMAP, Zhu2022_NICESLAM, Wang2023_CoSLAM,
Sandstrom2023_PointSLAM, Zhang2023_GOSLAM, Rosinol2023_NeRFSLAM,
Xu2022_FASTLIO2, Zheng2024_FASTLIVO2, Lin2024_R3LIVE, Keetha2024_SplaTAM,
Yan2024_GSSLAM, Huang2024_PhotoSLAM, Matsuki2024_MonoGS, Zhu2024_LoopSplat,
Lang2022_CtrlVIO, Ramezani2022_Wildcat, Cao2025_RESPLE, Zhao2026_CTVoxelMap.

---

## Addendum 3 (2026-09-10) — four newly surveyed related works

A third Doubao search round (queries targeting the last month / September 2026
arXiv listings, plus targeted follow-ups for specific systems) surfaced four
additional 3DGS-related works not captured in the 2026-09-08 / 2026-09-09
sets. All four have arXiv preprints; their PDFs were downloaded into
`papers/` and BibTeX entries appended to `bib/references.bib` under a new
"Addendum 3" section. `references.bib` now holds **44 entries** (40 + 4 new);
`papers/` now holds **41 PDFs** (37 + 4 new).

### J. LiDAR-augmented 3DGS reconstruction (offline, SLAM-fed)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **Structured-Li-GS** (Weng et al.) | ISPRS Congress 2026 | LiDAR + RGB + IMU | Offline reconstruction: run FAST-LIVO2 to get poses + dense colorized point cloud, then anchor Gaussians on down-sampled LiDAR points with normal-aligned ellipsoidal initialization; photometric + flatten + offset + depth + normal losses; **no densification** (fixed Gaussian count) | Directly comparable: same FAST-LIVO2 front-end as Gaussian-LIC2, but offline mapping (not online SLAM) and uses LiDAR normals for Gaussian orientation/shape instead of a depth-completion net. Shows the "structured initialization + geometric regularization" alternative to densification-driven coverage |

### K. LiDAR-constrained 3DGS for aerial / large-scale scenes

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **ARSGaussian** (Yao et al.) | ISPRS J. P&RS 2026 | aerial RGB + LiDAR | LiDAR-guided densification (grow/split along geometric benchmarks), distortion-aware camera model for LiDAR-RGB pixel alignment, depth + normal + scale consistency losses; releases AIR-LONGYAN dataset | A different scale regime (aerial, large standoff, sparse views) than Gaussian-LIC2's ground-level scenes, but shares the "LiDAR geometry regularizes Gaussian growth" principle; its depth/normal/scale consistency losses are a more explicit geometric-regularization recipe than Gaussian-LIC2's depth-gradient loss |

### L. Structure-/appearance-aware RGB(-D) 3DGS-SLAM

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **SEGS-SLAM** (Wen et al.) | ICCV 2025 | mono / stereo / RGB-D | Decoupled (ORB-SLAM3 + 3DGS): initializes Scaffold-GS-style **anchor points** from ORB-SLAM3's structured point cloud; Appearance-from-Motion embedding (AfME) encodes per-image appearance from camera pose; frequency-pyramid regularization | Strongest SOTA rendering baseline among RGB-D/mono 3DGS-SLAM (19.86% PSNR gain over MonoGS on TUM mono). No LiDAR, no CT factor — but the "structured anchor initialization" and "appearance-from-pose" ideas directly address two weaknesses Gaussian-LIC2 inherits from vanilla 3DGS (unstructured init, exposure modeling via a separate photometric factor) |

### M. Dynamic-environment monocular 3DGS-SLAM

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **WildGS-SLAM** (Zheng et al.) | CVPR 2025 | monocular RGB | DINOv2 + shallow MLP predict a per-pixel uncertainty map that soft-weights dense BA (tracking) and rendering loss (mapping), removing dynamic distractors without semantic priors or depth input; releases Wild-SLAM dataset | Orthogonal robustness axis: handles moving distractors that Gaussian-LIC2's static-world CT photometric factor does not model. The uncertainty-weighting pattern is directly portable to Gaussian-LIC2's photometric factor to down-weight dynamic pixels in outdoor crowds/traffic |

### Why these matter for Gaussian-LIC2 positioning

13. **Structured init vs. densification.** Structured-Li-GS shows that with
    LiDAR normals anchoring Gaussian orientation and shape, accurate
    reconstruction is achievable **without any densification** — the opposite
    design pole from Gaussian-LIC2's depth-completion + incremental insertion.
    This is the clearest existing ablation of the "cover blind spots by
    structure" vs. "cover blind spots by more points" trade-off, both fed by
    the same FAST-LIVO2 front-end.

14. **Geometric regularization recipes.** ARSGaussian (depth + normal + scale
    consistency) and Structured-Li-GS (flatten + offset + depth + normal) both
    push LiDAR geometry into the *loss*, not just the initialization. Gaussian-
    LIC2 currently supervises only the depth-gradient term; these works suggest
    adding a normal/planarity regularizer is a low-cost geometric-accuracy
    improvement, directly relevant to Gaussian-LIC2's stated gap on geometric
    reconstruction accuracy.

15. **Appearance modeling beyond a photometric factor.** SEGS-SLAM's AfME
    (appearance latent conditioned on camera pose) and WildGS-SLAM's per-pixel
    uncertainty are two alternatives to Gaussian-LIC2's exposure-aware
    photometric factor. AfME is a learned appearance code that generalizes to
    novel views; the uncertainty map is a data-driven robustness weight. Either
    could replace or augment Gaussian-LIC2's hand-tuned exposure gain.

16. **Dynamic-scene robustness.** WildGS-SLAM is the first monocular 3DGS-SLAM
    to handle dynamic environments via pure geometric uncertainty (no semantics,
    no depth). Gaussian-LIC2's CT photometric factor assumes a static world;
    importing an uncertainty-weighting layer (DINOv2 + MLP) into the photometric
    residual is the most direct path to outdoor dynamic-scene robustness without
    abandoning the continuous-time framework.

### Reproducing the Addendum 3 survey

Searches run on 2026-09-10 via Doubao web search:
- "Gaussian Splatting SLAM LiDAR inertial camera fusion 2026 arxiv September new" (OneMonth)
- "3D Gaussian Splatting SLAM real-time dense mapping arxiv 2026" (OneMonth)
- "Structured-Li-GS LiDAR 3D Gaussian Splatting ISPRS 2026 arxiv Weng" (OneMonth)
- "SEGS-SLAM structure enhanced gaussian splatting appearance embedding ICCV 2025 arxiv"
- "ARSGaussian aerial remote sensing LiDAR 3D Gaussian Splatting arxiv Yao Zhang"
- "WildGS-SLAM Zheng Zhu Bieri Pollefeys Peng Armeni arxiv monocular dynamic"
- "Structured-Li-GS Weng Li Yeum Waterloo ISPRS 2026 LiDAR Gaussian Splatting pdf download"

arXiv abstract pages were fetched to confirm author lists, venues, and DOIs.
The ISPRS Annals paper (Structured-Li-GS) and ISPRS Journal paper (ARSGaussian)
both have arXiv preprints and were downloaded from arXiv.

### Updated `papers/` inventory (41 PDFs)

The four new additions (Sections J–M) are:
Weng2026_StructuredLiGS, Yao2026_ARSGaussian, Wen2025_SEGSSLAM,
Zheng2025_WildGSSLAM.

---

## Addendum 4 (2026-09-11) — five newly surveyed related works

A fourth Doubao search round (targeting the last month of arXiv listings and
specific follow-up queries) surfaced five additional 3DGS-related works not
captured in the 2026-09-08 through 2026-09-10 sets. All five have arXiv
preprints; their PDFs were downloaded into `papers/` and BibTeX entries
appended to `bib/references.bib` under a new "Addendum 4" section.
`references.bib` now holds **49 entries** (44 + 5 new); `papers/` now holds
**46 PDFs** (41 + 5 new).

### N. LiDAR-incorporated 3DGS for large-scale reconstruction (offline)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **LI-GS** (Jiang et al.) | arXiv 2024 (Zhejiang U.) | LiDAR + RGB | Converts LiDAR point clouds to plane-constrained multimodal **Gaussian Mixture Models** (4D GMMs encoding position+color); uses 2D Gaussian surfels for surface alignment; GMMs supervise init + optimization + mesh extraction; SLICT for CT-LIO poses | Closest "LiDAR geometry as continuous probabilistic supervision" design to Gaussian-LIC2's depth-gradient loss; LI-GS's GMM formulation is a richer geometric prior than a per-pixel depth loss, and its 2D-surfel representation directly addresses the ellipsoid-vs-surface mismatch. Offline (not online SLAM) |

### O. Multi-agent large-scale 3DGS-SLAM with global consistency

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **GRAND-SLAM** (Thomas et al.) | RA-L 2025 (MIT ACL) | RGB-D | First multi-agent 3DGS-SLAM for **large-scale outdoor** scenes; local submap optimization with frame-to-model tracking; inter- and intra-robot loop closure via NetVLAD + dense RGB-D registration; pose-graph optimization (GTSAM); 91% lower multi-agent ATE on Kimera-Multi | Directly addresses two Gaussian-LIC2 open gaps: (1) large-scale / long-trajectory scalability via submap decomposition, and (2) global loop closure with PGO — the unchecked "fast post-optimization" roadmap item. RGB-D only (no LiDAR/inertial), but the submap + PGO recipe is portable to Gaussian-LIC2's CT framework |

### P. Post-hoc 3DGS primitive simplification

| paper | venue | key idea | relation to Gaussian-LIC2 |
|-------|-------|----------|----------------------------|
| **CVT-GS** (Li et al.) | arXiv 2026 (BIT/PKU) | Optimization-free post-hoc simplification: geometry-aware **Centroidal Voronoi Tessellation** partitions Gaussian centers into support cells; a lightweight MergeNet predicts one representative Gaussian per cell under differentiable rendering supervision; 100× primitive reduction at 12× speed vs. SOTA, +1.3 dB PSNR | Directly relevant to Gaussian-LIC2's uncontrolled-primitive-growth problem in long SLAM runs. Unlike Taming-3DGS (training-time) or Scaffold-GS (architectural), CVT-GS is post-hoc and renderer-compatible — could be applied as a maintenance step to compact the Gaussian map after online mapping |

### Q. Online latent-feature 3DGS mapping for open-vocabulary perception

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **LatentAM** (Lee & Tian) | RA-L 2026 (U. Michigan) | RGB-D | Online dictionary-learning approach to VLM feature mapping: each Gaussian gets a compact query vector converted to approximate CLIP/DINOv3/LSeg embeddings via a learnable attention dictionary; trust-region regularization; voxel-hashing local–global map for bounded GPU memory; 12–35 FPS, >530 m trajectories | Orthogonal axis: extends 3DGS-SLAM maps from pure geometry/appearance to open-vocabulary semantic querying. The voxel-hashing local–global map management (bounded GPU memory, CPU-indexed global map) is directly relevant to Gaussian-LIC2's memory scaling in long runs; the online dictionary-learning pattern could inform how Gaussian-LIC2 handles appearance/exposure latent codes |

### R. Dynamic-environment RGB-D 3DGS-SLAM

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **Gassidy** (Wen et al.) | arXiv 2024 (TUM) | RGB-D | Rendering-loss-flow analysis for dynamic-object filtering: instance-segmented object/background Gaussians; iteratively analyzes photometric-geometric loss streams to distinguish dynamic from static components without predefined semantic priors; 97.9% tracking ATE improvement | Same dynamic-scene robustness gap as WildGS-SLAM (Addendum 3) but uses rendering-loss-flow analysis instead of DINOv2 uncertainty. The "analyze loss streams per object" pattern is portable to Gaussian-LIC2's photometric factor: per-object loss monitoring could detect dynamic distractors in the CT residual without adding a separate semantic pipeline |

### Why these matter for Gaussian-LIC2 positioning

17. **LiDAR as continuous probabilistic supervision.** LI-GS's plane-constrained
    GMM is a more expressive geometric prior than Gaussian-LIC2's per-pixel
    depth-gradient loss. Rather than supervising depth at discrete LiDAR hits,
    the GMM provides continuous supervision over the entire surface, including
    unobserved areas — a stronger recipe for the geometric-accuracy gap that
    ARSGaussian and Structured-Li-GS (Addendum 3) also target.

18. **Submap decomposition + PGO for large-scale SLAM.** GRAND-SLAM is the
    most concrete recipe for scaling 3DGS-SLAM to large-scale outdoor
    environments with global consistency. Its submap-init-on-motion-threshold
    + NetVLAD loop closure + GTSAM PGO pipeline directly addresses
    Gaussian-LIC2's "fast post-optimization" unchecked item, and the
    local-optimization trick (optimize pose w.r.t. local frame, not global
    origin) prevents gradient imbalance in long trajectories — a practical
    concern for any CT-B-spline SLAM running over kilometers.

19. **Post-hoc map compaction.** CVT-GS shows that a trained 3DGS scene can
    be compressed 100× post-hoc without retraining, preserving renderer
    compatibility. For Gaussian-LIC2, this offers a maintenance pathway: run
    online mapping with standard densification, then periodically compact the
    map with CVT-GS-style merging to bound memory — complementing the
    structured-growth approaches (Scaffold-GS, Taming-3DGS) that operate at
    training time.

20. **Semantic 3DGS-SLAM scaling.** LatentAM demonstrates near-real-time
    (12–35 FPS) open-vocabulary 3DGS mapping over 530 m+ trajectories using
    a local–global voxel-hashing strategy. Its bounded-GPU-memory map
    management is directly applicable to Gaussian-LIC2's long-run memory
    problem, independent of the semantic-feature aspect.

21. **Dynamic-scene robustness via loss-flow analysis.** Gassidy's
    rendering-loss-flow approach (monitor per-object loss streams to detect
    dynamic distractors without semantic priors) is a lightweight alternative
    to WildGS-SLAM's DINOv2 uncertainty maps. For Gaussian-LIC2, per-object
    loss monitoring in the CT photometric residual could flag dynamic regions
    for down-weighting — a minimal modification that preserves the
    continuous-time framework.

### Reproducing the Addendum 4 survey

Searches run on 2026-09-11 via Doubao web search:
- "Gaussian Splatting SLAM LiDAR inertial camera fusion 2026 arxiv September new" (OneMonth)
- "3D Gaussian Splatting SLAM real-time dense mapping arxiv 2026 September" (OneMonth)
- "gaussian splatting SLAM arxiv 2609 LiDAR visual inertial odometry" (OneMonth)
- "gaussian splatting SLAM loop closure global consistency 2026 arxiv new September" (OneWeek)
- "CVT-GS Centroidal Voronoi Tessellation 3D Gaussian Splatting arxiv 2609.08730"
- "LI-GS Gaussian Splatting LiDAR large-scale reconstruction arxiv"
- "GRAND-SLAM multi-agent Gaussian SLAM arxiv Thomas Sonawalla How"
- "Gassidy Gaussian Splatting SLAM Dynamic Environments arxiv 2411.15476"
- "LatentAM latent gaussian attention mapping online dictionary learning arxiv 2602.12314"

arXiv abstract pages were fetched to confirm author lists, venues, and DOIs.
All five papers have arXiv preprints and were downloaded from arXiv.

### Updated `papers/` inventory (46 PDFs)

The five new additions (Sections N–R) are:
Jiang2024_LIGS, Thomas2025_GRANDSLAM, Li2026_CVTGS, Lee2026_LatentAM,
Wen2024_Gassidy.

---

## Addendum 5 (2026-09-12) — five newly surveyed related works

A fifth Doubao search round (targeting the first half of September 2026 arXiv
listings, plus targeted follow-ups for important baselines that were referenced
by surveyed works but not yet captured as standalone entries) surfaced five
additional 3DGS-SLAM works not in the 2026-09-08 through 2026-09-11 sets. All
five have arXiv preprints; their PDFs were downloaded into `papers/` and
BibTeX entries appended to `bib/references.bib` under a new "Addendum 5"
section. `references.bib` now holds **54 entries** (49 + 5 new); `papers/` now
holds **51 PDFs** (46 + 5 new).

### S. Real-time hybrid RGB-D 3DGS-SLAM with online loop closure

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **LightSplat** (Bao et al.) | IROS 2026 (Beihang U.) | RGB-D | Hybrid representation: sparse-feature tracking (fast, wide convergence basin) + dual-thread backend that progressively constructs dense Gaussian submaps; **feature-accelerated 3DGS registration** for online loop closure via pose-graph optimization; 8 FPS | Directly targets Gaussian-LIC2's open "fast post-optimization" gap — but in the RGB-D domain. The feature-accelerated submap registration (vs. LoopSplat's heavy iterative dense alignment) is a lightweight loop-closure recipe that could inform a CT-B-spline equivalent. RGB-D only (no LiDAR/inertial) |

### T. G-ICP-based 3DGS-SLAM (geometric registration tracking)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **RGBD GS-ICP SLAM** (Ha et al.) | ECCV 2024 (SKKU) | RGB-D | Single Gaussian map shared between G-ICP tracking and 3DGS mapping; covariance exchange + scale alignment eliminate redundant computation; 107 FPS | The canonical "Gaussian map as registration target" baseline (cited by LIV-GS, LightSplat, and others). Demonstrates that 3DGS primitives can serve directly as ICP correspondents — the same principle LIV-GS extends to LiDAR. No LiDAR/inertial, but establishes the tracking-via-Gaussian-registration paradigm |
| **G2S-ICP SLAM** (Pak et al.) | arXiv 2025 (Yonsei) | RGB-D | Extends GS-ICP with surface-aligned **2D Gaussian disks** (tangent-plane-constrained) embedded into G-ICP via anisotropic covariance prior; geometry-aware loss (photometric + depth + normal consistency) | A refinement of the GS-ICP lineage: the 2D-disk representation directly addresses the ellipsoid-vs-surface mismatch that also affects Gaussian-LIC2's geometric accuracy. The normal-consistency loss is the same recipe ARSGaussian and Structured-Li-GS (Addendum 3) advocate |

### U. Visual-inertial 3DGS-SLAM (IMU-enhanced tracking)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **MM3DGS SLAM** (Sun et al.) | IROS 2024 (UT Austin) | RGB-D + IMU | First visual-inertial 3DGS SLAM: pre-integrated IMU relative-pose constraints folded into the tracking loss alongside photometric + depth terms; scale awareness from IMU; releases UT-MM dataset | The earliest IMU+3DGS-SLAM system. Gaussian-LIC2's continuous-time B-spline framework is a more principled fusion than MM3DGS's loss-term IMU injection, but MM3DGS is the baseline that established "IMU improves 3DGS tracking" — directly comparable on the visual-inertial axis |
| **GI-SLAM** (Liu & Tan) | arXiv 2025 (Sun Yat-sen) | mono/stereo/RGB-D + IMU | IMU loss seamlessly integrated into the 3DGS-SLAM differentiable rendering framework; motion-constrained keyframe selection prevents motion-blurred keyframes; supports mono/stereo/RGB-D with/without IMU | A more mature visual-inertial 3DGS-SLAM than MM3DGS: the IMU loss is a lightweight additive term (not a CT factor graph). Gaussian-LIC2's B-spline + photometric factor is the continuous-time generalization; GI-SLAM is the discrete-time visual-inertial 3DGS-SLAM baseline |

### Why these matter for Gaussian-LIC2 positioning

22. **Loop closure for 3DGS — the lightweight recipe.** LightSplat's
    feature-accelerated submap registration is the most efficient online
    loop-closure mechanism for 3DGS-SLAM to date (vs. LoopSplat's heavy
    iterative dense alignment). For Gaussian-LIC2, this confirms that loop
    closure need not require full global re-optimization of all Gaussians —
    a pose-graph + local Gaussian refinement is sufficient, and the
    feature-accelerated registration could be adapted to the CT-B-spline
    framework by registering submap control-point windows.

23. **Gaussian-as-registration-target lineage.** GS-ICP → G2S-ICP → LIV-GS
    is now a clear three-step lineage: GS-ICP established that 3DGS
    primitives serve as ICP correspondents, G2S-ICP added surface-aligned
    2D disks for geometric fidelity, and LIV-GS extended the idea to LiDAR.
    Gaussian-LIC2's photometric factor is a different tracking signal
    (render-and-compare, not point-to-Gaussian ICP), but the lineage shows
    the geometric-registration axis is maturing rapidly — worth an
    experimental comparison against the photometric factor.

24. **Visual-inertial 3DGS-SLAM baselines.** MM3DGS (IROS 2024) and GI-SLAM
    (2025) are the two existing IMU+3DGS-SLAM systems. Both inject IMU
    constraints as loss terms in the differentiable-rendering optimization,
    not as a continuous-time factor graph. Gaussian-LIC2's B-spline
    trajectory + Coco-LIC odometry backend is architecturally richer, but
    these two works are the direct visual-inertial baselines to cite and
    compare against — they occupy the "simpler IMU fusion" design pole.

25. **2D Gaussian disks for surface fidelity.** G2S-ICP's tangent-plane-
    constrained 2D Gaussian disks (inheriting from 2DGS) directly address
    the ellipsoid-vs-surface mismatch that limits Gaussian-LIC2's geometric
    reconstruction accuracy. Combined with the normal-consistency losses
    from ARSGaussian and Structured-Li-GS (Addendum 3), this forms a
    coherent "surface-aware Gaussian" improvement direction that could
    augment Gaussian-LIC2's current 3D ellipsoid representation.

### Reproducing the Addendum 5 survey

Searches run on 2026-09-12 via Doubao web search:
- "Gaussian Splatting SLAM LiDAR inertial camera fusion 2026 arxiv September new" (OneMonth)
- "3D Gaussian Splatting SLAM real-time dense mapping arxiv 2026 September" (OneMonth)
- "gaussian splatting SLAM arxiv 2609 LiDAR visual inertial odometry new" (OneMonth)
- "gaussian splatting SLAM loop closure global consistency 2026 arxiv new September" (OneWeek)
- "GS-ICP OpenGS gaussian splatting SLAM registration 2026 arxiv" (OneMonth)
- "GS-ICP SLAM Ha Yeon Yu RGBD Gaussian Splatting ECCV 2024 arxiv"
- "MM3DGS SLAM multimodal 3D gaussian splatting vision depth inertial IROS 2024 arxiv"
- "GI-SLAM Gaussian Inertial SLAM arxiv 2503.18275"
- "LightSplat Real-Time High-Fidelity 3D Gaussian SLAM Loop Closure arxiv 2609.07213"

arXiv abstract pages and the arXiv CV/RO listing pages were fetched to confirm
author lists, venues, and DOIs. All five papers have arXiv preprints and were
downloaded from arXiv.

### Updated `papers/` inventory (51 PDFs)

The five new additions (Sections S–U) are:
Bao2026_LightSplat, Ha2024_GSICPSLAM, Sun2024_MM3DGS, Liu2025_GISLAM,
Pak2025_G2SICPSLAM.

---

## Addendum 6 (2026-09-13) — two newly surveyed related works

A sixth Doubao search round (re-checking the last 24 h of arXiv listings
and the continuous-time B-spline lineage) surfaced two additional works not
captured in the 2026-09-08 through 2026-09-12 sets. One has an arXiv preprint
(downloaded into `papers/`); the other is IEEE-published (BibTeX only).
`references.bib` now holds **56 entries** (54 + 2 new); `papers/` now holds
**52 PDFs** (51 + 1 new).

### V. Relocalization-informed depth estimation from a metrically scaled 3DGS map

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **RIDE** (Lian et al.) | arXiv 2026 (Sep 10) | RGB (with a pre-built metric 3DGS map) | Given a metrically scaled 3DGS model, RIDE estimates dense metric depth from a robot's RGB stream by combining sparse metric depth from PnP-RANSAC inlier correspondences (render–match–PnP relocalization) with a pretrained video-depth model prior; global + local depth correction with temporal memory handles intermittent observations | Orthogonal to Gaussian-LIC2's online SLAM but shares the "3DGS map feeds back into perception" thesis: RIDE uses the Gaussian map to *densify depth* at query time rather than at mapping time. The render–match–PnP pipeline is a relocalization-time analog of Gaussian-LIC2's depth-completion net — both bridge LiDAR-blind / unscaled regions using the Gaussian map as the geometric anchor. Relevant as a downstream consumer of a Gaussian-LIC2-built map |

### W. Continuous-time LiDAR odometry with adaptive non-uniform B-spline

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **A&B-LO** (Lu et al.) | RA-L 2026 (Mar) | LiDAR + IMU | Continuous-time LiDAR odometry via adaptive non-uniform B-spline trajectory; point-to-plane registration + pseudo-velocity smoothing; analytical Jacobians; adaptive knot spacing adjusts control-point time intervals online | Directly in the continuous-time B-spline lineage (Ctrl-VIO → Coco-LIC → Gaussian-LIC2). A&B-LO's adaptive knot spacing is the LiDAR-only analog of Coco-LIC's non-uniform control-point placement — both address the under/over-parameterization problem of uniform B-splines. LiDAR-only (no camera, no Gaussian map), but validates the adaptive non-uniform B-spline design choice that Gaussian-LIC2 inherits from Coco-LIC |

### Why these matter for Gaussian-LIC2 positioning

26. **3DGS map as a depth source at query time.** RIDE demonstrates that a
    metrically scaled 3DGS model can serve as the geometric backbone for dense
    depth estimation *after* mapping — a use case that Gaussian-LIC2's
    metrically scaled Gaussian map directly enables. The render–match–PnP
    inlier correspondences provide sparse metric anchors that the video-depth
    prior densifies, complementing Gaussian-LIC2's mapping-time depth
    completion with a query-time depth-recovery pathway.

27. **Adaptive non-uniform B-spline validation.** A&B-LO independently
    confirms that adaptive non-uniform B-spline knot spacing improves
    continuous-time LiDAR odometry — the same design principle Coco-LIC
    introduced and Gaussian-LIC2 inherits. A&B-LO's analytical Jacobian
    derivation and adaptive knot-spacing technique are concrete implementation
    details that could inform future refinements of Gaussian-LIC2's CT
    trajectory estimation.

### Reproducing the Addendum 6 survey

Searches run on 2026-09-13 via Doubao web search:
- "Gaussian Splatting SLAM LiDAR inertial camera fusion 2026 arxiv September new" (OneWeek)
- "3D Gaussian Splatting SLAM real-time dense mapping arxiv 2026 September" (OneWeek)
- "gaussian splatting SLAM arxiv 2609 LiDAR visual inertial odometry new" (OneMonth)
- "gaussian splatting SLAM loop closure global consistency 2026 arxiv new September" (OneWeek)
- "continuous-time LiDAR inertial visual odometry B-spline gaussian splatting 2026 arxiv new September" (OneMonth)
- "RIDE Relocalization-Informed Depth Estimation 3D Gaussian Splatting arxiv 2609.11079"
- "A&B-LO Adaptive Non-Uniform B-Spline LiDAR Odometry arxiv Yuchu Lu RA-L 2026"

arXiv abstract pages and the arXiv CV/RO listing pages were fetched to confirm
author lists, venues, and DOIs. RIDE has an arXiv preprint and was downloaded.
A&B-LO is IEEE-published (RA-L, Mar 2026) with no arXiv preprint; only its
BibTeX entry is included.

### Updated `papers/` inventory (52 PDFs)

The two new additions (Sections V–W) are:
Lian2026_RIDE (PDF), Lu2026_ABLO (BibTeX only — IEEE-published).

---

## Addendum 7 (2026-09-14) — two newly surveyed related works

A seventh Doubao search round (re-checking the last week of arXiv listings
and the event-/multi-camera 3DGS-SLAM axis) surfaced two additional works not
captured in the 2026-09-08 through 2026-09-13 sets. Both have arXiv preprints;
their PDFs were downloaded into `papers/` and BibTeX entries appended to
`bib/references.bib` under a new "Addendum 7" section. `references.bib` now
holds **58 entries** (56 + 2 new); `papers/` now holds **54 PDFs** (52 + 2 new).

### X. Event-fused RGB-D Gaussian Splatting SLAM

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **EGS-SLAM** (Chen et al.) | IEEE RA-L 2025 (NTU + Beihang) | RGB-D + Event | First event-RGB-D GS-SLAM; explicitly models the camera's continuous trajectory during exposure to render blur-aware images and event maps from a unified 3DGS; learnable Camera Response Function (CRF) aligns HDR events with LDR images; no-event loss suppresses ringing artifacts | Orthogonal robustness axis to Gaussian-LIC2's exposure-aware photometric factor: EGS-SLAM handles aggressive-motion blur via events rather than photometric exposure gain, but shares the "physics in the renderer" philosophy (modeling image formation over the exposure interval). The within-exposure continuous-trajectory interpolation is the event-camera analog of Gaussian-LIC2's continuous-time B-spline photometric factor — both integrate rendering over a time window rather than treating each frame as instantaneous. No LiDAR/inertial |

### Y. Multi-camera RGB Gaussian Splatting SLAM

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **MCGS-SLAM** (Cao et al.) | ICRA 2026 (ETH Zürich + U. Amsterdam) | Multi-camera RGB | First purely RGB-based multi-camera 3DGS SLAM; Multi-Camera Bundle Adjustment (MCBA) jointly refines poses and dense depth via photometric + geometric residuals across all views; scale-consistency module enforces metric alignment across cameras using low-rank geometric priors; supports RGB (and RGB-D); real-time at scale on Waymo-style rigs | Addresses the field-of-view / geometric-coverage limitation that monocular 3DGS-SLAM (and Gaussian-LIC2's single-camera setup) face. The multi-camera bundle adjustment with scale alignment is the multi-view generalization of the render-and-compare tracking paradigm; relevant as a design reference for extending Gaussian-LIC2 to multi-camera rigs (e.g., surround-view autonomous driving). No LiDAR/inertial, but the MCBA + scale-consistency formulation could be folded into a CT-B-spline multi-camera factor graph |

### Why these matter for Gaussian-LIC2 positioning

28. **Within-exposure continuous trajectory modeling.** EGS-SLAM's explicit
    modeling of the camera trajectory *during the exposure interval* —
    rendering blur-aware images by integrating latent sharp frames over
    time — is conceptually aligned with Gaussian-LIC2's continuous-time
    B-spline photometric factor, which also evaluates the rendering residual
    over a temporal support rather than at an instant. The difference is that
    EGS-SLAM uses a linear SE(3) interpolation over a single exposure (event-
    driven), whereas Gaussian-LIC2 uses a non-uniform B-spline over a sliding
    window (LiDAR-inertial-driven). EGS-SLAM confirms that exposure-time
    continuous modeling improves tracking under blur — a regime where
    Gaussian-LIC2's CT factor should also be more robust than discrete-frame
    alternatives, though this has not been explicitly benchmarked.

29. **Multi-camera 3DGS-SLAM.** MCGS-SLAM is the first to demonstrate that a
    calibrated multi-camera rig can be fused into a single continuously
    optimized Gaussian map with metric scale, via MCBA + low-rank scale
    priors. For Gaussian-LIC2, this is the design reference for the multi-
    camera extension axis: the CT-B-spline factor graph naturally supports
    multiple cameras on the same body, and MCGS-SLAM's scale-consistency
    module addresses the inter-camera metric-alignment problem that would
    arise. The wide-FoV coverage (240° on Waymo) also directly addresses the
    geometric-coverage limitation of single-camera Gaussian-LIC2 in
    surround-view scenarios.

### Reproducing the Addendum 7 survey

Searches run on 2026-09-14 via Doubao web search:
- "Gaussian Splatting SLAM LiDAR inertial camera fusion 2026 arxiv September new" (OneWeek)
- "3D Gaussian Splatting SLAM real-time dense mapping arxiv 2026 September" (OneWeek)
- "gaussian splatting SLAM arxiv 2609 LiDAR visual inertial odometry new September" (OneMonth)
- "gaussian splatting SLAM loop closure global consistency 2026 arxiv new September" (OneWeek)
- "EGS-SLAM event RGB-D gaussian splatting SLAM arxiv motion blur" (OneMonth)
- "MCGS-SLAM multi-camera gaussian splatting SLAM arxiv 2509.14191" (OneMonth)
- "gaussian splatting SLAM depth completion LiDAR 2026 arxiv new continuous-time B-spline September" (OneWeek)

arXiv abstract pages were fetched to confirm author lists, venues, and DOIs.
Both papers have arXiv preprints and were downloaded: EGS-SLAM (arXiv:2508.07003,
RA-L 2025) and MCGS-SLAM (arXiv:2509.14191, ICRA 2026).

### Updated `papers/` inventory (54 PDFs)

The two new additions (Sections X–Y) are:
Chen2025_EGSSLAM (PDF), Cao2026_MCGSSLAM (PDF).

---

## Addendum 8 (2026-09-15) — four newly surveyed related works

An eighth Doubao search round (re-checking the last week of arXiv listings
and the uncertainty-/geometry-aware 3DGS-SLAM axis) surfaced four additional
works not captured in the 2026-09-08 through 2026-09-14 sets. All four have
arXiv preprints; their PDFs were downloaded into `papers/` and BibTeX entries
appended to `bib/references.bib` under a new "Addendum 8" section.
`references.bib` now holds **62 entries** (58 + 4 new); `papers/` now holds
**58 PDFs** (54 + 4 new).

### Z. LiDAR-augmented 2DGS + neural SDF (offline reconstruction)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **GS-SDF** (Liu et al.) | IROS 2025 (HKU MARS) | LiDAR + RGB (+ IMU via FAST-LIVO2) | Trains a neural SDF from LiDAR point clouds, then uses it for SDF-based Gaussian initialization (marching-cubes vertices, gradient-aligned orientation, curvature-based scale) and a shape regularization that supervises each splat's disk surface against the SDF zero-level set; 2DGS (surfels) as the renderer | Directly comparable on the geometric-accuracy axis: same FAST-LIVO2 front-end as Gaussian-LIC2, but offline mapping. The "SDF as continuous geometric supervisor" recipe is a stronger alternative to Gaussian-LIC2's per-pixel depth-gradient loss — it provides manifold geometry over unobserved areas, not just at LiDAR hits. The shape regularization (sampling a point on each splat disk and pulling it to the SDF zero level set) is a concrete, low-cost normal/planarity regularizer that Gaussian-LIC2 currently lacks |

### AA. Uncertainty-aware 3DGS-SLAM (per-splat appearance variance)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **VarSplat** (Tran & Kosecka) | CVPR 2026 (George Mason U.) | RGB-D | Each Gaussian learns an extra per-channel appearance variance σ²; the law of total variance + alpha compositing render a differentiable per-pixel uncertainty map in a single rasterization pass (no extra forward, no Monte Carlo); the uncertainty map down-weights unreliable pixels in tracking, submap registration, and loop closure | Directly addresses a gap Gaussian-LIC2 inherits from vanilla 3DGS: its CT photometric factor weights all pixels uniformly, so low-texture / reflective / depth-discontinuity regions bias pose estimation. VarSplat's single-pass variance rendering is a drop-in, renderer-native uncertainty signal that could replace Gaussian-LIC2's hand-tuned exposure gain with a learned, per-pixel reliability weight. RGB-D only (no LiDAR/inertial), but the uncertainty-weighting pattern is portable to the CT photometric residual |

### BB. Uncertainty-driven 3DGS active mapping (anisotropic visibility field)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **GAVIS** (Xue et al.) | CVPR 2026 (Georgia Tech) | RGB (active mapping on a trained 3DGS) | Models each splat's visibility as an anisotropic, direction-dependent field stored analytically in spherical harmonics (training-free, <1 s to construct, constant-time query via an AM-GM lower bound); a Bayesian-network rasterizer composites visibility into a GMM-entropy uncertainty that drives next-best-view selection; virtual particles distinguish unexplored voids from true free space | Orthogonal to online SLAM but the most principled 3DGS uncertainty quantification to date: the "unobserved ⇒ high uncertainty" guarantee is exactly the property VarSplat (Addendum 8, AA) approximates with learned variance. For Gaussian-LIC2, GAVIS's SH-based visibility field is a candidate post-hoc module that could flag under-observed Gaussians for densification/re-observation — addressing the uncontrolled-growth + coverage-quality gap without retraining. The virtual-particle trick (zero-opacity probes to separate free space from unexplored regions) is a reusable fix for a known blind spot in 3DGS density control |

### CC. Variational Bayesian 3DGS-SLAM (closed-form posterior over poses + map)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **VBGS-SLAM** (Zhu et al.) | arXiv 2026 (UC Riverside) | RGB-D | Frames 3DGS-SLAM as a generative mixture model over 3D Gaussians and SE(3) poses (Lie groups); variational inference yields closed-form updates that jointly maintain posterior uncertainty over both poses and splat parameters, coupling map and pose uncertainty rather than treating pose as a point estimate; mitigates catastrophic forgetting in long sequences | A fundamentally different tracking paradigm from Gaussian-LIC2's ESIKF + CT B-spline: VBGS-SLAM replaces gradient-based optimization with closed-form variational updates, and explicitly propagates pose uncertainty into the map. Gaussian-LIC2's B-spline already represents a continuous pose distribution implicitly, but does not maintain posterior covariance over map parameters. VBGS-SLAM is the probabilistic-uncertainty pole of the 3DGS-SLAM design space — relevant as a reference for how tightly pose and map uncertainty can be coupled, and for its long-sequence robustness (an open concern for CT-B-spline SLAM over kilometer-scale trajectories) |

### Why these matter for Gaussian-LIC2 positioning

30. **SDF as a continuous geometric supervisor.** GS-SDF's neural SDF provides
    manifold geometry over the entire surface — including unobserved areas —
    which is a strictly richer geometric prior than Gaussian-LIC2's per-pixel
    depth-gradient loss (supervises only at LiDAR hits). The SDF-assisted
    initialization (marching-cubes vertices, gradient-aligned orientation)
    and the disk-surface shape regularization are two concrete, low-cost
    additions that target Gaussian-LIC2's stated geometric-accuracy gap,
    both fed by the same FAST-LIVO2 front-end Gaussian-LIC2 uses.

31. **Renderer-native uncertainty for the photometric factor.** VarSplat shows
    that per-splat appearance variance, propagated via the law of total
    variance in a single rasterization pass, yields a differentiable per-pixel
    uncertainty map at no extra forward-pass cost. This is the most direct
    replacement for Gaussian-LIC2's uniform-pixel-weight CT photometric
    residual: down-weight low-texture / reflective / boundary pixels without
    a separate exposure-gain model. It complements GAVIS's visibility-based
    uncertainty (which models *where* the map is under-observed) — together
    they cover both the "pixel unreliable" and "region unobserved" axes that
    Gaussian-LIC2's current factor does not distinguish.

32. **Posterior uncertainty over the map, not just the trajectory.** VBGS-SLAM
    and GAVIS both push 3DGS-SLAM toward explicit uncertainty over map
    parameters (variational posterior / visibility field), whereas
    Gaussian-LIC2 maintains uncertainty only over the B-spline trajectory
    (via the ESIKF covariance). For long-sequence robustness and for any
    downstream consumer of the Gaussian map (e.g., RIDE, Addendum 6), a map
    with calibrated uncertainty is increasingly the expected interface —
    a direction Gaussian-LIC2 could adopt without abandoning the CT framework.

### Reproducing the Addendum 8 survey

Searches run on 2026-09-15 via Doubao web search:
- "Gaussian Splatting SLAM LiDAR inertial camera fusion 2026 arxiv September new" (OneWeek)
- "3D Gaussian Splatting SLAM real-time dense mapping arxiv 2026 September" (OneWeek)
- "gaussian splatting SLAM arxiv 2609 LiDAR visual inertial odometry new September" (OneMonth)
- "GS-SDF LiDAR-Augmented Gaussian Splatting Neural SDF arxiv 2503.10170"
- "VarSplat uncertainty-aware 3D Gaussian Splatting RGB-D SLAM arxiv 2603.09673"
- "GAVIS Anisotropic Visibility Field active mapping gaussian splatting arxiv 2605.30342"
- "VBGS-SLAM Variational Bayesian Gaussian Splatting SLAM arxiv 2604.02696"

arXiv abstract pages were fetched to confirm author lists, venues, and DOIs.
All four papers have arXiv preprints and were downloaded: GS-SDF (arXiv:2503.10170,
IROS 2025), VarSplat (arXiv:2603.09673, CVPR 2026), GAVIS (arXiv:2605.30342,
CVPR 2026), VBGS-SLAM (arXiv:2604.02696).

### Updated `papers/` inventory (58 PDFs)

The four new additions (Sections Z–CC) are:
Liu2025_GSSDF, Tran2026_VarSplat, Xue2026_GAVIS, Zhu2026_VBGSSLAM.

---

## Addendum 9 (2026-09-16) — four newly surveyed related works

A ninth Doubao search round (re-checking the LIVO/GS-SLAM lineage and the
loop-closure baselines cited by GRAND-SLAM, Addendum 4) surfaced four
additional works not captured in the 2026-09-08 through 2026-09-15 sets. All
four have arXiv preprints; their PDFs were downloaded into `papers/` and
BibTeX entries appended to `bib/references.bib` under a new "Addendum 9"
section. `references.bib` now holds **66 entries** (62 + 4 new); `papers/`
now holds **62 PDFs** (58 + 4 new).

### DD. Tightly-coupled LiDAR-Inertial-Visual Gaussian radiance-field mapping

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **LIV-GaussMap** (Hong et al.) | RA-L 2024 (HKUST) | LIV | Size-adaptive-voxel LIO initializes surface Gaussians; photometric gradients refine SH coefficients + structure; differentiable ellipsoidal-surface Gaussians fix critical-incidence-angle point-cloud artifacts | The earliest tightly-coupled LIV + 3DGS mapping system. Shares Gaussian-LIC2's "LiDAR geometry + visual photometry" recipe but is a mapping system (poses from LIO, not jointly optimized with the Gaussian factor). No continuous-time factor, no depth completion; closer to R3LIVE's colorization lineage upgraded to 3DGS |
| **GS-LIVO** (Hong et al.) | T-RO 2025 (HKUST + HKU + SJTU) | LIV | Hash-indexed-octree global Gaussian map + sliding-window Gaussian optimization + IESKF odometry with a Gaussian-rendered visual measurement model; first real-time Gaussian-SLAM deployable on embedded Jetson Orin NX | The most direct LIV-Gaussian-SLAM competitor in the ESIKF lineage. GS-LIVO's IESKF + Gaussian-map visual measurement is the discrete-time analog of Gaussian-LIC2's continuous-time B-spline + photometric factor. Its sliding-window Gaussian maintenance (bounded GPU memory, embedded deployment) is the concrete efficiency recipe Gaussian-LIC2's online mapping could adopt. No continuous-time trajectory, no depth completion |

### EE. Online dense 3DGS mapping for urban / autonomous-driving scenes

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **HGS-Mapping** (Wu et al.) | RA-L 2024 (Fudan + HIT + SJTU) | LiDAR + RGB | First online dense 3DGS mapping for urban scenes; Hybrid Gaussian Representation (sphere Gaussians for sky, 2D-plane Gaussians for road, 3D Gaussians for roadside); lightweight feature-matching fills LiDAR coverage gaps; adaptive densify + importance pruning | Addresses the LiDAR-coverage-gap problem Gaussian-LIC2 solves via depth completion, but with a representation-level fix (typed Gaussians) rather than a learned depth net. The sky/road/object Gaussian typing is a structured-growth idea orthogonal to Gaussian-LIC2's uniform ellipsoids; relevant for outdoor extension where unbounded geometry dominates |

### FF. Monocular 3DGS-SLAM with submap-level loop closure

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **GLC-SLAM** (Xu et al.) | ESWA 2026 (Beihang) | Monocular RGB | Submap-level loop detection: spatio-temporal uncertainty sampling selects representative Gaussians, GSPR encodes them into a global descriptor, NVS-rendered depth verifies candidates geometrically; hierarchical global-to-local PGO + direct map adjustment; uncertainty-minimized keyframe selection | The strongest monocular loop-closure-for-3DGS baseline alongside LightSplat (Addendum 5) and LoopSplat (Addendum 2). GLC-SLAM's submap-level descriptor (built from the Gaussian map itself, not 2D image features) is a "map-native" place-recognition idea that Gaussian-LIC2's metrically scaled Gaussian map could adopt directly — its LiDAR-anchored Gaussians carry richer geometric signatures than monocular ones. Directly addresses the unchecked "fast post-optimization" roadmap item |

### Why these matter for Gaussian-LIC2 positioning

33. **The LIV-Gaussian-SLAM lineage is now a clear family.** LIV-GaussMap
    (2024) → GS-LIVO (2025, T-RO) → Gaussian-LIC2 (2026) form a progression:
    LIV-GaussMap established tightly-coupled LIV + 3DGS *mapping* (poses from
    LIO, Gaussians refined offline-by-photometry); GS-LIVO upgraded to a
    real-time *SLAM* system with IESKF + Gaussian-map visual measurement on
    embedded hardware; Gaussian-LIC2 then adds the continuous-time B-spline
    factor graph and a depth-completion net. GS-LIVO is the key discrete-time
    LIV-Gaussian-SLAM baseline to cite and compare against — it occupies the
    "IESKF + Gaussian photometric measurement, no CT factor" design pole.

34. **Embedded-deployment efficiency.** GS-LIVO's hash-octree global map +
    sliding-window Gaussian optimization (only FoV voxels optimized per frame)
    is the concrete memory/compute-bounding recipe that enables real-time
    Gaussian-SLAM on Jetson Orin NX. For Gaussian-LIC2, the sliding-window
    idea is directly portable to its CT sliding-window B-spline + Gaussian-map
    co-optimization, and the hash-octree structure addresses the
    uncontrolled-growth / large-scale memory concern noted across Addenda 2–8.

35. **Representation typing for outdoor scenes.** HGS-Mapping's
    sphere/2D-plane/3D Gaussian typing is a structured-growth alternative to
    Gaussian-LIC2's depth-completion + uniform-ellipsoid densification. For
    outdoor / aerial extension (where sky, ground planes, and roadside
    objects have very different geometry), typed Gaussians could complement
    Gaussian-LIC2's depth-completion net: the net handles LiDAR-blind
    near-field gaps, while typed Gaussians handle far-field unbounded
    structure. This is the outdoor-scale counterpart to the indoor
    structured-init ideas in Structured-Li-GS (Addendum 3) and GS-SDF
    (Addendum 8).

36. **Map-native loop closure.** GLC-SLAM's submap-level descriptor built
    *from the Gaussian map itself* (via GSPR encoding of uncertainty-sampled
    Gaussians) is the most "map-native" loop-closure recipe to date — it does
    not require a separate 2D image-retrieval module (NetVLAD/BoW) as
    LightSplat and LoopSplat do. For Gaussian-LIC2, whose LiDAR-anchored
    Gaussians carry metric scale and surface normals, a GSPR-style descriptor
    would be even more discriminative than for monocular GLC-SLAM. Combined
    with GS-LIVO's sliding-window map management, this forms a concrete path
    to the unchecked "fast post-optimization" roadmap item without abandoning
    the continuous-time framework.

### Reproducing the Addendum 9 survey

Searches run on 2026-09-16 via Doubao web search:
- "Gaussian Splatting SLAM LiDAR inertial camera fusion 2026 arxiv September new" (OneWeek)
- "3D Gaussian Splatting SLAM real-time dense mapping arxiv 2026 September" (OneWeek)
- "gaussian splatting SLAM arxiv 2609 LiDAR visual inertial odometry new" (OneMonth)
- "gaussian splatting SLAM loop closure global consistency 2026 arxiv new September" (OneWeek)
- "GLC-SLAM gaussian splatting SLAM efficient loop closure arxiv 2409.10982"
- "HGS-Mapping online dense mapping hybrid gaussian urban scenes arxiv"
- "LIV-GaussMap LiDAR-inertial-visual radiance field real-time arxiv Hong Shen"
- "GS-LIVO Real-Time LiDAR Inertial Visual Odometry Gaussian Mapping arxiv Hong Shen"

arXiv abstract pages were fetched to confirm author lists, venues, and DOIs.
All four papers have arXiv preprints and were downloaded: LIV-GaussMap
(arXiv:2401.14857, RA-L 2024), GS-LIVO (arXiv:2501.08672, T-RO 2025),
HGS-Mapping (arXiv:2403.20159, RA-L 2024), GLC-SLAM (arXiv:2409.10982, ESWA 2026).

### Updated `papers/` inventory (62 PDFs)

The four new additions (Sections DD–FF) are:
Hong2024_LIVGaussMap, Hong2025_GSLIVO, Wu2024_HGSMapping, Xu2024_GLCSLAM.

---

## Addendum 10 (2026-09-17) — five newly surveyed related works

A tenth Doubao search round (re-checking the 3DGS-SLAM family, the
LIV-Gaussian-SLAM competitors, and the continuous-time multi-modal
odometry lineage) surfaced five additional works not captured in the
2026-09-08 through 2026-09-16 sets. Four have arXiv preprints (PDFs
downloaded into `papers/`); LVGS-SLAM is IEEE-only, so only its BibTeX
entry is included (following the LIV-GS / RP-SLAM precedent noted in the
directory structure section above). `references.bib` now holds
**71 entries** (66 + 5 new); `papers/` now holds **66 PDFs** (62 + 4 new).

### GG. Panoramic 3DGS-SLAM (spherical-domain rendering)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **PanoGS-SLAM** (Mao et al.) | arXiv 2026 (Zhejiang Univ.) | Panoramic RGB (equirectangular) | First panoramic dense SLAM built on 3DGS; differentiable rendering and pose optimization directly in the spherical domain; sphere-consistent photometric loss compensating equirectangular area distortion; depth-guided Gaussian init for stable incremental mapping in newly observed regions; FoV-ablation shows monotonic improvement in optimization conditioning as angular coverage increases | Orthogonal sensing-geometry axis to Gaussian-LIC2's pinhole-LiDAR setup. Demonstrates that narrow-FoV is itself an optimization-landscape limitation for GS-SLAM; the sphere-consistent photometric loss is a rendering-domain correction that could complement Gaussian-LIC2's CT-B-spline + photometric factor when wide-FoV / panoramic cameras are added. No LiDAR, no IMU, no continuous-time factor |

### HH. Tightly-coupled LiDAR-Visual-Inertial GS-SLAM (LVI-GS family)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **LVI-GS** (Zhao et al.) | IEEE TIM 2025 (HKU ArcLab) | LIV | Tightly-coupled LIV mapping with 3DGS; Gaussians initialized from colourized LiDAR points, refined via differentiable rendering; pyramid (coarse-to-fine) training for multi-level feature learning; LiDAR-derived depth loss for geometric perception; custom CUDA acceleration, thread management, keyframe selection for real-time photo-realistic mapping | A direct LIV-Gaussian-SLAM competitor in the same sensor class as Gaussian-LIC2. LVI-GS uses a VIO-derived odometry front-end (poses from VIO, Gaussians refined separately) — no continuous-time B-spline factor graph, no depth-completion net. The pyramid coarse-to-fine training is a concrete efficiency recipe relevant to Gaussian-LIC2's online Gaussian optimization. Distinct from GS-LIVO (Addendum 9) which uses IESKF + Gaussian-map visual measurement; LVI-GS is the VIO-front-end + 3DGS-mapping design pole |

### II. LiDAR-Visual-Supervised GS-SLAM for unstructured environments

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **LVGS-SLAM** (Qian et al.) | RA-L Aug 2026 (UCAS) | LiDAR + RGB (no IMU) | Dense depth rendering & feedback: sparse LiDAR -> globally consistent pixel-level dense depth via 3DGS rendering (no extra NN), fed back to refine pose estimation; generative refinement module with a synthetic view bank colorizes untextured novel-view geometry and jointly refines Gaussians + poses; evaluated on Botanic Garden (unstructured) | Directly addresses the same sparse-LiDAR-to-dense-depth problem Gaussian-LIC2 solves with a learned depth-completion net — but without a neural network, instead exploiting the 3DGS-rendered depth itself as the densifier. This is a representation-native alternative to Gaussian-LIC2's SPNet/depth_completer module and is a useful comparison point for the "do we need a learned depth net?" question. No IMU, no continuous-time factor; unstructured-outdoor focus |

### JJ. Continuous-time Radar-IMU-LiDAR odometry (CT multi-modal lineage)

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **TRaIL-Odom** (Noh et al.) | RA-L 2026 (ETH + KAIST) | Radar + IMU + LiDAR | Tightly-coupled continuous-time Radar-IMU-LiDAR odometry with degeneracy-aware adaptive Doppler reweighting: per-point reweighting aligns radar Doppler with LiDAR-identified weak translational subspace; scan-wise gain scheduling emphasizes radar when LiDAR observability is poor, suppresses when reliable; 86.0% / 78.5% ATE / RTE reduction on degenerate sequences vs fixed-weight baseline | A continuous-time multi-modal odometry in the same CT-B-spline / Wildcat (Addendum 2) / Coco-LIC (this project's odometry backbone) lineage, but swapping the camera for radar. The degeneracy-aware adaptive sensor reweighting is a directly portable idea for Gaussian-LIC2's CT factor graph: the same per-direction observability analysis could adaptively weight the LiDAR, visual, and inertial residuals in degenerate scenes (e.g. long corridors, textureless walls). No Gaussian map, no photometric factor — purely an odometry contribution |

### KK. LiDAR-Visual GS-SLAM for dynamic outdoor scenes

| paper | venue | sensor | key idea | relation to Gaussian-LIC2 |
|-------|-------|--------|----------|----------------------------|
| **LVD-GS** (Zhu et al.) | arXiv 2025 (Southeast Univ.) | LiDAR + RGB | Hierarchical explicit-implicit collaborative rendering: Sem-Geo-DINO representation fuses semantic (Grounded SAM), geometric (LiDAR depth + DepthLab densification), and DINO features into multi-scale consistency loss; joint dynamic-mask module combines open-world segmentation with DINO-Depth uncertainty-based implicit residual constraints for fine-grained dynamic-object filtering; KITTI/nuScenes evaluation | Addresses the dynamic-object-handling gap that Gaussian-LIC2 (static-scene assumption) shares with most LIV-GS-SLAM systems. The DINO-feature loss and uncertainty-driven dynamic masking are a learned-semantic alternative to the geometry-only dynamic filtering in RoDyn-SLAM / Gassidy. Relevant for extending Gaussian-LIC2 to driving / urban scenes where dynamic objects dominate; the hierarchical representation collaboration is a structured way to inject semantic supervision into the Gaussian map without a separate semantic branch. No IMU, no continuous-time factor |

### Why these matter for Gaussian-LIC2 positioning

37. **The LIV-Gaussian-SLAM family keeps growing — and splitting.** With
    LVI-GS (TIM 2025), GS-LIVO (T-RO 2025, Addendum 9), and LVGS-SLAM
    (RA-L 2026) all published in the last year, the "LiDAR-Visual(-Inertial)
    + 3DGS" space now has three distinct design poles: (a) VIO front-end +
    separate Gaussian mapping (LVI-GS), (b) IESKF + Gaussian-map visual
    measurement (GS-LIVO), (c) depth-rendering feedback without a learned
    depth net (LVGS-SLAM). Gaussian-LIC2 occupies a fourth pole —
    continuous-time B-spline factor graph + learned depth completion — and
    these three new baselines sharpen what each design choice buys: LVI-GS
    shows pyramid training buys efficiency, GS-LIVO shows IESKF buys
    embedded deployability, LVGS-SLAM shows the Gaussian map itself can
    replace a depth-completion net.

38. **Representation-native depth densification vs learned depth
    completion.** LVGS-SLAM's dense-depth-rendering-feedback is the most
    direct alternative to Gaussian-LIC2's depth_completer / SPNet module:
    it densifies sparse LiDAR using the 3DGS-rendered depth field itself,
    with no extra neural network. This is a real design choice to
    acknowledge in the related-work discussion — Gaussian-LIC2's learned
    net buys supervised dense depth in LiDAR-blind areas, but at the cost
    of a network inference and a training corpus; LVGS-SLAM trades that
    for a self-supervised loop that depends on the Gaussian map already
    being geometrically reasonable. The two approaches could also
    compose: the learned net for cold-start / large-gap regions, the
    render-feedback loop for steady-state refinement.

39. **Degeneracy-aware adaptive sensor reweighting is portable to the CT
    factor graph.** TRaIL-Odom's per-direction observability analysis
    (identify weak translational subspace from LiDAR geometry, reweight
    radar Doppler to fill it) is a concrete recipe for adaptive residual
    weighting in a continuous-time factor graph. Gaussian-LIC2's CT
    B-spline tightly couples LiDAR, visual, and inertial residuals with
    fixed weights; TRaIL-Odom's scan-wise gain scheduling is a
    drop-in-pattern for making those weights scene-adaptive — emphasize
    visual photometry when LiDAR is geometrically degenerate (long
    corridor), emphasize LiDAR when visual is textureless (white wall).
    This directly addresses the robustness-in-degenerate-scenes concern
    noted across Addenda 2–9.

40. **Panoramic sensing geometry changes the GS-SLAM optimization
    landscape.** PanoGS-SLAM's controlled-FoV experiments showing
    monotonic improvement in optimization conditioning as angular
    coverage increases is a general result for differentiable
    Gaussian-based SLAM, not just a panoramic-camera trick. It quantifies
    *why* narrow-FoV pinhole GS-SLAM is fragile under rapid motion / large
    viewpoint changes — limited angular coverage weakens pose
    observability. For Gaussian-LIC2, this motivates (a) citing panoramic
    GS-SLAM as a complementary sensing-geometry direction, and (b)
    considering the sphere-consistent photometric loss formulation if a
    wide-FoV / fisheye / panoramic camera variant is ever explored. The
    CT-B-spline factor is orthogonal to and composable with this.

41. **Dynamic-scene handling via semantic-geometric collaboration.**
    LVD-GS's Sem-Geo-DINO hierarchical representation and uncertainty-driven
    dynamic masking is the most concrete dynamic-object-handling recipe in
    the LiDAR-Visual GS-SLAM family to date. Gaussian-LIC2, like most LIV
    GS-SLAM systems, assumes static scenes; LVD-GS shows a path to dynamic
    scenes that does not require a separate semantic-segmentation branch
    but instead fuses DINO features directly into the Gaussian
    optimization loss. For the urban / autonomous-driving extension
    direction (also touched by HGS-Mapping, Addendum 9), this is the
    relevant dynamic-scene baseline, and the DINO-feature loss is a
    learned-prior complement to the geometry-only dynamic filtering in
    Gassidy / RoDyn-SLAM.

### Reproducing the Addendum 10 survey

Searches run on 2026-09-17 via Doubao web search:
- "Gaussian Splatting SLAM LiDAR inertial camera fusion arxiv September 2026 new" (OneWeek)
- "3D Gaussian Splatting SLAM real-time dense mapping arxiv 2026 September new" (OneWeek)
- "continuous-time LiDAR inertial visual odometry gaussian splatting 2026 arxiv" (OneMonth)
- "gaussian splatting SLAM loop closure global consistency 2026 arxiv September new" (OneWeek)
- "LVI-GS Tightly Coupled LiDAR-Visual-Inertial SLAM 3D Gaussian Splatting Zhao arxiv"
- "LVGS-SLAM LiDAR-Visual-Supervised Gaussian Splatting dense depth rendering arxiv Qian"
- "EGS-SLAM RGB-D Gaussian Splatting events arxiv" (OneYear)
- "TRaIL-Odom continuous time radar IMU LiDAR odometry Doppler arxiv"

arXiv abstract pages and IEEE Xplore were fetched to confirm author
lists, venues, and DOIs. Four papers have arXiv preprints and were
downloaded: PanoGS-SLAM (arXiv:2609.17387), LVI-GS (arXiv:2411.02703,
TIM 2025), TRaIL-Odom (arXiv:2609.03561, RA-L 2026), LVD-GS
(arXiv:2510.22669). LVGS-SLAM (RA-L Aug 2026, DOI:10.1109/LRA.2026.3707359)
is IEEE-only with no arXiv preprint; only its BibTeX entry is included,
following the LIV-GS / RP-SLAM precedent.

### Updated `papers/` inventory (66 PDFs)

The five new additions (Sections GG–KK) are:
Mao2026_PanoGSSLAM, Zhao2025_LVIGS, Qian2026_LVGSSLAM (bib only, no PDF),
Noh2026_TRAILOdom, Zhu2025_LVDGS.

---

## Addendum 11 (2026-09-18) — two newly surveyed related works

**24-hour code-review note.** No commits or working-tree changes to the
Gaussian-LIC2 source tree in the last 24 hours (last commit `793b9bc`,
2026-08-08). The untracked `latex/`, `scripts/`, `.zcode/` directories and
the loose PDFs in the repo root remain from prior survey rounds. Nothing in
the codebase requires action this round; this addendum is a pure
related-work update.

Two new papers identified via Doubao web search (OneWeek / OneMonth) and
not previously in `papers/`:

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| LL | **Super Odometry 2.0** (Zhao et al., arXiv:2608.25427, Science Robotics 2025) | Sci. Robotics, Dec 2025; preprint 26 Aug 2026 | Camera + LiDAR + IMU (no depth sensor assumed) | Hierarchical degradation adaptation: adaptive feature selection (visual) -> adaptive state direction (LiDAR) -> adaptive factor/engine selection (mixed) -> learned IMU odometry fallback. IMU elevated to equal-rank sensor via self-supervised imperative learning; validated across 200 km / 800 h on aerial, wheeled, legged robots. | Gaussian-LIC2's CT B-spline fuses LiDAR+visual+inertial residuals with fixed weights. Super Odometry 2.0's *adaptive engine/factor selection* — reweighting or swapping residual sources per-direction based on detected degeneracy — is a directly transferable pattern for making the CT factor graph scene-adaptive. The learned-IMU fallback (imperative learning, IMU as equal-rank sensor) is the strongest published argument yet that inertial data deserves first-class residual weighting, which aligns with Gaussian-LIC2's tight IMU coupling. Degeneracy-aware reweighting complements TRaIL-Odom's Doppler-gain scheduling (Addendum 10) and addresses the robustness-in-degenerate-scenes concern noted across Addenda 2-10. |
| MM | **LV-GS SLAM** (He et al., Applied Sciences 16(16):8028, Aug 2026) | MDPI Applied Sciences, open access, 8 Aug 2026 | LiDAR + Visual (decoupled, no IMU) | Decoupled LiDAR-odometry frontend (30 Hz LiDAR, 15-19 Hz tracking) + incremental 3DGS mapping. Two technical novelties: (1) **depth propagation** initializes Gaussians from dense depth maps derived from LiDAR, giving 9x faster PSNR convergence vs. direct sparse-LiDAR Gaussian init; (2) keyframe-based submap management that dynamically allocates GPU memory by primitive density + inter-frame overlap, preventing OOM at large scale. Validated on KITTI and a quadruped robot. | LV-GS SLAM targets the *large-scale / KITTI* regime that Gaussian-LIC2's indoor/room-scale evaluation does not directly cover. Its **depth-propagation Gaussian initialization** is a concrete recipe for bridging sparse-LiDAR geometry and dense-3DGS rendering — directly relevant to how Gaussian-LIC2 initializes Gaussians from LiDAR in texture-poor regions. Its **submap memory management** (density + overlap-based allocation) is a deployable answer to the GPU-OOM concern that limits LIV-GS-SLAM systems at scale. The decoupled (non-tightly-coupled) LiDAR frontend is a contrasting design point to Gaussian-LIC2's tight CT coupling, useful as a baseline to argue for the tight-coupling trade-off. |

### Why these matter

42. **Adaptive residual weighting is the next step beyond fixed-weight CT
fusion.** Super Odometry 2.0's four-tier degradation hierarchy — each tier
activated only when the lower tier's adaptation is exhausted — is a
principled alternative to the fixed residual weights used in Gaussian-LIC2's
CT B-spline factor graph. The key insight is that degeneracy is
*directional* (a long corridor degenerates along the corridor axis but not
perpendicular to it), so a single scalar weight per sensor is wasteful:
Super Odometry 2.0 reweights per-point and per-direction based on alignment
with the weak subspace. This generalizes TRaIL-Odom's Doppler-gain
scheduling (Addendum 10, radar-LiDAR) to the camera-LiDAR-IMU triad that
Gaussian-LIC2 uses, and provides a concrete, validated mechanism for the
"robustness in degenerate scenes" thread that has recurred across Addenda
2-10. For the paper, this is the strongest citation for *why* fixed weights
are a limitation and *what* adaptive reweighting buys.

43. **Learned IMU as a first-class residual, not just a motion prior.**
Super Odometry 2.0's most provocative claim is elevating IMU to "equal
importance with camera and LiDAR" via a learned inertial odometry module
trained on 100+ hours of heterogeneous robot data, with online
self-supervised adaptation through imperative learning. Gaussian-LIC2 uses
IMU as the backbone of its CT B-spline (the spline is anchored to IMU
preintegrations), which is already a strong inertial commitment; Super
Odometry 2.0 argues the IMU should also contribute a *standalone* odometry
residual that can take over when both exteroceptive sensors fail. This is a
distinct and more aggressive inertial-fusion philosophy worth citing as a
future direction — especially for deployment scenarios (smoke, snow,
low-light) where Gaussian-LIC2's visual+LiDAR residuals both degrade
simultaneously.

44. **Bridging sparse LiDAR and dense 3DGS via depth propagation.** LV-GS
SLAM's depth-propagation initialization — deriving dense depth maps from
sparse LiDAR scans and using them to seed 3D Gaussians — achieves 9x faster
PSNR convergence than initializing Gaussians directly from the sparse LiDAR
point cloud. This is a concrete, quantified answer to the sparse-LiDAR
initialization problem that affects all LIV-GS-SLAM systems including
Gaussian-LIC2, where the quality of the initial Gaussian set strongly
influences tracking stability in newly-observed regions. PanoGS-SLAM
(Addendum 10) addressed this for panoramic cameras via depth-guided init;
LV-GS SLAM addresses it for LiDAR-visual systems specifically. For
Gaussian-LIC2, this is a directly applicable improvement to the Gaussian
initialization step and a citable baseline for the convergence-speed
advantage of dense-prior initialization.

45. **Submap memory management for large-scale LIV-GS-SLAM.** LV-GS SLAM's
keyframe-based submap framework — dynamically adjusting GPU memory
allocation based on primitive density *and* inter-frame overlap ratio — is
the most concrete published recipe for preventing GPU OOM in large-scale
3DGS-SLAM. Gaussian-LIC2's evaluation is primarily indoor/room-scale; the
urban / autonomous-driving extension direction (touched by HGS-Mapping
(Addendum 9) and LVD-GS (Addendum 10)) needs exactly this kind of memory
management to be tractable. The density+overlap metric is a simple,
deployable heuristic that complements the more aggressive learned pruning
in MonoGS / SplaTAM and is worth citing as the scalable-deployment
baseline.

### Reproducing the Addendum 11 survey

Searches run on 2026-09-18 via Doubao web search:
- "Gaussian Splatting SLAM LiDAR inertial camera fusion arxiv September 2026 new" (OneWeek)
- "3D Gaussian Splatting SLAM real-time dense mapping arxiv 2026 September new" (OneWeek)
- "continuous-time LiDAR inertial visual odometry gaussian splatting 2026 arxiv" (OneMonth)
- "gaussian splatting SLAM loop closure global consistency 2026 arxiv September new" (OneWeek)
- "Gaussian splatting SLAM arxiv 2609 2608 LiDAR visual inertial new method" (OneMonth)
- "Super Odometry resilient odometry hierarchical adaptation arxiv 2608.25427"

arXiv abstract pages and the MDPI / Science Robotics landing pages were
fetched to confirm author lists, venues, and DOIs. PanoGS-SLAM, TRaIL-Odom,
LVD-GS (all Addendum 10) and CGS-SLAM (Addendum 8) were re-encountered but
already in the inventory, so they are not re-added.

**PDF availability.** Super Odometry 2.0 has an arXiv preprint and was
downloaded: `papers/Zhao2026_SuperOdometry.pdf` (arXiv:2608.25427). LV-GS
SLAM is MDPI open-access but MDPI's PDF endpoint returns HTTP 403 to
non-interactive clients (verified via `curl` and the in-app browser
download path); only its BibTeX entry is included, following the LIV-GS /
RP-SLAM / LVGS-SLAM IEEE-only precedent.

### Updated `papers/` inventory (67 PDFs)

The two new additions (Sections LL-MM) are:
Zhao2026_SuperOdometry (PDF + bib), He2026_LVGSSLAM (bib only, no PDF —
MDPI blocks automated PDF retrieval).

## Addendum 12 (2026-09-19) — two newly surveyed related works

**24-hour code-review note.** No commits or working-tree changes to the
Gaussian-LIC2 source tree in the last 24 hours (last commit `793b9bc`,
2026-08-08). The untracked `latex/`, `scripts/`, `.zcode/` directories and
the loose PDFs in the repo root remain from prior survey rounds. Nothing in
the codebase requires action this round; this addendum is a pure
related-work update.

Two new papers identified via Doubao web search (OneWeek / OneMonth / OneYear)
and not previously in `papers/`:

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| NN | **Robust 3DGS-SLAM via Adaptive Kernel Smoothing** (Zhang et al., ECCV 2026; arXiv:2511.23221, v3 30 Jun 2026) | ECCV 2026 (Springer); preprint 28 Nov 2025 | RGB-D | Argues that *rasterizer robustness to Gaussian-parameter noise* matters more for tracking than rendering fidelity. Proposes **Corrective Blurry KNN (CB-KNN)**: during keyframe rendering only, transiently shift each pixel's K-nearest Gaussians toward their centroid and replace their RGB with a locally-adaptive weighted average, producing a deliberately blurred image that smooths the photometric-alignment loss landscape (Graduated Non-Convexity). The underlying map is *not* modified — smoothing is transient and keyframe-only, so scene fidelity is preserved while the pose-optimization basin widens. Plug-and-play into existing 3DGS-SLAM frameworks (validated with MonoGS). | Gaussian-LIC2's tracking relies on differentiable rendering of LiDAR-initialized Gaussians whose parameters are noisy in newly observed / texture-poor regions — exactly the regime CB-KNN targets. The keyframe-only, map-preserving smoothing is directly applicable to Gaussian-LIC2's CT-spline tracking: it widens the convergence basin during the per-frame photometric alignment without corrupting the persistent Gaussian map, addressing the "fast-motion / large viewpoint change" tracking failures noted across Addenda 2-11. The Graduated-Non-Convexity framing is a principled justification for *why* a slightly blurred render tracks better, and complements the degeneracy-aware adaptive reweighting thread (Super Odometry 2.0, Addendum 11) — CB-KNN regularizes the *rendering* side while adaptive reweighting regularizes the *residual-weighting* side. Worth citing as a low-cost robustness mechanism for the tracking front-end. |
| OO | **BDGS-SLAM: A Probabilistic 3D Gaussian Splatting Framework for Robust SLAM in Dynamic Environments** (Yang et al., Sensors 25(21):6641, Oct 2025) | MDPI Sensors, open access, 30 Oct 2025 | RGB-D (visual SLAM, no LiDAR/IMU) | Targets dynamic-environment 3DGS-SLAM. Integrates YOLOv5 semantic detection with a **Bayesian filter** that recursively updates each Gaussian's dynamic/static posterior probability (replacing hard binary labels). A **multi-view probabilistic update** with exponential-decay weighting aggregates co-visible keyframe observations to *recover* static Gaussians misclassified as dynamic. An **adaptive soft-penalty** optimization suppresses dynamic Gaussians' opacity contribution (rather than hard deletion), preserving static structure. Achieves SOTA ATE among dynamic 3DGS-SLAM methods on TUM RGB-D, BONN Dynamic, OpenLoris-Scene. | Gaussian-LIC2's current evaluation is static-scene; the dynamic-object handling gap has been flagged as a future direction since Addendum 2. BDGS-SLAM's *probabilistic-per-Gaussian* dynamic labeling (Bayesian posterior over time, not per-frame binary masks) is the most directly transferable dynamic-handling recipe for a 3DGS map, because it operates on the Gaussian primitives Gaussian-LIC2 already maintains. The multi-view recovery of misclassified static Gaussians and the soft-penalty (non-deletion) strategy both avoid the map-completeness loss that plagues hard-mask approaches — relevant if Gaussian-LIC2 extends to populated indoor/outdoor scenes. Although BDGS-SLAM is RGB-D only (no LiDAR/IMU), the Bayesian-per-Gaussian formulation is sensor-agnostic and could ingest LiDAR-derived dynamic-object semantics. Cite as the probabilistic-dynamic-handling baseline for 3DGS-SLAM. |

### Why these matter

46. **Transient render-side regularization decouples tracking robustness from
map fidelity.** Adaptive Kernel Smoothing's central insight — that the
rendered image used for pose alignment can be *deliberately blurred*
(transiently, without touching the stored map) to widen the optimization
basin — is a clean, low-cost addition to the 3DGS-SLAM tracking toolbox.
For Gaussian-LIC2, whose CT-spline tracking runs photometric alignment on
noisy LiDAR-initialized Gaussians in newly observed regions, this is a
near-zero-cost robustness lever: the smoothing is applied only at keyframes,
preserves the persistent map, and integrates as a plug-in to the existing
rasterizer. The Graduated-Non-Convexity framing gives a theoretical handle
for *why* it works (smoothed loss landscape bypasses sharp local minima from
outlier Gaussians), which strengthens the related-work argument for
tracking-robustness beyond just "better initialization" (LV-GS SLAM,
Addendum 11) or "adaptive residual weights" (Super Odometry 2.0, Addendum
11). Together these three form a layered robustness story: init quality,
residual weighting, and render-side smoothing.

47. **Probabilistic per-Gaussian dynamic labeling is the right granularity for
3DGS-SLAM.** BDGS-SLAM's Bayesian-per-Gaussian posterior (recursively updated
across frames, fused across co-visible keyframes with exponential decay) is a
better fit for explicit Gaussian maps than per-frame semantic masks, because
the map's primitive is the Gaussian itself. The two design choices most
relevant to Gaussian-LIC2 are (i) the multi-view *recovery* of static
Gaussians that were transiently misclassified as dynamic — this directly
addresses the map-completeness loss that hard-mask dynamic filtering causes,
and (ii) the *soft-penalty* optimization that suppresses dynamic-Gaussian
opacity rather than deleting them, leaving the door open to re-include them
if they later become static. For a LiDAR-visual-inertial system like
Gaussian-LIC2 that may deploy in populated scenes, this is the most
transferable dynamic-handling recipe surveyed, and it is sensor-agnostic: the
Bayesian filter could ingest LiDAR-based moving-object segmentation in
addition to YOLOv5. Cite as the probabilistic-dynamic baseline that
Gaussian-LIC2's static-scene evaluation would extend toward.

### Reproducing the Addendum 12 survey

Searches run on 2026-09-19 via Doubao web search:
- "Gaussian Splatting SLAM LiDAR inertial camera fusion arxiv September 2026 new" (OneWeek)
- "3D Gaussian Splatting SLAM real-time dense mapping arxiv 2026 September new method" (OneWeek)
- "gaussian splatting SLAM LiDAR visual inertial odometry 2026 arxiv new method continuous-time" (OneMonth)
- "gaussian splatting SLAM loop closure global consistency 2026 arxiv September new" (OneWeek)
- "3DGS SLAM dynamic scene removal robust tracking arxiv 2609 2026" (OneMonth)
- "BDGS-SLAM Bayesian dynamic gaussian splatting SLAM arxiv" (OneYear)
- "Adaptive Kernel Smoothing 3DGS SLAM arxiv CB-KNN ECCV 2026" (OneYear)
- "LiDAR inertial visual gaussian splatting radiance field mapping 2026 arxiv new tight coupling" (OneMonth)

PanoGS-SLAM (Addendum 10), LightSplat (Addendum 10), MCGS-SLAM (Addendum 8),
GRAND-SLAM (Addendum 10), LV-GS SLAM (Addendum 11), Gassidy (Addendum 9),
FeatureSLAM (Addendum 10), LVI-GS (Addendum 7), GS-SDF (Addendum 7) were
re-encountered but already in the inventory, so they are not re-added.

**PDF availability.** Adaptive Kernel Smoothing has an arXiv preprint and was
downloaded: `papers/Zhang2026_AdaptiveKernel.pdf` (arXiv:2511.23221, 6.96 MB,
verified PDF 1.7 with title-text markers). BDGS-SLAM is MDPI Sensors
open-access but MDPI's PDF endpoint returns HTTP 403 to non-interactive
clients (verified via `curl`); only its BibTeX entry is included, following
the LV-GS SLAM / IEEE-only precedent established in Addendum 11.

### Updated `papers/` inventory (68 PDFs)

The two new additions (Sections NN-OO) are:
Zhang2026_AdaptiveKernel (PDF + bib), Yang2025_BDGSSSLAM (bib only, no PDF —
MDPI blocks automated PDF retrieval).

## Addendum 13 (2026-09-20) — three newly surveyed related works

**24-hour code-review note.** No commits or working-tree changes to the
Gaussian-LIC2 source tree in the last 24 hours (last commit `793b9bc`,
2026-08-08, unchanged since Addendum 12). The untracked `latex/`,
`scripts/`, `.zcode/` directories and the loose PDFs in the repo root remain
from prior survey rounds. Nothing in the codebase requires action this
round; this addendum is a pure related-work update.

Three new papers identified via Doubao web search (OneWeek / OneMonth) and
not previously in `papers/`:

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| PP | **SCOUT-SLAM: Structurally-Coupled Dual Uncertainty-Aware 3DGS SLAM in the Wild** (Karthik, Jois, Sundaram; arXiv:2609.14634, submitted 13 Sep 2026) | arXiv preprint, 13 Sep 2026 | RGB-D (visual SLAM, no LiDAR/IMU) | Identifies a *circular dependency* in dynamic-environment 3DGS-SLAM: tracking accuracy depends on reconstruction stability, which depends on tracking accuracy, so reconstruction instabilities degrade uncertainty modeling, which degrades tracking, which degrades reconstruction. Breaks the cycle with a **structurally-coupled dual-uncertainty framework**: both tracking and reconstruction uncertainty are estimated from a *shared* base network. A **LoRA adapter** trained on multi-view feature consistency produces a tracking uncertainty that does *not* depend solely on reconstruction quality, decoupling the two. A **spatially-adaptive prior** modulates the training objective so that reconstruction instability does not inflate uncertainty on static regions, keeping the shared representation intact for both branches. SOTA camera tracking + artifact-free static scene reconstruction on TUM RGB-D, Bonn Dynamic, Wild-SLAM MoCap. | Gaussian-LIC2's tracking uses photometric alignment against a LiDAR-initialized Gaussian map whose quality varies sharply between well-observed and newly observed regions — exactly the regime where tracking-vs-reconstruction circular dependency bites. SCOUT-SLAM's *shared-network dual-uncertainty* formulation is the most principled uncertainty treatment surveyed: instead of bolting a separate confidence predictor onto the tracker, it estimates tracking and reconstruction uncertainty from the same backbone with a LoRA branch that decouples tracking confidence from reconstruction quality. The LoRA-on-multi-view-feature-consistency idea is directly portable to Gaussian-LIC2's CT-spline tracking — the multi-view consistency signal is already implicit in the keyframe structure, and a lightweight adapter would not perturb the dense map. The spatially-adaptive prior (suppress uncertainty inflation on static regions during reconstruction instability) is a clean answer to the "newly observed region" noise problem flagged across Addenda 2–12. Cite as the uncertainty-decoupling baseline for 3DGS-SLAM in cluttered/dynamic scenes. |
| QQ | **EliGSiR: Continual RGB-D Mapping with Gaussian Splatting under Bounded Compute** (Ellensohn, Rueckert, Rauch; arXiv:2609.20348, submitted 17 Sep 2026) | arXiv preprint, 17 Sep 2026 | RGB-D (visual mapping, no LiDAR/IMU) | Reframes online Gaussian mapping as a **bounded-budget continual-learning** problem. Three mechanisms control how the optimization budget is spent as the map evolves: (1) **Map-Guided View Scheduling** filters redundant incoming views and reconsiders retained views according to the *current state of the map* — views are dropped if the map already explains them well, and re-attended if the map has since improved in their region; (2) **Load-Adaptive Fidelity** adjusts supervision resolution to current mapping load instead of a fixed schedule, spending more pixels where the map is uncertain and fewer where it is settled; (3) **Targeted Geometry Growth** separates depth supervision from Gaussian *creation*, adding geometric capacity only where repeated RGB-D observations indicate missing or misplaced structure (preventing the Gaussian-count explosion that plagues naive densification). On TUM RGB-D fr3/long_office_household, 21.52 dB vs 19.42 dB for SplaTAM at GT poses; with live ORB-SLAM3 poses, 23.02 dB in 155.5 s vs 20.10 dB in 230.9 s for CaRtGS using its native tracker. Evaluated on Replica, TUM RGB-D, ScanNet++, real sensor sequences, including reconstruction quality *throughout* acquisition (not just final). | Gaussian-LIC2's Gaussian map grows continuously as the platform moves, and the question of *where to spend optimization effort* — which keyframes to revisit, which regions to densify, at what resolution to supervise — is an open engineering lever for the system. EliGSiR's three-pronged budget control is the most explicit treatment of this problem in the 3DGS-mapping literature: Map-Guided View Scheduling is a principled answer to Gaussian-LIC2's keyframe-selection and map-refinement policy (revisit views only where the map has since improved), Load-Adaptive Fidelity maps onto the variable-resolution supervision that a LiDAR-initialized map naturally calls for (dense supervision in LiDAR-rich regions, coarser in texture-only regions), and Targeted Geometry Growth directly addresses the Gaussian-count-growth problem that limits Gaussian-LIC2's long-sequence scalability. The "reconstruction quality throughout acquisition" evaluation protocol is also a better fit for an online SLAM system than the final-frame-only PSNR used by most 3DGS-SLAM benchmarks. Cite as the bounded-compute continual-mapping baseline whose view-scheduling and geometry-growth policies transfer to LiDAR-visual-inertial Gaussian mapping. |
| RR | **RawSLAM: Online HDR Gaussian SLAM from Linear Radiance** (Orozco González, Merino; arXiv:2609.20589, submitted 17 Sep 2026) | arXiv preprint, 17 Sep 2026 | RGB-D (+ IMU available in the released dataset) | First **online Gaussian SLAM operating directly on single-exposure 16-bit linear HDR imagery** rather than 8-bit tonemapped LDR. Three components: (1) an architecture-agnostic **HDR Gaussian Splatting module** with an *MLP-free logarithmic parameterization* of Gaussian color features — replacing the spherical-harmonic / MLP color head with a log-space representation that behaves well across the full radiance range; (2) a **Reinhard range-compressed photometric objective** that compresses the loss into a tractable range without throwing away HDR information; (3) **structure-guided spatial gradient weighting** that emphasizes edges consistent with scene geometry. Outperforms an HDR adaptation of MonoGS in both trajectory and reconstruction accuracy while rendering natively in linear scene radiance for post-rendering tone mapping. The same formulation runs unchanged on standard 8-bit inputs, roughly *halving* the MonoGS baseline error, and transfers seamlessly to SplaTAM, Gaussian SLAM, and DROID-W, eliminating all their tracking failures on challenging-illumination sequences. Releases the **RawSLAM dataset**: 10 real-world indoor sequences with 16-bit RAW imagery, aligned depth, IMU measurements, and external OptiTrack poses. | Gaussian-LIC2, like nearly all 3DGS-SLAM systems, consumes 8-bit tonemapped images and is therefore brittle in extreme lighting (shadows, highlights, indoor-outdoor transitions) — a robustness gap that has not been directly addressed in the survey until now. RawSLAM's log-space color parameterization and Reinhard-compressed photometric loss are the first concrete recipe for bringing HDR robustness into a Gaussian-SLAM tracker, and the architecture-agnostic module design means it could slot into Gaussian-LIC2's rendering path with the LiDAR depth initialization preserved. The striking result that the same formulation *halves* MonoGS error on standard 8-bit inputs suggests the log-space color head is a better representation even outside the HDR regime — relevant to Gaussian-LIC2's phot
ometric tracking under normal lighting, not just HDR. Cite as the HDR-robustness recipe for Gaussian-SLAM trackers and as evidence that log-space color heads improve 8-bit tracking too. |

### Why these matter

48. **Decouple tracking uncertainty from reconstruction quality.** SCOUT-SLAM shows the circular dependency between tracking accuracy and reconstruction stability is a real failure mode in 3DGS-SLAM, and that a LoRA adapter on multi-view feature consistency can produce a tracking uncertainty that does not collapse when the map is noisy. This is the most portable single idea of the round for Gaussian-LIC2: the multi-view consistency signal is already implicit in its keyframe structure, and a lightweight adapter would not perturb the LiDAR-initialized dense map. It also gives a principled answer to the "newly observed region" noise problem flagged across Addenda 2-12.

49. **Treat online mapping as a bounded-budget continual-learning problem.** EliGSiR is the first work in the survey to explicitly formulate *where to spend optimization effort* — which views to revisit, at what resolution to supervise, where to add Gaussians — as a budget-control problem driven by the current map state. Map-Guided View Scheduling, Load-Adaptive Fidelity, and Targeted Geometry Growth map directly onto Gaussian-LIC2's keyframe-selection, variable-resolution supervision (dense in LiDAR-rich regions, coarser in texture-only regions), and Gaussian-count-growth problems, and the "reconstruction quality throughout acquisition" evaluation protocol is a better fit for an online SLAM system than final-frame-only PSNR.

50. **Bring HDR robustness in via a log-space color head.** RawSLAM's MLP-free logarithmic parameterization of Gaussian color features, paired with a Reinhard range-compressed photometric loss, is the first concrete recipe for making a Gaussian-SLAM tracker robust to extreme lighting. The architecture-agnostic module slots into Gaussian-LIC2's rendering path with the LiDAR depth initialization preserved, and the result that the same formulation *halves* MonoGS error on standard 8-bit inputs suggests the log-space color head is a better representation even outside the HDR regime — relevant to Gaussian-LIC2's photometric tracking under normal lighting, not just HDR.

### Reproducing the Addendum 13 survey

Doubao web search (`mcp__doubao-search__web_search`), all run 2026-09-20:

1. `3DGS SLAM 2026` — TimeRange OneWeek, Count 25
2. `Gaussian Splatting SLAM uncertainty` — TimeRange OneMonth, Count 25
3. `HDR Gaussian Splatting SLAM` — TimeRange OneMonth, Count 20
4. `continual learning Gaussian Splatting mapping` — TimeRange OneMonth, Count 20

Candidate papers were cross-checked against the existing `papers/` inventory and the `references.bib` entry list; three were genuinely new (SCOUT-SLAM, EliGSiR, RawSLAM). Previously surveyed candidates that re-appeared in the results were ruled out: PanoGS-SLAM (Addendum 10), LV-GS SLAM (Addendum 11, `he2026lvgsslam`), LightSplat (Addendum 10), CGS-SLAM (Addendum 8), LVI-GS (Addendum 7), GS-LIVO (Addendum 6), LVGS-SLAM (Addendum 11).

### PDF availability

All three new papers have arXiv PDFs and were downloaded to `papers/`:

- `Karthik2026_SCOUTSLAM.pdf` (arXiv:2609.14634, PDF 1.7)
- `Ellensohn2026_EliGSiR.pdf` (arXiv:2609.20348, PDF 1.7)
- `Orozco2026_RawSLAM.pdf` (arXiv:2609.20589, PDF 1.7)

### Updated `papers/` inventory (71 PDFs)

The three new additions (Sections PP-RR) are:
Karthik2026_SCOUTSLAM.pdf, Ellensohn2026_EliGSiR.pdf, Orozco2026_RawSLAM.pdf.

`references.bib` now holds 78 entries (`grep -c "^@" references.bib` = 78).

## Addendum 14 (2026-09-21) — four newly surveyed related works

**24-hour code-review note.** No commits or working-tree changes to the
Gaussian-LIC2 source tree in the last 24 hours (last commit `793b9bc`,
2026-08-08, unchanged since Addendum 12/13). The untracked `latex/`,
`scripts/`, `.zcode/` directories and the loose PDFs in the repo root
remain from prior survey rounds. Nothing in the codebase requires action
this round; this addendum is a pure related-work update.

**Search method note.** The Doubao web-search API (`mcp__doubao-search`)
returned `10500 Internal Service Error` on every call this round (six
attempts across ~2 minutes, both `OneWeek` and `OneMonth` ranges).
Falling back to the **arXiv API** (`export.arxiv.org/api/query`) gave
reliable, current results; queries used are recorded in the reproduction
section below. Doubao should be retried next round, but arXiv is a
serviceable substitute for this survey's needs.

Four new papers identified via arXiv API queries and not previously in
`papers/`:

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| SS | **VGGT-GS SLAM: Uncalibrated Monocular Gaussian Splatting SLAM with Feed-Forward Priors** (Han, Wang, Cao, Liu; arXiv:2609.19628, submitted 17 Sep 2026) | arXiv preprint, 17 Sep 2026 | Monocular RGB (no LiDAR/IMU) | Tackles the **uncalibrated** setting most 3DGS-SLAM systems sidestep. Uses **feed-forward VGGT priors** for monocular pose and depth to bootstrap submap differentiable bundle adjustment that *jointly* refines camera poses and a 3D Gaussian map, and optimizes **submap-shared intrinsics and radial–tangential distortion through analytic calibration Jacobians**. Introduces **Gaussian-native alignment (GNA)** for camera-anchored scale refinement between submaps and to verify loop closures. Reports consistent improvements in localization accuracy and strong rendering quality on standard indoor benchmarks, positioning itself as a strong baseline for uncalibrated Gaussian SLAM. | Gaussian-LIC2 assumes calibrated intrinsics and a known LiDAR-camera extrinsic — the calibration pipeline is a real deployment friction point. VGGT-GS SLAM is the first surveyed work to **jointly optimize intrinsics + radial–tangential distortion inside the Gaussian-SLAM BA loop** with analytic Jacobians, and its **GNA camera-anchored scale refinement** between submaps is a clean answer to the submap-scale-drift problem that long sequences produce in any submap-based Gaussian-SLAM system. The feed-forward-prior bootstrapping also offers a fallback for keyframes where the LiDAR depth initialization is poor (e.g. featureless walls at close range). Cite as the uncalibrated / joint-intrinsic-calibration baseline for 3DGS-SLAM and as a reference for submap scale-alignment via Gaussian-native alignment. |
| TT | **Stipple: Real-Time Incremental Gaussian Splatting with Visual-Inertial Tracking** (Northoff, de Mayo, Cremers; arXiv:2608.00931, submitted 2 Aug 2026) | arXiv preprint, 2 Aug 2026 | Monocular RGB + IMU (visual-inertial) | A **VI-driven incremental 3DGS** system of the same family as Gaussian-LIC2. A **Basalt-based visual-inertial odometry** frontend feeds an **incremental 3DGS backend built on Brush** (an efficient Rust-based, GPU-vendor-agnostic 3DGS implementation). Substitutes 3DGS's heavy one-shot preprocessing with an **incremental training strategy driven by the VI tracker**, plus several efficiency improvements to keep the training thread real-time alongside tracking. Demonstrates that a standard VIO/SLAM tracker plus an incremental Gaussian backend is a viable real-time pipeline. | This is the most directly comparable system to Gaussian-LIC2 in the survey along the *sensor-modality axis minus LiDAR*: it is a **visual-inertial tracker coupled to an incremental 3DGS mapper**, exactly Gaussian-LIC2's architecture with the LiDAR depth-initialization arm removed. The Brush-based Rust backend is a concrete alternative rendering/training stack to Gaussian-LIC2's CUDA rasterizer, and the incremental training-from-VI-poses strategy mirrors Gaussian-LIC2's keyframe-fed mapping loop. The core contrast to draw in the related-work section is that **without LiDAR depth initialization the VI tracker alone must carry both pose and scale**, which is where Gaussian-LIC2's LiDAR arm earns its keep — Stipple is the clean ablation baseline that shows what the LiDAR buys. Cite as the VI-only incremental-3DGS baseline. |
| UU | **GLAM-SLAM: Real-time Gaussian Large-scale Mapping via Flow Densification and Spatial Decomposition** (Mermigkas, Manetas, Maragos; arXiv:2607.21416, submitted 23 Jul 2026) | arXiv preprint, 23 Jul 2026 | Monocular RGB (feature-based SLAM frontend, no LiDAR/IMU) | Targets the **long-sequence GPU-memory and real-time scaling** failure mode of monocular 3DGS-SLAM. A **decoupled** architecture: robust feature-based SLAM frontend for tracking + a **structured sparse anchor-grid** mapping representation. Introduces a **geometry-based flow-densification anchoring strategy** and a **scene-partitioning method with MLP initializations** to generate localized Gaussians per partition. On KITTI, Oxford RobotCar, and Málaga reports a **15% reconstruction-quality improvement** while maintaining real-time scaling to large outdoor scenes. | Gaussian-LIC2's Gaussian map grows continuously and unbounded across long trajectories — the **Gaussian-count explosion and GPU-memory growth** problem flagged across prior addenda is its primary long-sequence scalability bottleneck. GLAM-SLAM's three mechanisms are the most explicit treatment of large-scale Gaussian-mapping scalability in the survey: the **structured sparse anchor grid** is a memory-bounded alternative to a flat Gaussian pool, the **flow-densification anchoring** adds capacity only where geometry demands it (directly addressing the count-explosion problem), and the **scene partitioning with localized MLP-initialized Gaussians** is a clean way to keep per-region training tractable as the map grows. The outdoor large-scale evaluation (KITTI/RobotCar/Málaga) is also the evaluation regime Gaussian-LIC2's outdoor extension would face. Cite as the large-scale real-time Gaussian-mapping scalability baseline. |
| VV | **LXD-SLAM: LiDAR+X Dense SLAM with Configurable Sensor Combinations** (Wang, Zhang, Li, Shen, Zhang, Shi, Zhao; arXiv:2606.27811, submitted 26 Jun 2026) | arXiv preprint, 26 Jun 2026 | LiDAR-centric multi-sensor (LiDAR + Camera + IMU + Wheel Encoder + GNSS; up to 32 sensor combinations) | A **LiDAR-centric, plug-and-play multi-sensor fusion framework** — not a Gaussian-Splatting system, but a direct comparison point on the multi-sensor fusion axis. A **mathematically unified Iterative Error-State Kalman Filter with an adaptive hierarchical prediction strategy** fuses any subset of the supported sensors; updates minimize **point-to-mesh distances and visual reprojection errors**. The environment is modeled as **continuous multi-layered Gaussian-Process sub-meshes**, enabling efficient **ray-to-mesh depth recovery for visual features**. Global consistency via an **Extended Scan Context descriptor** derived from the GP sub-meshes plus a **Bidirectional PnP optimization** for robust multi-modal loop closure. Matches or exceeds specialized odometry SOTAs while generating high-fidelity globally consistent dense meshes in real time. | LXD-SLAM is the closest surveyed analogue to Gaussian-LIC2 on the **sensor-fusion architecture axis**: it is **LiDAR-centered, supports plug-and-play camera+IMU+GNSS, and produces a dense mesh in real time** — the same design points Gaussian-LIC2 hits, but with a **Gaussian-Process sub-mesh** map representation instead of Gaussian Splatting. The contrast is instructive: LXD-SLAM's unified IEKF + GP-sub-mesh formulation gives a cleaner mathematical fusion story across arbitrary sensor subsets, while Gaussian-LIC2 trades that modularity for the rendering quality and differentiability of a 3DGS map. The **Extended Scan Context + Bidirectional PnP loop-closure** pipeline is also a concrete, evaluable alternative to Gaussian-LIC2's loop-closure handling (an open engineering lever noted in prior addenda). Cite as the LiDAR-centric modular multi-sensor dense-SLAM baseline and as a reference for GP-sub-mesh map representations and Scan-Context-based multi-modal loop closure. |

### Why these matter

51. **Joint intrinsic + distortion calibration inside the Gaussian-SLAM BA loop.** VGGT-GS SLAM is the first surveyed work to optimize submap-shared intrinsics and radial-tangential distortion *with analytic calibration Jacobians inside the differentiable BA* that also refines the Gaussian map. Gaussian-LIC2 assumes calibrated intrinsics and known LiDAR-camera extrinsics — a real deployment friction point — and VGGT-GS's analytic-Jacobian joint calibration plus its Gaussian-native alignment for submap scale refinement give a concrete recipe for relaxing that assumption. The feed-forward-prior bootstrapping also offers a fallback for keyframes where LiDAR depth initialization is poor.

52. **The VI-only incremental-3DGS ablation baseline.** Stipple shares Gaussian-LIC2's exact architecture — VI tracker + incremental 3DGS mapper — minus the LiDAR arm. It is the cleanest comparison point in the survey for *what the LiDAR depth initialization buys*: without it, the VI tracker alone must carry pose and scale, and the incremental training has no depth prior to anchor new Gaussians. Its Brush-based Rust backend is also a concrete alternative rendering stack to the CUDA rasterizer. Cite as the ablation that motivates the LiDAR arm.

53. **Memory-bounded large-scale Gaussian mapping.** GLAM-SLAM's structured sparse anchor grid, geometry-based flow densification, and scene partitioning with localized MLP-initialized Gaussians are the most explicit treatment of the long-sequence scalability problem — the Gaussian-count explosion and GPU-memory growth that limits Gaussian-LIC2 on extended trajectories. The 15% reconstruction-quality gain at real-time scaling on KITTI/RobotCar/Málaga is evidence the approach works outdoors at the scale Gaussian-LIC2's outdoor extension would face.

54. **LiDAR-centric modular multi-sensor fusion, GP-sub-mesh map.** LXD-SLAM is the closest non-Gaussian-Splatting analogue to Gaussian-LIC2's design: LiDAR-centered, plug-and-play camera+IMU+GNSS, real-time dense mesh. The contrast — unified IEKF + Gaussian-Process sub-meshes vs. a differentiable 3DGS map — frames the central design trade-off (fusion modularity vs. rendering quality/differentiability). Its Extended Scan Context + Bidirectional PnP loop-closure pipeline is a concrete evaluable alternative to Gaussian-LIC2's loop-closure handling.

### Reproducing the Addendum 14 survey

Doubao web search was **unavailable** this round (six `mcp__doubao-search__web_search` calls all returned `Error CodeN 10500 Internal Service Error` across both `OneWeek` and `OneMonth` ranges, spanning ~2 minutes). The arXiv API (`http://export.arxiv.org/api/query`) was used instead, all run 2026-09-21:

1. `all:"Gaussian Splatting" AND all:SLAM`, `sortBy=submittedDate`, `sortOrder=descending`, `max_results=30` — returned the recent 3DGS-SLAM cohort (VGGT-GS SLAM, SLAMSqueezeBench, PanoGS-SLAM, SCOUT-SLAM, LightSplat, RoSe-SLAM, CGS-SLAM, AquaFlow, MotionGS-SLAM, Geometry-Aware Mapping, EndoMD-SLAM, EvTrajGS, Stipple, GLAM-SLAM, ...).
2. `all:"LiDAR" AND all:"Gaussian" AND all:SLAM`, `sortBy=submittedDate`, `sortOrder=descending`, `max_results=20` — returned the LiDAR+Gaussian cohort (Real-Time LiDAR Gaussian Splatting SLAM, Structured-Li-GS, LXD-SLAM, RICH-SLAM, ...).
3. `all:"visual-inertial" AND all:"Gaussian"`, `sortBy=submittedDate`, `sortOrder=descending`, `max_results=15` — returned Stipple, VIGS-SLAM, GS-GVINS, VINGS-Mono, LVI-GS, ...
4. Per-paper abstracts fetched from `https://arxiv.org/abs/<id>` for the four selected new papers.

Candidate papers were cross-checked against the existing `papers/` inventory and the `references.bib` entry list; four were genuinely new (VGGT-GS SLAM, Stipple, GLAM-SLAM, LXD-SLAM). Previously surveyed candidates that re-appeared in the results were ruled out: Real-Time LiDAR Gaussian Splatting SLAM (Addendum 9, `tak2026realtimelidargs`), Structured-Li-GS (Addendum 8, `weng2026structuredligs`), PanoGS-SLAM (Addendum 10, `mao2026panogsslam`), LightSplat (Addendum 10, `bao2026lightsplat`), RoSe-SLAM (Addendum 12, `wang2026roseslam`), CGS-SLAM (Addendum 8, `deambrogi2026cgsslam`), MotionGS-SLAM (Addendum 11, `hu2026motiongsslam`), Geometry-Aware Online Mapping (Addendum 12, `luu2026geometryawaremapping`), SCOUT-SLAM / EliGSiR / RawSLAM (Addendum 13). Candidates surveyed for the first time but **not selected** this round (kept on the watchlist): SLAMSqueezeBench (resource-constraint SLAM benchmark, broader than Gaussian-LIC2's scope), AquaFlow (underwater monocular 3DGS-SLAM, niche domain), EndoMD-SLAM (endoscopic, niche domain), EvTrajGS (event-camera, niche domain), VIGS-SLAM / GS-GVINS / VINGS-Mono (visual-inertial 3DGS but older, late-2025/early-2026, lower priority than the four selected).

### PDF availability

All four new papers have arXiv PDFs (PDF 1.7) and were downloaded to `papers/`:

- `Han2026_VGGTGSSSLAM.pdf` (arXiv:2609.19628, PDF 1.7, ~4.5 MB)
- `Northoff2026_Stipple.pdf` (arXiv:2608.00931, PDF 1.7, ~4.4 MB)
- `Mermigkas2026_GLAMSLAM.pdf` (arXiv:2607.21416, PDF 1.7, ~3.1 MB)
- `Wang2026_LXDSLAM.pdf` (arXiv:2606.27811, PDF 1.7, ~13.2 MB)

### Updated `papers/` inventory (75 PDFs)

The four new additions (Sections SS-VV) are:
Han2026_VGGTGSSSLAM.pdf, Northoff2026_Stipple.pdf, Mermigkas2026_GLAMSLAM.pdf, Wang2026_LXDSLAM.pdf.

`references.bib` now holds 82 entries (`grep -c "^@" references.bib` = 82).

## Addendum 15 (2026-09-22) — three newly surveyed related works

**24-hour code-review note.** No commits or working-tree changes to the
Gaussian-LIC2 source tree in the last 24 hours (last commit `793b9bc`,
2026-08-08, unchanged since Addendum 12/13/14). The untracked `latex/`,
`scripts/`, `.zcode/` directories and the loose PDFs in the repo root
remain from prior survey rounds. Nothing in the codebase requires action
this round; this addendum is a pure related-work update.

**Search method note.** The Doubao web-search API (`mcp__doubao-search`)
returned `Error CodeN 10408 — "The function is unavailable. Please renew,
reactivate, or contact customer support."` on every call this round (three
attempts across `OneWeek` and `OneMonth` ranges). This is a different
error from Addendum 14's `10500 Internal Service Error` (transient
overload) — `10408` indicates an account/entitlement problem that will
likely persist until the subscription is renewed, so **Doubao should not
be assumed available next round**; re-test once but expect to fall back.
Falling back to the **arXiv API** (`https://export.arxiv.org/api/query`,
note the `https` scheme and `-L` redirect-follow — `http` 301-redirects
to `https` and returns an empty body without `-L`) gave reliable, current
results; queries used are recorded in the reproduction section below.

Three new papers identified via arXiv API queries and not previously in
`papers/`:

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| WW | **RMGS-SLAM: Real-time Multi-sensor Gaussian Splatting SLAM** (Li, Liu, Liu, Sun, Huang, Sun, Liu, Yuan, Guo, Tay, Ang Jr; arXiv:2604.12942, submitted 14 Apr 2026) | arXiv preprint, 14 Apr 2026 | LiDAR + Inertial + Visual (tightly coupled) | A **tightly coupled LiDAR-Inertial-Visual 3DGS SLAM** system targeting **real-time large-scale** scenes. State estimation and 3D Gaussian primitive initialization run **in parallel** with a global Gaussian optimization, enabling continuous dense mapping. Introduces a **cascaded strategy that combines feed-forward predictions with geometric priors from voxel-based PCA** to improve Gaussian initialization quality and accelerate optimization convergence, and performs **loop closure directly on the optimized global Gaussian map** for long-term global consistency. | This is the **most direct overlap with Gaussian-LIC2's niche** in the entire survey: it is a real-time, tightly coupled **LiDAR-Inertial-Visual 3DGS SLAM** system for large-scale scenes — the same sensor stack and the same design goal (real-time photorealistic mapping with multi-sensor pose). It was published before Gaussian-LIC2's IJRR 2026 submission window and must be cited and compared against directly. The two methodologically distinctive contributions to weigh against Gaussian-LIC2 are (1) the **cascaded feed-forward + voxel-PCA geometric-prior initialization**, a different depth/geometry bootstrapping route than Gaussian-LIC2's LiDAR-driven Gaussian initialization, and (2) **loop closure performed on the global Gaussian map** rather than on a separate pose graph — a concrete answer to the loop-closure lever that prior addenda flagged as an open engineering point for Gaussian-LIC2. The parallel state-estimation + global-optimization scheduling is also a relevant systems-level comparison. Cite as the closest contemporary LiDAR-Inertial-Visual 3DGS SLAM baseline. |
| XX | **TRGS-SLAM: IMU-Aided Gaussian Splatting SLAM for Blurry, Rolling Shutter, and Noisy Thermal Images** (Carmichael, Skinner; arXiv:2603.20443, submitted 20 Mar 2026) | arXiv preprint, 20 Mar 2026 | Thermal camera + IMU (thermal-inertial) | A **3DGS thermal-inertial SLAM** system that handles the degradations of uncooled microbolometer thermal cameras — motion blur, rolling-shutter distortion, and fixed-pattern noise — via a **model-aware 3DGS rendering method**. Introduces several general 3DGS-SLAM innovations: **B-spline trajectory optimization with a two-stage IMU loss**, **view-diversity-based opacity resetting**, and **pose-drift correction schemes**. Demonstrates accurate tracking under real-world fast motion and degraded imagery. | Although the sensor modality is thermal rather than LiDAR/visual, **TRGS-SLAM's B-spline continuous-time trajectory optimization with a two-stage IMU loss is methodologically the closest analogue in the survey to Gaussian-LIC2's continuous-time B-spline formulation**. The two-stage IMU loss design (a coarse-then-fine IMU residual weighting, as the name implies) is a concrete recipe for integrating inertial residuals into a B-spline CT trajectory that Gaussian-LIC2's CT estimation can be compared against or could borrow. The model-aware 3DGS renderer that accounts for sensor-specific degradation (blur/rolling-shutter/noise here) is also a template for a LiDAR-aware rendering loss. Cite as the continuous-time B-spline + IMU methodological reference and as evidence that the CT-IMU formulation generalizes across sensor modalities. |
| YY | **Cube-Splat: High-Fidelity 360° Gaussian Splatting SLAM via Cubemap Factorization and Adjoint-Consistent Optimization** (Guo, Shi, Zhang, Yi, Mao, Yin, Wang; arXiv:2609.21347, submitted 18 Sep 2026) | arXiv preprint, 18 Sep 2026 | Panoramic (360°) RGB | The **first panoramic GS-SLAM**. Factorizes each 360° frame into a **cubemap of four fixed-orientation virtual pinhole views sharing a single optical center**; designates the front face as the primary pose state and uses an **adjoint-consistent optimization** so gradients from all faces coherently update a single state while strictly preserving cross-view geometric consistency. The mapping module densifies and optimizes anisotropic Gaussians using aggregated cubemap rays. Releases **SynPano**, a synthetic panoramic SLAM benchmark with parameterized complex trajectories and multi-modal ground truth. | Tangential to Gaussian-LIC2's LiDAR/visual-inertial focus — a different (panoramic) sensor modality — but a current GS-SLAM frontier. The **adjoint-consistent multi-face gradient aggregation** is a generally useful technique for any multi-camera or multi-view Gaussian-SLAM system that must keep a single coherent pose state while accumulating gradients from several observation directions, which is the situation Gaussian-LIC2 faces when fusing LiDAR and visual observations. Cite briefly as the panoramic GS-SLAM frontier and as a reference for adjoint-based multi-observation gradient aggregation. |

### Why these matter

55. **The closest contemporary LiDAR-Inertial-Visual 3DGS SLAM baseline.** RMGS-SLAM is the single most directly overlapping system with Gaussian-LIC2 in the survey: real-time, tightly coupled **LiDAR-Inertial-Visual 3DGS SLAM** for large-scale scenes — the same sensor stack and the same design goal. Its cascaded feed-forward + voxel-PCA initialization and its global-Gaussian-map loop closure are two concrete design points to weigh against Gaussian-LIC2's LiDAR-driven initialization and pose-graph loop-closure handling (the latter an open lever flagged in prior addenda). This paper must be cited and directly compared; it is the head-to-head contemporary baseline.

56. **Continuous-time B-spline + IMU, the closest methodological analogue.** TRGS-SLAM's B-spline trajectory optimization with a two-stage IMU loss is the closest surveyed analogue to Gaussian-LIC2's continuous-time B-spline estimation. The two-stage IMU residual weighting is a recipe Gaussian-LIC2's CT-IMU integration can be benchmarked against or borrow from, and its model-aware 3DGS renderer (accounting for sensor-specific blur/rolling-shutter/noise) is a template for a LiDAR-aware rendering loss. It is evidence the CT-IMU formulation generalizes beyond the LiDAR/visual setting.

57. **Adjoint-consistent multi-observation gradient aggregation.** Cube-Splat's adjoint mapping that lets multiple cubemap faces coherently update a single pose state while preserving cross-view geometric consistency is a generally applicable technique for any Gaussian-SLAM system that must accumulate gradients from several observation directions into one state — the situation Gaussian-LIC2 is in when fusing LiDAR and visual observations. Tangential in modality but a transferable method.

### Reproducing the Addendum 15 survey

Doubao web search was **unavailable** this round (three `mcp__doubao-search__web_search` calls all returned `Error CodeN 10408 — "The function is unavailable. Please renew, reactivate, or contact customer support."` across `OneWeek` and `OneMonth` ranges). The arXiv API (`https://export.arxiv.org/api/query`, with `https` scheme and `-L` redirect-follow) was used instead, all run 2026-09-22:

1. `all:"Gaussian Splatting" AND all:SLAM`, `sortBy=submittedDate`, `sortOrder=descending`, `max_results=40` — returned the recent 3DGS-SLAM cohort (Cube-Splat, 2D GauSS-MI, EliGSiR, SplashSplat, SLAMSqueezeBench, VGGT-GS SLAM, RawSLAM, PanoGS-SLAM, SCOUT-SLAM, LightSplat, RoSe-SLAM, ...).
2. `all:"Gaussian Splatting" AND (all:LiDAR OR all:inertial OR all:odometry)`, `sortBy=submittedDate`, `sortOrder=descending`, `max_results=40` — returned the LiDAR/inertial cohort (CGS-SLAM, Stipple, GLAM-SLAM, Real-Time LiDAR Gaussian Splatting SLAM, Structured-Li-GS, LIT-GS, LOGOS, RMGS-SLAM, TRGS-SLAM, ReefMapGS, RadarSplat-RIO, ...).
3. `all:"Gaussian Splatting" AND (all:"dense mapping" OR all:"real-time" OR all:tracking)`, `sortBy=submittedDate`, `sortOrder=descending`, `max_results=40` — returned the broad mapping cohort (overlapping with the above plus many NVS/compression/dynamic-scene papers filtered out).
4. Per-paper abstracts fetched from `https://arxiv.org/abs/<id>` (via `citation_abstract` meta tag) for the three selected new papers.

Candidate papers were cross-checked against the existing `papers/` inventory and the `references.bib` entry list; three were genuinely new (RMGS-SLAM, TRGS-SLAM, Cube-Splat). Previously surveyed candidates that re-appeared in the results were ruled out: CGS-SLAM (Addendum 8, `deambrogi2026cgsslam`), Stipple (Addendum 14, `northoff2026stipple`), GLAM-SLAM (Addendum 14, `mermigkas2026glamslam`), Real-Time LiDAR Gaussian Splatting SLAM (Addendum 9, `tak2026realtimelidargs`), Structured-Li-GS (Addendum 8, `weng2026structuredligs`), LIT-GS (`shi2026litgs`), PanoGS-SLAM (Addendum 10, `mao2026panogsslam`), LightSplat (Addendum 10, `bao2026lightsplat`), RoSe-SLAM (Addendum 12, `wang2026roseslam`), VGGT-GS SLAM (Addendum 14, `han2026vggtgsslam`), RawSLAM (Addendum 13, `orozco2026rawslam`), SCOUT-SLAM / EliGSiR (Addendum 13). Candidates surveyed for the first time but **not selected** this round (kept on the watchlist): 2D GauSS-MI (active 2DGS view selection, an active-reconstruction rather than SLAM problem), SplashSplat (fluid reconstruction, out of scope), SLAMSqueezeBench (resource-constraint benchmark, carried over from Addendum 14 watchlist), LOGOS (LiDAR-only obstacle segmentation, no SLAM/odometry), RadarSplat-RIO (radar-inertial, niche modality), ReefMapGS (underwater multimodal, niche), GSO-SLAM (VIO+GS coupling, older Feb 2026), thermal-odometry-and-dense-mapping (older, pre-3DGS-era lineage).

### PDF availability

All three new papers have arXiv PDFs and were downloaded to `papers/`:

- `Li2026_RMGS-SLAM.pdf` (arXiv:2604.12942, ~19.8 MB)
- `Carmichael2026_TRGSSLAM.pdf` (arXiv:2603.20443, ~5.2 MB)
- `Guo2026_CubeSplat.pdf` (arXiv:2609.21347, ~23.0 MB)

### Updated `papers/` inventory (78 PDFs)

The three new additions (Sections WW-YY) are:
Li2026_RMGS-SLAM.pdf, Carmichael2026_TRGSSLAM.pdf, Guo2026_CubeSplat.pdf.

`references.bib` now holds 85 entries (`grep -c "^@" references.bib` = 85).

---

## Addendum 16 (2026-09-23) — four newly surveyed related works

**24-hour code-review note.** No commits or working-tree changes to the
Gaussian-LIC2 source tree in the last 24 hours. `git log --since="24 hours ago"`
is empty; the most recent commit remains `793b9bc Update README` (2026-08-08
16:39:24 +0800). The only working-tree changes are the untracked
`latex/` survey directory, the untracked root-level survey PDFs, and the
untracked `scripts/` and `.zcode/` directories — all pre-existing
untracked artifacts, none a source-tree edit. So again there is nothing
in the codebase to review or feed into the related-work assessment this
round; the survey is purely additive.

Doubao web search was **available** this round (the A15 10408
entitlement error has cleared). Four `mcp__doubao-search__web_search`
calls were run 2026-09-23 with `OneWeek` / `OneMonth` / no time-range
filters against the standard 3DGS-SLAM + LiDAR/visual/inertial keyword
set. Candidate papers were cross-checked against the existing `papers/`
inventory and the `references.bib` entry list; four were genuinely new
(Dynamic-LIVO, AWM-3DFM, PointSLAM++, GauS-SLAM). Previously surveyed
candidates that re-appeared were ruled out: Structured-Li-GS (Addendum 8,
`weng2026structuredligs`), LV-GS SLAM (Addendum 9, `he2026lvgsslam` /
`qian2026lvgsslam`), RawSLAM (Addendum 13, `orozco2026rawslam`), GS-SDF
(already covered via `liu2025gssdf`), GS-SLAM / MonoGS (`yan2024gsslam` /
`matsuki2024monogs`), GPS-SLAM (watchlisted, RGB-D-only and older Dec
2025). GS-ICP SLAM (`ha2024gsicp`) and LiGS (`jiang2024ligs`) also
re-appeared and were already in the inventory.

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| ZZ | **Dynamic-LIVO: A Dynamic-Aware LiDAR-Inertial-Visual Odometry System Using Spatio-Temporal Normals** (Zhang, Ahiwe, Hale, Zhao, Ladosz; arXiv:2609.19336, submitted 16 Sep 2026) | arXiv preprint, 16 Sep 2026 | LiDAR + Inertial + Visual (LIVO) | A **dynamic-aware LIVO** system that uses **spatio-temporal (S-T) normal analysis** to identify dynamic LiDAR points and propagates the classification into **both** the LiDAR-inertial and visual-inertial updates, preventing dynamic measurements and their associated visual observations from contaminating state estimation or the static colored map. Introduces a **time-delayed S-T normal estimation** that defers classification of insufficiently constrained points (newly observed, spatially sparse) and re-evaluates them as more observations accumulate, improving dynamic-classification reliability while preserving valid static points. Validated on public + self-collected datasets with diverse sensor configs; code + dataset to be released. | This is the most directly on-topic new paper of the round: a **FAST-LIVO2-lineage LIVO system** that hardens state estimation and static colored mapping against dynamic outliers — exactly the dynamic-environment robustness gap that a LiDAR-visual-inertial 3DGS SLAM like Gaussian-LIC2 must close before feeding clean static primitives to the Gaussian map. The S-T normal dynamic-point rejection is a drop-in pre-filter for Gaussian-LIC2's LiDAR processing front, and the time-delayed re-evaluation strategy is a concrete recipe for handling the newly-observed / sparse-region case where a single-frame dynamic classifier would mislabel valid static geometry. Cite as the contemporary dynamic-aware LIVO frontend and as the dynamic-outlier-rejection reference Gaussian-LIC2's mapping pipeline should integrate or compare against. |
| AAA | **Adaptive World Memory 3D Foundation Model for Scalable 3D Mapping, Localization, and Rendering** (Deng, Shen, Shen, Wu, Fang, Ma, Zhang, Yuan, Burgard, Wang; arXiv:2609.21502, submitted 18 Sep 2026) | arXiv preprint, 18 Sep 2026 | RGB (monocular / multi-view streams) | A **memory-centric 3D foundation model** for scalable robotic localization, dense reconstruction, and Gaussian rendering. Core is a **dual-stage adaptive world memory**: (1) gated recurrent spatial states for learned memory propagation, (2) **test-time temporal-spatial regulation** calibrating token-wise update / preservation / forgetting from temporal state evolution and spatial observation-state consistency. Memory is organized into **local submaps** with progressive mapping/tracking, **loop closure**, and **SL(4)-based global refinement**; a **Gaussian reconstruction head** decodes the shared memory into renderable Gaussian primitives, unifying pose estimation, dense point-cloud reconstruction, and photorealistic rendering in one model — **without** the accurate pose init / depth input / per-scene optimization that conventional 3DGS-SLAM requires. | AWM-3DFM is a contemporary **alternative paradigm** to Gaussian-LIC2: foundation-model-driven (DUSt3R/MASt3R/VGGT lineage) Gaussian SLAM that replaces explicit multi-sensor factor-graph estimation with **learned adaptive memory + submap loop closure**. Gaussian-LIC2's classical LiDAR-visual-inertial continuous-time estimation does not take this direction, but the paper is the emerging learned-SLAM frontier the related-work section must acknowledge. Two transferable ideas worth calling out: (1) the **test-time temporal-spatial memory regulation** is a learned analogue of the memory/forgetting policy a SLAM system applies to its map, and (2) the **SL(4)-based submap global refinement** is a modern backend formulation to contrast with Gaussian-LIC2's pose-graph / CT optimization. Cite as the foundation-model Gaussian-SLAM frontier and the learned-memory alternative to classical multi-sensor estimation. |
| BBB | **PointSLAM++: Robust Dense Neural Gaussian Point Cloud-based SLAM** (Wang, Han, Chen, Liu, Li; AAAI 2026, arXiv:2601.11617) | AAAI 2026 (arXiv 10 Jan 2026) | RGB-D | A **robust dense RGB-D SLAM** using a **hierarchically constrained neural Gaussian representation**: a **two-tier anchor** mechanism (primary anchors from stable ORB feature points, secondary anchors added/removed by local geometric complexity) decoded by an MLP into Gaussian primitives. Tracking uses **progressive pose optimization** — GICP + ORB reprojection in a multi-scale pyramid, with a **global-feature relocalization** module for tracking loss under fast motion / low texture. Embeds **camera-view vectors** into anchor appearance for view-dependent lighting compensation. Reports PSNR +1.63 over prior SOTA and >50% ATE reduction on Replica; outperforms MonoGS / GS-ICP SLAM on Replica / TUM / ScanNet++. | PointSLAM++ is a current **RGB-D 3DGS-SLAM SOTA** that replaces the pure differentiable-rendering tracking of MonoGS-style systems with a **hybrid GICP+ORB progressive pose optimizer** — a tracking design Gaussian-LIC2 (which offloads tracking to a FAST-LIVO2 LIVO frontend) sidesteps, but which matters for the visual-only / RGB-D comparison column. The **two-tier anchor + MLP-decoded Gaussian** representation is a different map representation choice from Gaussian-LIC2's explicit LiDAR-initialized anisotropic Gaussians, and the **view-vector appearance embedding** for view-dependent lighting is a technique Gaussian-LIC2's SH-based appearance could be compared against. Cite in the RGB-D 3DGS-SLAM comparison and the anchor-representation discussion. |
| CCC | **GauS-SLAM: Dense RGB-D SLAM with Gaussian Surfels** (Su, Chen, Zhang, Zhao, Hou, Yu; RA-L 2026, arXiv:2505.01934) | IEEE RA-L 2026 (arXiv 3 May 2025) | RGB-D | A **dense RGB-D SLAM with 2D Gaussian surfels**. Identifies that Gaussian-based tracking suffers **geometry distortion** under novel viewpoints from (a) the **center-depth model** of 3D Gaussians (multi-view inconsistent) and (b) **mutual interference between surfaces during depth blending**. Proposes a **2D-Gaussian-surfel incremental reconstruction** with a **Surface-aware Depth Rendering** mechanism (unbiased intersection depth + depth adjustment + normalization) and a local-map design that dynamically isolates visible surfaces during tracking, keeping tracking efficient as Gaussian density grows. Front-end/back-end architecture with submap-based global optimization. SOTA tracking (0.06 cm ATE on Replica) and rendering (40.25 dB) on Replica/ScanNet/TUM/ScanNet++. | The **2D-surfel + surface-aware depth rendering** is a concrete remedy for the geometry-distortion / depth-blending ambiguity that any Gaussian-SLAM tracker faces, and is directly transferable to a LiDAR-visual setting where LiDAR depth can supervise the surface-aware rendering; the local-map-isolation-for-tracking idea parallels Gaussian-LIC2's keyframe-submap structure. Cite in the RGB-D 3DGS-SLAM comparison and the surfel / surface-aware rendering discussion. |

## Addendum 17 (2026-09-24) — two newly surveyed related works

**24-hour code-review note.** No commits or working-tree changes to the
Gaussian-LIC2 source tree in the last 24 hours. `git log --since="24 hours ago"`
is empty; the most recent commit remains `793b9bc Update README` (2026-08-08
16:39:24 +0800). The only working-tree changes are the untracked
`latex/` survey directory, the untracked root-level survey PDFs, and the
untracked `scripts/` and `.zcode/` directories — all pre-existing
untracked artifacts, none a source-tree edit. So again there is nothing
in the codebase to review or feed into the related-work assessment this
round; the survey is purely additive. (This Addendum 17 also repairs the
truncated Addendum 16 `GauS-SLAM` table row, which was cut off mid-sentence
in the previous write.)

Doubao web search was **available** this round. Five
`mcp__doubao-search__web_search` calls were run 2026-09-24 with
`OneWeek` / `OneMonth` time-range filters against the standard
3DGS-SLAM + LiDAR/visual/inertial keyword set. Candidate papers were
cross-checked against the existing `papers/` inventory and the
`references.bib` entry list; two were genuinely new (Dual Covariance
GS-SLAM, ArborSplat). Previously surveyed candidates that re-appeared in
the results were ruled out: Structured-Li-GS (Addendum 8,
`weng2026structuredligs`), LV-GS SLAM (Addendum 9, `he2026lvgsslam` /
`qian2026lvgsslam`), LightSplat (Addendum 10, `bao2026lightsplat`),
VGGT-GS SLAM (Addendum 14, `han2026vggtgsslam`), AWM-3DFM (Addendum 16,
`deng2026awm3dfm`), Dynamic-LIVO (Addendum 16, `zhang2026dynamiclivo`).
Candidates surveyed for the first time but **not selected** this round
(kept on the watchlist): SemSafe-3DGS (semantic risk-aware active
navigation in 3DGS maps — an active-navigation planner over a given GS
map, not a SLAM/mapping system), the dynamic-3DGS compression paper
(arXiv:2609.25633 — post-training 3DGS sequence coding, not SLAM).

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| DDD | **Dual Covariance Gaussian Splatting SLAM: Decoupling Rendering and Registration for Robust Real-Time Tracking** (Tan, Lam; Nanyang Technological University; arXiv:2609.25746, submitted 22 Sep 2026) | arXiv preprint, 22 Sep 2026 | RGB-D (RealSense D435i; wheeled + handheld outdoor) | An **ICP-based 3DGS SLAM** that **decouples the single shared Gaussian covariance** into a **rendering covariance** (mapper-optimized for photometric error) and a **tracking covariance** (derived from an RGB-D sensor noise model via the structured-light range law `σ_z(z)=A+Bz²`), sharing one mean. The tracking covariances also serve as **KLT anchors for image corners**, supplying the tangent-plane constraint that depth lacks in structure-less / geometrically degenerate scenes. Evaluated on TUM RGB-D, ScanNet, Replica, and two outdoor D435i sequences (wheeled + handheld); achieves robust tracking across scenes, reduced odometry drift, and ~60 FPS, with the lowest drift among evaluated 3DGS-based methods outdoors. | The **render/track covariance decoupling** is a principled fix for the ill-conditioning that GS-ICP-style trackers suffer when the mapper flattens covariances against surfaces — a failure mode Gaussian-LIC2's LiDAR-initialized Gaussians could in principle hit if ever aligned via ICP. The **sensor-noise-derived tracking covariance** is a concrete recipe for encoding actual LiDAR/depth measurement uncertainty into the registration, and the **KLT-anchor** idea is a visual complement to LiDAR-ICP constraints in geometrically degenerate scenes. Cite in the tracking-uncertainty / observability discussion and the ICP-based 3DGS-SLAM comparison. |
| EEE | **ArborSplat: Online Semantic Gaussian Splatting SLAM for Orchards** (Masini, Frosi, Usuelli, Matteucci; Politecnico di Milano; arXiv:2609.26315, submitted 22 Sep 2026) | arXiv preprint, 22 Sep 2026 | LiDAR (scan-to-submap odometry) + RGB (stereo + monocular depth) | An **online semantic 3DGS SLAM for orchards** that tracks with **LiDAR odometry** (scan-to-submap registration; the Gaussian map does **not** feed back into tracking) and optimizes appearance + semantics jointly on the Gaussian map, constrained by **class-specific height bands** above a RANSAC-fitted ground plane and a **multi-view semantic point cloud** that rejects labels inconsistent with the local ground surface or monocular depth (fixing thin-structure mislabeling where a trunk pixel inherits background depth). **Class-constrained refinement** reserves Gaussian capacity for underrepresented classes (trunk / trellis / fruit). Uses **SAM 3** open-vocabulary segmentation. ATE < 0.5 m on all 12 orchard traversals; beats SGS-SLAM / GS3LAM by 0.23–0.50 training-view and 0.15–0.36 held-out mIoU at 1.7–7.5× speed; SemGauss-SLAM runs out of GPU memory on all six. | A contemporary **LiDAR-odometry-frontended 3DGS SLAM** that **decouples tracking from the Gaussian map** — the same architectural split Gaussian-LIC2 uses via FAST-LIVO2 — but demonstrated outdoors in unstructured orchard environments rather than indoor RGB-D. The **class-constrained densification** is a capacity-allocation idea transferable to Gaussian-LIC2's primitive-growth policy when semantic priors are available, and the **thin-structure label-gating** addresses a real multi-view semantic-fusion failure mode. Cite in the LiDAR-odometry-frontended GS-SLAM family and the semantic / capacity discussion. |

### Why these matter

1. **Dual Covariance GS-SLAM** isolates a previously implicit failure mode in ICP-based 3DGS SLAM — that the mapper-optimized covariance is the *wrong* weighting for registration because it encodes photometric, not sensor, precision — and shows a clean two-covariance fix plus a visual-anchor complement for degenerate scenes. For Gaussian-LIC2 this is the canonical reference for the tracking-uncertainty / observability point and for the principle that the Gaussian primitive's rendering shape and its registration weighting need not be the same quantity.
2. **ArborSplat** extends the LiDAR-odometry-frontend + decoupled-Gaussian-mapping design (Gaussian-LIC2's own architecture) into outdoor unstructured agriculture with an explicit semantic layer and a capacity-allocation policy that protects small but important structures. It is the current example of that architectural family beyond indoor/autonomous-driving settings and a reference for how semantic priors should steer Gaussian densification.

### Reproducing the Addendum 17 survey

Searches were run via `mcp__doubao-search__web_search` on 2026-09-24 with
`OneWeek` and `OneMonth` time-range filters:

1. `3DGS SLAM LiDAR inertial visual gaussian splatting 2026` (OneWeek, 30 results)
2. `gaussian splatting SLAM LiDAR-visual-inertial odometry mapping arxiv 2026` (OneMonth, 30 results)
3. `3DGS-SLAM dense reconstruction gaussian splatting real-time 2026 arxiv` (OneWeek, 30 results)
4. `LiDAR visual inertial gaussian splatting continuous-time SLAM mapping arxiv September 2026` (OneMonth, 30 results)
5. `gaussian splatting SLAM loop closure submap large-scale outdoor arxiv 2026` (OneWeek, 30 results)

New PDFs downloaded via `curl -sL -o ... https://arxiv.org/pdf/<id>`:
`papers/Tan2026_DualCovGS.pdf` (arXiv:2609.25746),
`papers/Masini2026_ArborSplat.pdf` (arXiv:2609.26315).

### Inventory

`latex/papers/` now holds **85 PDFs**; `latex/bib/references.bib` now holds
**92 BibTeX entries** (`grep -c "^@" bib/references.bib` = 92,
`ls papers/*.pdf | wc -l` = 85). The 7-entry gap is the usual set of
surveyed-without-arXiv-PDF foundational works (Kerbl 3DGS, Mip-Splatting,
Scaffold-GS, Stop-ThePop, Taming-3DGS, iMAP, NICE-SLAM / Co-SLAM /
PointSLAM / GoSLAM / NeRF-SLAM where the canonical version is not an
arXiv PDF in the inventory, plus a couple of venue-only entries).

## Addendum 18 (2026-09-25) — one newly surveyed related work

**24-hour code-review note.** No commits or working-tree changes to the
Gaussian-LIC2 source tree in the last 24 hours. `git log --since="24 hours ago"`
is empty; the most recent commit remains `793b9bc Update README` (2026-08-08
16:39:24 +0800). The only working-tree changes are the untracked
`latex/` survey directory, the untracked root-level survey PDFs, and the
untracked `scripts/` and `.zcode/` directories — all pre-existing
untracked artifacts, none a source-tree edit. So again there is nothing
in the codebase to review or feed into the related-work assessment this
round; the survey is purely additive.

Doubao web search was **available** this round. Six
`mcp__doubao-search__web_search` calls were run 2026-09-25 with
`OneWeek` / `OneMonth` time-range filters against the standard
3DGS-SLAM + LiDAR/visual/inertial keyword set. The only arXiv-fresh
GS-SLAM submissions of the past week (ArborSplat arXiv:2609.26315,
Dual Covariance GS-SLAM arXiv:2609.25746, both 22 Sep 2026) were already
surveyed in Addendum 17, so this round is lighter. Candidate papers were
cross-checked against the existing `papers/` inventory and the
`references.bib` entry list; one was genuinely new (Wanderland).
Previously surveyed candidates that re-appeared in the results were
ruled out: LV-GS SLAM (Addendum 9, `he2026lvgsslam`), LVGS-SLAM
(Addendum 11, `qian2026lvgsslam`), LVI-GS (Addendum 7), GS-LIVO
(Addendum 6), Cube-Splat (`guo2026cubesplat`, Addendum 12). Candidates
surveyed for the first time but **not selected** this round (kept on the
watchlist): φ-RIE / "From Photorealistic Reconstruction to Interactive
Environments" (arXiv:2609.26795 — converts selected 3DGS objects into
movable simulator assets; an interaction layer over a given
reconstruction, not a SLAM/mapping system), the stochastic-3DGS neural
denoiser (arXiv:2609.25604 — rendering denoising, not SLAM).

**Back-filled PDF.** The LV-GS SLAM paper (He et al., Appl. Sci. 2026,
`he2026lvgsslam`) was added bib-only in Addendum 9 because the MDPI host
returned HTTP 403 to non-interactive clients; this round the MDPI
alternate download host (`mdpi-res.com`) succeeded, so
`papers/He2026_LVGSSSLAM.pdf` is now in the inventory (no new bib entry
— the Addendum 9 entry already covers it).

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| FFF | **Wanderland: Geometrically Grounded Simulation for Open-World Embodied AI** (Liu, Li, Deng, Chen, Zhang, Ma, Guo, Li, Zhang, Feng; NYU + Cornell; arXiv:2511.20620, v2 27 Mar 2026; CVPR 2026) | CVPR 2026 (arXiv Nov 2025, rev. Mar 2026) | LiDAR (Livox Mid-360 non-repetitive, with built-in IMU) + RGB (two sync 4K fisheye >180° FOV) + RTK-GNSS (handheld MetaCam Air scanner) | A **real-to-sim framework** that captures open-world indoor-outdoor urban scenes with a handheld multi-sensor 3D scanner and uses a **LiDAR-inertial-visual (LIV) SLAM** pipeline (built on VINS-Mono / GVINS / FAST-LIO2) to produce **metric-scale, globally consistent** point clouds and camera poses. **3DGS is initialized from the LIV dense colored point cloud** (~5M points/scene, original 5–10 mm spacing) and trained with a **depth regularization** that projects the initializing Gaussians to each pose to get GT depth (rather than using monocular pseudo-depth). **Collision meshes are extracted from the LiDAR point cloud** via voxelization + Marching Cubes — *not* from 3DGS opacity, which is fragmented and metrically ungrounded. Releases a **530-scene / 420K-frame / 3.8M-m²** dataset and empirically shows image-only video-3DGS pipelines (Vid2Sim, GaussGym) yield non-metric poses, fragmented geometry, and degraded extrapolated views, and that RL navigation training in geometrically unreliable environments can **degrade** rather than improve the policy. | A flagship **downstream consumer of LIV-SLAM + 3DGS** that empirically demonstrates *why* LiDAR-anchored metric geometry is necessary for reliable simulation and view synthesis versus pure-vision 3DGS — directly supporting Gaussian-LIC2's core multi-sensor-fusion + Gaussian-mapping thesis. The **LIV-SLAM-as-metric-anchor + point-cloud-initialized + depth-regularized 3DGS** pipeline is a non-real-time counterpart to Gaussian-LIC2's real-time tightly-coupled approach; the **point-cloud-derived (not opacity-derived) collision mesh** is a transferable lesson on geometry sourcing for downstream interaction. Cite in the application / downstream-impact discussion and the LIV-SLAM + 3DGS comparison. |

### Why this matters

1. **Wanderland** is the strongest recent empirical case for *why* LiDAR-inertial-visual SLAM matters for 3DGS-based simulation: it quantifies that even the best image-only pipelines leave meter-scale metric error and fragmented geometry that actively *harm* downstream RL, while LIV-SLAM-anchored 3DGS gives metric-accurate, extraplation-robust environments. For Gaussian-LIC2 this is a high-profile CVPR 2026 reference validating the very sensor-fusion premise of the system, and its point-cloud-initialized + depth-regularized 3DGS training recipe is a non-real-time counterpart worth contrasting against Gaussian-LIC2's real-time tightly-coupled mapping.

### Reproducing the Addendum 18 survey

Searches were run via `mcp__doubao-search__web_search` on 2026-09-25 with
`OneWeek` and `OneMonth` time-range filters:

1. `Gaussian Splatting SLAM LiDAR visual inertial 2026 arxiv` (OneWeek, 15 results)
2. `3DGS SLAM real-time dense reconstruction 2026` (OneWeek, 15 results)
3. `LiDAR inertial visual odometry Gaussian splatting mapping arxiv 2026` (OneMonth, 20 results)
4. `tightly-coupled LiDAR-visual-inertial SLAM gaussian splatting radiance field 2026` (OneMonth, 20 results)
5. `gaussian splatting SLAM arxiv new 2026 September submap surfel incremental` (OneWeek, 15 results)
6. `"LVGS-SLAM" Qian Li Hu arxiv preprint dense depth rendering unstructured` (web, 8 results) — confirmed LVGS-SLAM is IEEE-closed-access with no arXiv preprint, so bib-only (already in Addendum 11).

New PDF downloaded via `curl -sL -o ... https://arxiv.org/pdf/<id>`:
`papers/Liu2026_Wanderland.pdf` (arXiv:2511.20620). Back-filled PDF
(`papers/He2026_LVGSSSLAM.pdf`) retrieved from the MDPI alternate host
`mdpi-res.com` (the primary `www.mdpi.com` host still returns 403).

### Inventory

`latex/papers/` now holds **86 PDFs**; `latex/bib/references.bib` now holds
**92 BibTeX entries** (`grep -c "^@" bib/references.bib` = 92,
`ls papers/*.pdf | wc -l` = 86). The 6-entry gap is the usual set of
surveyed-without-arXiv-PDF foundational works (Kerbl 3DGS, Mip-Splatting,
Scaffold-GS, Stop-ThePop, Taming-3DGS, iMAP, NICE-SLAM / Co-SLAM /
PointSLAM / GoSLAM / NeRF-SLAM where the canonical version is not an
arXiv PDF in the inventory, plus a couple of venue-only entries).
## Addendum 20 (2026-09-26) — four newly surveyed related works

**24-hour code-review note.** No commits or working-tree changes to the
Gaussian-LIC2 source tree in the last 24 hours. `git log --since="24 hours ago"`
is empty; the most recent commit remains `793b9bc Update README` (2026-08-08
16:39:24 +0800). The only working-tree changes are the untracked
`latex/` survey directory, untracked root-level survey PDFs (all already
duplicated in `latex/papers/`), and the untracked `scripts/` and `.zcode/`
directories — all pre-existing untracked artifacts, none a source-tree
edit. So again there is nothing in the codebase to review or feed into the
related-work assessment this round; the survey is purely additive.

Doubao web search was **available** this round. Four
`mcp__doubao-search__web_search` calls were run 2026-09-26 with
`OneWeek` / `OneMonth` time-range filters against the standard
3DGS-SLAM + LiDAR/visual/inertial + continuous-time keyword set. The
arXiv-fresh GS-SLAM submissions of the past week (ArborSplat
arXiv:2609.26315, Dual Covariance GS-SLAM arXiv:2609.25746, both
22 Sep 2026) were already surveyed in Addendum 17, so they were ruled
out. Four genuinely new papers not in the inventory were identified and
added: G-solver (CT-SLAM solver), Pi3MOS-SLAM (CVPR 2026 dynamic visual
SLAM), HI-SLAM2 (T-RO 2025 / AAAI 2026 monocular GS-SLAM), and M3
(foundation-model monocular GS-SLAM). Candidates re-appearing in results
that were ruled out: LV-GS SLAM (Addendum 9, `he2026lvgsslam`), SCOUT-SLAM
(Addendum 16, `karthik2026scoutslam`), the tightly-coupled VIL dynamic
SLAM of Zhang & Peng (CIBDA'26 — workshop-tier, no arXiv preprint, kept
on the watchlist), HI-SLAM2 was tracked but only now added once its T-RO
publication was confirmed.

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| CT-SLAM | **Breaking Time: A Fully Gaussian Framework for Distributed and Continuous-Time SLAM** (Ceriola, Ferrari, Di Giammarino, Brizi, Grisetti; Sapienza U. Rome + U. Stuttgart; arXiv:2606.06250, Jun 2026; IEEE RA-L 11(8):9247–9254, Aug 2026) | RA-L Aug 2026 (arXiv Jun 2026) | Heterogeneous/asynchronous: rolling-shutter cameras, LiDAR scanners, radar sweeps, event cameras, multi-camera (method is sensor-agnostic) | Introduces **G-solver**, a fully Gaussian and **distributed** continuous-time SLAM framework that combines **Gaussian Belief Propagation (GBP)** with **Gaussian Process (GP) motion priors** for trajectory estimation. The GP model replaces spline knots with a probabilistic trajectory distribution, enabling consistent interpolation at arbitrary timestamps and data-driven hyperparameters; GBP provides scalable local message-passing inference instead of centralized NLLS, naturally suiting asynchronous multi-camera and non-uniform-readout sensors. Open-source: github.com/rvp-group/gsolver. | A **contemporary continuous-time SLAM solver** that is the most direct alternative to the spline-based CT formulation used by Gaussian-LIC2's Coco-LIC / FAST-LIVO2 backend. The GP-prior-vs-B-spline trade-off (principled uncertainty, data-driven hyperparameters, no fixed knot spacing) and the GBP distributed/incremental solve are exactly the axes along which Gaussian-LIC2's CT factor graph should be discussed. Cite in the continuous-time SLAM and optimization-backend discussion. |
| Dynamic / prior-driven | **Dynamic Visual SLAM using a General 3D Prior (Pi3MOS-SLAM)** (Zhong, Jin, Popović, Behley, Stachniss; U. Bonn + TU Delft + Lamarr Inst.; arXiv:2512.06868, Dec 2025; CVPR 2026) | CVPR 2026 (arXiv Dec 2025) | Monocular RGB only | A monocular visual SLAM that tightly integrates **patch-based online bundle adjustment** with a **feed-forward reconstruction model (π³_mos)** — an extension of π³ with a Moving Object Segmentation head — to filter dynamic regions and supply a depth prior under **uncertainty-aware weighting**. Scale alignment via patch-BA resolves the feed-forward model's batch-wise scale ambiguity. Open-source: github.com/PRBonn/Pi3MOS-SLAM. | A CVPR 2026 **vision-only dynamic-scene SLAM** representing the feed-forward-prior + classical-BA hybrid paradigm. Gaussian-LIC2's contribution is the tightly-coupled LIV sensor fusion giving metric scale directly, removing the scale-ambiguity problem Pi3MOS-SLAM must solve online via patch alignment. Cite in the dynamic-scene and learning-prior SLAM discussion as the learned-prior counterpoint to multi-sensor metric fusion. |
| Monocular 3DGS-SLAM | **HI-SLAM2: Geometry-Aware Gaussian SLAM for Fast Monocular Scene Reconstruction** (Zhang, Cheng, Skuddis, Zeller, Cremers, Haala; U. Stuttgart + TUM + Karlsruhe UAS + Munich Center for ML; arXiv:2411.17982, Nov 2024 v3 Feb 2026; IEEE T-RO 41:6478–6493, 2025; also AAAI 2026) | T-RO 2025 / AAAI 2026 (arXiv Nov 2024) | Monocular RGB only | A **geometry-aware Gaussian SLAM** using RGB input alone. Hybrid design: learning-based dense SLAM supplies depth as a proxy to **initialize and supervise a 3DGS map**, with **grid-based scale alignment** of monocular depth priors, **monocular normal priors** for surface quality, and **keyframe-pose-driven Gaussian deformation** for instant loop-closure map updates. Surpasses RGB-D-based methods in both reconstruction and rendering quality on Replica/ScanNet/ScanNet++. Open-source: hi-slam2.github.io. | A strong **monocular-only 3DGS-SLAM** that matches/surpasses RGB-D methods — the counterpoint to Gaussian-LIC2's multi-sensor approach. The scale-alignment and normal-prior ideas are transferable to a LIV system. Cite in the RGB-only-vs-LIV 3DGS-SLAM comparison; the keyframe-pose-driven Gaussian deformation is a relevant loop-closure-map-update mechanism. |
| Foundation-model GS-SLAM | **M³: Dense Matching Meets Multi-View Foundation Models for Monocular Gaussian Splatting SLAM** (Ren, Li, Jiang, Xu, Lu, Xu, Dong, Pang, Yu, Dai; SJTU + Shanghai AI Lab + Fudan + Shanghai Innovation Inst. + Zhejiang U. + BIT + CUHK + HKU; arXiv:2603.16844, Mar 2026) | arXiv Mar 2026 | Monocular RGB only | A streaming monocular 3DGS-SLAM coupling a **multi-view foundation model (Pi3X extended with a dense matching head, MASt3R-style)** with a SLAM backend. A **single feed-forward inference** over keyframes + incoming frame jointly updates geometry and tracking; **dynamic-region suppression** and **cross-inference intrinsic alignment** stabilize tracking. Reduces ATE RMSE 64.3% vs VGGT-SLAM 2.0 and outperforms ARTDECO by 2.11 dB PSNR on ScanNet++. | A **foundation-model-driven monocular GS-SLAM** representing the learned-correspondence paradigm; Gaussian-LIC2 provides metric geometry from LiDAR-inertial fusion rather than learned priors. Cite in the foundation-model-SLAM and monocular-vs-multisensor 3DGS-SLAM discussion. |

### Why these matter

1. **G-solver** is the most relevant new entry for Gaussian-LIC2's
   continuous-time formulation: it is a published RA-L 2026 CT-SLAM solver
   that replaces the B-spline trajectory representation (the basis of
   Coco-LIC / FAST-LIVO2's CT factor graph) with a Gaussian Process prior
   and replaces centralized NLLS with Gaussian Belief Propagation. This is
   the cleanest contemporary reference for the GP-vs-spline and
   distributed-vs-centralized axes of the CT-SLAM design space that
   Gaussian-LIC2 sits in, and it is open-source — worth citing in the
   CT-SLAM and optimization-backend discussion.
2. **Pi3MOS-SLAM, HI-SLAM2, and M³** together sharpen the
   **monocular-only 3DGS-SLAM vs multi-sensor LIV 3DGS-SLAM** contrast.
   All three are strong recent systems (CVPR 2026, T-RO 2025/AAAI 2026,
   and a Mar 2026 preprint) that achieve high-quality reconstruction from
   RGB alone by leaning on learned priors (feed-forward reconstruction,
   monocular depth/normal networks, multi-view foundation models). They
   must solve online the scale ambiguity and dynamic-object handling that
   Gaussian-LIC2 sidesteps via LiDAR-inertial metric fusion. The trio
   broadens the comparison baseline and frames Gaussian-LIC2's
   contribution as the multi-sensor-metric-geometry alternative to the
   learning-prior paradigm.

### Reproducing the Addendum 20 survey

Searches were run via `mcp__doubao-search__web_search` on 2026-09-26 with
`OneWeek` and `OneMonth` time-range filters:

1. `3DGS SLAM LiDAR visual inertial 2026 arxiv` (OneWeek, 15 results)
2. `Gaussian splatting SLAM real-time dense mapping 2026` (OneWeek, 15 results)
3. `LiDAR visual inertial odometry Gaussian splatting tightly coupled 2026` (OneMonth, 15 results)
4. `Gaussian-LIC2 LIV SLAM continuous-time factor graph` (OneMonth, 15 results)
5. `"Breaking Time" "G-solver" Gaussian continuous-time SLAM arxiv Ceriola` (web, 8 results) — confirmed arXiv:2606.06250, RA-L 11(8).
6. `Pi3MOS-SLAM "Dynamic Visual SLAM using a General 3D Prior" arxiv 2512.06868` (web, 8 results) — confirmed arXiv:2512.06868, CVPR 2026.
7. `HI-SLAM2 geometry-aware Gaussian SLAM monocular arxiv Zhang Cheng` (web, 8 results) — confirmed arXiv:2411.17982, IEEE T-RO 41:6478–6493 (2025), also AAAI 2026; M³ found via the same result set at arXiv:2603.16844.

New PDFs downloaded via `curl -sL -o ... https://arxiv.org/pdf/<id>`:
`papers/Ceriola2026_GSolver.pdf` (arXiv:2606.06250),
`papers/Zhong2026_Pi3MOSSSLAM.pdf` (arXiv:2512.06868),
`papers/Zhang2026_HISLAM2.pdf` (arXiv:2411.17982),
`papers/Ren2026_M3.pdf` (arXiv:2603.16844).

### Inventory

`latex/papers/` now holds **90 PDFs**; `latex/bib/references.bib` now holds
**97 BibTeX entries** (`grep -c "^@" bib/references.bib` = 97,
`ls papers/*.pdf | wc -l` = 90). The 7-entry gap is the usual set of
surveyed-without-arXiv-PDF foundational works plus a couple of
venue-only/library-software entries (GTSAM).

## Addendum 21 (2026-09-27) — three newly surveyed related works

**24-hour code-review note.** No commits or working-tree changes to the
Gaussian-LIC2 source tree in the last 24 hours. `git log --since="24 hours ago"`
is empty; the most recent commit remains `793b9bc Update README` (2026-08-08
16:39:24 +0800). The only working-tree changes are the untracked
`latex/` survey directory, untracked root-level survey PDFs (all already
duplicated in `latex/papers/`), and the untracked `scripts/` and `.zcode/`
directories — all pre-existing untracked artifacts, none a source-tree
edit. So again there is nothing in the codebase to review or feed into the
related-work assessment this round; the survey is purely additive.

Doubao web search was **available** this round. Five
`mcp__doubao-search__web_search` calls were run 2026-09-27 with
`OneWeek` / `OneMonth` time-range filters against the standard
3DGS-SLAM + LiDAR/visual/inertial + continuous-time keyword set. The
arXiv-fresh GS-SLAM submissions of the past week (ArborSplat
arXiv:2609.26315, Dual Covariance GS-SLAM arXiv:2609.25746, both
22 Sep 2026) were already surveyed in Addendum 17, so they were ruled
out. Three genuinely new papers not in the inventory were identified and
added: RawSLAM (online HDR Gaussian SLAM), Mono3DGS-SLAM (reliability-
gated monocular Gaussian–TSDF), and Cioffi & Scaramuzza's "Why does Deep
Learning Improve Visual SLAM?" (controlled study isolating learned
correspondence + uncertainty as the drivers of DL V-SLAM). Candidates
re-appearing in results that were ruled out: LV-GS SLAM (Addendum 9,
`he2026lvgsslam`), LVI-GS (Addendum 7, `zhao2025lvigs`), the CIBDA'26
tightly-coupled VIL dynamic SLAM of Zhang & Peng (workshop-tier, no
arXiv preprint — kept on the watchlist as in A18/A20), G-solver
(Addendum 20, `ceriola2026gsolver`), HI-SLAM2 (Addendum 20,
`zhang2026hislam2`). Candidates surveyed for the first time but **not
selected** this round (kept on the watchlist): GaussianFlow SLAM
(arXiv:2604.15612, Apr 2026 — monocular 3DGS-SLAM using optical-flow
alignment of projected Gaussian motion; KAIST, RA-L accepted Mar 2026;
relevant learned-cue monocular counterpoint but older than the OneWeek
window and lower priority than this round's three), Geometry-Aware Online
Mapping for 3DGS-SLAM (arXiv:2608.14902, Aug 2026 — three mapping-only
geometry-aware densification fixes for decoupled 3DGS-SLAM; a
mapping-quality refinement note rather than a new system).

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| HDR / robustness | **RawSLAM: Online HDR Gaussian SLAM from Linear Radiance** (Orozco González, Merino; Pablo de Olavide U. Sevilla; arXiv:2609.20589, 17 Sep 2026) | arXiv Sep 2026 | RGB-D (16-bit linear HDR single-exposure RAW + aligned depth + IMU + OptiTrack GT) | The **first online Gaussian SLAM framework that tracks and maps directly on single-exposure 16-bit linear HDR imagery**. Architecture-agnostic HDR Gaussian Splatting module with three components: an **MLP-free logarithmic parameterization** of Gaussian color features (stable under linear radiance dynamic range), a **Reinhard range-compressed photometric objective**, and **structure-guided spatial gradient weighting**. Outperforms a direct HDR adaptation of MonoGS in both trajectory and reconstruction accuracy, renders natively in linear scene radiance for post-rendering exposure control, and the **same formulation runs unchanged on standard 8-bit LDR inputs** (roughly halves MonoGS baseline error). The HDR module **transfers seamlessly to SplaTAM, Gaussian SLAM, and DROID-W**, eliminating all their tracking failures on challenging illumination sequences. Releases **RawSLAM**: a 10-scene dataset of 16-bit RAW imagery + aligned depth + IMU + external OptiTrack poses (~1,860 frames/scene). | An **HDR / imaging-condition-robustness reference for 3DGS-SLAM**. Gaussian-LIC2's photometric loss operates on 8-bit tonemapped LDR images and inherits the highlight-clipping / shadow-quantization fragility RawSLAM targets; the **log-color parameterization + Reinhard range-compressed photometric loss** are directly transferable to the Gaussian-LIC2 rendering objective to harden it against extreme lighting. Cite in the photometric-objective / robustness discussion. |
| Monocular hybrid GS-SLAM | **Mono3DGS-SLAM: Reliability-Aware Geometric Canonicalization for Monocular Gaussian–TSDF Reconstruction** (Wan, Wang, Xu, Gao, Wang; SJTU + Jiaxing U. + Shenyang Aerospace U. + Beijing Machine Tool Research Inst.; Appl. Sci. 16(19):9413, 22 Sep 2026) | Appl. Sci. Sep 2026 (MDPI) | Monocular RGB only | A **reliability-guided monocular Gaussian–TSDF** reconstruction system. **Deterministic reliability gates** select admissible observations; **one frozen scale** jointly transports predicted depth, camera translation, and all length-valued mapping parameters into an internally consistent **canonical (non-metric) coordinate**; a **confidence-weighted colorized TSDF** stores the persistent surface + base color + visibility support, while a **capacity-bounded Gaussian layer** is restricted to reliable residual regions to restore appearance detail over the fused surface. On Replica records **0.249 cm mean ATE** and lower ATE in 5 of 8 monocular-evaluated scenes; the hybrid output reaches **30.678 dB PSNR** in a paired comparison. The authors are explicit that the **full pipeline uses future observations and does not establish online/real-time SLAM performance**. Hybrid Gaussian–SDF design is adapted from GPS-SLAM. | A **monocular-only hybrid Gaussian–SDF counterpart** that must solve online the scale ambiguity, spatially varying reliability, and bounded-map-growth problems that Gaussian-LIC2 sidesteps via LiDAR-inertial metric fusion. The **reliability-gated observation** and **canonical dimensional transport** ideas are transferable framings for any learned-prior front end. Cite in the monocular-vs-multisensor and hybrid-geometry-representation discussion. |
| Learned-vs-geometric frontend | **Why does Deep Learning Improve Visual SLAM?** (Cioffi, Scaramuzza; U. Zurich RPG; arXiv:2607.06023, v2 21 Sep 2026) | arXiv Jul 2026, rev. Sep 2026 | Monocular RGB only | A **controlled empirical study** isolating which components of DL-based V-SLAM drive its performance. Replaces ORB-SLAM3's handcrafted descriptor matching with **DROID-SLAM's learned optical flow** (ORB-SLAM3-OF) and adds **learned uncertainty weighting** in BA (ORB-SLAM3-OF-U), keeping the classical feed-forward ORB-SLAM3 backbone fixed. **Finding: the success of DL-based V-SLAM hinges on learned 2D data association and uncertainty, NOT the recurrent architecture** — ORB-SLAM3-OF-U rivals DROID-SLAM/DPVO/DPV-SLAM on TartanAir and **outperforms them on out-of-distribution UZH-FPV**. Open-source. | A **clarifying reference for the learned-frontend-vs-classical-geometry design axis**. Gaussian-LIC2's frontend is classical geometric (LIV factor graph), and this work empirically supports the thesis that learned correspondence + uncertainty — not recurrence — is what makes modern learned V-SLAM robust; it frames where a learned visual frontend could **augment** (not replace) the LIV fusion backend. Cite in the learned-vs-geometric frontend and visual-frontend-design discussion. |

### Why these matter

1. **RawSLAM** is the most directly actionable new entry for
   Gaussian-LIC2's *rendering objective*: it shows that the standard
   8-bit tonemapped photometric loss used by virtually all 3DGS-SLAM
   systems (Gaussian-LIC2 included) discards dynamic range that matters
   for robustness under extreme lighting, and it supplies a drop-in fix
   — an MLP-free logarithmic color parameterization plus a Reinhard
   range-compressed photometric loss — that is architecture-agnostic and

2. **Mono3DGS-SLAM** and **Cioffi & Scaramuzza** together sharpen the
   **monocular-learned-prior vs multi-sensor-metric-fusion** framing
   that has run through Addenda 18–20. Mono3DGS-SLAM is a fresh
   monocular-only hybrid Gaussian–TSDF system that must explicitly
   solve scale canonicalization and observation reliability — problems
   Gaussian-LIC2 sidesteps via LiDAR-inertial metric scale. Cioffi &
   Scaramuzza's controlled study then explains *why* learned monocular
   frontends work (learned correspondence + uncertainty, not recurrence),
   which is the precise axis along which a learned visual frontend could
   augment Gaussian-LIC2's classical geometric frontend without
   replacing the LIV fusion backend. The pair broadens the comparison
   baseline and frames Gaussian-LIC2's contribution as the
   multi-sensor-metric-geometry alternative to the reliability-gated /
   learned-prior paradigm.

### Reproducing the Addendum 21 survey

Searches were run via `mcp__doubao-search__web_search` on 2026-09-27 with
`OneWeek` and `OneMonth` time-range filters:

1. `Gaussian Splatting SLAM LiDAR visual inertial 2026 arxiv` (OneWeek, 12 results)
2. `3DGS SLAM real-time dense mapping reconstruction 2026 arxiv new` (OneWeek, 3 results)
3. `LiDAR visual inertial odometry Gaussian splatting tightly coupled mapping 2026` (OneMonth, 12 results)
4. `Gaussian-LIC2 LIV SLAM continuous-time factor graph spline 2026` (OneMonth, 10 results)
5. `Mono3DGS-SLAM Reliability-Aware Geometric Canonicalization monocular Gaussian TSDF arxiv Wan` (web, 8 results) — confirmed MDPI Appl. Sci. 16(19):9413, 22 Sep 2026; PDF retrieved from the `mdpi-res.com` alternate host.
6. `RawSLAM Online HDR Gaussian SLAM Linear Radiance arxiv Orozco Gonzalez Merino 2026` (web, 8 results) — confirmed arXiv:2609.20589, 17 Sep 2026.
7. `"Why does Deep Learning Improve Visual SLAM" Cioffi Scaramuzza arxiv 2607.06023` (web, 8 results) — confirmed arXiv:2607.06023 v2 21 Sep 2026.

New PDFs downloaded:
`papers/Orozco2026_RawSLAM.pdf` (arXiv:2609.20589, via `curl -sL -o ... https://arxiv.org/pdf/2609.20589`),
`papers/Wan2026_Mono3DGSSSLAM.pdf` (MDPI `mdpi-res.com` alternate host — the primary `www.mdpi.com` host returns 403 to non-interactive clients, same as the LV-GS SLAM case in Addendum 18),
`papers/Cioffi2026_WhyDLVSLAM.pdf` (arXiv:2607.06023, via `curl -sL -o ... https://arxiv.org/pdf/2607.06023`).

### Inventory

`latex/papers/` now holds **92 PDFs**; `latex/bib/references.bib` now holds
**100 BibTeX entries** (`grep -c "^@" bib/references.bib` = 100,
`ls papers/*.pdf | wc -l` = 92). The 8-entry gap is the usual set of
surveyed-without-arXiv-PDF foundational works (Kerbl 3DGS, Mip-Splatting,
Scaffold-GS, Stop-ThePop, Taming-3DGS, iMAP) plus a couple of
venue-only / library-software entries (GTSAM).

## Addendum 22 (2026-09-28) — two newly surveyed related works

**24-hour code-review note.** There **was** one commit in the last 24
hours: `6687e45 docs: 添加多节点协同3DGS-SLAM论文草稿及相关文献调研`
(2026-09-27 16:14:42 +0800, author arthurlirui). It is a **docs-only**
commit — 24 files changed, +6,964 insertions, all under `latex/` (the
survey tree itself: `latex/README.md`, `latex/bib/references.bib`,
`latex/design/DESIGN.md`, `latex/paper/` arXiv-style draft + sections +
figures, `latex/mobicom/` MobiCom draft) plus one session-summary
markdown under `.zcode/` and `scripts/fetch_arxiv.mjs`. **No source-tree
(`src/`, `include/`, `CMakeLists.txt`, `launch/`, `config/`) changes** —
the Gaussian-LIC2 codebase proper was not touched. So there is still
nothing in the code to feed into the related-work assessment; this round
is again purely additive to the survey. (This commit is also the one
that introduced the MobiCo-formatted cooperative-multi-node paper draft
tracked in [[co-lic2-design-paper]].)

Doubao web search was **available** this round. Six
`mcp__doubao-search__web_search` calls were run 2026-09-28 with
`OneWeek` / `OneMonth` time-range filters against the standard
3DGS-SLAM + LiDAR/visual/inertial keyword set. The arXiv-fresh GS-SLAM
submissions of the past two weeks (ArborSplat arXiv:2609.26315, Dual
Covariance GS-SLAM arXiv:2609.25746, both 22 Sep 2026) were already
surveyed in Addendum 17; Mono3DGS-SLAM and RawSLAM were added in
Addendum 21. Two genuinely new papers not in the inventory were
identified and added this round: **VIGS-SLAM** (the ECCV 2026
visual-inertial GS-SLAM that several recent results kept citing as a
baseline) and its direct follow-up **Elevator-VIGS** (arXiv 20 Sep 2026).
A third candidate, **LV-GS SLAM** (He et al., Appl. Sci. 16(16):8028,
Aug 2026, decoupled large-scale LiDAR-Visual 3DGS SLAM, KITTI + quadruped
validation), re-appeared in results but was **already in the bib** as
`he2026lvgsslam` (added Addendum 9, bib-only — MDPI `www.mdpi.com` still
returns 403 to non-interactive clients, so the PDF remains un-fetched);
no change to that entry this round. Other re-appearing candidates ruled
out: LVI-GS (Addendum 7, `zhao2025lvigs`), GS-LIVO (Addendum 8,
`hong2025gslivo`), Structured-Li-GS (Addendum 18,
`weng2026structuredligs`), HI-SLAM2 (Addendum 20, `zhang2026hislam2`).

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| Visual-inertial GS-SLAM | **VIGS-SLAM: Visual Inertial Gaussian Splatting SLAM** (Zhu, Zhang, Li, Haala, Pollefeys, Barath; ETH Zürich + U. Stuttgart + Microsoft; ECCV 2026, LNCS 17055 pp. 322–341; arXiv:2512.02293 v2 13 Mar 2026) | ECCV 2026 | Monocular RGB + IMU | A **tightly-coupled visual-inertial 3DGS SLAM** system. A sliding-window **dense bundle adjustment jointly optimizes per-keyframe pose, per-pixel disparity, and IMU states** (velocity + gyro/accelerometer biases), with a **ConvGRU learned dense-correspondence frontend**, **robust IMU initialization**, **time-varying bias modeling**, and **loop closure with consistent Gaussian updates**. Evaluated on five challenging datasets (incl. FAST-LIVO2 Retail, EuRoC, TUM, TartanAir) and shown to **outperform SOTA 3DGS-SLAM under motion blur / low texture / exposure variation** — the failure modes of purely-visual GS-SLAM. Code to be released. | The **leading visual-inertial (no-LiDAR) contemporary GS-SLAM** and the natural baseline Gaussian-LIC2 is differentiated against on the inertial-coupling axis. VIGS-SLAM validates that inertial coupling materially improves tracking robustness for GS-SLAM, but it still relies on **learned monocular depth priors** rather than metric LiDAR scale — precisely the gap Gaussian-LIC2's LIV fusion closes. Cite in the visual-inertial GS-SLAM and learned-frontend discussion. |
| Moving-platform robustness | **Elevator-VIGS: Separating Elevator Motion from Robot Motion in Visual-Inertial Gaussian Splatting SLAM** (Zhou, Zhu, Zhang, Luo, Haala, Pollefeys; U. Zürich + ETH Zürich + U. Stuttgart + Microsoft; arXiv:2609.23491, 20 Sep 2026) | arXiv Sep 2026 | Monocular RGB + IMU | Extends VIGS-SLAM with a **per-keyframe "transport state"** (elevator rise + vertical velocity) in dense visual-inertial BA to handle the **frame conflict** inside a moving elevator: the camera sees only motion relative to the elevator while the IMU senses world-relative motion. Estimates **robot pose in the elevator frame** and **elevator motion in the world frame**, holds the transport state fixed through optimization, then **folds the rise into poses after the ride**; uses a **zero-shot VLM + depth-network ride detector**. Records real + simulated elevator sequences with laser-measured floor-to-floor GT heights; **SOTA on both**, and keeps VIGS-SLAM's SOTA on four elevator-free benchmarks. | A **moving-platform / degenerate-motion robustness reference** for visual-inertial GS-SLAM. The multi-floor / non-rigid-platform case is one Gaussian-LIC2's LIV fusion would also face in indoor deployment, and the **transport-state decoupling** idea is a candidate formulation for any platform-motion handling in the cooperative multi-node design ([[co-lic2-design-paper]]). Cite in the robustness / degenerate-motion and platform-motion discussion. |

### Why these matter

1. **VIGS-SLAM** fills a structural gap in the survey: until now the
   inventory had the purely-visual GS-SLAM systems (MonoGS, SplaTAM,
   GS-SLAM, Photo-SLAM, Splat-SLAM, HI-SLAM2) and the LiDAR/visual/LIV
   systems (Gaussian-LIC2, GS-LIVM, LIVE-GS, LIT-GS, RMGS-SLAM, LV-GS
   SLAM, Structured-Li-GS), but **no clean visual-inertial (no-LiDAR)
   GS-SLAM baseline**. VIGS-SLAM is that baseline — it is the system
   recent results (incl. Elevator-VIGS, and the Mono3DGS-SLAM related-
   work survey) cite as the visual-inertial SOTA. For Gaussian-LIC2 it
   crystallizes the differentiation: VIGS-SLAM shows inertial coupling
   helps, but without metric depth it leans on learned monocular priors,
   which is exactly what LIV fusion replaces.

2. **Elevator-VIGS** is the first GS-SLAM work to explicitly model a
   **non-rigid sensor-platform motion** (the elevator) inside the VI
   estimator. This matters for Gaussian-LIC2's cooperative multi-node
   extension ([[co-lic2-design-paper]]): when a node is itself on a
   moving platform, the same frame-conflict pathology arises between
   the camera/IMU and the LiDAR, and the **transport-state** formulation
   is a candidate way to decouple platform motion from node-relative
   motion in the cooperative pose graph.

### Reproducing the Addendum 22 survey

Searches were run via `mcp__doubao-search__web_search` on 2026-09-28
with `OneWeek` and `OneMonth` time-range filters:

1. `Gaussian Splatting SLAM 2026 arxiv LiDAR visual inertial` (OneWeek, 9 results)
2. `3DGS SLAM real-time mapping 2026 new method` (OneWeek, 6 results)
3. `Gaussian splatting LiDAR inertial visual odometry 2026` (OneMonth, 15 results)
4. `VIGS-SLAM visual inertial gaussian splatting arxiv Zihan Zhu` (OneMonth, 10 results) — confirmed arXiv:2512.02293 (dblp: `CoRR abs/2512.02293 (2025)`, v2 13 Mar 2026), ECCV 2026 LNCS 17055 pp. 322–341, DOI 10.1007/978-3-032-37261-1_19.
5. `LV-GS SLAM decoupled LiDAR visual gaussian splatting arxiv He Haotong` (OneMonth, 9 results) — confirmed already in bib as `he2026lvgsslam` (Addendum 9); MDPI PDF still 403, no new PDF fetched.
6. `gaussian splatting SLAM loop closure submap distributed multi-agent 2026 arxiv` (OneWeek, 6 results) — surfaced Elevator-VIGS (arXiv:2609.23491, 20 Sep 2026) as a novel moving-platform VI GS-SLAM result.

New PDFs downloaded:
`papers/Zhu2026_VIGSSLAM.pdf` (arXiv:2512.02293, via
`curl -sL -o ... https://arxiv.org/pdf/2512.02293` — 32 MB, valid PDF v1.7,
v2 dated 13 Mar 2026),
`papers/Zhou2026_ElevatorVIGS.pdf` (arXiv:2609.23491, via
`curl -sL -o ... https://arxiv.org/pdf/2609.23491` — 33 MB, valid PDF v1.7).
The LV-GS SLAM MDPI PDF was attempted but
`www.mdpi.com/2076-3417/16/16/8028/pdf` returns an HTML 403 page to
`curl` (same wall as Addenda 9/18/21); the entry remains bib-only
(`he2026lvgsslam`).

### Inventory

`latex/papers/` now holds **93 PDFs**; `latex/bib/references.bib` now
holds **102 BibTeX entries** (`grep -c "^@" bib/references.bib` = 102,
`ls papers/*.pdf | wc -l` = 93). The 9-entry gap is the usual set of
surveyed-without-arXiv-PDF foundational works (Kerbl 3DGS, Mip-Splatting,
Scaffold-GS, Stop-ThePop, Taming-3DGS, iMAP) plus a few venue-only /
library-software / MDPI-403 entries (GTSAM, LV-GS SLAM).

## Addendum 23 (2026-09-29) — three newly surveyed related works

**24-hour code-review note.** There was one commit in the last 24
hours: `07670cb docs: 添加新调研文献、MobiCom论文草稿及.zcodeignore配置`
(2026-09-28 20:02:49 +0800, author arthurlirui). It is a **docs-only**
commit — 29 files changed, +5,985 insertions, spanning `.zcodeignore`
(+57), the survey tree (`latex/README.md`, `latex/bib/references.bib`),
the `latex/mobicom/` MobiCom draft (acmart sigconf: `main.tex` + 11
section files + 6 figure `.tex` + `mobicom_refs.bib` + full build
artifacts `main.{aux,bbl,blg,log,out,pdf}`), and `latex/paper/main.pdf`.
**No source-tree (`src/`, `include/`, `CMakeLists.txt`, `launch/`,
`config/`) changes** — the Gaussian-LIC2 codebase proper was not touched,
so this round is again purely additive to the survey. The notable new
artifact is the MobiCom-formatted cooperative-multi-node paper draft
(`latex/mobicom/`) along with its compiled `main.pdf` — this is the
MobiCom venue version of the cooperative design tracked in
[[co-lic2-design-paper]].

Doubao web search was **available** this round. Six
`mcp__doubao-search__web_search` calls were run 2026-09-29 with
`OneWeek` / `OneMonth` time-range filters against the standard
3DGS-SLAM + LiDAR/visual/inertial keyword set, plus a targeted
multi-robot / cooperative-GS search. The arXiv-fresh GS-SLAM
submissions of the past two weeks (ArborSplat arXiv:2609.26315,
Dual Covariance GS-SLAM arXiv:2609.25746, both 22 Sep 2026) were
already surveyed in Addendum 17. Three genuinely new papers not in the
inventory were identified and added this round: **CoRef-GS** (a
cooperative multi-agent Gaussian-map registration/fusion framework —
the most directly relevant to the Co-LIC2 cooperative design),
**M3GD** (a Camera-LiDAR multimodal generative NVS method that composes
frozen 2D image + 3D point-cloud foundation models), and **LiTe-GS**
(an oracle-efficient next-best-view selection method for 3DGS, more
peripheral). Re-appearing candidates already in the bib and ruled out:
MCGS-SLAM (Addendum, `cao2026mcgsslam`, arXiv:2509.14191 v4 07 Sep
2026), Structured-Li-GS (Addendum 18, `weng2026structuredligs`).

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| Cooperative / multi-agent GS | **CoRef-GS: Cooperative Referring Gaussian Splatting for Multi-Agent Scene Understanding** (Zhou, Peng, Yang, Cai, Wen, Liu, Paudel, Zhou, Van Gool, Yang; Hunan U. + KIT + INSAIT + ETH; arXiv:2609.20586, 17 Sep 2026) | arXiv Sep 2026 | RGB (multi-agent) | A **cooperative multi-agent Gaussian-splatting framework** for referring scene understanding. Each agent builds a **local open-vocabulary instance-aware semantic Gaussian map** (CLIP-aligned anchors + instance grouping); a **cross-agent alignment module** then aligns partially overlapping maps by **geometric + semantic consistency** (coarse-to-fine, image-assisted), and language queries are grounded via a **view-conditioned mask relation graph** from the querying robot's viewpoint. Introduces **CoQuad-Ref**, a dual-quadruped benchmark (real + simulated indoor scenes). Reduces rotation error 2.58° → 0.15° after refinement; improves real-world referring mIoU 52.6% → 68.8% over ReferSplat. Code released. | The **first explicit cooperative multi-agent Gaussian-map registration/fusion** work in the survey and the closest precedent to the cooperative-multi-node design ([[co-lic2-design-paper]]). It tackles exactly the cross-agent map-merging problem a cooperative LIV GS-SLAM must solve — local maps built independently, then aligned and fused into a shared representation. Its limitations define the Co-LIC2 gap: it is **visual + semantic only** (no LiDAR/inertial), alignment is **offline per-scene** rather than inside an online SLAM loop, and it has no metric-scale / loop-closure machinery. Cite in the cooperative/multi-agent GS map-merging discussion as the direct visual-only counterpart Co-LIC2 extends with LIV fusion and online operation. |
| Camera-LiDAR multimodal NVS | **M3GD: Multi-Modal Multi-View Geometric Diffusion for Camera–LiDAR Novel View Synthesis** (Zhou, Xiao, Ye, Quang, Nieto-Granda, Loianno; NYU + UC Berkeley + ARL; arXiv:2609.30056, 24 Sep 2026) | arXiv Sep 2026 | RGB + LiDAR | A **Camera–LiDAR multimodal generative NVS** method that composes **frozen 2D image (Depth Anything 3) and 3D point-cloud (Utonia) foundation models without a separately trained cross-modal translator**. After camera projection, frozen LiDAR and image features share substantial spatial structure, so LiDAR enters the image-latent generative model as **view-aligned "packets"** (explicit geometry statistics + learned point-cloud descriptors) injected via a **lightweight residual adapter** into a multi-view **flow-matching** generator. Target-side LiDAR acts as a **geometric query**. Improves RGB + depth synthesis over image-only on GrandTour; deploys zero-shot on a ground robot with a different sensor suite. | A **Camera-LiDAR multimodal fusion reference at the representation level**, distinct from but neighboring the SLAM-side LIV fusion Gaussian-LIC2 performs. It shows how projected LiDAR features can condition an image-latent generative model — the "frozen-feature composition" idea is complementary to the joint-optimization fusion in Gaussian-LIC2 and relevant where the cooperative design needs feed-forward / generative view synthesis across unobserved viewpoints. Cite in the Camera-LiDAR fusion / generative-NVS-neighboring-work discussion. |
| 3DGS view selection | **LiTe-GS: Oracle-Efficient Next Best View Selection for 3D Gaussian Splatting** (Pandey, Mollaei Khass, Motee; UC Irvine; arXiv:2609.30393, 24 Sep 2026) | arXiv Sep 2026 | (N/A — 3DGS training) | An **oracle-efficient next-best-view (NBV) selection** method for 3DGS that reduces the number of **Fisher-information oracle evaluations** in active view selection from exhaustive greedy to an **ε-constrained randomized subset scheme** with expected **O(M log(1/ε))** complexity (independent of selection cardinality K), with **provable approximation guarantees**. Maintains reconstruction quality on Blender and Mip-NeRF 360 while substantially cutting oracle calls. | **Peripheral to Gaussian-LIC2** (about 3DGS training view selection, not SLAM), but relevant to the **keyframe / active-view-selection** design question for GS-SLAM map refinement — Gaussian-LIC2's keyframe selection and the cooperative design's cross-node view sharing both touch the same information-gain vs. cost trade-off LiTe-GS formalizes. Cite in the view/keyframe-selection discussion as the principled NBV-cost bound. |

### Why these matter

1. **CoRef-GS** is the most significant addition this round for the
   Gaussian-LIC2 program. Until now the survey had no work that
   explicitly performed **cooperative multi-agent Gaussian-map
   registration and fusion**; CoRef-GS is exactly that. For the
   cooperative multi-node LIV GS-SLAM design
   ([[co-lic2-design-paper]]) it is the direct visual-only counterpart
   to cite and differentiate against: CoRef-GS aligns and fuses
   independently reconstructed semantic Gaussian maps across agents,
   but does so offline, visually, and without metric LiDAR scale,
   inertial coupling, or a SLAM loop — precisely the capabilities
   Co-LIC2 adds. Its CoQuad-Ref dual-quadruped benchmark is also a
   useful reference for cooperative-evaluation protocol design.

2. **M3GD** broadens the Camera-LiDAR fusion picture in the survey.
   Gaussian-LIC2 fuses LIV inside a SLAM optimization loop; M3GD shows
   a complementary, feed-forward path where projected LiDAR features
   condition an image-latent generative model without a trained
   cross-modal translator. The "frozen 2D + 3D foundation-model
   composition" finding (projected LiDAR and image features share
   spatial structure after camera projection) is a useful design hint
   for any generative / feed-forward view-synthesis component in the
   cooperative system, e.g. synthesizing views for a node from a
   neighbor's LiDAR sweep.

3. **LiTe-GS** is included for completeness of the view-selection
   thread. Gaussian-LIC2 and the cooperative design both rely on
   keyframe / view selection; LiTe-GS provides the principled
   oracle-complexity bound (O(M log(1/ε)), independent of K) for
   information-driven NBV, which is the kind of cost control a
   real-time cooperative system needs when deciding which node's
   observations to integrate next.

### Reproducing the Addendum 23 survey

Searches were run via `mcp__doubao-search__web_search` on 2026-09-29
with `OneWeek` and `OneMonth` time-range filters:

1. `Gaussian Splatting SLAM 2026 arxiv LiDAR visual inertial` (OneWeek, 7 results) — surfaced ArborSplat (A17) and Dual Covariance GS-SLAM (A17), both already in bib.
2. `3DGS SLAM real-time dense mapping reconstruction 2026 new method` (OneWeek, 3 results) — surfaced LiTe-GS (arXiv:2609.30393, 24 Sep 2026) as a new NBV-selection result.
3. `Gaussian splatting LiDAR inertial visual odometry tightly coupled 2026 arxiv` (OneWeek, 7 results) — re-confirmed ArborSplat + Dual Covariance GS-SLAM.
4. `gaussian splatting SLAM loop closure submap distributed multi-agent 2026 arxiv` (OneWeek, 4 results) — re-confirmed ArborSplat + Dual Covariance GS-SLAM.
5. `LiDAR visual inertial SLAM Gaussian splatting continuous-time spline 2026 new arxiv September` (OneWeek, 10 results) — surfaced M3GD (arXiv:2609.30056, 24 Sep 2026) via the Camera-LiDAR multimodal angle.
6. `multi-robot collaborative SLAM gaussian splatting map merging 2026 arxiv` (OneMonth, 10 results) — surfaced CoRef-GS (arXiv:2609.20586, 17 Sep 2026), the cooperative multi-agent Gaussian-map registration/fusion work; also re-confirmed MCGS-SLAM (`cao2026mcgsslam`, already in bib) and Structured-Li-GS (A18, `weng2026structuredligs`).
7. `M3GD Multi-Modal Multi-View Geometric Diffusion Camera LiDAR Novel View Synthesis arxiv Zhou Xiao` (OneWeek, 6 results) — confirmed arXiv:2609.30056, 24 Sep 2026, NYU + UC Berkeley + ARL.

New PDFs downloaded:
`papers/Zhou2026_CoRefGS.pdf` (arXiv:2609.20586, via
`curl -sL -o ... https://arxiv.org/pdf/2609.20586` — ~5 MB, valid PDF v1.7),
`papers/Zhou2026_M3GD.pdf` (arXiv:2609.30056, via
`curl -sL -o ... https://arxiv.org/pdf/2609.30056` — ~13 MB, valid PDF v1.7),
`papers/Pandey2026_LiTeGS.pdf` (arXiv:2609.30393, via
`curl -sL -o ... https://arxiv.org/pdf/2609.30393` — ~37 MB, valid PDF v1.7).

### Inventory

`latex/papers/` now holds **96 PDFs**; `latex/bib/references.bib` now
holds **105 BibTeX entries** (`grep -c "^@" bib/references.bib` = 105,
`ls papers/*.pdf | wc -l` = 96). The 9-entry gap is the usual set of
surveyed-without-arXiv-PDF foundational works (Kerbl 3DGS, Mip-Splatting,
Scaffold-GS, Stop-ThePop, Taming-3DGS, iMAP) plus a few venue-only /
library-software / MDPI-403 entries (GTSAM, LV-GS SLAM).

## Addendum 24 (2026-09-30) — four newly surveyed related works

**24-hour code-review note.** There were **no new commits** in the last
24 hours — the most recent commit remains `07670cb` (2026-09-28 20:02:49
+0800, "docs: 添加新调研文献、MobiCom论文草稿及.zcodeignore配置"), already
covered in Addendum 23. The working tree has uncommitted edits to the
`latex/mobicom/` MobiCom draft (section `.tex` files, build artifacts
`main.{aux,bbl,blg,log,out}`, `mobicom_refs.bib`, `main.tex`) plus
uncommitted `latex/README.md` / `latex/bib/references.bib` survey
updates; **no source-tree (`src/`, `include/`, `CMakeLists.txt`,
`launch/`, `config/`) changes**. Note: 13 PDFs sit untracked at the
repo root (`Cao2025_RESPLE.pdf`, `DeAmbrogi2026_CGSSLAM.pdf`,
`Hu2026_SGADSLAM.pdf`, `Lang2023_CocoLIC.pdf`, `Lang2026_GaussianLIC2.pdf`,
`Park2026_LIVEGS.pdf`, `Ramezani2022_Wildcat.pdf`, `Shi2026_LITGS.pdf`,
`Tak2026_RealTimeLiDARGS.pdf`, `Thirgood2026_FeatureSLAM.pdf`,
`Wang2026_RoSeSLAM.pdf`, `Xie2024_GSLivM.pdf`, `Zhao2026_CTVoxelMap.pdf`)
— these are **stale duplicates** of files already present in
`latex/papers/` under the same names, not new survey material; they
should be removed or `.zcodeignore`d in a future cleanup. This round is
again purely additive to the survey.

Doubao web search was **available** this round. Four
`mcp__doubao-search__web_search` calls were run 2026-09-30 with
`OneWeek` / `OneMonth` time-range filters against the standard
3DGS-SLAM + LiDAR/visual/inertial keyword set, plus a targeted
cooperative/multi-agent + LIO search. Four genuinely new papers not in
the inventory were identified and added this round: **RRG-SLAM** (a
reflection-aware real-time RGB-D GS-SLAM), **ChronoFuseGS** (a
multi-temporal Gaussian-map fusion method, relevant to the cooperative
map-merging thread), **RRTO-CF3DGS** (a reliability-regulated
progressive COLMAP-free 3DGS trajectory optimizer), and
**CollisionSplatting** (collision-aware motion planning directly on
standard 3DGS scenes). Re-appearing candidates already in the bib and
ruled out: Structured-Li-GS (A18, `weng2026structuredligs`), LV-GS SLAM
(`he2026lvgsslam`, already in bib — the OpenAlex Applied Sciences
result), MCGS-SLAM (`cao2026mcgsslam`), CoRef-GS (A23,
`zhou2026corefgs`), LiTe-GS (A23, `pandey2026litegs`). FMCW-LIO
(arXiv:2609.29374) was excluded — it is a 2024 RA-L paper
(doi:10.1109/LRA.2024.3396636) only recently cross-posted to arXiv, not
a new 2026 result.

| Section | Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---------|-------|--------------|--------|----------|---------------------------|
| RGB-D GS-SLAM (appearance) | **RRG-SLAM: Real-time Reflection-aware Gaussian SLAM for Indoor Scenes** (Liu, Ye, Peng, Mei, Zhou, Shao; Zhejiang U. CAD&CG; arXiv:2609.34527, 28 Sep 2026) | arXiv Sep 2026 | RGB-D | The **first real-time reflection-aware GS-SLAM**: a reflection-aware **TSDF-Gaussian hybrid representation** separates diffuse base appearance (TSDF volume + base Gaussians) from reflection components (reflection groups = reflective plane + virtual-space reflection Gaussians). **Three-pass rendering** (TSDF raycast → OIT base-Gaussian render with depth culling → plane-ID-guided reflection-Gaussian rasterization, composited via reflection mask). Reflection-aware tracking excludes reflection-dominated regions; reflective planes detected by combining geometry (CAPE), semantics (Grounded SAM2), and a temporal raycast color-variance cue in a sliding window. Outperforms GPS-SLAM / GS-ICP SLAM / RTG-SLAM under strong planar reflections while real-time. | **Peripheral** (RGB-D indoor, no LiDAR/inertial), but relevant to the **appearance-modeling / robust-tracking** thread. The reflection/base separation is a transferable idea for LIV GS-SLAM scenes with specular surfaces (glass facades, wet roads) where photometric tracking corrupts. Cite in the appearance / robust-tracking discussion. |
| Multi-model Gaussian fusion | **ChronoFuseGS: Multi-Temporal Gaussian Fusion with Per-Splat Persistence and Change Visualization** (Batik, Marin, K{\'a}n, Kaufmann; TU Wien; arXiv:2609.31339, 25 Sep 2026, Pacific Graphics Short Papers) | arXiv / PG Short 2026 | RGB (multi-temporal) | **Multi-temporal 3DGS fusion**: takes multiple separately-trained 3DGS models (distinct timesteps, partial geographic overlap) and merges them into one combined model with **per-splat persistence encoding** (which timesteps each Gaussian contributes to) and change visualization. Supports incremental extension. Cross-timestep initialization estimates per-Gaussian persistence + light compensation; Gaussians from one timestep refine persistent parts of others, validated against the corresponding timestep's images. Change-aware rendering highlights sub-object-granularity changes. Evaluated on a real outdoor flood-management dataset over 7 months / 8 days; merged model beats single-timestep models in NVS. | Relevant to the **cooperative/distributed map-merging** thread ([[co-lic2-design-paper]]). Like CoRef-GS it fuses independently-built Gaussian maps, but along the **temporal** axis (same place, different time) rather than the agent axis, and without metric SLAM alignment. The **per-splat persistence encoding** is a transferable idea for cooperative map-merging where each node's Gaussians should carry provenance (which node / when observed). Cite in the multi-model Gaussian fusion / map-merging discussion. |
| Pose-free 3DGS tracking | **Reliability-Regulated Trajectory Optimization for Progressive COLMAP-Free 3D Gaussian Splatting** (Wu, Wang, Lin, Song, Lu, Ma, Ye, Jiang; Zhejiang Sci-Tech U. + Tsinghua + Lishui U. + Zhejiang U.; arXiv:2609.30865, 25 Sep 2026) | arXiv Sep 2026 | RGB (pose-free) | Addresses **error compounding in sequential pose-free 3DGS** (CF-3DGS): a self-supervised **bidirectional cycle-consistency reliability signal** that (1) gates first-order kinematic warm-starts into upcoming pairwise registrations (Forward Motion Propagation), intercepting untrusted transitions, and (2) dynamically weights relative-pose consistency constraints in a sliding window (Retrospective Trajectory Correction) — both under one unified reliability regulator, no external neural priors or offline preprocessing. Improves camera trajectory accuracy and NVS over unposed baselines on Tanks&Temples and CO3D-V2. | **Peripheral** (visual-only, no LiDAR/inertial, not a full SLAM loop), but relevant to the **pose-tracking-robustness** thread. Reliability-gated progressive registration is conceptually adjacent to how a LIV GS-SLAM must gate which frame-to-frame constraints to trust, and the retrospective sliding-window correction echoes loop-closure / local-BA design. Cite in the pose-tracking / drift-mitigation discussion. |
| 3DGS downstream (planning) | **CollisionSplatting: Collision-Aware Motion Planning in 3DGS Scenes with Image-Conditioned Objectives and Adjustable Conservatism** (Khorrambakht, Ortiz-Haro, Weiss, Righetti; NYU + ANITI Toulouse + Klagenfurt; arXiv:2609.35619, 28 Sep 2026) | arXiv Sep 2026 | 3DGS scene (planning) | **Collision-aware motion planning directly on standard 3DGS scenes**: a simple, modular, GPU-accelerated, probability-inspired distance metric with tunable conservatism operating on standard (unnormalized) 3DGS, supporting anisotropic/isotropic Gaussians, 2DGS disks, and ellipsoidal/spherical multi-link robot primitives. Extends a point-ellipsoid scaling-function distance to Gaussian obstacles via probability propagation. On-par or better collision-classification vs Splat-Nav / SAFER-SPLAT / ATLASNav / SPLANNING with substantially higher throughput and lower VRAM. Integrated into GPU MPPI and RRT planners (7-DoF manipulator + quadruped) with real-world demos. Positions 3DGS as an action-conditioned world model bridging perception and real-time planning. | **Peripheral** (planning on a built
3DGS scene, not SLAM), but relevant to the **downstream-application / deployment** thread. A cooperative LIV GS-SLAM's merged Gaussian map is exactly the representation such planners consume, and the standard-3DGS, single-kernel, low-VRAM design is attractive for the cooperative system's edge-node compute budget. Cite in the application / downstream-impact discussion. |

### Why these matter

1. **ChronoFuseGS** is the most relevant addition this round for the
   cooperative program ([[co-lic2-design-paper]]). It joins CoRef-GS
   (A23) as a second concrete example of **fusing independently-built
   Gaussian maps into a shared representation**, but along the temporal
   axis rather than the agent axis. Its **per-splat persistence
   encoding** — each Gaussian records which timesteps it contributes to,
   validated against the corresponding images — is directly transferable
   to cooperative map-merging, where each node's Gaussians should carry
   provenance (which node / when observed) so the fused map can be
   queried, de-duplicated, and updated by the right node. ChronoFuseGS
   and CoRef-GS together now bracket the multi-model Gaussian-fusion
   design space (temporal vs. spatial/agent), sharpening the
   differentiation for Co-LIC2's online, metric, LIV-fused map-merging.

2. **RRG-SLAM** extends the appearance-modeling thread. Gaussian-LIC2
   relies on photometric tracking; RRG-SLAM shows that strong planar
   reflections corrupt both photometric and feature-based tracking and
   demonstrates that explicitly separating reflection from base
   appearance (in a TSDF-Gaussian hybrid) restores tracking robustness
   and rendering quality in real time. For LIV GS-SLAM deployed in
   outdoor scenes with glass facades or wet roads, the reflection/base
   separation is a concrete robustness technique worth citing and
   potentially adapting.

3. **RRTO-CF3DGS** contributes to the pose-tracking-robustness thread.
   Its reliability-gated progressive registration — trust-gating
   frame-to-frame constraints with a self-supervised cycle-consistency
   signal and retrospectively correcting a sliding window — echoes the
   trust-gating and local-BA / loop-closure mechanisms a real-time LIV
   GS-SLAM needs. It is a useful visual-only reference for the
   drift-mitigation discussion even though it lacks LiDAR/inertial.

4. **CollisionSplatting** rounds out the downstream-application
   picture. The cooperative system's deliverable is a merged Gaussian
   map that downstream planners consume; CollisionSplatting shows that
   standard 3DGS (not a custom normalized variant) already supports
   real-time, low-VRAM collision-aware planning, which is encouraging
   for deploying the cooperative map on edge nodes with limited compute.

### Reproducing the Addendum 24 survey

Searches were run via `mcp__doubao-search__web_search` on 2026-09-30
with `OneWeek` and `OneMonth` time-range filters:

1. `3DGS SLAM LiDAR visual inertial 2026` (OneWeek, 5 results) — re-confirmed Structured-Li-GS (A18) and LV-GS SLAM (`he2026lvgsslam`, already in bib); surfaced RRG-SLAM (arXiv:2609.34527, 28 Sep 2026) and LiTe-GS (A23, already in bib).
2. `Gaussian splatting SLAM real-time 2026 arxiv` (OneWeek, 7 results) — surfaced CollisionSplatting (arXiv:2609.35619, 28 Sep 2026) and RRG-SLAM; re-confirmed LiTe-GS (A23).
3. `cooperative multi-agent Gaussian splatting map merging SLAM 2026` (OneMonth, 15 results) — surfaced ChronoFuseGS (arXiv:2609.31339, 25 Sep 2026); re-confirmed CoRef-GS (A23) and MCGS-SLAM (`cao2026mcgsslam`).
4. `LiDAR inertial visual odometry mapping real-time arxiv 2026` (OneWeek, 6 results) — surfaced FMCW-LIO (arXiv:2609.29374), excluded as a 2024 RA-L paper (doi:10.1109/LRA.2024.3396636) only recently cross-posted; re-confirmed LV-GS SLAM.
5. `Gaussian splatting SLAM arxiv September 2026 indoor outdoor reconstruction` (OneWeek, 7 results) — surfaced RRTO-CF3DGS (arXiv:2609.30865, 25 Sep 2026) and TangoGS (arXiv:2609.31248, a compact-3DGS model-sizing method, ruled out as non-SLAM/offline); re-confirmed RRG-SLAM and ChronoFuseGS.

New PDFs downloaded:
`papers/Liu2026_RRGSLAM.pdf` (arXiv:2609.34527, via
`curl -sL -o ... https://arxiv.org/pdf/2609.34527` — ~22 MB, valid PDF),
`papers/Batik2026_ChronoFuseGS.pdf` (arXiv:2609.31339, via
`curl -sL -o ... https://arxiv.org/pdf/2609.31339` — ~15 MB, valid PDF),
`papers/Wu2026_RRTOCF3DGS.pdf` (arXiv:2609.30865, via
`curl -sL -o ... https://arxiv.org/pdf/2609.30865` — ~15 MB, valid PDF),
`papers/Khorrambakht2026_CollisionSplatting.pdf` (arXiv:2609.35619, via
`curl -sL -o ... https://arxiv.org/pdf/2609.35619` — ~2.3 MB, valid PDF).

### Inventory

`latex/papers/` now holds **100 PDFs**; `latex/bib/references.bib` now
holds **109 BibTeX entries** (`grep -c "^@" bib/references.bib` = 109,
`ls papers/*.pdf | wc -l` = 100). The 9-entry gap is the usual set of
surveyed-without-arXiv-PDF foundational works (Kerbl 3DGS, Mip-Splatting,
Scaffold-GS, Stop-ThePop, Taming-3DGS, iMAP) plus a few venue-only /
library-software / MDPI-403 entries (GTSAM, LV-GS SLAM).

## Addendum 25 (2026-10-01) — two newly surveyed related works

### 24-hour code review

The last 24 hours of git history (since 2026-09-30 ~02:00) contain two
commits, both **docs-only / no source-tree changes**:

- `c55364d` (2026-09-30 13:35, "docs(latex): 添加新调研文献并精简MobiCom论文草稿")
  — 26 files, +2430/−1590 lines, entirely under `latex/` (README.md,
  bib/references.bib, the `latex/mobicom/` acmart sigconf draft with
  sections/figures/mobicom_refs.bib + recompiled main.pdf, and
  `latex/paper/main.pdf`). No code under `src/`, `include/`, `launch/`,
  `config/`, or `CMakeLists.txt` was touched.
- `e37c5c5` (2026-09-30 13:49, "chore(gitignore): 忽略调研文献PDF，保持仓库轻量")
  — 1 file, +4 lines to `.gitignore` (excluding the `latex/papers/*.pdf`
  bulk from version control). No source-tree changes.

So the Gaussian-LIC2 implementation tree itself is unchanged since
Addendum 24; this round is purely a literature-refresh pass.

### New papers added this round

Two genuinely new papers not in the inventory were identified and added.
Re-appearing candidates already in the bib were ruled out: RRG-SLAM
(A24, `liu2026rrgslam`), LiTe-GS (A23, `pandey2026litegs`), CoRef-GS
(A23, `zhou2026corefgs`), LV-GS SLAM (`he2026lvgsslam`), Structured-Li-GS
(A18, `weng2026structuredligs`), Wanderland (`liu2026wanderland`).

| Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---|---|---|---|---|
| **MAGS-SLAM** (`cao2026magsslam`, arXiv:2605.10760, v2 27 Jul 2026) | arXiv (cs.RO) | RGB only (monocular) | First monocular RGB-only multi-agent 3DGS SLAM: per-agent DROID-BA + Metric3D-v2 JDSA local Gaussian submaps, compact submap summaries (128-D desc + sparse 3D pts + anchor KF), coordinator builds global **Sim(3)** submap pose graph (MaPGBA) coupling geometric + photometric residuals, occupancy-aware Gaussian fusion (occupied + free-space voxel dedup), joint pose-Gaussian photometric refinement. RGB-only beats RGB-D collaborative baselines (43.24 dB PSNR on ReplicaMultiagent, +5 dB on ETH3D over MAC-Ego3D). Releases ReplicaMultiagent Plus (4 agents, long-horizon, semantic). | **Cooperative multi-node thread — direct.** The visual-only RGB cooperative counterpart to Co-LIC2 [[co-lic2-design-paper]]. Key contrast: MAGS-SLAM must solve monocular scale ambiguity via Sim(3) + Metric3D priors, while Co-LIC2's LiDAR yields metric scale directly (inter-node alignment is SE(3), not Sim(3)). Its occupancy-aware dedup (occupied + free-space voxel test, 0.10 m voxels) is directly transferable to LIV cooperative Gaussian-map fusion; its compact-submap-summary + coordinator architecture informs the communication-efficient protocol design. Cite as the RGB-only multi-agent baseline alongside CoRef-GS (A23, semantic/registration) and ChronoFuseGS (A24, temporal fusion). |
| **DynActiveGS** (`duan2026dynactivegs`, arXiv:2608.01178, v2 27 Sep 2026) | ACM Multimedia 2026 | RGB-D | Dynamic-aware active reconstruction: online pixel-wise uncertainty prediction + uncertainty-weighted Gaussian optimization suppresses motion-corrupted observations; explicitly decomposes uncertainty into **structural uncertainty** (under-reconstructed static regions) vs **motion-induced uncertainty** (dynamically unreliable areas), driving dynamic-aware viewpoint selection (Voronoi-graph local-global scoring) + motion-constrained path planning in a closed-loop pipeline. Beats active-reconstruction baselines (ActiveSplat, ActiveGS) on dynamic benchmarks. | **Robustness / dynamic-environment thread — peripheral.** RGB-D active reconstruction, no LiDAR/inertial, not full SLAM, but the structural-vs-motion uncertainty decomposition is transferable to LIV GS-SLAM for distinguishing geometric under-coverage from dynamic-object contamination in the Gaussian map; the closed-loop active-viewpoint idea connects to keyframe/active-view selection. Cite in the dynamic-scene / robustness discussion. |

### Why these matter

1. **MAGS-SLAM** is the most directly relevant new work for the
   cooperative multi-node design. It is the first system to show that a
   *pure-RGB* multi-agent 3DGS SLAM can match or beat RGB-D collaborative
   baselines, by correctly handling cross-agent scale via a Sim(3)
   submap pose graph and deduplicating Gaussians with an occupancy-aware
   (occupied + free-space) voxel test. For Co-LIC2 this matters in two
   ways. First, it validates the submap-summary + coordinator
   architecture as a communication-efficient collaboration pattern that
   scales beyond two agents (4 agents in ReplicaMultiagent Plus).
   Second, it gives a concrete baseline to position against: Co-LIC2's
   LIV fusion removes the scale-ambiguity problem that dominates
   MAGS-SLAM's design (its ablation shows dropping Sim(3)→SE(3) costs
   21.72 dB), so the LIV setting should simplify the hardest part of
   cooperative Gaussian SLAM while the occupancy-aware fusion +
   compact-summary ideas still carry over.

2. **DynActiveGS** extends the robustness thread into dynamic
   environments. The structural-vs-motion uncertainty decomposition is
   a useful conceptual tool: in a LIV GS-SLAM map, "under-reconstructed
   static regions" (need more keyframes) and "dynamically contaminated
   regions" (need to reject observations) call for opposite responses,
   and DynActiveGS shows that explicitly separating the two uncertainty
   fields — rather than collapsing them into a single scalar — improves
   both reconstruction and exploration. This is a citable reference for
   any dynamic-object handling / uncertainty-aware mapping discussion in
   the Co-LIC2 paper, even though DynActiveGS itself is RGB-D and
   offline-active rather than LIV and online-SLAM.

### Reproducing the Addendum 25 survey

Searches were run via `mcp__doubao-search__web_search` on 2026-10-01
with `OneWeek` and `OneMonth` time-range filters:

1. `3DGS SLAM LiDAR inertial visual 2026` (OneWeek, 5 results) — re-confirmed Structured-Li-GS (A18); surfaced the Unified Multi-Modal Landmark Tracking LIVO paper (a CSDN review of a non-3DGS tightly-coupled LIVO paper, excluded as not Gaussian-based).
2. `Gaussian Splatting SLAM real-time tracking mapping arXiv 2026` (OneWeek, 6 results) — re-confirmed LiTe-GS (A23) and RRG-SLAM (A24); surfaced **DynActiveGS** (arXiv:2608.01178, v2 27 Sep 2026, ACM MM 2026).
3. `cooperative multi-agent multi-robot Gaussian Splatting map fusion 2026` (OneMonth, 16 results) — re-confirmed CoRef-GS (A23); surfaced **MAGS-SLAM** (arXiv:2605.10760, v2 27 Jul 2026, the first monocular RGB-only multi-agent 3DGS SLAM).
4. `LiDAR-Inertial-Visual odometry SLAM Gaussian splatting online 2026` (OneMonth, 14 results) — re-confirmed LV-GS SLAM (`he2026lvgsslam`), ArborSplat (A17, `masini2026arborsplat`), Wanderland (`liu2026wanderland`, already in bib); no new LIV GS-SLAM papers this window.
5. `distributed collaborative Gaussian splatting SLAM multi-robot map merging 2026 arXiv` (OneMonth, 11 results) — re-confirmed CoRef-GS (A23) and HAMMER (already noted); surfaced ScaleGS (a distributed *training* framework for large-scale 3DGS, not SLAM, excluded) and MAGS-SLAM (confirmed, added).

New PDFs downloaded:
`papers/Cao2026_MAGSSLAM.pdf` (arXiv:2605.10760, via
`curl -sL -o ... https://arxiv.org/pdf/2605.10760` — ~3.0 MB, valid PDF),
`papers/Duan2026_DynActiveGS.pdf` (arXiv:2608.01178, via
`curl -sL -o ... https://arxiv.org/pdf/2608.01178` — ~5.1 MB, valid PDF).

### Inventory

`latex/papers/` now holds **102 PDFs**; `latex/bib/references.bib` now
holds **111 BibTeX entries** (`grep -c "^@" bib/references.bib` = 111,
`ls papers/*.pdf | wc -l` = 102). The 9-entry gap is the usual set of
surveyed-without-arXiv-PDF foundational works (Kerbl 3DGS, Mip-Splatting,
Scaffold-GS, Stop-ThePop, Taming-3DGS, iMAP) plus a few venue-only /
library-software / MDPI-403 entries (GTSAM, LV-GS SLAM).

## Addendum 26 (2026-10-02) — two newly surveyed related works

### 24-hour code review

The last 24 hours of git history (since 2026-10-01 ~02:00) contain two
commits, both **docs-only / no source-tree changes**:

- `c3b426f` (2026-10-01 21:03, "docs(latex): 添加新调研文献并更新相关工作综述日期")
  — 2 files, +180/−2 lines, entirely under `latex/` (README.md Addendum 25
  appended, bib/references.bib +91 lines for MAGS-SLAM + DynActiveGS). No
  code under `src/`, `include/`, `launch/`, `config/`, or `CMakeLists.txt`
  was touched.
- `1bbb9e6` (2026-10-01 21:11, "fix(mobicom): 修复未定义引用、标题书签警告并恢复数据流程图")
  — 5 files, +279/−239 lines, all under `latex/mobicom/` (recovered the
  Node Descriptor anchor `sec:descriptor` to clear three `??` undefined
  references in calibration/hardware/system; switched `\title` to
  `\texorpdfstring` to silence hyperref PDF-bookmark Unicode warnings;
  re-attached the orphan `dataflow.tex` figure into §3 fusion subsection
  as `fig:dataflow`, all 8 figures now live; full 4-pass recompile to 0
  undefined refs/citations, 0 overfull, 15 pages). No source-tree changes.

So the Gaussian-LIC2 implementation tree itself is unchanged since
Addendum 25; this round is purely a literature-refresh pass on top of a
MobiCom-draft fix-up.

### New papers added this round

Two genuinely new papers not in the inventory were identified and added.
Re-appearing candidates already in the bib were ruled out: VarSplat
(`tran2026varsplat`, CVPR 2026), VBGS-SLAM (`zhu2026vbgsslam`), Pi3MOS-SLAM
(`zhong2026pi3mosslam`), LV-GS SLAM (`he2026lvgsslam`), ArborSplat
(`masini2026arborsplat`, A17), Wanderland (`liu2026wanderland`),
Dual-Covariance GS-SLAM (`tan2026dualcovgsslam`, A17), FilterGS
(arXiv:2603.23891, non-SLAM LoD rendering acceleration, excluded),
UGOD (arXiv:2609.39089, sparse-view 3DGS not SLAM, excluded).

| Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---|---|---|---|---|
| **BayesianGS-SLAM** (`kang2026bayesiangssslam`, arXiv:2609.24140, 21 Sep 2026) | arXiv (cs.RO) | RGB-D | Uncertainty-aware 3DGS-SLAM via a tractable probabilistic formulation: decomposes predictive uncertainty into a **sensor-noise** component and an **opacity-induced map-representation** component, propagated through rendering by linearization. The same predictive uncertainty is reused across the whole SLAM pipeline — uncertainty-augmented mapping, uncertainty-normalized robust tracking, and a **predictive-surprise** (negative posterior-predictive likelihood) keyframe-selection criterion that cuts redundant mapping updates. First uncertainty-aware GS-SLAM to estimate predictive uncertainty for **both color and depth** and integrate it into mapping + tracking + keyframe selection. On real-world RGB-D datasets: substantially improved depth-uncertainty–error ranking vs. UncLe-SLAM / CG-SLAM / VarSplat / VBGS-SLAM, fewer keyframes/mapping calls at competitive tracking+rendering. | **Uncertainty / robustness thread — peripheral but direct conceptual fit.** RGB-D (no LiDAR/inertial), but sits squarely in the uncertainty-aware GS-SLAM family already in the bib (VarSplat, VBGS-SLAM). The unified sensor-noise + map-representation decomposition is the cleanest formulation yet of "where does 3DGS-SLAM uncertainty come from" and transfers cleanly to LIV GS-SLAM: LiDAR depth uncertainty and visual appearance uncertainty can enter as separate sensor-noise terms, while Gaussian-map coverage enters as the opacity-induced term. The predictive-surprise keyframe criterion is directly transferable to information-driven keyframe selection in LIV GS-SLAM. Cite alongside VarSplat/VBGS-SLAM in the uncertainty-aware discussion. |
| **CognitiveReality** (`kozlov2026cognitivereality`, arXiv:2609.31418, 25 Sep 2026) | arXiv (cs.RO) | RGB-D + (any SLAM backend) | Robot-agnostic semantic Gaussian mapping with an LLM agent for collaborative VR teleoperation: one mapper binary serves any platform via config, ingesting poses from robot SLAM / joint kinematics / motion capture / inline visual tracker; bridges localization outages via a **shadow tracker + keyframe-anchored PnP** (pose error 1–8 cm over 5–40 s outages); maintains **open-vocabulary instance identities with per-object quality at 2 Hz**; speech + controller rays grounded against persistent scene objects via validated typed tools (local Qwen3-VL-8B router at 81.24% tool exact match); Gaussian-TSDF map beats Gaussian+SDF baseline by 2–8 dB; deployed live on two quadrupeds (26/30 navigation + 20/20 re-observation requests). | **Cooperative / semantic-mapping thread — relevant.** The **robot-agnostic pose-ingestion design** (any SLAM backend, including a LIV one) is the closest existing analogue to a cooperative-map node that does not assume a single tracker; the **persistent open-vocabulary instance indexing with quality tracking** transfers to a cooperative LIV GS-SLAM where multiple nodes contribute to a shared semantic Gaussian map and need per-object provenance/quality; the **outage-bridging shadow tracker** connects to robustness under inter-node communication or SLAM dropouts. Cite in the cooperative multi-node + semantic-mapping discussion. |

### Why these matter

1. **BayesianGS-SLAM** tightens the uncertainty-aware GS-SLAM story.
   VarSplat (in bib) learns per-splat *color* variance and uses it in
   tracking/registration/loop detection; VBGS-SLAM (in bib) puts
   variational posteriors over Gaussian *parameters* for closed-form
   updates. BayesianGS-SLAM is the first to argue — and demonstrate —
   that the right move is to decompose predictive uncertainty into
   **sensor-noise** + **opacity-induced map-representation** terms for
   *both* color and depth, and then reuse that single quantity across
   mapping, tracking, *and* keyframe selection. For Co-LIC2 this is
   useful in two ways. First, it gives a principled place to insert
   LiDAR-specific sensor-noise terms alongside the visual ones in a LIV
   GS-SLAM, rather than bolting on a separate depth-uncertainty model.
   Second, its **predictive-surprise keyframe criterion** (negative
   posterior-predictive likelihood, an information-gain quantity) is a
   cleaner, principled replacement for the heuristic keyframe triggers
   common in GS-SLAM, and it explicitly reduces redundant mapping
   updates — relevant to the cooperative setting where each node's
   mapping budget is constrained.

2. **CognitiveReality** extends the cooperative/semantic thread. It is
   not a multi-*agent* SLAM system like CoRef-GS / MAGS-SLAM, but its
   architecture is the closest existing analogue to a **single-node
   cooperative map server**: a robot-agnostic mapper that ingests poses
   from any SLAM backend and maintains a shared, semantically indexed
   Gaussian map that multiple consumers (here, a VR operator + an LLM
   agent) read and write. Three design elements are directly
   transferable to Co-LIC2's cooperative LIV GS-SLAM: (a) the
   robot-agnostic pose ingestion, which generalizes naturally to
   multi-node pose streams from heterogeneous LIV rigs; (b) persistent
   open-vocabulary instance identities with per-object quality tracking,
   which is exactly the per-object provenance a cooperative semantic
   Gaussian map needs when multiple nodes observe the same instance;
   and (c) the shadow tracker + keyframe-anchored PnP that bridges SLAM
   outages, relevant to inter-node communication gaps or tracker
   failures in a cooperative deployment.

### Reproducing the Addendum 26 survey

Searches were run via `mcp__doubao-search__web_search` on 2026-10-02
with `OneWeek` and `OneMonth` time-range filters:

1. `Gaussian Splatting SLAM LiDAR visual inertial 2026` (OneWeek, 4 results)
   — re-confirmed MonoGS (CVPR 2024, in bib); surfaced DroneSplat+
   (TPAMI Oct 2026, drone RGB 3DGS reconstruction, excluded as non-SLAM)
   and the Uncertainty-Driven 3DGS RGB-D SLAM (Jiang et al., TASE 2026)
   which itself cites VarSplat/VBGS-SLAM already in the bib.
2. `3DGS SLAM multi-agent cooperative map fusion 2026 arXiv` (OneWeek, 5
   results) — re-confirmed MAGS-SLAM (A25); surfaced **CognitiveReality**
   (arXiv:2609.31418, 25 Sep 2026) and HAMMER (arXiv:2501.14147, LRA
   2025, server-based collaborative semantic 3DGS — ruled out as already
   considered and not LIV/cooperative-SLAM-core).
3. `LiDAR inertial visual Gaussian Splatting SLAM real-time 2026 arXiv`
   (OneMonth, 12 results) — re-confirmed Wanderland (`liu2026wanderland`,
   CVPR 2026), LV-GS SLAM (`he2026lvgsslam`), ArborSplat (A17),
   Dual-Covariance GS-SLAM (A17); no new LIV GS-SLAM papers this window.
4. `VarSplat uncertainty-aware 3D Gaussian Splatting RGB-D SLAM arXiv`
   (no time-range, 20 results) — re-confirmed VarSplat, VBGS-SLAM,
   GAVIS, UNG-GS, PUP-3DGS, POp-GS; surfaced **BayesianGS-SLAM**
   (arXiv:2609.24140, 21 Sep 2026) as the new uncertainty-aware GS-SLAM
   entry not yet in the inventory.
5. `Gaussian Splatting SLAM 2026 new arXiv October September large-scale
   outdoor` (OneWeek, 11 results) — re-confirmed FilterGS (non-SLAM LoD
   rendering), RRG-SLAM (A24), RRTO-CF3DGS (A24); surfaced UGOD
   (arXiv:2609.39089, sparse-view 3DGS, excluded as non-SLAM) and a
   batch of feed-forward / dynamic-3DGS papers (AESplat, DispFlow-GS,
   NRF-GS, SurgGMF) all excluded as non-SLAM.

### Inventory

After Addendum 26 the survey holds **113 BibTeX entries** in
`bib/references.bib` and **104 PDFs** in `papers/`. The 24-h code review
recorded two docs-only commits (Addendum 25 survey files + a MobiCom
undefined-reference/figure fix); no source-tree changes. RMGS-SLAM
(arXiv:2604.12942) remains the closest contemporary LiDAR-Inertial-Visual
3DGS SLAM head-to-head baseline; VIGS-SLAM (A22) the visual-inertial
baseline; CoRef-GS (A23) the cooperative multi-agent visual+semantic
baseline; MAGS-SLAM (A25) the cooperative multi-agent RGB-only baseline;
ChronoFuseGS (A24) the temporal-axis Gaussian-map-fusion counterpart;
and BayesianGS-SLAM (A26) now joins VarSplat + VBGS-SLAM as the
uncertainty-aware GS-SLAM family to cite in the robustness discussion.

## Addendum 27 (2026-10-03) — four newly surveyed related works

### 24-hour code review

The last 24 hours of git history (since 2026-10-02 ~02:10) contain **no
new commits** — the last commit is still `1bbb9e6` (2026-10-01 21:11,
"fix(mobicom): 修复未定义引用、标题书签警告并恢复数据流程图"). The working
tree carries uncommitted edits to `latex/README.md` and
`latex/bib/references.bib` from Addendum 26 (+199 lines, the
BayesianGS-SLAM + CognitiveReality entries). No code under `src/`,
`include/`, `launch/`, `config/`, or `CMakeLists.txt` was touched. So the
Gaussian-LIC2 implementation tree is unchanged since Addendum 26; this
round is purely a literature-refresh pass.

### New papers added this round

Four genuinely new papers not in the inventory were identified and
added. The Doubao search surfaced a productive cluster around the
**FAST-LIVO2-lineage LIVO family** — the same lineage Gaussian-LIC2
builds on — so this round substantially strengthens the LIVO /
multi-camera / degeneracy-handling coverage. Re-appearing candidates
already in the bib were ruled out: Structured-Li-GS (A18, ISPRS 2026),
Pi3MOS-SLAM (`zhong2026pi3mosslam`, CVPR 2026), MCGS-SLAM
(`cao2026mcgsslam`, ICRA 2026), RRG-SLAM (A24), CoRef-GS (A23),
DroneSplat+ (TPAMI Oct 2026, drone RGB 3DGS, non-SLAM, excluded),
AESplat / NRF-GS (feed-forward / appearance 3DGS, non-SLAM, excluded),
MonoGS (CVPR 2024, in bib).

| Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---|---|---|---|---|
| **Omni-LIVO** (`cao2026omnilivo`, arXiv:2509.15673 v5 29 Mar 2026; IEEE RA-L 11(4):4369–4376, Apr 2026) | IEEE RA-L 2026 | Multi-camera + LiDAR + IMU | Tightly-coupled **multi-camera LIVO extending FAST-LIVO2**. A Cross-View temporal-migration direct-alignment strategy preserves photometric consistency across **non-overlapping** camera views as patches transition between cameras; the ESIKF is extended with multi-view updates + adaptive per-view covariance for heterogeneous measurement reliability; LiDAR-derived depth drives multi-camera sparse direct alignment for extended spatial coverage. Outperforms SOTA LIVO / LIO / VI-SLAM baselines; deployed on the Omni-Bot underground-parking inspection robot (4-view panoramic camera + 360° LiDAR + IMU). | **Direct LIVO-lineage relative — high relevance.** Same FAST-LIVO2 base as Gaussian-LIC2. The multi-camera extension is the natural counterpart to a single-node multi-camera LIV rig, and the cross-view patch migration + adaptive multi-view ESIKF transfer to a cooperative LIV setting where different nodes / cameras observe non-overlapping regions of the same LiDAR-colored map. Cite alongside FAST-LIVO2 / GS-LIVO as the multi-camera LIVO extension. |
| **SA-LIVO** (`cao2026salivo`, arXiv:2606.25699 v2 6 Aug 2026, v1 24 Jun 2026) | arXiv (cs.RO) | LiDAR + camera + IMU | **Subspace-Aware LIVO** addressing independent failure modes (LiDAR degeneracy vs vision degradation). SAIF eigendecomposes the **joint LiDAR-visual information matrix** and gates each eigendirection by a single-threshold linear clamp — attenuating degenerate directions, passing well-observed ones at full strength; robust per-residual gating + scene-level quality factor screen corrupted measurements. LiDAR + visual residuals share **one InEKF loop at a shared linearization point**, and photometric Jacobians are assembled once and reused across iterations (visual information contributes only where LiDAR is deficient). 29 sequences (HILTI'22, NCD, Oxford Spires): competitive accuracy, bounded drift where R3LIVE / SR-LIVO diverge; 12.3 ms/frame laptop CPU, 26.8 ms embedded ARM w/o GPU, 3.6–6.3× lower peak memory. | **Direct LIVO-lineage relative — high relevance for robustness.** Same FAST-LIVO2 lineage. The direction-selective subspace-aware fusion is the principled degeneracy-handling counterpart to ad-hoc modality gating, directly transferable to a LIV GS-SLAM where LiDAR and visual residuals must be fused per-direction under geometric / photometric degradation; the single-loop InEKF with reused photometric Jacobians is an efficiency pattern relevant to embedded cooperative-node deployment. Cite in the LIVO / degeneracy-handling discussion. |
| **FIRE-LIVWO** (`hu2026firelivwo`, arXiv:2609.05325 v1 4 Sep 2026) | arXiv (cs.RO) | LiDAR + camera + IMU + 4D mmWave radar + wheel | **Failure-Immune mmWave-Radar-Enhanced LiDAR-Inertial-Visual-Wheel Odometry** for large-scale underground coal mines with combined visual + geometric degeneracy. IESKF-based tightly-coupled multi-modal fusion in a unified VoxelMap: LiDAR-radar point-to-plane residuals + sparse visual photometric residuals + pointwise Doppler velocity constraints (mmWave penetration in smoke/dust) + wheel odometry with non-holonomic constraints + online lever-arm compensation (long-corridor geometric degeneracy). A degradation-detection + adaptive fusion model-switching strategy grounded in geometric + visual observability analysis dynamically adjusts modality weights/activation. Real-world coal-mine experiments: avg error 5.677 m, superior to baselines; open-sourced. | **Robustness / degeneracy-handling thread — peripheral but relevant.** The most aggressive extension of the LIVO degeneracy-handling thread (cf. SA-LIVO's subspace-aware approach): adds mmWave radar + wheel odometry as complementary modalities under combined smoke/dust visual failure + corridor geometric failure. Peripheral to the core LIV GS-SLAM design but relevant to the robustness / degeneracy-handling discussion and to extreme-environment deployment. Cite alongside SA-LIVO in the degeneracy-handling discussion. |
| **StreamRig** (`wei2026streamrig`, arXiv:2609.40244 v1 30 Sep 2026) | arXiv (cs.CV) | Multi-camera (visual only) | **Streaming multi-camera odometry on a frozen multi-view 3D foundation model** — the first streaming odometer to transfer a frozen multi-view 3D foundation model to general multi-camera rigs. A frozen front-end jointly encodes synchronized images with intrinsics + rig extrinsics; a Rig-Resampler compresses each camera's features into a few latent tokens; a CausalBridge applies causal attention with a key-value cache; a lightweight head regresses rig poses; periodic re-anchoring supports stable long-sequence estimation. Only 74.6M trainable params, relative poses as sole supervision; two-stage training (group relocalization pretraining + causal rig training). Evaluated on NCLT, TartanGround, KITTI-360 + a humanoid-robot rig (zero-shot real-world transfer): lowest drift among non-oracle methods; 5-camera inference lower memory + latency than monocular CUT3R. | **Multi-camera / learned-odometry thread — peripheral.** Visual-only learned odometry, no LiDAR / inertial / Gaussian map. The multi-camera rig-aware streaming formulation is a reference for learned multi-camera front-ends that could complement a LIV GS-SLAM, and the freeze-and-stream transfer recipe (frozen 3D foundation model + compact trained pose back-end) is a relevant pattern for future learned-frontend integration. Cite in the multi-camera / learned-odometry discussion. |

### Why these matter

1. **Omni-LIVO + SA-LIVO** strengthen the FAST-LIVO2-lineage LIVO
   coverage — the same lineage Gaussian-LIC2 builds on. **Omni-LIVO**
   is the multi-camera extension of FAST-LIVO2, and its Cross-View
   temporal patch migration + adaptive multi-view ESIKF are the closest
   existing analogues to what a cooperative LIV node would need when
   different cameras / nodes observe non-overlapping regions of a shared
   LiDAR-colored map. **SA-LIVO** is the principled degeneracy-handling
   entry: rather than gating modalities wholesale, it eigendecomposes
   the joint LiDAR-visual information matrix and gates per-eigendirection,
   so visual residuals are steered into exactly the pose directions
   LiDAR under-constrains. The single-loop InEKF with once-assembled
   reused photom
etric Jacobians is an efficiency pattern directly
relevant to embedded cooperative-node deployment. Together they frame
the LIVO design space Gaussian-LIC2 sits in: multi-camera coverage
(Omni-LIVO) + direction-selective robust fusion (SA-LIVO).

2. **FIRE-LIVWO** extends the degeneracy-handling thread to the most
   extreme multi-modal setting yet surveyed (LiDAR + camera + IMU + 4D
   mmWave radar + wheel), with an observability-grounded adaptive
   fusion-switching strategy. It is the reference for what LIVO-style
   tight coupling looks like under combined visual + geometric failure
   (smoke/dust + long corridors), and is the natural contrast to
   SA-LIVO's direction-selective approach: FIRE-LIVWO switches
   modalities, SA-LIVO switches directions within the fused update.

3. **StreamRig** adds a learned-multi-camera-odometry reference. It is
   not a LIVO system and builds no Gaussian map, but it is the current
   state of the art for streaming rig-aware visual odometry and its
   freeze-and-stream transfer recipe (frozen 3D foundation model +
   compact trained pose back-end) is a relevant pattern for any future
   learned-frontend integration into a LIV GS-SLAM.

### Reproducing the Addendum 27 survey

Searches were run via `mcp__doubao-search__web_search` on 2026-10-03
with `OneWeek` and `OneMonth` time-range filters:

1. `3DGS SLAM LiDAR visual inertial 2026 arxiv` (OneWeek, 6 results)
   — re-confirmed Structured-Li-GS (A18), Pi3MOS-SLAM (in bib), RRG-SLAM
   (A24); surfaced an LIO-SLAM indoor-improvement paper (Sun Yat-sen
   Univ. J., 2026) excluded as a non-Gaussian LIO/VIO engineering paper.
2. `Gaussian Splatting SLAM real-time mapping tracking 2026` (OneWeek,
   5 results) — re-confirmed MonoGS (CVPR 2024, in bib), RRG-SLAM (A24);
   surfaced Gassidy (dynamic-env 3DGS-SLAM, blog repost, not separately
   added) and a medical-lab digital-twin 3DGS application (excluded as
   non-SLAM application).
3. `3D Gaussian Splatting SLAM arxiv 2609 2610 new method` (OneWeek,
   12 results) — re-confirmed RRG-SLAM (A24), CoRef-GS (A23),
   DroneSplat+ (excluded), MCGS-SLAM (in bib); surfaced AESplat
   (arXiv:2609.36693, feed-forward pose-free 3DGS, non-SLAM, excluded),
   NRF-GS (arXiv:2609.37115, neural residual appearance field for 3DGS,
   non-SLAM, excluded), a Prior-Driven Normals/Depths-Regularization
   3DGS paper (arXiv:2609.36969, SfM-prior 3DGS, non-SLAM, excluded).
4. `collaborative multi-agent Gaussian Splatting mapping fusion 2026
   arxiv` (OneMonth, 14 results) — re-confirmed CoRef-GS (A23),
   MCGS-SLAM (in bib), NRF-GS (excluded); no new cooperative entries.
5. `LiDAR inertial visual odometry LIVO SLAM 2026 new` (OneMonth, 20
   results) — re-confirmed FAST-LIVO2 (in bib), Dynamic-LIVO (in bib);
   surfaced **Omni-LIVO** (RA-L Apr 2026, arXiv:2509.15673),
   **SA-LIVO** (arXiv:2606.25699), **FIRE-LIVWO** (arXiv:2609.05325),
   and **StreamRig** (arXiv:2609.40244) as new LIVO / multi-camera
   odometry entries not yet in the inventory; also surfaced a LiLi Lie-
   theory degeneracy-detection paper (arXiv:2609.17145, LIO degeneracy
   detector only, excluded as not a full LIVO system).
6. `Omni-LIVO multi-camera visual inertial LiDAR odometry arxiv 2026`
   (OneMonth, 12 results) — confirmed Omni-LIVO arXiv ID 2509.15673,
   RA-L vol.11 no.4 pp.4369–4376, DOI 10.1109/LRA.2026.3662590, and the
   Omni-Bot deployment paper (UPINLBS Dec 2025, excluded as the
   application paper, Omni-LIVO itself added).
7. `SA-LIVO Subspace-Aware degeneracy arxiv 2606` (OneMonth, 10 results)
   — confirmed SA-LIVO arXiv:2606.25699 (v1 24 Jun 2026, v2 6 Aug 2026);
   also surfaced FAST-LIVGO (arXiv:2606.19190, LIVO+GNSS degeneracy-
   robust odometry) as a related but already-lineage-covered entry
   (excluded to keep the degeneracy-handling set focused on SA-LIVO +
   FIRE-LIVWO).

### Inventory

After Addendum 27 the survey holds **117 BibTeX entries** in
`bib/references.bib` and **108 PDFs** in `papers/`. The 24-h code review
recorded no new commits and no source-tree changes (uncommitted
Addendum 26 working-tree edits only). RMGS-SLAM (arXiv:2604.12942)
remains the closest contemporary LiDAR-Inertial-Visual 3DGS SLAM head-
to-head baseline; VIGS-SLAM (A22) the visual-inertial baseline; CoRef-GS
(A23) the cooperative multi-agent visual+semantic baseline; MAGS-SLAM
(A25) the cooperative multi-agent RGB-only baseline; ChronoFuseGS (A24)
the temporal-axis Gaussian-map-fusion counterpart; BayesianGS-SLAM (A26)
joins VarSplat + VBGS-SLAM as the uncertainty-aware GS-SLAM family;
Omni-LIVO (A27) is now the multi-camera LIVO extension in the FAST-LIVO2
lineage; SA-LIVO (A27) the direction-selective degeneracy-handling LIVO
counterpart; FIRE-LIVWO (A27) the most aggressive multi-modal
degeneracy-handling extension (LIVO + mmWave + wheel); StreamRig (A27)
the learned multi-camera streaming-odometry reference.


---

## Addendum 28 (2026-10-04) — three newly surveyed related works

### 24-hour code review

The last 24 hours of git history (since 2026-10-03 ~02:10) contain **no
new commits** — the last commit is still `1bbb9e6` (2026-10-01 21:11,
"fix(mobicom): 修复未定义引用、标题书签警告并恢复数据流程图"). The
working tree carries uncommitted edits to `latex/README.md` and
`latex/bib/references.bib` carried over from Addendum 26/27 (+490 lines
cumulative: BayesianGS-SLAM + CognitiveReality + Omni-LIVO + SA-LIVO +
FIRE-LIVWO + StreamRig entries). No code under `src/`, `include/`,
`launch/`, `config/`, or `CMakeLists.txt` was touched. So the
Gaussian-LIC2 implementation tree is unchanged since Addendum 26; this
round is again purely a literature-refresh pass.

### New papers added this round

Three genuinely new papers not in the inventory were identified and
added. The Doubao search (OneWeek / OneMonth, six calls) surfaced a
late-September / early-October batch on **3DGS view-selection cost
control, illumination-robust 3DGS, and uncertainty-driven adaptive
volumetric mapping** — complementary to the LIVO-family focus of
Addendum 27. Re-appearing candidates already in the bib were ruled out:
PanoGS-SLAM (arXiv:2609.17387, in bib), Dual-Covariance GS-SLAM
(`tan2026dualcovgsslam`, A17, arXiv:2609.25746, in bib), LightSplat
(arXiv:2609.07274, IROS 2026, in bib), SCOUT-SLAM (arXiv:2609.14634, in
bib), EliGSiR (arXiv:2609.20348, in bib), LiTe-GS (`pandey2026litegs`,
A23), RRG-SLAM (A24), CoRef-GS (A23), MAGS-SLAM (A25), Structured-Li-GS
(A18), MCGS-SLAM (in bib), DynActiveGS (A25), MonoGS (CVPR 2024, in
bib). Newly excluded: a Luminance-vs-Chroma 3DGS geometry-formation
study (arXiv:2610.00749, non-SLAM 3DGS analysis), Prior-Driven Normals/
Depths-Regularization 3DGS (arXiv:2609.36969, SfM-prior 3DGS, non-SLAM),
EffGS (arXiv:2609.39553, 3DGS acceleration/density-control, non-SLAM),
GS-PQM (arXiv:2610.00195, compressed-GS quality metric, non-SLAM).

| Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---|---|---|---|---|
| **AGILE-GS** (`khass2026agilegs`, arXiv:2609.34176 v1 28 Sep 2026) | arXiv (cs.CV) | Active 3DGS (RGB, simulator) | **Anchor-guided fast Next-Best-View (NBV) selection for active 3DGS.** Decouples "where is the most informative viewpoint in SE(3)" from "which candidate in the pool best reproduces it". A virtual **anchor pose** is optimized on SE(3) by Riemannian gradient ascent on expected information gain (Fisher information) — it need not be reachable or in the pool; it marks where the model is most uncertain. Each candidate then receives an **anchor leverage score** measuring how well it reproduces the anchor's viewing geometry, and a **greedy ridge-leverage subset-selection** step distills the pool into a small, non-redundant shortlist **without rendering any candidate**. AGILE-GS takes the leading shortlist view directly (zero Fisher evaluations on candidates); AGILE-GS+ reranks the shortlist by Fisher information gain (a handful of evaluations). Matches/exceeds FisherRF / POp-GS / COVER reconstruction accuracy at **1–2 orders of magnitude lower selection latency**; validated in closed-loop embodied acquisition on a simulated manipulator. | **View-selection / cost-control thread — peripheral but relevant.** Same Lehigh group as LiTe-GS (A23) and shares the ε/ridge-leverage efficiency framing. Peripheral to the LIV GS-SLAM core (RGB active 3DGS, no LiDAR/inertial/SLAM loop) but directly relevant to **keyframe / active-view-selection cost control** in a streaming LIV GS-SLAM: the anchor-guided decoupling (continuous SE(3) information optimum → discrete pool shortlist, no per-candidate rendering) is a transferable pattern for choosing which candidate frame/keyframe to optimize next under bounded compute, complementing LiTe-GS's randomized-subset oracle-complexity bound. Cite alongside LiTe-GS in the view-selection / compute-budget discussion. |
| **EvenSplat** (`wu2026evensplat`, arXiv:2610.01876 v1 1 Oct 2026) | arXiv (cs.CV) | RGB (multi-view 3DGS) | **Coupled 2D–3D illumination decomposition for 3DGS under exposure and illumination variation.** Standard 3DGS entangles capture-specific illumination with the geometry/color it recovers — a surface under uneven light looks different from different angles. EvenSplat couples an **image-space illumination decomposition** with an **illumination field carried by the Gaussians**, so the same explanation of the lighting is shared between the 2D and 3D views of the scene; a **camera-response network** absorbs global cross-view exposure differences and a **local exposure-compensation module** absorbs residual spatial illumination variation within a single image. Outperforms SOTA 3DGS methods across cross-view exposure, spatial illumination variation, and high-contrast lighting on real + simulated benchmarks, particularly under high-contrast illumination. | **Appearance-robustness thread — peripheral but relevant.** Not a SLAM system (offline 3DGS, no LiDAR/inertial/pose estimation), but directly addresses the **photometric-inconsistency-under-varying-illumination** problem that corrupts direct/photometric tracking in LIVO and GS-SLAM when exposure changes between views or lighting varies within a frame. The coupled 2D–3D illumination field + camera-response network is a transferable pattern for robustifying the visual residual term in a LIV GS-SLAM operating under auto-exposure / HDR / outdoor lighting changes — complementary to RRG-SLAM's (A24) reflection handling and to DynActiveGS's (A25) structural-vs-motion uncertainty split. Cite in the appearance-modeling / robust-tracking discussion. |
| **UnRL** (`ozkan2026unrl`, arXiv:2610.00188 v1 17 Sep 2026; BMVC 2026) | BMVC 2026 | RGB-D (TSDF volumetric mapping) | **Uncertainty-Aware RL-Controlled Adaptive 3D Mapping.** Replaces fixed-resolution TSDF voxel grids with a **multi-resolution TSDF** whose subdivision is driven by **semantic entropy** (label-uncertainty, class-agnostic, no semantic-taxonomy dependence) plus **geometric curvature** and **texture richness** as scene-complexity cues. A **reinforcement-learning agent (PPO)** then learns voxel-subdivision policies under a **user-specified target memory budget** — replacing hand-tuned thresholds with a single intuitive control parameter (a physical memory amount in MB). The RL agent observes local + global voxel statistics and trades reconstruction accuracy against storage cost. Outperforms MAP-ADAPT and fixed-resolution baselines on synthetic + real-world datasets in geometric accuracy, semantic consistency, and memory–accuracy trade-off. Code + models released. | **Memory-budget / adaptive-mapping thread — peripheral but relevant.** Not a GS-SLAM (TSDF volumetric, RGB-D), but directly addresses the **bounded-memory adaptive-mapping** problem that any long-running or cooperative LIV GS-SLAM must solve — how to allocate finite Gaussian/voxel budget to where it matters most. The semantic-entropy + curvature + texture complexity cues and the **RL-under-memory-budget** formulation are transferable to adaptive Gaussian densification / pruning under a memory cap in a cooperative setting (per-node memory budget → per-node subdivision policy). Cite alongside BayesianGS-SLAM (A26) and the uncertainty-aware family in the mapping-budget / adaptive-resolution discussion. |

### Why these matter

1. **AGILE-GS** closes out the **view-selection / cost-control** thread
   opened by LiTe-GS (A23). Where LiTe-GS bounds the *number* of Fisher
   oracle evaluations via randomized subset selection (O(M log(1/ε)),
   independent of cardinality K), AGILE-GS decouples *where the
   informative viewpoint is* (continuous SE(3) anchor, no rendering)
   from *which candidate approximates it* (anchor leverage score +
   ridge-leverage subset selection, no per-candidate rendering). The
   two are complementary: LiTe-GS is the oracle-efficient evaluator,
   AGILE-GS is the rendering-free shortlister; together they frame the
   NBV-cost-control design space for a streaming GS-SLAM's keyframe /
   active-view decision under bounded compute.

2. **EvenSplat** adds the **illumination-robustness** angle that the
   survey's appearance-modeling thread (RRG-SLAM reflections A24,
   DynActiveGS dynamic-uncertainty A25) was missing. Photometric
   inconsistency under auto-exposure / HDR / spatial illumination
   variation is a primary corruption source for the direct visual
   residual in LIVO and GS-SLAM; the coupled 2D–3D illumination field +
   camera-response network is a principled decomposition that could
   robustify the visual term in a LIV GS-SLAM without abandoning
   differentiable rendering.

3. **UnRL** brings a **bounded-memory adaptive-mapping** formulation
   the survey had not previously covered. The semantic-entropy +
   curvature + texture complexity cues are class-agnostic and
   transferable to Gaussian densification/pruning decisions, and the
   RL-under-memory-budget formulation is a principled replacement for
   hand-tuned densification thresholds — directly relevant to
   cooperative LIV GS-SLAM where each node has a finite and possibly
   heterogeneous memory budget. It joins BayesianGS-SLAM (A26) in the
   uncertainty/budget-aware mapping discussion, with the two being
   complementary: BayesianGS-SLAM quantifies *where* map uncertainty
   comes from, UnRL controls *how much* memory to spend reducing it.

### Reproducing the Addendum 28 survey

Searches were run via `mcp__doubao-search__web_search` on 2026-10-04
with `OneWeek` and `OneMonth` time-range filters:

1. `3DGS SLAM LiDAR inertial visual Gaussian 2026` (OneWeek, 4 results)
   — re-confirmed Structured-Li-GS (A18), LiV-GS (RA-L 2025, in bib),
   SEGS-SLAM (ICCV 2025, in bib).
2. `Gaussian splatting SLAM cooperative multi-agent map fusion arXiv`
   (OneMonth, 12 results) — re-confirmed CoRef-GS (A23), HAMMER (LRA
   2025, excluded earlier), MNE-SLAM (CVPR 2025, in bib); surfaced no
   new cooperative-GS entries since A23/A25.
3. `LIVO LiDAR visual inertial odometry FAST-LIVO arXiv October 2026`
   (OneWeek, 6 results) — re-confirmed FAST-LIVO2 source-reading blog
   posts; no new LIVO arXiv since A27's Omni-LIVO / SA-LIVO / FIRE-LIVWO.
4. `Gaussian Splatting SLAM real-time dynamic scene tracking arXiv 2026`
   (OneMonth, 19 results) — re-confirmed Dual-Covariance GS-SLAM (A17,
   in bib), MonoGS (in bib), DynActiveGS (A25); newly surfaced AGILE-GS
   (arXiv:2609.34176, added) and EffGS (arXiv:2609.39553, non-SLAM 3DGS
   acceleration, excluded).
5. `arXiv 2610 Gaussian splatting SLAM novel October 2026` (OneWeek, 9
   results) — newly surfaced EvenSplat (arXiv:2610.01876, added), a
   Luminance-vs-Chroma 3DGS geometry-formation study
   (arXiv:2610.00749, non-SLAM analysis, excluded), GS-PQM
   (arXiv:2610.00195, compressed-GS quality metric, excluded),
   UnRL/Uncertainty-Aware RL-Controlled Adaptive 3D Mapping
   (arXiv:2610.00188, BMVC 2026, added); re-confirmed RRG-SLAM (A24),
   CollisionSplatting (A24).
6. `visual inertial odometry Gaussian splatting online mapping arXiv
   September October 2026` (OneMonth, 19 results) — re-confirmed
   PanoGS-SLAM (arXiv:2609.17387, in bib), LightSplat (IROS 2026, in
   bib), SCOUT-SLAM (arXiv:2609.14634, in bib), EliGSiR
   (arXiv:2609.20348, in bib), VIGS-SLAM (ECCV 2026, A22), Prior-Driven
   Normals/Depths-Regularization 3DGS (arXiv:2609.36969, non-SLAM,
   excluded); no new LIV GS-SLAM head-to-head baseline surfaced.

### Inventory

After Addendum 28 the survey holds **120 BibTeX entries** in
`bib/references.bib` and **111 PDFs** in `papers/`. The 24-h code review
recorded no new commits and no source-tree changes (uncommitted
Addendum 26/27 working-tree edits only, now augmented by the A28
addendum). RMGS-SLAM (arXiv:2604.12942) remains the closest contemporary
LiDAR-Inertial-Visual 3DGS SLAM head-to-head baseline; VIGS-SLAM (A22)
the visual-inertial baseline; CoRef-GS (A23) the cooperative multi-
agent visual+semantic baseline; MAGS-SLAM (A25) the cooperative
multi-agent RGB-only baseline; ChronoFuseGS (A24) the temporal-axis
Gaussian-map-fusion counterpart; BayesianGS-SLAM (A26) joins VarSplat +
VBGS-SLAM as the uncertainty-aware GS-SLAM family; Omni-LIVO (A27) the
multi-camera LIVO extension in the FAST-LIVO2 lineage; SA-LIVO (A27)
the direction-selective degeneracy-handling LIVO counterpart;
FIRE-LIVWO (A27) the most aggressive multi-modal degeneracy-handling
extension (LIVO + mmWave + wheel); StreamRig (A27) the learned
multi-camera streaming-odometry reference; AGILE-GS (A28) now joins
LiTe-GS (A23) in the view-selection / cost-control thread; EvenSplat
(A28) the illumination-robust 3DGS counterpart in the appearance-
modeling thread; UnRL (A28) the bounded-memory adaptive-mapping
counterpart in the mapping-budget discussion.

---

## Addendum 29 (2026-10-05) — four newly surveyed related works

### 24-hour code review

The last 24 hours of git history (since 2026-10-04 ~02:10) contain **no
new commits** — the last commit is still `1bbb9e6` (2026-10-01 21:11,
"fix(mobicom): 修复未定义引用、标题书签警告并恢复数据流程图"). The
working tree carries uncommitted edits to `latex/README.md` and
`latex/bib/references.bib` accumulated across Addenda 26/27/28 (+962
lines cumulative: BayesianGS-SLAM + CognitiveReality + Omni-LIVO +
SA-LIVO + FIRE-LIVWO + StreamRig + AGILE-GS + EvenSplat + UnRL). No
code under `src/`, `include/`, `launch/`, `config/`, or `CMakeLists.txt`
was touched. So the Gaussian-LIC2 implementation tree is unchanged
since Addendum 26; this round is again purely a literature-refresh
pass.

### New papers added this round

Four genuinely new papers not in the inventory were identified and
added. The Doubao search (OneWeek / OneMonth, four calls) surfaced a
batch spanning **LiDAR + 3D-vision-foundation-model fusion**, **2D-
Gaussian visual-LiDAR odometry**, **LIVO-driven sparse-scan Gaussian
densification**, and a **multi-agent neural-submap + 3DGS** SLAM.
Re-appearing candidates already in the bib were ruled out:
Structured-Li-GS (A18, in bib), LiV-GS (RA-L 2025, in bib), MAGS-SLAM
(A25, in bib), CoRef-GS (A23), MAGiC-SLAM (CVPR 2025, in bib),
GRAND-SLAM (LRA 2025, in bib), SplaTAM (in bib), MonoGS (CVPR 2024, in
bib), VGGT-GS SLAM (`han2026vggtgsslam`, in bib), CGS-SLAM
(`deambrogi2026cgsslam`, in bib). Newly excluded: D3GS (arXiv:2609.22941,
sparse-view diffusion-guided 3DGS, non-SLAM), GSFix3D (3DV 2026, 3DGS
novel-view repair, non-SLAM), Filling-the-Unseen / QA-Mask (ACM MM 2026,
3DGS scene extrapolation, non-SLAM), LiDAR-GS++ (arXiv:2511.12304, LiDAR
NVS re-simulation, non-SLAM), Splat-LOAM (arXiv:2503.17491, pure-LiDAR
2DGS odometry, already excluded in earlier rounds as off-thread),
SceneVGGT (ICIP 2026, VGGT-based semantic SLAM, off-thread VGGT
extension), VGGT-DynMap (ICCA 2026, RGB-D VGGT dense mapping, no
LiDAR/inertial), LEMON-Mapping (TASE 2026, multi-session point-cloud
merging, no Gaussian/SLAM), CoMA-SLAM (AAAI 2026, in bib), DUAG-C
(ISPRS J 2026, decentralized Gaussian consensus, no preprint and
RGB-D-only, deferred), DGOMapping (Sensors 2026, 4DGS multi-agent, no
preprint and dynamic-only, deferred).

| Paper | Venue / date | Sensor | Key idea | Relation to Gaussian-LIC2 |
|---|---|---|---|---|
| **LiDAR-VGGT** (`wang2026lidarvggt`, arXiv:2511.01186 v1 3 Nov 2025; IEEE RA-L 11(4):4721–4728, Apr 2026) | arXiv → IEEE RA-L | LiDAR-IMU + RGB (LIVO setup) | **Cross-modal coarse-to-fine fusion of LiDAR-Inertial odometry with the VGGT 3D-vision foundation model for globally consistent, metric-scale dense colored mapping.** VGGT is a feed-forward transformer that infers camera poses + dense point clouds from a stack of images in one forward pass, but it lacks metric scale and degrades on long trajectories; LIVO is metric and globally consistent but sparse and exquisitely sensitive to extrinsic calibration. LiDAR-VGGT couples them in two stages: (1) **pre-fusion** — LIO poses seed VGGT per session, scale-RANSAC + a linearity-validation/rotation-correction step recovers a coarse metric scale for the VGGT point cloud even when camera motion is near-linear (a known VGGT degeneracy); (2) **post-fusion** — an enhanced cross-modal Sim(3) registration aligns the VGGT-colored clouds to the LiDAR map with a bounding-box regularization that suppresses the scale distortion induced by LiDAR-vs-camera FOV mismatch, followed by global pose-graph optimization. Outperforms both VGGT-based methods and LIVO baselines (FAST-LIVO2) on density + global consistency + color fidelity across MARS-LVIG, MUN-FRL, and a self-collected TechnologyPark dataset; robust even under inaccurate extrinsics / time sync. Releases a new colored-point-cloud evaluation toolkit (CD/CF/LCR/CCS). | **LIVO-lineage dense-mapping thread — directly relevant.** This is the first work to fuse a frozen 3D-vision foundation model (VGGT) into the LIVO loop, and it does so to fix the long-standing sparsity + extrinsic-sensitivity pain point of LIVO that the present survey's FAST-LIVO2-lineage thread (Omni-LIVO A27 multi-camera, SA-LIVO A27 degeneracy, FIRE-LIVWO A27 multi-modal) has been circling. The coarse-to-fine cross-modal Sim(3) + bbox-regularization pattern and the linearity-validation scale-recovery are transferable to a cooperative LIV GS-SLAM where per-node VGGT-style dense color could fill the gaps between sparse LiDAR-colored Gaussians. Also the natural reference for any "use a 3D foundation model to densify the LIV map" baseline. PDF saved as `Wang2026_LiDARVGGT.pdf`. |
| **G²VLO** (`tu2026g2vlo`, IEEE RA-L 11(6):6911–6918, Jun 2026; no arXiv preprint as of 2026-10-05) | IEEE RA-L | Camera + LiDAR (no IMU) | **Accurate and generic 2D-Gaussian-based visual-LiDAR odometry.** Builds the odometry map as a set of 2D Gaussian surfels (the surface-oriented variant of 3DGS) and registers each new LiDAR scan + camera frame against the 2D-Gaussian map directly — the Gaussian map is both the rendering primitive and the registration target, in the spirit of LiV-GS (RA-L 2025, in bib) but using 2D rather than 3D Gaussians for better surface fidelity. Reported to outperform SOTA visual-LiDAR odometry on benchmark datasets. | **Visual-LiDAR odometry thread — directly relevant.** A 2D-Gaussian counterpart to LiV-GS (RA-L 2025, in bib): both register LiDAR against a Gaussian map, but G²VLO uses 2D surfels (orientation-explicit, surface-faithful) where LiV-GS uses 3D Gaussians. For a LIV GS-SLAM the choice of 2D vs 3D Gaussians is a live design decision (cf. PINGS, GS-ICP-SLAM, RMGS-SLAM); G²VLO is a clean data point on the 2D-Gaussian side of the visual-LiDAR odometry space and a head-to-head candidate for the LiDAR-visual tracking formulation. IEEE-only entry; no PDF saved (no arXiv preprint). |
| **FillFusion-GS** (`sun2026fillfusiongs`, IEEE RA-L 11(7):8688–8695, Jul 2026; no arXiv preprint as of 2026-10-05) | IEEE RA-L | LiDAR + camera (LIVO-driven 3DGS) | **From sparse scans to dense scenes via visual-structure-guided 3D Gaussian splatting.** Uses a LIVO trajectory (cf. the present project's LIVO heritage) to align a sequence of sparse LiDAR scans + camera frames, then fills the gaps the sparse LiDAR leaves in the 3DGS map using **visual-structure guidance** — image-derived depth/normal cues steer Gaussian densification into LiDAR-unobserved regions so the final Gaussian map is dense and photo-consistent rather than sparse and hole-ridden. Targets the well-known failure mode of LiDAR-initialized 3DGS (sparse coverage → holes between scan lines) without abandoning the metric scale LiDAR provides. | **LIVO + 3DGS densification thread — directly relevant.** Addresses the sparsity problem that LiDAR-VGGT (above) tackles with a foundation model, but with a classical visual-structure-guidance approach instead — a useful contrast pair. Directly relevant to Gaussian-LIC2 because the project's LIVO backend produces exactly the sparse-LiDAR + camera-pose stream FillFusion-GS consumes; the visual-structure-guided densification is a candidate post-processing / online-densification stage on top of the LIV GS map. IEEE-only entry; no PDF saved (no arXiv preprint). |
| **MANG-SLAM** (`li2026mangslam`, IEEE RA-L 11(2):2242–2249, Feb 2026; no arXiv preprint as of 2026-10-05) | IEEE RA-L | RGB-D (multi-agent) | **Multi-Agent Neural Submap + 3DGS for dense mapping.** Each agent independently builds **neural submaps** that guide 3DGS rendering; a server fuses the per-agent submaps (submap integration + loop-closure detection + global optimization) to correct accumulated drift, improve geometric consistency, and fill scene gaps. Targets the global-drift / loop-closure / gap-filling weaknesses of multi-agent 3DGS-SLAM (cf. MAGiC-SLAM CVPR 2025 in bib, CoMA-SLAM AAAI 2026 in bib, MAGS-SLAM A25, GRAND-SLAM LRA 2025 in bib). Validated on Replica + ScanNet, showing improved global consistency + local-detail recovery. | **Cooperative multi-agent GS-SLAM thread — directly relevant.** Joins the cooperative-multi-agent cluster (CoRef-GS A23, MAGS-SLAM A25, MAGiC-SLAM in bib, CoMA-SLAM in bib, GRAND-SLAM in bib) as another architectural data point: per-agent neural submaps + server-side submap fusion + loop closure + global optimization. The neural-submap-guides-Gaussian-rendering coupling and the server-side gap-filling are the closest analogues to the cooperative LIV GS-SLAM's per-node submap-merge design among RGB-D multi-agent works. Cite in the cooperative-multi-agent discussion alongside MAGS-SLAM and CoRef-GS. IEEE-only entry; no PDF saved (no arXiv preprint). |

### Why these matter

1. **LiDAR-VGGT** is the first work to fuse a frozen 3D-vision foundation
   model into the LIVO loop, and it directly attacks the sparsity +
   extrinsic-sensitivity pain point that the FAST-LIVO2-lineage thread
   (Omni-LIVO, SA-LIVO, FIRE-LIVWO — all A27) has been circling. The
   coarse-to-fine cross-modal Sim(3) + bbox-regularization +
   linearity-validation scale-recovery pattern is transferable to
   cooperative LIV GS-SLAM where per-node dense color from a foundation
   model could fill the gaps between sparse LiDAR-colored Gaussians. It
   is also the natural "use a 3D foundation model to densify the LIV
   map" baseline the survey was missing.

2. **G²VLO** and **FillFusion-GS** are two complementary LIVO-thread
   data points the survey had not previously captured. G²VLO is the
   2D-Gaussian counterpart to LiV-GS (RA-L 2025, in bib) on the
   visual-LiDAR odometry side — a clean design-decision data point for
   2D vs 3D Gaussians in the LIV tracking formulation. FillFusion-GS
   attacks the same sparse-LiDAR coverage problem as LiDAR-VGGT but
   with classical visual-structure guidance rather than a foundation
   model, giving a contrast pair on the densification axis. Both are
   directly on-thread for a LIVO-driven LIV GS-SLAM.

3. **MANG-SLAM** extends the cooperative-multi-agent GS-SLAM cluster
   (CoRef-GS A23, MAGS-SLAM A25, MAGiC-SLAM / CoMA-SLAM / GRAND-SLAM in
   bib) with a per-agent neural-submap + server-side fusion + loop-
   closure architecture — the closest analogue to the cooperative LIV
   GS-SLAM's per-node submap-merge design among RGB-D multi-agent
   works, and a useful citation in the cooperative-multi-agent
   discussion.

### Reproducing the Addendum 29 survey

Searches were run via `mcp__doubao-search__web_search` on 2026-10-05
with `OneWeek` and `OneMonth` time-range filters:

1. `3DGS SLAM LiDAR inertial visual 2026 arxiv` (OneWeek, 3 results) —
   re-confirmed Structured-Li-GS (A18), LiV-GS (RA-L 2025, in bib),
   and a CVPR'26 Bonn dynamic-visual-SLAM post (off-thread); surfaced
   LiDAR-VGGT (RA-L Apr 2026, added) via the FAST-LIVO citation list.
2. `Gaussian Splatting SLAM cooperative multi-agent map fusion 2026`
   (OneWeek, 5 results) — re-confirmed MAGS-SLAM (A25, in bib),
   SplaTAM (in bib); newly surfaced MANG-SLAM (RA-L Feb 2026, added);
   re-confirmed SplaTAM, MAGiC-SLAM (in bib).
3. `LIVO LiDAR-Visual-Inertial Odometry Gaussian splatting 2026 arxiv`
   (OneWeek, 5 results) — re-confirmed Structured-Li-GS (A18),
   FAST-LIVO citation list (surfacing LiDAR-VGGT, G²VLO, FillFusion-GS,
   SC-FAST-LIVO2, FAST-LIEO2); newly added G²VLO (RA-L Jun 2026,
   IEEE-only) and FillFusion-GS (RA-L Jul 2026, IEEE-only);
   SC-FAST-LIVO2 / FAST-LIEO2 deferred as conference/loop-closure
   papers without preprints.
4. `FillFusion-GS / LiDAR-VGGT / G2VLO / MANG-SLAM arxiv preprint`
   (follow-up OneMonth + arXiv API checks) — confirmed LiDAR-VGGT has
   arXiv:2511.01186 (PDF saved as `Wang2026_LiDARVGGT.pdf`); confirmed
   G²VLO, FillFusion-GS, MANG-SLAM have **no arXiv preprint** as of
   2026-10-05 (IEEE RA-L journal-only), so they are recorded as
   DOI-only BibTeX entries without local PDFs.

### Inventory

After Addendum 29 the survey holds **124 BibTeX entries** in
`bib/references.bib` and **112 PDFs** in `papers/`. The 24-h code review
recorded no new commits and no source-tree changes (uncommitted
Addendum 26/27/28 working-tree edits only, now augmented by the A29
addendum). RMGS-SLAM (arXiv:2604.12942) remains the closest contemporary
LiDAR-Inertial-Visual 3DGS SLAM head-to-head baseline; VIGS-SLAM (A22)
the visual-inertial baseline; CoRef-GS (A23) the cooperative multi-
agent visual+semantic baseline; MAGS-SLAM (A25) the cooperative
multi-agent RGB-only baseline; ChronoFuseGS (A24) the temporal-axis
Gaussian-map-fusion counterpart; BayesianGS-SLAM (A26) joins VarSplat +
VBGS-SLAM as the uncertainty-aware GS-SLAM family; Omni-LIVO (A27) the
multi-camera LIVO extension in the FAST-LIVO2 lineage; SA-LIVO (A27)
the direction-selective degeneracy-handling LIVO counterpart;
FIRE-LIVWO (A27) the most aggressive multi-modal degeneracy-handling
extension (LIVO + mmWave + wheel); StreamRig (A27) the learned
multi-camera streaming-odometry reference; AGILE-GS (A28) joins
LiTe-GS (A23) in the view-selection / cost-control thread; EvenSplat
(A28) the illumination-robust 3DGS counterpart in the appearance-
modeling thread; UnRL (A28) the bounded-memory adaptive-mapping
counterpart in the mapping-budget discussion; **LiDAR-VGGT (A29) now
the foundation-model-augmented LIVO dense-mapping reference in the
FAST-LIVO2 lineage**; **G²VLO (A29) the 2D-Gaussian visual-LiDAR
odometry counterpart alongside LiV-GS (RA-L 2025)**; **FillFusion-GS
(A29) the LIVO-driven sparse-scan Gaussian-densification counterpart
alongside LiDAR-VGGT (foundation-model densification) and
ChronoFuseGS (temporal-axis fusion)**; **MANG-SLAM (A29) joins the
cooperative multi-agent GS-SLAM cluster alongside CoRef-GS (A23),
MAGS-SLAM (A25), MAGiC-SLAM / CoMA-SLAM / GRAND-SLAM (in bib)**.

---

## Addendum 30 (2026-10-08) — six newly surveyed related works

**Date of this addendum:** 2026-10-08. **24-hour code review window:**
the only commit in the past 24 h is `550215f` (2026-10-08 01:48, "docs
(latex): 新增两篇不确定性感知SLAM文献并更新综述日期"), a docs-only
commit (+873/−2 under `latex/README.md` and `latex/bib/references.bib`)
that finalized the Addendum 26 entries (BayesianGS-SLAM +
CognitiveReality) and bumped the survey "re-checked" date to 2026-10-05.
**No source-tree (C++/Python/build) changes occurred** — the working tree
is clean as of this round. Doubao web search was available; this round
ran eight OneWeek/OneMonth web-search calls across 3DGS-SLAM, LIVO,
multi-agent, dynamic-scene, and large-scale-3DGS keywords.

### Newly surveyed papers

| # | Paper | Venue / Date | Sensors / Modality | Key idea | Relation to Gaussian-LIC2 |
|---|-------|--------------|---------------------|----------|---------------------------|
| 1 | **Voxel-LIVO** `zhang2026voxellivo` | IEEE TIM 75, 28 Jan 2026 (DOI 10.1109/TIM.2026.3657488); **no arXiv** | LiDAR-Inertial-Visual (LIVO) | Unified adaptive voxel map supporting short-/mid-/long-term data association; IESKF fusion; LiDAR-map-assisted visual patch association (LM-VPA) uses LiDAR planar features for image-patch affine transforms; sequential LiDAR-visual local BA for mid-term association; hybrid keyframe-sparse + sliding-window-dense voxel map for memory-bounded long-term operation; strong under LiDAR/visual degeneracy | Direct FAST-LIVO2-lineage LIVO relative — the multi-timescale voxel-map + LM-VPA patch-warping pattern is a degeneracy-robust counterpart to SA-LIVO (A27) direction-selective and FIRE-LIVWO (A27) modality-switching; LM-VPA (LiDAR-plane-driven image-patch affine) is a candidate lightweight photometric-alignment augmentation for the LIV GS-SLAM tracking loop |
| 2 | **DC-LIVO** (dual-confidence) `li2026dclivo` | Meas. Sci. Technol. 37(28):286306, Jul 2026 (DOI 10.1088/0957-0233/37/28/286306); **no arXiv** | LiDAR-Inertial-Visual (LIVO) | Tightly-coupled ESKF LIVO with explicit **dual-confidence** fusion + degradation awareness: LiDAR confidence from point-to-plane residual distribution, visual confidence from feature-correspondence quality under the measurement update; adaptively down-weights the degraded modality | FAST-LIVO2-lineage degeneracy-handling LIVO counterpart — complements SA-LIVO (A27, eigendirection gating) and FIRE-LIVWO (A27, modality switching) with a residual-distribution + correspondence-quality dual-confidence signal; the confidence-from-residual-distribution estimator transfers to LIV GS-SLAM as a per-residual weighting prior |
| 3 | **HPGS-SLAM** `su2026hpgsslam` | IEEE RA-L 11(2):1882–1889, Feb 2026 (DOI 10.1109/LRA.2026.3700944); **no arXiv** | RGB-D (visual SLAM) | Hybrid point-guided dense visual SLAM: ORB-style sparse point tracking supplies accurate pose + 3D landmarks, then online 3DGS dense mapping with photorealistic reconstruction; evaluated on Replica / TUM-RGBD | Peripheral (RGB-D, no LiDAR/inertial) but joins the hybrid-tracking + GS-mapping family (cf. Photo-SLAM, GS-ICP SLAM in bib) — the sparse-point-guided GS-initialization + online-mapping pattern is a lightweight tracking alternative for LIV GS-SLAM when a feature frontend is available |
| 4 | **DynaGSLAM** `li2026dynagslam` | WACV 2026, pp. 2434–2444 (DOI 10.1109/WACV57702.2026.00247); **no arXiv** | RGB-D, dynamic scenes | First real-time GS-SLAM achieving online GS rendering + tracking + **motion prediction of moving objects** in dynamic scenes while jointly estimating ego motion; explicitly models dynamic object trajectories instead of just filtering them | Dynamic-scene GS-SLAM counterpart — complements the dynamic-filtering approaches (DG-SLAM, GARAD-SLAM, WildGS-SLAM in bib; DynActiveGS A25 uncertainty decomposition) by *predicting* moving-object motion rather than discarding it; the joint ego-motion + dynamic-object trajectory estimation pattern is relevant to LIV GS-SLAM in populated environments where LiDAR sees dynamic objects strongly |
| 5 | **LoCoSplat** `wang2026locosplat` | arXiv:2610.04351, 3 Oct 2026 (under review); **PDF saved** `Wang2026_LoCoSplat.pdf` | RGB feed-forward 3DGS | Real-time feed-forward 3DGS with minimal 3D reasoning: exploits that a Gaussian is a *local* primitive — once depth is predicted, scale/rotation/opacity depend only on the local point-cloud neighborhood, so a 0.14M-param pointwise MLP + fixed local average replaces heavy learned 3D networks; whole encoder runs as one fp16 CUDA graph; 33 ms / 6-view scene, 4.2× faster + 6.7× less memory than prior SOTA | Peripheral (offline feed-forward NVS, not SLAM) but the "Gaussian is local — no global 3D network needed" observation is a recipe for lightweight per-keyframe Gaussian prediction that could feed a streaming LIV GS-SLAM front-end on embedded nodes; relevant to the efficiency/embedded-deployment thread |
| 6 | **Budgeted-GS** `wang2026budgetedgs` | arXiv:2610.03162, 2 Oct 2026 (EG 2027 preprint); **PDF saved** `Wang2026_BudgetedGS.pdf` | RGB 3DGS, large-scale | Post-hoc method turning any trained 3DGS into a factoring tree (multi-resolution moment-matched aggregates); single quality parameter selects per-view LOD fitting target-device memory so one city-scale model serves GPUs of widely different capacity; budget-centered training measures how many primitives a scene needs and trains directly at that size; grounded in a capacity-floor / budget-error law from optimal transport | Peripheral (offline large-scale rendering, not SLAM) but addresses the bounded-memory / large-scale-3DGS-rendering problem directly — the factoring-LOD + budget-error law transfers to memory-bounded cooperative LIV GS-SLAM map serving (per-node memory budget → LOD selection); joins UnRL (A28) in the memory-budget discussion |

### Why these matter

1. **The LIVO family keeps expanding along the degeneracy-robustness
   axis.** Voxel-LIVO (multi-timescale voxel map + LiDAR-assisted visual
   patch warping) and DC-LIVO (dual-confidence residual-distribution
   weighting) are two more points in the FAST-LIVO2-lineage design space
   that SA-LIVO (A27, eigendirection gating) and FIRE-LIVWO (A27,
   modality switching) opened. Together they sketch a spectrum —
   per-eigendirection gating, per-modality switching, per-residual
   confidence, multi-timescale association — from which a robust LIV
   GS-SLAM fusion rule can be assembled.

2. **Dynamic-scene GS-SLAM is splitting into filter vs. predict camps.**
   DynaGSLAM (WACV 2026) is the first real-time GS-SLAM to *predict*
   moving-object motion alongside ego motion, complementing the
   filter-and-discard camp (DG-SLAM, GARAD-SLAM, WildGS-SLAM in bib;
   DynActiveGS A25). For LIV GS-SLAM in populated scenes, LiDAR's strong
   dynamic-object returns make the predict camp attractive.

3. **Feed-forward + budgeted 3DGS are the efficiency frontier.** LoCoSplat
   (33 ms / scene, 0.14M params) and Budgeted-GS (factoring-LOD +
   capacity floor) show two routes to running 3DGS under tight memory:
   make the per-view predictor local-and-tiny, or make the trained model
   adaptively LOD'd. Both are relevant to deploying cooperative LIV
   GS-SLAM on memory-constrained edge nodes.

### Reproducing the Addendum 30 survey

Doubao web search (`web_search`), 2026-10-08, `SearchType=web`,
time-range `OneWeek`/`OneMonth`:

1. `3D Gaussian Splatting SLAM 2026 arxiv LiDAR inertial visual` (OneWeek)
2. `Gaussian Splatting SLAM 2026 multi-agent cooperative map fusion` (OneWeek)
3. `Gaussian Splatting SLAM 2026 arxiv uncertainty dynamic scene outdoor` (OneWeek)
4. `LiDAR visual inertial odometry LIVO 2026 arxiv foundation model` (OneMonth)
5. `3D Gaussian Splatting SLAM real-time 2026 arxiv October keyframe tracking` (OneWeek)
6. `Gaussian Splatting 2026 arxiv large-scale scene reconstruction LiDAR mapping` (OneMonth)
7. `arxiv 2610 Gaussian Splatting SLAM new method October 2026` (OneWeek)
8. `LiDAR inertial visual odometry dual confidence degradation arXiv 2026` (OneMonth)

PDFs downloaded via `curl -sL -o ... https://arxiv.org/pdf/<id>`:
`Wang2026_LoCoSplat.pdf` (arXiv:2610.04351), `Wang2026_BudgetedGS.pdf`
(arXiv:2610.03162). Voxel-LIVO, DC-LIVO, HPGS-SLAM, DynaGSLAM have no
arXiv preprint as of 2026-10-08 and are DOI-only bib entries (no PDF).

### Re-appearing candidates ruled out (already in bib)

SplaTAM (`keetha2024splatam`), PlanarGS (NeurIPS'25, arXiv:2510.23930,
non-SLAM indoor 3DGS, excluded), LiV-GS (`xiao2025livgs`), SEGS-SLAM
(`wen2025segsslam`), MAGS-SLAM (`cao2026magsslam`, A25), PanoGS-SLAM
(`mao2026panogsslam`), Cube-Splat (`guo2026cubesplat`), ArborSplat
(`masini2026arborsplat`), Dual-Covariance GS-SLAM
(`tan2026dualcovgsslam`, A17), LiTe-GS (`pandey2026litegs`, A23),
CoRef-GS (`zhou2026corefgs`, A23), Dynamic-LIVO
(`zhang2026dynamiclivo`), VIGS-SLAM (`zhu2026vigsslam`, A22), DynActiveGS
(`duan2026dynactivegs`, A25), GauS-SLAM (`su2026gauslam`, Gaussian
surfels, distinct from HPGS-SLAM).

Newly excluded as off-thread / non-SLAM: Ex4DGS (arXiv:2410.15629, 4D
dynamic NVS, non-SLAM), Post-Training Semantic Lifting (arXiv:2610.08756,
3DGS semantic label lifting, non-SLAM), SteadySplats (arXiv:2610.05576,
stochastic OIT rendering, non-SLAM), Virtual-memory-3DGS (Computers &
Graphics 2026, large-scene rendering, non-SLAM — related to Budgeted-GS
but purely rendering-side), PlanarGS (NeurIPS'25, indoor 3DGS with
plane priors, non-SLAM), ADE-SLAM (ISCER 2026, dynamic RGB-D GS-SLAM but
workshop, not separately added alongside DynaGSLAM), IO-LIO (IEEE TITS
2026, pure-LIO voxel mapping, off the LIVO thread).

### Inventory after Addendum 30

After Addendum 30 the survey holds **130 BibTeX entries** in
`latex/bib/references.bib` (124 from A29 + 6 new) and **114 PDFs** in
`latex/papers/` (112 from A29 + 2 new arXiv PDFs; the 4 IEEE/conference-
only entries have no PDF). RMGS-SLAM (arXiv:2604.12942) remains the
closest contemporary LiDAR-Inertial-Visual 3DGS SLAM head-to-head
baseline; VIGS-SLAM (A22) the visual-inertial baseline; CoRef-GS (A23)
the cooperative multi-agent visual+semantic baseline; MAGS-SLAM (A25) the
cooperative multi-agent RGB-only baseline; ChronoFuseGS (A24) the
temporal-axis Gaussian-map-fusion counterpart; BayesianGS-SLAM (A26)
joins VarSplat + VBGS-SLAM as the uncertainty-aware GS-SLAM family;
Omni-LIVO (A27) the multi-camera LIVO extension; SA-LIVO (A27) the
direction-selective degeneracy-handling LIVO counterpart; FIRE-LIVWO
(A27) the most aggressive multi-modal degeneracy-handling extension;
StreamRig (A27) the learned multi-camera streaming-odometry reference;
AGILE-GS (A28) joins LiTe-GS (A23) in the view-selection / cost-control
thread; EvenSplat (A28) the illumination-robust 3DGS counterpart; UnRL
(A28) the bounded-memory adaptive-mapping counterpart; LiDAR-VGGT (A29)
the foundation-model-augmented LIVO dense-mapping reference; G²VLO (A29)
the 2D-Gaussian visual-LiDAR odometry counterpart; FillFusion-GS (A29)
the LIVO-driven sparse-scan Gaussian-densification counterpart; MANG-SLAM
(A29) joins the cooperative multi-agent GS-SLAM cluster; **Voxel-LIVO
(A30) the multi-timescale voxel-map + LM-VPA degeneracy-robust LIVO
counterpart**; **DC-LIVO (A30) the dual-confidence degradation-aware LIVO
counterpart**; **HPGS-SLAM (A30) the hybrid point-guided RGB-D GS-SLAM
counterpart in the hybrid-tracking family**; **DynaGSLAM (A30) the
predict-camp dynamic-scene GS-SLAM counterpart (vs. the filter camp:
DG-SLAM / GARAD-SLAM / WildGS-SLAM / DynActiveGS)**; **LoCoSplat (A30)
the local-primitive feed-forward 3DGS efficiency reference**;
**Budgeted-GS (A30) the factoring-LOD + budget-error-law large-scale 3DGS
memory reference**.
