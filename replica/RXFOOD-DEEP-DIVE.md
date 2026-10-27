# RxFood and MealMirror: product breakdown and delivery decisions

Reviewed October 27, 2026 against MealMirror main `05340bf`, source candidate 21. This is a public-source product investigation, not an authenticated RxFood walkthrough, clinical assessment or comparative accuracy test. The detailed [capability matrix](rxfood-capabilities.csv), [recon](recon.md), [review sample](reviews.csv) and [fix plan](fixes.md) make the gaps inspectable. No RxFood code, model, private endpoint, account or traffic was examined.

## What the earlier analysis missed

The earlier report identified the broad photo/CGM/clinician offering, but did not adequately separate current product claims, user complaints, historical research and unknown behavior. It did not establish superiority. This revision adds public promotional screen inspection, version context, eleven deduplicated review observations, a historical offline-mode counterexample, primary pilot-study context, and explicit delivery/acceptance decisions.

**Correction:** the [FAQ](https://rxfood.com/faq) describes connection-dependent tablet logging, but a publicly hosted [historical packaging table](https://static1.squarespace.com/static/6037ba61b229976563b35c2e/t/640646b74dfb5208db987f37/1678132920116/RxFood_Pricing_and_Packaging.pdf) lists offline mode in its RxExec column. Its present availability and behavior are unknown. The rendered one-page table was inspected; it is not a current price quote. We cannot say RxFood has no offline mode or that offline operation alone makes MealMirror unique.

## Source register

| ID | Public source | What it can establish |
| --- | --- | --- |
| P01 | [US App Store listing](https://apps.apple.com/us/app/rxfood/id1482235880) | Advertised logging, support, learning, recipes; developer-declared platform/languages and release notes. |
| P02 | [RxFood with Dexcom](https://rxfood.com/dexcom) | Advertised food/portion/net-carb estimates and connected timeline; education-only disclaimer. |
| P03 | [Dexcom clinician offering](https://rxfood.com/dexcom/clinicians) | Care-team assessments, glucose context and dietary reports. |
| P04 | [Patient page](https://rxfood.com/patient) | Access route and limitations for hidden contents; vendor testimonials are not representative validation. |
| P05 | [FAQ](https://rxfood.com/faq) | Scheduling/logging-period rules and connection-dependent tablet workflow. |
| P06 | [Deletion help](https://rxfood.com/support-for-logging-and-deleting-meal) | Whole-meal and individual-food removal instructions. |
| P07 | [Canada reviews page](https://apps.apple.com/ca/app/rxfood/id1482235880?platform=iphone&see-all=reviews) | Nine sampled review observations and visible developer responses. |
| P08 | [Historical packaging PDF](https://static1.squarespace.com/static/6037ba61b229976563b35c2e/t/640646b74dfb5208db987f37/1678132920116/RxFood_Pricing_and_Packaging.pdf) | Older tier matrix, including offline; not present pricing or a runtime demonstration. |
| P09 | [Privacy policy](https://rxfood.com/privacy-policy) | Published data categories, processing/sharing disclosures and estimate limitations. Not an independent privacy audit. |
| P10 | [User terms](https://rxfood.com/terms-and-conditions-user) | Account/guardian terms, healthcare arrangements and content restrictions. No legal conclusion inferred. |
| P11 | [2020 iSpy pilot paper](https://mhealth.jmir.org/2020/10/e22074) | Historical study methods and limitations, not current RxFood-version performance. |
| P12 | [Clinical evidence index](https://rxfood.com/clinical-evidence) | Links to research; marketing summaries are not substituted for study methods. |
| P13 | [Promotional meal screen](https://images.squarespace-cdn.com/content/v1/6037ba61b229976563b35c2e/63e0db80-a5bd-4a94-9a72-80c9597fb7b4/app-dexcom-timeline-en.png) | Visible hierarchy in a promotional example. |
| P14 | [Promotional overview](https://images.squarespace-cdn.com/content/v1/6037ba61b229976563b35c2e/75c10174-3bfb-4dd3-9201-dea5cf0f4420/app-dexcom-overview-en.png) | Visible chart/card structure in a promotional example. |

Sources were read individually. Public screenshots/PDF remain private references and are not shipped or committed. P01 displayed version 2.8.16 and September 25 release notes; generic fixes do not prove any specific complaint resolved. Country listings and dynamic dates vary. No numeric review stars were reliably recoverable for the selected entries, so their ratings remain blank.

## 1. The product RxFood is actually offering

RxFood combines several jobs, not just a food classifier:

- **Capture:** photo and alternative logging, with recurring/recent entries reducing repetition. [P01]
- **Interpretation:** approximate foods, portions and estimated net carbs. This is more automatic than MealMirror's present checked-manual-amount path. [P02]
- **Context:** a connected food/glucose view with logged insulin and activity. A logged dose is not a recommended dose. [P02, P03]
- **Support:** professional/AI assistance, learning and recipe content. These constitute an ongoing service beyond the Challenge artifact. [P01]
- **Care workflow:** enrollment, observation periods, assessments and clinician use. [P03–P05]

RxFood advertises a broader connected service with care-team tools. MealMirror has no working live CGM link, clinician service, qualified worldwide recognition evaluation or measured clinical-outcome evidence. RxFood's historical studies are considered separately below; this investigation does not establish its current worldwide performance. MealMirror's implemented direction is local review: eligible on-device image names, editable uncertainty, separately checked values and local history. Physical offline behavior and broad usefulness remain unverified.

## 2. Screen and flow analysis

The two inspected promotional images show a meal photo as the dominant content, an editable meal/time header, a food/amount summary and glucose context. A persistent icon-plus-text navigation bar offers broad product areas and a central creation action. The overview places a glucose trace above the meal card; event symbols relate entries to that trace. Both use a September 2023 example date; current native layout/version is unverified. [P13, P14]

What to learn: use a clear image-to-action-to-summary hierarchy, readable labels beside functional icons and distinct event semantics. What to design independently: MealMirror's Pixel Kitchen silhouettes, warm palette, sprites, spacing and state illustrations. A decorative glucose chart, insulin syringe icon or fake carb amount must not suggest a working medical integration.

| Flow | Publicly supported path | Still unknown | MealMirror decision |
| --- | --- | --- | --- |
| Entry | Provider/invitation or Dexcom access → logging [P02, P04] | All present enrollment variants and exact steps | No required sign-in for the offline core. |
| New meal | Photo/alternative entry → food/amount result [P01, P02] | Native tap count, processing time, correction affordances | One photo must be enough to begin; show a useful manual route immediately if analysis fails. |
| Correction | Meal → food removal or whole-meal deletion [P06] | All edit/undo semantics | Clearly distinguish removing an item, excluding it from this review and deleting a saved review. |
| Familiar meal | Recent logging advertised [P01] | Reuse rules and whether portions refresh | Add editable reuse later, with fresh confirmation of current values and portions. |
| Glucose reflection | Meal/events → connected timeline [P02] | Refresh delay, gaps, offline cache semantics | Future vendor-supported connection; no simulated live data in the Challenge. |
| Sharing | Clinical service plus reviewer requests for direct export [P03, P07] | Current self-service export formats | Consider an explicit, local, user-initiated review summary; never automatically send it. |
| Failure | Connection issue described in FAQ [P05] | Current cold offline launch, timeout, permission-denial and retry states | Test each MealMirror state; do not infer competitor failure from missing documentation. |

Tap counts and task-time comparisons are **unmeasured**. Marketing pictures are not a successful runtime walkthrough.

## 3. Where RxFood is ahead, and what MealMirror lacks

| Area | Current gap in MealMirror | What would close it |
| --- | --- | --- |
| Recognition and nutrition | Tentative names can be wrong; no photo-derived portion or grams | Qualified data, independent evaluations and calibrated abstention. A general Apple model is not nutrition validation. |
| Repeat use | No recent-meal reuse or favourites workflow | A fresh editable draft from a saved review; never silently reuse an old total as today's amount. |
| Packaged/restaurant entry | Label OCR exists, but no barcode product lookup or restaurant database | Preserve checked label entry now; later use licensed, dated nutrition records with editable portion/source. Offline barcode detection alone supplies no nutrition database. |
| Saved record correction | Components can be adjusted before saving; history is not a full saved-meal editor | An explicit edit/version design that preserves old provenance and requires reconfirmation. |
| Longitudinal context | Local reviews only; no glucose/event overlay | Official CGM access, consent, timestamps/units, freshness and gap semantics. Live sync needs a connection. |
| Nutrition breadth | Finite illustrative catalog and user-entered carbs | Validated nutrition source and portions before presenting other nutrients as measured. |
| Learning/support | Three Practice examples; no broad education/recipe or clinical service | Original clinician-reviewed micro-lessons first; larger services need separate content and operations. |
| User control | No self-service review export | A readable local preview and selective sharing with source/uncertainty labels; photos excluded by default. |
| Inclusive use | Eighteen resource catalogs, not eighteen validated experiences | Qualified language review, actual RTL/large-text/VoiceOver work and diverse age/caregiver usability. |
| Visual coherence | Existing sprites/icons and artwork, incomplete current-build visual coverage | Per-screen asset audit and one original icon/illustration grammar; actual rendered checks after integration. |

RxFood's patient page includes a culturally specific food testimonial. That is not broad accuracy evidence, but it also means we should not portray worldwide food support as a category RxFood simply ignores. [P04]

## 4. What the review sample really says

There are **11 selected unique review observations from one platform**, across Canadian and US listings: nine from P07, two from P01. Repeated expanded/collapsed copies were deduplicated. Three Canadian observations are explicitly positive. This is a purposive sample, not a prevalence survey, independent multi-source consensus or a 100-review study.

Hand review found requests concerning access, delays, retained information, nutrient consistency and personal sharing; positive observations value convenient capture and useful learning. Developer responses report fixes/improvements and support-assisted sharing. Those responses are retained, and no historical complaint is labeled a demonstrated current defect.

The [CSV](reviews.csv) preserves one-word exact locators plus paraphrased context, source/date visibility and response limits. Dates without years remain unknown; stars are not invented. The Replica [generated feedback](feedback.md) analyzes those abbreviated locators only, so its scores are not severity estimates, population percentages or roadmap authority. Every theme is thin. The manual fix decisions below use full-page context and MealMirror's actual gaps, not keyword rank alone.

## 5. The research bar we need to respect

The 2020 iSpy paper describes iterative youth usability work, a small pilot trial, selected-food testing and qualified nutrition references. The investigators refined recognition on the test foods, so that food-set figure must not be treated as modern independent open-world accuracy. The pilot required a data plan and enrolled ages 10–17 after younger children struggled with navigation. It is not proof that the current commercial version works offline, serves every age, or matches every cuisine. [P11]

For MealMirror this implies: co-design with intended users and educators; separate development/calibration/final evaluation; include unfamiliar mixed dishes and nonfood; log corrections and failure recovery; and measure comprehension, not just attractive screenshots. Neither one successful exposed Simulator meal nor a 48MP downsampling pass closes these gaps. No clinical benefit or insulin-dose accuracy comparison has been established.

## 6. Delivery plan to earn a better choice

These are proposed acceptance targets, not achieved results. They supplement the existing [completion plan](../SUBMISSION-COMPLETION-PLAN.md).

| Order / owner | Deliverable | Required proof |
| --- | --- | --- |
| 1 / Full Stack + Backend | Complete the current exact-package build/resource/signing checks and remaining failure recovery | Preserve build-21 failures; finish real verification after host recovery. Exact artifact identity and explicit unrun gates. |
| 2 / Backend | Trustworthy local name/unknown handling | Qualified, lawfully usable diverse inputs with split/exposure controls; report naming, abstention and correction separately. No automatic grams. |
| 3 / Frontend + UI designs | Image-led core flow with coherent visuals and reachable controls | Original contact sheet and per-screen assets; exact native light/dark, compact/iPad, large text, RTL and Reduce Motion checks. Decorative art cannot obscure the primary photo action. |
| 4 / joint | Mixed-meal recovery | Wrap, soup, smoothie and mixed-plate cases: add views/label or a description; unknown remains useful; only explicitly confirmed items affect a total. |
| 5 / joint | Recent review reuse | Fresh review identity, editable current values, fresh confirmation, no retained photo, no mutation of the original. Older records without item detail must not manufacture it. |
| 6 / joint | Optional local review export | Preview exactly selected records and provenance; correct dates/units; no automatic transmission, photos or diagnosis data. User initiates sharing. |
| 7 / Frontend + qualified reviewers | Plain-language learning and accessible help | One concise source-reviewed learning moment; user/caregiver comprehension testing; language quality is reviewed, not inferred from catalog count. |
| 8 / Full Stack + applicant | Physical offline and Challenge demonstration | Exact ZIP, eligible/unavailable-model routes, cold relaunch and save/delete without network; human-paced three-minute story; applicant review and actual-year requirements. |

Connected Dexcom/Libre, professional support, comprehensive nutrition/recipes and any clinical dosing remain visible broader-product gaps. They are not silently counted as done or necessary network dependencies in the offline Challenge artifact. See the [CGM plan](../CGM-INTEGRATION-PLAN.md).

## 7. When we can say better

| Claim | Evidence required before making it |
| --- | --- |
| Easier to use | Same defined task and matched conditions, consented intended-user testing, completion/errors/help/comprehension reported; favourable impressions alone do not suffice. |
| Faster at meal review | Same hardware/input/task, cold and warm cases, preparation/model/manual fallback separately timed, median/tail/failure observations; no model-only stopwatch presented as whole-meal speed. |
| More accurate | Independent qualified food/portion/nutrition truth with lawful rights; fair comparable conditions and uncertainty; no food-label correctness substituted for carb accuracy. |
| Better offline | State exactly which features work after cold launch, model ready/unavailable and no connectivity; competitor's current offline tier still needs direct observation. |
| More inclusive | Diverse cuisines and users, accessible interaction and qualified language review; resource count and synthetic food art are insufficient. |
| More private | Source/data-flow review plus observed network behavior and clear user-controlled storage/sharing; no claim that a competitor violates its policy. |

Until those checks exist, the honest position is a promising offline meal-review alternative under development. The intended product should let people keep enjoying their chosen foods while understanding what the app knows, what it does not know and what they need to check.

## Tools and boundaries

Replica recon structured this investigation; replica-entrepreneur's actual `reviews.py` generated the feedback from the linked sample. Existing Agent Reach installation was not invoked because official web retrieval already supplied the needed sources; no account/cookie/extension setup was required. REA's earlier own-app artifact inventory remains historical. A new source-directory inventory attempt was rejected as an unsupported target, exited 1 and is retained; it produced no accepted findings. No REA native helpers, decompilation, private API discovery or competitor-code extraction ran. Tool names are not evidence of product superiority.
