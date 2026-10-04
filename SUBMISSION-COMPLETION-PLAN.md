# MealMirror submission completion plan

Prepared October 3, 2026; active delivery goal resumed October 4. **Status: not submission-ready.** Apple's published [terms](https://developer.apple.com/swift-student-challenge/policy/) are still for the completed 2026 Challenge; confirm the next cycle's rules before treating any requirement as final. Clinical dose output and the applicant's submission remain separate gates.

## Goal and acceptance standard

Deliver one original, short, English-language Swift app playground that a judge can experience offline in about three minutes. It should demonstrate a private, photo-first meal review for someone new to Type 1 diabetes, with food freedom, truthful uncertainty, easy correction, and an inclusive interface. The exact submitted ZIP must build, launch, and complete the story on supported hardware. The applicant must understand and substantially contribute to the work, disclose AI assistance and assets, write their own responses, and meet the published eligibility requirements.

The strongest differentiator to prove is **useful on-device meal understanding with clear abstention**: a picture starts the experience, but the app asks only for what the picture cannot establish. No model, UI polish, or number of features guarantees an award. Apple's [judging terms](https://developer.apple.com/swift-student-challenge/policy/) cite technical accomplishment, creativity, and written responses; its [overview](https://developer.apple.com/swift-student-challenge/) also highlights innovation, social impact, and inclusivity.

## Current inventory

| Area | Done and evidenced | Missing or limited |
| --- | --- | --- |
| Native package | Swift 6/SwiftUI `.swiftpm`, iPhone/iPad targets, SwiftUI Pixel Kitchen theme, bundled fonts/assets. October 4 English-only generated ZIP after UI commit `4a47191` is 12,186,523 bytes with SHA-256 `a1e1cdb2d0d48847b7700f727ff17340641fd38061b1640c409582b2acbb4a44`; archive integrity and clean-extraction Xcode 26.6 generic iOS Simulator build passed. | Exact final ZIP needs rebuilding after every substantive change and complete on-device launch/run. Xcode emitted non-blocking duplicate asset warnings. |
| Meal entry | Photo-only flow, library picker, camera route, optional description, three Practice meals. Background downsampling and latest-photo selection guard are implemented. | Physical camera capture/return, a large real camera image, and a deliberately delayed library-selection race are unverified. |
| On-device image work | `VNClassifyImageRequest`, local mapping, 12-second fallback, request cancellation, and an honest unavailable state. Possible image labels start excluded. | iOS 26.5 Simulator labels for three distinct meals were unrelated. Mac Vision clue coverage was limited and had wrong food names. No independently validated broad meal model is integrated; no physical iPhone Vision result. |
| Carbohydrate review | Person can confirm/exclude items, adjust illustrative portions, add a trusted manually entered carb value, see source trail, and save/delete local reviewed history. Newly saved reviews retain the included foods, their sources and reviewed ranges; older records still open as range-only. | Catalog is finite and reference ranges are not clinically validated for arbitrary meals. Photos do not measure recipes, servings, or grams. Full edit/save/delete regression walkthrough is open. |
| Privacy/offline | Bundled guidance and resources, no required network/account/analytics/photo upload. History file is locally protected and photos are not saved. The [CGM integration decision](CGM-INTEGRATION-PLAN.md) maps official Dexcom, Libre and HealthKit routes. | Exact ZIP has not had a physical-device airplane-mode walkthrough. No connected CGM path. |
| Design/accessibility | Selected pot emblem, coherent warm light/dark palette, food-ring loading art, some VoiceOver labels, Dynamic Type/Reduce Motion and RTL handling. Home/Practice/Settings were inspected in Simulator. | Full every-screen light/dark/iPad/large-text/VoiceOver/RTL walkthrough and child/caregiver usability checks remain. |
| Language | Everyday source offers English and 17 more language choices; Challenge ZIP strips to English under the last published rules. | Non-English medical/legal strings and native-speaker QA are incomplete. Future Challenge language rules may change. |
| Competitive evidence | Public RxFood/SNAQ/Carbetic/CarbCam claims were reviewed; the current RxFood public feature map is in [replica/recon.md](replica/recon.md) and [replica/features.csv](replica/features.csv). MealMirror's offline/no-account design is a potential distinction. | No head-to-head product or accuracy comparison; do not claim superiority. |
| Submission | Packaging script, working AI/asset disclosure, previous clean ZIP build, public GitHub `main`. | Current eligibility, proof, applicant-owned essays, individual-contribution review, final archive, and actual submission are open. |

The app currently has **no insulin-unit calculation, Dexcom/Libre integration, pump connection, or treatment recommendation**. These are not hidden completed features. The October 4 public App Store listing adds RxFood text/recent/SMS logging, wearable context, education, recipes and expert support to the competitive baseline. The full connected service is larger than the offline three-minute Challenge slice.

## Priority 1 — prove the photo-first core

**Work:** Choose a permitted on-device image path. Evaluate Apple's WWDC26 Foundation Models image input when the matching Xcode/iOS toolchain and compatible hardware are available. Also evaluate a properly licensed compact Core ML/Core AI alternative that can be bundled under the ZIP limit. Keep the current Vision and manual recovery path until a replacement performs better. Do not bundle research-only model weights or a model merely because it recognizes the three Practice images. [Apple's WWDC26 model update](https://developer.apple.com/videos/play/wwdc2026/241/), [Core ML](https://developer.apple.com/documentation/coreml).

**Evidence needed:** A lawful, held-out collection with home-cooked, restaurant, school, mixed, packaged, culturally varied, and nonfood pictures; labels from reliable sources; separate model selection and final evaluation sets; outcomes for correct clues, incompatible clues, abstention, latency, battery/thermal behavior, and device support. Include an explicit unknown result for foods outside the model's scope. Set measurable pass criteria *before* final evaluation, with appropriate clinical/nutrition input. Do not interpret classification confidence as nutritional accuracy.

**Done when:** The exact bundled model or OS model reliably offers *reviewable food clues* on physical devices across the selected test set, declines to name food when it should, fits the archive and offline rules, and preserves a fast manual path. “Any meal” remains a direction unless evidence actually supports that breadth.

## Priority 2 — make review trustworthy and effortless

**Work:** Keep photo-only entry as the fastest route. Tighten the review around three things: possible visible foods, missing/uncertain ingredients and portions, and the source of any carbohydrate number. Let the person correct a clue quickly without moralizing about food. Make a trusted package-label/manual amount easy to enter and inspect. Keep Practice examples clearly separate from real nutrition claims.

**Evidence needed:** Clinician/dietitian review of all nutritional wording and any values intended for real-use claims; usability sessions with newly diagnosed people, caregivers, and age-appropriate participants; edge cases such as covered foods, sauces, shared plates, leftovers, and multiple dishes.

**Done when:** Every path from photo to review makes the origin and uncertainty of each number obvious; an unknown meal is still usable; no unconfirmed model clue creates a carb total. A new user can complete the core story in roughly three minutes, as [Apple's eligibility page](https://developer.apple.com/swift-student-challenge/eligibility/) asks.

## Priority 3 — finish native quality and accessibility

**Work:** Inspect and repair welcome, camera/library, loading, error, Practice, ingredient edit, review, history, privacy, and Settings in both appearances and on compact phone/iPad. Check Dynamic Type at accessibility sizes, VoiceOver order/labels, Reduce Motion, contrast, keyboard focus/dismissal, and RTL layouts. Review everyday translations with qualified speakers; preserve the required English-only Challenge package if the next rules repeat 2026.

**Done when:** A fresh-install walkthrough completes without clipped actions, dead ends, unreadable text, inaccessible controls, or language/safety copy that changes meaning. Keep dated screenshots and a short issue list for any remaining limitations.

## Priority 4 — verify the exact artifact and Apple requirements

**Work:** Rebuild the English-only `.swiftpm` ZIP after final changes, check integrity and size, extract into a clean location, build and run it with the required Xcode/Swift Playgrounds version, and complete the three-minute story in airplane mode on an iPhone. Exercise camera/library, unknown photo, correction, cancellation, manual trusted value, Practice, save/delete, and relaunch. Inspect the archive for all fonts/assets and no external dependency. Recheck current Apple rules and eligibility when the next Challenge opens.

**Done when:** The final ZIP—not merely the repo checkout—passes a recorded offline physical-device walkthrough, remains within Apple's then-current size/toolchain/language rules, and has no sign-in or judge tracking. The 2026 rules specify a `.swiftpm` ZIP, local resources, offline judging, 25 MB maximum, Xcode 26 or Swift Playgrounds 4.6+, English content, AI-use disclosure, and an individual contribution. [2026 terms](https://developer.apple.com/swift-student-challenge/policy/).

## Priority 5 — applicant-owned submission work

**Work:** Verify age/student/developer eligibility and award limits under the new rules; gather valid proof of enrollment and school contact; audit rights and explanations for fonts, logo, generated Practice images, code, and any future model; accurately disclose all Codex/AI assistance; review/revise and understand the entire app; write all required responses personally; submit once through Apple's form during the official window.

**Done when:** The applicant can explain how the photo path works, its measured limitations, why uncertain suggestions are excluded, the local data path, accessibility choices, and their own technical decisions. The disclosure and essays match the actual project history. Apple explicitly requires significant individual contribution and technical understanding, applicant-written essays, and individual work. [2026 terms](https://developer.apple.com/swift-student-challenge/policy/).

## Insulin calculation: formula identified, product decision still open

The likely calculation you remember is the **meal bolus**, often expressed conceptually as:

`meal coverage = carbohydrate grams ÷ prescribed insulin-to-carbohydrate ratio (grams per unit)`

`correction = (current glucose − prescribed target glucose) ÷ prescribed insulin sensitivity/correction factor (glucose units per insulin unit)`

`candidate bolus = meal coverage + any clinically appropriate correction`, with prior active insulin and other safety conditions handled according to that person's treatment plan and delivery system. Do **not** treat this shorthand as a ready-to-implement dosing algorithm. An [American Diabetes Association school medical-management plan](https://diabetes.org/sites/default/files/2023-10/DMMPNov12019final_0.pdf) shows the meal and correction terms as clinician-filled settings; a [children-and-families NHS guide](https://www.uclh.nhs.uk/patients-and-visitors/patient-information-pages/managing-food-activity-and-type-1-diabetes-introduction-newly-diagnosed-children-and-families) notes that ratios may vary by meal. Active insulin, delivery type, glucose trend, exercise, illness, low glucose, ketones, timing, and rounding can change what is appropriate. [NHS pump guidance](https://www.cuh.nhs.uk/patient-information/omnipod-dash-omnipod-5-manual-mode-handbook/), [NHS pediatric guidance](https://www.alderhey.nhs.uk/conditions/patient-information-leaflets/multiple-daily-injections-mdi-insulin-pens-high-blood-glucose-levels-without-ketones/).

The **500 rule** (`500 ÷ total daily insulin dose`) can estimate starting grams-per-unit ICR. The **1800 rule** (`1800 ÷ total daily insulin dose`, mg/dL) or **100 rule** (`100 ÷ total daily insulin dose`, mmol/L) can estimate a starting sensitivity factor. These are *initial estimates to be individualized*, not defaults to assign to a child or anyone else. Research in prepubertal children found that the 500 rule often needed adjustment, including different breakfast needs. [Pediatric pump study](https://pmc.ncbi.nlm.nih.gov/articles/PMC5478012/), [NHS pump dose guide](https://diabetesandendocrinology.heartofengland.nhs.uk/wp-content/uploads/2013/02/Navigator-Insulin-Pump-Dose-Adjustment-Guidelines.pdf).

**If the applicant chooses a real dose calculator for MealMirror:** first obtain a qualified clinical partner and a written intended-use/clinical protocol. Specify who enters and verifies the individual ICR, correction factor, target, insulin type, active-insulin duration, delivered doses, glucose source, device increment/rounding, and exceptions. Decide how to prevent unit mix-ups (`mg/dL` versus `mmol/L`), stale/missing CGM values, duplicated boluses, incorrect portions, lows/ketones, and pediatric-specific errors. Independently validate reference cases and failure cases, use human-factors testing, secure sensitive settings, and obtain regulatory/App Store review appropriate to distribution. Never let a photo-derived or illustrative catalog range silently become an insulin recommendation. The exact active-insulin adjustment is device- and protocol-specific; it cannot be reduced to one universal subtraction rule. [ADA plan](https://diabetes.org/sites/default/files/2023-10/DMMPNov12019final_0.pdf), [NHS bolus-app explanation](https://www.uclh.nhs.uk/patients-and-visitors/patient-information-pages/mylife-bolus-advice-app), [Apple App Review Guideline 1.4.2](https://developer.apple.com/app-store/review/guidelines/), [Health Canada ML medical-device guidance](https://www.canada.ca/en/health-canada/services/drugs-health-products/medical-devices/application-information/guidance-documents/pre-market-guidance-machine-learning-enabled-medical-devices.html).

**Challenge decision:** Apple's published Student Challenge terms do not explicitly ban a medical calculator, but that does not validate one. App Store Guideline 1.4.2 is a separate distribution rule and places a high bar on drug-dosage calculators. The recommended Challenge scope is to finish the dependable offline meal-review story first and keep dose output out **unless** a clinical partner, individual treatment-plan inputs, safety verification, and applicable clearance/review are completed in time. The broader regulated product can pursue dosing and Dexcom/Libre integration after those gates. This is a proposal for the applicant to review, not an implemented change.

## Decision points for applicant review

1. Confirm the desired Challenge story: offline photo → honest clue/unknown → quick correction → understood meal review.
2. Decide whether insulin *education only* belongs in the short playground, or whether a real personalized calculator should enter a separate clinical workstream. If selecting a calculator, identify the clinical partner and the exact prescribed protocol first.
3. Provide physical iPhone access for final camera/Vision/offline evidence when available.
4. Review the final ownership, AI/asset, eligibility, and personal-essay obligations before any application is submitted.

No implementation or medical recommendation was added by this planning document. No award outcome is guaranteed.
