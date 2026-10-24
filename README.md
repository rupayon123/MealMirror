# MealMirror

MealMirror is a SwiftUI project for making meal review feel simpler after a Type 1 diabetes diagnosis. The product's direction is food-positive and photo-first: someone can start with the meal in front of them, keep the foods they enjoy, and review what is known or uncertain with the people who support them.

This is an internal-testing project, not a medical device, treatment guide, or submission-ready Challenge entry. Build 1.0 (4) retains optional local Foundation Models image prompting for supported iOS 27 devices. Its current fixed prompt requests tentative main visible food/dish clues. A small iOS Simulator development comparison and separate snack/dessert/drink scope checks completed without creating carbohydrate amounts, while retaining uncertain outputs. These checks do not establish broad accuracy, the complete app journey or physical offline use. See [Foundation Models evidence](research/foundation-models/README.md) and [the completion plan](SUBMISSION-COMPLETION-PLAN.md).

**Testing only:** Direct development installs and the existing internal TestFlight group are allowed. Do not submit MealMirror for App Store review, release it on the App Store, enable external/public TestFlight testing, or publish app releases without a new explicit applicant request. The public source repository is separate from app distribution.

## Open and run

Open [`MealMirror.swiftpm`](MealMirror.swiftpm) in Xcode 27.1 or later and choose an iPhone or iPad simulator. The app retains an iOS 17 deployment floor; the Foundation Models image path is gated to iOS 27 or later. The package includes bundled Practice images and local example ranges; those values demonstrate the review controls and are not measurements of a real meal.

For an iPhone test later, open `MealMirror.swiftpm` in Xcode, connect and unlock the iPhone, choose it as the destination, select your Apple development team if requested, and Run. The current exact ZIP clean-builds for arm64 Simulator; x86_64 source builds apply to the prior prompt revision. The prior `6abc22fa…` build 3 completed the illustrative Practice → confirmation → Review → Save → history/detail path and retained that test record after relaunch on open Duo. Picker cancellation, unknown-description recovery and checked-form input were observed on those older bytes. Current build 4 has separate invalid/valid checked-input form evidence, with the synthetic entry canceled without saving. Photo/model and checked-amount commit journeys remain open; [readiness](CHALLENGE-READINESS.md) records the controls and viewport limits. Prior Home/fixture captures remain tied to older bytes. Camera and physical offline use remain unverified.

The candidate is Swift-only and has no sign-in, required server, Dexcom/Libre connection, or insulin-dose calculation. A person can add up to three meal views and one nutrition-label image. Photo preparation, the optional Foundation Models image request, Vision food inspection, and Vision label transcription stay on device. The label text is shown beside its photo for checking; it never fills a carbohydrate amount automatically. Its instructions, assets, and examples are bundled; no app screen needs a network connection. A photo never determines a portion or carbohydrate amount. When a food is not recognized, the person can add foods they know or enter a value from a package or another trusted source. A manually entered amount stays fixed and can be edited directly; the portion controls apply only to illustrative catalog ranges. The local catalog is finite; it does not cover every meal or culture, and its example ranges are not clinically validated.

MealMirror's product aim is to keep food and joy in everyday life after diagnosis. It should welcome family recipes, restaurant meals, snacks, celebrations, and foods from any culture without shaming choices. For a picture that leaves questions, the app should ask only for details the person can confirm.

## Offline meal photo AI

[`LocalPhotoAI.swift`](MealMirror.swiftpm/LocalPhotoAI.swift) explicitly selects Apple's on-device `SystemLanguageModel.default`. It checks OS support, model availability, image and guided-generation capabilities, and the selected language. Up to three views are treated as one meal; the prompt asks for possible visible food names and abstention. A bounded wait, cancellation, and unavailable messages preserve the local fallback. No cloud model is selected and the app does not download model weights.

Possible names appear separately from carbohydrate items. Tapping a name only prefills an editable name; a person must supply a checked amount before it can enter a total. The model has no structured portion, nutrition, or dose fields. Its text filter limits display text but cannot establish whether a food name is true. Empty successful model output remains an unknown result; the app does not replace that abstention with Vision guesses. If the model is unavailable, Vision/manual review remains available. The label photo follows the separate local OCR path.

**Status refreshed October 24, 2026:** A source-derived iOS 27.1 Simulator diagnostic exercised input bounds, UIKit orientation/scale preparation, three overlapping views, nonfood handling and caller cancellation/recovery. Eight new meal/nonfood photos exposed unsupported ingredient guesses. One fixed main-visible-food/dish prompt was then run once on those eight development images and three separately frozen fruit/dessert/drink scope examples. The observed soup, taco and sandwich clues became simpler; pasta decomposition and drink identity remain uncertain. All eleven proposal requests completed without creating amount components, a carbohydrate total or review readiness. See [fixed-prompt evidence](research/foundation-models/main-visible-food-20261024.json) and [independent review](research/foundation-models/main-visible-food-20261024-review.md). This is prompt tuning and limited integration evidence, not independent accuracy, full app interaction or physical offline validation. Historical storage and eight component-render checks remain in [Foundation Models evidence](research/foundation-models/README.md).

**Internal testing update:** Exact English-only candidates 1.0 (3) and 1.0 (4) were signed, verified against iPhoneOS 27.1/iOS 17 minimum, and uploaded with `testFlightInternalTestingOnly = true` and automatic version changes disabled. Both uploads succeeded and Apple reported processing; processing completion, compliance, existing-group Testing and phone installation remain unverified. Build 2 remains the last verified Testing build from the earlier dated check. See [build-3 evidence](research/foundation-models/internal-build3-20261024.json) and the latest [build-4 receipt](research/checked-amounts/whole-grams-20261024.json). App Store Connect requires sign-in again. The app was not submitted for App Store review or released.

## Language support

The everyday app includes a menu for English, French, Simplified Chinese, Cantonese (Traditional), Punjabi, Urdu, Tamil, Filipino, Spanish, Arabic, Persian, Hindi, Portuguese, Gujarati, Bengali, Japanese, Korean, and Hungarian. All 18 catalogs have 487 matching keys. The nine new photo-AI status/help strings are translated in every catalog and passed static JSON/native-string parity checks. Older English fallbacks and uncatalogued copy remain, and native-speaker and rendered review are still open. The Challenge package must follow the official language rules for its submission year.

## Swift Student Challenge packaging

Apple's currently published terms are for the 2026 Challenge; that deadline was February 28, 2026. The October 24 official-page check found no 2027 terms or opening window; recheck before submission. The 2026 terms specify an offline `.swiftpm` ZIP, locally included resources, English content, a 25 MB maximum, and Xcode 26 or Swift Playgrounds 4.6 or later. Recheck Apple's [terms](https://developer.apple.com/swift-student-challenge/policy/) and [eligibility requirements](https://developer.apple.com/swift-student-challenge/eligibility/) before a later submission.

The current packaging script creates an English-only candidate archive:

```sh
./scripts/prepare-ssc-submission.sh
```

It writes `build/MealMirror-SSC2027.zip`, removes non-English resource catalogs and Xcode user state, and checks the currently published size limit. A generated archive is only a packaging artifact; it does not establish app readiness, applicant eligibility, authorship, or a completed submission.

For local testing, [open the current build-4 ZIP](candidate/MealMirror-SSC2027.zip): 12,203,814 bytes, SHA-256 `e9e702f4f835e32abc934391cd333a7aeab56f6ba34a8abb59b846ba0efb8b5e`. Deterministic packaging, integrity, English-only resources and equality of all 17 Swift files passed. The exact ZIP clean-builds, installs/launches and shows checked-input validation/recovery on Duo; [readiness](CHALLENGE-READINESS.md) records the limits. Build 4 rejects ambiguous numeric syntax while retaining localized decimal digits; [4,284 Mac checks and 1,224 iOS Simulator rows](research/checked-amounts/README.md) passed. Its signed internal-only upload succeeded; processing/compliance/group availability and the full photo-to-history/physical-offline gates remain open.

The last verified App Store Connect check showed build 1.0 (2) Testing in MealMirror Internal with one invited tester. Invitation acceptance and phone installation remain unverified. That older ZIP (`1a147445…`, 12,196,173 bytes) clean-built and passed the Duo folded-welcome/photo-picker check. The earlier `ab082da8…` ZIP completed the photo/label/manual-entry/save/history/delete journey on iPhone SE Simulator. Build 3 separately passed limited Practice/save/history/relaunch checks; those older journeys do not establish build 4’s full runtime behavior. The [readiness checklist](CHALLENGE-READINESS.md) records exact artifact evidence and remaining gates.

## Project records

- [`PLAN.md`](PLAN.md) tracks the delivery goal, current evidence, product boundaries, and ordered work.
- [`CHALLENGE-READINESS.md`](CHALLENGE-READINESS.md) records the exact candidate ZIP, Apple checklist, Simulator checks, and open submission gates.
- [`SUBMISSION-COMPLETION-PLAN.md`](SUBMISSION-COMPLETION-PLAN.md) separates finished work, the remaining Challenge gates, and the decision about any future insulin calculator.
- [`APPLE-TECHNOLOGY-BRIEFING.md`](APPLE-TECHNOLOGY-BRIEFING.md) identifies the Apple frameworks used today, the implemented model gates, and the remaining evaluation work.
- [`research/checked-amounts/README.md`](research/checked-amounts/README.md) records strict localized whole-gram parsing, regression checks and exact-app form states.
- [`CGM-INTEGRATION-PLAN.md`](CGM-INTEGRATION-PLAN.md) explains Dexcom, Libre, and HealthKit access limits and the optional connected product path.
- [`COMPETITIVE-REVIEW.md`](COMPETITIVE-REVIEW.md) reviews public feature claims from RxFood and other meal-photo apps without unsupported superiority claims.
- [`WORLDWIDE-MEAL-EVALUATION.md`](WORLDWIDE-MEAL-EVALUATION.md) sets a broad, permissioned evaluation plan for meals and labels across cuisines and conditions, including unknown and nonfood cases.
- [`MealMirror.swiftpm/AI-AND-ASSET-DISCLOSURE.md`](MealMirror.swiftpm/AI-AND-ASSET-DISCLOSURE.md) is a working record; the applicant must reconcile it with the full project history and actual bundled assets.

## Signed iPhone archive

Run `scripts/archive-testflight.sh /absolute/path/MealMirror.xcarchive APPLE_TEAM_ID` with a new output path. It archives the everyday multilingual app and verifies the executable's actual SDK and minimum iOS version before a separate upload. This includes the Xcode 27.1 Swift product-link SDK workaround; it preserves the iOS 17 deployment floor. Build 2 has separate App Store Connect evidence of Testing in MealMirror Internal. The exact English-only archives and internal-only uploads for builds 3 and 4 succeeded. Processing, compliance, the server’s Internal indicator and existing-group Testing remain unverified; no App Store review or public beta is authorized. Each exact-candidate archive used an unchanged copy of the script beside a clean ZIP extraction. The repository script resolves its source from its own location; changing the caller’s directory alone does not select an extracted candidate.

The [REA review](replica/rea-review-20261022.md) records static app-package inspection and public RxFood research. It does not establish native RxFood internals or a head-to-head accuracy result.
