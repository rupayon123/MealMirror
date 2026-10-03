// Research-only macOS probe. Pass local image paths; it prints JSON lines.
// Each view is 75% of the original width and height, anchored to a corner.
// macOS Vision outputs cannot establish physical iPhone behavior.
import Foundation
import ImageIO
import Vision

for path in CommandLine.arguments.dropFirst() {
    guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        continue
    }
    let width = image.width
    let height = image.height
    let cropWidth = width * 3 / 4
    let cropHeight = height * 3 / 4
    let views: [(String, CGRect)] = [
        ("top-left", CGRect(x: 0, y: 0, width: cropWidth, height: cropHeight)),
        ("top-right", CGRect(x: width - cropWidth, y: 0, width: cropWidth, height: cropHeight)),
        ("bottom-left", CGRect(x: 0, y: height - cropHeight, width: cropWidth, height: cropHeight)),
        ("bottom-right", CGRect(x: width - cropWidth, y: height - cropHeight, width: cropWidth, height: cropHeight)),
    ]
    for (view, rect) in views {
        guard let crop = image.cropping(to: rect) else { continue }
        let request = VNClassifyImageRequest()
        do {
            try VNImageRequestHandler(cgImage: crop).perform([request])
            let observations = request.results ?? []
            let row: [String: Any] = [
                "image": URL(fileURLWithPath: path).lastPathComponent,
                "view": view,
                "foodConfidence": Double(observations.first(where: { $0.identifier == "food" })?.confidence ?? 0),
                "labels": observations.prefix(12).map {
                    ["name": $0.identifier, "confidence": Double($0.confidence)]
                },
            ]
            let data = try JSONSerialization.data(withJSONObject: row, options: [.sortedKeys])
            print(String(decoding: data, as: UTF8.self))
        } catch {
            fputs("\(path) \(view): \(error)\n", stderr)
        }
    }
}
