import SwiftUI

@main
struct CarbInApp: App {
    @StateObject private var localization = LocalizationStore()

    init() {
#if DEBUG
        // UI tests opt into an isolated local-history state. This code is not
        // compiled into Release and never runs for an ordinary app launch.
        if ProcessInfo.processInfo.arguments.contains("-carbin.ui-test.reset-local-data") {
            _ = LocalReviewStore.clear()
        }
#endif
    }

    var body: some Scene {
        WindowGroup {
            CarbInRootView()
                .environmentObject(localization)
                .environment(\.locale, localization.language.locale)
                .environment(\.layoutDirection, localization.language.layoutDirection)
        }
    }
}
