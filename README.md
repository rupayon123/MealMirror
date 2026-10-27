# MealMirror

An offline SwiftUI meal-review app for iPhone and iPad. Start with a photo of the meal you choose, check uncertain food clues, and record carbohydrate amounts from a label or another trusted source. The aim is to make life after a Type 1 diabetes diagnosis easier while preserving food freedom.

**Testing only. Not submission-ready or clinically validated.** No Android version, required account, server or cloud-model endpoint.

## Current source candidate: 1.0 (26)

**Current source candidate 1.0 (26):** Selected meal photos and the nutrition-label thumbnail now appear in separate sections. The repeated in-card label amount button is removed; the primary checked-amount action remains. Approved artwork, theme, AI, calculation and storage are unchanged.

- **Package:** English ZIP **12,270,251 bytes**, 138 files, SHA-256 `53e4dfac49af9b90fd75a5435fe55c49febb64bafb04afd4f21e80e828287ef9`; two byte-identical packs and 18 matching Swift sources across English/full-language snapshots.
- **Verified:** Both incremental arm64 Simulator builds, signed device archive, strict signing and 18-language resource checks passed. Actual full26 app in English passed photo+label/local model/OCR/separately typed37g/confirmation/Save/relaunch/detail/unique deletion/empty relaunch. A separate normal-size attachment test passed empty, label-only, food-only, both roles, per-role removal and three-photo limit. Eight media files and app files were preserved; final history file absent.
- **Internal testing:** Build26 is not uploaded. Last confirmed internal Testing build is25, in the existing one-tester/six-build MealMirror Internal group. Apple reports25 Validated; its earlier expired-account/skipped-validation upload warnings remain recorded. No public release or physical install is claimed.
- **Open:** Dark/large-text/RTL/accessibility and other form factors, physical offline/camera, independent diverse-food recognition, recent-meal reuse/export and applicant gates. Intake label thumbnail cropping and current26 settled-transcription review remain follow-ups. Tests use an exposed generated meal and synthetic label; stock photos in the attachment test are layout fixtures only. **Not submission-ready.**

[Exact package, native cases, retained verifier errors and limits](research/native-ui-journey/photo-role-20261027-build26.json). [Previous25 native checks and internal Testing](research/native-ui-journey/photo-label-save-20261027-build25.json).

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
