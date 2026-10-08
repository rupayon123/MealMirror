# MealMirror

MealMirror is a SwiftUI project for making meal review feel simpler after a Type 1 diabetes diagnosis. The product's direction is food-positive and photo-first: someone can start with the meal in front of them, keep the foods they enjoy, and review what is known or uncertain with the people who support them.

This is a work in progress, not a medical device, treatment guide, or submission-ready Challenge entry. Photo-only entry works, but iOS 26.5 Simulator's Vision classifier returned the same unrelated scene labels for three different meal photos. MealMirror treats that known bad result as an unavailable inspection and shows no carbohydrate range. The person can describe the meal or enter a value from a trusted source. A separate macOS Vision run recognized the biryani photo; physical iPhone/iPad behavior remains unverified. See [`PLAN.md`](PLAN.md) for evidence and remaining work.

## Open and run

Open [`MealMirror.swiftpm`](MealMirror.swiftpm) in Xcode 26 or later and choose an iPhone or iPad simulator. The package includes bundled Practice images and local example ranges; those values demonstrate the review controls and are not measurements of a real meal.

For an iPhone test later, download the repository or the candidate ZIP below, open `MealMirror.swiftpm` in Xcode, connect and unlock the iPhone, select it as the run destination, choose your Apple development team if Xcode requests signing, and press Run. The previous exact package was checked in Simulator; the current refreshed ZIP has not yet been rebuilt or installed. Camera capture and offline use on a physical device still need that device check.

The candidate is Swift-only and has no sign-in, required server, Dexcom/Libre connection, or insulin-dose calculation. A person can add up to three meal views and one nutrition-label image. Photo selection, Vision food inspection, and Vision label transcription stay on device. The label text is shown beside its photo for checking; it never fills a carbohydrate amount automatically. Its instructions, assets, and examples are bundled; no app screen needs a network connection. A photo never determines a portion or carbohydrate amount. When a food is not recognized, the person can add foods they know or enter a value from a package or another trusted source. A manually entered amount stays fixed and can be edited directly; the portion controls apply only to illustrative catalog ranges. The local catalog is finite; it does not cover every meal or culture, and its example ranges are not clinically validated.

MealMirror's product aim is to keep food and joy in everyday life after diagnosis. It should welcome family recipes, restaurant meals, snacks, celebrations, and foods from any culture without shaming choices. For a picture that leaves questions, the app should ask only for details the person can confirm.

Xcode 27.0 and the iOS 27 SDKs are installed on this Mac. Apple now documents Foundation Models image attachments, but the candidate still uses Vision and the image-model path has not been implemented or evaluated. The Xcode and Apple SDK license remains unaccepted, so the candidate cannot yet be rebuilt with this toolchain. Any model path must check device, region, and model readiness and keep a useful offline manual fallback. Broader food coverage and physical-device validation remain open.

## Language support

The everyday app includes a menu for English, French, Simplified Chinese, Cantonese (Traditional), Punjabi, Urdu, Tamil, Filipino, Spanish, Arabic, Persian, Hindi, Portuguese, Gujarati, Bengali, Japanese, Korean, and Hungarian. Some newly added strings still fall back to English in non-English locales; reviewed translations remain an open task. The Challenge package must follow the official language rules for its submission year.

## Swift Student Challenge packaging

Apple's currently published terms are for the 2026 Challenge; that deadline was February 28, 2026. Apple has not published the 2027 terms on the pages checked. The 2026 terms specify an offline `.swiftpm` ZIP, locally included resources, English content, a 25 MB maximum, and Xcode 26 or Swift Playgrounds 4.6 or later. Recheck Apple's [terms](https://developer.apple.com/swift-student-challenge/policy/) and [eligibility requirements](https://developer.apple.com/swift-student-challenge/eligibility/) before a later submission.

The current packaging script creates an English-only candidate archive:

```sh
./scripts/prepare-ssc-submission.sh
```

It writes `build/MealMirror-SSC2027.zip`, removes non-English resource catalogs and Xcode user state, and checks the currently published size limit. A generated archive is only a packaging artifact; it does not establish app readiness, applicant eligibility, authorship, or a completed submission.

For testing, [download the current candidate ZIP](candidate/MealMirror-SSC2027.zip), generated from app commit `03d9870`. Its SHA-256 is `bcb6393874f29db3f3bd9dd660701876a06e50038ce122b81b49db0e35c2a35d` and its size is 12,196,081 bytes. This package-only refresh updates the bundled README with the current toolchain status; app source and assets are unchanged. The prior archive (`ab082da88a5b600af6fbeac6858e5ab2930652cef078e782aa24d73286b479f9`, 12,195,987 bytes) was clean-built and installed/launched on iPhone 17, iPhone SE, and iPad mini simulators, and passed the full photo/label/manual-entry/save/history/delete journey on iPhone SE. The refreshed ZIP has passed deterministic packaging and integrity checks but has not been rebuilt or installed; the Xcode license is still pending. This is a review candidate, not a submission or clinically validated app. It includes the Pixel Kitchen UI, up to three numbered meal photos plus a separate label photo, local label transcription, and a checked manual-amount path. A manual iPhone 17 run on the prior exact archive reached local photo inspection with two meal photos and showed the honest unavailable/no-range state; label, confirmation, and save/history remain unverified there. The [readiness checklist](CHALLENGE-READINESS.md) distinguishes package evidence from remaining work.

## Project records

- [`PLAN.md`](PLAN.md) tracks the delivery goal, current evidence, product boundaries, and ordered work.
- [`CHALLENGE-READINESS.md`](CHALLENGE-READINESS.md) records the exact candidate ZIP, Apple checklist, Simulator checks, and open submission gates.
- [`SUBMISSION-COMPLETION-PLAN.md`](SUBMISSION-COMPLETION-PLAN.md) separates finished work, the remaining Challenge gates, and the decision about any future insulin calculator.
- [`APPLE-TECHNOLOGY-BRIEFING.md`](APPLE-TECHNOLOGY-BRIEFING.md) identifies the Apple frameworks used today and the unshipped on-device AI options.
- [`CGM-INTEGRATION-PLAN.md`](CGM-INTEGRATION-PLAN.md) explains Dexcom, Libre, and HealthKit access limits and the optional connected product path.
- [`COMPETITIVE-REVIEW.md`](COMPETITIVE-REVIEW.md) reviews public feature claims from RxFood and other meal-photo apps without unsupported superiority claims.
- [`WORLDWIDE-MEAL-EVALUATION.md`](WORLDWIDE-MEAL-EVALUATION.md) sets a broad, permissioned evaluation plan for meals and labels across cuisines and conditions, including unknown and nonfood cases.
- [`MealMirror.swiftpm/AI-AND-ASSET-DISCLOSURE.md`](MealMirror.swiftpm/AI-AND-ASSET-DISCLOSURE.md) is a working record; the applicant must reconcile it with the full project history and actual bundled assets.
