// Real UIKit/ImageIO on Mac Catalyst, in a command-line process, NOT an app host.
// Ports the three prior hosted image cases with their same fixed expectations.
import CoreGraphics
import Darwin
import Foundation
import ImageIO
import UIKit

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
private struct EncodedCatalystChecks {
    @MainActor static func main() throws {
        #if !targetEnvironment(macCatalyst)
        fatalError("Requires real Mac Catalyst UIKit")
        #endif
        guard CommandLine.arguments.count == 3 else { fatalError("fixture directory and new report path required") }
        let fixtures = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let report = URL(fileURLWithPath: CommandLine.arguments[2])
        guard !FileManager.default.fileExists(atPath: report.path) else { fatalError("Refusing overwrite") }
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 20) { exit(124) }
        let started = ProcessInfo.processInfo.systemUptime
        var checks: [[String: Any]] = []
        func check(_ id: String, _ passed: Bool) { checks.append(["id": id, "passed": passed]) }
        func data(_ orientation: Int) throws -> Data {
            try Data(contentsOf: fixtures.appendingPathComponent("fixture-o\(orientation).jpeg"))
        }
        let input = try data(1)
        for limit in [-1, 0, 2_401] {
            check("limit.\(limit).nil", MealPhotoPreparation.downsampledImage(from: input, maxPixelSize: limit) == nil)
        }
        for (limit, width, height) in [(1, 1, 1), (40, 40, 30), (2_400, 320, 240)] {
            let image = MealPhotoPreparation.downsampledImage(from: input, maxPixelSize: limit)
            let pixels = image?.cgImage
            check("limit.\(limit).image", pixels != nil)
            check("limit.\(limit).width", pixels?.width == width)
            check("limit.\(limit).height", pixels?.height == height)
            check("limit.\(limit).bound", pixels.map { max($0.width, $0.height) <= limit } ?? false)
        }
        check("empty.nil", MealPhotoPreparation.downsampledImage(from: Data(), maxPixelSize: 1_800) == nil)
        check("truncated.nil", MealPhotoPreparation.downsampledImage(from: Data(input.prefix(16)), maxPixelSize: 1_800) == nil)
        let cases: [(Int, Int, Int, [String])] = [
            (2, 320, 240, ["yellow", "blue", "green", "red"]),
            (6, 240, 320, ["red", "blue", "green", "yellow"]),
            (8, 240, 320, ["yellow", "green", "blue", "red"])
        ]
        for (orientation, width, height, expected) in cases {
            let image = MealPhotoPreparation.downsampledImage(from: try data(orientation), maxPixelSize: 1_800)
            let pixels = image?.cgImage
            check("exif.\(orientation).image", pixels != nil)
            check("exif.\(orientation).width", pixels?.width == width)
            check("exif.\(orientation).height", pixels?.height == height)
            check("exif.\(orientation).up", image?.imageOrientation == .up)
            check("exif.\(orientation).scale", image?.scale == 1)
            check("exif.\(orientation).corners", pixels.flatMap { corners(of: $0) } == expected)
        }
        let failures = checks.filter { $0["passed"] as? Bool != true }.count
        var usage = rusage()
        let usageStatus = getrusage(RUSAGE_SELF, &usage)
        let result: [String: Any] = ["macCatalyst": true, "appHosted": false,
            "caseGroups": 3, "checkCount": checks.count, "failureCount": failures, "checks": checks,
            "seconds": ProcessInfo.processInfo.systemUptime - started,
            "rusageStatus": usageStatus, "ruMaxRSSRaw": usage.ru_maxrss]
        try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
            .write(to: report, options: .withoutOverwriting)
        if failures > 0 || checks.count != 35 { exit(1) }
    }
}
