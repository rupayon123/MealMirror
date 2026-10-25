# MealMirror delivery team

Established October 25, 2026 at the applicant's request for the same three-chat workflow used for GTA. Scope: native iOS/iPadOS Swift playground, offline judging, approved Pixel Kitchen theme and testing-only distribution.

## Responsibilities

| Chat | Owns | First delivery |
| --- | --- | --- |
| Full Stack - MealMirror | Integration checkout, shared contracts, readiness, exact submission ZIP, final build/runtime verification, reviewed public main pushes and existing internal testing | Integrate independently reviewed fixes and maintain an evidence-backed completion plan. |
| Front end - MealMirror | SwiftUI screens, Theme, icons, localization, accessible interactions and visual QA in its own branch | Inspect the current core journey at compact/large text and both appearances; repair demonstrated issues while preserving the approved theme. |
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

The active goal remains submission readiness. Neither setting up chats nor passing a narrow test completes it; current Apple rules, applicant eligibility/code review/AI disclosure/essays and all remaining technical gates still apply.
