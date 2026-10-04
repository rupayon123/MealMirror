@preconcurrency import Vision
import Foundation
import ImageIO
import UIKit
import MealCore

struct MealAnalysisEngine {
    func analyze(
        source: MealInputSource,
        demoMeal: DemoMeal,
        description: String,
        referenceItemPresent: Bool,
        image: UIImage?,
        language: AppLanguage
    ) async -> MealAnalysis {
        switch source {
        case .demo:
            return demoMeal.analysis(description: description, referenceItemPresent: referenceItemPresent)
        case .manual, .personalPhoto:
            let visionStatus: VisionStatus = if source == .personalPhoto {
                await VisionPhotoInspector.inspect(image)
            } else {
                .notRun
            }
            let catalog = LocalizationCatalog.shared
            let describedComponents = MealIngredientCatalog.components(
                matching: description,
                locale: language.locale,
                localizedKeyword: { catalog.text($0, language: language) }
            )
            .map { matched in
                var candidate = matched
                // A food word can be part of a negation or a different recipe
                // (for example, "no rice" or "apple pie"). A text match alone
                // must never create a carbohydrate total for a real meal.
                candidate.isIncluded = false
                return candidate
            }
            let describedIDs = Set(describedComponents.map(\.id))
            let visualLabels: [String] = if case let .inspected(labels) = visionStatus {
                labels
            } else {
                []
            }
            let photoClues = PhotoCluePolicy.components(
                matching: visualLabels,
                locale: language.locale,
                localizedKeyword: { catalog.text($0, language: language) }
            )
            let visualMatches = photoClues
            .filter { !describedIDs.contains($0.id) }
            .map { component in
                MealComponent(
                    id: component.id,
                    name: component.name,
                    detail: component.detail,
                    carbohydrates: component.baselineCarbohydrates,
                    symbol: component.symbol,
                    signal: "Possible photo match",
                    nameTreatment: component.nameTreatment,
                    detailTreatment: component.detailTreatment,
                    signalTreatment: .localizedCatalog,
                    portion: component.portion,
                    isIncluded: false
                )
            }
            // Vision's general-purpose classifier can return unrelated scene
            // labels for a meal photo. Keep those raw labels out of the review
            // trail; show only food names that mapped to a local food reference.
            let reviewVisionStatus: VisionStatus = switch visionStatus {
            case .notRun:
                .notRun
            case .unavailable:
                .unavailable
            case .inspected:
                .inspected(labels: photoClues.map(\.name))
            }
            let components = describedComponents + visualMatches
            let hasVisualMatches = !photoClues.isEmpty
            let methodNote: String
            if hasVisualMatches {
                methodNote = "On-device Vision suggested possible food names. Photo suggestions start excluded. Add only foods you recognize; the photo does not determine portions or carbohydrate values."
            } else if components.isEmpty {
                if case .unavailable = visionStatus {
                    methodNote = "Photo selected; inspection unavailable"
                } else {
                    methodNote = "Nothing matched a food in the local list yet. Add only foods you recognize or a trusted carbohydrate value."
                }
            } else {
                methodNote = "Add the foods you recognize to build an inspectable carbohydrate range."
            }
            return MealAnalysis(
                title: hasVisualMatches ? "Possible foods to check" : (components.isEmpty ? "Add a little more detail" : "Your meal review"),
                description: description,
                source: source,
                components: components,
                referenceItemPresent: referenceItemPresent,
                visionStatus: reviewVisionStatus,
                methodNote: methodNote,
                uncertaintyNote: hasVisualMatches
                    ? "A photo can miss hidden ingredients and cannot reliably establish a mixed dish, recipe, or serving size. Confirm each item and portion; check a trusted label or reference when available."
                    : components.isEmpty
                    ? "Add a verified carbohydrate amount from a package label or trusted source, go back and describe the meal in more detail, or choose an optional Practice meal."
                    : "Confirm whether each item belongs in the total, then choose the closest portion. These local reference ranges are a starting point—not a substitute for a product label or your own trusted carb-counting method."
            )
        }
    }
}

enum MealPhotoPreparation {
    static func downsampledImageAsync(from data: Data, maxPixelSize: Int = 1_800) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: downsampledImage(from: data, maxPixelSize: maxPixelSize))
            }
        }
    }

    static func downsampledImage(from data: Data, maxPixelSize: Int = 1_800) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: CFDictionary = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceShouldCacheImmediately: true
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    static func downsampledImage(from image: UIImage, maxPixelSize: CGFloat = 1_800) -> UIImage {
        image.preparingThumbnail(of: CGSize(width: maxPixelSize, height: maxPixelSize)) ?? image
    }

    static func downsampledImageAsync(from image: UIImage, maxPixelSize: CGFloat = 1_800) async -> UIImage {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: downsampledImage(from: image, maxPixelSize: maxPixelSize))
            }
        }
    }
}

enum VisionPhotoInspector {
    static func inspect(_ image: UIImage?) async -> VisionStatus {
        guard let image, let cgImage = image.cgImage else {
            #if DEBUG
            print("[MealMirror Vision] Image did not provide a CGImage.")
            #endif
            return .unavailable
        }

        let cancellation = VisionCancellationLatch()
        return await withTaskCancellationHandler {
            await performInspection(image: image, cgImage: cgImage, cancellation: cancellation)
        } onCancel: {
            cancellation.cancel()
        }
    }

    private static func performInspection(
        image: UIImage,
        cgImage: CGImage,
        cancellation: VisionCancellationLatch
    ) async -> VisionStatus {
        return await withCheckedContinuation { continuation in
            let gate = VisionContinuationGate(continuation: continuation)
            guard cancellation.register(gate) else { return }
            // Keep the meal flow usable if Vision never calls back. The gate
            // ignores a late result and cancels any still-running request.
            DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
                gate.cancelAndResume()
            }
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNClassifyImageRequest { request, error in
                    guard error == nil else {
                        #if DEBUG
                        if let error {
                            let nsError = error as NSError
                            print("[MealMirror Vision] Request callback failed: \(nsError.domain) (\(nsError.code)): \(error.localizedDescription)")
                        }
                        #endif
                        gate.resume(with: .unavailable)
                        return
                    }

                    let observations = (request.results ?? [])
                        .compactMap { $0 as? VNClassificationObservation }
#if targetEnvironment(simulator)
                    // iOS 26.5 Simulator returned this same scene sequence for
                    // three different bundled meal photos. Its GPU request also
                    // failed to create an Espresso context. Do not present this
                    // known broken result as a successful photo inspection.
                    let brokenSimulatorLabels = ["outdoor", "night_sky", "sky", "celestial_body", "moon"]
                    if Array(observations.prefix(5).map(\.identifier)) == brokenSimulatorLabels {
                        gate.resume(with: .unavailable)
                        return
                    }
#endif
                    // A scene label such as "apple" can describe an object or
                    // brand instead of a meal. Require Vision's broad food
                    // label before offering any ingredient clues. A clue
                    // still starts excluded from every carbohydrate total.
                    guard observations.contains(where: {
                        $0.identifier == "food" && $0.confidence >= 0.10
                    }) else {
                        gate.resume(with: .inspected(labels: []))
                        return
                    }
                    var seen = Set<String>()
                    let labels = observations
                        .filter { $0.confidence >= 0.08 }
                        .prefix(12)
                        .compactMap { observation -> String? in
                            let label = observation.identifier
                                .split(separator: ",")
                                .last
                                .map(String.init)?
                                .replacingOccurrences(of: "_", with: " ")
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            guard let label, !label.isEmpty,
                                  seen.insert(label.lowercased()).inserted else { return nil }
                            return label
                        }
                    gate.resume(with: .inspected(labels: labels))
                }
                guard gate.register(request) else { return }
#if targetEnvironment(simulator)
                // Ask Vision which devices support this request, then prefer
                // its CPU path in Simulator when one is available.
                if let supportedDevices = try? request.supportedComputeStageDevices,
                   let cpuDevice = supportedDevices[.main]?.first(where: {
                    if case .cpu = $0 { true } else { false }
                }) {
                    request.setComputeDevice(cpuDevice, for: .main)
                }
#endif

                let handler = VNImageRequestHandler(
                    cgImage: cgImage,
                    orientation: image.imageOrientation.cgImagePropertyOrientation,
                    options: [:]
                )

                do {
                    try handler.perform([request])
                } catch {
                    #if DEBUG
                    let nsError = error as NSError
                    print("[MealMirror Vision] Request execution failed: \(nsError.domain) (\(nsError.code)): \(error.localizedDescription)")
                    #endif
                    gate.resume(with: .unavailable)
                }
            }
        }
    }
}

private final class VisionCancellationLatch: @unchecked Sendable {
    private let lock = NSLock()
    private var gate: VisionContinuationGate?
    private var isCancelled = false

    func register(_ newGate: VisionContinuationGate) -> Bool {
        lock.lock()
        let shouldStart = !isCancelled
        if shouldStart { gate = newGate }
        lock.unlock()
        if !shouldStart { newGate.cancelAndResume() }
        return shouldStart
    }

    func cancel() {
        lock.lock()
        isCancelled = true
        let currentGate = gate
        gate = nil
        lock.unlock()
        currentGate?.cancelAndResume()
    }
}

private final class VisionContinuationGate: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<VisionStatus, Never>?
    private var request: VNRequest?

    init(continuation: CheckedContinuation<VisionStatus, Never>) {
        self.continuation = continuation
    }

    func resume(with result: VisionStatus) {
        lock.lock()
        let currentContinuation = continuation
        continuation = nil
        request = nil
        lock.unlock()
        currentContinuation?.resume(returning: result)
    }

    func register(_ newRequest: VNRequest) -> Bool {
        lock.lock()
        let isPending = continuation != nil
        if isPending { request = newRequest }
        lock.unlock()
        if !isPending { newRequest.cancel() }
        return isPending
    }

    func cancelAndResume() {
        lock.lock()
        let currentContinuation = continuation
        let currentRequest = request
        continuation = nil
        request = nil
        lock.unlock()
        currentRequest?.cancel()
        currentContinuation?.resume(returning: .unavailable)
    }
}

private extension UIImage.Orientation {
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
