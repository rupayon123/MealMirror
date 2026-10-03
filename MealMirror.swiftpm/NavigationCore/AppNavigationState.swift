public enum AppRoute: Hashable, Sendable {
    case addMeal
    case estimate
    case review
    case howItWorks
    case privacy
    case settings
    case privacyPolicy
    case medicalSafety
}

public struct AppNavigationState: Equatable, Sendable {
    public var path: [AppRoute]

    public init(path: [AppRoute] = []) {
        self.path = path
    }

    public mutating func open(_ route: AppRoute) {
        path.append(route)
    }

    public mutating func beginMealReview() {
        path = [.addMeal]
    }

    public mutating func showEstimate() {
        path.append(.estimate)
    }

    public mutating func showFinalReview() {
        path.append(.review)
    }

    public mutating func resetToHome() {
        path.removeAll(keepingCapacity: true)
    }
}
