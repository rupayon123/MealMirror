# MealMirror

MealMirror is a SwiftUI project for making meal review feel simpler after a Type 1 diabetes diagnosis. The product's direction is food-positive and photo-first: someone can start with the meal in front of them, keep the foods they enjoy, and review what is known or uncertain with the people who support them.

This is an internal-testing project, not a medical device, treatment guide, or submission-ready Challenge entry. Build 1.0 (3) now includes an optional Apple Foundation Models image path for supported iOS 27 devices. It offers uncertain food names only, with Vision and manual review available when the local model is unavailable. The model path compiles, but real image inference and broad meal accuracy have not been verified. See [the completion plan](SUBMISSION-COMPLETION-PLAN.md) for what is done and still missing.

**Testing only:** Direct development installs and the existing internal TestFlight group are allowed. Do not submit MealMirror for App Store review, release it on the App Store, enable external/public TestFlight testing, or publish app releases without a new explicit applicant request. The public source repository is separate from app distribution.

## Open and run

Open [`MealMirror.swiftpm`](MealMirror.swiftpm) in Xcode 27.1 or later and choose an iPhone or iPad simulator. The app retains an iOS 17 deployment floor; the Foundation Models image path is gated to iOS 27 or later. The package includes bundled Practice images and local example ranges; those values demonstrate the review controls and are not measurements of a real meal.

For an iPhone test later, download the repository or the candidate ZIP below, open `MealMirror.swiftpm` in Xcode, connect and unlock the iPhone, select it as the run destination, choose your Apple development team if Xcode requests signing, and press Run. The current source builds for arm64/x86_64 Simulator with Xcode 27.1, and the current exact ZIP clean-builds for arm64 Simulator. Build 3 installed on Simulator, but its launch failed when the Simulator server died under heavy Mac load; no current rendered or functional runtime pass is claimed. Camera capture and offline use on a physical device still need that device check.

The candidate is Swift-only and has no sign-in, required server, Dexcom/Libre connection, or insulin-dose calculation. A person can add up to three meal views and one nutrition-label image. Photo preparation, the optional Foundation Models image request, Vision food inspection, and Vision label transcription stay on device. The label text is shown beside its photo for checking; it never fills a carbohydrate amount automatically. Its instructions, assets, and examples are bundled; no app screen needs a network connection. A photo never determines a portion or carbohydrate amount. When a food is not recognized, the person can add foods they know or enter a value from a package or another trusted source. A manually entered amount stays fixed and can be edited directly; the portion controls apply only to illustrative catalog ranges. The local catalog is finite; it does not cover every meal or culture, and its example ranges are not clinically validated.

MealMirror's product aim is to keep food and joy in everyday life after diagnosis. It should welcome family recipes, restaurant meals, snacks, celebrations, and foods from any culture without shaming choices. For a picture that leaves questions, the app should ask only for details the person can confirm.

## Offline meal photo AI

[`LocalPhotoAI.swift`](MealMirror.swiftpm/LocalPhotoAI.swift) explicitly selects Apple's on-device `SystemLanguageModel.default`. It checks OS support, model availability, image and guided-generation capabilities, and the selected language. Up to three views are treated as one meal; the prompt asks for possible visible food names and abstention. A bounded wait, cancellation, and unavailable messages preserve the local fallback. No cloud model is selected and the app does not download model weights.

Possible names appear separately from carbohydrate items. Tapping a name only prefills an editable name; a person must supply a checked amount before it can enter a total. The model has no structured portion, nutrition, or dose fields. Its text filter limits display text but cannot establish whether a food name is true. Empty successful model output remains an unknown result; the app does not replace that abstention with Vision guesses. If the model is unavailable, Vision/manual review remains available. The label photo follows the separate local OCR path.

The Xcode/SDK license gate is cleared. On this Mac a native availability probe returned `modelNotReady`, so no real-model photo result, accuracy, or latency has been demonstrated. After approved system setup, Settings reports Siri support is being added; model readiness must be checked again when that finishes. The final offline walkthrough must include both model-ready and unavailable paths. [Model decision and evaluation limits](OFFLINE-MODEL-DECISION.md).

## Language support

The everyday app includes a menu for English, French, Simplified Chinese, Cantonese (Traditional), Punjabi, Urdu, Tamil, Filipino, Spanish, Arabic, Persian, Hindi, Portuguese, Gujarati, Bengali, Japanese, Korean, and Hungarian. All 18 catalogs have 487 matching keys. The nine new photo-AI status/help strings are translated in every catalog and passed static JSON/native-string parity checks. Older English fallbacks and uncatalogued copy remain, and native-speaker and rendered review are still open. The Challenge package must follow the official language rules for its submission year.

## Swift Student Challenge packaging

Apple's currently published terms are for the 2026 Challenge; that deadline was February 28, 2026. Apple has not published the 2027 terms on the pages checked. The 2026 terms specify an offline `.swiftpm` ZIP, locally included resources, English content, a 25 MB maximum, and Xcode 26 or Swift Playgrounds 4.6 or later. Recheck Apple's [terms](https://developer.apple.com/swift-student-challenge/policy/) and [eligibility requirements](https://developer.apple.com/swift-student-challenge/eligibility/) before a later submission.

The current packaging script creates an English-only candidate archive:

```sh
./scripts/prepare-ssc-submission.sh
```

It writes `build/MealMirror-SSC2027.zip`, removes non-English resource catalogs and Xcode user state, and checks the currently published size limit. A generated archive is only a packaging artifact; it does not establish app readiness, applicant eligibility, authorship, or a completed submission.

For local testing, [open the current candidate ZIP](candidate/MealMirror-SSC2027.zip). Build 1.0 (3) is 12,202,518 bytes, SHA-256 `26baa803366482870a4696e411009f6bc4c11132fde005dc1f6333bd117143e2`. Two generations were byte-identical, archive integrity checks passed, and its clean-extraction arm64 Simulator build passed. Its complete runtime journey remains unverified. Build 3 has not been uploaded to TestFlight.

Internal TestFlight still contains build 1.0 (2), marked Testing in MealMirror Internal, with one invited tester at the latest check. Invitation acceptance and phone installation remain unverified. That older ZIP (`1a147445…`, 12,196,173 bytes) clean-built and passed the Duo folded-welcome/photo-picker check. The earlier `ab082da8…` ZIP completed the photo/label/manual-entry/save/history/delete journey on iPhone SE Simulator. Those results do not establish build 3 runtime behavior. The [readiness checklist](CHALLENGE-READINESS.md) records exact artifact evidence and remaining gates.

## Project records

- [`PLAN.md`](PLAN.md) tracks the delivery goal, current evidence, product boundaries, and ordered work.
- [`CHALLENGE-READINESS.md`](CHALLENGE-READINESS.md) records the exact candidate ZIP, Apple checklist, Simulator checks, and open submission gates.
- [`SUBMISSION-COMPLETION-PLAN.md`](SUBMISSION-COMPLETION-PLAN.md) separates finished work, the remaining Challenge gates, and the decision about any future insulin calculator.
- [`APPLE-TECHNOLOGY-BRIEFING.md`](APPLE-TECHNOLOGY-BRIEFING.md) identifies the Apple frameworks used today, the implemented model gates, and the remaining evaluation work.
- [`CGM-INTEGRATION-PLAN.md`](CGM-INTEGRATION-PLAN.md) explains Dexcom, Libre, and HealthKit access limits and the optional connected product path.
- [`COMPETITIVE-REVIEW.md`](COMPETITIVE-REVIEW.md) reviews public feature claims from RxFood and other meal-photo apps without unsupported superiority claims.
- [`WORLDWIDE-MEAL-EVALUATION.md`](WORLDWIDE-MEAL-EVALUATION.md) sets a broad, permissioned evaluation plan for meals and labels across cuisines and conditions, including unknown and nonfood cases.
- [`MealMirror.swiftpm/AI-AND-ASSET-DISCLOSURE.md`](MealMirror.swiftpm/AI-AND-ASSET-DISCLOSURE.md) is a working record; the applicant must reconcile it with the full project history and actual bundled assets.

## Signed iPhone archive

Run `scripts/archive-testflight.sh /absolute/path/MealMirror.xcarchive APPLE_TEAM_ID` with a new output path. It archives the everyday multilingual app and verifies the executable's actual SDK and minimum iOS version before a separate upload. This includes the Xcode 27.1 Swift product-link SDK workaround; it preserves the iOS 17 deployment floor. Build 2 has separate App Store Connect evidence of Testing in MealMirror Internal. Build 3 is local only until its own archive, upload, processing, and internal-group checks are completed; no App Store review or public beta is authorized.

The [REA review](replica/rea-review-20261022.md) records static app-package inspection and public RxFood research. It does not establish native RxFood internals or a head-to-head accuracy result.
