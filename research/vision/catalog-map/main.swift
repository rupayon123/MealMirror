// Build from the repository root:
// swiftc MealMirror.swiftpm/MealCore/MealModels.swift research/vision/catalog-map/main.swift -o /tmp/vision-catalog-map
// /tmp/vision-catalog-map /path/to/vision-labels.jsonl
// Add --details to print one JSON row per image with the offered clue IDs.
import Foundation

private struct Label: Decodable {
    let confidence: Double
    let name: String
}

private struct Record: Decodable {
    let foodConfidence: Double
    let image: String
    let labels: [Label]
}

private struct Detail: Encodable {
    let image: String
    let clueIDs: [String]
}

guard (CommandLine.arguments.count == 2 || CommandLine.arguments.count == 3),
      (CommandLine.arguments.count == 2 || CommandLine.arguments[2] == "--details") else {
    fputs("Usage: vision-catalog-map labels.jsonl [--details]\n", stderr)
    exit(2)
}
let showDetails = CommandLine.arguments.count == 3

let lines = try String(contentsOfFile: CommandLine.arguments[1], encoding: .utf8)
    .split(separator: "\n")
var gateCounts: [String: Int] = [:]
var clueCounts: [String: Int] = [:]

for line in lines {
    let record = try JSONDecoder().decode(Record.self, from: Data(line.utf8))
    let group = String(record.image.split(separator: "-").first ?? "unknown")
    guard record.foodConfidence >= 0.10 else {
        if showDetails {
            let row = Detail(image: record.image, clueIDs: [])
            print(String(decoding: try JSONEncoder().encode(row), as: UTF8.self))
        }
        continue
    }
    gateCounts[group, default: 0] += 1

    let names = record.labels
        .filter { $0.confidence >= 0.08 }
        .prefix(12)
        .map { label in
            String(label.name.split(separator: ",").last ?? "")
                .replacingOccurrences(of: "_", with: " ")
        }
    let mapped = MealIngredientCatalog.components(matchingLabels: names)
    if showDetails {
        let row = Detail(image: record.image, clueIDs: mapped.map(\.id))
        print(String(decoding: try JSONEncoder().encode(row), as: UTF8.self))
    }
    if !mapped.isEmpty {
        clueCounts[group, default: 0] += 1
    }
}

let summary = "Food gate by filename group: \(gateCounts)\nAt least one local food clue: \(clueCounts)\n"
if showDetails {
    fputs(summary, stderr)
} else {
    print(summary, terminator: "")
}
