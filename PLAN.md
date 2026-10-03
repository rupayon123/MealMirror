# MealMirror delivery goal

## Product promise

Food should still feel like part of life after a Type 1 diabetes diagnosis. MealMirror should make it easier for a child, adult, or caregiver to begin with the meal in front of them, keep foods from every cuisine and occasion on the table, and understand what is known and what is still uncertain. It should never shame a food choice or imply that a photograph can reveal a hidden recipe or exact serving.

The long-term direction is: take a meal photo, confirm the foods and portions that the person recognizes, then review a transparent carbohydrate estimate. Keep that experience local and useful without internet access. Make the first step feel as simple as taking the picture, while asking for only the extra information a picture cannot provide. A diagnosis should not turn food into a list of forbidden things; support family recipes, cultural foods, restaurant meals, snacks, and celebrations with calm language and no shame.

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
- The everyday build has 18 language choices. Newer safety and feature strings still have English fallbacks in some language resources. The Challenge archive must remain English-only under the last published terms; a multilingual everyday build is a separate product capability and needs reviewed translations.
- Photo-only entry now reaches the review screen without typed meal text. The synthetic biryani photo produced no reliable range; the app asks the person to describe recognized foods or enter a trusted carbohydrate amount.
- With the simulator-specific CPU request, Vision completed on the synthetic biryani image but returned unrelated general scene labels such as “night sky” and “moon.” A prior default-compute run failed to create an Espresso context. Raw labels are now filtered: only labels that match a local food reference can become unchecked suggestions. The tested photo now yields “No clear food clues found in this photo,” not unrelated scene terms.
- The trusted-item recovery was exercised with synthetic “Test food” and 42 g input. It appears as a user-entered value; this was a flow check, not nutrition validation. No value was inferred from the image, and no dose was calculated.
- Removed the how-it-works screen's taps to USDA, NIDDK, and ADA web pages. The instructions and bundled examples remain local; the core flow does not need an internet connection.
- Physical-device photo behavior remains unverified. The user's iPhone 16 Pro was unavailable during the previous device inventory; no connected iPhone/iPad hardware result is claimed.
- Apple now documents multimodal image prompting for Foundation Models, but the installed Xcode 26.6 / iOS 26.5 SDK interface in this workspace does not expose the documented image `Attachment` API. Do not claim Foundation Models image analysis is integrated until the final compatible SDK/API can be compiled and tested. The current photo path uses Vision.
- The shared theme overhaul is still in its separate mockup-review stage. Do not change the visual tokens or logo here. A simulator screenshot also shows the fixed photo action footer letting “Remove selected photo” ghost through underneath; send that finding through the visual review before applying theme changes.
- The bundled local food catalog is illustrative and finite. It does not provide validated values for any meal from anywhere, and current image classification does not recognize arbitrary recipes, reliably measure portions, or calculate nutrition. Expand only with an honest uncertainty model and broad, representative evaluation—not a marketing claim.
- This folder has no Git metadata or remote yet. The user authorized a public `rupayon123/MealMirror` repository; create and push it after reviewing the initial snapshot, then verify the remote head.
- `COMPETITIVE-REVIEW.md` now includes RxFood's public claims and offline limitation. No hands-on or head-to-head nutrition accuracy study has been performed.

## Ordered work

1. Preserve the user's approved theme/logo and wait for the separate mockup approval before app-wide visual edits; route the footer overlap finding back into that review.
2. Keep the photo-only path, safe empty-result state, and trusted-entry recovery clear. Never display arbitrary classifier labels as food; keep suggestions unchecked and require the person to confirm foods and portions.
3. Investigate a food-specific on-device model only when its provenance, license, supported hardware, offline behavior, size, and real-photo performance can be verified within the Challenge package. Revisit Apple's multimodal Foundation Models image API when a compatible non-beta SDK is available.
4. Walk through welcome, camera, library, photo-only, unknown meal, Practice, edit, review trail, local history, Settings, and recovery states at phone and larger type sizes. Inspect screenshots and accessibility labels.
5. Reconcile branding and AI/asset disclosure, remove stale copy, check localization and safety wording, and refresh the English-only archive.
6. Inspect archive root structure, English resources, local assets, user-state exclusion, integrity, and archive size. Keep simulator and physical-device evidence distinct.
7. Review source and docs, create the authorized public GitHub repository, push `main`, and verify the published commit and run/package instructions.
8. Recheck the official 2027 rules when Apple publishes them. Keep eligibility, essays, ownership review, and final submission as applicant-owned steps.
