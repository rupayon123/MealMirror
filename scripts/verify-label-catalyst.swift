// Synthetic text/blank fixtures. Actual inspector/gates appended by driver.
// Mac Catalyst API check, not an app host, device or worldwide label evaluation.
import Darwin
import Foundation
import UIKit

@main private struct LabelCatalystChecks {
    @MainActor static func image(lines: [String]) -> UIImage {
        let height = max(320, 40 + lines.count * 56)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: CGSize(width: 1100, height: height), format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1100, height: height))
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36), .foregroundColor: UIColor.black]
            for (index, line) in lines.enumerated() {
                (line as NSString).draw(at: CGPoint(x: 30, y: 20 + index * 56), withAttributes: attributes)
            }
        }
    }

    @MainActor static func main() async throws {
        #if !targetEnvironment(macCatalyst)
        fatalError("Requires real Mac Catalyst")
        #endif
        guard CommandLine.arguments.count == 2 else { fatalError("New output directory required") }
        let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let report = output.appendingPathComponent("results.json")
        guard !FileManager.default.fileExists(atPath: report.path) else { fatalError("Refusing overwrite") }
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 60) { exit(124) }
        let cases = ["label", "blank", "longLabel", "noPixelBacking"]
        var rows: [[String: Any]] = []
        var failed = false
        for id in cases {
            let text: [String] = switch id {
            case "label": ["NUTRITION FACTS", "Total Carbohydrate 37 g", "per serving"]
            case "longLabel": (1...28).map { String(format: "CHECK %02d", $0) }
            default: []
            }
            let input = id == "noPixelBacking" ? UIImage() : image(lines: text)
            // Preserve generated fixtures for inspection before consuming them.
            if let png = input.pngData() {
                try png.write(to: output.appendingPathComponent(id + ".png"), options: .withoutOverwriting)
            }
            let started = ProcessInfo.processInfo.systemUptime
            let status = await VisionLabelInspector.inspect(input)
            let elapsed = ProcessInfo.processInfo.systemUptime - started
            var checks: [[String: Any]] = []
            func check(_ name: String, _ passed: Bool) { checks.append(["id": name, "passed": passed]) }
            var observed: [String] = []
            var kind = "unavailable"
            switch status {
            case let .read(lines): observed = lines; kind = "read"
            case .notRun: kind = "notRun"
            case .unavailable: break
            }
            switch id {
            case "label":
                check("read", kind == "read")
                check("exactText", observed == text)
            case "blank":
                check("read", kind == "read")
                check("noText", observed.isEmpty)
            case "longLabel":
                check("read", kind == "read")
                check("cap24", observed.count == 24)
                check("first24Exact", observed == Array(text.prefix(24)))
            default:
                check("noCGImage", input.cgImage == nil)
                check("unavailable", kind == "unavailable")
            }
            let passed = checks.allSatisfy { $0["passed"] as? Bool == true }
            rows.append(["id": id, "status": kind, "lines": observed, "seconds": elapsed,
                "checks": checks, "passed": passed])
            if !passed { failed = true; break }
        }
        let result: [String: Any] = ["macCatalyst": true, "appHosted": false,
            "cases": rows, "failed": failed, "unrun": Array(cases.dropFirst(rows.count))]
        try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
            .write(to: report, options: .withoutOverwriting)
        if failed { exit(1) }
    }
}
