//
//  MetalHelpers.swift
//  GaussianLIC
//
//  Utility functions for Metal device access and simd matrix operations.
//  Render-target texture helpers have been removed — RealityKit manages
//  its own render targets when using GaussianSplatComponent.
//
//  The simd extensions are used by sensor capture and training modules.
//

import Foundation
import Metal
import MetalKit
import CoreVideo
import simd

enum MetalHelpers {

    /// Get the system default Metal device.
    static var device: MTLDevice? {
        MTLCreateSystemDefaultDevice()
    }

    /// Create a Metal texture from a CVPixelBuffer (zero-copy via IOSurface).
    static func makeTexture(from pixelBuffer: CVPixelBuffer,
                            pixelFormat: MTLPixelFormat,
                            device: MTLDevice) -> MTLTexture? {
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)

        guard let cache = textureCache else { return nil }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        var cvTexture: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            cache,
            pixelBuffer,
            nil,
            pixelFormat,
            width,
            height,
            0,
            &cvTexture
        )

        guard let cvTexture else { return nil }
        return CVMetalTextureGetTexture(cvTexture)
    }

    /// Create a Metal texture from an ARFrame's capturedImage (YUV 420f).
    /// Returns a BGRA texture via CIImage conversion.
    static func makeRGBTexture(from capturedImage: CVPixelBuffer,
                               device: MTLDevice,
                               commandQueue: MTLCommandQueue) -> MTLTexture? {
        let ciContext = CIContext(mtlDevice: device)
        let ciImage = CIImage(cvPixelBuffer: capturedImage)

        let width = CVPixelBufferGetWidth(capturedImage)
        let height = CVPixelBufferGetHeight(capturedImage)

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm_srgb,
            width: width,
            height: height,
            usage: [.shaderRead, .shaderWrite]
        )

        guard let texture = device.makeTexture(descriptor: descriptor) else { return nil }

        ciContext.render(ciImage, to: texture, commandBuffer: nil,
                         bounds: ciImage.extent,
                         colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)

        return texture
    }

    /// Allocate a Metal buffer with aligned size.
    static func makeBuffer<T>(device: MTLDevice, array: [T], options: MTLResourceOptions) -> MTLBuffer? {
        device.makeBuffer(bytes: array, length: MemoryLayout<T>.size * array.count, options: options)
    }

    /// Compute the aligned size for uniform buffer binding (256-byte alignment).
    static func alignedSize(_ size: Int, alignment: Int = 256) -> Int {
        (size + alignment - 1) & ~(alignment - 1)
    }

    /// Available GPU working-set headroom in bytes (for memory-safe training budgets).
    static func availableWorkingSetSize(device: MTLDevice) -> UInt64 {
        device.recommendedMaxWorkingSetSize
    }
}

// MARK: - Matrix Utilities

extension simd_float4x4 {
    /// Extract the upper-left 3×3 as a simd_float3x3.
    var upperLeft3x3: simd_float3x3 {
        simd_float3x3(
            SIMD3<Float>(columns.0.x, columns.0.y, columns.0.z),
            SIMD3<Float>(columns.1.x, columns.1.y, columns.1.z),
            SIMD3<Float>(columns.2.x, columns.2.y, columns.2.z)
        )
    }

    /// Extract translation (column 3).
    var translation: SIMD3<Float> {
        SIMD3(columns.3.x, columns.3.y, columns.3.z)
    }
}

extension simd_float3x3 {
    /// Convert from ARCamera.intrinsics format.
    /// ARCamera.intrinsics is a 3×3 matrix where:
    ///   [fx  0  cx]
    ///   [0  fy  cy]
    ///   [0   0   1]
    var fx: Float { columns.0.x }
    var fy: Float { columns.1.y }
    var cx: Float { columns.2.x }
    var cy: Float { columns.2.y }
}
