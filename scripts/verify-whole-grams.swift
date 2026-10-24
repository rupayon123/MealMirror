// Compile from the repository root with the ACTUAL parser source:
// xcrun swiftc -swift-version 6 -parse-as-library \
//   MealMirror.swiftpm/MealCore/MealModels.swift scripts/verify-whole-grams.swift \
//   -o /tmp/mealmirror-verify-whole-grams
// /tmp/mealmirror-verify-whole-grams [optional-new-report.json]
// No copied parser, model, network, UI, device or storage implementation is used.
import Foundation

@main
private struct VerifyWholeGrams {
    static func main() throws {
        let localeIDs = ["en", "fr", "zh-Hans", "yue-Hant", "pa", "ur", "ta", "fil", "es", "ar", "fa", "hi", "pt", "gu", "bn", "ja", "ko", "hu"]
        let scripts: [(name: String, digits: String)] = [
            ("ASCII", "0123456789"), ("Arabic-Indic", "٠١٢٣٤٥٦٧٨٩"),
            ("Eastern Arabic-Indic", "۰۱۲۳۴۵۶۷۸۹"), ("Bengali", "০১২৩৪৫৬৭৮৯"),
            ("Devanagari", "०१२३४५६७८९"), ("Gujarati", "૦૧૨૩૪૫૬૭૮૯"),
            ("Gurmukhi", "੦੧੨੩੪੫੬੭੮੯"), ("Tamil", "௦௧௨௩௪௫௬௭௮௯"),
            ("Fullwidth", "０１２３４５６７８９")
        ]
        var count = 0
        var groupCounts: [String: Int] = [:]
        var failures: [[String: Any]] = []

        func expect(_ input: String, _ expected: Int?, locale: Locale, group: String,
                    allowedRange: ClosedRange<Int> = 0...500) {
            count += 1
            groupCounts[group, default: 0] += 1
            let actual = WholeGramParser.parse(input, locale: locale, allowedRange: allowedRange)
            if actual != expected {
                failures.append([
                    "group": group, "locale": locale.identifier, "input": input,
                    "expected": expected.map { $0 as Any } ?? NSNull(),
                    "actual": actual.map { $0 as Any } ?? NSNull()
                ])
            }
        }

        let invalidSyntax = [
            "", " ", "\t\n", "-1", "-0", "−1", "−0", "+37", "＋３７",
            "37.0", "37.5", "37,0", "37,5", "٣٧٫٠", "٣٧٫٥", "３７．０",
            "0,037", "0.037", "0 037", "0\u{00A0}037", "0\u{202F}037", "٠٬٠٣٧",
            "3e1", "3E1", "3.7e1", "37e0", "37E+0", "٣e١",
            "37.000000000000001", "37/2", "3 7", "3\t7", "3\n7",
            "37 g", "37abc", "٣٧ غ", "37%", "$37", "0x25", "37\u{0000}",
            "NaN", "nan", "Infinity", "inf", "∞", "三十七", "ⅩⅩⅩⅦ", "³⁷", "③⑦",
            "3\u{0301}7", "3\u{200B}7", "3\u{200C}7", "3\u{200D}7"
        ]
        // Representative directional marks, not a claim that a particular
        // iOS keyboard inserts them. The policy requires plain decimal digits:
        // silently removing invisible marks could hide a pasted input change.
        let directionalMarks = [
            "\u{061C}", "\u{200E}", "\u{200F}", "\u{202A}", "\u{202B}",
            "\u{202C}", "\u{202D}", "\u{202E}", "\u{2066}", "\u{2067}",
            "\u{2068}", "\u{2069}"
        ]

        for localeID in localeIDs {
            let locale = Locale(identifier: localeID)
            for script in scripts {
                let digits = Array(script.digits)
                func render(_ ascii: String) -> String {
                    String(ascii.map { digits[Int(String($0))!] })
                }
                for value in [0, 1, 9, 10, 37, 99, 100, 499, 500] {
                    expect(render(String(value)), value, locale: locale, group: "localized whole digits")
                }
                for input in [
                    " \t\n" + render("37") + "\r ",
                    "\u{00A0}" + render("37") + "\u{00A0}",
                    "\u{202F}" + render("37") + "\u{202F}",
                    render("00037")
                ] {
                    expect(input, 37, locale: locale, group: "outer whitespace or leading zeroes")
                }
                expect(render("501"), nil, locale: locale, group: "localized above range")
                expect(render("999999999999999999999999999999999999999999"), nil,
                       locale: locale, group: "localized overflow")
            }

            // Decimal scripts may be mixed; each scalar is still an explicit
            // base-ten decimal digit. No digit script is treated as ASCII text.
            for input in ["٣7", "৩۷", "０३৭", "𝟛𝟟"] {
                expect(input, 37, locale: locale, group: "mixed or supplementary decimal digits")
            }
            for input in invalidSyntax {
                expect(input, nil, locale: locale, group: "non-whole syntax")
            }
            for mark in directionalMarks {
                for input in [mark + "٣٧", "٣٧" + mark, "٣" + mark + "٧"] {
                    expect(input, nil, locale: locale, group: "directional marks rejected")
                }
            }
            for input in ["9223372036854775807", "9223372036854775808", String(repeating: "9", count: 4_096)] {
                expect(input, nil, locale: locale, group: "long or overflowing number")
            }
            expect(String(repeating: "0", count: 32) + "37", 37,
                   locale: locale, group: "long leading zeroes")
            expect("37", 37, locale: locale, group: "custom allowed range", allowedRange: 37...37)
            expect("36", nil, locale: locale, group: "custom allowed range", allowedRange: 37...37)
            expect("38", nil, locale: locale, group: "custom allowed range", allowedRange: 37...37)

            // Actual Foundation locale-formatted POSITIVE whole numbers are
            // checked separately from assumed keyboard output. Direct iOS
            // keyboard, paste, RTL layout and VoiceOver checks remain external.
            let formatter = NumberFormatter()
            formatter.locale = locale
            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = false
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
            for value in [0, 37, 500] {
                if let input = formatter.string(from: NSNumber(value: value)) {
                    expect(input, value, locale: locale, group: "Foundation-formatted positive whole numbers")
                } else {
                    count += 1
                    failures.append(["group": "Foundation formatter unavailable", "locale": localeID, "value": value])
                }
            }
        }

        let report: [String: Any] = [
            "scope": "Unit checks against actual MealModels.swift parser source; native Foundation behavior, not iOS keyboard/UI evidence.",
            "policy": "Trim outer whitespace/newlines; accept nonempty Unicode decimal digits including mixed scripts and leading zeroes in range; reject signs, separators, exponents, fractions, controls and other numeric symbols.",
            "locales": localeIDs, "digitScripts": scripts.map(\.name), "checks": count,
            "checksByGroup": groupCounts, "failureCount": failures.count, "failures": failures,
            "limits": "No model/network, nutrition validation, app save flow or actual keyboard interaction exercised. Representative bidi-mark rejection and locale formatter output are not observations of keyboard-emitted text."
        ]
        if CommandLine.arguments.count == 2 {
            let data = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: URL(fileURLWithPath: CommandLine.arguments[1]), options: .withoutOverwriting)
        } else if CommandLine.arguments.count != 1 {
            fatalError("Usage: verify-whole-grams [optional-new-report.json]")
        }
        if !failures.isEmpty {
            for failure in failures.prefix(20) { print(failure) }
            fatalError("Whole-gram verification failed: \(failures.count)/\(count) mismatches. See the optional JSON report for all cases.")
        }
        print("Whole-gram verification passed: \(count) checks; 18 locales; 9 decimal-digit scripts; strict syntax, ranges, mixed scripts, bidi, leading zeroes and locale formatting.")
    }
}
