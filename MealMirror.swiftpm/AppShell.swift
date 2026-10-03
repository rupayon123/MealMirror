import SwiftUI
import OnboardingCore

struct CarbInRootView: View {
    @AppStorage(OnboardingState.completionKey) private var hasCompletedOnboarding = false
    @State private var isPreparing = true
    @State private var startsWithPractice = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Group {
                if isPreparing { CarbInTheme.loadingCanvas } else { CarbInTheme.canvas }
            }
            .ignoresSafeArea()

            if isPreparing {
                LaunchExperienceView {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.24)) {
                        isPreparing = false
                    }
                }
                .transition(reduceMotion ? .identity : .opacity)
            } else if hasCompletedOnboarding {
                ContentView(
                    startsWithPractice: startsWithPractice,
                    onReplayOnboarding: { hasCompletedOnboarding = false }
                )
                    .transition(reduceMotion ? .identity : .opacity)
            } else {
                OnboardingView {
                    startsWithPractice = true
                    hasCompletedOnboarding = true
                }
                .transition(reduceMotion ? .identity : .opacity)
            }
        }
    }
}

private struct LaunchExperienceView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var localization: LocalizationStore
    @State private var markVisible = false

    let onReady: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                FoodOrbitRing(diameter: 286)
                MealMirrorBadge()
                    .frame(width: 218, height: 218)
            }
                .frame(width: 286, height: 286)
                .offset(y: reduceMotion || markVisible ? 0 : 16)
                .opacity(reduceMotion || markVisible ? 1 : 0)
                .accessibilityHidden(true)

            VStack(spacing: 5) {
                Text("MealMirror")
                    .font(CarbInTheme.brand(.largeTitle, size: 30))
                    .foregroundStyle(CarbInTheme.actionInk)
                Text(localization.text("A clearer view of your meal"))
                    .font(CarbInTheme.display(.headline, size: 16))
                    .foregroundStyle(CarbInTheme.actionInk.opacity(0.92))
            }

            VStack(spacing: 10) {
                Text(localization.text("Preparing MealMirror"))
                    .font(CarbInTheme.display(.headline, size: 17))
                    .foregroundStyle(CarbInTheme.ink)
                PixelDivider()
            }
            .frame(maxWidth: 300)
            .padding(14)
            .background(CarbInTheme.surface, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 9, style: .continuous).stroke(CarbInTheme.line, lineWidth: 3) }
            .shadow(color: CarbInTheme.line.opacity(0.55), radius: 0, x: 0, y: 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CarbInTheme.loadingCanvas)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("MealMirror. \(localization.text("A clearer view of your meal")). \(localization.text("Preparing MealMirror"))")
        .accessibilityIdentifier("carbin.launch")
        .task {
            if reduceMotion {
                markVisible = true
                try? await Task.sleep(for: .milliseconds(180))
            } else {
                withAnimation(.easeOut(duration: 0.24)) {
                    markVisible = true
                }
                try? await Task.sleep(for: .milliseconds(650))
            }
            guard !Task.isCancelled else { return }
            onReady()
        }
    }
}

private struct OnboardingPage: Identifiable {
    let id: Int
    let symbol: String
    let eyebrow: String
    let title: String
    let detail: String
    let safety: String?
}

private struct OnboardingIllustration: View {
    let page: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(CarbInTheme.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(CarbInTheme.basil, lineWidth: 3)
                }

            MealPlateGraphic(showsPen: false)
                .frame(width: 180, height: 180)
                .offset(x: page == 1 ? -26 : 0)

            if page == 1 {
                VStack(spacing: 7) {
                    miniTicket(width: 74)
                    miniTicket(width: 62)
                    miniTicket(width: 70)
                }
                .offset(x: 72, y: 18)
            } else if page == 2 {
                HStack(spacing: 4) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle().fill(CarbInTheme.butter).frame(width: 8, height: 8)
                    }
                }
                .offset(y: 91)
            } else if page == 3 {
                Image(systemName: "lock.fill")
                    .font(CarbInTheme.display(.title2, size: 22))
                    .foregroundStyle(CarbInTheme.surface)
                    .frame(width: 54, height: 54)
                    .background(CarbInTheme.tomato, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .offset(x: 68, y: 65)
            }

        }
        .frame(width: 250, height: 250)
        .accessibilityHidden(true)
    }

    private func miniTicket(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Rectangle().fill(CarbInTheme.tomato).frame(width: width * 0.45, height: 5)
            Rectangle().fill(CarbInTheme.line).frame(width: width, height: 3)
            Rectangle().fill(CarbInTheme.basil).frame(width: width * 0.72, height: 3)
        }
        .padding(7)
        .background(CarbInTheme.ticket, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(CarbInTheme.line.opacity(0.7), lineWidth: 1)
        }
    }
}

private enum OnboardingLegalSheet: Int, Identifiable {
    case privacy
    case safety

    var id: Int { rawValue }
}

private struct OnboardingView: View {
    @EnvironmentObject private var localization: LocalizationStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var page = 0
    @State private var legalSheet: OnboardingLegalSheet?

    let onFinish: () -> Void

    private var pages: [OnboardingPage] {
        [
            OnboardingPage(
                id: 0,
                symbol: "fork.knife.circle.fill",
                eyebrow: "WELCOME",
                title: "Meet MealMirror",
                detail: "Describe a meal or choose a photo. MealMirror offers local food clues and a carbohydrate range for you to review. Try a bundled meal to see the full experience.",
                safety: "Photo clues can be wrong and cannot measure portions. MealMirror does not calculate insulin or treatment actions. Your meal stays on this device."
            )
        ]
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                ScrollView {
                    VStack(spacing: 16) {
                        languageMenu
                        onboardingPage(pages[page])

                        VStack(spacing: 4) { legalButtons }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CarbInTheme.pine)
                            .padding(.horizontal, 20)

                        continueButton
                    }
                }
            } else {
                VStack(spacing: 0) {
                    languageMenu

                    TabView(selection: $page) {
                        ForEach(pages) { item in
                            ScrollView {
                                onboardingPage(item)
                            }
                            .tag(item.id)
                            .accessibilityIdentifier("carbin.onboarding.page.\(item.id)")
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 16) { legalButtons }
                        VStack(spacing: 0) { legalButtons }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CarbInTheme.pine)
                    .padding(.horizontal, 20)

                    continueButton
                }
            }
        }
        .background(CountertopBackdrop())
        .sheet(item: $legalSheet) { destination in
            NavigationStack {
                Group {
                    switch destination {
                    case .privacy:
                        PrivacyPolicyView()
                            .toolbar { legalCloseToolbar }
                    case .safety:
                        MedicalSafetyView()
                            .toolbar { legalCloseToolbar }
                    }
                }
            }
        }
    }

    private var languageMenu: some View {
        HStack {
            Spacer()
            LanguagePickerMenu(accessibilityIdentifier: "carbin.onboarding.language")
        }
        .padding(.horizontal, 20)
    }

    private func onboardingPage(_ item: OnboardingPage) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 34) {
                OnboardingIllustration(page: item.id)
                onboardingCopy(item)
            }
            VStack(alignment: .leading, spacing: 22) {
                OnboardingIllustration(page: item.id)
                    .frame(maxWidth: .infinity, alignment: .center)
                onboardingCopy(item)
            }
        }
        .frame(maxWidth: 860, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("carbin.onboarding.page.\(item.id)")
    }

    private func onboardingCopy(_ item: OnboardingPage) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 6) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Rectangle()
                        .fill(
                            index == item.id
                                ? CarbInTheme.tomato
                                : index < item.id ? CarbInTheme.basil : CarbInTheme.line.opacity(0.45)
                        )
                        .frame(maxWidth: index == item.id ? 44 : 24, minHeight: 6, maxHeight: 6)
                }
            }
            .accessibilityHidden(true)

            Text(localization.text(item.eyebrow))
                .font(.caption.weight(.bold))
                .tracking(localization.language.supportsDecorativeTracking ? 0.7 : 0)
                .foregroundStyle(CarbInTheme.tomato)

            Text(localization.text(item.title))
                .font(CarbInTheme.display(.title1, size: 26))
                .foregroundStyle(CarbInTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(localization.text(item.detail))
                .font(.body)
                .foregroundStyle(CarbInTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            if let safety = item.safety {
                SafetyRail(
                    title: "A clear boundary",
                    detail: LocalizedStringKey(safety),
                    symbol: item.id == 3 ? "lock.fill" : "exclamationmark.shield.fill"
                )
            }
        }
        .mealTicket(inset: 20)
        .frame(maxWidth: 520, alignment: .leading)
    }

    private var continueButton: some View {
        Button {
            if page == pages.count - 1 {
                onFinish()
            } else {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.22)) {
                    page += 1
                }
            }
        } label: {
            Label(
                localization.text("Try a practice meal"),
                systemImage: continueSymbol
            )
        }
        .buttonStyle(PrimaryActionStyle())
        .frame(maxWidth: 620)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .accessibilityIdentifier("carbin.onboarding.continue")
    }

    @ToolbarContentBuilder
    private var legalCloseToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") { legalSheet = nil }
                .accessibilityLabel("Close")
                .accessibilityIdentifier("carbin.onboarding.legal.close")
        }
    }

    private var continueSymbol: String {
        let isRightToLeft = localization.language.layoutDirection == .rightToLeft
        if page == pages.count - 1 {
            return isRightToLeft ? "arrow.left.circle.fill" : "arrow.right.circle.fill"
        }
        return isRightToLeft ? "chevron.left" : "chevron.right"
    }

    @ViewBuilder
    private var legalButtons: some View {
        Button { legalSheet = .privacy } label: {
            Text("Privacy")
                .frame(minWidth: 48, minHeight: 48)
                .contentShape(Rectangle())
        }
        .frame(minWidth: 48, minHeight: 48)
        .contentShape(Rectangle())
        .accessibilityIdentifier("carbin.onboarding.legal.privacy")
        Button { legalSheet = .safety } label: {
            Text("Medical Safety")
                .frame(minWidth: 48, minHeight: 48)
                .contentShape(Rectangle())
        }
        .frame(minWidth: 48, minHeight: 48)
        .contentShape(Rectangle())
        .accessibilityIdentifier("carbin.onboarding.legal.medical")
    }
}
