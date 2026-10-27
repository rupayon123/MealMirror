# MealMirror

An offline SwiftUI meal-review app for iPhone and iPad. Start with a photo of the meal you choose, check uncertain food clues, and record carbohydrate amounts from a label or another trusted source. The aim is to make life after a Type 1 diabetes diagnosis easier while preserving food freedom.

**Testing only. Not submission-ready or clinically validated.** No Android version, required account, server or cloud-model endpoint.

## Current source candidate: 1.0 (21)

| Artifact or check | Result |
| --- | --- |
| [English Challenge source ZIP](candidate/MealMirror-SSC2027.zip) | 12,208,090 bytes; 60 files; two byte-identical repacks |
| ZIP SHA-256 | `8690e3a64f3f8fdefd4f764490709c6af7defcc368571d8b8135b7ed681181d6` |
| Simulator builds | English and full-language variants passed for arm64, including executable and debug library |
| Internal archive | Build 21 unrun after language-verifier timeout; build 20 remains the last verified signed archive |
| Internal TestFlight upload | Build 21 not attempted; build 20 failed because Xcode requires App Store Connect account access |
| Latest previously uploaded build | 19; build 2 remains the last independently verified existing-group Testing state |

Build 21 delivers the local-model gate's chosen result before asynchronously requesting worker/timer cancellation, including late registration. The same 15 controlled checks pass after four baseline ordering failures. The first cold build was interrupted; a distinct incremental recovery passed. A verifier path mistake was corrected, then full-language verification timed out. These failures remain retained; no build-21 archive, upload, fresh UI or physical acceptance is claimed. [Delivery evidence](research/vision-diagnostics/delivery-20261027-build21.json) · [Controlled comparison](research/vision-diagnostics/photo-ai-cancellation-20261027.json).

The internal testing resource variant retains 18 languages; build 21's complete language verifier remains open. The separate Challenge ZIP is English-only; all 18 Swift source files match between variants. These are different resource variants, not identical binaries. Catalog parity does not establish translation or layout quality.

## What the app does

- Accepts up to three meal views and one separate nutrition-label photo.
- Uses Apple's on-device Foundation Models image path on supported iOS 27+ hardware when Apple Intelligence, model readiness, capabilities and language permit it. Vision/manual review remains available when the model is unavailable.
- Presents tentative, editable food names separately from carbohydrate items. Tapping a name prefills a form; it does not supply a portion or amount. An empty successful model response remains unknown.
- Shows locally recognized label text beside the label image. A person checks the serving size and enters a trusted amount; OCR never fills that amount automatically.
- Includes bundled Practice meals with illustrative ranges, direct amount editing, explicit review confirmation, and local save/history/detail/deletion.
- Keeps saved review files local and excluded from backup. Physical iOS file-protection behavior still needs device validation.

The local reference catalog is finite and its example ranges are not measurements of the selected meal. Recognition still returns unsupported or uncertain names on some development photos. No arbitrary-meal accuracy, worldwide coverage or superiority over RxFood has been established. **Insulin-dose calculation, Dexcom/Libre integration and pump control are not implemented.**

## Open and run

Open [`MealMirror.swiftpm`](MealMirror.swiftpm) in Xcode 27.1 or later and choose an iPhone or iPad simulator. The deployment floor is iOS 17; the image-model path is availability-gated to iOS 27. Instructions, fonts, images and Practice content are bundled. The model must already be prepared by the OS for offline use; the app does not download model weights.

Create a Challenge source ZIP with `bash scripts/prepare-ssc-submission.sh /absolute/path/new-candidate.zip`. For a signed internal archive, use `bash scripts/archive-testflight.sh /absolute/path/new-archive.xcarchive APPLE_TEAM_ID`. The archive script uses the repository source and verifies signing, SDK/deployment metadata and the full language resources. Upload is separate.

Keep distribution to development installs and the existing internal TestFlight group. Preserve manual release. No App Store review/release, external/public beta, public beta links or public binary releases are authorized. Public source backup is separate from app distribution.

## Evidence and remaining work

The latest completed full native photo-to-save/delete journey is [build 13](research/native-ui-journey/full-photo-save-20261025-build13.json): one exposed meal, separate synthetic label and manually checked amount on iOS Simulator. It is not fresh build-21, worldwide recognition, accessibility or physical airplane-mode acceptance. Command-line OCR failures remain recorded separately; they do not invalidate that version-specific iOS observation. Physical iPhone testing is deferred to the applicant.

Remaining gates include dependable food naming/abstention on qualified independent data, fresh native journeys and recovery cases, large-image resource checks, accessibility/RTL/iPad/motion and translation review, physical offline validation, internal account/server verification, current Challenge rules, and applicant-owned code review/disclosures/answers. The broad companion redesign remains paused; the approved Pixel Kitchen theme is preserved.

| Record | Purpose |
| --- | --- |
| [Readiness checklist](CHALLENGE-READINESS.md) | Apple requirements, exact artifacts and remaining gates |
| [Completion plan](SUBMISSION-COMPLETION-PLAN.md) | Ordered delivery work and clinical/applicant dependencies |
| [Apple technology briefing](APPLE-TECHNOLOGY-BRIEFING.md) | APIs used, on-device model requirements and Google collaboration |
| [Team workflow](TEAM-WORKFLOW.md) · [Stress-test plan](STRESS-TEST-PLAN.md) | Frontend/backend ownership and evidence requirements |
| [Worldwide evaluation plan](WORLDWIDE-MEAL-EVALUATION.md) · [Recognition research](research/recognition-architecture/README.md) | Qualified data, naming/unknown failures and rejected prototypes |
| [Foundation Models evidence](research/foundation-models/README.md) | Development results, limitations and retained failures |
| [RxFood deep dive](replica/RXFOOD-DEEP-DIVE.md) · [43-capability matrix](replica/rxfood-capabilities.csv) · [Fix plan](replica/fixes.md) | Public evidence, actual gaps and proposed acceptance; no head-to-head accuracy claim |
| [CGM plan](CGM-INTEGRATION-PLAN.md) | Vendor access limits and the separate connected product path |
| [AI and asset disclosure](MealMirror.swiftpm/AI-AND-ASSET-DISCLOSURE.md) | Working assistance/provenance record for applicant reconciliation |

Historical build results remain in the readiness records and linked research receipts. The applicant must reconcile the final package against the published rules for the actual submission year and personally review the code and write the Challenge answers.
