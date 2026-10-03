# MealMirror

MealMirror is a short, offline SwiftUI experience for reviewing meal carbohydrates. Its aim is to make the first step approachable for a newly diagnosed child or adult while preserving the joy and choice of everyday food. The Pixel Kitchen theme uses the user's selected MM pot emblem, Pixelify Sans for short Latin-script headings, Nunito for Latin-script reading text, native fonts for other scripts, and kitchen dialogue panels.

The product direction begins with a photo, then asks the person to confirm anything a photo cannot establish. Photo-only entry works, but iOS 26.5 Simulator's general Vision classifier returned the same unrelated scene labels for three distinct meal photos. MealMirror marks that known result as an unavailable inspection and shows no reliable range. A separate macOS Vision run recognized the biryani image; physical iPhone/iPad behavior remains unverified.

## Open and run

Open this `MealMirror.swiftpm` package in Xcode 26 or later, choose an iPhone or iPad simulator, and run. The included images, catalog, instructions, and sample ranges are local. The meal-review flow has no account or network dependency.

## Three-minute Practice walkthrough

1. Tap **Start a meal review** on Home, then scroll to **Optional Practice**.
2. Choose the bundled biryani, grain-bowl, or breakfast Practice meal and tap **Build my local review**.
3. Inspect the example items and carbohydrate range. Adjust or exclude anything that does not fit.
4. Read the review trail and final check; save only if a local note is useful.

Practice numbers teach the review controls. They do not analyze the example image, validate a real serving, or replace a package label or trusted carb-counting method.

## Product boundary

- No sign-in, required server, analytics, or photo upload.
- No insulin ratio, insulin units, correction, treatment recommendation, pump connection, Dexcom, or Libre integration in this Challenge candidate.
- The app does not tell someone what to eat. It shows the source and limits of a carbohydrate estimate for the person to review.
- If the photo is unclear, the person can name foods or add a carbohydrate amount from a package or another trusted source. Photo labels never set portion sizes or carbohydrate values.
- Local catalog values are illustrative and finite; MealMirror does not currently analyze arbitrary home-cooked, restaurant, mixed, or culturally specific meals from a photo alone.
- The installed Xcode 26.6 / iOS 26.5 SDK does not expose Apple's documented Foundation Models image-attachment API. The current photo path uses Vision; a broader on-device food model remains open work.

## Languages

The everyday app has English, French, Simplified Chinese, Cantonese (Traditional), Punjabi, Urdu, Tamil, Filipino, Spanish, Arabic, Persian, Hindi, Portuguese, Gujarati, Bengali, Japanese, Korean, and Hungarian choices. Some new strings fall back to English in non-English catalogs and still need reviewed translation. The Challenge archive is made English-only to match Apple's last published terms.

## Challenge status

Apple's currently published rules are for the 2026 Challenge, whose February 28, 2026 deadline has passed. Apple has not published the 2027 rules on the official pages checked for this project. The 2026 rules require a locally resourced, offline `.swiftpm` ZIP of up to 25 MB, English content, and Xcode 26 or Swift Playgrounds 4.6 or later. Recheck the [official terms](https://developer.apple.com/swift-student-challenge/policy/) and [eligibility requirements](https://developer.apple.com/swift-student-challenge/eligibility/) for the next cycle.

Create an English-only candidate archive from the repository root with:

```sh
./scripts/prepare-ssc-submission.sh
```

The applicant still owns eligibility, current enrollment proof, a complete AI/asset disclosure, personal review and understanding of the work, their own essay answers, and final submission.

See [`../PLAN.md`](../PLAN.md) for current evidence and remaining work, and [`AI-AND-ASSET-DISCLOSURE.md`](AI-AND-ASSET-DISCLOSURE.md) for the working provenance record.
