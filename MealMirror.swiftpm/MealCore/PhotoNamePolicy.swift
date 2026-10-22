import Foundation

/// Bounds the display text returned by a photo model. This is not semantic
/// validation: an accepted name may still be wrong or describe something that
/// is not food. Every accepted name remains an uncertain clue, excluded from
/// carbohydrate totals until a person supplies a checked amount separately.
public enum PhotoNamePolicy {
    public static func names(from rawNames: [String], visibleFood: Bool) -> [String] {
        guard visibleFood else { return [] }

        var result: [String] = []
        var seen = Set<String>()
        // Bound both the candidate count and scalar count. A single grapheme
        // can contain many combining marks, so a grapheme limit alone is not
        // a bound on the amount of model text processed.
        for rawName in rawNames.prefix(32) {
            guard rawName.unicodeScalars.prefix(481).count <= 480,
                  let name = cleanedName(rawName) else { continue }
            let folded = name.folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: Locale(identifier: "en_US_POSIX")
            )
            let tokens = folded.components(separatedBy: CharacterSet.letters.inverted)
            guard !tokens.contains(where: excludedTokens.contains),
                  seen.insert(folded).inserted else { continue }
            result.append(name)
            if result.count == 6 { break }
        }
        return result
    }

    private static let excludedTokens: Set<String> = [
        "insulin", "dose", "doses", "unit", "units", "carbohydrate",
        "carbohydrates", "glucose", "grams", "bolus", "boluses", "carb", "carbs"
    ]

    private static func cleanedName(_ rawName: String) -> String? {
        var normalized = ""
        var pendingSpace = false
        var hasLetter = false

        for scalar in rawName.unicodeScalars {
            // Reject these before whitespace normalization: line breaks,
            // controls and bidi formatting must not enter a one-line clue.
            guard !CharacterSet.controlCharacters.contains(scalar),
                  !CharacterSet.newlines.contains(scalar),
                  !(0x202A...0x202E).contains(scalar.value),
                  !(0x2066...0x2069).contains(scalar.value) else { return nil }

            if CharacterSet.whitespaces.contains(scalar) {
                pendingSpace = !normalized.isEmpty
                continue
            }

            let isAllowed: Bool
            switch scalar.properties.generalCategory {
            case .uppercaseLetter, .lowercaseLetter, .titlecaseLetter,
                 .modifierLetter, .otherLetter:
                hasLetter = true
                isAllowed = true
            case .nonspacingMark, .spacingMark, .enclosingMark:
                isAllowed = true
            default:
                isAllowed = scalar == "'" || scalar == "’" || scalar == "-"
            }
            guard isAllowed else { return nil }
            if pendingSpace {
                normalized.append(" ")
                pendingSpace = false
            }
            normalized.unicodeScalars.append(scalar)
        }

        guard hasLetter, !normalized.isEmpty, normalized.count <= 60 else { return nil }
        return normalized
    }
}
