# RxFood public recon for MealMirror

Reviewed October 4, 2026. This is a clean-room feature map from public pages, not an account-based walkthrough or an accuracy study. Screen details that are not publicly visible are marked inferred. The goal is an original Swift Student Challenge experience for newly diagnosed people with Type 1 diabetes, children and caregivers, centered on an offline meal photo and a trustworthy review.

## Public sources

| Source | Evidence |
| --- | --- |
| [RxFood App Store listing](https://apps.apple.com/us/app/rxfood/id1482235880) | Current advertised photo, text, recent-meal and SMS logging; nutrition and wearable context; expert support, education and recipes. |
| [RxFood with Dexcom](https://rxfood.com/dexcom) | Public patient flow, approximate foods/portions/net carbs, food-glucose-insulin-exercise timeline, explicit no-dosing disclaimer and Dexcom sign-in. |
| [RxFood clinician page](https://rxfood.com/dexcom/clinicians) | Clinician overlay, dietary report, GI/fibre/whole-grain and substitution claims. |
| [RxFood FAQ](https://rxfood.com/faq) | Tablet connection requirement and manual photo/time entry when data is unavailable. |
| [RxFood patient FAQ](https://rxfood.com/patient) | Invited care workflow; public admission that wraps, smoothies and soups can hide ingredients from the photo analysis. |
| [RxFood logging help](https://rxfood.com/support-for-logging-and-deleting-meal) | Whole-meal and individual-food deletion. |

## Publicly supported screen inventory

| ID | Screen or state | Entry and purpose | Visibility |
| --- | --- | --- | --- |
| S01 | Sign-in/invitation | Dexcom account or care-program access | Publicly stated; layout unverified |
| S02 | Meal capture/log | Photo and alternative logging modes | Publicly stated; layout unverified |
| S03 | Meal food list | Foods, approximate portions and estimated carbohydrates | Publicly stated; layout unverified |
| S04 | Meal detail/edit | Remove a food or the whole meal | Public help article; layout partly described |
| S05 | Food-glucose timeline | Food, CGM, insulin and exercise context, with glucose-range filtering | Publicly stated; layout unverified |
| S06 | Dietary insights | Nutrients, diet quality and suggestions | Publicly stated; layout unverified |
| S07 | Education/recipes/support | Learning modules, recipes and expert/AI support | App Store description; layout unverified |
| S08 | Clinician report | Care-team assessment and patient history | Publicly stated; layout unverified |

No reliable public screen-by-screen inventory of loading, failure, denied-permission, empty or offline states was found. Those states cannot be claimed as RxFood behavior from these sources.

## User flows

- F01 meal photo: S01 → S02 → S03 → S04. Public materials describe a photo-first food list; tap count and exact correction controls are unverified.
- F02 glucose context: S03 → S05 → S06. Requires connected Dexcom data in the advertised offering.
- F03 clinician review: S02/S03 → S08. Report generation and care-team access are service features, not part of an offline playground.
- F04 recovery: S02 → manual image/time entry when connection is unavailable, according to the FAQ. Exact screens are unverified.

## Repeated components and data, inferred from public claims

- Meal photo, timestamp, food item, approximate portion, estimated nutrient values, optional user-entered insulin/exercise events, CGM reading and clinician report are public-facing concepts. Internal fields, schemas and APIs are unknown.
- Likely reusable components: meal card, food row, nutrition summary, timeline marker, education card and report chart. Their visual design and interactions are not inferred as facts.

## What MealMirror should beat, and how to prove it

1. **Offline completion:** finish the photo → honest clue or unknown → correction → saved review path in airplane mode, with no account. RxFood's public FAQ describes a connected tablet path; this is a testable product distinction, not a blanket claim that RxFood never works offline.
2. **Visible uncertainty:** every food and carbohydrate value shows its source; no unconfirmed image label enters a total. Evaluate this with real users and varied meals, including mixed and hidden-ingredient dishes.
3. **Low burden and food freedom:** a child or caregiver can start with one photo, recover from an unknown result, and discuss any chosen meal without shame. Measure completion time, mistakes and comprehension, not aesthetic preference alone.
4. **Accessibility:** verify VoiceOver, large text, reduced motion, contrast and right-to-left layouts on the actual app and final package.

The current MealMirror build has not proved superiority on recognition, nutrition accuracy, clinical outcomes or breadth. Existing Vision results were unreliable in Simulator, and no validated any-meal model is bundled.

## Scope and hard parts

The Challenge slice is S02/S03/S04 as an original three-minute offline experience, plus a local history and concise learning moment. Dexcom/Libre live connections, clinician networks, a comprehensive recipe library and personalized insulin dosing require online services, licensing or clinical validation outside this offline artifact. The broader product can address them in separately verified workstreams. Hard parts: reliable open-world meal recognition with abstention; medically meaningful nutrition validation; clinical-grade dosing and CGM safety. Overall size: XL for the full RxFood-like service, M/L for a carefully scoped Challenge playground.
