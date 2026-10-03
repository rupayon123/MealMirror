import Foundation
import UIKit

// Research only. Run in a copied package with a deliberate two-second pause
// after VisionContinuationGate registers its request.
func runVisionCancellationProbe() async {
    guard let url = Bundle.module.url(forResource: "biryani-demo", withExtension: "png"),
          let image = UIImage(contentsOfFile: url.path) else { return }

    let task = Task { await VisionPhotoInspector.inspect(image) }
    try? await Task.sleep(for: .milliseconds(100))
    let cancellationTime = Date()
    task.cancel()
    let result = await task.value
    let elapsed = Date().timeIntervalSince(cancellationTime)
    let report: [String: Any] = [
        "status": String(describing: result),
        "secondsAfterCancellation": elapsed,
        "injectedRequestDelaySeconds": 2.0
    ]
    do {
        let data = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("vision-cancellation-probe.json")
        try data.write(to: path)
    } catch {
        print("Vision cancellation probe write failed: \(error)")
    }
}
