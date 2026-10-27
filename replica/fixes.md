# MealMirror improvements from the RxFood investigation

October 27, 2026. Read the [full breakdown](RXFOOD-DEEP-DIVE.md) and [43-capability matrix](rxfood-capabilities.csv). These are work decisions, not completed feature or superiority claims.

## Interpreting feedback

The sample has 11 unique App Store observations, three explicitly positive Canadian entries, no verified per-review star values and only one independent platform. All themes are thin. The generated feedback uses abbreviated locators; its weighted scores do not rank market prevalence. Full source context and developer replies take precedence.

- **Reported friction:** account entry, waiting during meals, persistence/reliability and nutrient consistency. No current version was reproduced; developer-reported fixes remain unresolved rather than ignored.
- **Requested capabilities:** direct personal sharing and more customizable nutrient presentation. One regression report also asks for export, so manual review finds two export mentions although the abbreviated classifier finds one.
- **Valued behavior:** convenient photo/label entry, restaurant context, learning and continued engagement. Preserve these jobs without copying vendor art or implying equivalent measurement accuracy.
- **Not established:** universal dissatisfaction, current outage rates, RxFood lacking all offline functionality or accessibility, or MealMirror already being more accurate.

## Ordered fix backlog

| Order | Work | Owner | Size | Acceptance |
| --- | --- | --- | --- | --- |
| 1 | Finish reliable current-package local review/recovery | Full Stack + Backend | M | Exact package, resource/signing proof, failed/unavailable route and cold offline save/relaunch/delete; first failures retained. |
| 2 | Evaluate useful names and calibrated unknowns | Backend + qualified reviewers | L | Lawful diverse split-controlled data, clear error/abstention/correction results; numeric quantities remain separate. |
| 3 | Complete Pixel Kitchen icons and state art | UI designs + Frontend | M | Original source/provenance, contact sheet, coherent placements and actual native accessibility/viewport checks. |
| 4 | Make mixed/hidden meals easy to correct | Frontend + Backend | M | Label, added view and typed detail remain distinguishable; nothing hidden is invented. |
| 5 | Add recent-review reuse | Frontend + Backend | M | New draft/identity, current-value confirmation, older incomplete records handled, original unchanged. |
| 6 | Add selective local review export | joint | M | Explicit preview and share action, source/date/units retained, no automatic send/photos/diagnosis. |
| 7 | Add concise reviewed learning | Frontend + clinician/content reviewer | M | Comprehension task, non-shaming wording, original/licensed content and qualified translation. |
| 8 | Prove the intended-user and judging story | Full Stack + applicant | L | Three-minute human-paced experience, physical offline and accessible user tasks; actual-year rules and applicant work. |

Sizes are planning estimates, not deadlines. No broad feature parity or award is promised. Barcode/restaurant nutrition, wider nutrients, CGM, professional services and dosing remain separately gated gaps in the full matrix.

## Positioning hypotheses

1. For a person who wants to start a local review without enrollment: a clear photo-to-correction flow with no required account. Verify cold offline operation before advertising it.
2. For a child or caregiver learning a new routine: fewer competing actions, useful uncertainty and source-visible amounts. Verify comprehension with intended users.
3. For someone who wants control over their own record: on-device review history and optional explicit sharing. Sharing is not implemented yet.

Use hypothesis 2 as the design direction, with 1 as an engineering requirement and 3 as a concrete follow-up. None is a proven exclusive market niche. A meaningful comparison needs matched task evidence; an attractive theme or tool invocation alone cannot establish a better app.
