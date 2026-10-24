# Neutral wording proposal: rejected

Recorded October 24, 2026. **This proposal was not applied to MealMirror.** The app and exact build-6 ZIP remain unchanged. [Evidence and hashes](neutral-eligibility-20261024.json), [unapplied prompt diff](neutral-eligibility-20261024.diff).

## What was tested

The current prompt presupposes meal photographs even while asking for nonfood abstention. One fixed proposal replaced that framing and separated uncertainty about food presence from uncertainty about its exact recipe. It changed only two Guides, system instructions and the request, retaining the Bool/names schema, model/default guardrails, one call, preparation, options, policy, deadline and amount separation. It is longer, not a simplification. Apple's [guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation) constrains output format; it does not establish food correctness.

An isolated source-derived iOS 27.1 QA bundle made one serial call on each of the same twelve **already exposed** images. Prior baseline calls were separate in time. Expected answers, captions and provenance text were absent from the model prompt. Fixed visual expectations are fallible AI annotations, not qualified human, material, recipe, nutrition or clinical ground truth.

All twelve calls returned inspected: nine nonempty lists and three empty. Each retained zero amount/included components, no carbohydrate total and no review readiness. Independent mechanical verification passed 30 checks. These are processing results, not twelve correct identifications.

## All returned names

| ID | Prior baseline | Candidate | Review |
| --- | --- | --- | --- |
| P01 | rice; salad; meat; drink | rice; salad; meat; drink | Unchanged broad clues; bottle contents unconfirmed. |
| P02 | ceramic bowl | empty | Object clue became empty in this call. |
| P03 | lasagna | lasagna | Exact closed-dish recipe still unconfirmed. |
| P04 | flatbread | dumpling | Lost broad flatbread clue; dumpling unsupported by the visual review. |
| P05 | pâté; sauce | patties; sauce | Patties fits the broad appearance better; composition unknown. |
| P06 | empty | empty | Inspected-empty retained. |
| P07 | brown square | brown dessert | Nonempty dessert guess fails the fixed empty gate; material remains uncertain. |
| P08 | curry; flatbread; fried potatoes | dal; chapati; potato; garlic | New unconfirmed recipe/garlic identities; hidden ingredients are not proved absent. |
| P09 | chicken; potatoes; green beans; carrots | chicken; potatoes; carrots; green beans | Same names reordered; exact green vegetable remains unconfirmed. |
| P10 | dumplings | dumplings | Broad dumpling clue retained; filling unknown. |
| P11 | fried egg; noodles; shrimp; lime | fried egg; noodles; shrimp | Visible mixed-dish decomposition remains; citrus clue lost. |
| P12 | empty | empty | Inspected-empty retained. |

## Decision

**Do not adopt.** P07 had a pre-inference inspected-empty requirement and returned `brown dessert`. Calling every clue tentative cannot waive that gate; there is no confidence field. The object remains materially uncertain. P04/P08 also leave lost-usefulness or unsupported-specificity concerns. The observed P02/P05 improvements do not override these contrary results or establish causation/stable improvement. Inspected-empty remains distinct from unavailable/error.

Eight separately collected images received two caption-free AI pixel reviews: five recognizable food/drink presentations, one clear nonfood and two uncertain. **They remain unrun.** Hidden wrapped/bowl contents were not forced into source-selection categories. Finite known-corpus dedup and source credits do not establish all historical/model-training independence, material truth or privacy clearance; pixels are not redistributed or bundled in the app.

Next: investigate the general food/uncertainty decision architecture and supported local capabilities before another frozen proposal, preserving useful broad clues and unfamiliar cultural foods. A typed abstention schema is an unimplemented possibility, not a proven repair. Do not add object-word blacklists or replace failed cases with the unrun set.

The QA app wrote an isolated report/attempt marker and was shut down afterward; saved-meal-review APIs were not invoked. MainActor 45/600-second timers are cooperative, with a separate 660-second host observation cutoff; failure cleanup was not exercised by this successful mechanical run. No full production UI, physical airplane-mode, performance/memory, clinical, worldwide accuracy or submission-readiness claim follows. No production code, ZIP, upload or distribution change resulted.
