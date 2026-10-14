// swift-tools-version: 6.1
// GaussianLIC iOS — Gaussian Splatting capture, training & rendering for iPhone Pro
// Copyright (C) 2026 arthurlirui
//
// Rendering uses Apple's native RealityKit GaussianSplatComponent (iOS 27+).
// On-device training uses the msplat Metal engine (third_party/msplat, Apache 2.0).

import PackageDescription

let package = Package(
    name: "GaussianLIC",
    platforms: [
        .iOS(.v27)
    ],
    products: [
        .library(name: "GaussianLIC", targets: ["GaussianLIC"])
    ],
    dependencies: [
        // msplat: Metal-based 3DGS training engine for on-device optimization.
        // Vendored as a git submodule at third_party/msplat.
        .package(path: "../third_party/msplat")
    ],
    targets: [
        .target(
            name: "GaussianLIC",
            dependencies: [
                .product(name: "msplat", package: "msplat")
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
