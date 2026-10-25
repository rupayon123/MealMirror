# Vision terminal diagnostics

## Current build 11 status

Build **1.0 (11)** adopts the exact reviewed engine diagnostics: winning photo-terminal decisions can emit a fixed reason and numeric code in **DEBUG-only notice logs**. The [delivery receipt](delivery-20261025.json) pins the **12,204,356-byte ZIP**, SHA256 `af99929a1a1a7019a01a92aa2773e4ab9e563415d8273bdc8e1bda903b69955d`. Its 59 members/17 Swift files match the manifest/extraction; only MealAnalysisEngine and the build number differ from exact build 10. The local model/prompt/schema, classifier thresholds/routes, OCR and amount boundaries are unchanged.

The exact arm64 Simulator Debug build exited 0. The signed iOS archive/codesign verification and internal-only upload also exited 0; Apple’s upload tool reported processing. The archive is version 11/minimum 17/SDK 27.1. Simulator main SDK 27.1 and engine dylib SDK 27.0 remain distinct. Fixed-prefix inspection is positive in the Debug dylib and negative in the Release archive executable; this is a binary boundary, not a complete privacy or runtime proof. **No current build 11 install, UI, phone, processing-complete/compliance/internal indicator/group Testing confirmation is recorded here.** Photo UI evidence remains separately scoped to build 10. Testing only; no public binary release.

## Synthetic capture: failures preserved

The [capture receipt](capture-20261025.json) records one external macOS CLI emission and one later capture-only query. The emitter process exited 0, but the first controller exited 6 before querying: its process receipt overwrote the emitter completion receipt. The lost completion fields remain unknown.

The recovery query exited 0; its strict controller exited 6 for an extra-category record. Independent read-only review found **eight exact fixed payloads plus three automatic same-process records** in the 11-row captured JSON: one activity creation and two XPC connection records. The original full-array criterion still failed. No rerun, re-emission or changed parser acceptance is claimed. A separate mocked filesystem regression exited 0, reproducing baseline loss and preserving the receipt under proposed namespaced filenames; it made no real subprocess or OSLog call.

These artifacts establish that the eight synthetic payloads were present in that recent-store capture after emitter exit. They do not establish clean capture acceptance, the lost call-completion receipt, permanent retention, actual app/Simulator/XCTest/xcresult retrieval, a classifier cause or recognition accuracy. Raw logs/automatic process metadata remain outside the repository.

## Historical proposal verification

The unchanged [verification receipt](verification-20261025.json) records the **earlier external, unadopted proposal stage against build 10**. Its false adoption/source-change fields remain historically valid. The separate build 11 delivery receipt records current adoption.

- The external copy of exact build 10 changed only MealAnalysisEngine; the other 58 package members matched. Full-source unsigned arm64 Simulator Debug/Release builds exited 0, with the retained string-boundary limits.
- The Foundation-only fixture compiled in Swift 5 mode and exited 0. Its 20 logical checks comprise 17 gate checks, two source-only mappings and one in-memory sink case. Twenty-one schedules per baseline/candidate produced 42 continuation schedules with one returned value and the frozen result/registration/stub-cancellation/event expectations. The independent retained-result review found no scope blocker.
- G03 uses a synthetic empty payload; G06/G07 are source-only; G18 is OCR-shaped generic-gate behavior; G19 does not execute an image task group. The request spy does not prove OS compute stopped, injected ordering does not measure the production 12-second timers, and the sink does not test OSLog retention. G17 permits either valid winner independently.

Actual Debug-app terminal retrieval remains a separate gate. Recognition, full photo workflow, accessibility, physical offline, clinical/applicant and submission-readiness gates remain open. Earlier preparation freezes are immutable; later results do not rewrite their original uncompiled/unrun status. No binaries, pixels, raw logs or private identifiers are copied into this research folder.
