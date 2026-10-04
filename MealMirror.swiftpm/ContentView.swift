import PhotosUI
import SwiftUI
import UIKit
import MealCore
import NavigationCore

private enum InitialPhotoSource {
    case none
    case camera
    case library
}

struct ContentView: View {
    let startsWithLibrary: Bool
    let onReplayOnboarding: () -> Void

    init(startsWithLibrary: Bool = false, onReplayOnboarding: @escaping () -> Void = {}) {
        self.startsWithLibrary = startsWithLibrary
        self.onReplayOnboarding = onReplayOnboarding
    }

    @State private var navigation = AppNavigationState()
    @State private var selectedMeal = DemoMeal.library[0]
    @State private var mealDescription = ""
    @State private var referenceItemPresent = false
    @State private var selectedPhoto: UIImage?
    @State private var inputSource: MealInputSource = .manual
    @State private var analysis = MealAnalysis.empty()
    @State private var initialPhotoSource: InitialPhotoSource = .none
    @State private var initialDescriptionMode = false
    @EnvironmentObject private var localization: LocalizationStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var didApplyInitialLibrary = false

    var body: some View {
        NavigationStack(path: $navigation.path) {
            HomeView(
                onStart: { beginMealReview(photoSource: .none) },
                onCamera: { beginMealReview(photoSource: .camera) },
                onLibrary: { beginMealReview(photoSource: .library) },
                onHowItWorks: { navigation.open(.howItWorks) },
                onHistory: { navigation.open(.privacy) },
                onSettings: { navigation.open(.settings) }
            )
            .navigationTitle(localization.text("Close"))
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .addMeal:
                    AddMealView(
                        selectedMeal: $selectedMeal,
                        mealDescription: $mealDescription,
                        referenceItemPresent: $referenceItemPresent,
                        selectedPhoto: $selectedPhoto,
                        inputSource: $inputSource,
                        initialPhotoSource: initialPhotoSource,
                        startsWithDescription: initialDescriptionMode,
                        onInitialPhotoSourceConsumed: { initialPhotoSource = .none },
                        onSelectMeal: selectMeal,
                        onAnalyze: { newAnalysis in
                            analysis = newAnalysis
                            navigation.showEstimate()
                        }
                    )
                case .estimate:
                    EstimateView(
                        analysis: $analysis,
                        fallbackMeal: selectedMeal,
                        selectedPhoto: selectedPhoto,
                        onReview: { navigation.showFinalReview() }
                    )
                case .review:
                    ReviewView(
                        analysis: $analysis,
                        onStartAnother: resetExperience
                    )
                case .howItWorks:
                    HowItWorksView(onReplayOnboarding: onReplayOnboarding)
                case .privacy:
                    PrivacyView()
                case .settings:
                    SettingsView(
                        onHowItWorks: { navigation.open(.howItWorks) },
                        onPrivacyPolicy: { navigation.open(.privacyPolicy) },
                        onLocalPrivacy: { navigation.open(.privacy) },
                        onMedicalSafety: { navigation.open(.medicalSafety) },
                        onReplayOnboarding: onReplayOnboarding
                    )
                case .privacyPolicy:
                    PrivacyPolicyView()
                case .medicalSafety:
                    MedicalSafetyView()
                }
            }
        }
        .tint(CarbInTheme.moss)
        .toolbarBackground(CarbInTheme.canvas, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(colorScheme, for: .navigationBar)
        .onChange(of: localization.language) { oldLanguage, _ in
            guard inputSource == .demo else { return }
            let oldPrompt = LocalizationCatalog.shared.text(selectedMeal.prompt, language: oldLanguage)
            if mealDescription == selectedMeal.prompt || mealDescription == oldPrompt {
                mealDescription = localization.text(selectedMeal.prompt)
            }
        }
        .onChange(of: navigation.path) { oldPath, newPath in
            guard newPath.isEmpty, oldPath.contains(where: isMealFlowRoute) else { return }
            clearMealDraft()
        }
        .task {
            guard startsWithLibrary, !didApplyInitialLibrary else { return }
            didApplyInitialLibrary = true
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            beginMealReview(photoSource: .library)
        }
    }

    private func selectMeal(_ meal: DemoMeal) {
        selectedMeal = meal
        mealDescription = localization.text(meal.prompt)
        selectedPhoto = nil
        inputSource = .demo
    }

    private func beginMealReview(photoSource: InitialPhotoSource, prefersDescription: Bool = false) {
        clearMealDraft()
        initialPhotoSource = photoSource
        initialDescriptionMode = prefersDescription
        navigation.beginMealReview()
    }

    private func clearMealDraft() {
        initialPhotoSource = .none
        initialDescriptionMode = false
        selectedMeal = DemoMeal.library[0]
        mealDescription = ""
        referenceItemPresent = false
        selectedPhoto = nil
        inputSource = .manual
        analysis = .empty()
    }

    private func resetExperience() {
        clearMealDraft()
        navigation.resetToHome()
    }

    private func isMealFlowRoute(_ route: AppRoute) -> Bool {
        switch route {
        case .addMeal, .estimate, .review:
            true
        case .howItWorks, .privacy, .settings, .privacyPolicy, .medicalSafety:
            false
        }
    }
}

private struct HomeView: View {
    let onStart: () -> Void
    let onCamera: () -> Void
    let onLibrary: () -> Void
    let onHowItWorks: () -> Void
    let onHistory: () -> Void
    let onSettings: () -> Void

    @State private var reviews = LocalReviewStore.load()
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var localization: LocalizationStore

    var body: some View {
        ScreenScroll(maxWidth: 1080) {
            VStack(alignment: .leading, spacing: 18) {
                AppHeader(onSettings: onSettings)
                if dynamicTypeSize.isAccessibilitySize {
                    quickActions
                    homeHero
                    historyTicket
                    howItWorksTicket
                } else if horizontalSizeClass == .regular {
                    homeHero
                    HStack(alignment: .top, spacing: 16) {
                        quickActions
                        VStack(spacing: 14) {
                            historyTicket
                            howItWorksTicket
                        }
                    }
                } else {
                    quickActions
                    homeHero
                    historyTicket
                    howItWorksTicket
                }

                SafetyRail(
                    title: "A clear boundary",
                    detail: "MealMirror estimates carbohydrates for you to review. It does not recommend insulin doses, corrections, or treatment decisions."
                )
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !dynamicTypeSize.isAccessibilitySize {
                Button(action: onStart) {
                    Label("Start a meal review", systemImage: "plus")
                }
                .buttonStyle(PrimaryActionStyle())
                .accessibilityIdentifier("carbin.home.estimate")
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(CarbInTheme.canvas)
                .overlay(alignment: .top) {
                    CarbInTheme.line.frame(height: 3)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { reviews = LocalReviewStore.load() }
    }

    private var homeHero: some View {
        VStack(spacing: 10) {
            if !dynamicTypeSize.isAccessibilitySize {
                MealMirrorBadge()
                    .frame(width: horizontalSizeClass == .regular ? 250 : 205,
                           height: horizontalSizeClass == .regular ? 250 : 205)
                    .padding(.top, 6)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("What’s on your plate?")
                    .font(CarbInTheme.display(.title1, size: 25))
                    .foregroundStyle(CarbInTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if !dynamicTypeSize.isAccessibilitySize {
                    Text("Start with a photo or a few words. Add context when a picture leaves questions.")
                        .font(CarbInTheme.reading(.body, size: 16, weight: .semibold))
                        .foregroundStyle(CarbInTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .kitchenBubble(inset: 14)
        }
        .padding(14)
        .background { CheckerboardSurface() }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(CarbInTheme.line, lineWidth: 3)
        }
        .shadow(color: CarbInTheme.line.opacity(0.38), radius: 0, x: 4, y: 5)
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            if dynamicTypeSize.isAccessibilitySize {
                Button(action: onStart) {
                    Label("Start a meal review", systemImage: "plus")
                }
                .buttonStyle(PrimaryActionStyle())
                .accessibilityIdentifier("carbin.home.estimate")
                quickAction("Camera", symbol: "camera", enabled: CameraAccess.isAvailable, action: onCamera)
                    .accessibilityIdentifier("carbin.home.camera")
                quickAction("Library", symbol: "photo.on.rectangle", enabled: true, action: onLibrary)
                    .accessibilityIdentifier("carbin.home.library")
            } else {
                HStack(spacing: 10) {
                    quickAction("Camera", symbol: "camera", enabled: CameraAccess.isAvailable, action: onCamera)
                        .accessibilityIdentifier("carbin.home.camera")
                    quickAction("Library", symbol: "photo.on.rectangle", enabled: true, action: onLibrary)
                        .accessibilityIdentifier("carbin.home.library")
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func quickAction(_ title: LocalizedStringKey, symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(CarbInTheme.tomato)
                    .accessibilityHidden(true)
                Text(title)
                    .font(CarbInTheme.display(.headline, size: 17))
                    .foregroundStyle(CarbInTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 78)
        }
        .buttonStyle(.plain)
        .workbenchSurface(inset: 12)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.58)
    }

    private var howItWorksTicket: some View {
        Button(action: onHowItWorks) {
            HStack(spacing: 12) {
                Image(systemName: "info.circle")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(CarbInTheme.basil)
                    .frame(width: 44, height: 44)
                    .background(CarbInTheme.basilSoft, in: RoundedRectangle(cornerRadius: 6))
                    .accessibilityHidden(true)
                Text("How it works")
                    .font(CarbInTheme.display(.headline, size: 18))
                    .foregroundStyle(CarbInTheme.ink)
                Spacer(minLength: 4)
                Image(systemName: "chevron.forward")
                    .foregroundStyle(CarbInTheme.ink)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 54)
        }
        .buttonStyle(.plain)
        .workbenchSurface(inset: 14)
        .accessibilityIdentifier("carbin.home.how")
    }

    private var historyTicket: some View {
        Button(action: onHistory) {
            HStack(spacing: 12) {
                Image(systemName: "tray.full.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(CarbInTheme.basil)
                    .frame(width: 44, height: 44)
                    .background(CarbInTheme.basilSoft, in: RoundedRectangle(cornerRadius: 6))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Local review history")
                        .font(CarbInTheme.display(.headline, size: 18))
                        .foregroundStyle(CarbInTheme.ink)
                    Text(historySummary)
                        .font(CarbInTheme.reading(.subheadline, size: 14, weight: .semibold))
                        .foregroundStyle(CarbInTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.forward")
                    .foregroundStyle(CarbInTheme.ink)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
        }
        .buttonStyle(.plain)
        .workbenchSurface(inset: 14)
        .accessibilityIdentifier("carbin.home.history")
    }

    private var historySummary: String {
        if reviews.isEmpty { return localization.text("No saved reviews yet") }
        if reviews.count == 1 { return localization.text("1 local review is saved on this device.") }
        return localization.text("%lld local reviews are saved on this device.", arguments: Int64(reviews.count))
    }
}

private struct AppHeader: View {
    let onSettings: () -> Void

    @EnvironmentObject private var localization: LocalizationStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutDirection) private var layoutDirection

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                HStack(alignment: .center, spacing: 12) {
                    brand
                    Spacer(minLength: 8)
                    settingsButton
                }
            } else if layoutDirection == .rightToLeft {
                VStack(alignment: .leading, spacing: 12) {
                    brand
                    settingsButton
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            } else {
                HStack(alignment: .center) {
                    brand
                    Spacer()
                    settingsButton
                }
            }
        }
    }

    private var brand: some View {
        HStack(spacing: 12) {
            MealMirrorBadge(showsStars: false)
                .frame(width: 60, height: 60)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                Text("MealMirror")
                    .font(dynamicTypeSize.isAccessibilitySize
                        ? CarbInTheme.brand(.headline, size: 16)
                        : CarbInTheme.brand(.title2, size: 22))
                    .foregroundStyle(CarbInTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                if !dynamicTypeSize.isAccessibilitySize {
                    Text(localization.text("A clearer view of your meal"))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CarbInTheme.tomato)
                }
            }
        }
    }

    private var settingsButton: some View {
        Button(action: onSettings) {
            Image(systemName: "gearshape.fill")
                .font(.body.weight(.semibold))
                .frame(width: 44, height: 44)
                .background(CarbInTheme.ticket, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(CarbInTheme.line.opacity(0.8), lineWidth: 1)
                }
        }
        .foregroundStyle(CarbInTheme.moss)
        .accessibilityLabel(localization.text("Settings, language, privacy, and safety"))
        .accessibilityIdentifier("carbin.home.settings")
    }
}

private struct AddMealView: View {
    @Binding var selectedMeal: DemoMeal
    @Binding var mealDescription: String
    @Binding var referenceItemPresent: Bool
    @Binding var selectedPhoto: UIImage?
    @Binding var inputSource: MealInputSource

    let initialPhotoSource: InitialPhotoSource
    let startsWithDescription: Bool
    let onInitialPhotoSourceConsumed: () -> Void
    let onSelectMeal: (DemoMeal) -> Void
    let onAnalyze: (MealAnalysis) -> Void

    @State private var photoPickerItem: PhotosPickerItem?
    @State private var isAnalyzing = false
    @State private var showsPhotoInput = true
    @State private var isPreparingPhoto = false
    @State private var photoLoadError: String?
    @State private var photoLoadToken = UUID()
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var cameraError: String?
    @State private var analysisTask: Task<Void, Never>?
    @State private var analysisRunID = UUID()
    @FocusState private var isMealDescriptionFocused: Bool
    @EnvironmentObject private var localization: LocalizationStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScreenScroll(maxWidth: 1080) {
            VStack(alignment: .leading, spacing: 24) {
                StepRail(current: 1)
                if !dynamicTypeSize.isAccessibilitySize {
                    SectionHeading(
                        eyebrow: showsPhotoInput ? "Photo" : "Description",
                        title: "Start with your meal",
                        detail: "Start with a photo or a few words. Add context when a picture leaves questions."
                    )
                }

                if horizontalSizeClass == .regular && !dynamicTypeSize.isAccessibilitySize {
                    HStack(alignment: .top, spacing: 18) {
                        photoWorkbench
                        descriptionWorkbench
                    }
                } else {
                    inputTabs
                    if showsPhotoInput {
                        photoWorkbench
                        if selectedPhoto != nil { descriptionWorkbench }
                    } else {
                        descriptionWorkbench
                    }
                }

                referenceToggle
                practiceShelf

                if inputSource == .personalPhoto {
                    Label("Apple Vision offers possible food clues on this device. You choose what belongs; only confirmed items and local reference ranges shape the review.", systemImage: "cpu")
                        .font(CarbInTheme.reading(.footnote, size: 13))
                        .foregroundStyle(CarbInTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if dynamicTypeSize.isAccessibilitySize {
                    analyzeAction
                } else {
                    Color.clear.frame(height: 66)
                }
            }
            .disabled(isAnalyzing)
        }
        .safeAreaInset(edge: .bottom) {
            if dynamicTypeSize.isAccessibilitySize {
                EmptyView()
            } else {
                analyzeAction
            }
        }
        .overlay {
            if isAnalyzing {
                GeometryReader { geometry in
                    let diameter = min(dynamicTypeSize.isAccessibilitySize ? 210 : 286, geometry.size.width - 48)
                    ScrollView {
                        VStack(spacing: 17) {
                            KitchenLoadingArtwork(diameter: diameter)
                            Text(localization.text("Inspecting on this device…"))
                                .font(CarbInTheme.display(.title2, size: 24))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(CarbInTheme.actionInk)
                            Text(localization.text("A clearer view of your meal"))
                                .font(.subheadline.weight(.bold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(CarbInTheme.actionInk)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: geometry.size.height)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(CarbInTheme.loadingCanvas.ignoresSafeArea())
                .transition(reduceMotion ? .identity : .opacity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(localization.text("Analysis in progress"))
            }
        }
        .kitchenNavigationTitle("Add a meal")
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoPickerItem, matching: .images)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CarbInTheme.canvas, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isMealDescriptionFocused = false
                }
                .accessibilityIdentifier("carbin.meal.keyboard.done")
            }
        }
        .onChange(of: photoPickerItem) { _, newItem in
            guard let newItem else { return }
            cancelPendingAnalysis()
            let token = UUID()
            photoLoadToken = token
            isPreparingPhoto = true
            Task {
                do {
                    guard let data = try await newItem.loadTransferable(type: Data.self),
                          let image = await MealPhotoPreparation.downsampledImageAsync(from: data) else {
                        guard photoLoadToken == token else { return }
                        isPreparingPhoto = false
                        photoLoadError = "MealMirror could not prepare that photo. Choose another image or use the camera."
                        return
                    }
                    guard photoLoadToken == token else { return }
                    isPreparingPhoto = false
                    usePersonalPhoto(image)
                } catch {
                    guard photoLoadToken == token else { return }
                    isPreparingPhoto = false
                    photoLoadError = "That photo could not be loaded. Choose it again, select a different image, or use the camera."
                }
            }
        }
        .onChange(of: mealDescription) { _, newDescription in
            guard inputSource == .demo else { return }
            let practicePrompt = localization.text(selectedMeal.prompt)
            if newDescription != practicePrompt && newDescription != selectedMeal.prompt {
                inputSource = .manual
            }
        }
        .onChange(of: inputSource) { _, newSource in
            if newSource == .demo { showsPhotoInput = false }
        }
        .alert("Couldn’t use that photo", isPresented: Binding(
            get: { photoLoadError != nil },
            set: { if !$0 { photoLoadError = nil } }
        )) {
            Button("OK", role: .cancel) {
                photoLoadError = nil
            }
        } message: {
            Text(LocalizedStringKey(photoLoadError ?? ""))
        }
        .alert("Camera unavailable", isPresented: Binding(
            get: { cameraError != nil },
            set: { if !$0 { cameraError = nil } }
        )) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                cameraError = nil
            }
            Button("Not Now", role: .cancel) {
                cameraError = nil
            }
        } message: {
            Text(LocalizedStringKey(cameraError ?? ""))
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCapture(
                onCapture: { image in
                    showCamera = false
                    cancelPendingAnalysis()
                    let token = UUID()
                    photoLoadToken = token
                    isPreparingPhoto = true
                    Task { @MainActor in
                        let prepared = await MealPhotoPreparation.downsampledImageAsync(from: image)
                        guard photoLoadToken == token else { return }
                        isPreparingPhoto = false
                        guard let prepared else {
                            photoLoadError = "MealMirror could not prepare that photo. Choose another image or use the camera."
                            return
                        }
                        usePersonalPhoto(prepared)
                    }
                },
                onCancel: {
                    showCamera = false
                },
                onFailure: {
                    showCamera = false
                    cameraError = "The camera did not return a photo. Try again or choose a photo from your library."
                }
            )
            .ignoresSafeArea()
        }
        .onDisappear {
            cancelPendingAnalysis()
        }
        .task {
            showsPhotoInput = !startsWithDescription
            let source = initialPhotoSource
            guard source != .none else { return }
            onInitialPhotoSourceConsumed()
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            switch source {
            case .camera:
                openCamera()
            case .library:
                showPhotoPicker = true
            case .none:
                break
            }
        }
    }

    private var inputTabs: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 5))
            : AnyLayout(HStackLayout(spacing: 5))
        return layout {
            inputTab("Description", isSelected: !showsPhotoInput) { showsPhotoInput = false }
            inputTab("Photo", isSelected: showsPhotoInput) { showsPhotoInput = true }
        }
        .padding(4)
        .background(CarbInTheme.inset, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(CarbInTheme.line, lineWidth: 2)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: showsPhotoInput)
    }

    private func inputTab(_ title: LocalizedStringKey, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(CarbInTheme.display(.headline, size: 16))
                .foregroundStyle(CarbInTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
        .background(isSelected ? CarbInTheme.surface : Color.clear, in: RoundedRectangle(cornerRadius: 6))
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? CarbInTheme.line : Color.clear, lineWidth: 2)
        }
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var descriptionWorkbench: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(LocalizedStringKey(inputSource == .demo ? "Practice meal description" : inputSource == .personalPhoto ? "What can you identify?" : "What’s on your plate?"))
                    .font(CarbInTheme.display(.title3, size: 19))
                    .foregroundStyle(CarbInTheme.ink)
                Spacer(minLength: 8)
                Image(systemName: "text.alignleft")
                    .foregroundStyle(CarbInTheme.tomato)
                    .accessibilityHidden(true)
            }

            if !dynamicTypeSize.isAccessibilitySize {
                descriptionHelp
            }

            TextEditor(text: $mealDescription)
                .font(CarbInTheme.reading(.body, size: 17))
                .foregroundStyle(CarbInTheme.ink)
                .focused($isMealDescriptionFocused)
                .frame(minHeight: 150)
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(CarbInTheme.ticket, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(CarbInTheme.basil, lineWidth: isMealDescriptionFocused ? 2 : 1)
                }
                .accessibilityLabel("Meal description")
                .accessibilityHint("Describe ingredients and any details the photo does not show.")
                .accessibilityIdentifier("carbin.meal.description")

            if dynamicTypeSize.isAccessibilitySize {
                descriptionHelp
            }

            if mealDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Label("Choose a photo or name one food to continue.", systemImage: "info.circle")
                    .font(CarbInTheme.reading(.footnote, size: 13))
                    .foregroundStyle(CarbInTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .workbenchSurface()
    }

    private var descriptionHelp: some View {
        Text(LocalizedStringKey(inputSource == .demo ? "This Practice meal starts with a prepared description. Editing it switches back to your own meal." : "Name carbohydrate-containing items and portion details. You’ll be able to adjust the result and add a verified label value next."))
            .font(CarbInTheme.reading(.footnote, size: 13))
            .foregroundStyle(CarbInTheme.mutedInk)
    }

    private var photoWorkbench: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Use your meal photo")
                .font(CarbInTheme.display(.title3, size: 19))
                .foregroundStyle(CarbInTheme.ink)
            Text("The camera and on-device inspection never upload the photo.")
                .font(CarbInTheme.reading(.footnote, size: 13))
                .foregroundStyle(CarbInTheme.mutedInk)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) { mealPhotoActions(hasSelectedPhoto: selectedPhoto != nil) }
                VStack(spacing: 8) { mealPhotoActions(hasSelectedPhoto: selectedPhoto != nil) }
            }

            if selectedPhoto != nil || inputSource == .demo {
                PhotoPreview(
                    meal: selectedMeal,
                    selectedPhoto: selectedPhoto,
                    source: inputSource,
                    aspectRatio: 1.6,
                    emptyState: .mealEntry
                )
            } else {
                Label("No photo selected", systemImage: "photo")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CarbInTheme.mutedInk)
                    .frame(maxWidth: .infinity, minHeight: 70, alignment: .center)
                    .insetControlGroup(inset: 10)
            }

            if selectedPhoto != nil {
                Button {
                    cancelPendingAnalysis()
                    invalidatePendingPhotoLoad()
                    selectedPhoto = nil
                    photoPickerItem = nil
                    inputSource = .manual
                } label: {
                    Label("Remove selected photo", systemImage: "xmark.circle")
                        .frame(minWidth: 44, minHeight: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .foregroundStyle(CarbInTheme.tomato)
                .accessibilityIdentifier("carbin.meal.removePhoto")
            }

            if !CameraAccess.isAvailable {
                Label("Camera capture becomes available on a physical iPhone or iPad with a camera.", systemImage: "iphone")
                    .font(CarbInTheme.reading(.footnote, size: 13))
                    .foregroundStyle(CarbInTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if isPreparingPhoto {
                Label("Preparing your photo on this device…", systemImage: "arrow.triangle.2.circlepath")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(CarbInTheme.basil)
                    .accessibilityLabel("Preparing selected photo on this device")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mealTicket()
    }

    private var referenceToggle: some View {
        Toggle(isOn: $referenceItemPresent) {
            VStack(alignment: .leading, spacing: 4) {
                Text("I added a reference item")
                    .font(CarbInTheme.display(.headline, size: 16))
                    .foregroundStyle(CarbInTheme.ink)
                Text("Recorded for your own portion review. It does not change the carbohydrate range.")
                    .font(CarbInTheme.reading(.footnote, size: 13))
                    .foregroundStyle(CarbInTheme.mutedInk)
            }
        }
        .tint(CarbInTheme.basil)
        .insetControlGroup()
        .accessibilityIdentifier("carbin.meal.reference")
    }

    private var practiceShelf: some View {
        VStack(alignment: .leading, spacing: 13) {
            Label("Optional Practice", systemImage: "gamecontroller.fill")
                .font(CarbInTheme.display(.headline, size: 16))
                .foregroundStyle(CarbInTheme.tomato)
            Text("Use a bundled Practice meal to learn the review controls. Practice values are examples, not an analysis of your meal.")
                .font(CarbInTheme.reading(.footnote, size: 13))
                .foregroundStyle(CarbInTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(DemoMeal.library) { meal in
                        MealChoiceCard(
                            meal: meal,
                            isSelected: inputSource == .demo && selectedMeal.id == meal.id,
                            action: { selectDemo(meal) }
                        )
                    }
                }
                VStack(spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(DemoMeal.library.prefix(2)) { meal in
                            MealChoiceCard(
                                meal: meal,
                                isSelected: inputSource == .demo && selectedMeal.id == meal.id,
                                action: { selectDemo(meal) }
                            )
                        }
                    }
                    ForEach(DemoMeal.library.dropFirst(2)) { meal in
                        MealChoiceCard(
                            meal: meal,
                            isSelected: inputSource == .demo && selectedMeal.id == meal.id,
                            action: { selectDemo(meal) }
                        )
                    }
                }
                VStack(spacing: 12) {
                    ForEach(DemoMeal.library) { meal in
                        MealChoiceCard(
                            meal: meal,
                            isSelected: inputSource == .demo && selectedMeal.id == meal.id,
                            action: { selectDemo(meal) }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mealTicket(inset: 14)
    }

    private var analyzeAction: some View {
        Button(action: analyze) {
            HStack(spacing: 10) {
                if isAnalyzing {
                    ProgressView().tint(CarbInTheme.surface)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                }
                Text(LocalizedStringKey(isAnalyzing ? "Inspecting on this device…" : "Build my local review"))
            }
        }
        .buttonStyle(PrimaryActionStyle(isEnabled: canBuildLocalReview))
        .disabled(!canBuildLocalReview)
        .accessibilityValue(Text(LocalizedStringKey(isAnalyzing ? "Analysis in progress" : isPreparingPhoto ? "Photo preparation in progress" : "")))
        .accessibilityIdentifier("carbin.meal.analyze")
        .frame(maxWidth: 840)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(CarbInTheme.canvas)
        .overlay(alignment: .top) { Rectangle().fill(CarbInTheme.line.opacity(0.45)).frame(height: 1) }
    }

    private var canBuildLocalReview: Bool {
        !isAnalyzing
            && !isPreparingPhoto
            && (selectedPhoto != nil || !mealDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    private func analyze() {
        cancelPendingAnalysis()
        let runID = UUID()
        analysisRunID = runID
        isAnalyzing = true
        analysisTask = Task { @MainActor in
            let result = await MealAnalysisEngine().analyze(
                source: inputSource,
                demoMeal: selectedMeal,
                description: mealDescription,
                referenceItemPresent: referenceItemPresent,
                image: selectedPhoto,
                language: localization.language
            )
            guard !Task.isCancelled, analysisRunID == runID else { return }
            analysisTask = nil
            isAnalyzing = false
            onAnalyze(result)
        }
    }

    private func usePersonalPhoto(_ image: UIImage) {
        cancelPendingAnalysis()
        let isUntouchedDemoPrompt = inputSource == .demo
            && (mealDescription == selectedMeal.prompt || mealDescription == localization.text(selectedMeal.prompt))
        invalidatePendingPhotoLoad()
        photoPickerItem = nil
        selectedPhoto = image
        inputSource = .personalPhoto
        if isUntouchedDemoPrompt {
            mealDescription = ""
        }
    }

    private func selectDemo(_ meal: DemoMeal) {
        cancelPendingAnalysis()
        invalidatePendingPhotoLoad()
        photoPickerItem = nil
        photoLoadError = nil
        onSelectMeal(meal)
        onAnalyze(meal.analysis(
            description: localization.text(meal.prompt),
            referenceItemPresent: referenceItemPresent
        ))
    }

    private func invalidatePendingPhotoLoad() {
        photoLoadToken = UUID()
        isPreparingPhoto = false
    }

    private func cancelPendingAnalysis() {
        analysisRunID = UUID()
        analysisTask?.cancel()
        analysisTask = nil
        isAnalyzing = false
    }

    @ViewBuilder
    private func mealPhotoActions(hasSelectedPhoto: Bool) -> some View {
        Button(action: openCamera) {
            Label("Camera", systemImage: "camera")
        }
        .buttonStyle(CompactActionStyle())
        .disabled(!CameraAccess.isAvailable)
        .opacity(CameraAccess.isAvailable ? 1 : 0.5)
        .accessibilityHint(Text(LocalizedStringKey(CameraAccess.isAvailable ? "Opens the camera after you grant access." : "Camera is available when this app is run on an iPhone or iPad with a camera.")))
        .accessibilityIdentifier("carbin.meal.camera")

        PhotosPicker(selection: $photoPickerItem, matching: .images) {
            Label {
                Text(LocalizedStringKey(hasSelectedPhoto ? "Chosen" : "Library"))
                    .fixedSize(horizontal: true, vertical: false)
            } icon: {
                Image(systemName: hasSelectedPhoto ? "checkmark" : "photo.on.rectangle")
            }
        }
        .buttonStyle(CompactActionStyle())
        .accessibilityLabel(Text(LocalizedStringKey(selectedPhoto == nil ? "Choose a meal photo from your library" : "A meal photo has been chosen")))
        .accessibilityIdentifier("carbin.meal.library")
    }

    private func openCamera() {
        Task { @MainActor in
            if await CameraAccess.requestAuthorization() {
                showCamera = true
            } else {
                cameraError = "Camera access is off. You can allow it in Settings, or choose a photo without giving MealMirror access to your whole library."
            }
        }
    }
}

private struct EstimateView: View {
    @Binding var analysis: MealAnalysis
    let fallbackMeal: DemoMeal
    let selectedPhoto: UIImage?
    let onReview: () -> Void

    @ScaledMetric(relativeTo: .largeTitle) private var rangeFontSize = 48
    @State private var showIngredientEditor = false
    @State private var hasConfirmedMealParts = false
    @State private var showReviewTrail = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var localization: LocalizationStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var estimateActionClearance = 104

    var body: some View {
        ScreenScroll(maxWidth: 1080) {
            VStack(alignment: .leading, spacing: 22) {
                StepRail(current: 2)
                if !dynamicTypeSize.isAccessibilitySize {
                    SectionHeading(
                        eyebrow: "Your estimate",
                        title: analysis.isReadyForReview
                            ? "A range worth checking"
                            : (analysis.components.isEmpty ? "A little more detail will help" : "Possible foods to check"),
                        detail: analysis.isReadyForReview
                            ? "The range stays visible and editable, so you can review what it is based on."
                            : analysis.methodNote
                    )
                }

                if horizontalSizeClass == .regular && analysis.source != .manual {
                    HStack(alignment: .top, spacing: 18) {
                        rangeWorkbench
                        mealPreview
                    }
                    if !analysis.components.isEmpty {
                        ingredientLedger
                    }
                } else {
                    rangeWorkbench
                    if !analysis.components.isEmpty {
                        ingredientLedger
                    }
                    if analysis.source != .manual { mealPreview }
                }
                reviewTrail

                SafetyRail(
                    title: "A clear boundary",
                    detail: LocalizedStringKey(analysis.uncertaintyNote),
                    symbol: "exclamationmark.triangle.fill"
                )

                if analysis.isReadyForReview {
                    confirmationToggle
                }

                if !analysis.components.isEmpty {
                    Button {
                        showIngredientEditor = true
                    } label: {
                        Label("Adjust ingredients", systemImage: "slider.horizontal.3")
                    }
                    .buttonStyle(SecondaryActionStyle())
                    .accessibilityIdentifier("carbin.estimate.adjust")
                } else {
                    Button {
                        showIngredientEditor = true
                    } label: {
                        Label("Add a verified carbohydrate item", systemImage: "plus.circle")
                    }
                    .buttonStyle(SecondaryActionStyle())
                    .accessibilityHint("Add a carbohydrate amount from packaging or another trusted source.")
                    .accessibilityIdentifier("carbin.estimate.addVerified")
                }

                if dynamicTypeSize.isAccessibilitySize {
                    estimateAction
                } else {
                    Color.clear.frame(height: estimateActionClearance)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if dynamicTypeSize.isAccessibilitySize {
                EmptyView()
            } else {
                estimateAction
            }
        }
        .kitchenNavigationTitle("Your estimate")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CarbInTheme.canvas, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showIngredientEditor) {
            IngredientEditorSheet(analysis: $analysis)
        }
        .onChange(of: analysis.components) { _, _ in
            hasConfirmedMealParts = false
        }
    }

    private var rangeWorkbench: some View {
        Group {
            if let range = analysis.overallRange {
                rangeCopy(range)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Label("No reliable range yet", systemImage: "questionmark.circle")
                        .font(CarbInTheme.display(.title3, size: 19))
                        .foregroundStyle(CarbInTheme.tomato)
                    Text(LocalizedStringKey(analysis.components.isEmpty
                        ? "Add a verified carbohydrate amount from a package label or trusted source, go back and describe the meal in more detail, or choose an optional Practice meal."
                        : "Add the foods you recognize to build an inspectable carbohydrate range."))
                        .font(CarbInTheme.reading(.subheadline, size: 15))
                        .foregroundStyle(CarbInTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .workbenchSurface(fill: analysis.overallRange == nil ? CarbInTheme.tomatoSoft : CarbInTheme.basilSoft)
    }

    private func rangeCopy(_ range: CarbRange) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if analysis.source == .demo {
                Text("Practice meal")
                    .font(CarbInTheme.display(.caption1, size: 12))
                    .foregroundStyle(CarbInTheme.basil)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(CarbInTheme.basilSoft, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            }
            Text(localization.carbohydrateRange(range))
                .font(CarbInTheme.display(.largeTitle, size: rangeFontSize))
                .monospacedDigit()
                .foregroundStyle(CarbInTheme.basil)
                .lineLimit(1)
                .minimumScaleFactor(0.25)
                .accessibilityLabel(Text(
                    (analysis.source == .demo ? localization.text("Practice meal") + ". " : "")
                    + localization.text(
                        "Estimated carbohydrate range: %lld to %lld grams",
                        arguments: Int64(range.low),
                        Int64(range.high)
                    )
                ))
            Text("Starting carbohydrate range")
                .font(CarbInTheme.display(.headline, size: 16))
                .foregroundStyle(CarbInTheme.ink)
            PixelDivider(color: CarbInTheme.butter)
            Text("Keep the full range visible while you verify portions, ingredients, and labels. This is not dose advice.")
                .font(CarbInTheme.reading(.footnote, size: 13))
                .foregroundStyle(CarbInTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mealPreview: some View {
        PhotoPreview(
            meal: fallbackMeal,
            selectedPhoto: selectedPhoto,
            source: analysis.source,
            aspectRatio: 1.3,
            emptyState: .descriptionReview
        )
        .overlay(alignment: .topLeading) {
            Text(LocalizedStringKey(analysis.source == .demo ? "PRACTICE" : "ON DEVICE"))
                .font(.caption2.weight(.black))
                .tracking(localization.language.supportsDecorativeTracking ? 0.7 : 0)
                .foregroundStyle(CarbInTheme.surface)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(CarbInTheme.tomato, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                .padding(10)
                .accessibilityLabel(Text(LocalizedStringKey(analysis.source == .demo ? "Practice meal review" : "On-device photo inspection")))
        }
        .frame(maxWidth: .infinity)
        .workbenchSurface(inset: 10)
    }

    private var ingredientLedger: some View {
        VStack(alignment: .leading, spacing: 12) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    rangeHeading
                    Spacer()
                    rangeStatus
                }
                VStack(alignment: .leading, spacing: 4) {
                    rangeHeading
                    rangeStatus
                }
            }
            PixelDivider(color: CarbInTheme.basil)
            ForEach(analysis.components) { component in
                ComponentRow(component: component)
            }
        }
        .mealTicket()
    }

    private var reviewTrail: some View {
        DisclosureGroup(isExpanded: $showReviewTrail) {
            VStack(alignment: .leading, spacing: 14) {
                ConfidenceTrail(
                    descriptionProvided: !analysis.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    referenceItemPresent: analysis.referenceItemPresent,
                    visionStatus: analysis.visionStatus,
                    source: analysis.source
                )
                Text(LocalizedStringKey(analysis.methodNote))
                    .font(CarbInTheme.reading(.footnote, size: 13))
                    .foregroundStyle(CarbInTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
                Text(localizedVisionDetail)
                    .font(CarbInTheme.reading(.footnote, size: 13))
                    .foregroundStyle(CarbInTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 12)
        } label: {
            Label("Review trail", systemImage: "list.bullet.clipboard")
                .font(CarbInTheme.display(.headline, size: 16))
                .foregroundStyle(CarbInTheme.ink)
        }
        .tint(CarbInTheme.basil)
        .mealTicket()
    }

    private var confirmationToggle: some View {
        Toggle(isOn: $hasConfirmedMealParts) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Confirm the parts you recognize before you keep a local record.")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CarbInTheme.ink)
                Text("Recipe, portion size, sauces, and product labels can change this range. Confirm or adjust every listed item.")
                    .font(CarbInTheme.reading(.footnote, size: 13))
                    .foregroundStyle(CarbInTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .tint(CarbInTheme.basil)
        .accessibilityHint("Confirm whether each item belongs in the total, then choose the closest portion. These local reference ranges are a starting point—not a substitute for a product label or your own trusted carb-counting method.")
        .accessibilityIdentifier("carbin.estimate.confirmParts")
        .insetControlGroup()
    }

    private var estimateAction: some View {
        Group {
            if analysis.isReadyForReview {
                Button(action: onReview) {
                    Label("Review before saving", systemImage: "arrow.right.circle.fill")
                }
                .buttonStyle(PrimaryActionStyle(isEnabled: hasConfirmedMealParts))
                .disabled(!hasConfirmedMealParts)
                .accessibilityIdentifier("carbin.estimate.review")
            } else if !analysis.components.isEmpty {
                Button(action: { showIngredientEditor = true }) {
                    Label("Adjust ingredients", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(PrimaryActionStyle())
                .accessibilityIdentifier("carbin.estimate.reviewCandidates")
            } else {
                Button(action: { dismiss() }) {
                    Label("Go back and add detail", systemImage: "chevron.backward")
                }
                .buttonStyle(PrimaryActionStyle())
                .accessibilityIdentifier("carbin.estimate.back")
            }
        }
        .frame(maxWidth: 840)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(CarbInTheme.canvas)
        .overlay(alignment: .top) { Rectangle().fill(CarbInTheme.line.opacity(0.45)).frame(height: 1) }
    }

    private var localizedVisionDetail: String {
        switch analysis.visionStatus {
        case .notRun:
            localization.text(analysis.source == .demo
                ? "No photo inspection was needed for this Practice meal."
                : "No photo was selected, so the review uses only the meal description.")
        case let .inspected(labels):
            if labels.isEmpty {
                localization.text("No clear food clues found in this photo.")
            } else {
                localization.text("Photo inspected on this device. Visual cues: %@.", arguments: labels.joined(separator: ", "))
            }
        case .unavailable:
            if analysis.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                localization.text("Photo inspection was unavailable. No food or carbohydrate value came from the image.")
            } else {
                localization.text("Photo inspection was unavailable. The range still comes only from the meal details you entered.")
            }
        }
    }

    private var rangeHeading: some View {
        Text(LocalizedStringKey(analysis.isReadyForReview ? "What shaped the range" : "Possible foods to check"))
            .font(CarbInTheme.display(.headline, size: 16))
            .foregroundStyle(CarbInTheme.ink)
    }

    private var rangeStatus: some View {
        Text(LocalizedStringKey(analysis.isReadyForReview || !analysis.components.isEmpty ? "Adjust if needed" : "Add more detail"))
            .font(.caption)
            .foregroundStyle(CarbInTheme.mutedInk)
    }
}

private struct ReviewView: View {
    @Binding var analysis: MealAnalysis
    let onStartAnother: () -> Void

    @State private var saved = false
    @State private var showSaveError = false
    @Environment(\.locale) private var locale
    @EnvironmentObject private var localization: LocalizationStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScreenScroll {
            VStack(alignment: .leading, spacing: 24) {
                StepRail(current: 3)
                SectionHeading(
                    eyebrow: "Review",
                    title: saved ? "Saved privately." : "Your check, your call.",
                    detail: saved ? savedDetail : "Confirm the parts you recognize before you keep a local record.",
                    detailTreatment: saved ? .formattedLocalized : .localizedCatalog
                )

                reviewTicket
                if dynamicTypeSize.isAccessibilitySize {
                    reviewAction
                } else {
                    Color.clear.frame(height: 66)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if dynamicTypeSize.isAccessibilitySize {
                EmptyView()
            } else {
                reviewAction
            }
        }
        .kitchenNavigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn’t save this review", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The local review could not be saved. Nothing was uploaded. Try again while your device is unlocked.")
        }
    }

    private var reviewTicket: some View {
        VStack(alignment: .leading, spacing: 16) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top) {
                    reviewSummary
                    Spacer()
                    reviewStatusIcon
                }
                VStack(alignment: .leading, spacing: 10) {
                    reviewStatusIcon
                    reviewSummary
                }
            }

            PixelDivider(color: saved ? CarbInTheme.basil : CarbInTheme.tomato)

            ReviewFact(
                symbol: "text.alignleft",
                title: "Description",
                value: analysis.description,
                valueTreatment: .verbatimUser
            )
            ReviewFact(
                symbol: analysis.referenceItemPresent ? "ruler.fill" : "ruler",
                title: "Reference note",
                value: analysis.referenceItemPresent ? "Recorded only; it does not alter this carbohydrate range" : "No reference item recorded"
            )
            ReviewFact(
                symbol: "list.bullet",
                title: "Included components",
                value: localization.text("%lld meal parts", arguments: Int64(analysis.includedComponents.count)),
                valueTreatment: .formattedLocalized
            )

            SafetyRail(
                title: "No insulin recommendation",
                detail: "This estimate is not a dose calculator. Use the approach and care plan you and your diabetes team have agreed on."
            )
        }
        .mealTicket(inset: 20)
    }

    private var reviewAction: some View {
        Group {
            if saved {
                Button(action: onStartAnother) {
                    Label("Estimate another meal", systemImage: "arrow.counterclockwise.circle.fill")
                }
                .buttonStyle(PrimaryActionStyle())
                .accessibilityIdentifier("carbin.review.another")
            } else {
                Button(action: saveReview) {
                    Label("Save this local review", systemImage: "lock.fill")
                }
                .buttonStyle(PrimaryActionStyle())
                .accessibilityIdentifier("carbin.review.save")
            }
        }
        .frame(maxWidth: 840)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(CarbInTheme.canvas)
        .overlay(alignment: .top) { Rectangle().fill(CarbInTheme.line.opacity(0.45)).frame(height: 1) }
    }

    private var reviewSummary: some View {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey(analysis.title))
                                .font(CarbInTheme.display(.headline, size: 16))
                                .foregroundStyle(CarbInTheme.ink)
                            Text(localization.text(
                                "%@ carbohydrates",
                                arguments: analysis.overallRange.map(localization.carbohydrateRange) ?? localization.text("No range")
                            ))
                                .font(CarbInTheme.display(.title3, size: 19))
                                .foregroundStyle(CarbInTheme.moss)
                        }
    }

    private var reviewStatusIcon: some View {
        Image(systemName: saved ? "checkmark.seal.fill" : "doc.text.magnifyingglass")
            .font(CarbInTheme.display(.title2, size: 22))
            .foregroundStyle(saved ? CarbInTheme.actionInk : CarbInTheme.tomato)
            .frame(width: 52, height: 52)
            .background(saved ? CarbInTheme.basilAction : CarbInTheme.tomatoSoft.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .rotationEffect(saved ? .degrees(-4) : .zero)
            .accessibilityHidden(true)
    }

    private var savedDetail: String {
        switch analysis.source {
        case .personalPhoto:
            localization.text("Only this compact review was saved on this device. Your selected photo was not copied into history.")
        case .demo:
            localization.text("Only this compact review was saved on this device. The Practice image was not copied into history.")
        case .manual:
            localization.text("Only this compact review was saved on this device. No photo was attached to this meal.")
        }
    }

    private func saveReview() {
        if LocalReviewStore.save(analysis: analysis) {
            saved = true
        } else {
            showSaveError = true
        }
    }
}

private struct IngredientEditorSheet: View {
    @Binding var analysis: MealAnalysis
    @Environment(\.dismiss) private var dismiss
    @State private var showManualEntry = false
    @EnvironmentObject private var localization: LocalizationStore

    var body: some View {
        NavigationStack {
            ZStack {
                CountertopBackdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                    Text("Confirm whether each item belongs in the total, then choose the closest portion. These local reference ranges are a starting point—not a substitute for a product label or your own trusted carb-counting method.")
                        .font(CarbInTheme.reading(.footnote, size: 13))
                        .foregroundStyle(CarbInTheme.mutedInk)
                        .workbenchSurface()

                    Text("Meal items")
                        .font(CarbInTheme.display(.title3, size: 19))
                        .foregroundStyle(CarbInTheme.ink)
                    ForEach(analysis.components.indices, id: \.self) { index in
                        let component = analysis.components[index]
                        VStack(alignment: .leading, spacing: 10) {
                            Toggle(isOn: $analysis.components[index].isIncluded) {
                                Text(display(component.name, treatment: component.nameTreatment))
                            }
                                .tint(CarbInTheme.moss)
                            Text(display(component.detail, treatment: component.detailTreatment))
                                .font(CarbInTheme.reading(.footnote, size: 13))
                                .foregroundStyle(CarbInTheme.mutedInk)

                            if component.isIncluded {
                                Picker(
                                    localization.text(
                                        "Portion for %@",
                                        arguments: display(component.name, treatment: component.nameTreatment)
                                    ),
                                    selection: $analysis.components[index].portion
                                ) {
                                    ForEach(PortionAdjustment.allCases) { adjustment in
                                        Text(LocalizedStringKey(adjustment.title)).tag(adjustment)
                                    }
                                }
                                .pickerStyle(.menu)
                                .accessibilityHint("Changes the local carbohydrate range for this ingredient.")
                            }
                        }
                        .workbenchSurface()
                    }

                    Button {
                        showManualEntry = true
                    } label: {
                        Label("Add a verified carbohydrate item", systemImage: "plus.circle")
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    }
                    .foregroundStyle(CarbInTheme.moss)
                    .workbenchSurface()
                    .accessibilityHint("Add a carbohydrate amount from packaging or your own trusted reference.")
                    .accessibilityIdentifier("carbin.ingredient.addVerified")
                    }
                    .frame(maxWidth: 720, alignment: .leading)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                }
            }
            .kitchenNavigationTitle("Adjust ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showManualEntry) {
                ManualCarbEntrySheet { component in
                    analysis.components.append(component)
                }
            }
        }
    }

    private func display(_ value: String, treatment: MealTextTreatment) -> String {
        MealTextResolver.resolve(value, treatment: treatment, localize: { localization.text($0) })
    }
}

private struct ManualCarbEntrySheet: View {
    let onAdd: (MealComponent) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @State private var name = ""
    @State private var grams = ""

    var body: some View {
        NavigationStack {
            ZStack {
                CountertopBackdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                    Text("Add a verified item")
                        .font(CarbInTheme.display(.title3, size: 19))
                        .foregroundStyle(CarbInTheme.ink)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Item name")
                            .font(.subheadline.weight(.semibold))
                        TextField("For example, packaged drink", text: $name)
                            .textInputAutocapitalization(.words)
                            .accessibilityLabel("Item name")
                            .accessibilityIdentifier("carbin.ingredient.name")
                    }
                    .workbenchSurface()
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Carbohydrates in whole grams")
                            .font(.subheadline.weight(.semibold))
                        TextField("For example, 18", text: $grams)
                            .keyboardType(.numberPad)
                            .accessibilityLabel("Carbohydrates in whole grams")
                            .accessibilityIdentifier("carbin.ingredient.grams")
                    }
                    .workbenchSurface()

                    if !grams.isEmpty && !isValidGrams {
                        Label("Enter a whole number from 0 to 500.", systemImage: "exclamationmark.circle")
                            .font(CarbInTheme.reading(.footnote, size: 13))
                            .foregroundStyle(CarbInTheme.terracotta)
                    }

                    Text("Use a package label or another trusted source. This field records carbohydrates only; it never calculates insulin.")
                        .font(CarbInTheme.reading(.footnote, size: 13))
                        .foregroundStyle(CarbInTheme.mutedInk)
                        .workbenchSurface()
                    }
                    .frame(maxWidth: 720, alignment: .leading)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                }
            }
            .kitchenNavigationTitle("Add item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addItem() }
                        .disabled(!canAdd)
                        .accessibilityHint(Text(LocalizedStringKey(canAdd ? "Adds this verified carbohydrate amount to the review." : "Enter an item name and a whole carbohydrate amount from 0 to 500 grams first.")))
                        .accessibilityIdentifier("carbin.ingredient.confirm")
                }
            }
        }
    }

    private func addItem() {
        guard let value = parsedGrams else { return }
        onAdd(
            MealComponent(
                id: UUID().uuidString,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                detail: "Verified amount you entered",
                carbohydrates: CarbRange(low: value, high: value),
                symbol: "checkmark.seal.fill",
                signal: "Your verified entry",
                nameTreatment: .verbatimUser
            )
        )
        dismiss()
    }

    private var isValidGrams: Bool {
        parsedGrams != nil
    }

    private var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isValidGrams
    }

    private var parsedGrams: Int? {
        WholeGramParser.parse(grams, locale: locale)
    }
}

private struct HowItWorksView: View {
    let onReplayOnboarding: () -> Void

    var body: some View {
        ScreenScroll {
            VStack(alignment: .leading, spacing: 24) {
                SectionHeading(
                    eyebrow: "THE APPROACH",
                    title: "Make the estimate inspectable.",
                    detail: "A photo alone cannot reliably understand portions, recipes, or ingredients hidden by the frame. MealMirror is designed around that reality."
                )

                VStack(spacing: 0) {
                    HowItWorksStep(number: "01", symbol: "camera.viewfinder", title: "Show the meal", detail: "Take a photo or choose one from your library, then describe the foods you can identify. You can record a familiar reference object for your own review; it does not alter the carbohydrate range.")
                    HowItWorksStep(number: "02", symbol: "cpu", title: "Check possible food clues", detail: "Apple Vision can suggest food words on-device. Possible matches start excluded; you choose what belongs, and local reference ranges—not the photo—supply the example carbohydrate values.")
                    HowItWorksStep(number: "03", symbol: "checkmark.circle", title: "Keep your judgment", detail: "Adjust portions, remove a mismatch, add a verified carbohydrate item, and decide whether to save a local note. There is no dose recommendation.")
                }
                .mealTicket()

                VStack(alignment: .leading, spacing: 9) {
                    Text("What MealMirror can and cannot do")
                        .font(CarbInTheme.display(.headline, size: 16))
                        .foregroundStyle(CarbInTheme.ink)
                    Text("Apple Vision can inspect a chosen photo locally, while your description drives the ingredient review. MealMirror shows an estimate and its uncertainty; confirm every value with a trusted source and your clinician-approved care plan.")
                        .font(CarbInTheme.reading(.footnote, size: 13))
                        .foregroundStyle(CarbInTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .mirrorCard()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Reference note")
                        .font(CarbInTheme.display(.headline, size: 16))
                        .foregroundStyle(CarbInTheme.ink)

                    Text("Confirm whether each item belongs in the total, then choose the closest portion. These local reference ranges are a starting point—not a substitute for a product label or your own trusted carb-counting method.")
                        .font(CarbInTheme.reading(.footnote, size: 13))
                        .foregroundStyle(CarbInTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Carbohydrate values can differ by recipe, product, serving, preparation, and hidden ingredients. Features may change as safety, legal, accessibility, and platform requirements evolve.")
                        .font(.caption)
                        .foregroundStyle(CarbInTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .mirrorCard()
                .accessibilityIdentifier("carbin.methodology.sources")

                Button(action: onReplayOnboarding) {
                    Label("Replay the welcome guide", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(SecondaryActionStyle())
            }
        }
        .kitchenNavigationTitle("How it works")
        .navigationBarTitleDisplayMode(.inline)
    }

}

private struct PrivacyView: View {
    @State private var reviews = LocalReviewStore.load()
    @State private var hasStoredReviewFile = LocalReviewStore.hasStoredReviewFile
    @State private var reviewLoadFailed = !LocalReviewStore.storedReviewsAreReadable
    @State private var selectedReview: SavedReview?
    @State private var pendingDeleteID: UUID?
    @State private var showDeleteAllConfirmation = false
    @State private var showDeleteError = false
    @EnvironmentObject private var localization: LocalizationStore

    private var savedCount: Int { reviews.count }

    var body: some View {
        ScreenScroll {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Local review history")
                        .font(CarbInTheme.display(.largeTitle, size: 30))
                        .foregroundStyle(CarbInTheme.ink)
                    Text("Your meal stays close.")
                        .font(CarbInTheme.reading(.body, size: 17, weight: .semibold))
                        .foregroundStyle(CarbInTheme.mutedInk)
                }
                VStack(alignment: .leading, spacing: 12) {
                    if reviewLoadFailed {
                        Label("Review needed", systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CarbInTheme.terracotta)
                            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                    } else {
                        Text(savedCount == 1
                             ? localization.text("1 local review is saved on this device.")
                             : localization.text("%lld local reviews are saved on this device.", arguments: Int64(savedCount)))
                            .font(CarbInTheme.reading(.subheadline, size: 15))
                            .foregroundStyle(CarbInTheme.mutedInk)
                    }

                    if reviews.isEmpty, !reviewLoadFailed {
                        Label("No saved reviews yet", systemImage: "tray")
                            .font(CarbInTheme.reading(.subheadline, size: 15))
                            .foregroundStyle(CarbInTheme.mutedInk)
                            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(Array(reviews.enumerated()), id: \.element.id) { index, review in
                                SavedReviewRow(
                                    review: review,
                                    index: index,
                                    onOpen: { selectedReview = review },
                                    onDelete: { pendingDeleteID = review.id }
                                )
                            }
                        }
                    }

                    Button(role: .destructive) {
                        showDeleteAllConfirmation = true
                    } label: {
                        Text("Delete all saved reviews")
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .foregroundStyle(CarbInTheme.terracotta)
                    .disabled(!hasStoredReviewFile)
                    .opacity(hasStoredReviewFile ? 1 : 0.45)
                    .accessibilityHint(Text(LocalizedStringKey(hasStoredReviewFile ? "Deletes all saved local reviews from this device." : "No local reviews are saved.")))
                    .accessibilityIdentifier("carbin.history.deleteAll")
                }
                .mirrorCard()

                Text("Privacy")
                    .font(CarbInTheme.display(.title2, size: 22))
                    .foregroundStyle(CarbInTheme.ink)

                VStack(spacing: 0) {
                    PrivacyRow(symbol: "wifi.slash", title: "No developer server", detail: "MealMirror makes no requests to a developer-operated server.")
                    PrivacyRow(symbol: "person.crop.circle.badge.xmark", title: "No account", detail: "There is no sign-in and no user profile to create.")
                    PrivacyRow(symbol: "icloud.slash", title: "Backup-excluded local storage", detail: "Reviews are saved in a device-protected local file that MealMirror excludes from backups.")
                    PrivacyRow(symbol: "photo.on.rectangle.angled", title: "Photos stay out of history", detail: "A chosen image is inspected only for the active review; saved history stores no photo.")
                }
                .mealTicket()

            }
        }
        .kitchenNavigationTitle("Local review history")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { refreshHistory() }
        .sheet(item: $selectedReview) { review in
            SavedReviewDetailView(
                review: review,
                onDelete: { delete(review.id) }
            )
        }
        .confirmationDialog(
            "Delete this saved review?",
            isPresented: Binding(
                get: { pendingDeleteID != nil },
                set: { if !$0 { pendingDeleteID = nil } }
            ),
            titleVisibility: .visible
        ) {
            if let pendingDeleteID {
                Button("Delete review", role: .destructive) {
                    // Capture the selected identifier while building the dialog.
                    // SwiftUI can dismiss the presentation binding before invoking
                    // the action, which clears the backing optional in its setter.
                    delete(pendingDeleteID)
                }
                .accessibilityIdentifier("carbin.history.delete.confirm")
            }
            Button("Cancel", role: .cancel) { pendingDeleteID = nil }
        } message: {
            Text("This removes only the selected local review. It cannot be undone.")
        }
        .alert("Delete all saved reviews?", isPresented: $showDeleteAllConfirmation) {
            Button("Delete", role: .destructive) {
                if LocalReviewStore.clear() {
                    reviews = []
                    hasStoredReviewFile = false
                    reviewLoadFailed = false
                } else {
                    showDeleteError = true
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the locally saved meal reviews from this device. It cannot be undone.")
        }
        .alert("Couldn’t delete local reviews", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The local review file could not be deleted. Try again while your device is unlocked.")
        }
    }

    private func delete(_ id: UUID) {
        pendingDeleteID = nil
        if LocalReviewStore.delete(id: id) {
            reviews.removeAll { $0.id == id }
            hasStoredReviewFile = LocalReviewStore.hasStoredReviewFile
            if selectedReview?.id == id { selectedReview = nil }
        } else {
            showDeleteError = true
        }
    }

    private func refreshHistory() {
        reviews = LocalReviewStore.load()
        hasStoredReviewFile = LocalReviewStore.hasStoredReviewFile
        reviewLoadFailed = !LocalReviewStore.storedReviewsAreReadable
    }
}

private struct SavedReviewRow: View {
    let review: SavedReview
    let index: Int
    let onOpen: () -> Void
    let onDelete: () -> Void

    @Environment(\.locale) private var locale
    @EnvironmentObject private var localization: LocalizationStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    reviewSummary
                    Spacer(minLength: 8)
                    Text(localization.carbohydrateRange(review.range))
                        .font(.subheadline.monospacedDigit().weight(.bold))
                        .foregroundStyle(CarbInTheme.moss)
                }
                VStack(alignment: .leading, spacing: 4) {
                    reviewSummary
                    Text(localization.carbohydrateRange(review.range))
                        .font(.subheadline.monospacedDigit().weight(.bold))
                        .foregroundStyle(CarbInTheme.moss)
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) { rowActions }
                VStack(spacing: 8) { rowActions }
            }
        }
        .padding(12)
        .background(CarbInTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CarbInTheme.line.opacity(0.7), lineWidth: 1)
        }
    }

    private var reviewSummary: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(MealTextResolver.resolve(
                review.mealName,
                treatment: review.mealNameTreatment,
                localize: { localization.text($0) }
            ))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CarbInTheme.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("carbin.history.item.\(index)")
            Text(review.createdAt.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened).locale(locale)))
                .font(.caption)
                .foregroundStyle(CarbInTheme.mutedInk)
        }
    }

    @ViewBuilder
    private var rowActions: some View {
        Button(action: onOpen) {
            Label("View details", systemImage: "doc.text.magnifyingglass")
        }
        .buttonStyle(CompactActionStyle())
        .accessibilityIdentifier("carbin.history.open.\(index)")

        Button(role: .destructive, action: onDelete) {
            Label("Delete review", systemImage: "trash")
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        .foregroundStyle(CarbInTheme.terracotta)
        .accessibilityIdentifier("carbin.history.delete.\(index)")
    }
}

private struct SavedReviewDetailView: View {
    let review: SavedReview
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @EnvironmentObject private var localization: LocalizationStore
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScreenScroll {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeading(
                        eyebrow: "SAVED ON THIS DEVICE",
                        title: review.mealName,
                        detail: "This compact record contains no photo and can be deleted at any time.",
                        titleTreatment: review.mealNameTreatment
                    )

                    VStack(alignment: .leading, spacing: 14) {
                        LabeledContent("Carbohydrate range") {
                            Text(localization.carbohydrateRange(review.range))
                                .font(.headline.monospacedDigit())
                                .foregroundStyle(CarbInTheme.moss)
                        }
                        LabeledContent("Saved") {
                            Text(review.createdAt.formatted(Date.FormatStyle(date: .long, time: .shortened).locale(locale)))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .mirrorCard()

                    if review.items.isEmpty {
                        Text("This older saved review contains only the total range. Its individual sources were not saved.")
                            .font(.subheadline)
                            .foregroundStyle(CarbInTheme.mutedInk)
                            .mirrorCard()
                    } else {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(localization.text("What shaped the range"))
                                .font(.headline)
                                .foregroundStyle(CarbInTheme.ink)
                            ForEach(review.items) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(MealTextResolver.resolve(item.name, treatment: item.nameTreatment, localize: { localization.text($0) }))
                                        .font(.subheadline.weight(.semibold))
                                    Text(localization.text("%@ portion", arguments: localization.text(item.portion.title)))
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(CarbInTheme.moss)
                                    Text(localization.carbohydrateRange(item.carbohydrates))
                                        .font(.subheadline.monospacedDigit())
                                    Text(MealTextResolver.resolve(item.source, treatment: item.sourceTreatment, localize: { localization.text($0) }))
                                        .font(.caption)
                                        .foregroundStyle(CarbInTheme.mutedInk)
                                }
                                .accessibilityElement(children: .combine)
                            }
                            Text(localization.text("A photo cannot reveal every ingredient or portion. Confirm the foods, adjust portions, and prefer a package label or trusted reference when available."))
                                .font(.caption)
                                .foregroundStyle(CarbInTheme.mutedInk)
                            Text(localization.text("This estimate is not a dose calculator. Use the approach and care plan you and your diabetes team have agreed on."))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CarbInTheme.terracotta)
                        }
                        .mirrorCard()
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete this review", systemImage: "trash")
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .contentShape(Rectangle())
                    }
                    .foregroundStyle(CarbInTheme.terracotta)
                    .accessibilityIdentifier("carbin.history.detail.delete")
                }
            }
            .kitchenNavigationTitle("Saved review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityIdentifier("carbin.history.detail.close")
                }
            }
            .alert("Delete this saved review?", isPresented: $showDeleteConfirmation) {
                Button("Delete review", role: .destructive) { onDelete() }
                    .accessibilityIdentifier("carbin.history.detail.delete.confirm")
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes only this local record. It cannot be undone.")
            }
        }
    }
}

private struct ScreenScroll<Content: View>: View {
    let maxWidth: CGFloat
    @ViewBuilder let content: Content
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(maxWidth: CGFloat = 840, @ViewBuilder content: () -> Content) {
        self.maxWidth = maxWidth
        self.content = content()
    }

    var body: some View {
        ZStack {
            CountertopBackdrop()
            ScrollView {
                content
                    .frame(maxWidth: maxWidth, alignment: .leading)
                    .padding(.horizontal, horizontalSizeClass == .regular ? 32 : 16)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .toolbarBackground(CarbInTheme.canvas, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

private struct SectionHeading: View {
    let eyebrow: String
    let title: String
    let detail: String
    let titleTreatment: MealTextTreatment
    let detailTreatment: MealTextTreatment
    @EnvironmentObject private var localization: LocalizationStore

    init(
        eyebrow: String,
        title: String,
        detail: String,
        titleTreatment: MealTextTreatment = .localizedCatalog,
        detailTreatment: MealTextTreatment = .localizedCatalog
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.detail = detail
        self.titleTreatment = titleTreatment
        self.detailTreatment = detailTreatment
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(eyebrow))
                .font(CarbInTheme.display(.caption1, size: 13))
                .tracking(localization.language.supportsDecorativeTracking ? 0.8 : 0)
                .foregroundStyle(CarbInTheme.ink)
            Text(MealTextResolver.resolve(title, treatment: titleTreatment, localize: { localization.text($0) }))
                .font(CarbInTheme.display(.title1, size: 29))
                .foregroundStyle(CarbInTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(MealTextResolver.resolve(detail, treatment: detailTreatment, localize: { localization.text($0) }))
                .font(CarbInTheme.reading(.body, size: 17))
                .foregroundStyle(CarbInTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct MealChoiceCard: View {
    let meal: DemoMeal
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var localization: LocalizationStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 9) {
                DemoMealImage(meal: meal)
                    .frame(width: cardWidth - 20, height: dynamicTypeSize.isAccessibilitySize ? 128 : 108)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                    .accessibilityHidden(true)

                Text(localization.text(meal.name))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CarbInTheme.ink)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(meal.analysis(description: meal.prompt, referenceItemPresent: false).overallRange.map(localization.carbohydrateRange) ?? localization.text("Review needed"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(CarbInTheme.moss)
            }
            .frame(width: cardWidth, alignment: .topLeading)
            .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 260 : 205, alignment: .topLeading)
            .padding(10)
            .background(isSelected ? CarbInTheme.basilSoft : CarbInTheme.ticket, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? CarbInTheme.tomato : CarbInTheme.line, lineWidth: isSelected ? 3 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            localization.text("Practice meal") + ". "
            + localization.text(
                "%@, %@ carbohydrate range%@",
                arguments: localization.text(meal.name),
                meal.analysis(description: meal.prompt, referenceItemPresent: false).overallRange.map(localization.carbohydrateRange) ?? localization.text("Review needed"),
                isSelected ? localization.text(", selected") : ""
            )
        )
        .accessibilityHint("Use a bundled Practice meal to learn the review controls. Practice values are examples, not an analysis of your meal.")
        .accessibilityIdentifier("carbin.practice.\(meal.id)")
    }

    private var cardWidth: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 260 : 190
    }
}

private enum PhotoPreviewEmptyState {
    case mealEntry
    case descriptionReview

    var titleKey: String {
        switch self {
        case .mealEntry:
            "Your meal starts empty"
        case .descriptionReview:
            "No photo selected"
        }
    }

    var detailKey: String {
        switch self {
        case .mealEntry:
            "Start with a photo or a few words. Add context when a picture leaves questions."
        case .descriptionReview:
            "No photo was selected, so the review uses only the meal description."
        }
    }
}

private struct PhotoPreview: View {
    let meal: DemoMeal
    let selectedPhoto: UIImage?
    let source: MealInputSource
    let aspectRatio: CGFloat
    let emptyState: PhotoPreviewEmptyState
    @EnvironmentObject private var localization: LocalizationStore

    var body: some View {
        SwiftUI.Group {
            if let selectedPhoto {
                Image(uiImage: selectedPhoto)
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .clipped()
            } else if source == .demo {
                DemoMealImage(meal: meal)
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .clipped()
            } else {
                ZStack {
                    CarbInTheme.elevatedSurface
                    VStack(spacing: 10) {
                        Image(systemName: "fork.knife")
                            .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                            .foregroundStyle(CarbInTheme.moss)
                        Text(LocalizedStringKey(emptyState.titleKey))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CarbInTheme.ink)
                        Text(LocalizedStringKey(emptyState.detailKey))
                            .font(.caption)
                            .foregroundStyle(CarbInTheme.mutedInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .multilineTextAlignment(.center)
                    .padding(28)
                }
                .frame(maxWidth: .infinity, minHeight: 180)
            }
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .pixelCorners(color: selectedPhoto == nil ? CarbInTheme.basil : CarbInTheme.tomato, inset: 10)
        .accessibilityLabel(
            selectedPhoto != nil
                ? localization.text("Selected meal photo")
                : source == .demo
                    ? localization.text("Practice photo of %@", arguments: localization.text(meal.name))
                    : emptyStateAccessibilityLabel
        )
    }

    private var emptyStateAccessibilityLabel: String {
        localization.text(emptyState.titleKey)
            + ". "
            + localization.text(emptyState.detailKey)
    }
}

private struct DemoMealImage: View {
    let meal: DemoMeal

    var body: some View {
        if let image = DemoMealImageLoader.image(named: meal.imageName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                CarbInTheme.elevatedSurface
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(CarbInTheme.mutedInk)
            }
        }
    }
}

private enum DemoMealImageLoader {
    static func image(named name: String) -> UIImage? {
        guard let url = Bundle.module.url(forResource: name, withExtension: "png") else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}

private struct ConfidenceTrail: View {
    let descriptionProvided: Bool
    let referenceItemPresent: Bool
    let visionStatus: VisionStatus
    let source: MealInputSource
    @EnvironmentObject private var localization: LocalizationStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    trailTitle
                    Spacer()
                    trailSubtitle
                }
                VStack(alignment: .leading, spacing: 3) {
                    trailTitle
                    trailSubtitle
                }
            }

            EvidenceRow(
                symbol: "camera.viewfinder",
                title: "On-device photo inspection",
                detail: photoInspectionDetail,
                isActive: false
            )
            EvidenceRow(symbol: "text.alignleft", title: "Your description", detail: descriptionProvided ? "Added to the review" : "Not provided", isActive: descriptionProvided)
            EvidenceRow(
                symbol: "ruler.fill",
                title: "Reference note",
                detail: referenceItemPresent ? "Recorded only; it does not change this range" : "Not recorded",
                isActive: referenceItemPresent
            )
        }
        .insetControlGroup(inset: 12)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Review trail: possible photo matches are suggestions only and start excluded. Only the foods and portions you confirm affect the displayed carbohydrate range.")
    }

    private var photoInspectionDetail: String {
        switch visionStatus {
        case .notRun:
            source == .demo ? "Not run for this Practice meal" : "No photo selected"
        case let .inspected(labels):
            labels.isEmpty
                ? "Inspected locally; no clear food clues found"
                : localizedPhotoClues(labels)
        case .unavailable:
            "Photo selected; inspection unavailable"
        }
    }

    private func localizedPhotoClues(_ labels: [String]) -> String {
        let names = labels.joined(separator: ", ")
        let isolatedNames = localization.language.isRightToLeft ? "\u{2068}\(names)\u{2069}" : names
        return localization.text("Photo inspected on this device. Visual cues: %@.", arguments: isolatedNames)
            + " "
            + localization.text("Add the foods you recognize to build an inspectable carbohydrate range.")
    }

    private var trailTitle: some View {
        Text("Review trail")
            .font(CarbInTheme.display(.headline, size: 17))
            .foregroundStyle(CarbInTheme.ink)
    }

    private var trailSubtitle: some View {
        Text("How inputs were handled")
            .font(.caption)
            .foregroundStyle(CarbInTheme.mutedInk)
    }
}

private struct EvidenceRow: View {
    let symbol: String
    let title: String
    let detail: String
    let isActive: Bool
    @EnvironmentObject private var localization: LocalizationStore

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isActive ? CarbInTheme.moss : CarbInTheme.mutedInk)
                .frame(width: 32, height: 32)
                .background(isActive ? CarbInTheme.basilSoft : CarbInTheme.inset, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(localization.text(title))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CarbInTheme.ink)
                Text(localization.text(detail))
                    .font(.caption)
                    .foregroundStyle(CarbInTheme.mutedInk)
            }
            Spacer()
            Image(systemName: isActive ? "checkmark.circle.fill" : "minus.circle")
                .foregroundStyle(isActive ? CarbInTheme.moss : CarbInTheme.mutedInk)
                .accessibilityHidden(true)
        }
    }
}

private struct ComponentRow: View {
    let component: MealComponent
    @EnvironmentObject private var localization: LocalizationStore
    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize || (layoutDirection == .rightToLeft && horizontalSizeClass != .regular) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        componentIcon
                        rangeText
                    }
                    componentDetails
                }
            } else {
                HStack(spacing: 13) {
                    componentIcon
                    componentDetails
                    Spacer(minLength: 8)
                    rangeText
                }
            }
        }
        .padding(.vertical, 11)
        .overlay(alignment: .bottom) {
            Rectangle().fill(CarbInTheme.line.opacity(0.40)).frame(height: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var componentIcon: some View {
        Image(systemName: component.symbol)
            .font(.body.weight(.medium))
            .foregroundStyle(CarbInTheme.basil)
            .frame(width: 38, height: 38)
            .background(CarbInTheme.basilSoft, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .accessibilityHidden(true)
    }

    private var componentDetails: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(display(component.name, treatment: component.nameTreatment))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CarbInTheme.ink)
            Text(
                display(component.detail, treatment: component.detailTreatment)
                + " • "
                + display(component.signal, treatment: component.signalTreatment)
                + (component.portion == .usual
                   ? ""
                   : " • " + localization.text("%@ portion", arguments: localization.text(component.portion.title)))
            )
                .font(.caption)
                .foregroundStyle(CarbInTheme.mutedInk)
        }
    }

    private var rangeText: some View {
        Text(component.isIncluded ? localization.carbohydrateRange(component.carbohydrates) : localization.text("Excluded"))
            .font(.subheadline.monospacedDigit().weight(.semibold))
            .foregroundStyle(component.isIncluded ? CarbInTheme.moss : CarbInTheme.mutedInk)
            .accessibilityLabel(component.isIncluded
                ? localization.text("%lld to %lld grams", arguments: Int64(component.carbohydrates.low), Int64(component.carbohydrates.high))
                : localization.text("Excluded from total"))
    }

    private func display(_ value: String, treatment: MealTextTreatment) -> String {
        MealTextResolver.resolve(value, treatment: treatment, localize: { localization.text($0) })
    }
}

private struct ReviewFact: View {
    let symbol: String
    let title: String
    let value: String
    let valueTreatment: MealTextTreatment
    @EnvironmentObject private var localization: LocalizationStore

    init(
        symbol: String,
        title: String,
        value: String,
        valueTreatment: MealTextTreatment = .localizedCatalog
    ) {
        self.symbol = symbol
        self.title = title
        self.value = value
        self.valueTreatment = valueTreatment
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(CarbInTheme.moss)
                .frame(width: 20)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(localization.text(title))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CarbInTheme.mutedInk)
                Text(MealTextResolver.resolve(value, treatment: valueTreatment, localize: { localization.text($0) }))
                    .font(CarbInTheme.reading(.subheadline, size: 15))
                    .foregroundStyle(CarbInTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct HowItWorksStep: View {
    let number: String
    let symbol: String
    let title: String
    let detail: String
    @EnvironmentObject private var localization: LocalizationStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutDirection) private var layoutDirection

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize || layoutDirection == .rightToLeft {
                VStack(alignment: .leading, spacing: 12) {
                    stepMarker
                    stepCopy
                }
            } else {
                HStack(alignment: .top, spacing: 16) {
                    stepMarker
                    stepCopy
                }
            }
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle().fill(CarbInTheme.line.opacity(0.40)).frame(height: 1)
        }
    }

    private var stepMarker: some View {
        VStack(spacing: 8) {
            Text(number)
                .font(.system(.caption, design: .monospaced).weight(.bold))
                .foregroundStyle(CarbInTheme.canvas)
                .frame(width: 34, height: 24)
                .background(CarbInTheme.terracotta)
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(CarbInTheme.moss)
                .frame(width: 42, height: 42)
                .background(CarbInTheme.mossSoft, in: RoundedRectangle(cornerRadius: 8))
                .accessibilityHidden(true)
        }
    }

    private var stepCopy: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(localization.text(title))
                .font(CarbInTheme.display(.headline, size: 16))
                .foregroundStyle(CarbInTheme.ink)
            Text(localization.text(detail))
                .font(CarbInTheme.reading(.subheadline, size: 15))
                .foregroundStyle(CarbInTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct PrivacyRow: View {
    let symbol: String
    let title: String
    let detail: String
    @EnvironmentObject private var localization: LocalizationStore

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(CarbInTheme.basil)
                .frame(width: 38, height: 38)
                .background(CarbInTheme.basilSoft, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(localization.text(title))
                    .font(CarbInTheme.display(.headline, size: 16))
                    .foregroundStyle(CarbInTheme.ink)
                Text(localization.text(detail))
                    .font(CarbInTheme.reading(.subheadline, size: 15))
                    .foregroundStyle(CarbInTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle().fill(CarbInTheme.line.opacity(0.40)).frame(height: 1)
        }
    }
}
