# MealMirror

An offline SwiftUI meal-review app for iPhone and iPad. Start with a photo of the meal you choose, check uncertain food clues, and record carbohydrate amounts from a label or another trusted source. The aim is to make life after a Type 1 diabetes diagnosis easier while preserving food freedom.

**Testing only. Not submission-ready or clinically validated.** No Android version, required account, server or cloud-model endpoint.

## Current source candidate: 1.0 (24)

| Artifact or check | Result |
| --- | --- |
| [English Challenge source ZIP](candidate/MealMirror-SSC2027.zip) | 12,269,942 bytes; 138 files; two byte-identical repacks |
| ZIP SHA-256 | `760ac1ecb07b718a34e72e782e8499fcdd4195be714299e8d578875b1e179dbb` |
| Pixel UI | 20 full roles + six compact roles; 52 light/dark PNGs; stepped surfaces and grouped Home/Settings rows |
| Simulator source builds | English and full-language variants passed for arm64; incremental builds, not clean/universal |
| Full-language integrity | All 18 catalogs/native strings match source; 488 English keys; translation/layout quality still open |
| Outline geometry | 363 macOS SwiftUI checks pass, including the new corner tiers; not native app visual proof |
| Internal archive/upload | Build 24 signed archive/internal-only upload passed; confirmed Testing |
| Existing internal TestFlight group | Build 24 Testing; builds 23, 22, 19, 2 preserved; one tester |

The current UI uses consistent stepped corners, adaptive photo-source trays, quieter grouped surfaces, clearer entry fields and a regular-tooth Settings gear. [Source/package checks](research/visual/delivery-20261027-build24.json) and [native interaction/archive/internal-testing evidence](research/visual/native-navigation-20261027-build24.json) retain exact scope and earlier failures. One native case passed safety/help scrolling, Settings, photo-source controls, description entry and unsaved amount cancel/reopen. It did not select photos, run AI, save a review or test the physical phone. Further visual refinement and broad accessibility/offline verification remain open.

The internal resource variant retains 18 languages, while the judging ZIP is English-only. All 18 Swift source bytes match; resources and binaries differ. Catalog integrity does not establish translation or native layout quality.

Current exact-source runtime checks exercised real Foundation Models and separate-label OCR in an isolated iOS test host; all eight narrow coordinator checks passed. The Mac command-line OCR case failed and remains recorded. [Results and limits](research/foundation-models/coordinator-host-20261027.json). Full MealMirror UI and physical offline gates remain open.

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

Latest [signed archive and internal upload evidence](research/visual/archive-20261027-build22.json) records build 22; earlier controller/interpreter, verifier and CLI upload failures remain in their historical receipts. The full-language internal archive is distinct from the English Challenge ZIP.
