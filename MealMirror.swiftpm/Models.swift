import Foundation
import MealCore

enum MealInputSource: String, Codable, Hashable {
    case demo
    case manual
    case personalPhoto

    var title: String {
        switch self {
        case .demo: "Practice meal"
        case .manual: "Meal description"
        case .personalPhoto: "Your on-device photo"
        }
    }
}

enum VisionStatus: Hashable, Sendable {
    case notRun
    case inspected(labels: [String])
    case unavailable

    var isInspected: Bool {
        if case .inspected = self { return true }
        return false
    }

    var detail: String {
        switch self {
        case .notRun:
            "No photo inspection was run."
        case let .inspected(labels):
            labels.isEmpty
                ? "Photo inspected on this device, but no clear food labels were found."
                : "Possible visual clues: \(labels.joined(separator: ", ")). Confirm what you recognize."
        case .unavailable:
            "The photo remains on this device, but visual inspection was unavailable. Your description still drives the review."
        }
    }
}

enum LabelTextStatus: Hashable, Sendable {
    case notRun
    case read(lines: [String])
    case unavailable
}

struct MealAnalysis: Hashable {
    var title: String
    var description: String
    var source: MealInputSource
    var components: [MealComponent]
    var referenceItemPresent: Bool
    var visionStatus: VisionStatus
    var labelTextStatus: LabelTextStatus
    var methodNote: String
    var uncertaintyNote: String

    var includedComponents: [MealComponent] {
        components.filter(\.isIncluded)
    }

    var overallRange: CarbRange? {
        CarbRange.total(of: includedComponents.map(\.carbohydrates))
    }

    var isReadyForReview: Bool {
        overallRange != nil
    }

    var currentUncertaintyNote: String {
        let included = includedComponents
        if !included.isEmpty && included.allSatisfy({ !$0.allowsPortionAdjustment }) {
            // A trusted amount added after an unknown photo should no longer
            // tell the person to add that same amount again.
            return "Check the amount against the serving size and your trusted source. This is not dose advice."
        }
        return uncertaintyNote
    }

    static func empty() -> MealAnalysis {
        MealAnalysis(
            title: "Your meal review",
            description: "",
            source: .manual,
            components: [],
            referenceItemPresent: false,
            visionStatus: .notRun,
            labelTextStatus: .notRun,
            methodNote: "Add the foods you recognize to build an inspectable carbohydrate range.",
            uncertaintyNote: "No meal details have been entered yet."
        )
    }
}

struct DemoMeal: Identifiable, Hashable {
    let id: String
    let name: String
    let summary: String
    let imageName: String
    let prompt: String
    let components: [MealComponent]
    let uncertaintyNote: String

    func analysis(description: String, referenceItemPresent: Bool) -> MealAnalysis {
        MealAnalysis(
            title: name,
            description: description,
            source: .demo,
            components: components,
            referenceItemPresent: referenceItemPresent,
            visionStatus: .notRun,
            labelTextStatus: .notRun,
            methodNote: "Repeatable bundled Practice data. This range teaches the review flow and does not validate a real meal.",
            uncertaintyNote: uncertaintyNote
        )
    }

    static let library: [DemoMeal] = [
        DemoMeal(
            id: "biryani",
            name: "Chicken biryani plate",
            summary: "Rice, chicken, raita, and salad",
            imageName: "biryani-demo",
            prompt: "Chicken biryani with raita and salad",
            components: [
                MealComponent(name: "Basmati rice", detail: "About 1¼–1½ cups", carbohydrates: CarbRange(low: 42, high: 55), symbol: "circle.grid.2x2.fill", signal: "Visible main portion"),
                MealComponent(name: "Raita", detail: "Small side bowl", carbohydrates: CarbRange(low: 5, high: 7), symbol: "cup.and.saucer.fill", signal: "Described and visible"),
                MealComponent(name: "Cucumber salad", detail: "Small side serving", carbohydrates: CarbRange(low: 2, high: 4), symbol: "leaf.fill", signal: "Visible side portion")
            ],
            uncertaintyNote: "Rice volume and recipe ingredients can change this range."
        ),
        DemoMeal(
            id: "grain-bowl",
            name: "Lentil grain bowl",
            summary: "Quinoa, lentils, vegetables, and sauce",
            imageName: "grain-bowl-demo",
            prompt: "Lentil and roasted vegetable grain bowl",
            components: [
                MealComponent(name: "Quinoa", detail: "About ¾ cup", carbohydrates: CarbRange(low: 30, high: 39), symbol: "circle.grid.2x2.fill", signal: "Visible main portion"),
                MealComponent(name: "Lentils", detail: "About ½ cup", carbohydrates: CarbRange(low: 17, high: 22), symbol: "leaf.fill", signal: "Visible main portion"),
                MealComponent(name: "Sweet potato", detail: "About ½ cup", carbohydrates: CarbRange(low: 15, high: 20), symbol: "square.grid.2x2.fill", signal: "Visible side portion"),
                MealComponent(name: "Vegetables and sauce", detail: "Broccoli, tomatoes, tahini", carbohydrates: CarbRange(low: 8, high: 13), symbol: "drop.fill", signal: "Recipe-dependent")
            ],
            uncertaintyNote: "Sauce and grain portions are the largest sources of uncertainty."
        ),
        DemoMeal(
            id: "breakfast",
            name: "Toast and berry breakfast",
            summary: "Whole-grain toast, berries, eggs, and yogurt",
            imageName: "breakfast-demo",
            prompt: "Whole-grain toast, scrambled eggs, berries, and yogurt",
            components: [
                MealComponent(name: "Whole-grain toast", detail: "Two medium slices", carbohydrates: CarbRange(low: 28, high: 34), symbol: "rectangle.stack.fill", signal: "Visible main portion"),
                MealComponent(name: "Berries", detail: "Small side serving", carbohydrates: CarbRange(low: 10, high: 14), symbol: "circle.hexagongrid.fill", signal: "Visible side portion"),
                MealComponent(name: "Plain yogurt", detail: "Small bowl", carbohydrates: CarbRange(low: 6, high: 9), symbol: "cup.and.saucer.fill", signal: "Described and visible"),
                MealComponent(name: "Scrambled eggs", detail: "No toast spread included", carbohydrates: CarbRange(low: 1, high: 2), symbol: "sun.max.fill", signal: "Low-carbohydrate item")
            ],
            uncertaintyNote: "Bread size, yogurt type, and any spreads can change this range."
        )
    ]
}

struct SavedReviewItem: Codable, Hashable, Identifiable {
    let id: UUID
    let name: String
    let nameTreatment: MealTextTreatment
    let source: String
    let sourceTreatment: MealTextTreatment
    let portion: PortionAdjustment
    let allowsPortionAdjustment: Bool?
    let carbohydrates: CarbRange

    init(_ component: MealComponent) {
        id = UUID()
        name = component.name
        nameTreatment = component.nameTreatment
        source = component.signal
        sourceTreatment = component.signalTreatment
        portion = component.portion
        allowsPortionAdjustment = component.allowsPortionAdjustment
        carbohydrates = component.carbohydrates
    }
}

struct SavedReview: Codable, Hashable, Identifiable {
    let id: UUID
    let mealName: String
    let mealNameTreatment: MealTextTreatment
    let source: MealInputSource?
    let referenceItemPresent: Bool?
    let range: CarbRange
    let createdAt: Date
    let items: [SavedReviewItem]

    init(
        id: UUID,
        mealName: String,
        mealNameTreatment: MealTextTreatment,
        source: MealInputSource?,
        referenceItemPresent: Bool?,
        range: CarbRange,
        createdAt: Date,
        items: [SavedReviewItem] = []
    ) {
        self.id = id
        self.mealName = mealName
        self.mealNameTreatment = mealNameTreatment
        self.source = source
        self.referenceItemPresent = referenceItemPresent
        self.range = range
        self.createdAt = createdAt
        self.items = items
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case mealName
        case mealNameTreatment
        case source
        case referenceItemPresent
        case range
        case createdAt
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        mealName = try container.decode(String.self, forKey: .mealName)
        mealNameTreatment = try container.decodeIfPresent(MealTextTreatment.self, forKey: .mealNameTreatment)
            ?? .localizedCatalog
        // Older records did not retain their origin or reference selection.
        // Keep those values unknown rather than treating an example as a real meal.
        source = try container.decodeIfPresent(MealInputSource.self, forKey: .source)
        referenceItemPresent = try container.decodeIfPresent(Bool.self, forKey: .referenceItemPresent)
        range = try container.decode(CarbRange.self, forKey: .range)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        items = try container.decodeIfPresent([SavedReviewItem].self, forKey: .items) ?? []
    }
}

enum LocalReviewStore {
    private static let fileName = "CarbInReviews.json"

    private static var directoryURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("CarbIn", isDirectory: true)
    }

    private static var storageURL: URL {
        directoryURL.appendingPathComponent(fileName, isDirectory: false)
    }

    static var hasStoredReviewFile: Bool {
        FileManager.default.fileExists(atPath: storageURL.path)
    }

    static var storedReviewsAreReadable: Bool {
        !hasStoredReviewFile || (try? readStoredReviews()) != nil
    }

    static func save(analysis: MealAnalysis) -> Bool {
        guard let range = analysis.overallRange else { return false }
        let trimmedDescription = analysis.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let mealName: String
        let mealNameTreatment: MealTextTreatment
        if analysis.source != .demo, !trimmedDescription.isEmpty {
            mealName = trimmedDescription
            mealNameTreatment = .verbatimUser
        } else if analysis.source == .personalPhoto {
            // An empty-description photo analysis may use an instructional
            // heading such as "Add a little more detail". That is not a meal name.
            mealName = "Your meal review"
            mealNameTreatment = .localizedCatalog
        } else {
            mealName = analysis.title
            mealNameTreatment = .localizedCatalog
        }
        guard var reviews = try? readStoredReviews() else { return false }
        reviews.insert(
            SavedReview(
                id: UUID(),
                mealName: mealName,
                mealNameTreatment: mealNameTreatment,
                source: analysis.source,
                referenceItemPresent: analysis.referenceItemPresent,
                range: range,
                createdAt: Date(),
                items: analysis.includedComponents.map(SavedReviewItem.init)
            ),
            at: 0
        )
        return write(reviews)
    }

    static func load() -> [SavedReview] {
        (try? readStoredReviews()) ?? []
    }

    static func clear() -> Bool {
        do {
            if FileManager.default.fileExists(atPath: storageURL.path) {
                try FileManager.default.removeItem(at: storageURL)
            }
            return true
        } catch {
            return false
        }
    }

    static func delete(id: UUID) -> Bool {
        guard let current = try? readStoredReviews() else { return false }
        let updated = current.filter { $0.id != id }
        guard updated.count != current.count else { return true }
        if updated.isEmpty { return clear() }
        return write(updated)
    }

    private static func write(_ reviews: [SavedReview]) -> Bool {
        let fileManager = FileManager.default
        let temporaryURL = directoryURL.appendingPathComponent(".CarbInReviews-\(UUID().uuidString).tmp")
        defer { try? fileManager.removeItem(at: temporaryURL) }

        do {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: [.protectionKey: FileProtectionType.complete]
            )
            let data = try JSONEncoder().encode(reviews)
            try data.write(to: temporaryURL, options: .atomic)
#if !targetEnvironment(simulator)
            try fileManager.setAttributes(
                [.protectionKey: FileProtectionType.complete],
                ofItemAtPath: temporaryURL.path
            )
#endif

            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            var protectedTemporaryURL = temporaryURL
            try protectedTemporaryURL.setResourceValues(resourceValues)

            guard try storedFileSecurityIsValid(at: temporaryURL, fileManager: fileManager) else {
                return false
            }

            if fileManager.fileExists(atPath: storageURL.path) {
                _ = try fileManager.replaceItemAt(
                    storageURL,
                    withItemAt: temporaryURL,
                    options: .usingNewMetadataOnly
                )
            } else {
                try fileManager.moveItem(at: temporaryURL, to: storageURL)
            }
            return true
        } catch {
            return false
        }
    }

    private static func storedFileSecurityIsValid(at url: URL, fileManager: FileManager) throws -> Bool {
        let isExcludedFromBackup = try url
            .resourceValues(forKeys: [.isExcludedFromBackupKey])
            .isExcludedFromBackup == true
#if targetEnvironment(simulator)
        // CoreSimulator does not model iOS data-protection classes. Backup exclusion
        // remains verifiable here; the device build additionally verifies .complete.
        return isExcludedFromBackup
#else
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return isExcludedFromBackup
            && attributes[.protectionKey] as? FileProtectionType == .complete
#endif
    }

    private static func readStoredReviews() throws -> [SavedReview] {
        guard hasStoredReviewFile else { return [] }
        let data = try Data(contentsOf: storageURL)
        return try JSONDecoder().decode([SavedReview].self, from: data)
    }
}
