# Recognition study data protocol

This is a preparation protocol, not an accepted dataset or a new recognizer. No photos were acquired, qualified labels accepted, classifier trained, or app behavior changed for this step.

## Conditional source routes

Start with individually verified CC0 files from Wikimedia Commons. Retain each file page/version, original source, uploader/rightsholder, stated CC0 basis, retrieval date and exact image hash in a private evidence record. Commons requires checking each file's conditions and does not warrant their accuracy. CC0 does not remove every possible third-party right. [Commons reuse guidance](https://commons.wikimedia.org/wiki/Commons:Reusing_content_outside_Wikimedia/en), [CC0 legal code](https://creativecommons.org/publicdomain/zero/1.0/legalcode.en).

Open Images V7 is a backup discovery route. Its images are listed under CC BY 2.0 and annotations under CC BY 4.0; Google explicitly requires verifying individual image licensing. Preserve original landing/source URLs and attribution separately for image and annotation. Human-verified object presence or absence is class-specific, not a whole-image food/nonfood judgment. Missing labels do not establish absence. [Dataset facts](https://storage.googleapis.com/openimages/web/factsfigures_v7.html), [metadata and annotation formats](https://storage.googleapis.com/openimages/web/download_v7.html), [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/legalcode), [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/legalcode).

Neither route is blanket clearance for training or distributing model derivatives. Actual per-file rights evidence and qualified human appearance review remain outstanding. Captions, categories and model annotations are discovery clues, not accepted truth.

## Partition contract

Keep development, training, calibration, evaluation and reserved partitions separate. Already exposed project images stay in development. Reserved inputs remain untouched. Group related views/crops of an original asset, the same scene and the same photographer together; none of these groups may cross partitions. Group identifiers describe actual relationships, not host domains or invented per-sample substitutes. Unknown relationships must be resolved before an evaluation claim.

An exposure ledger maps known exact SHA-256 values to `development_exposed` or `reserved_untouched`. It must cover the retained project history; the checker cannot establish completeness or independence from Apple's pretraining.

## Metadata checker

Run `python3 scripts/validate-recognition-manifest.py manifest.json --exposure-ledger ledger.json --require-reviewed-metadata --report report.json` from the repository root. Reports are created exclusively and existing reports are not overwritten.

Schema version 1 has a `datasetID` and a nonempty `samples` array. Each sample needs:

- Opaque `id`, exact declared lowercase `sha256`, `split`, `assetGroup`, `sceneGroup`, `photographerGroup` and `projectExposure`.
- `rights.review`: `pending`, `recorded` or `rejected`; nullable Boolean `training`, `calibration`, `evaluation`, `derivedModelDistribution`; and opaque evidence `record`.
- `label.value`: `food_like`, `nonfood`, `uncertain` or `unreviewed`; `label.review`: `unreviewed`, `ai_annotation`, `provisional_human` or `qualified_human`; and opaque evidence `record`.

Permission true means an asserted permission, null/missing means pending, and false means denied. Active partitions require their own use permission. Training and calibration also require an asserted model-distribution permission because both can affect distributed model parameters or thresholds. An explicit applicable denial or rejected rights review fails in both modes. Draft mode warns about pending assertions; reviewed-metadata mode requires all applicable assertions, evidence IDs, qualified human label assertions and an exposure ledger. A draft pass is not permission to train.

The script reads only the two supplied JSON metadata files, never images, source URLs or evidence records. It rejects duplicate keys, duplicate declared hashes, cross-partition groups, contradictory exposure declarations and invalid types. Reports expose codes and row numbers, not captions or source paths. Synthetic fixtures in `scripts/test-recognition-manifest.py` contain mock permissions and mock labels only.

## Acceptance still required

A metadata pass does not authenticate rights, reviewers or hashes; detect perceptual duplicates; prove independent scenes/photographers; establish worldwide coverage; validate appearance labels; or accept a model. Keep actual provenance and review evidence private. Freeze exact manifest and ledger hashes before a study, verify image bytes and relationships separately, and predeclare metrics and failure thresholds.

Qualified review must distinguish visible appearance from edibility, recipe or nutrition. Separate training, calibration and final evaluation data are still needed, including varied cuisines, mixed dishes, drinks, desserts and difficult nonfood/unknown cases. Actual name quality and abstention, physical iPhone offline behavior, performance, and Mac/iOS feature representation compatibility remain unresolved. This tool does not calculate carbohydrates or insulin.
