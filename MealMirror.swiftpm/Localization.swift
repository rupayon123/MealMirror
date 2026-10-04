import Foundation
import MealCore
import SwiftUI

enum AppLanguage: String, CaseIterable, Codable, Identifiable, Sendable {
    case english = "en"
    case french = "fr"
    case simplifiedChinese = "zh-Hans"
    case cantoneseTraditional = "yue-Hant"
    case punjabi = "pa"
    case urdu = "ur"
    case tamil = "ta"
    case filipino = "fil"
    case spanish = "es"
    case arabic = "ar"
    case persian = "fa"
    case hindi = "hi"
    case portuguese = "pt"
    case gujarati = "gu"
    case bengali = "bn"
    case japanese = "ja"
    case korean = "ko"
    case hungarian = "hu"

    var id: String { rawValue }
    var locale: Locale { Locale(identifier: rawValue) }
    var layoutDirection: LayoutDirection { isRightToLeft ? .rightToLeft : .leftToRight }
    var isRightToLeft: Bool { self == .arabic || self == .persian || self == .urdu }
    var supportsDecorativeTracking: Bool {
        switch self {
        case .simplifiedChinese, .cantoneseTraditional, .arabic, .persian, .urdu, .japanese, .korean:
            false
        default:
            true
        }
    }

    var nativeName: String {
        switch self {
        case .english: "English"
        case .french: "Français"
        case .simplifiedChinese: "简体中文"
        case .cantoneseTraditional: "粵語（繁體）"
        case .punjabi: "ਪੰਜਾਬੀ"
        case .urdu: "اردو"
        case .tamil: "தமிழ்"
        case .filipino: "Filipino"
        case .spanish: "Español"
        case .arabic: "العربية"
        case .persian: "فارسی"
        case .hindi: "हिन्दी"
        case .portuguese: "Português"
        case .gujarati: "ગુજરાતી"
        case .bengali: "বাংলা"
        case .japanese: "日本語"
        case .korean: "한국어"
        case .hungarian: "Magyar"
        }
    }

    var englishName: String {
        switch self {
        case .english: "English"
        case .french: "French"
        case .simplifiedChinese: "Simplified Chinese"
        case .cantoneseTraditional: "Cantonese (Traditional)"
        case .punjabi: "Punjabi"
        case .urdu: "Urdu"
        case .tamil: "Tamil"
        case .filipino: "Filipino"
        case .spanish: "Spanish"
        case .arabic: "Arabic"
        case .persian: "Persian"
        case .hindi: "Hindi"
        case .portuguese: "Portuguese"
        case .gujarati: "Gujarati"
        case .bengali: "Bengali"
        case .japanese: "Japanese"
        case .korean: "Korean"
        case .hungarian: "Hungarian"
        }
    }

    var bilingualMenuName: String {
        guard nativeName != englishName else { return nativeName }
        return "\u{2068}\(nativeName)\u{2069} · \u{2068}\(englishName)\u{2069}"
    }

    static func bestMatch(preferredLanguages: [String], available: [AppLanguage]) -> AppLanguage {
        for identifier in preferredLanguages {
            let normalized = identifier.replacingOccurrences(of: "_", with: "-").lowercased()
            if normalized.hasPrefix("yue"), available.contains(.cantoneseTraditional) {
                return .cantoneseTraditional
            }
            if normalized.hasPrefix("zh-hant") { continue }
            if normalized.hasPrefix("zh"), available.contains(.simplifiedChinese) {
                return .simplifiedChinese
            }
            if (normalized.hasPrefix("fil") || normalized.hasPrefix("tl")), available.contains(.filipino) {
                return .filipino
            }
            if let match = available.first(where: {
                normalized == $0.rawValue.lowercased() || normalized.hasPrefix($0.rawValue.lowercased() + "-")
            }) {
                return match
            }
        }
        return .english
    }
}

struct LocalizationCatalog: Sendable {
    static let shared = LocalizationCatalog()

    private let tables: [String: [String: String]]

    init(bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: "app_strings", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [String: String]].self, from: data) else {
            tables = [:]
            return
        }
        tables = decoded
    }

    var availableLanguages: [AppLanguage] {
        let populated = AppLanguage.allCases.filter { !(tables[$0.rawValue]?.isEmpty ?? true) }
        return populated.isEmpty ? [.english] : populated
    }

    func text(_ key: String, language: AppLanguage) -> String {
        tables[language.rawValue]?[key] ?? tables[AppLanguage.english.rawValue]?[key] ?? key
    }

    var hasCompleteEnglishTable: Bool { !(tables[AppLanguage.english.rawValue]?.isEmpty ?? true) }
}

@MainActor
final class LocalizationStore: ObservableObject {
    static let preferenceKey = "mealmirror.language"

    @Published var language: AppLanguage {
        didSet {
            defaults.set(language.rawValue, forKey: Self.preferenceKey)
            CarbInTheme.selectedLanguage = language
        }
    }

    private let defaults: UserDefaults
    private let catalog: LocalizationCatalog

    init(defaults: UserDefaults = .standard, catalog: LocalizationCatalog = .shared) {
        self.defaults = defaults
        self.catalog = catalog
        let available = catalog.availableLanguages
        if let stored = defaults.string(forKey: Self.preferenceKey),
           let preferred = AppLanguage(rawValue: stored), available.contains(preferred) {
            self.language = preferred
        } else {
            self.language = AppLanguage.bestMatch(preferredLanguages: Locale.preferredLanguages, available: available)
        }
        CarbInTheme.selectedLanguage = language
    }

    var availableLanguages: [AppLanguage] { catalog.availableLanguages }

    func text(_ key: String) -> String {
        catalog.text(key, language: language)
    }

    func text(_ key: String, arguments: CVarArg...) -> String {
        String(format: catalog.text(key, language: language), locale: language.locale, arguments: arguments)
    }

    func carbohydrateRange(_ range: CarbRange) -> String {
        let localizedFormat = catalog.text("%lld–%lld g", language: language)
        if range.low == range.high, localizedFormat.contains("%lld–%lld") {
            // Every catalog keeps its own unit after this shared placeholder.
            // A user-entered fixed value should read as one amount, not 42–42.
            let singleFormat = localizedFormat.replacingOccurrences(of: "%lld–%lld", with: "%lld")
            let displayFormat = language.isRightToLeft
                ? singleFormat.replacingOccurrences(of: "%lld", with: "\u{2066}%lld\u{2069}")
                : singleFormat
            return String(format: displayFormat, locale: language.locale, arguments: [Int64(range.low)])
        }
        // Keep the low-to-high numeric run in order inside right-to-left text.
        let displayFormat = language.isRightToLeft
            ? localizedFormat.replacingOccurrences(of: "%lld–%lld", with: "\u{2066}%lld–%lld\u{2069}")
            : localizedFormat
        return range.display(
            locale: language.locale,
            format: displayFormat
        )
    }
}

struct LanguagePickerMenu: View {
    @EnvironmentObject private var localization: LocalizationStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var accessibilityIdentifier: String
    var showsCurrentLanguage = false

    var body: some View {
        Menu {
            Picker(localization.text("Language"), selection: $localization.language) {
                ForEach(localization.availableLanguages) { language in
                    Text(verbatim: language.bilingualMenuName).tag(language)
                }
            }
        } label: {
            Group {
                if showsCurrentLanguage && dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 4) {
                        languageTitle
                        currentLanguageName
                    }
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 9) {
                        languageTitle
                        if showsCurrentLanguage {
                            Spacer(minLength: 10)
                            currentLanguageName
                        }
                    }
                }
            }
            .foregroundStyle(CarbInTheme.ink)
            .frame(maxWidth: showsCurrentLanguage ? .infinity : nil, minHeight: 44, alignment: .leading)
            .padding(.horizontal, 12)
            .background(CarbInTheme.ticket, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(CarbInTheme.line.opacity(0.7), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
        .accessibilityHint(localization.text("Choose the language used throughout MealMirror."))
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private var languageTitle: some View {
        Label(localization.text("Language"), systemImage: "globe")
            .font(CarbInTheme.reading(.subheadline, size: 15, weight: .bold))
            .fixedSize(horizontal: false, vertical: true)
    }

    private var currentLanguageName: some View {
        Text(verbatim: localization.language.bilingualMenuName)
            .font(CarbInTheme.reading(.subheadline, size: 15))
            .foregroundStyle(CarbInTheme.mutedInk)
            .fixedSize(horizontal: false, vertical: true)
    }
}
