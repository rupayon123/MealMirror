# Main-visible-food v1 comparison review

Provenance: copied from the external collection preparer's `COMPARISON-REVIEW.md` (SHA256 `a03e076a4951a67927da080430608a3a4822aaff5fd0cc3fdc9ea1ecbf00acf5`). The review body is preserved; this note and the Evidence section identify durable repository records. The preparer's visual review is not blinded expert annotation, and this copy did not perform another model request or image review.

## Recommendation

**Apply the exact tested `main-visible-food-v1` text as a bounded naming/usability refinement**, retaining the existing tentative, editable clue flow and complete separation from nutrition amounts. The observed soup, taco and sandwich outputs are simpler and avoid the earlier unsupported `garlic`/`cheese` and onion-synonym duplication. This is a qualitative implementation decision from exploratory evidence, not proof of broad accuracy, causal reliability, clinical validity or submission readiness.

Pasta still decomposes a dish into components despite the instruction. `Milk` remains a tentative appearance interpretation; the drink's actual contents are not established. Do not present the new prompt as a semantic guarantee or use any clue to populate nutrition automatically. Apply the tested wording without undocumented changes; package/build verification after application belongs to the parent.

## What was reviewed

All eleven actual thumbnails were re-opened and individually visually inspected against their unchanged pre-frozen expectations. Each proposal result and all eight baseline results were read; fixture hashes match. The artifact diff shows changes to the names Guide, system-instruction string and request string only. The comparison uses one fixed proposal and one recorded request per image, with no retries or omitted outcomes.

The original eight images were already exposed and prompted this proposal: they are a tuning comparison. The three separately frozen fruit/dessert/drink cases test scope on new local examples, with no baseline calls on those three. Neither group is qualified held-out acceptance. This assistant prepared both collections; this review is separate from the parent's review but is not blinded expert annotation.

## Eight exposed cases: baseline and fixed proposal

| Case | Baseline names | Proposal names | Pixel-based interpretation |
| --- | --- | --- | --- |
| Soup | soup; meat; green onions; scallions; noodles; garlic | soup | `Soup` fits the visible bowl and broth and preserves a useful broad clue. Unsupported garlic and the green-onions/scallions synonym duplication are absent in this observed output. Visible garnish/partly occluded strands were optional, so shorter output does not itself establish lost required coverage. |
| Flatbread/stew | bread; sauce | flatbread; sauce | `Flatbread` better fits the visible porous bread than generic bread. `Sauce` is compatible with the thick topping but remains generic relative to the frozen stew category. No specific legume, meat or beverage contents are invented. This is partial clarity improvement, not complete cultural/dish identification. |
| Filled tortillas | taco; meat; onion; garlic; cilantro; red pepper | tacos | `Tacos` fits the visible open filled tortillas. The previously unsupported garlic and ambiguous red-pepper/herb-specific interpretations are absent from this output. It retains the main meal form without asserting exact fillings. |
| Pasta | noodles; pepper; onion; meat | noodles; meat; vegetables; sauce | `Noodles` fits the visible cooked pasta; broad vegetable/sauce terms fit visible appearance. Generic meat-like pieces remain plausible, not verified protein truth. The result still decomposes the mixed dish and retains review burden; the whole-dish/no-decomposition instruction is **not reliably followed in this example**. Do not label this fully fixed. |
| Rice/beans | rice; beans; plantains | rice; beans; plantains | Unchanged. Rice and beans fit clearly visible structures. Plantains remain the pre-frozen optional plantain-like interpretation of broad browned slices; species, preparation and amounts are not established. Distinct plate areas make separate broad food clues reasonable here. |
| Sandwich | bread; cheese; tomato; egg; bacon | sandwich | `Sandwich` clearly fits the layered sliced bread and preserves the main meal category. The unsupported distinct cheese layer and other filling-specific interpretations are absent from this observed output. Exact fillings remain unknown. |
| Empty mugs | empty list | empty list | Both are successful inspected-empty outcomes, compatible with the visible empty containers. They are not errors or unavailable-model fallbacks. This covers only this scene. |
| Shoes | empty list | empty list | Both are successful inspected-empty outcomes, compatible with the nonfood objects. This covers only this scene. |

The shorter soup/taco/sandwich outputs show fewer questionable specific identities in these particular calls. Single baseline/proposal calls on exposed images cannot establish that wording alone caused the difference, that it will persist, or that other dishes will improve. No accuracy percentage is derived.

## Three separate scope checks

| Scope case | Proposal names | Comparison to pre-frozen visual expectation |
| --- | --- | --- |
| Whole-fruit snack | apple | Compatible with the clearly visible whole red/yellow apple-like fruit. The proposal did not abstain merely because this is a snack. No cultivar, ripeness, weight or nutrition was emitted. |
| Dessert | cake | Compatible with the visible layered cake portion. The proposal did not require a savory meal or infer a recipe/flavor/filling from the dark topping. No food-shaming judgment was emitted. |
| Filled beverage | milk | Nonempty output shows that this visible drink was included in scope, unlike the empty-mug control. `Milk` is visually compatible with the opaque white liquid **only as an unconfirmed appearance clue**. It does not establish dairy versus plant source, fat content, sweetening, ingredients, volume or nutrition. The instruction “do not guess their contents” is not a validated guarantee. |

There are no baseline results for these three; therefore this review makes no baseline-improvement or regression-rate claim. Three examples cannot prove that all snacks, desserts or drinks remain covered.

## Amount separation and remaining gates

Every proposal raw report records zero amount components, zero included components, no automatic carbohydrate total, and `readyForReview: false`. All eleven reached completed reports with an available local model; the two controls successfully emitted empty names. These checks support the tested name/amount boundary only.

Remaining concerns are dish decomposition (especially pasta), uncertain ingredient/drink identity, limited cultural and visual diversity, changing OS/model behavior and unknown pretraining exposure. Exact-app photo interaction, physical-device/offline isolation, accessibility interaction, clinical validity and submission requirements remain outside this comparison. Keep all raw evidence, the original frozen expectations and these limits. Do not rerun until answers look preferable or tune a case-specific ingredient blacklist.


## Evidence

- [Durable comparison record](main-visible-food-20261024.json): exact identities, all eight baseline and eleven proposal outcomes, frozen source/license/expectation metadata, and local-only raw artifact identifiers.
- [Earlier iOS source-derived diagnostics](ios-diagnostics-20261024.json): original matrix and eight-photo baseline evidence.
- [Worldwide meal evaluation plan](../../WORLDWIDE-MEAL-EVALUATION.md): independent evaluation still required.

Original prompt, protocol, raw reports, review provenance and source manifests remain local research artifacts under the workspace-relative `outputs/` identifiers in the durable record. They are not files tracked in this repository. Images, diagnostic helpers, model files, apps and binaries are not copied here or into the Challenge playground.
