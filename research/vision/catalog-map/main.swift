// Build from the repository root:
// swiftc MealMirror.swiftpm/MealCore/MealModels.swift research/vision/catalog-map/main.swift -o /tmp/vision-catalog-map
// /tmp/vision-catalog-map /path/to/vision-labels.jsonl
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

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: vision-catalog-map labels.jsonl\n", stderr)
    exit(2)
}

let lines = try String(contentsOfFile: CommandLine.arguments[1], encoding: .utf8)
    .split(separator: "\n")
var gateCounts: [String: Int] = [:]
var clueCounts: [String: Int] = [:]

for line in lines {
    let record = try JSONDecoder().decode(Record.self, from: Data(line.utf8))
    let group = String(record.image.split(separator: "-").first ?? "unknown")
    guard record.foodConfidence >= 0.10 else { continue }
    gateCounts[group, default: 0] += 1

    let names = record.labels
        .filter { $0.confidence >= 0.08 }
        .prefix(12)
        .map { label in
            String(label.name.split(separator: ",").last ?? "")
                .replacingOccurrences(of: "_", with: " ")
        }
    let mapped = MealIngredientCatalog.components(matching: names.joined(separator: " "))
    if !mapped.isEmpty {
        clueCounts[group, default: 0] += 1
    }
}

print("Food gate by filename group: \(gateCounts)")
print("At least one local food clue: \(clueCounts)")
