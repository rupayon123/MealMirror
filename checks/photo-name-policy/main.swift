import Foundation

func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else { fatalError(message) }
}

let worldwideNames = ["Crème brûlée", "寿司", "عدس", "খিচুড়ি", "Phở bò", "Chana masala"]
check(
    PhotoNamePolicy.names(from: worldwideNames, visibleFood: true) == worldwideNames,
    "Letters and combining marks from worldwide food names must be preserved."
)
check(
    PhotoNamePolicy.names(from: ["  Phở   bò  ", "PHO BO", "Pho bò"], visibleFood: true) == ["Phở bò"],
    "Whitespace is collapsed; case and diacritic variants are deduplicated."
)
check(
    PhotoNamePolicy.names(from: worldwideNames, visibleFood: false).isEmpty,
    "A nonfood result must produce no clues."
)
check(
    PhotoNamePolicy.names(from: ["Döner-kebab", "Chef's rice", "Chef’s rice", "Black gram"], visibleFood: true)
        == ["Döner-kebab", "Chef's rice", "Chef’s rice", "Black gram"],
    "Supported apostrophes, hyphens and the food name black gram remain usable."
)

let malformed = [
    "", "   ", "---", "rice\nbeans", "rice\rbeans", "rice\tbeans", "rice\u{0000}",
    "rice\u{202E}beans", "rice\u{2066}beans", "rice\u{2069}beans", "rice 2", "rice ٢",
    "rice ২", "https://food.example", "www.food.example", "<rice>", "**rice**",
    "rice/beans", "rice, beans", "rice🍚", "rice ½", String(repeating: "a", count: 61),
    "a" + String(repeating: "\u{0301}", count: 480)
]
check(
    PhotoNamePolicy.names(from: malformed, visibleFood: true).isEmpty,
    "Controls, numbers, formatting, URLs, unsupported punctuation and long output must be rejected."
)

let medical = [
    "insulin", "INSULIN", "insulín", "insulin-dose", "dose of rice", "two doses",
    "units", "unit", "carbohydrate", "carbohydrates", "glucose", "grams", "bolus", "carbs"
]
check(
    PhotoNamePolicy.names(from: medical, visibleFood: true).isEmpty,
    "Obvious English medical or numeric-request tokens must be rejected."
)
check(
    PhotoNamePolicy.names(from: ["Dosai", "Doseh", "Unitas bread"], visibleFood: true)
        == ["Dosai", "Doseh", "Unitas bread"],
    "Whole-token filtering must not reject a food name because it contains a substring."
)
check(
    PhotoNamePolicy.names(from: [String(repeating: "界", count: 60)], visibleFood: true)
        == [String(repeating: "界", count: 60)],
    "The name limit counts Unicode graphemes, not UTF-8 bytes."
)
check(
    PhotoNamePolicy.names(
        from: ["Rice", "Beans", "Sushi", "Lentils", "Pasta", "Bread", "Oats"],
        visibleFood: true
    ) == ["Rice", "Beans", "Sushi", "Lentils", "Pasta", "Bread"],
    "At most six unique names must be returned, preserving accepted input order."
)
check(
    PhotoNamePolicy.names(from: Array(repeating: "", count: 32) + ["Rice"], visibleFood: true).isEmpty,
    "Candidate processing must remain bounded."
)

print("PhotoNamePolicy checks passed: worldwide names, limits, deduplication, nonfood, malformed and medical text.")
