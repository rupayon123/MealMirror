# Content-tagging model selection — rejected, unapplied

October 24, 2026. This was an external source-derived experiment against the twelve original exposed neutral images, based on commit `665f84e` and exact build-6 ZIP `774e37b2…`. **No production change resulted from this experiment.** Later independent app changes belong to their own evidence records.

## Proposal and API evidence

The [unapplied diff](content-tagging-20261024.diff) regenerates exactly one processing-line substitution at line 79: default SystemLanguageModel → its contentTagging use case with default guardrails. Original prompts, schema, generation options, preparation, deadline, fallback and amount separation remained unchanged. External QA entry/package changes isolated the experiment; they were not product changes.

Apple documents content tagging as an adapted **on-device text** feature. The reviewed article does not explicitly document image inputs; this omission does not establish that images are unsupported. Apple separately documents multimodal classification and capability inspection. [Content tagging](https://developer.apple.com/documentation/foundationmodels/categorizing-and-organizing-data-with-content-tags), [multimodal prompting](https://developer.apple.com/documentation/foundationmodels/analyzing-images-with-multimodal-prompting), [capabilities](https://developer.apple.com/documentation/foundationmodels/languagemodelcapabilities).

A native Mac **metadata-only** probe reported default, explicit general and contentTagging available with English, vision and guided generation; none advertised reasoning. It created no session or image/generation request. Actual selected-model iOS preflight also advertised availability, vision, guided generation and English. These advertisements did not establish successful image inference.

## Stopped outcome

The frozen run allowed at most twelve serial engine entries and no retry. It stopped at **P01** with one engine-entry intent checkpoint and **zero inspected cases**. P01 returned `unavailable: failed`; Vision fallback was also unavailable. The acceptedNames field was absent, not an inspected empty list. Amount/included components remained zero, the total absent and review readiness false on this one return.

**P02–P12 and the separate new eight remain unrun.** Required nonfood/uncertain empty results and food-usefulness gates were not assessed. The all-twelve-inspected gate was unmet, so the parent rejected adoption. No accuracy, correct-abstention, comparative food-quality or causal model-selection conclusion follows. A checkpoint also does not prove Apple’s internal generation began.

The final independent review passed **26 identity/evidence/stop-consistency checks**, with no unresolved evidence blocker. Those are not recognition tests or a successful batch. The isolated arm64 build succeeded; the main executable records SDK 27.1 and debug dylib 27.0. Existing sysroot, duplicate asset and skipped App Intents warnings remain retained.

## Failure, environment and cleanup limits

The app report declares exit 6, the console command exited 0, and the outer controller was observed exiting 1 after its incomplete-run assertion. That outer exit is a **parent-transcribed tool observation**, not an independently emitted controller receipt. Console exit 0 does not establish model success.

Earlier boot output included “Data Migration Failed” despite exit 0. Fresh available/booted state and an environment probe did not clear model/runtime health. The public failed mapping does not identify a guardrail, unsupported image, preparation, model-delivery or Simulator cause; migration/environment confounds remain.

The controller found nothing left to terminate and shut down its separate QA target. A later cleanup request reported it already shut down. Reports/data were retained; the original interactive build-4 picker was untouched. This does not prove OS inference compute release. The QA helper wrote its report/marker but invoked no saved-meal-review API; `storageTouched=false` is not a no-I/O claim.

## Record and next step

The [machine-readable record](content-tagging-20261024.json) pins the finalized proposal, candidate, freeze, build, reviews, raw result, interpretation, root decision, metadata probe and cleanup receipts. Relative local-output references identify **unreproduced local artifacts**; no research pixels, source/license metadata or private paths/identifiers are included here.

Keep this selection proposal unapplied. Any failure diagnosis needs a separately frozen bounded protocol; do not rerun or fill this attempt. No full app journey, physical offline, performance, clinical, worldwide or submission gate closed. See [current readiness](../../CHALLENGE-READINESS.md) for later artifact status.
