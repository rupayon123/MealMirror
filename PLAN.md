# MealMirror delivery goal

## Product promise

Food should still feel like part of life after a Type 1 diabetes diagnosis. MealMirror should make it easier for a child, adult, or caregiver to begin with the meal in front of them, keep foods from every cuisine and occasion on the table, and understand what is known and what is still uncertain. It should never shame a food choice or imply that a photograph can reveal a hidden recipe or exact serving.

The product target is that someone can start with a photo of any meal they want to eat: a family recipe, a mixed home-cooked dish, a school lunch, a restaurant plate, a snack, or a celebration meal from any culture. The first step should be as simple as taking the picture, and photo processing should work on the device without internet. The app should offer only useful, confirmable clues, make correction easy, and ask for extra context only when the image cannot provide it. A diagnosis should not turn food into a list of forbidden things.

MealMirror has not reached this target yet. The current Vision classifier missed the tested biryani photo. Treat wide, offline recognition as a primary product blocker, not as copy the app may claim it already fulfills. A photo can suggest food names, but it cannot establish a hidden recipe, ingredients, serving size, or exact carbohydrate amount.

## Two delivery tracks

### Swift Student Challenge candidate

Keep this a small, memorable, self-contained Swift playground that works offline and can be understood in a short judging session. Include the full interactive story and its assets in the `.swiftpm` ZIP. Do not add Android, a server, sign-in, Dexcom/Libre data, or insulin-dose calculation to this candidate.

The 2026 Apple terms currently published require an offline `.swiftpm` ZIP of up to 25 MB, English content, and Xcode 26 or Swift Playgrounds 4.6 or later. The 2026 deadline was February 28, 2026. As of this review, Apple has not published 2027 terms. Recheck the official [terms](https://developer.apple.com/swift-student-challenge/policy/) and [eligibility requirements](https://developer.apple.com/swift-student-challenge/eligibility/) before packaging for a future cycle.

### Full MealMirror product direction

Keep the following as a separate roadmap, not a claim that the Challenge package already does it:

- A photo-first start for meals prepared at home, bought outside, or made from a family recipe.
- On-device suggestions when a compatible local model is available, with a plain explanation when it is not.
- Easy correction for hidden ingredients, mixed dishes, unfamiliar foods, serving size, sauces, and packaged labels. A person can say “I don’t know” and use their trusted method instead.
- Local history, repeat meals, caregiver-friendly setup, clear language, VoiceOver, Dynamic Type, and translated everyday content.
- Optional Dexcom and FreeStyle Libre connections only after vendor/API access, user consent, privacy and security review, resilient failure behavior, and applicable regulatory review. A live CGM connection necessarily adds a connected mode and cannot be part of a fully offline promise.
- Any future insulin support is a separate, medically governed project. Do not display insulin units or dose suggestions until clinicians, people with T1D, clinical evidence, device/regulatory counsel, and risk controls define and validate a safe scope. A meal photo alone can never supply all dosing inputs.

## Acceptance criteria

### Everyday meal experience

- No account, internet, or prior health data is needed to begin.
- The first useful action is choosing or taking a meal photo; typing remains optional context, not a gate to starting.
- The recognition target includes varied real meals, not only foods represented by one fixed image-classification taxonomy. No cuisine or recipe is blocked because the model lacks its label.
- Before claiming broad recognition, evaluate a lawful, consented, culturally varied set of real home-cooked and restaurant photos offline, including mixed dishes and unfamiliar meals. Report coverage and uncertainty; keep an honest unknown result when evidence is weak.
- The app makes possible food names easy to confirm or dismiss. Unknown or culturally specific meals have a clear manual path; no unmatched photo is presented as a confident carb count.
- A photo never establishes ingredients, recipe, portion size, or carbohydrate grams. Estimates state their source, keep uncertainty visible, and remain editable.
- A complete guided Practice path works offline and fits a short judging session.
- Food copy is calm and non-judgmental. It makes room for ordinary food, family meals, and personal choice instead of telling people what to eat.
- VoiceOver, Dynamic Type, Reduce Motion, localization, right-to-left layout, clear empty/loading/error/recovery states, and child/caregiver comprehension are considered in the design.

### Challenge package and ownership

- Open and build the current `.swiftpm` with the required Apple toolchain; keep every resource needed for the experience inside the ZIP.
- Build an English-only candidate ZIP under the currently published 25 MB maximum. Recheck these rules when 2027 terms appear.
- Review the full package offline and confirm the bundled Practice path, photo fallback, app navigation, and accessibility behavior.
- Document all AI assistance, generated or user-provided assets, and third-party material accurately. The applicant must personally review and understand the final code, make substantial individual contributions, verify licenses and project history, and write every application essay.
- Keep applicant eligibility, current proof of enrollment, form answers, and final submission as applicant-owned steps. Do not label a build “submitted” or “submission ready” without the applicable future rules and those steps.

### Delivery

- Keep the public GitHub source, run instructions, delivery plan, competitive review, asset disclosure, and packaged candidate aligned with each other.
- Publish reviewed, buildable updates to `rupayon123/MealMirror` so the user can install and evaluate them.
- Compare public feature claims and documented limitations fairly. Do not claim MealMirror is more accurate, safer, or award-winning without evidence; the goal is to build the strongest candidate we can substantiate, not promise a judging result.

## Current evidence and open gaps — October 3, 2026

- The SwiftUI package builds successfully with Xcode 26.6 for iOS 26.5 Simulator. The latest photo-only source changes were installed and exercised on an iPhone 17 simulator. It uses local resources and has no sign-in or required network service.
- The everyday build has 18 language choices: English plus 17 other locales. All tables contain 472 keys; source inspection found 18 user-facing phrases whose values remain English in every non-English locale. The separate UI preview task also reported mixed-direction carbohydrate ranges that need numeric isolation in right-to-left layouts; verify after its proposal is approved. The Challenge archive must follow Apple's next language rules; everyday translations need native review.
- Photo-only entry now reaches the review screen without typed meal text. The synthetic biryani photo produced no reliable range; the app asks the person to describe recognized foods or enter a trusted carbohydrate amount.
- With the simulator-specific CPU request, Vision completed on the synthetic biryani image but returned unrelated general scene labels such as “night sky” and “moon.” A prior default-compute run failed to create an Espresso context. Raw labels are now filtered: only labels that match a local food reference can become unchecked suggestions. The tested photo now yields “No clear food clues found in this photo,” not unrelated scene terms.
- The trusted-item recovery was exercised with synthetic “Test food” and 42 g input. It appears as a user-entered value; this was a flow check, not nutrition validation. No value was inferred from the image, and no dose was calculated.
- Removed the how-it-works screen's taps to USDA, NIDDK, and ADA web pages. The instructions and bundled examples remain local; the core flow does not need an internet connection.
- Physical-device photo behavior remains unverified. The user's iPhone 16 Pro was unavailable during the previous device inventory; no connected iPhone/iPad hardware result is claimed.
- [Apple's Foundation Models image-attachment documentation](https://developer.apple.com/documentation/foundationmodels/attachment) currently marks `Attachment` as beta; the installed Xcode 26.6 / iOS 26.5 SDK interface does not expose the documented API. The current photo path uses Vision. Revisit a compatible, non-beta Apple image API with the next supported toolchain, and verify offline behavior and device compatibility before relying on it.
- The shared theme overhaul is still in its separate mockup-review stage. Do not change the visual tokens or logo here. A simulator screenshot also shows the fixed photo action footer letting “Remove selected photo” ghost through underneath; send that finding through the visual review before applying theme changes.
- The bundled local food catalog is illustrative and finite. It does not provide validated values for any meal from anywhere, and current image classification does not recognize arbitrary recipes, reliably measure portions, or calculate nutrition. The [Food-101 research dataset](https://data.vision.ee.ethz.ch/cvl/datasets_extra/food-101/) has 101 dish categories, so a classifier limited to that taxonomy would not satisfy MealMirror's any-meal goal by itself. Expand only with an honest uncertainty model and broad, representative evaluation—not a marketing claim.
- The authorized public repository is live at [github.com/rupayon123/MealMirror](https://github.com/rupayon123/MealMirror). The verified source and product-goal updates are on `main`, which tracks the public remote; the worktree is clean after the October 3, 2026 push. Keep publishing reviewed, buildable progress for the user's testing.
- `COMPETITIVE-REVIEW.md` now includes RxFood's public claims and offline limitation. No hands-on or head-to-head nutrition accuracy study has been performed.

## Ordered work

1. Resolve the broad offline photo-recognition blocker. Compare Apple-supported on-device options and properly licensed food models against real, culturally varied meal photos; check whether each fits the current package and device constraints before integrating it.
2. Preserve photo-only entry, user confirmation, safe unknown results, and clear trusted-value recovery. Never display arbitrary classifier labels as food or present photo-only nutrition values as reliable.
3. Preserve the user's approved theme/logo and wait for the separate mockup approval before app-wide visual edits; carry the photo-footer overlap into that review.
4. Walk through welcome, camera, library, photo-only, unfamiliar meals, Practice, edit, review trail, local history, Settings, and recovery at phone and larger text sizes. Inspect screenshots and accessibility behavior.
5. Reconcile branding and AI/asset disclosure, review translations and safety wording, then refresh the English-only archive.
6. Keep the public repository, buildable source, delivery plan, and downloadable candidate aligned. Push reviewed progress and verify each remote head.
7. Recheck the official 2027 rules when Apple publishes them. Keep eligibility, essays, ownership review, and final submission as applicant-owned steps.
