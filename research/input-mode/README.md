# Keep the chosen meal-input tab on Back

October 24, 2026. Build 8 exposed a navigation-state defect: after choosing Description, entering an unfamiliar synthetic meal and building an unknown review, Back returned to Photo. The description remained in the draft and still enabled Build.

The root operator recorded this on the exact build-8 app in iOS 26.5 Simulator. The checked-amount form was canceled, so no entered amount was committed. The preserved Back-transition screenshot shows Photo selected, but has clipped transition edges and is not a layout pass. The action timeline comes from the CUA operator record, not an automated replay or the screenshot alone.

## Cause and correction

`AddMealView.task` reapplied the initial Photo preference each time entry appeared. The person's tab choice was child-local state; the description was parent-owned and survived the return.

The build-9 correction makes the selected tab part of the same parent meal draft:

- `ContentView` owns `showsPhotoInput` and passes a binding to entry.
- A new draft applies its initial preference; clearing a draft restores Photo.
- Practice selection explicitly selects Description before navigating to its estimate.
- Entry's appearance task consumes camera/library intent without resetting the tab.

The exact initial-intent task body, disappearance cancellation/invalidation guards, tab controls, Build eligibility/analysis and child Practice/token actions retain their source bytes. Theme, meal amounts, processing and history logic are unchanged by this fix.

## Evidence and acceptance

[source-20261024.json](source-20261024.json) pins the baseline source, exact patch, source invariants and actual baseline operator evidence. Source comparison accounts for the complete code delta. It is not a simulated-state fixture or a runtime restoration pass.

Acceptance was pending when the source receipt was curated. The later [build-9 delivery](delivery-20261024.json) now records four actual iOS 26.5 Simulator navigation checks: Description → unknown estimate → canceled amount form → Back, Photo and Practice returns, and a fresh-draft reset. The selected mode and retained description survived Back; the new draft started in Photo with no attachments and Build disabled. These were root-operated CUA observations, not an independent replay. No photos were attached and no amount or review was saved. One-use camera/library intent, the full photo-to-history journey, physical offline behavior and broader accessibility remain open; this does not establish recognition, clinical or submission readiness.
