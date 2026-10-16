// swift-tools-version: 6.1
// GaussianLIC iOS — Gaussian Splatting capture, training & rendering for iPhone Pro
// Copyright (C) 2026 arthurlirui
//
// Rendering uses MetalSplatter (MIT, github.com/scier/MetalSplatter) for
// Metal-based 3DGS rasterization on iOS 18+.
// On-device training uses Apple's MLX Swift (Apache 2.0, github.com/ml-explore/mlx-swift)
// for differentiable Gaussian Splatting optimization via Metal.

import PackageDescription

let package = Package(
    name: "GaussianLIC",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "GaussianLIC", targets: ["GaussianLIC"])
    ],
    dependencies: [
        // MetalSplatter: Swift/Metal Gaussian Splat renderer (PLY/SPZ/.splat, SH0–SH3).
        // Vendored as a git submodule at third_party/MetalSplatter.
        .package(path: "../third_party/MetalSplatter"),

        // MLX Swift: Apple's array framework for on-device ML with autograd.
        // We use a custom ManualAdam for per-group constant LRs (matching win_lic),
        // so MLXOptimizers is not needed.
        .package(url: "https://github.com/ml-explore/mlx-swift.git", from: "0.22.0")
    ],
    targets: [
        .target(
            name: "GaussianLIC",
            dependencies: [
                .product(name: "MetalSplatter", package: "MetalSplatter"),
                .product(name: "SplatIO", package: "MetalSplatter"),
                .product(name: "MLX", package: "mlx-swift"),
                .product(name: "MLXRandom", package: "mlx-swift")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "GaussianLICTests",
            dependencies: ["GaussianLIC"],
            path: "Tests"
        )
    ]
)
