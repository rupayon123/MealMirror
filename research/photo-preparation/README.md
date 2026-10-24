# Photo preparation checks

Recorded October 24, 2026. This is a processing-unit check using procedural fixtures in a standalone iOS 27.1 Simulator process. Source, script, protocol and result hashes are in [the evidence record](ci-origin-20261024.json). Raw artifacts remain outside the repository and submission package.

## Reproduced and corrected

- **Negative fractional CI origin:** the original implementation passed 48 of 64 geometry cases; all 16 negative-fraction cases returned `nil`. Scaling produced integral bounds of 769 × 513 for a nominal 768 × 512 image, consistent with render-bound expansion. The retained probe does not distinguish render failure from pixel-limit rejection. Normalizing the origin before scaling corrected the tested cases.
- **Malformed image scale:** public CI-backed `UIImage` constructors retained NaN/infinite scales, which the original CI branch passed into its result. The existing scale guard now runs before either image path. Zero/negative requested scales normalized to 1 on this runtime and remained usable; this does not establish a real camera failure.

Apple documents integralization/intersection of the region passed to [`createCGImage(_:from:)`](https://developer.apple.com/documentation/coreimage/cicontext/createcgimage(_:from:)). Rendering remains after scaling; no extra full-size render was added.

## Verified scope

The [driver](../../scripts/verify-photo-preparation.py) extracts the actual enum byte-identically at runtime and compiles it with [procedural Swift fixtures](../../scripts/verify-photo-preparation.swift), without a committed production implementation copy. The combined correction passed **83 checks with zero failures** in one execution:

- 64 cases covering four origins, eight orientations and scales 1/2;
- four representative meal/label size-limit cases;
- eight scale-constructor cases and seven invalid-input cases.

Valid scales/orientation metadata and bounded dimensions passed. Four orientation-aware reference corners matched exactly; the largest display-aspect difference was 0.000174. These samples do not establish full pixel equivalence or coverage of the off-center marker. An existing-output invocation refused before running a second Simulator process and preserved the prior receipt.

Run from the repository root with an already booted Simulator and a new external directory:

```sh
python3 scripts/verify-photo-preparation.py --simulator SIMULATOR_UUID \
  --output /path/outside/repository/new-check
```

## Memory remains unresolved

The original stress measurement's raw receipt was not located. Fresh 48 MP procedural checks still showed high preparation peaks on both CI and CG paths; an explicitly filled bitmap control reached 662,077,440 bytes peak RSS after preparation versus 256,999,424 after fixture creation. Fixture allocation alone does not explain the peak, and internal rendering/decoder costs remain unisolated. No memory improvement is claimed. Disabling [`cacheIntermediates`](https://developer.apple.com/documentation/coreimage/cicontextoption/cacheintermediates) controls intermediate caching; it does not establish a peak-memory ceiling.

These checks do not validate real camera/Photos decoding, physical-device behavior, complete app UI, network isolation or meal recognition. They are not submission-package or distribution evidence.

## Exact build-5 delivery

The [delivery receipt](delivery-20261024.json) records the deterministic English-only ZIP, clean arm64 Simulator build/install/launch and initial Welcome rendering, verified signed archive and successful internal-only upload. Apple reported processing; compliance, processing completion, existing-group Testing and phone installation remain unverified. The separate [combined photo/label processing check](../foundation-models/combined-label-20261024.json) retained tentative names and raw OCR outside amounts. Neither check completes the actual app’s photo-to-history journey or physical offline validation.
