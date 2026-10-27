# MealMirror

An offline SwiftUI meal-review app for iPhone and iPad. Start with a photo of the meal you choose, check uncertain food clues, and record carbohydrate amounts from a label or another trusted source. The aim is to make life after a Type 1 diabetes diagnosis easier while preserving food freedom.

**Testing only. Not submission-ready or clinically validated.** No Android version, required account, server or cloud-model endpoint.

## Current source candidate: 1.0 (27)

**Current source candidate 1.0 (28):** Selected nutrition labels can open in a full-screen local viewer from Add Meal or Estimate. Pinch or the Larger/Smaller controls zoom from 1× to 4×; the image pans in both directions. A fixed Close header stays outside the scrolling image and stacks at accessibility text sizes. Food previews, removal, analysis, calculations and storage are unchanged.

- **Package:** English ZIP **12,271,696 bytes**, 138 files, SHA-256 `a7551a36fd26c2be73bd6b3f6658b254f2e2c509bc4d1472c69254fd6534ac53`; two byte-identical packs and 18 matching Swift sources across English/full-language snapshots.
- **Verified:** Both incremental arm64 Simulator builds, signed archive, strict signing and 18-language resource integrity passed. Native tall-label inspection passed in maximum-text/dark settings. The normal/light full photo/label journey passed both viewer entry points, pinch, zoom limits, pan, Close, separate checked amount, Save, relaunch/detail and guarded deletion. Root inspected the relevant native frames. All nine media files, installed app files and original absent history were preserved; display settings were restored. Prior app and harness failures are retained in the evidence.
- **Internal testing:** Build 28 uploaded through TestFlight Internal Only without warnings shown. Apple reports **Processing**; build 27 remains the latest confirmed **Testing** build in the existing MealMirror Internal group. No public app release or physical installation is claimed.
- **Open:** Physical offline/camera, broader accessibility/viewport/language acceptance, independent recognition, safe meal reuse/export and applicant gates. Three new interface keys have draft non-English translations requiring review. The six-screen visual portfolio remains a proposal. **Not submission-ready.**

[Exact build 28 package, native inspection cases and retained failures](research/native-ui-journey/label-inspection-20261027-build28.json). [Prior build 27 evidence](research/native-ui-journey/label-fit-20261027-build27.json).

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
