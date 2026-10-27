# MealMirror

An offline SwiftUI meal-review app for iPhone and iPad. Start with a photo of the meal you choose, check uncertain food clues, and record carbohydrate amounts from a label or another trusted source. The aim is to make life after a Type 1 diabetes diagnosis easier while preserving food freedom.

**Testing only. Not submission-ready or clinically validated.** No Android version, required account, server or cloud-model endpoint.

## Current source candidate: 1.0 (27)

**Current source candidate 1.0 (27):** Whole nutrition-label thumbnails now fit inside the existing stepped frame; food previews retain their fill/crop. The vertical photo-source divider sits between rows, so it no longer crosses the taller wrapped action. Theme, strings, selection, AI, calculation, storage and assets are preserved.

- **Package:** English ZIP **12,270,472 bytes**, 138 files, SHA-256 `dae250d0572bc14e877f27b97bbc6b8327582031456bc5fbca1357847dc1993e`; two byte-identical packs and 18 matching Swift sources across English/full-language snapshots.
- **Verified:** Both incremental arm64 Simulator builds, signed device archive, strict signing and 18-language resource checks passed. Actual full27 app passed the local-photo/label/model/OCR/checked-amount/Save/relaunch/detail/unique-delete journey. Maximum-system-text/dark attachment states passed; original tall-label selection/fit/removal passed in normal/light and maximum-text/dark. Root inspected wide/tall previews and the corrected divider. Nine media files/app files preserved; final history absent and display settings restored.
- **Internal testing:** Build27 is not uploaded. Last confirmed internal Testing build is25, in the existing one-tester/six-build MealMirror Internal group. No public app release or physical install is claimed.
- **Open:** Physical offline/camera, full-size label inspection, whole-app VoiceOver/Reduce Motion/RTL/other sizes/languages, independent food recognition, recent-meal reuse/export and applicant gates. One exposed generated meal and synthetic labels are not accuracy or human3minute evidence. **Not submission-ready.**

[Exact27 source/package and four native cases](research/native-ui-journey/label-fit-20261027-build27.json). [Prior26 maximum-text failures and visual diagnosis](research/native-ui-journey/photo-role-ax-dark-20261027-build26.json). [Build25 internal Testing receipt](research/native-ui-journey/photo-label-save-20261027-build25.json).

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
