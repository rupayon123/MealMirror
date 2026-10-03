# New Vision image-classification API probe — October 3, 2026

Apple's newer [`ClassifyImageRequest`](https://developer.apple.com/documentation/vision/classifyimagerequest) is a plausible replacement for the older `VNClassifyImageRequest`. This isolated experiment checks whether that API changes the bad food-photo result observed in iOS Simulator. It does not run in the submission candidate.

## Reproduction

1. Copy `MealMirror.swiftpm` to a scratch package and change the copied package's bundle identifier, leaving the source repository untouched.
2. Copy `NewVisionProbe.swift` into the copied package. Add `.task { await runVisionProbe() }` to the copied app's root view.
3. Build and launch the copied package on an iPhone 17 / iOS 26.5 Simulator using Xcode 26.6. Read `new-vision-probe.json` from the app's Documents container.

The probe loads the three bundled synthetic meal images from `Bundle.module`, runs the new request once with its default compute choice and once with CPU selected, and records its top eight identifiers and confidences. [`ios26-new-api-results.json`](ios26-new-api-results.json) is the captured result. The host ran macOS 26.4. No network or model download was used by this probe.

## Result and decision

CPU returned `outdoor`, `night_sky`, `sky`, `celestial_body`, and `moon` for each meal image. The first two confidence values were about 0.49 for all three. The default path gave the same labels for the breakfast and grain bowl, and failed with `Failed to create espresso context` for biryani. Thus the new Swift Vision request does not repair this particular Simulator failure. It may share the underlying classifier path; that is an inference, not a demonstrated implementation detail.

Keep the existing unavailable result for this known Simulator pattern. This experiment cannot establish behavior on a physical iPhone or any other OS release. Do not treat these labels as food or derive carbohydrate grams from them.

## Bounded fallback check

The candidate's `VisionPhotoInspector` now resumes its inspection as unavailable after 12 seconds if Vision does not answer. To exercise that path without changing the candidate, a second copied package inserted `Thread.sleep(forTimeInterval: 30)` at the start of the background classification closure. Its root `.task` called `VisionPhotoInspector.inspect` with the bundled biryani image and saved the elapsed time and status to Documents. The [captured result](ios26-timeout-results.json) was `unavailable` after 12.25 seconds on the same iPhone 17 Simulator. This verifies the fallback under a deliberate stall; it does not measure real Vision latency or a physical device.

The current candidate also calls `VNRequest.cancel()` when that 12-second fallback fires. A locked gate prevents a late Vision callback from resuming the same continuation twice and cancels a request registered after the timeout. The clean iOS Simulator build verifies this integration compiles; the earlier delayed-request probe did not exercise cancellation, so resource savings and exact cancellation timing remain unmeasured.

## Food-label gate and deeper clue scan — October 3, 2026

On macOS 26.4 with Xcode 26.6, `VNClassifyImageRequest` returned a broad `food` label for all three bundled Practice photos (confidence 0.93 for biryani, 0.84 for the grain bowl, 0.63 for breakfast). Biryani itself scored 0.92. Quinoa appeared tenth for the grain bowl at 0.18, beyond the app's previous five-label cutoff. These are synthetic Practice images and a macOS result, not iPhone validation. Apple's [Vision classification documentation](https://developer.apple.com/documentation/vision/vnclassifyimagerequest) describes these outputs as labels with confidence values, not nutrition measurements.

The research-only [`MacVisionFoodGateProbe.swift`](MacVisionFoodGateProbe.swift) emits the top labels and broad-food confidence as JSON lines for image paths supplied locally. The experiment used the first 100 UECFoodPix test photos as meals and the first 100 images from each of the Oxford-IIIT Pet test and Oxford 102 Flowers validation mirrors as nonfood. Photos and model outputs with per-image labels stayed outside the repository. Of 100 meals, 88 had `food` confidence at least 0.10 and 67 had at least 0.50. None of the 100 pets reached 0.10; five flowers did, including two above 0.50. Thus a broad-food gate filters many meals at a high threshold and is not proof that an image is food at any threshold. The sample is limited and was inspected while choosing the threshold, so it is exploratory rather than an independent performance estimate.

The candidate now scans up to 12 Vision labels above 0.08 when the broad `food` confidence is at least 0.10, allowing lower-ranked food clues to reach the existing local catalog. Every photo-origin component remains excluded from the carbohydrate total until the person reviews it. The known broken iOS 26.5 Simulator result still reports inspection unavailable. No output from this macOS experiment establishes food recognition on a physical iPhone, a portion, carbohydrate grams, or dose advice.
