# MealMirror delivery team

**October 27 build-21 archive and internal testing:** The frozen full-language build-21 device archive passed in 295.310 seconds, followed by strict code-sign verification, 18-language resource parity and actual executable SDK 27.1/minimum iOS 17 checks. An initial controller launch failed before Xcode because the shell selected Python 3.9; the same controller ran with bundled Python 3.12. The internal-only upload failed70 requiring Xcode account access. Separately, already-uploaded build19 was added to the existing internal group and is confirmed **Testing**; build2 remains. No device install is claimed. Candidate21 ZIP/source is unchanged. [Archive, failure and testing evidence](research/vision-diagnostics/archive-20261027-build21.json).

Established October 25, 2026 at the applicant's request for the same three-chat workflow used for GTA. Scope: native iOS/iPadOS Swift playground, offline judging, approved Pixel Kitchen theme and testing-only distribution.

## Responsibilities

| Chat | Owns | First delivery |
| --- | --- | --- |
| Full Stack - MealMirror | Integration checkout, shared contracts, readiness, exact submission ZIP, final build/runtime verification, reviewed public main pushes and existing internal testing | Integrate independently reviewed fixes and maintain an evidence-backed completion plan. |
| Front end - MealMirror | SwiftUI screens, Theme, icons, localization, accessible interactions and visual QA in its own branch | Inspect the current core journey at compact/large text and both appearances; repair demonstrated issues while preserving the approved theme. |
| UI designs - MealMirror | Original icon/illustration grammar, uniquely named asset proposals, provenance and per-screen visual audit in its own branch | Coordinate placements with Front end; original light/dark contact sheet before native integration. |
| Back end - MealMirror | Local AI/image processing, analysis contracts, storage, strict input handling and focused unit/stress checks in its own branch | Stress real encoded-photo preparation and local data failures, retaining boundaries between tentative image clues and checked amounts. |

“Back end” covers the app's on-device engine and data layer. The Challenge experience uses no required server, account, Firebase, cloud LLM or API key. The historical branding chat remains a reference; its broad redesign stays paused.

## Safe parallel work

- Each worker uses a separate Git worktree based on the integration commit and reads this document, project instructions, readiness and the completion plan before edits.
- Frontend owns UI in `ContentView.swift`, `Theme.swift`, `PixelKitchenIcon.swift`, `Localization.swift`, `AppShell.swift` and UI/legal/camera presentation. Backend owns `LocalPhotoAI.swift`, `MealAnalysisEngine.swift`, `PhotoCluePolicy.swift`, `Models.swift` and `MealCore` logic. Propose shared contract changes before editing another role's files.
- Full Stack owns package/version metadata, candidate ZIP, submission/release documentation and final integration. Workers commit on their own branches; the coordinator reviews and integrates them. No worker pushes main, uploads binaries or publishes app releases.
- Read current repository/branch/dirty state before changes. Preserve unrelated work and the original interactive Simulator. Runtime ownership is assigned explicitly in private local coordination records; verify live task/process state before transferring a device. A stale lease file alone is not proof work is running or stopped.
- Frontend receives the dedicated QA Simulator for its first bounded UI batch. Backend starts with isolated logic/fixture checks and requests a runtime handoff before iOS execution. Avoid simultaneous heavy builds, model calls and memory measurements.
- Keep raw images, private paths, QA records and task identifiers outside public Git. Public reports contain curated results and hashes. Private family context stays private.

## Delivery contract

Every batch records starting commit, owned files, fixed cases, expected outcomes, process bounds, actual exits, failures, unrun cases and retained evidence. Diagnose failures before fixes; preserve the original result. Compare unchanged tests where possible and distinguish source/unit, Simulator, physical-device and server evidence.

Use the [stress-test plan](STRESS-TEST-PLAN.md). AI accuracy requires qualified labels and independent evaluation; two AI appearance reviews are not ground truth. Do not tune against exposed examples or consume reserved inputs without a reviewed protocol. A photo must not invent portions, carbohydrate amounts or insulin units. No clinical dose output without individualized validation.

After app changes, Full Stack regenerates and verifies the exact English-only ZIP against the applicable published rules, builds it, exercises affected flows and pushes reviewed source. Direct development installs and the existing internal TestFlight group remain the only app distribution authorized. Manual release setting stays unchanged. Physical phone testing remains applicant-deferred.

Keep the two resource variants explicit. The Challenge ZIP contains English resources; the internal testing build preserves the source language catalogs so the applicant can test the language menu. Match all Swift source hashes between their frozen snapshots, compile each variant, and run `verify-testing-localizations.py` on the full-language built app/archive before internal upload. A full-language TestFlight archive is not the exact English-only ZIP binary. Resource parity does not establish translation quality, rendered layout, accessibility, recognition accuracy or physical offline operation.

The active goal remains submission readiness. Neither setting up chats nor passing a narrow test completes it; current Apple rules, applicant eligibility/code review/AI disclosure/essays and all remaining technical gates still apply.

## Build 20 handoff, October 27

The shared Vision gate now returns its fallback before utility-worker request cancellation. Both English/full-language arm64 Simulator variants and the signed full-language device archive passed their stated build, signing, SDK and resource checks. Internal upload failed70 requiring Xcode App Store Connect account access. Existing build19 is the last uploaded artifact; build2 remains the last verified internal-group Testing state. No build20 Simulator install or fresh UI/phone acceptance is claimed. The six-check held-cancel comparison uses a declared request spy, not real Apple cancellation latency or OCR proof. Preserve the retained universal-build timeout and candidate19 identity history. [Delivery scope](research/vision-diagnostics/delivery-20261027-build20.json).


## Build 21 handoff, October 27

**Current candidate 1.0 (21):** English-only source ZIP **12,208,090 bytes**, SHA-256 `8690e3a64f3f8fdefd4f764490709c6af7defcc368571d8b8135b7ed681181d6`, 60 files and three byte-identical packs. All 18 Swift sources match the English/full-language snapshots. Both arm64 Simulator builds passed; the English result was an incremental recovery after the interrupted first attempt. Separate later checks passed 18-language integrity and the signed full-language device archive with actual SDK 27.1/minimum iOS 17 verification. Internal upload failed70 for Xcode account access; already-uploaded build19 is now confirmed Testing in the existing internal group. The 15 controlled local-model gate checks pass; real inference cancellation latency and OCR recovery remain unproven. Original interruption, verifier path/timeout and interpreter-launch failures remain recorded. Model, prompts, theme and translations are unchanged. Current UI, recognition, physical offline and applicant gates remain open; this is not submission-ready. [Initial delivery](research/vision-diagnostics/delivery-20261027-build21.json) · [Later archive and upload](research/vision-diagnostics/archive-20261027-build21.json).

Do not run another heavy batch while the Mac remains severely overloaded. The frontend Simulator and original media remain preserved. The subsequent root-owned PNG/HEIC check passed all 28 direct Catalyst assertions; see research/photo-preparation/png-heic-catalyst-20261027.json. No iPhone/picker or recognition acceptance follows. Browser sign-in is now verified; build19 now shows Testing in the existing internal group, with one tester and two builds. This does not establish Xcode account access or build21 availability.


## Visual design and competitive research, October 27

The dedicated UI designs role supplies original assets; Front end owns actual SwiftUI layout, Theme and placement. It must coordinate shared files, preserve the selected emblem and Pixel Kitchen, and label historical frames/static review separately from current runtime evidence. Root reviews integration, disclosure, final ZIP size and native verification. No worker pushes main or starts heavy tests without resource handoff. The [expanded RxFood breakdown](replica/RXFOOD-DEEP-DIVE.md) and [fix plan](replica/fixes.md) guide product gaps, without copying branding or claiming unmeasured superiority.

## Selected pixel direction and QA recovery, October 27

The applicant superseded the SF Symbol trial with the [original 20-role dimensional pixel family](design/pixel-kitchen/README.md). Exact masters/exports and portable drawing source are preserved outside the app/Challenge ZIP. Compact inline art remains pending; neither rejected trial nor new art is integrated. The frontend native attempt failed before compilation with cache/service access errors and its former QA target is absent. Root retained that failure, confirmed the protected original exists without operating it, and created one fresh empty isolated QA target. A later boot request succeeded, but the 60-second boot-readiness check timed out and stopped before install/launch. A single shutdown request for the fresh QA also timed out with an exiting owned monitor still present at return; final device state is unconfirmed. Hold further native jobs and inspect that same recorded PID/group before any next action; no service reset or denied-signal bypass. No native visual pass is claimed. [Scoped handoff evidence](research/vision-diagnostics/pixel-ui-handoff-20261027.json).
