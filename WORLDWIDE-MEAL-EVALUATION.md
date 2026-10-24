# Worldwide meal photo evaluation

Refreshed October 24, 2026.

MealMirror should work for the meal a person chooses, whether it is cooked at home, bought, packed for school, or served at a celebration. The optional Foundation Models image path, Vision fallback and small reference catalog have **not** been shown to recognize arbitrary meals. This document is the acceptance plan for expanding coverage without claiming that a picture reveals a recipe, portion, or carbohydrate amount.

## Current usable path

A person may add up to three views of a meal and one nutrition-label photo. All selected images are processed on the device. On supported iOS 27 devices, the optional Foundation Models path checks model readiness, vision/guided-generation capabilities and language before requesting tentative visible food names. Those names stay separate from carbohydrate items; tapping one only prefills an editable name and still requires a checked amount. A successful empty model result stays unknown. Unavailable/error/timeout paths retain local Vision/manual review. Food labels from Vision are only possible clues and start outside the carbohydrate total. The label reader presents raw text beside the original image; the person checks the serving size and enters any carbohydrate amount themselves. A meal outside the local catalog can still be described and recorded with a trusted, manually entered amount. These paths support varied foods but do not prove recognition or nutritional accuracy.

## Current evidence is not held-out evaluation

The reviewed fixed-text native Mac comparison and its original-prompt failures are recorded once in [Foundation Models evidence](research/foundation-models/README.md). The text is now applied, but previously exposed fixtures and exploratory selection prevent this comparison from serving as the independent acceptance set below. Pet empty lists do not establish broad semantic abstention. External fixture rendering also provides no recognition evidence.

Record inspected-empty, policy rejection, unavailability, timeout, guardrail and other errors separately. An error fallback must not count as correct nonfood classification. No current smoke check establishes broad cultural coverage, nutrition, calibrated performance, iOS app behavior or physical offline readiness.

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
| Packaged and nonfood controls | Several label languages and layouts, drinks, snacks, medicine boxes, pets, flowers | OCR confusion, false food suggestions, serving mismatch |

Include multiple lighting conditions, phone cameras, containers, visual accessibility needs, and both single and multi-view submissions. Keep source, model-selection, and final held-out evaluation sets separate. Do not include personal images in the public repository or Challenge ZIP without explicit rights and a clear disclosure.

## Release gate for any automatic suggestion

Before expanding the local model or catalog, record per-group and overall correct food clues, wrong clues, safe abstentions, latency, memory, battery and thermal behavior, ZIP size, and failures on nonfood images. Decide pass thresholds with qualified nutrition and clinical reviewers before looking at held-out results. Review mistakes by dish and context; a high average must not hide a group that performs poorly. Never infer insulin units or a carbohydrate number from a photo-only classifier. If a view is unclear or a dish falls outside validated coverage, ask for a correction or a trusted value.

Nutrition-label OCR needs a separate evaluation across languages, serving formats, curved packages, glare, small print, and multiple products in one image. Its current output is transcription only. It must not silently select a number, multiply servings, or imply that a label describes the entire pictured meal.
