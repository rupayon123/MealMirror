import SwiftUI
import OnboardingCore

struct CarbInRootView: View {
    @AppStorage(OnboardingState.completionKey) private var hasCompletedOnboarding = false
    @State private var isPreparing = true
    @State private var startsWithLibrary = false
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
                    startsWithLibrary: startsWithLibrary,
                    onReplayOnboarding: { hasCompletedOnboarding = false }
                )
                    .transition(reduceMotion ? .identity : .opacity)
            } else {
                OnboardingView {
                    startsWithLibrary = true
                    hasCompletedOnboarding = true
                }
                .transition(reduceMotion ? .identity : .opacity)
            }
        }
    }
}

private struct LaunchExperienceView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var localization: LocalizationStore
    @State private var markVisible = false

    let onReady: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let diameter = min(dynamicTypeSize.isAccessibilitySize ? 210 : 286, geometry.size.width - 48)
            ScrollView {
                VStack(spacing: 18) {
                    KitchenLoadingArtwork(diameter: diameter)
                        .offset(y: reduceMotion || markVisible ? 0 : 16)
                        .opacity(reduceMotion || markVisible ? 1 : 0)

                    VStack(spacing: 5) {
                        Text("MealMirror")
                            .font(CarbInTheme.brand(.largeTitle, size: 30))
                            .foregroundStyle(CarbInTheme.actionInk)
                        Text(localization.text("A clearer view of your meal"))
                            .font(CarbInTheme.display(.headline, size: 16))
                            .foregroundStyle(CarbInTheme.actionInk.opacity(0.92))
                    }
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

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
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
        }
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
    let size: CGFloat

    var body: some View {
        ZStack {
            if page != 0 {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(CarbInTheme.surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(CarbInTheme.basil, lineWidth: 3)
                    }
            }

            MealPlateGraphic(showsPen: false)
                .frame(width: size * (page == 0 ? 1 : 0.72),
                       height: size * (page == 0 ? 1 : 0.72))
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
        .frame(width: size, height: size)
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
                detail: "Describe a meal or choose a photo, then review a carbohydrate range. Optional Practice meals are also available.",
                safety: "MealMirror estimates carbohydrates for you to review. It does not recommend insulin doses, corrections, or treatment decisions."
            )
        ]
    }

    var body: some View {
        GeometryReader { geometry in
            let compactHeight = geometry.size.height < 700
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 16) {
                                languageMenu
                                onboardingPage(pages[page], compactHeight: compactHeight)

                                VStack(spacing: 4) { legalButtons }
                                    .font(CarbInTheme.reading(.caption1, size: 13, weight: .semibold))
                                    .foregroundStyle(CarbInTheme.pine)
                                    .padding(.horizontal, 20)
                            }
                        }
                        continueButton
                    }
                } else {
                    VStack(spacing: 0) {
                        languageMenu

                        TabView(selection: $page) {
                            ForEach(pages) { item in
                                ScrollView {
                                    onboardingPage(item, compactHeight: compactHeight)
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
                        .font(CarbInTheme.reading(.caption1, size: 13, weight: .semibold))
                        .foregroundStyle(CarbInTheme.pine)
                        .padding(.horizontal, 20)

                        continueButton
                    }
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

    @ViewBuilder private var languageMenu: some View {
        if localization.availableLanguages.count > 1 {
            HStack {
                Spacer()
                LanguagePickerMenu(accessibilityIdentifier: "carbin.onboarding.language")
            }
            .padding(.horizontal, 20)
        }
    }

    private func onboardingPage(_ item: OnboardingPage, compactHeight: Bool) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 34) {
                OnboardingIllustration(page: item.id, size: compactHeight ? 160 : 250)
                onboardingCopy(item, compactHeight: compactHeight)
            }
            VStack(alignment: .leading, spacing: compactHeight ? 12 : 22) {
                OnboardingIllustration(page: item.id, size: compactHeight ? 160 : 250)
                    .frame(maxWidth: .infinity, alignment: .center)
                onboardingCopy(item, compactHeight: compactHeight)
            }
        }
        .frame(maxWidth: 860, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, compactHeight ? 10 : 18)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("carbin.onboarding.page.\(item.id)")
    }

    private func onboardingCopy(_ item: OnboardingPage, compactHeight: Bool) -> some View {
        VStack(alignment: .leading, spacing: compactHeight ? 10 : 15) {
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
                .font(CarbInTheme.reading(.caption1, size: 13, weight: .bold))
                .tracking(localization.language.supportsDecorativeTracking ? 0.7 : 0)
                .foregroundStyle(CarbInTheme.tomato)

            Text(localization.text(item.title))
                .font(CarbInTheme.display(.title1, size: 26))
                .foregroundStyle(CarbInTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(localization.text(item.detail))
                .font(CarbInTheme.reading(.body, size: 17))
                .foregroundStyle(CarbInTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            if let safety = item.safety {
                SafetyRail(
                    title: "A clear boundary",
                    detail: LocalizedStringKey(safety),
                    symbol: item.id == 3 ? "lock.fill" : "exclamationmark.shield.fill"
                )
                Text(localization.text("A photo cannot reveal every ingredient or portion. Confirm the foods, adjust portions, and prefer a package label or trusted reference when available."))
                    .font(CarbInTheme.reading(.footnote, size: 13))
                    .foregroundStyle(CarbInTheme.mutedInk)
                Text(localization.text("Your meal stays on this device"))
                    .font(CarbInTheme.reading(.footnote, size: 13, weight: .bold))
                    .foregroundStyle(CarbInTheme.basil)
            }
        }
        .mealTicket(inset: compactHeight ? 16 : 20)
        .frame(maxWidth: 520, alignment: .leading)
    }

    private var continueButton: some View {
        let photoAction = page == pages.count - 1
        return Button {
            if photoAction {
                onFinish()
            } else {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.22)) {
                    page += 1
                }
            }
        } label: {
            Label(
                localization.text(photoAction && dynamicTypeSize.isAccessibilitySize ? "Photo" : photoAction ? "Choose a meal photo from your library" : "Continue"),
                systemImage: photoAction ? "photo.on.rectangle" : continueSymbol
            )
        }
        .accessibilityLabel(localization.text(photoAction ? "Choose a meal photo from your library" : "Continue"))
        .buttonStyle(PrimaryActionStyle())
        .frame(maxWidth: 620)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .accessibilityIdentifier("carbin.onboarding.continue")
    }

    private var continueSymbol: String {
        localization.language.layoutDirection == .rightToLeft ? "chevron.left" : "chevron.right"
    }

    @ToolbarContentBuilder
    private var legalCloseToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") { legalSheet = nil }
                .accessibilityLabel("Close")
                .accessibilityIdentifier("carbin.onboarding.legal.close")
        }
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
