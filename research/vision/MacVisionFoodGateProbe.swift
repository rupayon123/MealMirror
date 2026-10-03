// Research-only macOS probe. Pass local image paths; it writes no photos.
// macOS Vision results cannot establish iPhone or iOS Simulator behavior.
import Foundation
import Vision

for path in CommandLine.arguments.dropFirst() {
    let request = VNClassifyImageRequest()
    let handler = VNImageRequestHandler(url: URL(fileURLWithPath: path))
    do {
        try handler.perform([request])
        let observations = request.results ?? []
        let foodConfidence = observations.first(where: { $0.identifier == "food" })?.confidence ?? 0
        let labels = observations.prefix(12).map {
            ["name": $0.identifier, "confidence": Double($0.confidence)] as [String: Any]
        }
        let row: [String: Any] = [
            "image": URL(fileURLWithPath: path).lastPathComponent,
            "foodConfidence": Double(foodConfidence),
            "labels": labels,
        ]
        let data = try JSONSerialization.data(withJSONObject: row, options: [.sortedKeys])
        print(String(decoding: data, as: UTF8.self))
    } catch {
        let row: [String: Any] = [
            "image": URL(fileURLWithPath: path).lastPathComponent,
            "error": String(describing: error),
        ]
        let data = try! JSONSerialization.data(withJSONObject: row)
        print(String(decoding: data, as: UTF8.self))
    }
}
