# Multi-Node Cooperative LiDAR-Inertial-Visual Gaussian Splatting SLAM
## System Design Document (v1.0)

**Project:** Co-LIC2 — Cooperative Gaussian-LIC2
**Author:** arthurlirui
**Date:** 2026-09-25
**Status:** Draft for internal review

---

## 0. Document Scope

This document specifies the system model, hardware configuration, software
architecture, communication protocol, and data-sharing mechanism of a
**multi-node cooperative sensing system** in which each node is a moving
platform carrying **multiple cameras, multiple LiDARs, and an IMU**, and the
nodes communicate with each other to share collected data and jointly build a
photo-realistic 3D Gaussian map. It extends the single-platform
Gaussian-LIC2 framework into a distributed, multi-agent setting.

The companion paper draft lives in `latex/paper/` and references this document
for the full module- and interface-level detail.

---

## 1. Motivation & Design Goals

### 1.1 Motivation

Gaussian-LIC2 demonstrates real-time, photo-realistic LiDAR-Inertial-Camera
Gaussian Splatting SLAM on a **single** moving platform. Many real-world
scenarios, however, demand **multiple cooperative platforms**:

- **Large-scale outdoor mapping** (city blocks, construction sites) where one
  platform cannot cover the area in time.
- **Disaster response / search-and-rescue** where a team of UAVs and UGVs must
  rapidly build a shared scene model under occlusion and partial failure.
- **Autonomous fleets** (warehouse, mine, port) that need a consistent shared
  map for downstream planning.
- **Cross-platform data collection** where heterogeneous rigs (a high-end
  surveying vehicle + low-cost drones) pool their observations.

A single-node Gaussian-LIC2 map is locally photo-realistic but has no mechanism
to (i) exchange submaps, (ii) align coordinate frames across nodes, (iii)
reconcile conflicting Gaussian parameters, or (iv) stay consistent under
intermittent / bandwidth-limited links. This design addresses exactly those
gaps.

### 1.2 Design Goals

| # | Goal | Metric / Target |
|---|------|-----------------|
| G1 | **Scalability** — support 2–16 nodes | sub-linear bandwidth growth with node count |
| G2 | **Robustness to link loss** — nodes degrade gracefully when disconnected | map quality within 5% of connected after 30 s outage |
| G3 | **Global consistency** — globally aligned Gaussian map | ATE < 0.3 m on 200 m loops with 3 nodes |
| G4 | **Photo-realism** — preserve Gaussian-LIC2 rendering quality | PSNR within 1 dB of single-node baseline |
| G5 | **Real-time** — local odometry at ≥20 Hz, map merge at ≤2 s latency | on commodity edge GPU (Jetson Orin / RTX 4090) |
| G6 | **Heterogeneity** — nodes may differ in sensor count / quality | unified node descriptor + capability negotiation |
| G7 | **Backward compatibility** — a single node behaves as Gaussian-LIC2 | no regression on existing datasets |

---

## 2. System Model

### 2.1 Node Definition

A **node** is one moving platform. Each node carries:

- **N_c cameras** (N_c ≥ 1), rigidly mounted, partially overlapping fields of
  view. A multi-camera rig widens FOV and provides stereo-like baseline for
  scale in textureless regions.
- **N_l LiDARs** (N_l ≥ 1), rigidly mounted, possibly of different types
  (mechanical spinning, solid-state, MEMS). Multi-LiDAR widens spatial
  coverage and provides redundancy.
- **1 IMU** (or one per LiDAR head, fused into a virtual body-frame IMU).
- **Onboard compute** (edge GPU).
- **Wireless comm** interface (Wi-Fi 6/6E, 5G NR, or ad-hoc mesh radio).

All intrinsics, extrinsics, and time offsets are calibrated offline and stored
in a **node descriptor** (Section 2.4).

### 2.2 Body Frame Convention

Each node defines a **body frame** `B_i` anchored at the IMU center. Every
sensor's extrinsic is expressed as `T_{B_i <- S}` (sensor in body). The node's
trajectory is the pose of `B_i` in the node's **local world frame** `W_i`,
initialized at startup. Inter-node alignment is expressed as `T_{W_j <- W_i}`,
estimated by the **submap registration** module (Section 5).

### 2.3 Multi-Sensor Fusion Per Node

Per-node fusion generalizes Coco-LIC's continuous-time LiDAR-Inertial-Visual
odometry to the multi-camera / multi-LiDAR case:

- **IMU** drives a non-uniform B-spline over `SE(3)`, exactly as in Coco-LIC.
- **Each LiDAR** registers its scan against the local Gaussian-surfel map via
  point-to-Gaussian ICP residuals sampled at its own acquisition times on the
  spline (generalizes Gaussian-LIC2's single-LiDAR registration).
- **Each camera** contributes photometric residuals (SSIM + L1) rendered from
  the local Gaussian map at the camera's exposure mid-point on the spline.
- **Cross-sensor time offsets** (camera–LiDAR, LiDAR–LiDAR) are estimated
  online jointly with the spline, mirroring Coco-LIC's online time
  calibration, now extended to N_c + N_l offsets.

All residuals are stacked in a single sliding-window Gauss-Newton solve with
the B-spline prior as motion model, identical in spirit to Coco-LIC but with
the sensor count parameterized.

### 2.4 Node Descriptor

A self-describing, CBOR-encoded structure exchanged on node join:

```
NodeDescriptor {
  node_id:        u16            // unique, assigned by coordinator / hash of pubkey
  capabilities: {
    n_cameras:    u8
    n_lidars:     u8
    has_imu:      bool
    compute_tier: enum { ORIN, 4090, A100, ... }
    comm_tier:    enum { WIFI6, 5G, MESH }
  }
  sensors: [
    { kind: CAM, idx, model, intrinsics[K,D], res[w,h], fps, extrinsic[4x4] },
    { kind: LIDAR, idx, model, beams, fov, rate, extrinsic[4x4] },
    { kind: IMU, idx, rate, extrinsic[4x4] }
  ]
  time_offset_prior_ms: f64
  signing_pubkey:        ed25519
}
```

Descriptors are signed; a node refuses to merge data from an unsigned or
mismatched descriptor (capability gating, G6).

### 2.5 Network Topology — Hierarchical Hybrid

We adopt a **hierarchical hybrid** topology (decision: confirmed during design
review, see Section 9), motivated by the trade-offs below.

| Topology | Pros | Cons |
|----------|------|------|
| Centralized (1 fusion server + N clients) | simplest, global optimum | single point of failure, server bottleneck, high uplink |
| Decentralized P2P (full mesh) | no SPOF, low latency | O(N²) links, hard consistency, no global view |
| **Hierarchical hybrid** (cluster heads + P2P within cluster + optional edge server) | scalable, degrades to P2P on server loss, balances load | more complex protocol |

The hierarchy has **three logical tiers**:

1. **Tier-0 — Edge fusion server (optional).** A fixed or vehicle-mounted
   edge node (e.g., a backpack workstation or a stationary base station).
   Provides global map fusion, loop-closure search across clusters, and a
   ground-truth anchor. **Absent** in ad-hoc deployments; the system degrades
   to Tier-1 P2P.
2. **Tier-1 — Cluster heads.** Nodes self-elect cluster heads (by compute_tier
   and link quality). A cluster head merges submaps from its cluster members
   and talks to other cluster heads (P2P) and to the Tier-0 server (if present).
3. **Tier-2 — Cluster members.** Plain nodes that run local Gaussian-LIC2
   odometry and publish compressed submaps to their cluster head.

Election uses a deterministic score: `score = compute_tier_weight *
link_quality^(1/2) + n_sensors_bonus`. Highest score in a 2-hop neighborhood
becomes head; ties broken by `node_id`. Re-election triggers on head
heartbeat timeout (default 3 s).

### 2.6 System Architecture Overview

```
            ┌──────────────────────── Tier-0 (optional) ─────────────────────────┐
            │                  Edge Fusion Server                                 │
            │   ┌──────────────┐  ┌────────────────┐  ┌───────────────────┐      │
            │   │ Global Map   │←│ Cross-Cluster  │←│ Loop-Closure       │      │
            │   │ Merger       │  │ Submap Reg.    │  │ Graph (PGO)        │      │
            │   └──────┬───────┘  └────────┬───────┘  └─────────┬─────────┘      │
            └──────────┼────────────────────┼────────────────────┼────────────────┘
                       │ uplink (compressed) │                    │ constraints
            ┌──────────▼────────────────────▼────────────────────▼────────────────┐
   Tier-1   │              Inter-Cluster P2P Bus (DDS / ROS 2 / gRPC)              │
            │  ┌────────────┐        ┌────────────┐        ┌────────────┐          │
            │  │ Cluster Hd │◄──────►│ Cluster Hd │◄──────►│ Cluster Hd │          │
            │  └─────┬──────┘        └─────┬──────┘        └─────┬──────┘          │
            └────────┼──────────────────────┼─────────────────────┼────────────────┘
                     │ intra-cluster        │ intra-cluster       │ intra-cluster
            ┌────────▼──────┐       ┌───────▼──────┐      ┌───────▼──────┐
   Tier-2   │ Node 1 (local)│       │ Node 2 (local)│      │ Node 3 (local)│  ...
            │  LIO + VIO    │       │  LIO + VIO    │      │  LIO + VIO    │
            │  Local GS map │       │  Local GS map │      │  Local GS map │
            │  Submap pub.  │       │  Submap pub.  │      │  Submap pub.  │
            └───────────────┘       └───────────────┘      └───────────────┘
```

---

## 3. Software Architecture (per node)

Each node runs a **ROS 2 / DDS**-based component graph. The local pipeline is
Gaussian-LIC2 with new **cooperative** components added.

### 3.1 Component graph

```
  sensor drivers ──► sync & timestamp ──► [LIO core] ──► local trajectory (B-spline)
                                          │                │
                  ┌───────────────────────┘                ├──► local GS map (GaussianMap)
                  │                                          │
                  ▼                                          ▼
            [VIO photometric] ◄── renders ──  GaussianMap  ──► [Submap Extractor]
                                                                │
                                                                ▼
                                                        [Submap Compressor]
                                                                │
                                                                ▼
                                                        [Comm Layer] ──► peers / head
                                                                ▲
                                                        [Map Merger] ◄── incoming submaps
                                                                │
                                                                ▼
                                                        GaussianMap (merged)
                                                                │
                                                                ▼
                                                        [Loop-Closure Agent] ──► PGO graph
```

### 3.2 Module responsibilities

| Module | Responsibility | Reuse from Gaussian-LIC2 |
|--------|----------------|--------------------------|
| `spline_estimator` | CT B-spline over SE(3), multi-sensor residuals | yes (generalized to N_c, N_l) |
| `gaussian_map` | 3DGS map, densify/prune, rasterize | yes |
| `depth_completer` | zero-shot LiDAR depth completion for blind areas | yes |
| `submap_extractor` | carve a spatial sub-volume of Gaussians for export | **new** |
| `submap_compressor` | compress Gaussians (prune, SH trunc, entropy-coded attributes) | **new** |
| `comm_layer` | DDS transport, QoS, reliability, bandwidth cap | **new** |
| `map_merger` | align + dedupe + reconcile incoming submaps into local map | **new** |
| `loop_closure_agent` | detect inter-node loops, emit PGO constraints | **new** |
| `coordinator` | node discovery, cluster-head election, descriptor exchange | **new** |

---

## 4. Communication Protocol

### 4.1 Transport

- **DDS / ROS 2** as the default middleware (zero-copy intra-host, QoS
  reliability, multicast discovery). Falls back to **gRPC** over TCP for
  cross-subnet links where DDS multicast is blocked.
- **Wire format:** CBOR for control messages, **KTX2 + custom Gaussian blob**
  for submap payloads (see Section 4.4).
- **QoS profiles:** control = reliable + keep-last 10; submap = best-effort +
  keep-last 1 (a stale submap is useless); trajectory stream = reliable +
  keep-last 1.

### 4.2 Message Catalogue

| Msg type | Direction | Frequency | Payload | Reliability |
|----------|-----------|-----------|---------|-------------|
| `HELLO` | node→net | on join | NodeDescriptor | reliable |
| `HEARTBEAT` | node→net | 5 Hz | node_id, pose, health | best-effort |
| `POSE_STREAM` | node→head | 20 Hz | pose @ B-spline knots | reliable |
| `SUBMAP_PUSH` | node→head | on submap close | compressed submap | best-effort |
| `SUBMAP_PULL` | head→node | on demand | spatial query bbox | reliable |
| `CONSTRAINT` | any→any | on loop | PGO constraint (SE3 + info) | reliable |
| `MAP_DELTA` | head→node | 1 Hz | merged-map deltas | best-effort |
| `ELECTION` | node→net | on timeout | candidate score | reliable |
| `LEAVE` | node→net | on exit | node_id | reliable |

### 4.3 Connection Lifecycle

1. **Join.** New node broadcasts `HELLO` with its descriptor. Existing nodes
   reply with their descriptors; the cluster head replies with the current
   cluster map digest and its `node_id`.
2. **Calibration handshake.** If the new node's `W_i` is unaligned, the head
   sends an initial `T_{W_head <- W_i}` prior from a coarse GNSS /WiFi-RSSI /
   descriptor-extrinsic prior, refined after the first submap exchange.
3. **Steady state.** Node streams `POSE_STREAM` and publishes `SUBMAP_PUSH`
   on submap boundaries (every `S_sub` meters of travel or `T_sub` seconds,
   whichever first; defaults `S_sub=5 m`, `T_sub=3 s`).
4. **Link loss.** A node that loses the head for >3 s enters **autonomous
   mode**: continues local Gaussian-LIC2, buffers submaps locally, and
   re-broadcasts `HELLO` every 1 s. On reconnect, buffered submaps are
   flushed in chronological order (G2).
5. **Leave / eviction.** `LEAVE` triggers head to mark the node's submaps
   as "owned-but-absent"; they are kept for `T_keep=60 s` then garbage
   collected unless referenced by a loop constraint.

### 4.4 Submap Format & Compression

A **submap** is a spatially bounded subset of a node's Gaussian map, exported
on a submap boundary. It is the unit of inter-node data sharing.

**Submap structure (CBOR header + Gaussian blob):**

```
Submap {
  header: {
    submap_id:      u64,        // (node_id << 32) | seq
    node_id:        u16,
    seq:            u32,
    bbox_w_min:     [f64;3],    // in W_i
    bbox_w_max:     [f64;3],
    pose_w_b:       [f64;7],    // quat+trans of body at submap close, in W_i
    n_gaussians:    u32,
    version:        u8,
    crc32:          u32,
  },
  gaussians: [
    // SoA, entropy-coded:
    mean        : [f16;3] x N,     // quantized to 1 cm in local submap frame
    scale_log   : [f16;3] x N,
    rotation    : [f16;4] x N,     // quat
    opacity_logit: [f16]   x N,
    sh_coef     : [f16;k] x N,     // k = degree-dependent, default 3
    semantic_id : [u8]    x N,     // optional, from FeatureSLAM-style segs
  ]
}
```

**Compression knobs** (traded against bandwidth budget `B_budget`):

| Knob | Range | Effect |
|------|-------|--------|
| SH degree | 0–3 | halve bytes per Gaussian per degree step |
| Opacity prune | 0.005–0.05 | remove <1–5% of Gaussians, ~lossless |
| Spatial quantize | 1 cm – 5 cm | mean quantization error budget |
| Score threshold | density-based | drop low-contribution Gaussians |
| Entropy coding | zstd level 1–9 | 2–4× on top of above |

The compressor runs in a **budget controller**: it picks the tightest knob
combination that fits `B_budget` for the current submap, monitoring a moving
average of uplink throughput. On a 20 Mbps Wi-Fi 6 link a 5 m-travel submap
(~50 k Gaussians) compresses to ~3 MB at SH degree 2 + 2 cm quantize + zstd-5,
i.e. ~1.2 s at budget — consistent with G5.

### 4.5 Bandwidth Model

Let `N` be the number of nodes, `g` the per-submap Gaussian count, `f_s` the
submap publication rate. Uplink per node:

```
B_up = f_s * sizeof(compressed_submap(g))
     ≈ f_s * (g * 24 bytes)        // after compression, SH deg 2
```

For a cluster of `N` nodes on a cluster head, downlink load on the head is
`(N-1) * B_up`. With `N=8`, `g=50k`, `f_s = 0.33 Hz` → head downlink ≈ 3.2 MB/s
≈ 26 Mbps. The head therefore needs a ≥ Wi-Fi 6 (≈ 1 Gbps shared) or 5G link,
while member uplinks fit in a single 20 Mbps channel. This satisfies G1
(sub-linear growth via clustering: head count grows as √N, not N).

---

## 5. Cooperative Mapping

### 5.1 Local Map (per node)

Identical to Gaussian-LIC2: a 3DGS map densified by the depth-completer,
supervised by LiDAR geometry and camera photometry, with bounded scale and
regularization. Each node owns the Gaussians it creates (`owner = node_id`).

### 5.2 Submap Registration (inter-node alignment)

When a head receives a submap from node `j` expressed in `W_j`, it must align
it into the head's `W_head`. Three cases, in escalating cost:

1. **Descriptor prior.** If a coarse `T_{W_head <- W_j}` is known (GNSS,
   prior map, or initial handshake), use it as the prior for (2).
2. **Gaussian-to-Gaussian ICP.** Register the incoming submap's Gaussians
   against the head's current merged map using point-to-plane ICP on the
   Gaussian means, weighted by opacity and planarity (covariance of scale).
   Converges within 10 iterations when spatial overlap > 30%.
3. **Feature-based fallback.** If overlap < 30%, run a 2D feature match
   between representative camera keyframes of the two nodes (extracted from
   the submap's `pose_w_b` history and stored image descriptors), recover
   `T` via PnP + RANSAC, then refine with (2).

The result is a `T_{W_head <- W_j}` estimate with covariance, emitted as a
PGO constraint (Section 5.4).

### 5.3 Gaussian Map Merge

Once aligned, incoming Gaussians are merged into the head's map:

- **Spatial dedup.** For each incoming Gaussian, query the map octree for
  existing Gaussians within `τ_d = 3 * mean_scale`. If found, **fuse** the
  pair (weighted average of means, scales, SH; sigmoid-mixed opacities,
  mirroring the consolidation in GS-LIVM / LIV-GS). If not, insert.
- **Ownership bookkeeping.** Merged Gaussians carry a list of contributing
  `owner` ids, so a node can later prune only its own contributions.
- **Map delta broadcast.** The head emits a `MAP_DELTA` containing only the
  changed Gaussians (new + fused), so member nodes can lazily update their
  local copies for rendering / planning.

### 5.4 Pose-Graph Optimization

A robust pose graph is maintained across all nodes:

- **Vertices:** per-node keyframe poses (one per submap close).
- **Edges:**
  - intra-node odometry edges (from the B-spline, with information matrix
    from the Gauss-Newton Hessian),
  - inter-node registration edges (from Section 5.2),
  - loop-closure edges (from Section 5.5).

PGO is solved by GTSAM's `iSAM2` on the cluster head (and on the Tier-0
server at coarser granularity). Solutions are pushed down as `MAP_DELTA`
corrections to member nodes, which apply a per-Gaussian rigid correction
within their owned submaps (since a submap is rigid, this is exact for the
means and rotations, with a small scale/SH re-fit).

### 5.5 Loop Closure

Two mechanisms:

- **Geometric.** Submap registration with a low overlap threshold (10%) is
  attempted against geographically distant (in graph terms) submaps using the
  pose graph as a prior; success creates a loop edge.
- **Visual.** A NetVLAD descriptor is computed for each keyframe and
  broadcast to the head. The head maintains a DBoW2-style inverted index and
  queries candidate loops when descriptors match within threshold. Verified
  loops emit PGO constraints.

### 5.6 Conflict Resolution

Conflicts (same spatial region, divergent Gaussian parameters from two
nodes) are resolved by a **confidence-weighted** rule:

```
confidence = opacity * (n_photometric_obs + n_lidar_obs) * sensor_quality_weight
```

Higher-confidence Gaussians dominate the merge; lower-confidence ones are
demoted (opacity shrink) and eventually pruned. `sensor_quality_weight`
comes from the node descriptor (e.g., a survey-grade LiDAR weights higher
than a toy-drone LiDAR).

---

## 6. Failure Modes & Robustness

| Failure | Detection | Response |
|---------|-----------|----------|
| Head loss | HEARTBEAT timeout 3 s | re-election; nodes buffer submaps |
| Member loss | HEARTBEAT timeout 3 s | head marks submaps owned-but-absent; GC after 60 s |
| Link jitter | RTT > 500 ms for 5 s | compressor lowers SH degree, raises quantize |
| Total partition | all peers gone | node runs pure Gaussian-LIC2 indefinitely (G7) |
| Descriptor mismatch | signature fail / capability gap | refuse merge; log security event |
| Clock desync | offset drift > 5 ms | re-run online time offset estimation (Coco-LIC-style) on next submap overlap |
| Byzantine node | constraint residual outlier | PGO robust kernel (DCS); node flagged after 3 outliers |

---

## 7. Interfaces (key APIs)

### 7.1 `coordinator` API (sketch)

```cpp
class Coordinator {
 public:
  // Called on startup; broadcasts HELLO, collects descriptors.
  void joinNetwork(const NodeDescriptor& self);
  // Returns the current cluster head id (self if elected).
  NodeId clusterHead() const;
  // Called when a new node's HELLO is received.
  void onHello(const NodeDescriptor& peer);
  // Called on HEARTBEAT timeout; triggers re-election.
  void onHeadTimeout();
};
```

### 7.2 `submap_extractor` API (sketch)

```cpp
struct SubmapRequest {
  AABB bbox_w;          // spatial query, in W_i
  Pose pose_w_b_at_close;
  CompressionConfig cfg; // budget knobs
};
Submap extractSubmap(GaussianMap& map, const SubmapRequest& req);
```

### 7.3 `map_merger` API (sketch)

```cpp
class MapMerger {
 public:
  // Align incoming submap to local W, merge into local map, emit PGO edge.
  MergeResult merge(const Submap& incoming,
                    const std::optional<PosePrior>& prior);
  // Apply a PGO correction delta to the local map.
  void applyCorrection(const PoseGraphDelta& delta);
};
```

---

## 8. Configuration Parameters (defaults)

| Param | Default | Meaning |
|-------|---------|---------|
| `S_sub` | 5 m | submap spatial size |
| `T_sub` | 3 s | submap temporal size |
| `B_budget` | 20 Mbps | per-node uplink budget |
| `τ_d` | 3 × mean_scale | Gaussian dedup radius |
| `T_heartbeat` | 200 ms | heartbeat period |
| `T_head_timeout` | 3 s | head loss detection |
| `T_keep` | 60 s | orphan submap GC delay |
| `SH_degree_max` | 2 | max SH degree on the wire |
| `quantize_cm` | 2 cm | mean quantization |
| `loop_overlap_min` | 10% | min overlap to attempt loop |

---

## 9. Design Decisions Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-09-25 | Hierarchical hybrid topology | balances scalability, SPOF risk, and complexity (Section 2.5) |
| 2026-09-25 | 3DGS as shared map representation | continuity with Gaussian-LIC2, photo-realism (G4), mature compression |
| 2026-09-25 | DDS + gRPC fallback transport | ROS 2 ecosystem fit; cross-subnet fallback |
| 2026-09-25 | Submap = unit of sharing | bounded size, spatially localized, natural boundary from CT trajectory |
| 2026-09-25 | Ownership-tagged Gaussians | enables per-node pruning and conflict resolution |

---

## 10. Open Questions (for next iteration)

- **O1.** Dynamic cluster-head handoff under node mobility — how to migrate
  merged state without a stall?
- **O2.** Multi-node dynamic-object handling — RoSe-SLAM-style motion seg
  per node, then cross-node consensus?
- **O3.** Bandwidth under 5G with per-flow QoS — measurement campaign.
- **O4.** Security model beyond signed descriptors — sybil resistance,
  replay protection.
- **O5.** Energy budget on UAV nodes — compressor cost vs. comm cost
  trade-off.

---

*End of design document. See `latex/paper/` for the paper draft that
presents this system to the research community.*
