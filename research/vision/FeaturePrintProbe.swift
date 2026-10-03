import Foundation
import Vision
import CoreML

// Research only. Run from a copied app package, never the Challenge candidate.
func runFeaturePrintProbe() {
    let names = ["biryani-demo", "grain-bowl-demo", "breakfast-demo"]
    var prints: [String: VNFeaturePrintObservation] = [:]
    var failures: [String: String] = [:]

    for name in names {
        guard let url = Bundle.module.url(forResource: name, withExtension: "png") else {
            failures[name] = "missing image"
            continue
        }
        let request = VNGenerateImageFeaturePrintRequest()
        if let devices = try? request.supportedComputeStageDevices,
           let cpu = devices[.main]?.first(where: {
               if case .cpu = $0 { true } else { false }
           }) {
            request.setComputeDevice(cpu, for: .main)
        }
        do {
            try VNImageRequestHandler(url: url).perform([request])
            if let observation = request.results?.first {
                prints[name] = observation
            } else {
                failures[name] = "no feature print"
            }
        } catch {
            failures[name] = String(describing: error)
        }
    }

    var distances: [String: Double] = [:]
    for left in names {
        for right in names {
            guard let leftPrint = prints[left], let rightPrint = prints[right] else { continue }
            do {
                var distance: Float = 0
                try leftPrint.computeDistance(&distance, to: rightPrint)
                distances["\(left)|\(right)"] = Double(distance)
            } catch {
                failures["\(left)|\(right)"] = String(describing: error)
            }
        }
    }

    let report: [String: Any] = ["distances": distances, "failures": failures]
    do {
        let data = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("feature-print-probe.json")
        try data.write(to: path)
    } catch {
        print("Feature-print probe write failed: \(error)")
    }
}
