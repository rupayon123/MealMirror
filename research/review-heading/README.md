# Final review heading

The final review could keep showing an earlier instruction such as “Add a little more detail” after a person added a checked amount. Adding the component made the analysis ready but did not replace its original `analysis.title`.

Build **1.0 (8)** changes one title expression in `ReviewView.reviewSummary`:

```swift
analysis.source == .demo ? analysis.title : "Your meal review"
```

Non-Practice final reviews use the existing “Your meal review” key. Practice keeps its actual meal title. The expression changes the displayed heading; it does not change `analysis.title`, amounts, inclusion, readiness, photo clues, processing or saved-history names. The separate package version change identifies build 8.

## Native comparison

A frozen native Mac Swift 6 probe used the actual extracted model/core value types, manual component constructor and append statement. It compared three constructed ready states after a checked 37 component was appended, plus three actual bundled Practice values. These were constructed value cases, not form interaction or meal-nutrition validation.

| Case | Baseline title argument | Candidate title argument |
| --- | --- | --- |
| Photo with empty clues and checked amount | Add a little more detail | Your meal review |
| Photo with an uncertain name clue and checked amount | Possible foods to check | Your meal review |
| Unknown manual meal with checked amount | Add a little more detail | Your meal review |
| Practice biryani | Chicken biryani plate | Chicken biryani plate |
| Practice grain bowl | Lentil grain bowl | Lentil grain bowl |
| Practice breakfast | Toast and berry breakfast | Toast and berry breakfast |

Each variant had **six cases and 28 checks**. The baseline had the three predeclared heading failures (exit 1); the candidate passed all 28 (exit 0). Whole-analysis equality, amount/inclusion, source, readiness and photo-name checks passed in both variants. One baseline and one candidate run are recorded, with no automatic retry.

The preserved protocol/result wording “after rendering” means **after evaluating the title expression**. This probe called no rendering API. It provides no SwiftUI/UIKit, form, navigation/lifecycle, localization, storage, photo-processing or model evidence. It does not complete the photo-to-history journey.

## Source checks and remaining scope

The applied View change matches the tested expression exactly. The existing “Your meal review” key is nonempty in all 18 source catalogs. That is key-presence evidence only; translation quality, runtime localization and RTL layout were not reviewed here.

[check-20261024.json](check-20261024.json) pins the frozen protocol, independent review, raw native results and applied-source receipt. Its artifact base resolves **from this JSON’s directory** to external local output files. Those files are not redistributed in this repository and are not reproducible from the public summary alone.

Exact artifact, build, render and distribution evidence is separate in [delivery-20261024.json](delivery-20261024.json). This heading check makes no upload, app-render, device, full-journey, clinical or submission-readiness claim.

## Historical build-8 actual UI follow-up

A separate iOS 26.5 Simulator ran the exact build-8 app through actual Device Hub/CUA controls. The [historical UI record](native-ui-20261024.json) separates a successful bundled Practice confirmation → saved Review → history/detail → relaunch check from a canceled synthetic checked-amount form and an unselected native photo picker. One new Practice record persisted alongside two older records; no deletion was performed.

All six retained screenshots were viewed before labeling. The entry-return frame is mid-Back with Photo selected; the saved frame is after Save, and the detail frame is a real sheet with content continuing below the viewport. The two history PNGs are byte-identical, so the separate relaunch commands/operator observations support persistence. This is light/current-text-setting evidence without category readback; it verifies neither the non-Practice final heading nor build 9, the iOS 27 image model, full photo/manual-commit journey, accessibility or physical offline use.
