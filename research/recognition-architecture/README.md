# Offline recognition: next architecture

Decision started October 24, 2026; updated October 25. **Research decision, not a new recognizer.** Current app 1.0 (13) retains the default local Apple model and `143feea0…` prompt source. Its selected-name handoff repair does not repair recognition; model, prompt and engine remain unchanged. The neutral-wording, content-tagging and typed-presence proposals were rejected; no further tuning against the exposed twelve is proposed.

## Decision

No replacement is ready to adopt. Investigate a small, independently trained visual appearance gate before naming, while continuing to evaluate the usefulness of the names themselves. A gate cannot fix wrong dish names or prove edibility. Broad recognition of unfamiliar family and cultural foods, cooked and mixed meals, snacks and drinks remains the goal.

| Direction | Evidence and decision |
| --- | --- |
| Default Apple model with local tools | Apple supports image references, OCR/barcode tools and custom tool calls. These organize evidence; they do not create independent visual truth. Existing Vision/catalog errors remain. A package barcode or text does not establish a whole meal. No agent loop is adopted. |
| Compact Core ML model | Historical TinyCLIP conversion fit the package but failed independent precision/coverage expectations. Narrow ImageNet/Food-101 vocabularies do not solve arbitrary-meal naming. Current Apple MobileCLIP weight terms exclude product development; the code license does not clear the weights. No replacement weights are approved or bundled. |
| Apple Feature Print plus a learned appearance head | Create ML Components provides native image features and classifier composition. A small food-like/nonfood head with a separately calibrated unknown band could suppress object clues without restricting cultural names. This is a feasibility hypothesis: feature behavior, data rights, calibration, useful names and physical-device behavior must pass before adoption. |

Primary sources: [Apple multimodal prompting](https://developer.apple.com/documentation/foundationmodels/analyzing-images-with-multimodal-prompting), [tool calling](https://developer.apple.com/documentation/foundationmodels/expanding-generation-with-tool-calling), [ImageFeaturePrint](https://developer.apple.com/documentation/createmlcomponents/imagefeatureprint), [component composition](https://developer.apple.com/videos/play/wwdc2022/10019/), and [MobileCLIP model terms](https://github.com/apple-aiml-research/ml-mobileclip/blob/main/LICENSE_MODELS). The proposed gate is our design inference, not an Apple food-recognition guarantee.

## First experiment

A separate explicit-revision-2 diagnostic uses three generated geometric images and one identical-input repeat on iOS 27.1 Simulator. It checks only finite, nonconstant 768-value features, differences between these three inputs and repeat consistency. It uses no food labels, LLM calls, training or production processing. Its numerical tolerances are diagnostic tolerances, not food-confidence thresholds. The corrected runner compiled, but its first extraction stopped with `NSOSStatusErrorDomain -1` before returning a vector. The other three steps were unrun. This does not evaluate noncollapse or repeatability, identify the cause, or establish physical-device incompatibility. The owned QA Simulator was shut down with its evidence retained. See [the probe receipt](feature-v2-20261024.json) for compile corrections and limits. A [separate one-call error diagnostic](error-observability-20261024.json) then captured “Failed to create espresso context.” before any vector. That identifies the failing stage, not the underlying cause or the prior call’s cause. Those component-route failures are distinct from the direct Vision observation below; their underlying causes remain unresolved. No training or adoption follows.

## Direct Vision CPU route: one returned observation

A [separately frozen one-call diagnostic](direct-vision-cpu-20261024.json) kept the same procedural F01 bytes, ImageIO → CIImage sRGB route, upright orientation and centerCrop. Direct Vision revision 2 reported one exposed stage, with CPU and GPU support; it selected a returned CPU device, verified assignment readback and performed one request off the main thread. One 768-value Float32 observation returned. Independent review verified identities, copies and all 768 scalar byte roundtrips; the values were finite and not all equal within this single vector. App, console and controller exits were zero, meaning observation completion, not feature or recognition acceptance.

The boot record still logged `Data Migration Failed`; the warning and retained evidence remain, and the owned QA Simulator was recorded shut down. Changing wrapper/device route is not a causal CPU-only comparison or proven Espresso bypass. Equal feature counts do not prove equivalence with component `MLShapedArray` representations. No training, food accuracy, physical-device, network-isolated offline or performance pass follows.

That single observation was followed by the separately frozen diagnostic below. It did not approve training or a production change.

## A–B–A diagnostic: repeat criterion failed

The [three-case receipt](direct-vision-multi-20261025.json) records one fixed A1/F01, B/F02, A2/F01 sequence using two generated geometric images. All three revision-2 requests passed their returned-CPU selection/readback gates and returned one finite, nonconstant 768-value Float32 observation each. Independent review checked 78 evidence conditions and all 2,304 scalar byte roundtrips.

**The numerical diagnostic failed.** A1 versus B exceeded the frozen difference floors, but A1 versus the identical-input A2 repeat had the same maximum absolute difference (`0.0003711208701133728`) and L2 distance (`0.0017806017870063094`), exceeding the repeat ceilings of `0.00001` and `0.0001`. B and A2 were byte-identical despite their different frozen PNG inputs; A1 matched the prior single F01 observation. Passing the across-input floors therefore does not establish useful input sensitivity or semantic separation. The underlying cause remains unknown; static input mapping and file hashes do not prove the rendered pixels Vision consumed.

The app report stopped at `identicalRepeatCriterion` with exit 6. Console/controller exits zero mean the diagnostic failure was observed and retained, not a numeric pass. There was one launch, no automatic retry or timeout, and no tolerance change. The `Data Migration Failed` boot warning remains recorded; copied evidence and owned-QA shutdown do not establish environment health or OS compute release.

A separately frozen CI-only input/render witness was subsequently attempted, as recorded below. No head is trained or adopted; useful names, calibrated abstention, representation equivalence, physical offline behavior and actual app integration remain open. The production source and ZIP are unchanged.

## Original CI-only witness: startup attempt failed

The [CI-only witness receipt](ci-input-witness-20261025.json) keeps the same F01/F02 bytes and planned ImageIO → CIImage sRGB → default-CIContext RGBA8 route. It contains no Vision, CoreML, FoundationModels or training call. The first Xcode build timed out; direct typechecking then passed with an empty diagnostic log, and an incremental second build succeeded with all eight frozen files unchanged. This does not explain the first build timeout.

The installed seven-file inventory matched, but the sole console launch attempt returned `NSPOSIXErrorDomain` code 3 without an app process handle; the controller exited 1. No marker, app report or RGBA buffer was retained. **Actual app entry/exit and decode/render counts are unobserved, not zero.** The controller’s `launched=true` means it started the host launch command, not that the app entered its worker. There is no pixel comparison or explanation of the earlier feature-vector failure.

The `Data Migration Failed` boot warning and terminate warning remain recorded; neither is established as the startup failure cause. Owned-QA shutdown was recorded, data was retained, and no retry occurred. Any follow-up must be separately scoped before execution. No source fix, threshold relaxation, trained head, recognition improvement or production change follows.

## Work after feature feasibility

1. Establish lawful training, calibration and untouched evaluation partitions before collection or training. Group by source, scene and photographer so crops and related images cannot cross splits. Include varied meals, snacks/drinks, packaging, empty containers, imitations, plants, pets and ambiguous/poor-quality photos. Retain label disagreements; qualified independent human review is needed for acceptance claims.
2. Freeze useful-name coverage, false-food suggestions and false-abstention criteria before evaluation. The exposed twelve remain development/regression data. The separate unrun eight must not silently become calibration data. No object-word blacklist or restricted cultural dictionary.
3. Train/calibrate one fixed head externally only after features and rights are suitable. Evaluate the gate together with actual model names; reject suppression that hides foods while leaving wrong names unresolved.
4. Before adoption, verify the exact package, actual photo-to-history journey, error recovery, accessibility and physical network-isolated behavior. Name clues must still create no amount, portion, total, readiness or dose automatically.

The historical build-11 ZIP was 12,204,356 bytes and left **12,795,644 bytes** under a conservative 25,000,000-byte planning cap. No replacement model, head, labels or notices have been added to that package. An OS feature extractor avoids importing an encoder, but this alone does not prove offline availability. Apple's [published policy](https://developer.apple.com/swift-student-challenge/policy/) still identifies 2026; recheck 2027 rules before submission.

The source research and SDK metadata are retained outside the repository under `outputs/recognition-architecture-20261024/` and `outputs/recognition-architecture-20261025/`; public receipts pin selected evidence without redistributing datasets or model weights. No trained gate, improved recognition, worldwide accuracy, clinical validation or submission-readiness claim follows.

## Fresh-target controls and CGImage route: repeat still failed

The [follow-up receipt](fresh-target-and-cgimage-20261025.json) keeps the original CI startup failure as a separate historical result with its cause unresolved. The same compiled startup-only app and flag failed on the earlier QA environment, then returned four checkpoints with all six guards passing on a fresh owned iOS 27.1 Simulator. Target state and a new installation differed; this does not establish an earlier cause or fix.

The original compiled CI-only witness then returned two distinct 518400-byte RGBA8 buffers, differing at 372606 byte positions. Independent review recomputed their hashes and fixed summaries. This describes that CI render route, not pixels consumed by Vision.

The unchanged CI-handler CPU batch and the separately built direct-CGImage-handler batch each returned all three observations but failed the same fixed identical-input repeat criterion. Every CGImage case was byte-identical to its counterpart in both retained CI-handler batches; B and A2 remained identical. App reports stopped with exit 6; console/controller exits 0 mean the failure was retained, not a numeric pass. No criterion was relaxed, no head is trained or adopted, and no recognition or production change follows. Warnings and recorded owned-QA shutdown remain part of the evidence.

## Direct Core ML synthetic host check

The [direct-model receipt](direct-coreml-pattern-20261025.json) records one separately approved macOS run of the exact inspected MobileNetV2 INT8-LUT artifact: one model compile/load and three CPU-only-configured A–B–A predictions on two fixed procedural 224×224 RGB patterns. The frozen mechanical criteria passed: A1/B maximum absolute difference was `0.40495932020712644` and L2 was `0.4412468590582912`; A1/A2 had zero difference and identical retained bytes. Root’s independent Python byte/numeric readback and a separate retained-record review agree.

The runtime exposed 1001 positional labels and 1000 unique probability keys because `crane` is duplicated. The returned dictionary is preserved without inventing separate scores or a merge rule. This is synthetic macOS mechanics only: no food/world-cuisine or unknown/nonfood quality, calibrated abstention, iOS/device portability, physical offline, performance, final-package or adoption acceptance. Earlier Vision failures remain unchanged with no cause/fix established. No classifier head is trained and no model is added to the app.

## Direct Core ML synthetic iOS Simulator check

The [iOS receipt](ios-direct-coreml-pattern-20261025.json) records the first build’s SDK compiler errors and a separately frozen v2 correction using synchronous helper wrappers. V2 compiled and completed one isolated iOS 27.1 Simulator run: one model compile/load and three predictions configured for CPU only, in A–B–A order, on the same generated 224×224 patterns and exact MobileNetV2 INT8-LUT bytes. Unchanged mechanical gates passed: A1/B maximum absolute difference `0.4049592002411373`, L2 `0.4412462654049975`; identical-input A1/A2 differences were zero and their bytes matched. Independent byte/math reviews agree.

The 1001-label/1000-key duplicate-crane uncertainty, incompatible-sysroot warning, main SDK 27.1 versus debug dylib SDK 27.0, and boot’s `Data Migration Failed` warning remain recorded. Shutdown of the owned QA target was confirmed. Earlier Vision failures stay retained; this result establishes no cause/fix, Mac/iOS equality, food/unknown quality, physical offline behavior or model adoption. No head is trained or model added to production.

## Exposed-photo direct Core ML regression: not ready to adopt

The [regression receipt](direct-coreml-exposed-photos-20261025.json) records one Mac run of the exact MobileNetV2 INT8-LUT artifact on only the already-exposed P01–P12 photos. One compile/load and twelve serial predictions completed with CPU-only configuration readback. The fixed orientation/channel witness passed before model access; independent review checked all 12,000 Float64 JSON/byte roundtrips, schemas and prepared-image hashes. This is operational completion, not recognition acceptance.

Against the prior full-frame AI appearance notes, outputs often favor plate/vessel/cookware classes or unconfirmed dish/ingredient/species names: meatloaf alternatives on several meals, crab species instead of a broad dumpling clue, and popsicle/eel/chocolate-sauce alternatives on inputs annotated as nonfood. P07 remains materially ambiguous; neither the model nor its source caption resolves edibility. Some broad family overlap exists, but the notes are not human truth, center crop may remove peripheral components, and no accuracy percentage was calculated. Top-five classes are alternatives, not a multi-food list or calibrated food confidence.

Do not adopt this current general ImageNet classifier for broad meal naming or nonfood/unknown abstention. Keep it external as a research baseline; no cutoff, label filter, prompt or model was tuned against these outputs. Earlier Vision failures remain unchanged. No ingredient/nutrition/insulin, clinical, fresh-evaluation, physical-offline, portability or submission acceptance follows.

## Compact MobileCLIP eligibility: no adoption

The [bounded S0 eligibility screen](mobileclip-eligibility-20261025.json) rejects the inspected current MobileCLIP/MobileCLIP2 checkpoints for this app: research-only model terms explicitly exclude product development, and no student/testing app exception was established. The older official V1 Core ML package has insufficient artifact-specific rights evidence; a model-card tag and broken historical license link do not clear it or establish a retroactive change.

Apple publishes a separate V1 image encoder, whose raw package metadata totals 22,871,573 bytes. The current candidate leaves 12,795,569 bytes under the conservative 25 MB planning cap. No quantized, compiled or compressed candidate was produced, so final ZIP fit is unestablished. The V2 combined checkpoint is 299,864,852 bytes and is not an image-only Core ML export. A matching precomputed text-vector bank is technically possible, but does not clear licensing or establish food accuracy. No weights were downloaded, converted, evaluated or added; the default Apple model and reserved inputs remain unchanged.
