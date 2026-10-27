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
// Direct Mac Catalyst UIKit/ImageIO format diagnostic; no app or Simulator.
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
private struct EncodedFormatsCatalystProbe {
    @MainActor static func main() throws {
        #if !targetEnvironment(macCatalyst)
        fatalError("Requires real Mac Catalyst UIKit")
        #endif
        guard CommandLine.arguments.count == 6 else {
            fatalError("PNG, PNG SHA-256, HEIC, HEIC SHA-256, report path required")
        }
        let pngURL = URL(fileURLWithPath: CommandLine.arguments[1])
        let heicURL = URL(fileURLWithPath: CommandLine.arguments[3])
        let report = URL(fileURLWithPath: CommandLine.arguments[5])
        guard !FileManager.default.fileExists(atPath: report.path) else { fatalError("Refusing overwrite") }
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 30) { _exit(124) }
        let started = ProcessInfo.processInfo.systemUptime
        let initialRSS = peakRSSRaw()
        let expectedCorners = ["blue", "yellow", "red", "green"]
        let expectedLimits = [(1_800, 1_800, 1_350), (2_400, 2_400, 1_800)]
        let inputs = [("png", pngURL, CommandLine.arguments[2], "public.png"),
                      ("heic", heicURL, CommandLine.arguments[4], "public.heic")]
        var inputRows: [[String: Any]] = []
        var caseRows: [[String: Any]] = []
        var failed = false
        outer: for (name, url, expectedHash, expectedUTI) in inputs {
            let data = try Data(contentsOf: url)
            guard sha256(data) == expectedHash else { fatalError("Frozen \(name) SHA-256 mismatch") }
            if name == "png" {
                guard data.starts(with: [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]) else {
                    fatalError("PNG signature mismatch")
                }
            } else {
                guard data.count >= 12, String(data: data[4..<8], encoding: .ascii) == "ftyp" else {
                    fatalError("HEIC container signature mismatch")
                }
            }
            guard let source = CGImageSourceCreateWithData(data as CFData, nil),
                  let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
                  properties[kCGImagePropertyPixelWidth as String] as? Int == 3200,
                  properties[kCGImagePropertyPixelHeight as String] as? Int == 2400 else {
                fatalError("Input dimensions mismatch for \(name)")
            }
            let actualUTI = CGImageSourceGetType(source).map { $0 as String }
            guard actualUTI == expectedUTI else { fatalError("ImageIO type mismatch for \(name)") }
            let orientation = properties[kCGImagePropertyOrientation as String] as? Int
            guard orientation == nil || orientation == 1 else { fatalError("Input orientation mismatch for \(name)") }
            inputRows.append(["format": name, "sha256": expectedHash, "bytes": data.count,
                              "imageIOType": actualUTI ?? "", "pixels": [3200, 2400],
                              "sourceOrientation": orientation ?? 1,
                              "ruMaxRSSAfterInputRaw": peakRSSRaw()])
            for (limit, width, height) in expectedLimits {
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
                caseRows.append(["format": name, "limit": limit,
                                 "expectedPixels": [width, height],
                                 "actualPixels": pixels.map { [$0.width, $0.height] } ?? [],
                                 "expectedCorners": expectedCorners,
                                 "actualCorners": observedCorners ?? [],
                                 "checks": checks, "passed": passed,
                                 "apiSeconds": apiSeconds,
                                 "ruMaxRSSBeforeRaw": before, "ruMaxRSSAfterRaw": after])
                if !passed { failed = true; break outer }
            }
        }
        let passed = !failed && inputRows.count == 2 && caseRows.count == 4
            && caseRows.allSatisfy { $0["passed"] as? Bool == true }
        let result: [String: Any] = [
            "schemaVersion": 1, "macCatalyst": true, "appHosted": false,
            "formatOrder": ["png", "heic"], "limitOrderPerFormat": [1800, 2400],
            "inputRows": inputRows, "caseRows": caseRows, "passed": passed,
            "processSeconds": ProcessInfo.processInfo.systemUptime - started,
            "ruMaxRSSAtStartRaw": initialRSS, "ruMaxRSSAtEndRaw": peakRSSRaw(),
            "resourceLimit": "Single serial probe process; raw peak includes input reads and all API calls. Not per-case decoder allocation or iPhone memory acceptance."
        ]
        try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
            .write(to: report, options: .withoutOverwriting)
        if !passed { exit(1) }
    }
}
