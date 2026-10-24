# Foundation Models research evidence

Reviewed October 24, 2026. This records native Mac probes and a source-derived iOS Simulator integration run. The latter executes the exact ZIP's processing code in a separate QA app, with real UIKit preparation and no Mac image substitution. It is **not** an exact-app UI/full-journey, physical-device, airplane-mode or accuracy pass. Limited synthetic mechanics and previously exposed real-photo exploratory checks do not establish independent acceptance performance.

Raw logs and harness sources remain in local output folders outside the repository and Challenge ZIP. The links below resolve in this Mac workspace; they are not publicly distributed artifacts. No images, model weights or executables are added here.

## Dated model readiness

| Check | Recorded result | Evidence and scope |
| --- | --- | --- |
| October 22, 5:32 p.m. EDT | `modelNotReady`; inference skipped | [Earlier probe](../../../../outputs/offline-ai-20261022/heartbeat-readiness-2131.json). Historical setup failure, preserved after the later success. |
| October 22, 9:26 p.m. EDT | `available`, vision and guided generation true | [Later probe](../../../../outputs/offline-ai-20261022/heartbeat-readiness-0126.json). `supportsLocale` returned true for English, French, Spanish and Japanese, false for Arabic and Bengali. This is an availability check, not multilingual recognition evaluation. |

The later preliminary probe completed one bundled synthetic biryani image and returned tentative rice, chicken, salad and yogurt names. Its prompt/schema differ from the app: it omits the `visibleFood` Boolean and uses a different token bound. Do not substitute that output for the source-derived harness below or present it as an app result. Clock anomalies prevent calibrated latency claims.

## Original-prompt source-derived native Mac harness — historical

The [harness report](../../../../outputs/offline-ai-20261023-native/RESULTS.md), [source provenance](../../../../outputs/offline-ai-20261023-native/source-provenance.json), [platform adaptation diff](../../../../outputs/offline-ai-20261023-native/platform-adaptation.diff) and [final provenance checks](../../../../outputs/offline-ai-20261023-native/final-provenance-checks.json) document a native Mac build and execution from source checkout `fed98db1281d39f259a2e862a65d98453c4f71fb`.

The October 23 app prompt/instructions, `VisibleFoodNames` schema, generation options, locale/capability checks, image-count bound, one-shot continuation gate and cancellation/error mapping are preserved. The schema contains only visible-food status and a bounded list of possible names; it has no portion, nutrition, glucose or insulin fields. The copied `PhotoNamePolicy` is byte-identical; it bounds display text, not semantic accuracy. The source's 15-second caller gate remains present, but the recorded clocks do not prove an observed strict deadline.

UIKit is unavailable in the Mac command-line harness. Declared substitutions replace `UIImage` with a CGImage/orientation wrapper, iOS availability with macOS availability, and UIKit thumbnail preparation with CoreGraphics downsampling using the same 768-pixel bound. All fixtures in those synthetic runs were upright PNGs. This does not exercise iOS decoding, camera images, rotation/mirroring, SwiftUI or the exact ZIP. The [native build](../../../../outputs/offline-ai-20261023-native/build-result.json) and [clock-instrumentation rebuild](../../../../outputs/offline-ai-20261023-native/build-monotonic-result.json) exited 0.

| Synthetic case | Recorded result | What this establishes |
| --- | --- | --- |
| One bundled biryani image | `inspected`, one photo; accepted tentative names: chicken, rice, cucumber, tomato, onion, yogurt | [Food result](../../../../outputs/offline-ai-20261023-native/synthetic-food-result.json). One request completed through the adapted app prompt/schema/filter/gate. No ground-truth identity or nutritional validation. |
| Geometric nonfood diagram, first attempt | `unavailable(.timeout)` | [Nonfood result](../../../../outputs/offline-ai-20261023-native/synthetic-nonfood-result.json). Error recovery, not successful nonfood abstention or strict observed deadline proof. |
| Full synthetic image plus two overlapping crops | `inspected`, three attachments; accepted names empty | [Derived-view result](../../../../outputs/offline-ai-20261023-native/same-meal-derived-views-result.json). Multi-attachment/empty-result mechanics. These are derived views of one synthetic image. The accepted list alone cannot distinguish `visibleFood=false`, empty names or policy rejection. |
| Same geometric nonfood diagram, retry | `unavailable(.failed)` | [Retry result](../../../../outputs/offline-ai-20261023-native/synthetic-nonfood-retry-result.json). Generic failure, not recognized nonfood or semantic abstention. |

Each recorded inference process exited 0 without the outer harness timeout. Conflicting first-run clock readings are retained in the logs; they preclude calibrated latency comparisons or a strict observed deadline claim. Later consistent isolated readings still do not establish representative performance. No connectivity-isolation test was performed.

### Separate guardrail diagnostic

One separately instrumented retry of the geometric fixture identified `FoundationModels.LanguageModelError.guardrailViolation` before preserving the app's generic failed mapping. The sanitized category identifies that run's error; it does not identify the input/instruction/output trigger or prove either earlier failure shared the cause. Guardrails were not weakened. See [diagnosis](../../../../outputs/offline-ai-20261023-native/diagnostic-nonfood/DIAGNOSIS.md) and [diagnostic-only diff](../../../../outputs/offline-ai-20261023-native/diagnostic-nonfood/diagnostic-only.diff).

Evaluate guardrail failures, other errors, timeout, unavailability, inspected-empty and policy-rejected output separately. An error fallback must not count as correct nonfood classification.

## iOS rendering and historical runtime limits

The previous `26baa803…` ZIP installed/launched on Duo and its initial Pixel Kitchen Home was visibly checked. Persisted onboarding means this is not a fresh welcome pass. An external fixture separately renders synthetic food names and the checked-amount action without numeric amounts; it is outside the ZIP and performs no model inference or verified interactions. Screenshot hashes and per-artifact scope live once in [Challenge readiness](../../CHALLENGE-READINESS.md).

Historical October 22 failures remain: the earlier build-3 source install on Duo succeeded, but launch reported exit 204/Mach error -308 while the host was heavily overloaded. Exact-ZIP installation on the iOS 26.5 iPhone 16 Pro Simulator timed out at 45 seconds twice, including after boot completion. Later Duo install/launch recovery does not establish an older-system pass. See [first older-system install](../../../../outputs/offline-ai-20261022/ios26-exact-install.json), [retry](../../../../outputs/offline-ai-20261022/ios26-exact-install-retry.json), [recovered Duo install](../../../../outputs/offline-ai-20261022/duo-retry-0126-install.json) and [launch](../../../../outputs/offline-ai-20261022/duo-retry-0126-launch.json).

The locked Mac prevents interactive computer-use QA. These historical renders alone do not establish clue taps, checked-amount interactions, scrolling, complete large-text/dark-mode coverage or the full meal journey. The separate source-derived iOS model request is recorded below; it is processing evidence rather than a rendered interaction. The duplicate uncertainty reminder in the external fixture is a companion UI follow-up.

## October 24 previously exposed real-photo exploration — four calls completed

**No real-meal recognition was demonstrated in this original-prompt four-call cohort.** The [frozen manifest](../../../../outputs/offline-ai-20261023-native/previously-exposed-12/manifest.json) selected 12 previously exposed fixtures before new inference, then recorded four specifically authorized serial calls: two meal images, one dog and one cat. Eight frozen cases remain unrun. The unchanged source-derived binary still matched its frozen hash. There were no retries within this four-call experiment and no outer process timeouts.

| Executed case | Fixture/source | Recorded result | Interpretation |
| --- | --- | --- | --- |
| `uec-1919` | `food-000.jpg`; UECFoodPix approximate-mask edition, noodle image | `unavailable(.failed)` | No accepted clue; underlying cause is suppressed by the unchanged binary. |
| `uec-5803` | `food-001.jpg`; UECFoodPix approximate-mask edition, fish image | `unavailable(.failed)` | No accepted clue; underlying cause is suppressed by the unchanged binary. |
| `pet-000` | Oxford-IIIT Pet dog control | `unavailable(.failed)` | Error recovery, not successful nonfood abstention. |
| `pet-009` | Oxford-IIIT Pet cat control | `inspected`, accepted names empty | A successful empty clue list, without visibility into raw `visibleFood` or whether filtering removed names. Not broad semantic abstention evidence. |

All four processes completed: three generic failed results and one inspected-empty result. No accepted food name was available to compare for compatibility; errors must not be counted as correct recognition or abstention. The manifest records visual inspection of the four actual images and their hashes. Dataset dish labels do not establish hidden ingredients, portions, carbohydrate amounts or insulin ground truth. Raw monotonic readings remain local reproducibility records, not calibrated or iOS latency evidence.

The frozen selection used the first eight existing food-manifest entries plus the first two dog and first two cat copies; only the four cases above ran. These photos had already been used in Vision/TinyCLIP/segmentation screening. Prior exposure, small scope and incomplete execution prevent treating this as an independent held-out acceptance set or a completed 12-case evaluation.

### Two separate real-food diagnostic retries

After the four-call experiment, two separately logged diagnostic calls reused the noodle and fish files. Both identified `FoundationModels.LanguageModelError.guardrailViolation` and mapped to `unavailable(.failed)`: [food-000 diagnostic](../../../../outputs/offline-ai-20261023-native/diagnostic-real-food/food-000-diagnostic.json), [food-001 diagnostic](../../../../outputs/offline-ai-20261023-native/diagnostic-real-food/food-001-diagnostic.json). Their exact input/instruction/output trigger is unknown. They identify the error in those new calls; they do not expose the cause of the earlier three generic failures or establish nonfood/food recognition. Keep these two retries separate from the four-call cohort and its zero-retry count.

The binaries' inherited raw labels still say `synthetic-food` and, in diagnostic stderr, synthetic-nonfood scope. Those strings are not correct provenance for these real photos: `synthetic-food` selected the reusable file-loader path. The enclosing manifest/diagnostic records truthfully identify the real research fixtures. Raw records are preserved rather than relabeled. No guardrail was disabled or weakened, and no app source or ZIP changed.

### Source rights and image handling

The [official UECFoodPix page](https://mm.cs.uec.ac.jp/uecfoodpix/) limits use to non-commercial research and distinguishes approximate GrabCut masks from the manually annotated Complete edition; this cohort uses the approximate edition. The [official Oxford-IIIT Pet page](https://www.robots.ox.ac.uk/~vgg/data/pets/) identifies a Creative Commons Attribution-ShareAlike 4.0 International license and retains copyright with original image owners. These rights statements were checked October 24. No cohort image is redistributed in this repository or included in the app/Challenge ZIP; source IDs, hashes and local paths remain in the manifest.

## October 24 ordinary food-classification comparison — completed and fixed text applied

The [comparison report](../../../../outputs/offline-ai-20261024-benign-prompt/RESULTS.md), [frozen manifest](../../../../outputs/offline-ai-20261024-benign-prompt/frozen-manifest.json) and [source fidelity/outcomes](../../../../outputs/offline-ai-20261024-benign-prompt/source-fidelity-and-outcomes.json) record five preselected serial calls with no retries. The fixed text clarifies ordinary visible food-name classification and removes unnecessary medical-domain wording. No hidden ingredients, recipes, amounts/portions, recommendations or untrusted image instructions are allowed; uncertain names remain person-correctable.

| Fixture | Fixed-text native Mac comparison result |
| --- | --- |
| Previously exposed noodle image `uec-1919` | `inspected`: tentative noodles, green onions |
| Previously exposed fish image `uec-5803` | `inspected`: tentative fish |
| Previously exposed dog `pet-000` | `inspected`: accepted names empty |
| Previously exposed cat `pet-009` | `inspected`: accepted names empty |
| Bundled synthetic biryani illustration | `inspected`: tentative rice, chicken, salad |

All five processes exited 0, with no recorded sanitized error, outer timeout or retry. These observations support only broad visual compatibility on the two already exposed meals and empty accepted lists on two pet controls. They do not establish which words triggered earlier guardrail failures, because several fixed text phrases changed and calls were not randomized/interleaved. Empty lists still do not expose raw visibleFood or policy rejection. Do not report accuracy percentages, broad nonfood reliability, calibrated latency, clinical suitability or iOS behavior from this comparison.

After review, root applied **only** the tested names Guide description and fixed system instructions to `LocalPhotoAI.swift`. The resulting source is byte-identical to [AppTextProposal](../../../../outputs/offline-ai-20261024-benign-prompt/LocalPhotoAI-AppTextProposal.swift), SHA-256 `46b9723a3118bacbf6f97a344afdce919371ae2239010fba7bec608cec9bbbe3`; [the text-only diff](../../../../outputs/offline-ai-20261024-benign-prompt/app-text-only.diff) identifies the change. The proposal/harness report predates this application and accurately states that its own task did not edit app source.

Default Apple guardrails, local model route, schema, policy, capability/locale checks, image bounds, caller gate and amount separation remain unchanged. No safety protection was disabled or weakened, no cloud route was added and no dose/nutrition fields were introduced. The Mac comparison remains outside the iOS app despite the fixed text now matching app source.

### Refined build-3 artifact

The new current ZIP is 12,202,497 bytes, SHA-256 `6457bc795e7faef1fff14614a40267f165ee4dd0b0c7a23a98a3c8ef3cfdc675`. Two generations matched; integrity, English-only packaging and equality of the 17 Swift sources passed. Generic source Simulator builds for arm64/x86_64 and the clean-extracted exact-ZIP arm64 build passed: [source log](../../../../outputs/offline-ai-20261024-delivery/source-build.log), [exact-ZIP log](../../../../outputs/offline-ai-20261024-delivery/exact-build.log). Non-blocking duplicate asset and absent AppIntents-metadata warnings remain, with no build errors. The build number stays 3; the hash distinguishes this text refinement.

The refined `6457bc79…` ZIP now installs/launches on Duo and visibly renders initial Home only. Persisted onboarding means this is not fresh onboarding or model/interaction evidence. The [runtime scope](../../../../outputs/offline-ai-20261024-delivery/exact-runtime-scope.json) retains the boot migration warning, initial SpringBoard capture, later active Home and inactive-display limits; no crash is established. The previous `26baa803…` Home and external fixture captures stay historical. Source-derived iOS processing evidence is recorded next; complete exact-app journeys, accessibility and physical offline gates remain open. Screenshot hashes/scopes belong in [readiness](../../CHALLENGE-READINESS.md).

## October 24 source-derived iOS integration — completed

The [completed iOS report](ios-simulator-20261024.json), also retained as a [local run record](../../../../outputs/offline-ai-ios-integration-20261024/ios-processing-probe.json), records execution on the Duo iOS 27.1 Simulator in the separate bundle `com.mealmirror.qa.offlineintegration20261024c49`. The runner was extracted from the current `6457bc79…` ZIP. [Source fidelity](../../../../outputs/offline-ai-ios-integration-20261024/harness-source-fidelity.json) confirms byte-identical `LocalPhotoAI.swift`, `MealAnalysisEngine.swift`, `Models.swift`, `PhotoNamePolicy.swift` and synthetic image; 55 original files are unchanged. There is no UIKit-to-Mac substitution, changed model prompt, custom guardrail setting or cloud route.

The [external-only diff](../../../../outputs/offline-ai-ios-integration-20261024/harness-only.diff) changes the QA entry point, bundle/display name and appended visual fixture, and adds the isolated storage helper. Original `ContentView.swift` bytes remain an exact prefix. The processing run selects a static SwiftUI task rather than driving the real app's photo picker or review screens; visual-fixture mode does not run the processing/storage checks.

| Check | Actual recorded result | Scope |
| --- | --- | --- |
| Local-model availability | `available`; vision/guided generation and English supported; Arabic unsupported | Runtime Foundation Models checks inside the iOS probe, not a physical iPhone/device-coverage result. |
| Real UIKit/ImageIO preparation | Synthetic preview 1,254 × 1,254; model thumbnail 768 × 768; upright orientation retained | Unchanged app preparation functions ran. Rotated/mirrored camera inputs remain untested. |
| `MealAnalysisEngine` with one synthetic photo and no description, label or manual amount | Model returned tentative rice, chicken, salad and sauce names; zero amount-bearing components, zero included components, no carbohydrate total, `readyForReview=false` | The actual iOS model path completed and names stayed outside amounts. The synthetic illustration supplies no identity, serving or nutrition ground truth. Vision/OCR were `notRun`; this is not fallback or label-flow evidence. |
| Arabic locale request | `unavailable(.language)` with the language guard observed | One unsupported-locale API path, not multilingual recognition or localized UI recovery. |
| Pre-cancelled task | `unavailable(.cancelled)` with the public entry guard observed | Cancellation before task execution; no in-flight generation cancellation or compute-release claim. |
| Isolated actual `LocalReviewStore` save/read/delete | Passed; synthetic person-entered 37 g and photo-origin provenance retained; excluded/OCR/model markers absent; expected JSON schema and backup exclusion verified; generated review deleted | Actual filesystem operations in the fresh QA container only. Simulator did not expose the file-protection class, and physical protection remains unverified. The helper does not test the entire camera/photo pipeline. |

### External runner lifecycle failure and correction

The first QA runner used a standalone `UIApplicationDelegate` entry without scene adoption. It installed/launched but produced no report; its crash's first frame was `___UIApplicationEvaluateRuntimeIssueForNoSceneLifecycleAdoption_block_invoke`. The [failure rationale](../../../../outputs/offline-ai-ios-integration-20261024/scene-fix-rationale.json), [preserved failed entry](../../../../outputs/offline-ai-ios-integration-20261024/MealMirrorApp-UIApplicationDelegate-failed.swift.snapshot) and [lifecycle-only correction](../../../../outputs/offline-ai-ios-integration-20261024/scene-lifecycle-fix.diff) retain that evidence. Switching the external runner to the proven SwiftUI `App`/`WindowGroup` lifecycle allowed the completed report above. This was a QA harness defect, not a production MealMirror defect; the production app already uses SwiftUI lifecycle. [Build evidence](../../../../outputs/offline-ai-ios-integration-20261024/build-evidence.json) identifies the corrected code artifacts.

This closes the earlier absence of an executed iOS model request for a bundled synthetic input. It does not establish real-meal accuracy, nonfood reliability, latency or a strict elapsed deadline, exact-app clue interactions, physical camera/device behavior, offline network isolation or submission readiness. Host clock anomalies still prevent performance claims. Photos, harness code and binaries remain outside the repository and Challenge ZIP.

## Remaining gates and distribution

Complete exact-ZIP model/fallback/nonempty-clue interactions and full meal journeys, reliable nonfood behavior, supported/unsupported-locale UI recovery, in-flight cancellation and retry, rotated/mirrored real-camera inputs, independent culturally varied meal/nonfood evaluation, representative performance under stable clocks, accessibility, and later physical model-ready airplane-mode use. The isolated iOS API/entry-guard and storage results above do not replace these gates. The [worldwide evaluation plan](../../WORLDWIDE-MEAL-EVALUATION.md) defines the independent collection still needed.

Build 2 remains the last verified internal TestFlight Testing build; build 3 has not been uploaded. Direct development/internal testing only: no App Store review/release, external/public beta or public app release is authorized. Source documentation does not certify submission readiness, individual authorship or an award.
