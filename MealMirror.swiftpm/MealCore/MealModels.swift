import Foundation

public struct CarbRange: Hashable, Codable, Sendable {
    public let low: Int
    public let high: Int

    public init(low: Int, high: Int) {
        self.low = max(0, low)
        self.high = max(self.low, high)
    }

    public func display(locale: Locale, format: String = "%lld–%lld g") -> String {
        String(
            format: format,
            locale: locale,
            arguments: [Int64(low), Int64(high)]
        )
    }

    public static func total(of ranges: [CarbRange]) -> CarbRange? {
        guard !ranges.isEmpty else { return nil }
        var totalLow = 0
        var totalHigh = 0

        for range in ranges {
            let (nextLow, lowOverflow) = totalLow.addingReportingOverflow(range.low)
            let (nextHigh, highOverflow) = totalHigh.addingReportingOverflow(range.high)
            guard !lowOverflow, !highOverflow else { return nil }
            totalLow = nextLow
            totalHigh = nextHigh
        }

        return CarbRange(low: totalLow, high: totalHigh)
    }

    public func adjusted(for portion: PortionAdjustment) -> CarbRange {
        CarbRange(
            low: Int((Double(low) * portion.lowMultiplier).rounded(.down)),
            high: Int((Double(high) * portion.highMultiplier).rounded(.up))
        )
    }
}

public enum PortionAdjustment: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case smaller
    case usual
    case larger

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .smaller: "Smaller"
        case .usual: "Usual"
        case .larger: "Larger"
        }
    }

    public var lowMultiplier: Double {
        switch self {
        case .smaller: 0.65
        case .usual: 1
        case .larger: 1.25
        }
    }

    public var highMultiplier: Double {
        switch self {
        case .smaller: 0.8
        case .usual: 1
        case .larger: 1.5
        }
    }
}

public enum MealTextTreatment: String, Codable, Hashable, Sendable {
    case localizedCatalog
    case verbatimUser
    case formattedLocalized
}

public enum MealTextResolver {
    public static func resolve(
        _ value: String,
        treatment: MealTextTreatment,
        localize: (String) -> String
    ) -> String {
        switch treatment {
        case .localizedCatalog:
            localize(value)
        case .verbatimUser, .formattedLocalized:
            value
        }
    }
}

public struct MealComponent: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let detail: String
    public let baselineCarbohydrates: CarbRange
    public let symbol: String
    public let signal: String
    public let nameTreatment: MealTextTreatment
    public let detailTreatment: MealTextTreatment
    public let signalTreatment: MealTextTreatment
    public var portion: PortionAdjustment
    public var isIncluded: Bool

    public init(
        id: String? = nil,
        name: String,
        detail: String,
        carbohydrates: CarbRange,
        symbol: String,
        signal: String,
        nameTreatment: MealTextTreatment = .localizedCatalog,
        detailTreatment: MealTextTreatment = .localizedCatalog,
        signalTreatment: MealTextTreatment = .localizedCatalog,
        portion: PortionAdjustment = .usual,
        isIncluded: Bool = true
    ) {
        self.id = id ?? name.lowercased().replacingOccurrences(of: " ", with: "-")
        self.name = name
        self.detail = detail
        self.baselineCarbohydrates = carbohydrates
        self.symbol = symbol
        self.signal = signal
        self.nameTreatment = nameTreatment
        self.detailTreatment = detailTreatment
        self.signalTreatment = signalTreatment
        self.portion = portion
        self.isIncluded = isIncluded
    }

    public var carbohydrates: CarbRange {
        baselineCarbohydrates.adjusted(for: portion)
    }
}

public enum WholeGramParser {
    public static func parse(
        _ input: String,
        locale: Locale,
        allowedRange: ClosedRange<Int> = 0...500
    ) -> Int? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        guard let number = formatter.number(from: input.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }
        let value = number.doubleValue
        guard value.isFinite, value.rounded() == value else { return nil }
        guard value >= Double(Int.min), value < Double(Int.max) else { return nil }
        guard value >= Double(allowedRange.lowerBound),
              value <= Double(allowedRange.upperBound) else {
            return nil
        }
        return Int(value)
    }
}

public enum MealIngredientCatalog {
    private struct Rule {
        let keywords: [String]
        let component: MealComponent
    }

    private static let rules: [Rule] = [
        Rule(keywords: ["biryani"], component: MealComponent(id: "biryani-rice", name: "Biryani rice portion", detail: "Recipe and serving size vary", carbohydrates: CarbRange(low: 44, high: 65), symbol: "circle.grid.2x2.fill", signal: "Description match")),
        Rule(keywords: ["rice", "basmati", "jasmine rice"], component: MealComponent(id: "rice", name: "Rice", detail: "Default bowl portion", carbohydrates: CarbRange(low: 32, high: 48), symbol: "circle.grid.2x2.fill", signal: "Description match")),
        Rule(keywords: ["toast", "bread"], component: MealComponent(id: "bread", name: "Bread or toast", detail: "Default medium slice", carbohydrates: CarbRange(low: 14, high: 20), symbol: "rectangle.stack.fill", signal: "Description match")),
        Rule(keywords: ["pasta", "spaghetti", "macaroni"], component: MealComponent(id: "pasta", name: "Pasta", detail: "Default cup portion", carbohydrates: CarbRange(low: 35, high: 50), symbol: "frying.pan.fill", signal: "Description match")),
        Rule(keywords: ["noodle", "ramen"], component: MealComponent(id: "noodles", name: "Noodles", detail: "Default bowl portion", carbohydrates: CarbRange(low: 35, high: 55), symbol: "frying.pan.fill", signal: "Description match")),
        Rule(keywords: ["sweet potato"], component: MealComponent(id: "sweet-potato", name: "Sweet potato", detail: "Default half-cup portion", carbohydrates: CarbRange(low: 15, high: 22), symbol: "square.grid.2x2.fill", signal: "Description match")),
        Rule(keywords: ["potato", "potatoes", "fries"], component: MealComponent(id: "potato", name: "Potato", detail: "Default serving", carbohydrates: CarbRange(low: 20, high: 35), symbol: "square.grid.2x2.fill", signal: "Description match")),
        Rule(keywords: ["quinoa"], component: MealComponent(id: "quinoa", name: "Quinoa", detail: "Default three-quarter cup portion", carbohydrates: CarbRange(low: 30, high: 39), symbol: "circle.grid.2x2.fill", signal: "Description match")),
        Rule(keywords: ["lentil", "lentils", "dal"], component: MealComponent(id: "lentils", name: "Lentils", detail: "Default half-cup portion", carbohydrates: CarbRange(low: 17, high: 24), symbol: "leaf.fill", signal: "Description match")),
        Rule(keywords: ["chickpea", "chickpeas", "garbanzo"], component: MealComponent(id: "chickpeas", name: "Chickpeas", detail: "Default half-cup portion", carbohydrates: CarbRange(low: 18, high: 24), symbol: "leaf.fill", signal: "Description match")),
        Rule(keywords: ["bean", "beans", "black beans", "kidney beans"], component: MealComponent(id: "beans", name: "Beans", detail: "Default half-cup portion", carbohydrates: CarbRange(low: 17, high: 24), symbol: "leaf.fill", signal: "Description match")),
        Rule(keywords: ["naan"], component: MealComponent(id: "naan", name: "Naan", detail: "Default medium piece", carbohydrates: CarbRange(low: 35, high: 50), symbol: "square.fill", signal: "Description match")),
        Rule(keywords: ["roti", "chapati"], component: MealComponent(id: "roti", name: "Roti or chapati", detail: "Default medium piece", carbohydrates: CarbRange(low: 15, high: 22), symbol: "square.fill", signal: "Description match")),
        Rule(keywords: ["tortilla", "wrap"], component: MealComponent(id: "tortilla", name: "Tortilla or wrap", detail: "Default medium piece", carbohydrates: CarbRange(low: 20, high: 30), symbol: "square.fill", signal: "Description match")),
        Rule(keywords: ["oat", "oatmeal"], component: MealComponent(id: "oats", name: "Oats", detail: "Default cooked bowl", carbohydrates: CarbRange(low: 25, high: 35), symbol: "circle.grid.2x2.fill", signal: "Description match")),
        Rule(keywords: ["banana"], component: MealComponent(id: "banana", name: "Banana", detail: "Default medium fruit", carbohydrates: CarbRange(low: 24, high: 30), symbol: "leaf.fill", signal: "Description match")),
        Rule(keywords: ["berry", "berries", "strawberry", "blueberry"], component: MealComponent(id: "berries", name: "Berries", detail: "Default small side serving", carbohydrates: CarbRange(low: 10, high: 15), symbol: "circle.hexagongrid.fill", signal: "Description match")),
        Rule(keywords: ["apple", "whole orange", "fresh orange", "fruit"], component: MealComponent(id: "fruit", name: "Fruit", detail: "Default medium serving", carbohydrates: CarbRange(low: 15, high: 25), symbol: "apple.logo", signal: "Description match")),
        Rule(keywords: ["yogurt", "raita"], component: MealComponent(id: "yogurt", name: "Yogurt or raita", detail: "Default small serving", carbohydrates: CarbRange(low: 5, high: 12), symbol: "cup.and.saucer.fill", signal: "Description match")),
        Rule(keywords: ["milk"], component: MealComponent(id: "milk", name: "Milk", detail: "Default cup", carbohydrates: CarbRange(low: 10, high: 15), symbol: "cup.and.saucer.fill", signal: "Description match")),
        Rule(keywords: ["juice", "smoothie"], component: MealComponent(id: "juice", name: "Juice or smoothie", detail: "Default cup", carbohydrates: CarbRange(low: 20, high: 35), symbol: "cup.and.saucer.fill", signal: "Description match")),
        Rule(keywords: ["pizza"], component: MealComponent(id: "pizza", name: "Pizza", detail: "Default single slice", carbohydrates: CarbRange(low: 30, high: 40), symbol: "triangle.fill", signal: "Description match"))
    ]

    public static func components(
        matching description: String,
        locale: Locale = Locale(identifier: "en"),
        localizedKeyword: (String) -> String = { $0 }
    ) -> [MealComponent] {
        let input = description.lowercased(with: locale)
        var usedIDs = Set<String>()
        return rules.compactMap { rule in
            let candidates = rule.keywords + rule.keywords.map(localizedKeyword)
            guard candidates.contains(where: { matches($0.lowercased(with: locale), in: input) }),
                  !shouldSuppress(rule.component.id, in: input, locale: locale, localizedKeyword: localizedKeyword),
                  usedIDs.insert(rule.component.id).inserted else {
                return nil
            }
            return rule.component
        }
    }

    private static func shouldSuppress(
        _ componentID: String,
        in input: String,
        locale: Locale,
        localizedKeyword: (String) -> String
    ) -> Bool {
        let sweetPotato = ["sweet potato", localizedKeyword("sweet potato")]
        let biryani = ["biryani", localizedKeyword("biryani")]
        return (componentID == "potato" && sweetPotato.contains { matches($0.lowercased(with: locale), in: input) })
            || (componentID == "rice" && biryani.contains { matches($0.lowercased(with: locale), in: input) })
    }

    private static func matches(_ keyword: String, in input: String) -> Bool {
        guard !keyword.isEmpty else { return false }
        if usesContinuousWordScript(keyword) {
            return input.contains(keyword)
        }
        let escapedKeyword = NSRegularExpression.escapedPattern(for: keyword)
        let pattern = "(?<![\\p{L}\\p{N}])\(escapedKeyword)(?![\\p{L}\\p{N}])"
        return input.range(of: pattern, options: .regularExpression) != nil
    }

    private static func usesContinuousWordScript(_ value: String) -> Bool {
        value.unicodeScalars.contains { scalar in
            switch scalar.value {
            case 0x1100...0x11FF,   // Hangul Jamo
                 0x3040...0x30FF,   // Hiragana and Katakana
                 0x3130...0x318F,   // Hangul compatibility Jamo
                 0x3400...0x4DBF,   // CJK Extension A
                 0x4E00...0x9FFF,   // Unified CJK ideographs
                 0xAC00...0xD7AF,   // Hangul syllables
                 0xF900...0xFAFF,   // CJK compatibility ideographs
                 0xFF66...0xFF9D:   // Half-width Katakana
                true
            default:
                false
            }
        }
    }
}
