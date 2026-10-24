// Run through verify-photo-preparation.py. That driver extracts the ACTUAL
// MealPhotoPreparation enum into an external output folder before compilation.
// This file contains only procedural fixtures, reference drawing and assertions.
// Four corner samples do not establish full pixel equivalence or marker coverage.
import CoreImage
import Darwin
import Foundation
import UIKit

private func fixtureBitmap() -> CGImage {
    let width = 1_920, height = 1_280
    let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
        bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0.91, 0.13, 0.07), (0.04, 0.81, 0.27), (0.08, 0.21, 0.93), (0.96, 0.77, 0.04)
    ]
    for index in 0..<4 {
        let color = colors[index]
        context.setFillColor(red: color.0, green: color.1, blue: color.2, alpha: 1)
        context.fill(CGRect(x: (index % 2) * width / 2, y: (index / 2) * height / 2,
                           width: width / 2, height: height / 2))
    }
    context.setFillColor(red: 0.6, green: 0.12, blue: 0.72, alpha: 1)
    context.fill(CGRect(x: CGFloat(width) * 0.31, y: CGFloat(height) * 0.43,
                       width: CGFloat(width) * 0.07, height: CGFloat(height) * 0.13))
    return context.makeImage()!
}

private func normalizedCorners(_ image: UIImage) -> [[Int]] {
    let factor: CGFloat = 240 / max(image.size.width, image.size.height)
    let size = CGSize(width: max(1, (image.size.width * factor).rounded()),
                      height: max(1, (image.size.height * factor).rounded()))
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    format.opaque = false
    let rendered = UIGraphicsImageRenderer(size: size, format: format).image {
        _ in image.draw(in: CGRect(origin: .zero, size: size))
    }.cgImage!
    let width = rendered.width, height = rendered.height
    var bytes = [UInt8](repeating: 0, count: width * height * 4)
    bytes.withUnsafeMutableBytes { raw in
        let context = CGContext(data: raw.baseAddress, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.draw(rendered, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    return [(0.1, 0.1), (0.9, 0.1), (0.1, 0.9), (0.9, 0.9)].map { point in
        let offset = (min(height - 1, Int(Double(height) * point.1)) * width
                      + min(width - 1, Int(Double(width) * point.0))) * 4
        return Array(bytes[offset..<offset + 4]).map(Int.init)
    }
}

private func geometryObservation(_ output: UIImage?, reference: UIImage, scale: CGFloat,
                                 orientation: UIImage.Orientation, limit: Int) -> [String: Any] {
    guard let output, let cg = output.cgImage else { return ["outcome": "nil", "passed": false] }
    let finiteSize = output.size.width.isFinite && output.size.height.isFinite
        && output.size.width > 0 && output.size.height > 0
    guard finiteSize else { return ["outcome": "invalidDisplaySize", "passed": false] }
    let expected = normalizedCorners(reference)
    let actual = normalizedCorners(output)
    let difference = zip(expected, actual).flatMap { zip($0.0, $0.1).map { abs($0 - $1) } }.max()!
    let opaque = expected.allSatisfy { $0[3] == 255 } && actual.allSatisfy { $0[3] == 255 }
    let distinctness = (0..<4).flatMap { first in
        ((first + 1)..<4).map { second in
            zip(expected[first], expected[second]).map { abs($0 - $1) }.max()!
        }
    }.min()!
    let aspectDifference = abs(output.size.width / output.size.height - reference.size.width / reference.size.height)
    let bound = max(cg.width, cg.height) <= limit && min(cg.width, cg.height) > 0
    let metadata = output.scale == scale && output.imageOrientation == orientation
    return ["outcome": "prepared", "outputPixels": [cg.width, cg.height],
        "outputScale": output.scale, "outputOrientationRawValue": output.imageOrientation.rawValue,
        "pixelBoundSatisfied": bound, "scaleAndOrientationPreserved": metadata,
        "displayAspectDifference": aspectDifference, "expectedCorners": expected,
        "actualCorners": actual, "maxCornerComponentDifference": difference,
        "referenceMinPairwiseCornerDifference": distinctness, "cornersOpaque": opaque,
        "passed": bound && metadata && aspectDifference <= 0.005
            && opaque && distinctness >= 64 && difference <= 12]
}

@MainActor
@main
private struct VerifyPhotoPreparation {
    static func main() throws {
        guard CommandLine.arguments.count == 2 else { fatalError("A new report path is required") }
        let url = URL(fileURLWithPath: CommandLine.arguments[1])
        guard !FileManager.default.fileExists(atPath: url.path) else { fatalError("Refusing to overwrite a report") }
        // Bounds this isolated test process only; no app or model deadline claim.
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 20) { exit(124) }
        let base = fixtureBitmap()
        let origins: [(String, CGPoint)] = [
            ("zero", .zero), ("integer", CGPoint(x: 100, y: -50)),
            ("positiveFraction", CGPoint(x: 100.25, y: 50.5)),
            ("negativeFraction", CGPoint(x: -100.25, y: -50.5))
        ]
        var geometry: [[String: Any]] = []
        var callerLimits: [[String: Any]] = []
        var scales: [[String: Any]] = []
        var invalidInputs: [[String: Any]] = []

        for (id, origin) in origins {
            for rawOrientation in 0...7 {
                let orientation = UIImage.Orientation(rawValue: rawOrientation)!
                for scale: CGFloat in [1, 2] {
                    let row: [String: Any] = autoreleasepool {
                        let ci = CIImage(cgImage: base).transformed(by: CGAffineTransform(translationX: origin.x, y: origin.y))
                        let input = UIImage(ciImage: ci, scale: scale, orientation: orientation)
                        let reference = UIImage(cgImage: base, scale: scale, orientation: orientation)
                        return ["originID": id, "actualCIExtent": NSCoder.string(for: ci.extent),
                            "inputScale": scale, "inputOrientationRawValue": rawOrientation, "maxPixelSize": 768,
                            "result": geometryObservation(MealPhotoPreparation.downsampledImage(from: input, maxPixelSize: 768),
                                reference: reference, scale: scale, orientation: orientation, limit: 768)]
                    }
                    geometry.append(row)
                }
            }
        }
        // Exercise the actual meal and label caller bounds without inferring
        // untested performance or repeating the whole orientation matrix.
        for (id, origin) in [origins[0], origins[3]] {
            for limit in [1_800, 2_400] {
                let row: [String: Any] = autoreleasepool {
                    let ci = CIImage(cgImage: base).transformed(by: CGAffineTransform(translationX: origin.x, y: origin.y))
                    let input = UIImage(ciImage: ci, scale: 2, orientation: .leftMirrored)
                    let reference = UIImage(cgImage: base, scale: 2, orientation: .leftMirrored)
                    return ["originID": id, "inputScale": 2, "inputOrientationRawValue": 6, "maxPixelSize": limit,
                        "result": geometryObservation(MealPhotoPreparation.downsampledImage(from: input, maxPixelSize: CGFloat(limit)),
                            reference: reference, scale: 2, orientation: .leftMirrored, limit: limit)]
                }
                callerLimits.append(row)
            }
        }
        for backing in ["CI", "CG"] {
            for (name, requested): (String, CGFloat) in [
                ("zero", 0), ("negative", -1), ("nan", .nan), ("infinity", .infinity)
            ] {
                let input = backing == "CI"
                    ? UIImage(ciImage: CIImage(cgImage: base), scale: requested, orientation: .up)
                    : UIImage(cgImage: base, scale: requested, orientation: .up)
                let output = MealPhotoPreparation.downsampledImage(from: input, maxPixelSize: 32)
                let invalidActualScale = !input.scale.isFinite || input.scale <= 0
                let validOutput = output.map {
                    $0.scale.isFinite && $0.scale > 0 && $0.scale == input.scale
                        && max($0.cgImage?.width ?? Int.max, $0.cgImage?.height ?? Int.max) <= 32
                } ?? false
                scales.append(["backing": backing, "requestedScale": name,
                    "actualInputScaleText": String(describing: input.scale),
                    "actualOutputScaleText": output.map { String(describing: $0.scale) } ?? "nil",
                    "actualScaleIsInvalid": invalidActualScale, "returnedNil": output == nil,
                    "passed": invalidActualScale ? output == nil : validOutput])
            }
        }
        for (id, ci) in [("infiniteCIExtent", CIImage(color: CIColor(red: 0.5, green: 0.2, blue: 0.1))),
                         ("emptyCIExtent", CIImage.empty())] {
            let input = UIImage(ciImage: ci, scale: 1, orientation: .up)
            let output = MealPhotoPreparation.downsampledImage(from: input, maxPixelSize: 768)
            invalidInputs.append(["id": id, "returnedNil": output == nil, "passed": output == nil])
        }
        let invalidData = MealPhotoPreparation.downsampledImage(from: Data([0, 1, 2, 3]))
        invalidInputs.append(["id": "invalidImageData", "returnedNil": invalidData == nil, "passed": invalidData == nil])
        for (id, limit): (String, CGFloat) in [("zero", 0), ("negative", -1), ("nan", .nan), ("infinity", .infinity)] {
            let input = UIImage(ciImage: CIImage(cgImage: base), scale: 1, orientation: .up)
            let output = MealPhotoPreparation.downsampledImage(from: input, maxPixelSize: limit)
            invalidInputs.append(["id": "invalidLimit-" + id, "returnedNil": output == nil, "passed": output == nil])
        }
        let geometryFailures = geometry.filter { ($0["result"] as! [String: Any])["passed"] as? Bool != true }.count
        let callerFailures = callerLimits.filter { ($0["result"] as! [String: Any])["passed"] as? Bool != true }.count
        let scaleFailures = scales.filter { $0["passed"] as? Bool != true }.count
        let invalidFailures = invalidInputs.filter { $0["passed"] as? Bool != true }.count
        let failures = geometryFailures + callerFailures + scaleFailures + invalidFailures
        let report: [String: Any] = ["schemaVersion": 1, "phase": "completed", "systemVersion": UIDevice.current.systemVersion,
            "scope": "Actual source-derived direct iOS Simulator preparation checks. Four orientation-aware reference corner samples, aspect, scale, bounds and malformed-input behavior only. No full-pixel/marker equivalence, real-camera, UI, physical-device, decoder-performance, offline-isolation or model accuracy claim.",
            "geometryCaseCount": geometry.count, "callerLimitCaseCount": callerLimits.count,
            "malformedScaleCaseCount": scales.count, "invalidInputCaseCount": invalidInputs.count,
            "failureCount": failures, "geometry": geometry, "callerLimits": callerLimits,
            "malformedScales": scales, "invalidInputs": invalidInputs]
        try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]).write(to: url, options: .atomic)
        print("Photo preparation: \(geometry.count) geometry, \(callerLimits.count) caller limits, \(scales.count) scales, \(invalidInputs.count) invalid inputs; \(failures) failures")
        if failures != 0 { exit(1) }
    }
}
