# MealMirror

MealMirror is a short, offline SwiftUI experience for reviewing meal carbohydrates. Its aim is to make the first step approachable for a newly diagnosed child or adult while preserving the joy and choice of everyday food. The Pixel Kitchen theme uses the user's selected MM pot emblem, Pixelify Sans for short Latin-script headings, Nunito for Latin-script reading text, native fonts for other scripts, and kitchen dialogue panels.

The product direction begins with a photo, then asks the person to confirm anything a photo cannot establish. Build 3 adds Apple's local Foundation Models image path on supported iOS 27 devices. It checks availability, image and structured-output capability, and language before requesting tentative main visible food or dish names from up to three views of one meal. These names stay separate from all carbohydrate values. Tapping one opens an editable name with a blank checked-amount field; it does not add an ingredient or amount by itself. Unsupported models, timeouts and errors retain local Vision/manual review, with no cloud fallback. Separate iOS 27.1 Simulator checks completed synthetic and real-photo requests without creating carbohydrate amounts. A fixed whole-food/dish prompt was reviewed on eight development photos and three separate snack/dessert/drink scope examples; it reduced some unsupported recipe guesses in that small comparison. Names remain unconfirmed, including uncertain drink contents and mixed-dish components. This is limited processing and tuning evidence; the complete app journey, independent real-meal accuracy and physical offline use remain unverified.

Photo-only entry also works without the new model. The iOS 26.5 Simulator's general Vision classifier returned the same unrelated scene labels for three distinct meal photos. MealMirror marks that known result as unavailable and shows no reliable range. A separate macOS Vision run recognized the biryani image; physical iPhone/iPad behavior remains unverified.

## Open and run

Open this `MealMirror.swiftpm` package in Xcode 27.1 or later, choose an iPhone or iPad simulator, and run. Xcode 27.1 is the verified toolchain for the image-input API; the app's deployment floor remains iOS 17, with the new model path gated to iOS 27. The included images, catalog, instructions, and sample ranges are local. The meal-review flow has no account or network dependency. Swift Playgrounds compilation has not been verified.

## Three-minute walkthrough

1. On first launch, tap **Choose a meal photo from your library**. Select a photo for your own review, or close the picker to explore the entry screen. Later, Home offers **Camera**, **Library**, and **Start a meal review**.
2. For a guided example, scroll to **Optional Practice** and choose biryani, grain bowl, or breakfast. A Practice choice opens its example review directly; no personal photo or measured serving is implied.
3. Inspect the possible items and example carbohydrate range. Include, exclude, or adjust portions, then confirm the meal parts and open the final review.
4. Read the source trail and final check; save only if a local note is useful. A personal photo or description instead uses **Build my local review** before this step.

Practice numbers teach the review controls. They do not analyze the example image, validate a real serving, or replace a package label or trusted carb-counting method.

## Product boundary

- No sign-in, required server, analytics, or photo upload.
- No insulin ratio, insulin units, correction, treatment recommendation, pump connection, Dexcom, or Libre integration in this Challenge candidate.
- The app does not tell someone what to eat. It shows the source and limits of a carbohydrate estimate for the person to review.
- If the photo is unclear, the person can name foods or add a carbohydrate amount from a package or another trusted source. Photo labels never set portion sizes or carbohydrate values.
- Local catalog values are illustrative and finite; MealMirror does not currently analyze arbitrary home-cooked, restaurant, mixed, or culturally specific meals from a photo alone.
- Build 3 uses the iOS 27.1 SDK while retaining an iOS 17 deployment minimum. Apple Intelligence hardware, an enabled and ready local model, supported capabilities and locale are required for the new image path. It remains unvalidated on real meals and cannot be described as arbitrary-meal recognition. The exact ZIP must be checked after this change. [Apple image prompting API](https://developer.apple.com/documentation/FoundationModels/analyzing-images-with-multimodal-prompting).

## Languages

The everyday app has English, French, Simplified Chinese, Cantonese (Traditional), Punjabi, Urdu, Tamil, Filipino, Spanish, Arabic, Persian, Hindi, Portuguese, Gujarati, Bengali, Japanese, Korean, and Hungarian choices. Its catalogs include the new photo-model status text, but older English fallbacks and unreviewed translations remain. The Challenge archive is made English-only to match Apple's last published terms.

## Challenge status

Apple's currently published rules are for the 2026 Challenge, whose February 28, 2026 deadline has passed. Apple has not published the 2027 rules on the official pages checked for this project. The 2026 rules require a locally resourced, offline `.swiftpm` ZIP of up to 25 MB, English content, and Xcode 26 or Swift Playgrounds 4.6 or later. Recheck the [official terms](https://developer.apple.com/swift-student-challenge/policy/) and [eligibility requirements](https://developer.apple.com/swift-student-challenge/eligibility/) for the next cycle.

Create an English-only candidate archive from the repository root with:

```sh
./scripts/prepare-ssc-submission.sh
```

The applicant still owns eligibility, current enrollment proof, a complete AI/asset disclosure, personal review and understanding of the work, their own essay answers, and final submission.

The bundled [`AI-AND-ASSET-DISCLOSURE.md`](AI-AND-ASSET-DISCLOSURE.md) is the working provenance record. The source repository maintains the detailed readiness checklist and remaining work separately from this standalone playground.
