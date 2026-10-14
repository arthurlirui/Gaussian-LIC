//
//  PLYLoader.swift
//  GaussianLIC
//
//  Parses standard 3DGS PLY files (binary little-endian) into
//  RealityKit's GaussianSplatResource.BufferResource for use with
//  GaussianSplatComponent.
//
//  PLY property layout (standard 3DGS convention):
//    x, y, z                          — float32 position
//    f_dc_0, f_dc_1, f_dc_2           — float32 SH degree 0 (base color)
//    f_rest_0 … f_rest_44             — float32 SH degrees 1-3 (45 coefficients for sh_degree=3)
//    opacity                          — float32 (unbounded, sigmoid'd by RealityKit)
//    scale_0, scale_1, scale_2        — float32 (log space, exp'd by RealityKit)
//    rot_0, rot_1, rot_2, rot_3       — float32 quaternion (w, x, y, z)
//
//  Follows the pattern from Apple's "Rendering Gaussian splats with RealityKit"
//  sample code: read raw bytes, deinterleave into separate buffers, sanitize
//  NaN/Inf values (RealityKit rejects non-finite splat data).
//

import Foundation
import RealityKit

/// Holds the deinterleaved per-splat GPU buffers ready for GaussianSplatResource.
struct GaussianSplatBuffers {
    var positionBuffer: LowLevelBuffer?
    var scaleBuffer: LowLevelBuffer?
    var rotationBuffer: LowLevelBuffer?
    var opacityBuffer: LowLevelBuffer?
    var shBuffer: LowLevelBuffer?
    var splatCount: UInt32 = 0
    var degreeSH: Int = 0
    var tupleSH: Bool = false  // true if SH data is stored as SIMD3 tuples
}

enum PLYLoaderError: LocalizedError {
    case cannotOpen(URL)
    case invalidHeader
    case unsupportedFormat
    case noVertexElement
    case propertyCountMismatch(expected: Int, actual: Int)

    var errorDescription: String? {
        switch self {
        case .cannotOpen(let url): return "Cannot open PLY file: \(url.lastPathComponent)"
        case .invalidHeader: return "Invalid PLY header"
        case .unsupportedFormat: return "Only binary little-endian PLY is supported"
        case .noVertexElement: return "PLY has no vertex element"
        case .propertyCountMismatch(let expected, let actual):
            return "Expected \(expected) properties per vertex but found \(actual)"
        }
    }
}

enum PLYLoader {

    /// Parsed PLY header information.
    private struct PLYHeader {
        var format: String = "binary_little_endian"
        var vertexCount: Int = 0
        var properties: [String] = []  // ordered property names
    }

    /// Load and parse a PLY file, producing GaussianSplatBuffers for RealityKit.
    ///
    /// - Parameters:
    ///   - url: File URL to the .ply file.
    ///   - maxSplatCount: Optional cap on splats to load (0 = unlimited).
    /// - Returns: Deinterleaved buffers ready for GaussianSplatResource.BufferResource.
    static func load(_ url: URL, maxSplatCount: Int = 0) throws -> GaussianSplatBuffers {
        guard let data = try? Data(contentsOf: url) else {
            throw PLYLoaderError.cannotOpen(url)
        }
        return try load(from: data, maxSplatCount: maxSplatCount)
    }

    /// Parse PLY from in-memory Data.
    static func load(from data: Data, maxSplatCount: Int = 0) throws -> GaussianSplatBuffers {
        // Parse the ASCII header (ends with "end_header\n").
        guard let headerEndRange = data.range(of: Data("end_header\n".utf8)) else {
            throw PLYLoaderError.invalidHeader
        }

        let headerString = String(data: data.subdata(in: 0..<headerEndRange.lowerBound),
                                   encoding: .utf8) ?? ""
        let header = try parseHeader(headerString)

        guard header.vertexCount > 0 else {
            throw PLYLoaderError.noVertexElement
        }

        guard header.format == "binary_little_endian" else {
            throw PLYLoaderError.unsupportedFormat
        }

        // Determine how many splats to actually load.
        let count = maxSplatCount > 0 ? min(maxSplatCount, header.vertexCount) : header.vertexCount

        // Binary data starts right after "end_header\n".
        let binaryStart = headerEndRange.upperBound
        let binaryData = data.subdata(in: binaryStart..<data.count)

        // All properties are float32 in standard 3DGS PLY.
        let floatSize = MemoryLayout<Float>.size
        let bytesPerVertex = header.properties.count * floatSize

        guard binaryData.count >= count * bytesPerVertex else {
            throw PLYLoaderError.propertyCountMismatch(
                expected: bytesPerVertex, actual: binaryData.count)
        }

        // Map property names to indices for deinterleaving.
        let propIndex = buildPropertyIndexMap(header.properties)

        // Determine SH degree from f_rest count.
        let fRestCount = header.properties.filter { $0.hasPrefix("f_rest_") }.count
        let degreeSH: Int
        switch fRestCount {
        case 0:  degreeSH = 0
        case 9:  degreeSH = 1
        case 24: degreeSH = 2
        case 45: degreeSH = 3
        default: degreeSH = 0
        }

        // Allocate output arrays.
        var positions = [SIMD3<Float>](repeating: .zero, count: count)
        var scales = [SIMD3<Float>](repeating: .zero, count: count)
        var rotations = [SIMD4<Float>](repeating: .zero, count: count)
        var opacities = [Float](repeating: 0, count: count)
        let shCoeffsPerSplat = fRestCount + 3  // f_dc (3) + f_rest
        var shCoeffs = [Float](repeating: 0, count: count * shCoeffsPerSplat)

        // Deinterleave binary data.
        binaryData.withUnsafeBytes { rawBuffer in
            let floatPtr = rawBuffer.bindMemory(to: Float.self)

            for i in 0..<count {
                let base = i * header.properties.count

                // Position
                if let xi = propIndex["x"], let yi = propIndex["y"], let zi = propIndex["z"] {
                    positions[i] = SIMD3(
                        sanitize(floatPtr[base + xi]),
                        sanitize(floatPtr[base + yi]),
                        sanitize(floatPtr[base + zi])
                    )
                }

                // Scale (log space)
                if let si0 = propIndex["scale_0"], let si1 = propIndex["scale_1"], let si2 = propIndex["scale_2"] {
                    scales[i] = SIMD3(
                        sanitize(floatPtr[base + si0]),
                        sanitize(floatPtr[base + si1]),
                        sanitize(floatPtr[base + si2])
                    )
                }

                // Rotation (w, x, y, z)
                if let ri0 = propIndex["rot_0"], let ri1 = propIndex["rot_1"],
                   let ri2 = propIndex["rot_2"], let ri3 = propIndex["rot_3"] {
                    rotations[i] = SIMD4(
                        sanitize(floatPtr[base + ri0]),
                        sanitize(floatPtr[base + ri1]),
                        sanitize(floatPtr[base + ri2]),
                        sanitize(floatPtr[base + ri3])
                    )
                }

                // Opacity (unbounded)
                if let oi = propIndex["opacity"] {
                    opacities[i] = sanitize(floatPtr[base + oi])
                }

                // SH coefficients: f_dc_0..2 then f_rest_0..N
                if let dc0 = propIndex["f_dc_0"], let dc1 = propIndex["f_dc_1"], let dc2 = propIndex["f_dc_2"] {
                    shCoeffs[i * shCoeffsPerSplat + 0] = sanitize(floatPtr[base + dc0])
                    shCoeffs[i * shCoeffsPerSplat + 1] = sanitize(floatPtr[base + dc1])
                    shCoeffs[i * shCoeffsPerSplat + 2] = sanitize(floatPtr[base + dc2])
                }
                for j in 0..<fRestCount {
                    if let ri = propIndex["f_rest_\(j)"] {
                        shCoeffs[i * shCoeffsPerSplat + 3 + j] = sanitize(floatPtr[base + ri])
                    }
                }
            }
        }

        // Create LowLevelBuffers for RealityKit.
        // Each buffer uses a stride matching the descriptor we'll create in SplatSceneManager.
        let positionBuffer = LowLevelBuffer(
            stride: MemoryLayout<SIMD3<Float>>.stride,
            count: count,
            containing: positions
        )
        let scaleBuffer = LowLevelBuffer(
            stride: MemoryLayout<SIMD3<Float>>.stride,
            count: count,
            containing: scales
        )
        let rotationBuffer = LowLevelBuffer(
            stride: MemoryLayout<SIMD4<Float>>.stride,
            count: count,
            containing: rotations
        )
        let opacityBuffer = LowLevelBuffer(
            stride: MemoryLayout<Float>.stride,
            count: count,
            containing: opacities
        )
        let shBuffer = LowLevelBuffer(
            stride: MemoryLayout<Float>.stride,
            count: count * shCoeffsPerSplat,
            containing: shCoeffs
        )

        return GaussianSplatBuffers(
            positionBuffer: positionBuffer,
            scaleBuffer: scaleBuffer,
            rotationBuffer: rotationBuffer,
            opacityBuffer: opacityBuffer,
            shBuffer: shBuffer,
            splatCount: UInt32(count),
            degreeSH: degreeSH,
            tupleSH: false
        )
    }

    // MARK: - Header Parsing

    private static func parseHeader(_ header: String) throws -> PLYHeader {
        var result = PLYHeader()
        var inVertexElement = false

        for line in header.split(separator: "\n", omittingEmptySubsequences: true) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let parts = trimmed.split(separator: " ", omittingEmptySubsequences: true)

            guard let keyword = parts.first else { continue }

            switch String(keyword) {
            case "format":
                if parts.count >= 2 {
                    result.format = String(parts[1])
                }
            case "element":
                if parts.count >= 3 && parts[1] == "vertex" {
                    result.vertexCount = Int(parts[2]) ?? 0
                    inVertexElement = true
                } else {
                    inVertexElement = false
                }
            case "property":
                if inVertexElement && parts.count >= 3 {
                    // "property float x" → name is parts[2]
                    result.properties.append(String(parts[2]))
                }
            default:
                break
            }
        }

        return result
    }

    // MARK: - Helpers

    /// Replace NaN/Inf with 0 (RealityKit rejects non-finite splat values).
    @inline(__always)
    private static func sanitize(_ value: Float) -> Float {
        value.isFinite ? value : 0
    }

    /// Build a dictionary mapping property name → column index in the interleaved data.
    private static func buildPropertyIndexMap(_ properties: [String]) -> [String: Int] {
        var map: [String: Int] = [:]
        for (i, name) in properties.enumerated() {
            map[name] = i
        }
        return map
    }
}
