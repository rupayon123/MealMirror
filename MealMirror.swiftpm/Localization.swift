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
        didSet { defaults.set(language.rawValue, forKey: Self.preferenceKey) }
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
    }

    var availableLanguages: [AppLanguage] { catalog.availableLanguages }

    func text(_ key: String) -> String {
        catalog.text(key, language: language)
    }

    func text(_ key: String, arguments: CVarArg...) -> String {
        String(format: catalog.text(key, language: language), locale: language.locale, arguments: arguments)
    }

    func carbohydrateRange(_ range: CarbRange) -> String {
        range.display(
            locale: language.locale,
            format: catalog.text("%lld–%lld g", language: language)
        )
    }
}

struct LanguagePickerMenu: View {
    @EnvironmentObject private var localization: LocalizationStore

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
            HStack(spacing: 9) {
                Label(localization.text("Language"), systemImage: "globe")
                    .font(.subheadline.weight(.bold))
                if showsCurrentLanguage {
                    Spacer(minLength: 10)
                    Text(verbatim: localization.language.bilingualMenuName)
                        .font(.subheadline)
                        .foregroundStyle(CarbInTheme.mutedInk)
                        .lineLimit(1)
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
}
