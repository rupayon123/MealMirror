import Foundation
import UIKit
import ImageIO
import CoreImage
enum MealPhotoPreparation {
    static func downsampledImageAsync(from data: Data, maxPixelSize: Int = 1_800) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: downsampledImage(from: data, maxPixelSize: maxPixelSize))
            }
        }
    }

    static func downsampledImage(from data: Data, maxPixelSize: Int = 1_800) -> UIImage? {
        // Reject invalid limits and keep decoded previews within the app's
        // largest intentional label-photo size.
        guard !data.isEmpty, (1...2_400).contains(maxPixelSize) else { return nil }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: CFDictionary = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceShouldCacheImmediately: true
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options),
              cgImage.width > 0, cgImage.height > 0,
              max(cgImage.width, cgImage.height) <= maxPixelSize else { return nil }
        return UIImage(cgImage: cgImage)
    }

    static func downsampledImage(from image: UIImage, maxPixelSize: CGFloat = 1_800) -> UIImage? {
        guard maxPixelSize.isFinite, maxPixelSize > 0,
              image.scale.isFinite, image.scale > 0 else { return nil }

        // UIKit's thumbnail preparer returns nil for a CIImage-backed UIImage.
        // Never pass the unprepared original to the preview or Vision.
        if let ciImage = image.ciImage {
            let extent = ciImage.extent
            guard !extent.isNull, !extent.isInfinite,
                  extent.width.isFinite, extent.height.isFinite,
                  extent.width > 0, extent.height > 0,
                  extent.width * extent.height <= 50_000_000 else { return nil }
            let scale = min(1, maxPixelSize / max(extent.width, extent.height))
            // Align the crop before scaling so integral render bounds do not
            // add a pixel for a negative fractional origin and exceed the limit.
            let normalizedImage = ciImage.transformed(by: CGAffineTransform(
                translationX: -extent.minX, y: -extent.minY
            ))
            let scaledImage = normalizedImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            guard let cgImage = CIContext(options: [.cacheIntermediates: false])
                .createCGImage(scaledImage, from: scaledImage.extent),
                  max(CGFloat(cgImage.width), CGFloat(cgImage.height)) <= maxPixelSize else {
                return nil
            }
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }

        // preparingThumbnail's size is in points; Vision receives CGImage pixels.
        let pointLimit = maxPixelSize / max(image.scale, 1)
        guard let thumbnail = image.preparingThumbnail(
            of: CGSize(width: pointLimit, height: pointLimit)
        ), let cgImage = thumbnail.cgImage,
              max(CGFloat(cgImage.width), CGFloat(cgImage.height)) <= maxPixelSize else {
            return nil
        }
        return thumbnail
    }

    static func downsampledImageAsync(from image: UIImage, maxPixelSize: CGFloat = 1_800) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: downsampledImage(from: image, maxPixelSize: maxPixelSize))
            }
        }
    }
}

extension UIImage.Orientation {
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch self {
        case .up: .up
        case .upMirrored: .upMirrored
        case .down: .down
        case .downMirrored: .downMirrored
        case .left: .left
        case .leftMirrored: .leftMirrored
        case .right: .right
        case .rightMirrored: .rightMirrored
        @unknown default: .up
        }
    }
}
