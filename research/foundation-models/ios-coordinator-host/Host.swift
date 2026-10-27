import Foundation
import UIKit
import SwiftUI
import Darwin

private struct CombinedDiagnostic {
    @MainActor static func run() async throws {
        let output = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard !FileManager.default.fileExists(atPath: output.appendingPathComponent("results.json").path) else { fatalError("Refusing overwrite") }
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 50) { exit(124) }
        guard let meal = UIImage(contentsOfFile: Bundle.main.url(forResource: "grain-bowl-demo", withExtension: "png")!.path) else { fatalError("Demo unavailable") }
        let format = UIGraphicsImageRendererFormat(); format.scale = 1; format.opaque = true
        let labelLines = ["NUTRITION FACTS", "Total Carbohydrate 37 g", "per serving"]
        let label = UIGraphicsImageRenderer(size: CGSize(width: 1100, height: 320), format: format).image { context in
            UIColor.white.setFill(); context.fill(CGRect(x: 0, y: 0, width: 1100, height: 320))
            for (index, line) in labelLines.enumerated() {
                (line as NSString).draw(at: CGPoint(x: 30, y: 20 + index * 56), withAttributes: [.font: UIFont.systemFont(ofSize: 36), .foregroundColor: UIColor.black])
            }
        }
        try label.pngData()!.write(to: output.appendingPathComponent("synthetic-label.png"), options: .withoutOverwriting)
        let started = ProcessInfo.processInfo.systemUptime
        let result = await MealAnalysisEngine().analyze(source: .personalPhoto, demoMeal: DemoMeal.library[0], description: "rice", referenceItemPresent: false, foodImages: [meal, meal, meal], labelImage: label, language: .english)
        var lines: [String] = []
        if case let .read(value) = result.labelTextStatus { lines = value }
        let checks: [String: Bool] = [
            "englishCatalogLoaded": LocalizationCatalog.shared.hasCompleteEnglishTable,
            "actualLocalModelUsed": result.photoAI.usedLocalModel,
            "nameCluesWithinLimit": result.photoAI.names.count <= 6,
            "separateLabelExactOCR": lines == labelLines,
            "descriptionMatchedExcludedReference": !result.components.isEmpty && result.components.allSatisfy { !$0.isIncluded },
            "nothingAutomaticallyIncluded": result.includedComponents.isEmpty,
            "noAutomaticCarbohydrateTotal": result.overallRange == nil,
            "sourceIsPersonalPhoto": result.source == .personalPhoto
        ]
        let report: [String: Any] = ["iOSSimulator": true, "appHosted": true, "seconds": ProcessInfo.processInfo.systemUptime - started,
            "checks": checks, "allChecksPassed": checks.values.allSatisfy { $0 }, "names": result.photoAI.names,
            "labelText": lines, "labelStatus": String(describing: result.labelTextStatus), "photoStatus": String(describing: result.photoAI), "visionStatus": String(describing: result.visionStatus), "componentNames": result.components.map(\.name), "includedCount": result.includedComponents.count,
            "hasTotal": result.overallRange != nil, "methodNote": result.methodNote,
            "scope": "Actual coordinator/model/OCR; exposed repeated demo and procedural label. Not UI, camera/picker, independent accuracy, physical offline or dose validation."]
        try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]).write(to: output.appendingPathComponent("results.json"), options: .withoutOverwriting)
        print(String(data: try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys]), encoding: .utf8)!)
        exit(checks.values.allSatisfy { $0 } ? 0 : 1)
    }
}

@main private struct EngineDiagnosticApp: App {
    var body: some Scene {
        WindowGroup { DiagnosticView() }
    }
}
private struct DiagnosticView: View {
    @State private var started = false
    var body: some View {
        Text("MealMirror engine diagnostic")
            .task {
                guard !started else { return }
                started = true
                do { try await CombinedDiagnostic.run() }
                catch { print("Diagnostic harness error: \(error)"); exit(2) }
            }
    }
}
