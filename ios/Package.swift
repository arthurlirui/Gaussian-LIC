// swift-tools-version: 5.9
// GaussianLIC iOS — Gaussian Splatting capture & rendering for iPhone Pro
// Copyright (C) 2026 arthurlirui

import PackageDescription

let package = Package(
    name: "GaussianLIC",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "GaussianLIC", targets: ["GaussianLIC"])
    ],
    dependencies: [
        // MetalSplatter is already in the repo as a git submodule.
        // We reference it via relative path so the iOS app and macOS viewer
        // share the same checkout.
        .package(path: "../third_party/MetalSplatter")
    ],
    targets: [
        .target(
            name: "GaussianLIC",
            dependencies: [
                .product(name: "MetalSplatter", package: "MetalSplatter"),
                .product(name: "SplatIO", package: "MetalSplatter")
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
