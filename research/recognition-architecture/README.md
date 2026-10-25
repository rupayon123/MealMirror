# Offline recognition: next architecture

October 24, 2026. **Research decision, not a new recognizer.** Current app 1.0 (9) retains the default local Apple model and `143feea0…` prompt source. Its draft-mode correction does not repair recognition; build 8’s final-heading change remains. The neutral-wording, content-tagging and typed-presence proposals were rejected; no further tuning against the exposed twelve is proposed.

## Decision

No replacement is ready to adopt. Investigate a small, independently trained visual appearance gate before naming, while continuing to evaluate the usefulness of the names themselves. A gate cannot fix wrong dish names or prove edibility. Broad recognition of unfamiliar family and cultural foods, cooked and mixed meals, snacks and drinks remains the goal.

| Direction | Evidence and decision |
| --- | --- |
| Default Apple model with local tools | Apple supports image references, OCR/barcode tools and custom tool calls. These organize evidence; they do not create independent visual truth. Existing Vision/catalog errors remain. A package barcode or text does not establish a whole meal. No agent loop is adopted. |
| Compact Core ML model | Historical TinyCLIP conversion fit the package but failed independent precision/coverage expectations. Narrow ImageNet/Food-101 vocabularies do not solve arbitrary-meal naming. Current Apple MobileCLIP weight terms exclude product development; the code license does not clear the weights. No replacement weights are approved or bundled. |
| Apple Feature Print plus a learned appearance head | Create ML Components provides native image features and classifier composition. A small food-like/nonfood head with a separately calibrated unknown band could suppress object clues without restricting cultural names. This is a feasibility hypothesis: feature behavior, data rights, calibration, useful names and physical-device behavior must pass before adoption. |

Primary sources: [Apple multimodal prompting](https://developer.apple.com/documentation/foundationmodels/analyzing-images-with-multimodal-prompting), [tool calling](https://developer.apple.com/documentation/foundationmodels/expanding-generation-with-tool-calling), [ImageFeaturePrint](https://developer.apple.com/documentation/createmlcomponents/imagefeatureprint), [component composition](https://developer.apple.com/videos/play/wwdc2022/10019/), and [MobileCLIP model terms](https://github.com/apple-aiml-research/ml-mobileclip/blob/main/LICENSE_MODELS). The proposed gate is our design inference, not an Apple food-recognition guarantee.

## First experiment

A separate explicit-revision-2 diagnostic uses three generated geometric images and one identical-input repeat on iOS 27.1 Simulator. It checks only finite, nonconstant 768-value features, differences between these three inputs and repeat consistency. It uses no food labels, LLM calls, training or production processing. Its numerical tolerances are diagnostic tolerances, not food-confidence thresholds. The corrected runner compiled, but its first extraction stopped with `NSOSStatusErrorDomain -1` before returning a vector. The other three steps were unrun. This does not evaluate noncollapse or repeatability, identify the cause, or establish physical-device incompatibility. The owned QA Simulator was shut down with its evidence retained. See [the probe receipt](feature-v2-20261024.json) for compile corrections and limits. A [separate one-call error diagnostic](error-observability-20261024.json) then captured “Failed to create espresso context.” before any vector. That identifies the failing stage, not the underlying cause or the prior call’s cause. A documented direct Vision per-stage CPU route is a later, unexecuted hypothesis; it is not a proven Espresso bypass. No training or adoption follows.

## Work after feature feasibility

1. Establish lawful training, calibration and untouched evaluation partitions before collection or training. Group by source, scene and photographer so crops and related images cannot cross splits. Include varied meals, snacks/drinks, packaging, empty containers, imitations, plants, pets and ambiguous/poor-quality photos. Retain label disagreements; qualified independent human review is needed for acceptance claims.
2. Freeze useful-name coverage, false-food suggestions and false-abstention criteria before evaluation. The exposed twelve remain development/regression data. The separate unrun eight must not silently become calibration data. No object-word blacklist or restricted cultural dictionary.
3. Train/calibrate one fixed head externally only after features and rights are suitable. Evaluate the gate together with actual model names; reject suppression that hides foods while leaving wrong names unresolved.
4. Before adoption, verify the exact package, actual photo-to-history journey, error recovery, accessibility and physical network-isolated behavior. Name clues must still create no amount, portion, total, readiness or dose automatically.

The current 12,203,935-byte ZIP leaves **12,796,065 bytes** under a conservative 25,000,000-byte planning cap. No new head, labels or notices have been exported or sized. An OS feature extractor avoids importing an encoder, but this alone does not prove offline availability. Apple's [published policy](https://developer.apple.com/swift-student-challenge/policy/) still identifies 2026; recheck 2027 rules before submission.

The source research and SDK metadata are retained outside the repository under `outputs/recognition-architecture-20261024/`; public receipts pin selected evidence without redistributing datasets or model weights. No trained gate, improved recognition, worldwide accuracy, clinical validation or submission-readiness claim follows.
