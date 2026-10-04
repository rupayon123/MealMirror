# MealMirror Challenge readiness checklist

Reviewed October 3, 2026. This is an evidence inventory, not a submission or an award prediction. Apple's published [terms](https://developer.apple.com/swift-student-challenge/policy/) still describe the **2026** Challenge, whose February 28 deadline has passed; [2027 rules](https://developer.apple.com/swift-student-challenge/) have not been published on the pages checked. Reconcile every item when the next rules appear.

The freshly regenerated ZIP is 12,186,125 bytes, SHA-256 `8e01885b46fbffb8a9b9dcde59a8967d76c3f20b5710bf2c9a617c665acdf1d0`. Its archive integrity/locales check passed, and a clean extraction built for a generic iOS Simulator with Xcode 26.6. Xcode reported duplicate `Brand.xcassets` build-file warnings; the build exited successfully. This is build evidence, not a device or full-flow pass.

## What the current app can do

| Capability | Current behavior and limit |
| --- | --- |
| Start a meal | Opens a short SwiftUI onboarding and a photo-first meal flow. The person can use the camera on a supported device, choose a library image, type a description, or select one of three bundled Practice meals. A selected photo alone can advance to review. Camera capture and return have not been verified on physical hardware. |
| Inspect a photo offline | Uses Apple's local Vision classifier and a small bundled food catalog. It never uploads the image. Possible food matches start excluded, and a photo never sets portions or carbohydrate grams. The current iOS 26.5 Simulator returned unrelated scene labels for three different meal images; the app shows inspection unavailable and no range in that case. Broad or reliable any-meal recognition is **not implemented**. |
| Recover from an unknown photo | Allows the person to name foods or enter a carbohydrate amount copied from packaging or another trusted source. The result identifies that input as user-entered. This is not nutrition validation. |
| Review an estimate | Shows included and excluded items, adjustable portion choices for local catalog examples, an illustrative range where supported, a source/review trail, and a final confirmation step. The local catalog is finite and its example ranges are not clinically validated. |
| Learn with Practice | Includes synthetic biryani, grain-bowl, and breakfast images with example review data. These values teach the controls; they are not measurements of those pictured servings. |
| Save and control history | Can save a reviewed description, range, and date in protected local storage; shows saved reviews and offers deletion. It does not save meal photos. |
| Work without an account | Meal review, reference content, assets, and storage are local. There is no required server, sign-in, judge tracking, or analytics in the candidate source. Actual offline airplane-mode use on a physical device is still unverified. |
| Present the Pixel Kitchen theme | Uses the selected pot emblem, warm adaptive colors, bundled Pixelify and Nunito fonts, food-ring loading art, and matching review cards. Home, Practice, and Settings have been inspected in Simulator light and dark mode; full-flow and large-text visual review remains open. |
| Support languages | The everyday source offers English plus 17 other language choices. Several translations and medical/legal strings still need native review. The generated Challenge ZIP contains English only, matching the last published rules. |
| Accessibility | Source includes many VoiceOver labels/identifiers and Reduce Motion handling. Direct VoiceOver, all screens at large Dynamic Type, contrast, and right-to-left checks remain incomplete. |

The candidate does **not** connect to Dexcom or Libre, compute insulin units, provide a correction or treatment recommendation, measure portions from an image, or reliably recognize arbitrary home-cooked, restaurant, mixed, and culturally varied meals. Those missing capabilities must not be implied by the demo. See [PLAN.md](PLAN.md) and the [competitive review](COMPETITIVE-REVIEW.md) for the product direction and RxFood comparison.

## Apple's published checklist and evidence

The checkmarks below mean the *current 2026 wording* has been checked against this candidate. They cannot certify a future Challenge. Apple's [eligibility page](https://developer.apple.com/swift-student-challenge/eligibility/) also calls for an app playground that can be experienced in three minutes.

| 2026 requirement or judging concern | Status | Evidence or remaining action |
| --- | --- | --- |
| One `.swiftpm` app playground in a ZIP | **Checked for package shape** | `scripts/prepare-ssc-submission.sh` creates `MealMirror.swiftpm` inside one ZIP and checks its required files and integrity. |
| ZIP at most 25 MB | **Checked for current candidate** | The regenerated archive is 12,186,125 bytes. Recheck after any model or asset change. |
| Fully local resources and offline judging | **Source and archive checked; device run open** | Bundled fonts, pictures, catalog, and instructions; no required network call in the candidate. Run the exact ZIP in airplane mode on hardware before final claim. |
| Xcode 26 or Swift Playgrounds 4.6 or later | **Xcode path checked** | Candidate builds with installed Xcode 26.6 for iOS Simulator. Swift Playgrounds 4.6 and physical hardware have not been checked. |
| English content | **Archive checked** | Packaging removes non-English `.lproj` directories and catalog entries. Inspect all rendered English screens once more. |
| Experience in three minutes | **Designed; timing open** | The included Practice walkthrough is short, but the full fresh-install path has not been timed end to end. |
| Function during judging | **Partial** | The package builds and previously exercised paths work in Simulator. Camera, full edit/save/delete flow, accessibility, and hardware photo inspection need an end-to-end run. |
| No required sign-in or judge tracking | **Source checked** | No account or analytics dependency in the playground source. |
| AI assistance fully disclosed | **Applicant action open** | [Working disclosure](MealMirror.swiftpm/AI-AND-ASSET-DISCLOSURE.md) lists Codex, Apple Vision, and generated Practice artwork. Applicant must audit the entire history and accurately disclose all assistance in Apple's form. |
| Individual creation and technical understanding | **Applicant action open** | Apple requires significant individual contribution and understanding. Applicant must review, revise, and be able to explain the final playground; the repository or this checklist cannot establish that. |
| Third-party licensing and explanation | **Applicant action open** | Bundled font licenses are present; applicant must reconcile all assets, artwork, code, and license explanations before submission. Research-only model weights are outside the app. |
| Applicant-written essays | **Applicant action open** | Apple's required answers must be written by the applicant. |
| Age, developer registration, student status, award limits | **Applicant action open** | Applicant must verify eligibility under the rules active when submission opens. |
| Current class schedule or proof and school contact | **Applicant action open** | 2026 form required valid proof showing applicant name, institution, and dates, plus dean/principal contact. |
| One submission via Apple's form by deadline | **Future action** | 2026 deadline passed. Wait for the next official window and submit once with required fields/files. |
| Technical accomplishment and creativity | **Judging quality open** | A usable offline experience exists, but unreliable food recognition and incomplete physical-device validation weaken its core demonstration. |
| Social impact and inclusivity | **Direction present; evidence open** | Food freedom and uncertainty are explicit. Test with children/adults and diverse real meals, plus accessibility review, before claiming broad usefulness. |

Official sources: [2026 terms](https://developer.apple.com/swift-student-challenge/policy/), [eligibility and three-minute guidance](https://developer.apple.com/swift-student-challenge/eligibility/), [Challenge homepage](https://developer.apple.com/swift-student-challenge/). Apple judges technical accomplishment, creativity, and written responses; awards are discretionary. No checklist can guarantee selection.

## Next actions in priority order

1. **Make the photo promise real.** Establish a licensed on-device model or other Apple-supported route; evaluate independent culturally varied cooked/mixed meals and realistic nonfood images. Measure correct suggestions, safe abstention, latency, and final ZIP size. Keep unknown meals unknown until evidence supports recognition.
2. **Run the exact ZIP on an iPhone.** Check camera and library, photo-only entry, unknown-photo recovery, Practice, portion edits, review trail, local save/delete, airplane mode, and returning from a canceled analysis. Record hardware Vision results and timing.
3. **Finish a full design and accessibility pass.** Inspect every screen in light/dark mode, compact phone and iPad, large text, VoiceOver, Reduce Motion, and right-to-left layouts. Complete native review for everyday translations, especially safety text.
4. **Have the applicant review ownership.** Reconcile AI assistance, generated art, licenses, code comprehension, eligibility proof, and personally written essays. Do not submit until the applicant can stand behind the work.
5. **Recheck the next official terms.** Repackage and rerun the exact artifact after the final code change and when Apple posts the next year's rules.

The connected physical iPhone was unavailable at this review. Dexcom/Libre and insulin dosing are separate future product work requiring vendor access and clinical/safety validation; they are not a shortcut to Challenge readiness.
