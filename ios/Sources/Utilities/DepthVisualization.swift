//
//  DepthVisualization.swift
//  GaussianLIC
//
//  Converts ARKit LiDAR depth maps to colourized images for on-screen
//  preview during capture. Uses a turbo-like colour map for intuitive
//  depth perception.
//

import Foundation
import ARKit
import CoreVideo
import CoreImage
import UIKit

enum DepthVisualization {

    /// Convert a Float32 depth CVPixelBuffer to a colourized UIImage.
    /// Near = red, far = blue. Values beyond `maxDepth` are clamped.
    static func colourize(depthMap: CVPixelBuffer, maxDepth: Float = 5.0) -> UIImage? {
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }

        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)

        guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap) else { return nil }

        // Create a RGBA bitmap context.
        let colourSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let rgbBytesPerRow = width * 4

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: rgbBytesPerRow,
            space: colourSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }

        guard let rgbData = context.data else { return nil }

        let depthPtr = baseAddress.assumingMemoryBound(to: Float.self)
        let rgbPtr = rgbData.assumingMemoryBound(to: UInt8.self)

        for y in 0..<height {
            for x in 0..<width {
                let depth = depthPtr[y * (bytesPerRow / MemoryLayout<Float>.size) + x]
                let normalized = max(0, min(1, depth / maxDepth))
                let (r, g, b) = turboColourMap(normalized)

                let offset = (y * rgbBytesPerRow) + (x * 4)
                rgbPtr[offset] = r
                rgbPtr[offset + 1] = g
                rgbPtr[offset + 2] = b
                rgbPtr[offset + 3] = 255
            }
        }

        guard let cgImage = context.makeImage() else { return nil }
        return UIImage(cgImage: cgImage)
    }

    /// Convert a confidence map to a grayscale UIImage.
    static func visualizeConfidence(_ confidenceMap: CVPixelBuffer) -> UIImage? {
        CVPixelBufferLockBaseAddress(confidenceMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(confidenceMap, .readOnly)

        let width = CVPixelBufferGetWidth(confidenceMap)
        let height = CVPixelBufferGetHeight(confidenceMap)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(confidenceMap)

        guard let baseAddress = CVPixelBufferGetBaseAddress(confidenceMap) else { return nil }

        let confPtr = baseAddress.assumingMemoryBound(to: UInt8.self)

        // Map: 0 (low) = red, 1 (medium) = yellow, 2 (high) = green
        let colourSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let rgbBytesPerRow = width * 4

        guard let context = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: rgbBytesPerRow,
            space: colourSpace, bitmapInfo: bitmapInfo.rawValue
        ), let rgbData = context.data else { return nil }

        let rgbPtr = rgbData.assumingMemoryBound(to: UInt8.self)

        for y in 0..<height {
            for x in 0..<width {
                let conf = confPtr[y * bytesPerRow + x]
                let (r, g, b): (UInt8, UInt8, UInt8)
                switch conf {
                case 0: (r, g, b) = (255, 0, 0)       // low = red
                case 1: (r, g, b) = (255, 200, 0)     // medium = yellow
                default: (r, g, b) = (0, 255, 0)      // high = green
                }
                let offset = (y * rgbBytesPerRow) + (x * 4)
                rgbPtr[offset] = r
                rgbPtr[offset + 1] = g
                rgbPtr[offset + 2] = b
                rgbPtr[offset + 3] = 255
            }
        }

        guard let cgImage = context.makeImage() else { return nil }
        return UIImage(cgImage: cgImage)
    }

    // MARK: - Turbo Colour Map

    /// Approximate turbo colour map (simplified for performance).
    /// Maps [0, 1] → (r, g, b) in 0-255.
    private static func turboColourMap(_ t: Float) -> (UInt8, UInt8, UInt8) {
        let t = max(0, min(1, t))

        // Simplified turbo: blue → cyan → green → yellow → red
        let r: Float
        let g: Float
        let b: Float

        if t < 0.25 {
            r = 0
            g = 4 * t
            b = 1
        } else if t < 0.5 {
            r = 0
            g = 1
            b = 1 - 4 * (t - 0.25)
        } else if t < 0.75 {
            r = 4 * (t - 0.5)
            g = 1
            b = 0
        } else {
            r = 1
            g = 1 - 4 * (t - 0.75)
            b = 0
        }

        return (
            UInt8(r * 255),
            UInt8(g * 255),
            UInt8(b * 255)
        )
    }

    /// Convert a CVPixelBuffer (YUV or BGRA) to UIImage for preview.
    static func convertToUIImage(_ pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
