# Checked carbohydrate input

## October 24, 2026 — build 4

The checked-amount form requests whole grams from 0 to 500. Its existing `WholeGramParser` used Foundation `NumberFormatter` and then checked the converted number. That accepted richer syntax than the form requests: for example, `3e1` became 30 and, in Spanish, `0.037` became 37. A sufficiently small fractional suffix could also round to an integer before validation. This was a syntax gap, not a failure to support localized digits.

The parser now trims outer whitespace/newlines and requires a nonempty sequence of Unicode decimal digits before calling the existing locale-aware formatter. It preserves leading zeros and localized numerals, including mixed decimal-digit scripts. Signs, decimal/grouping separators, exponents, suffixes, fractions, directional marks and other controls are rejected. The existing range, finite-number and integer checks remain. This policy applies to the app's 0–500 g field; it does not validate a food's nutrition or calculate insulin.

### Verification

- The original source-derived Mac probe covered 1,224 rows across 18 locales and nine digit scripts. Before the fix, all 486 valid digit rows passed, while 162 of 702 intended syntax rejections were accepted. After the fix, all 1,224 rows matched expectations, including 36 outer-whitespace/leading-zero cases. Garbage suffixes were already rejected in that probe; no partial-prefix parsing bug is claimed.
- The same unchanged probe and actual fixed `MealModels.swift` compiled and ran in a separate arm64 process on the booted iOS 27.1 Simulator: all 1,224 rows passed. The probe's old “native Mac” scope literal was preserved; execution metadata establishes the actual iOS Simulator environment. The explicit SDK directory was 27.1; the standalone binary's link metadata reports SDK 27.0. Both are retained in the local record.
- The committed regression harness passed 4,284 checks against the actual production source. It adds boundary, mixed/supplementary digit, directional-mark, overflow, locale-formatting and small custom-range cases. It stays outside the submitted playground.
- The regenerated English-only build-4 ZIP is deterministic and clean-builds for arm64 Simulator. Its installed executable and Info.plist match the built bytes. In the actual app's light/standard-size open-Duo form, synthetic `3e1` displayed the existing warning and disabled Add; replacing it with `٣٧` cleared the warning and visibly enabled Add. Input was set through accessibility, not typed on an Arabic keyboard. The entry was canceled without saving.

Run the regression suite from the repository root:

```sh
xcrun swiftc -swift-version 6 -parse-as-library \
  MealMirror.swiftpm/MealCore/MealModels.swift scripts/verify-whole-grams.swift \
  -o /tmp/mealmirror-verify-whole-grams
/tmp/mealmirror-verify-whole-grams
```

The [dated receipt](whole-grams-20261024.json) records source/artifact identities, outcomes and limits. Raw probes, reports, logs and two reviewed screenshots remain outside the playground under `../../../../outputs/checked-amount-parser-20261024/`, `../../../../outputs/whole-grams-ios-20261024/` and `../../../../outputs/whole-grams-delivery-20261024/`.

### Historical build-4 limits

Those build-4 checks did not prove actual localized keyboard/paste behavior, RTL layout, VoiceOver, a checked-amount commit/save, the complete photo/model/OCR journey, physical-device offline behavior or clinical validity. The public helper's pre-existing `Double` conversion is not an exact-integer guarantee for custom ranges above 2^53; the app only uses 0–500. Build 4 changes checked-input syntax and its build number; the model source, image policy and uncertainty boundaries are unchanged. Current distribution and submission status remain in [readiness](../../CHALLENGE-READINESS.md).

## October 25, 2026 — build 9 native Add check

The [native Add receipt](native-add-20261025.json) records one completed test of the exact build-9 app on iOS 26.5 Simulator, in English/light/standard-size configuration. A synthetic unknown-meal description opened Estimate; entering a synthetic checked item and `37` enabled Add. Native Add dismissed the form, and Estimate showed the item with “Your entry” and a fixed `37 g` range while unconfirmed Review remained disabled. The test passed one case with zero failures; two relevant form/Estimate screenshots were reviewed. A subsequent current-container lookup exited zero and confirmed all 17 installed files still matched; the three saved records remained byte-identical. This verifies the checked-amount Add step into Estimate, without saving a meal.

The earlier command rejection and interrupted run remain recorded. The completed run kept the same assertions and 150-second case allowance under a 600-second host bound; it had no event-loop idle warning and does not explain the prior stall. Photos/camera, OCR/model inference, parts confirmation, final Review, Save/history/delete, physical offline behavior, localized input and broad accessibility remain outside this check. The `37 g` value is synthetic test data, not nutrition or clinical validation; production source and ZIP were unchanged.
