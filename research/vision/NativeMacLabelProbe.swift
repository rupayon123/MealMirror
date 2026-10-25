import Foundation
import CoreGraphics
import ImageIO
import Vision
import Darwin
struct UIImage: @unchecked Sendable {
    let cgImage: CGImage?
    let imageOrientation: Orientation
    enum Orientation { case up, upMirrored, down, downMirrored, left, leftMirrored, right, rightMirrored }
}
enum LabelTextStatus: Hashable, Sendable {
    case notRun
    case read(lines: [String])
    case unavailable
}
enum VisionLabelInspector {
    static func inspect(_ image: UIImage) async -> LabelTextStatus {
        guard let cgImage = image.cgImage else { return .unavailable }
        let cancellation = VisionCancellationLatch<LabelTextStatus>()
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                let gate = VisionContinuationGate(continuation: continuation, fallback: .unavailable)
                guard cancellation.register(gate) else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
                    gate.cancelAndResume()
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    let request = VNRecognizeTextRequest { request, error in
                        guard error == nil else {
                            gate.resume(with: .unavailable)
                            return
                        }
                        let lines = (request.results ?? [])
                            .compactMap { $0 as? VNRecognizedTextObservation }
                            .compactMap { $0.topCandidates(1).first?.string.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                        gate.resume(with: .read(lines: Array(lines.prefix(24))))
                    }
                    request.recognitionLevel = .accurate
                    request.automaticallyDetectsLanguage = true
                    request.usesLanguageCorrection = false
                    guard gate.register(request) else { return }
                    let handler = VNImageRequestHandler(
                        cgImage: cgImage,
                        orientation: image.imageOrientation.cgImagePropertyOrientation,
                        options: [:]
                    )
                    do {
                        try handler.perform([request])
                    } catch {
                        gate.resume(with: .unavailable)
                    }
                }
            }
        } onCancel: {
            cancellation.cancel()
        }
    }
}

private final class VisionCancellationLatch<Result: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var gate: VisionContinuationGate<Result>?
    private var isCancelled = false
    private let didCancel: (@Sendable () -> Void)?

    init(didCancel: (@Sendable () -> Void)? = nil) {
        self.didCancel = didCancel
    }

    func register(_ newGate: VisionContinuationGate<Result>) -> Bool {
        lock.lock()
        let shouldStart = !isCancelled
        if shouldStart { gate = newGate }
        lock.unlock()
        if !shouldStart, newGate.cancelAndResume() { didCancel?() }
        return shouldStart
    }

    func cancel() {
        lock.lock()
        isCancelled = true
        let currentGate = gate
        gate = nil
        lock.unlock()
        if currentGate?.cancelAndResume() == true { didCancel?() }
    }
}

private final class VisionContinuationGate<Result: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Result, Never>?
    private var request: VNRequest?
    private let fallback: Result

    init(continuation: CheckedContinuation<Result, Never>, fallback: Result) {
        self.continuation = continuation
        self.fallback = fallback
    }

    @discardableResult
    func resume(with result: Result) -> Bool {
        lock.lock()
        let currentContinuation = continuation
        continuation = nil
        request = nil
        lock.unlock()
        currentContinuation?.resume(returning: result)
        return currentContinuation != nil
    }

    func register(_ newRequest: VNRequest) -> Bool {
        lock.lock()
        let isPending = continuation != nil
        if isPending { request = newRequest }
        lock.unlock()
        if !isPending { newRequest.cancel() }
        return isPending
    }

    @discardableResult
    func cancelAndResume() -> Bool {
        lock.lock()
        let currentContinuation = continuation
        let currentRequest = request
        continuation = nil
        request = nil
        lock.unlock()
        currentRequest?.cancel()
        currentContinuation?.resume(returning: fallback)
        return currentContinuation != nil
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

@main private struct NativeLabelCase {
    static func main() async throws {
        guard CommandLine.arguments.count == 2 else { exit(64) }
        let out = URL(fileURLWithPath: CommandLine.arguments[1])
        let input = out.appendingPathComponent("label.png")
        guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
            let cg = CGImageSourceCreateImageAtIndex(source, 0, nil) else { exit(65) }
        DispatchQueue.global().asyncAfter(deadline: .now() + 25) { exit(124) }
        let started = ProcessInfo.processInfo.systemUptime
        let status = await VisionLabelInspector.inspect(UIImage(cgImage: cg, imageOrientation: .up))
        let elapsed = ProcessInfo.processInfo.systemUptime - started
        var lines: [String] = []
        var kind = "unavailable"
        switch status { case .read(let value): kind = "read"; lines = value
            case .notRun: kind = "notRun"; case .unavailable: break }
        let expected = ["NUTRITION FACTS", "Total Carbohydrate 37 g", "per serving"]
        let checks = ["read": kind == "read", "exactText": lines == expected]
        let passed = checks.values.allSatisfy { $0 }
        let result: [String: Any] = ["status": kind, "lines": lines, "seconds": elapsed,
            "checks": checks, "passed": passed, "platform": "native macOS UIImage adapter; actual Vision OCR, not UIKit/iOS/app-host proof"]
        try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
            .write(to: out.appendingPathComponent("result.json"), options: .withoutOverwriting)
        exit(passed ? 0 : 1)
    }
}
