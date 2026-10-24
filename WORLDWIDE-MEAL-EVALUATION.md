# Worldwide meal photo evaluation

Refreshed October 24, 2026.

MealMirror should work for the meal a person chooses, whether it is cooked at home, bought, packed for school, or served at a celebration. The optional Foundation Models image path, Vision fallback and small reference catalog have **not** been shown to recognize arbitrary meals. This document is the acceptance plan for expanding coverage without claiming that a picture reveals a recipe, portion, or carbohydrate amount.

## Current usable path

A person may add up to three views of a meal and one nutrition-label photo. All selected images are processed on the device. On supported iOS 27 devices, the optional Foundation Models path checks model readiness, vision/guided-generation capabilities and language before requesting tentative names for main foods, dishes or clearly visible drinks. The current instructions prefer whole dishes or broad categories, tell the model to avoid ingredient decomposition and synonymous duplicates, and retain snacks, desserts and drinks within scope. Instructions do not guarantee model compliance. Those names stay separate from carbohydrate items; tapping one only prefills an editable name and still requires a checked amount. A successful empty model result stays unknown. Unavailable/error/timeout paths retain local Vision/manual review. Food labels from Vision are only possible clues and start outside the carbohydrate total. The label reader presents raw text beside the original image; the person checks the serving size and enters any carbohydrate amount themselves. A meal outside the local catalog can still be described and recorded with a trusted, manually entered amount. These paths support varied foods but do not prove recognition or nutritional accuracy.

## Current evidence is not held-out evaluation

The [central Foundation Models evidence](research/foundation-models/README.md) retains the earlier native Mac comparison and original-prompt failures. The later iOS checks below used unchanged processing code from historical commit `c49c209` and ZIP `6457bc79…`; they must not be described as runs of the newly applied prompt.

The [five additional iOS matrix diagnostics](research/foundation-models/ios-diagnostics-20261024.json) establish bounded mechanics:

| Scope | Observed evidence | Limit |
| --- | --- | --- |
| Direct inspector input bounds | Zero and four image inputs returned unavailable/failed. | Direct entry checks, not wholesale engine rejection or semantic abstention. |
| Image preparation | Four procedural cases, up and left-mirrored at scales 1 and 2, satisfied the 768-pixel bound and orientation-aware corner/aspect comparisons. | These cases do not cover every camera format, orientation or color condition. |
| Three views of one meal | Three views derived from one bundled synthetic example returned names with zero amount components, no total and no review readiness. | No real multi-view accuracy, portion or extra-serving inference is established. |
| Procedural nonfood pattern | A generated shape pattern completed with an empty accepted-name list. | One control is not broad nonfood validation. |
| Cancellation and recovery | Cancellation after an external entry witness returned cancelled; one subsequent request completed after awaiting that result. | The witness does not prove internal generation started, or that OS computation stopped. |

The same historical prompt also completed one fixed request for each of six varied Commons meal photos and two nonfood objects. Broad clues were useful, but visual review found unsupported soup/taco `garlic`, unsupported sandwich `cheese`, an ambiguous taco `red pepper`, and duplicated `green onions`/`scallions`. Successful empty lists for the mugs and shoes are distinct from errors. Exact image rights, hashes and expectations were frozen before those requests; image bytes remain outside the repository and ZIP.

The current `main-visible-food-v1` text, source SHA-256 `143feea02ca5918360904cdbbfc4f17d8ea6acd87eda8edf2e4f2ba60ee0290c`, was then tested once per image in a separate iOS bundle and applied to source. This is [tuning on the same eight exposed images](research/foundation-models/main-visible-food-20261024.json), with a [qualitative review](research/foundation-models/main-visible-food-20261024-review.md). Observed outputs became `soup`, `tacos` and `sandwich`, avoiding the earlier questionable ingredient lists and synonym duplicate in those calls. Flatbread became more specific, but its topping remained generic `sauce`. Pasta still decomposed into `noodles`, `meat`, `vegetables` and `sauce` despite the whole-dish instruction. Plantain identity remains tentative. One baseline/proposal call per exposed image does not prove a reliable or causal improvement.

Three separately frozen scope checks returned `apple`, `cake` and `milk`, retaining a whole-fruit snack, dessert and visible beverage in these examples. There are no baseline calls on these three. White liquid supports a milk-like appearance clue, not verified dairy, plant source, fat content, sweetening, volume or nutrition. These small purposive collections are not the independent acceptance set below, a worldwide benchmark or clinical validation. Every successful proposal result retained zero amount components, no automatic total and no review readiness. Final package identity and verification belong in [readiness](CHALLENGE-READINESS.md); historical ZIP builds do not prove the newly packaged prompt builds or completes its journey.

A later [combined build-5 processing case](research/foundation-models/combined-label-20261024.json) used three correlated views of the already exposed soup photo, plus one separate synthetic nutrition-label image. The actual engine/model/OCR sources returned tentative `soup`, separately transcribed the fabricated `Total Carbohydrate 37 g` line, and created no amount components, total or review readiness. This adds combined pipeline/separation evidence, not new meal diversity, independent camera views, real-label nutrition, recognition accuracy or full app interaction. The [83 procedural image-preparation checks](research/photo-preparation/README.md) test geometry/metadata/bounds, with no food-recognition or memory-improvement claim.

Record inspected-empty, policy rejection, unavailability, timeout, guardrail and other errors separately. An error fallback must not count as correct nonfood classification. No current diagnostic establishes broad cultural coverage, nutrition, calibrated performance, full exact-app behavior or physical offline readiness. External component renders provide no recognition evidence.

## Evaluation set to collect with permission

Recruit contributors across cuisines and household practices, not demographic stereotypes. Collect independently photographed, permissioned meals with known ingredient descriptions and a documented source for any carbohydrate figure. Include:

| Coverage area | Examples to recruit | Hard cases |
| --- | --- | --- |
| East and Southeast Asian meals | Rice and noodle bowls, dumplings, congee, sushi, stir-fries, soups | Hidden noodles, sauces, fillings, rice under toppings |
| South and Central Asian meals | Biryani, roti with vegetables or lentils, plov, noodle dishes | Mixed rice, layered bread, shared plates |
| African and Middle Eastern meals | Injera with stews, jollof and sides, couscous, tagine, shawarma, mezze | Mixed grains, dips, bread portions, stews |
| Latin American and Caribbean meals | Tacos, arepas, pupusas, rice and beans, plantain dishes, soups | Fillings, tortillas, fried sides, mixed plates |
| European and North American meals | Pasta, pizza, sandwiches, casseroles, potatoes, breakfast plates | Size variation, spreads, dressings, added sugar |
| Cross-cultural and personal meals | Fusion dishes, leftovers, school lunches, restaurant specials, homemade adaptations | Unknown recipe, obscured ingredients, multiple servings |
| Snacks, desserts and drinks | Whole fruit, baked snacks, cakes, frozen desserts, milk-like drinks, juices and other visible beverages | Mixed contents, fillings, opaque liquids, unsupported ingredient identities |
| Packaged foods and nonfood controls | Several label languages and layouts, food packaging, empty containers, medicine boxes, pets, flowers | OCR confusion, false food suggestions, serving mismatch |

Include multiple lighting conditions, phone cameras, containers, visual accessibility needs, and both single and multi-view submissions. Keep source, model-selection, and final held-out evaluation sets separate. Do not include personal images in the public repository or Challenge ZIP without explicit rights and a clear disclosure.

## Release gate for any automatic suggestion

Before expanding the local model or catalog, record per-group and overall correct food clues, wrong clues, safe abstentions, latency, memory, battery and thermal behavior, ZIP size, and failures on nonfood images. Decide pass thresholds with qualified nutrition and clinical reviewers before looking at held-out results. Review mistakes by dish and context; a high average must not hide a group that performs poorly. Never infer insulin units or a carbohydrate number from a photo-only classifier. If a view is unclear or a dish falls outside validated coverage, ask for a correction or a trusted value.

Nutrition-label OCR needs a separate evaluation across languages, serving formats, curved packages, glare, small print, and multiple products in one image. Its current output is transcription only. It must not silently select a number, multiply servings, or imply that a label describes the entire pictured meal.
