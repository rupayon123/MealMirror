import Foundation
import UIKit
import ImageIO
enum MealPhotoPreparation {
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

}
// Real Mac Catalyst UIKit/ImageIO command-line diagnostic. Not an app host or iOS device.
import CoreGraphics
import CryptoKit
import Darwin
import Foundation
import ImageIO
import UIKit

private func sha256(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

private func peakRSSRaw() -> Int64 {
    var usage = rusage()
    guard getrusage(RUSAGE_SELF, &usage) == 0 else { return -1 }
    return Int64(usage.ru_maxrss)
}

private func corners(of image: CGImage) -> [String]? {
    var bytes = [UInt8](repeating: 0, count: 64)
    let rendered = bytes.withUnsafeMutableBytes { buffer -> Bool in
        guard let context = CGContext(data: buffer.baseAddress, width: 4, height: 4,
            bitsPerComponent: 8, bytesPerRow: 16, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
        context.interpolationQuality = .none
        context.draw(image, in: CGRect(x: 0, y: 0, width: 4, height: 4))
        return true
    }
    guard rendered else { return nil }
    return [(0, 0), (3, 0), (0, 3), (3, 3)].map { x, y in
        let offset = (y * 4 + x) * 4
        let r = Int(bytes[offset]), g = Int(bytes[offset + 1]), b = Int(bytes[offset + 2])
        if r > 150 && g > 140 && b < 100 { return "yellow" }
        if r > g + 60 && r > b + 60 { return "red" }
        if g > r + 60 && g > b + 60 { return "green" }
        if b > r + 60 && b > g + 60 { return "blue" }
        return "unclassified"
    }
}

@main
private struct LargeEncodedCatalystProbe {
    @MainActor static func main() throws {
        #if !targetEnvironment(macCatalyst)
        fatalError("Requires real Mac Catalyst UIKit")
        #endif
        guard CommandLine.arguments.count == 4 else { fatalError("fixture, frozen SHA-256, report path required") }
        let fixture = URL(fileURLWithPath: CommandLine.arguments[1])
        let expectedHash = CommandLine.arguments[2]
        let report = URL(fileURLWithPath: CommandLine.arguments[3])
        guard !FileManager.default.fileExists(atPath: report.path) else { fatalError("Refusing overwrite") }
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 40) { _exit(124) }
        let started = ProcessInfo.processInfo.systemUptime
        let initialRSS = peakRSSRaw()
        let data = try Data(contentsOf: fixture)
        let inputRSS = peakRSSRaw()
        guard sha256(data) == expectedHash else { fatalError("Input SHA-256 differs from frozen bytes") }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              properties[kCGImagePropertyPixelWidth as String] as? Int == 8000,
              properties[kCGImagePropertyPixelHeight as String] as? Int == 6000,
              properties[kCGImagePropertyOrientation as String] as? Int == 6 else {
            fatalError("Input dimensions or EXIF orientation differ from frozen protocol")
        }
        var rows: [[String: Any]] = []
        let expectedCorners = ["red", "blue", "green", "yellow"]
        for (limit, width, height) in [(1_800, 1_350, 1_800), (2_400, 1_800, 2_400)] {
            let before = peakRSSRaw()
            let start = ProcessInfo.processInfo.systemUptime
            let image = MealPhotoPreparation.downsampledImage(from: data, maxPixelSize: limit)
            let apiSeconds = ProcessInfo.processInfo.systemUptime - start
            let after = peakRSSRaw()
            let pixels = image?.cgImage
            let observedCorners = pixels.flatMap { corners(of: $0) }
            let checks: [String: Bool] = [
                "returnedImage": pixels != nil,
                "width": pixels?.width == width,
                "height": pixels?.height == height,
                "longEdgeBound": pixels.map { max($0.width, $0.height) <= limit } ?? false,
                "orientationUp": image?.imageOrientation == .up,
                "scaleOne": image?.scale == 1,
                "cornerOrientation": observedCorners == expectedCorners
            ]
            let passed = checks.values.allSatisfy { $0 }
            rows.append(["limit": limit, "expectedPixels": [width, height],
                         "actualPixels": pixels.map { [$0.width, $0.height] } ?? [],
                         "expectedCorners": expectedCorners,
                         "actualCorners": observedCorners ?? [],
                         "checks": checks, "passed": passed,
                         "apiSeconds": apiSeconds,
                         "ruMaxRSSBeforeRaw": before, "ruMaxRSSAfterRaw": after])
            if !passed { break } // First failed case stops the planned serial batch.
        }
        let passed = rows.count == 2 && rows.allSatisfy { $0["passed"] as? Bool == true }
        let result: [String: Any] = [
            "schemaVersion": 1, "macCatalyst": true, "appHosted": false,
            "inputSHA256": expectedHash, "inputBytes": data.count,
            "inputPixels": [8000, 6000], "inputEXIFOrientation": 6,
            "caseOrder": [1800, 2400], "casesRun": rows.count,
            "caseRows": rows, "passed": passed,
            "processSeconds": ProcessInfo.processInfo.systemUptime - started,
            "ruMaxRSSAtStartRaw": initialRSS, "ruMaxRSSAfterInputRaw": inputRSS,
            "ruMaxRSSAtEndRaw": peakRSSRaw(),
            "resourceLimit": "Separate decode process: raw peak includes input read and both serial API calls, not generator or compiler; not decoder-only memory."
        ]
        try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
            .write(to: report, options: .withoutOverwriting)
        if !passed { exit(1) }
    }
}
