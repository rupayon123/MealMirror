import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var localization: LocalizationStore

    let onHowItWorks: () -> Void
    let onPrivacyPolicy: () -> Void
    let onLocalPrivacy: () -> Void
    let onMedicalSafety: () -> Void
    let onReplayOnboarding: () -> Void

    var body: some View {
        Form {
            Section {
                HStack(spacing: 14) {
                    MealMirrorBadge(showsStars: false)
                        .frame(width: 54, height: 54)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("MealMirror")
                            .font(CarbInTheme.display(.title3, size: 19))
                        Text("A clearer view of your meal")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CarbInTheme.tomato)
                    }
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(CarbInTheme.ticket)

            Section("Learn") {
                Button(action: onHowItWorks) {
                    Label("How MealMirror works", systemImage: "questionmark.circle")
                }
                .accessibilityIdentifier("carbin.settings.how")
                Button(action: onReplayOnboarding) {
                    Label("Replay the welcome guide", systemImage: "arrow.counterclockwise")
                }
                .accessibilityIdentifier("carbin.settings.replayOnboarding")
            }

            Section("Preferences") {
                LanguagePickerMenu(
                    accessibilityIdentifier: "carbin.settings.language",
                    showsCurrentLanguage: true
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
            }

            Section("Legal and safety") {
                Button(action: onLocalPrivacy) {
                    Label("Local data and deletion", systemImage: "externaldrive.badge.xmark")
                }
                .accessibilityIdentifier("carbin.settings.history")
                Button(action: onPrivacyPolicy) {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                }
                .accessibilityIdentifier("carbin.settings.legal.privacy")
                Button(action: onMedicalSafety) {
                    Label("Medical Safety", systemImage: "cross.case.fill")
                }
                .accessibilityIdentifier("carbin.settings.legal.medical")
            }

            Section("About") {
                LabeledContent("App") { Text("MealMirror") }
                LabeledContent("Meaning") { Text("A clearer view of your meal") }
                LabeledContent("Version") { Text(versionLabel).monospacedDigit() }
            }
        }
        .scrollContentBackground(.hidden)
        .background(CarbInTheme.canvas)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CarbInTheme.canvas, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var versionLabel: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        PolicyScroll(
            eyebrow: "CHALLENGE CANDIDATE · UPDATED OCTOBER 2, 2026",
            title: "Privacy Policy",
            introduction: "MealMirror is designed to review meal carbohydrates without an account or a developer-operated server. This policy describes the data handled by this version of the app."
        ) {
            PolicySection(
                symbol: "camera.fill",
                title: "Camera and selected photos",
                body: "MealMirror processes only the photo you capture or explicitly select for the active meal review. Apple Vision inspection runs on this device. MealMirror does not upload the photo or save it in review history. Apple’s system photo picker may retrieve an item you selected from iCloud Photos on Apple’s behalf."
            )
            PolicySection(
                symbol: "internaldrive.fill",
                title: "Saved review data",
                body: "If you choose Save, MealMirror stores the user-entered meal description, reviewed carbohydrate range, date, and a random identifier in a protected local file. The file is excluded from device backups. Only the welcome-guide preference is stored in app preferences. Insulin ratios and insulin-unit arithmetic are not saved."
            )
            PolicySection(
                symbol: "network.slash",
                title: "No collection by the developer",
                body: "This version has no account, advertising, analytics, tracking, third-party SDK, or developer-server transmission. MealMirror does not sell or share personal information."
            )
            PolicySection(
                symbol: "trash.fill",
                title: "Retention and deletion",
                body: "Selected photos remain only for the active review. Saved reviews remain until you delete local review history in MealMirror or remove the app. Uninstalling MealMirror removes its local app data under iOS controls."
            )
            PolicySection(
                symbol: "person.2.fill",
                title: "Children and supported use",
                body: "MealMirror does not ask for a child’s age or require an account. Children should review meal and health information with a parent or guardian and their qualified care team."
            )
            PolicySection(
                symbol: "envelope.fill",
                title: "Policy changes",
                body: "This Challenge candidate has no online policy or support service. Its privacy practices are described here for this version and may change in a later release."
            )
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MedicalSafetyView: View {
    var body: some View {
        PolicyScroll(
            eyebrow: "READ BEFORE USE",
            title: "Medical Safety",
            introduction: "Insulin decisions can cause severe harm. MealMirror’s Challenge build stops at a reviewed carbohydrate range."
        ) {
            PolicySection(symbol: "scope", title: "What MealMirror does", body: "MealMirror organizes user-described meal items, shows inspectable local reference ranges, preserves uncertainty, and lets you replace an estimate with a trusted label value.")
            PolicySection(symbol: "hand.raised.fill", title: "What MealMirror does not do", body: "MealMirror does not determine an insulin-to-carbohydrate ratio, display insulin units, calculate a correction, consider glucose or insulin on board, connect to a pump, or recommend treatment.")
            PolicySection(symbol: "cross.case.fill", title: "Use qualified guidance", body: "Confirm carbohydrate information and all treatment decisions with your clinician-established plan or an appropriately authorized calculator. If you may be experiencing an emergency, contact local emergency services.")
            PolicySection(symbol: "lock.shield.fill", title: "Insulin calculations unavailable", body: "This public version does not include insulin-unit arithmetic. Any future clinical version would require separate qualified review and the applicable regulatory and marketplace evidence before distribution.")
        }
        .navigationTitle("Medical Safety")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PolicyScroll<Content: View>: View {
    let eyebrow: String
    let title: String
    let introduction: String
    @ViewBuilder let content: Content
    @EnvironmentObject private var localization: LocalizationStore

    init(
        eyebrow: String,
        title: String,
        introduction: String,
        @ViewBuilder content: () -> Content
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.introduction = introduction
        self.content = content()
    }

    var body: some View {
        ZStack {
            CountertopBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(LocalizedStringKey(eyebrow))
                        .font(.caption.weight(.bold))
                        .tracking(localization.language.supportsDecorativeTracking ? 1 : 0)
                        .foregroundStyle(CarbInTheme.tomato)
                    Text(LocalizedStringKey(title))
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(CarbInTheme.ink)
                    Text(LocalizedStringKey(introduction))
                        .font(.body)
                        .foregroundStyle(CarbInTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                    content
                }
                .frame(maxWidth: 720, alignment: .leading)
                .padding(20)
                .frame(maxWidth: .infinity)
            }
        }
        .toolbarBackground(CarbInTheme.canvas, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

private struct PolicySection: View {
    let symbol: String
    let title: String
    let text: String

    init(symbol: String, title: String, body: String) {
        self.symbol = symbol
        self.title = title
        self.text = body
    }

    var viewBody: some View {
        VStack(alignment: .leading, spacing: 9) {
            Label {
                Text(LocalizedStringKey(title))
            } icon: {
                Image(systemName: symbol).accessibilityHidden(true)
            }
            .font(CarbInTheme.display(.headline, size: 16))
            .foregroundStyle(CarbInTheme.ink)
            Text(LocalizedStringKey(text))
                .font(.subheadline)
                .foregroundStyle(CarbInTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle().fill(CarbInTheme.line.opacity(0.45)).frame(height: 1)
        }
    }

    var body: some View { viewBody }
}
