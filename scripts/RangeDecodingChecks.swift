import Foundation

/// Portable model checks, not iOS storage, UI or clinical validation.
@main
struct RangeDecodingChecks {
    static func main() throws {
        var checks = 0
        var failures: [String] = []
        func check(_ name: String, _ condition: @autoclosure () -> Bool) {
            checks += 1
            if !condition() { failures.append(name) }
        }

        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let invalid = [
            "negative lower": "{\"low\":-10,\"high\":5}",
            "both negative": "{\"low\":-10,\"high\":-5}",
            "negative upper": "{\"low\":0,\"high\":-1}",
            "reversed": "{\"low\":40,\"high\":10}",
            "missing lower": "{\"high\":37}",
            "missing upper": "{\"low\":37}",
            "null lower": "{\"low\":null,\"high\":37}",
            "null upper": "{\"low\":37,\"high\":null}",
            "string lower": "{\"low\":\"37\",\"high\":40}",
            "fraction": "{\"low\":1.5,\"high\":40}",
            "overflow": "{\"low\":0,\"high\":9223372036854775808}",
            "partial": "{\"low\":37,\"high\":"
        ]
        for (name, text) in invalid {
            do {
                _ = try decoder.decode(CarbRange.self, from: Data(text.utf8))
                check("reject \(name)", false)
            } catch is DecodingError {
                check("reject \(name)", true)
            } catch {
                check("decoding error for \(name)", false)
            }
        }

        for (low, high) in [(0, 0), (0, 37), (37, 37), (12, 48), (Int.max - 1, Int.max)] {
            let text = "{\"low\":\(low),\"high\":\(high)}"
            let range = try decoder.decode(CarbRange.self, from: Data(text.utf8))
            check("valid existing bounds \(low)...\(high)", range.low == low && range.high == high)
            let encoded = try encoder.encode(range)
            let object = try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
            check("existing two-key wire format", Set(object?.keys.map { $0 } ?? []) == ["low", "high"])
            let roundTrip = try decoder.decode(CarbRange.self, from: encoded)
            check("valid round trip", roundTrip == range)
        }

        // Every allowed manual whole-gram value remains representable and stable.
        for grams in 0...500 {
            let range = CarbRange(low: grams, high: grams)
            let encoded = try encoder.encode(range)
            let roundTrip = try decoder.decode(CarbRange.self, from: encoded)
            check("manual value round trip \(grams)", roundTrip == range)
        }

        check("constructor normalization unchanged", CarbRange(low: -5, high: -1) == CarbRange(low: 0, high: 0))
        check("constructor ordering unchanged", CarbRange(low: 40, high: 10) == CarbRange(low: 40, high: 40))
        check("empty total unchanged", CarbRange.total(of: []) == nil)
        check("valid totals unchanged", CarbRange.total(of: [CarbRange(low: 2, high: 5), CarbRange(low: 3, high: 8)]) == CarbRange(low: 5, high: 13))

        let report: [String: Any] = [
            "checks": checks, "passed": checks - failures.count, "failures": failures,
            "scope": "Production CarbRange model on macOS. Rejected malformed bounds and existing valid encoding only; not iOS storage, UI or clinical validation."
        ]
        let data = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
        print(String(decoding: data, as: UTF8.self))
        if !failures.isEmpty { exit(1) }
    }
}
