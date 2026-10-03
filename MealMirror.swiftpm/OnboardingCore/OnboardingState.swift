import Foundation

public enum OnboardingState {
    public static let completionKey = "carbin.onboarding.completed"

    public static func isComplete(in defaults: UserDefaults = .standard) -> Bool {
        defaults.bool(forKey: completionKey)
    }

    public static func setComplete(_ value: Bool, in defaults: UserDefaults = .standard) {
        defaults.set(value, forKey: completionKey)
    }
}
