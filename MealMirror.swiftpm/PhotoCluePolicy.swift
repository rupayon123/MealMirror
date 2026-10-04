import Foundation
import MealCore

enum PhotoCluePolicy {
    static func components(
        matching labels: [String],
        locale: Locale,
        localizedKeyword: (String) -> String
    ) -> [MealComponent] {
        let matches = MealIngredientCatalog.components(
            matchingLabels: labels,
            locale: locale,
            localizedKeyword: localizedKeyword
        )

        // Vision can emit both a parent category and its child for one food.
        // Do not offer a second carbohydrate item for a generic "fruit" label
        // when a berry or banana clue already explains it. An independently
        // named fruit can still be a separate item for the person to review.
        let hasSpecificFruit = matches.contains { $0.id == "berries" || $0.id == "banana" }
        let hasOtherNamedFruit = labels.contains { label in
            switch label.lowercased().replacingOccurrences(of: "_", with: " ") {
            case "apple", "whole orange", "fresh orange", "citrus fruit": true
            default: false
            }
        }
        guard hasSpecificFruit && !hasOtherNamedFruit else { return matches }
        return matches.filter { $0.id != "fruit" }
    }
}
