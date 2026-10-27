import Foundation
import UIKit
import FoundationModels
import Darwin

@MainActor private final class CompletionObservation { var completed = false }

@main private struct PhotoAIDiagnostic {
    @MainActor static func main() async throws {
        let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        guard !FileManager.default.fileExists(atPath: output.appendingPathComponent("results.json").path) else { fatalError("Refusing overwrite") }
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 50) { exit(124) }
        let model = SystemLanguageModel.default
        let format = UIGraphicsImageRendererFormat(); format.scale = 1; format.opaque = true
        let blank = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512), format: format).image { context in
            UIColor.white.setFill(); context.fill(CGRect(x: 0, y: 0, width: 512, height: 512))
        }
        guard let meal = UIImage(contentsOfFile: output.appendingPathComponent("Assets/grain-bowl-demo.png").path) else { fatalError("Demo fixture unavailable") }
        var rows: [[String: Any]] = []
        for (id, images) in [("empty", [UIImage]()), ("fourViewsRejected", [blank, blank, blank, blank]), ("exposedDemo", [meal]), ("syntheticBlank", [blank])] {
            let start = ProcessInfo.processInfo.systemUptime
            let result = await LocalPhotoAI.inspect(images, locale: Locale(identifier: "en_US"))
            let status: String
            let reason: String
            switch result {
            case .notRun: status = "notRun"; reason = ""
            case let .unavailable(value): status = "unavailable"; reason = value.rawValue
            case .inspected: status = "inspected"; reason = ""
            }
            rows.append(["id": id, "imageCount": images.count, "status": status, "reason": reason, "names": result.names, "seconds": ProcessInfo.processInfo.systemUptime - start])
        }
        let threeStart = ProcessInfo.processInfo.systemUptime
        let three = await LocalPhotoAI.inspect([meal, meal, meal], locale: Locale(identifier: "en_US"))
        let threeSeconds = ProcessInfo.processInfo.systemUptime - threeStart
        let observation = CompletionObservation()
        let requestStart = ProcessInfo.processInfo.systemUptime
        let pendingRequest = Task { @MainActor in
            let value = await LocalPhotoAI.inspect([meal], locale: Locale(identifier: "en_US"))
            observation.completed = true
            return value
        }
        try await Task.sleep(for: .milliseconds(200))
        let wasPendingAtCancellation = !observation.completed
        let cancelStart = ProcessInfo.processInfo.systemUptime
        pendingRequest.cancel()
        let cancelled = await pendingRequest.value
        let cancelSeconds = ProcessInfo.processInfo.systemUptime - cancelStart
        let cancellation: [String: Any] = ["requestPendingAtCancellation": wasPendingAtCancellation,
            "beforeCancelSeconds": cancelStart - requestStart, "cancelToReturnSeconds": cancelSeconds,
            "status": String(describing: cancelled), "names": cancelled.names,
            "scope": "Caller return only; underlying Apple worker termination is not observed."]
        let threeViews: [String: Any] = ["input": "Three identical exposed demo images, not different camera views",
            "status": String(describing: three), "names": three.names, "seconds": threeSeconds]
        let report: [String: Any] = ["macCatalyst": true, "appHosted": false, "modelAvailability": String(describing: model.availability), "modelCapabilities": String(describing: model.capabilities), "rows": rows, "threeDuplicateViews": threeViews, "cancellation": cancellation, "scope": "Diagnostic only; exposed/synthetic inputs, no semantic accuracy acceptance or physical offline proof."]
        try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]).write(to: output.appendingPathComponent("results.json"), options: .withoutOverwriting)
        print(String(data: try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys]), encoding: .utf8)!)
    }
}
