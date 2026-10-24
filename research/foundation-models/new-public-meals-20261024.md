# Twelve new public images: qualitative check

Recorded October 24, 2026. [The evidence record](new-public-meals-20261024.json) includes frozen source/input hashes, all returned names, source credits, independent reviews and local artifact references.

## What ran

An external iOS 27.1 Simulator bundle used the unchanged build-6 model, engine and preparation sources from exact ZIP `774e37b2…`. Only its QA lifecycle/package wiring differed. Twelve neutral images ran serially, once each, with one food-image attachment, English, an empty description and no label image. Expected answers, source captions and provenance text were absent from the model prompt. The fixed prompt, schema, default Apple guardrails, policy and production deadlines were unchanged.

Before inference, two independent AI agents reviewed pixels without captions or model outputs. Their reconciled expectations retained eight food-like images, three clear nonfood presentations and one uncertain food imitation. These are purposive AI visual annotations, **not qualified human, nutrition or clinical ground truth**. Known retained-fixture/source dedup found no matches, but does not establish complete historical or model-training independence. All twelve are now exposed development evidence.

## Actual results

All twelve calls returned inspected results: ten nonempty lists and two empty lists. Every returned analysis had zero amount/included components, no carbohydrate total and no review readiness. Label OCR and Vision fallback remained not-run. Independent mechanical verification passed 29 checks. **These are processing/separation results, not twelve correct food identifications.**

| ID | Returned final names | Comparison with frozen visual expectations |
| --- | --- | --- |
| P01 | rice; salad; meat; drink | Broad plated-meal clues fit. Drink contents are inferred from a capped bottle, not directly verified. |
| P02 | ceramic bowl | The object noun fits a vessel, but a nonfood object entered the food-clue channel. Exact material is unconfirmed. |
| P03 | lasagna | Plausible, but more specific than the visible closed baked dish establishes. Hidden layers/filling remain unknown. |
| P04 | flatbread | Broadly compatible with wrapped browned rounds; recipe and composition remain unknown. |
| P05 | pâté; sauce | Pâté is a poor principal fit for the browned fritter/patty-like pieces. Generic sauce fits the visible base. |
| P06 | empty | Observed empty accepted list for the sponge-like object. This is one abstention, not general nonfood reliability. |
| P07 | brown square | Visually descriptive but not a useful food category. The wick-like detail and material/edibility uncertainty remain. |
| P08 | curry; flatbread; fried potatoes | Some side-level resemblance; base/side localization, recipe and preparation method are unconfirmed. |
| P09 | chicken; potatoes; green beans; carrots | Several qualified poultry/side clues fit; green-bean identity is not established by the thick ridged pieces. |
| P10 | dumplings | Broadly compatible; closed fillings and regional recipe are unknown. |
| P11 | fried egg; noodles; shrimp; lime | Mostly visible elements, with mixed-dish decomposition. This is not evidence of hidden-ingredient hallucination. |
| P12 | empty | Observed empty accepted list for yarn. The internal reason for emptiness is inaccessible. |

The public API exposes final filtered names, not raw `visibleFood`, rejected text or the internal reason for emptiness. Errors and timeouts would have stopped the batch; neither occurred in this recorded run. No retry or prompt change followed these outputs.

## What this changes

The next reliability task is to keep nonfood objects and generic shape descriptions out of possible-food suggestions while preserving unfamiliar and culturally varied food names. This run does not validate a blacklist, semantic gate or prompt repair. Any proposal needs separate review and a newly frozen evaluation; these twelve cannot become fresh held-out evidence after tuning.

The ZIP and app source are unchanged by this experiment. No new app upload or distribution action occurred. Full production photo/clue/label/checked-amount/save/history interaction, accessibility, physical camera/airplane-mode use and applicant/2027 requirements remain open. There is no insulin-dose or connected CGM feature.

The QA app wrote an isolated evidence report and attempt marker; it did not call the saved-meal-review store. The 45/600-second in-app timers need cooperative MainActor scheduling, and the host has a separate 660-second observation cutoff with bounded cleanup. This successful run did not exercise failure/termination branches or establish OS compute cancellation, calibrated speed, memory/battery behavior, nutrition accuracy or an advantage over another app.
