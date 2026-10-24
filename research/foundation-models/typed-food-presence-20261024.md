# Typed food-presence proposal — rejected, unapplied

October 24, 2026. A separate source-derived experiment completed the original twelve-image comparison. **The proposal failed its fixed uncertainty gate and was not added to MealMirror.** Current app 1.0 (7), its exact ZIP `2b3472a5…`, approved appearance and testing-only distribution remain unchanged.

## What was tried

The [unapplied source diff](typed-food-presence-20261024.diff) replaces the existing visible-food Boolean plus names with three private cases: `foodOrDrink(VisibleFoodNames)`, `nonfood` and `uncertain`. Only the food case has a names payload. All successful cases still return the existing inspected status; nonfood/uncertain map to empty names. Errors remain unavailable. The existing text policy, amount separation, default local model and guardrails, one-generation limit, 180-token cap, temperature zero and 15-second caller deadline are retained.

Apple documents associated-value enums for [guided generation](https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation). Choosing this shape for food presence is our design inference. The original Boolean already came first; this was no new “classification first” guarantee. Schema and necessary instructions/mapping changed together. Correctly shaped output cannot establish correct food presence or names. The public result exposes neither the private branch nor why names were filtered.

## Compile and mapping evidence

The exact experimental app compiled once for arm64 iOS Simulator. Its distinct QA identity/version, all 30 built files, thirteen neutral input resources and 146 frozen source references passed independent review. Main executable SDK 27.1/debug dylib 27.0 and existing build warnings remain recorded.

Separately, native Mac compilation and six manually constructed enum scenarios passed **20/20 checks** using the extracted candidate types/status/mapping and unchanged policy. These check mapping, counts and representative text hygiene; no model was called. They do not verify model branch selection, decoder behavior, Guide enforcement, recognition or language quality.

## Every returned list

The inputs, order and criteria were frozen before inference. One serial run completed twelve inspected outcomes, with no retries, substitutions or unrun original cases. Compare with the original default-model baseline, not either rejected intervening experiment.

| Input | Original baseline | Typed candidate |
|---|---|---|
| P01 | rice, salad, meat, drink | rice, salad, meat, drink |
| P02 | ceramic bowl | empty |
| P03 | lasagna | baked dish |
| P04 | flatbread | flat bread |
| P05 | pâté, sauce | pâté, sauce |
| P06 | empty | empty |
| P07 | brown square | brown square, nuts |
| P08 | curry, flatbread, fried potatoes | stew, flatbread, fried slices, fried pieces |
| P09 | chicken, potatoes, green beans, carrots | chicken, potatoes, green beans, carrots |
| P10 | dumplings | dumplings |
| P11 | fried egg, noodles, shrimp, lime | fried egg, noodles, shrimp, lime |
| P12 | empty | empty |

P02 improved from a nonfood vessel name to empty. P03 became a broader baked-dish clue. Those changes do not waive contrary results: **P07 returned `brown square, nuts` when inspected-empty was required**, so adoption is rejected. P07 remains an uncertain visual/material case, not proven nonfood. P05 retains its weak `pâté` clue; P08 still raises dish-category and extra-item concerns. Existing specific labels and mixed-dish decomposition also remain. The complete record preserves unchanged, added and lost names.

Every return retained zero amount and included components, no automatic carbohydrate total and false review readiness. Label OCR and Vision fallback stayed notRun. This establishes limited processing separation, **not twelve correct meal identifications**. Empty public names do not identify a particular private enum branch or prove correct abstention.

## Limits and next work

The expectations came from two blind AI pixel reviews, not qualified human, recipe, material, nutrition or clinical ground truth. All twelve are exposed development cases. The separate new eight and candidate multi-view/label follow-ups remain **unrun** because the fixed gate failed.

Fresh boot output again said “Data Migration Failed” despite exit zero. Actual completion of this run does not clear that environment warning or diagnose the earlier content-tagging failure. The owned headless QA Simulator was shut down with reports/data retained; the original interactive picker was untouched. Neither shutdown nor caller cancellation proves when OS inference compute stops.

The [machine-readable record](typed-food-presence-20261024.json) pins the proposal, reviews, mapping results, exact QA build, raw outcomes, decision and cleanup. Its local artifact references identify retained artifacts not reproduced in the public record; research pixels and private paths/identifiers are excluded.

Keep this proposal unapplied. Reconsider recognition architecture and evaluation before further inference, rather than continue prompt tuning against exposed cases. No current full app journey, direct accessibility, physical/network-isolated offline, calibrated performance, qualified accuracy, competitive superiority or submission-readiness gate closed. See [current readiness](../../CHALLENGE-READINESS.md).
