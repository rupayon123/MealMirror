import Foundation
import Vision
import CoreML

// Research only: call runVisionProbe() from the copied app's root .task.
// The copied package contains the three image resources used here.
func runVisionProbe() async {
    guard #available(iOS 18.0, *) else { return }
    var report: [String: [String: [String]]] = [:]
    for name in ["biryani-demo", "grain-bowl-demo", "breakfast-demo"] {
        guard let url = Bundle.module.url(forResource: name, withExtension: "png") else {
            report[name] = ["error": ["missing image"]]
            continue
        }
        var variants: [String: [String]] = [:]
        do {
            let request = ClassifyImageRequest()
            let results = try await request.perform(on: url)
            variants["default"] = Array(results.prefix(8)).map { "\($0.identifier):\($0.confidence)" }
        } catch {
            variants["default"] = ["error: \(error)"]
        }
        do {
            var request = ClassifyImageRequest()
            if let cpu = MLComputeDevice.allComputeDevices.first(where: {
                if case .cpu = $0 { true } else { false }
            }) {
                request.setComputeDevice(cpu, for: .main)
            }
            let results = try await request.perform(on: url)
            variants["cpu"] = Array(results.prefix(8)).map { "\($0.identifier):\($0.confidence)" }
        } catch {
            variants["cpu"] = ["error: \(error)"]
        }
        report[name] = variants
    }
    do {
        let data = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("new-vision-probe.json")
        try data.write(to: path)
    } catch {
        print("Vision probe write failed: \(error)")
    }
}
