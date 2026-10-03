# TinyCLIP offline feasibility experiment

This is **research only**. The Challenge app does not bundle this model or use these scripts. The model card labels the checkpoint MIT; confirm all model and dataset rights again before redistribution. Do not treat a food name as a carbohydrate or insulin estimate.

## Reproduce on Apple silicon

Export `MEALMIRROR_MODEL_LAB` as a scratch directory outside this repository. With Python 3.11 and `uv` installed:

```sh
uv venv --python 3.11 "$MEALMIRROR_MODEL_LAB/.venv"
uv pip install --python "$MEALMIRROR_MODEL_LAB/.venv/bin/python" torch==2.14.1 transformers==5.18.0 coremltools==9.0 safetensors==0.8.0 pillow==12.3.0 httpx==0.28.1 pyarrow==23.0.1
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" -c 'from huggingface_hub import snapshot_download; import os; snapshot_download("wkcn/TinyCLIP-ViT-8M-16-Text-3M-YFCC15M", revision="a2a8c6eaa2549ad66eb7c31b85022bf58273a26c", allow_patterns=["config.json", "model.safetensors", "preprocessor_config.json", "tokenizer.json"], local_dir=os.environ["MEALMIRROR_MODEL_LAB"] + "/TinyCLIP")'
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" research/tinyclip/convert.py
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" research/tinyclip/verify.py
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" research/tinyclip/benchmark_food101.py
```

For the broader balanced check, download the pinned [Food-101 validation mirror](https://huggingface.co/datasets/ethz/food101/tree/main/data) and the official [CIFAR-10 Python archive](https://cave.cs.toronto.edu/kriz/cifar.html) into scratch space:

```sh
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" -c 'from huggingface_hub import snapshot_download; import os; snapshot_download("ethz/food101", repo_type="dataset", revision="83488de741c1bd1ce27aa6a2b33e19c7bdf92ca9", allow_patterns=["data/validation-*.parquet"], local_dir=os.environ["MEALMIRROR_MODEL_LAB"] + "/Food101")'
curl -L https://cave.cs.toronto.edu/kriz/cifar-10-python.tar.gz -o "$MEALMIRROR_MODEL_LAB/cifar-10-python.tar.gz"
md5 -q "$MEALMIRROR_MODEL_LAB/cifar-10-python.tar.gz"
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" research/tinyclip/benchmark_food101_balanced.py
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" research/tinyclip/benchmark_cifar10_nonfood.py
```

The CIFAR-10 checksum must match the author's published `c58f30108f718f92721af3b95e74349a` **before** the pickle-based script is run. The scripts output aggregate results and local JSON to scratch; no dataset images or model weights belong in the app repository.

The higher-resolution negative check also uses the [Oxford 102 Flowers](https://www.robots.ox.ac.uk/~vgg/data/flowers/102/) and [Oxford-IIIT Pet](https://www.robots.ox.ac.uk/~vgg/data/pets/) benchmarks. Their pinned Hugging Face mirrors were downloaded into scratch, with no images committed:

```sh
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" -c 'from huggingface_hub import snapshot_download; import os; root=os.environ["MEALMIRROR_MODEL_LAB"]; snapshot_download("dpdl-benchmark/oxford_flowers102", repo_type="dataset", revision="544b55c9af69a05742ead7571cd7ae23cfcd758b", allow_patterns=["data/validation-*.parquet"], local_dir=root + "/OxfordFlowers"); snapshot_download("timm/oxford-iiit-pet", repo_type="dataset", revision="089695c834a7deb60505b7cc506672db1c31a6aa", allow_patterns=["data/test-*.parquet"], local_dir=root + "/OxfordPets")'
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" research/tinyclip/benchmark_reject_prompts.py
```

For an independent cuisine check, download the official [UECFoodPix research dataset](https://mm.cs.uec.ac.jp/uecfoodpix/) to `$MEALMIRROR_MODEL_LAB/UECFOODPIX.tar` and verify its 740,782,080-byte size and SHA-256 `5a9fe296879d9f853dcca258d367dc0f18f1c9468c311e00cfbe5e1ad704580b`. The provider permits non-commercial research only; do not bundle or redistribute its photos or masks. Its test split has 1,000 photos with pixel-level food labels. Run:

```sh
MEALMIRROR_MODEL_LAB="$MEALMIRROR_MODEL_LAB" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" research/tinyclip/benchmark_uecfoodpix.py
```

The script uses the official 100 named meal categories as prompts plus the previously chosen 20 nonfood prompts, and keeps the earlier Food-101 score-gap cutoff of 0.04 without retuning. A top name counts as compatible if its category occupies at least 1% of the image mask; this is a conservative category agreement check, not ingredient or nutrition validation.

The conversion uses [Apple Core ML Tools](https://apple.github.io/coremltools/docs-guides/source/convert-a-torchvision-model-from-pytorch.html) and [8-bit post-training weight compression](https://apple.github.io/coremltools/docs/source/coremltools.optimize.coreml.post_training_quantization.html). Core ML Tools 9.0 warned that the installed PyTorch 2.14.1 was newer than its tested version; successful conversion and three output comparisons do not prove cross-version or iPhone behavior.

## October 3, 2026 result

| Measurement | Result | Scope |
| --- | ---: | --- |
| Published full checkpoint | 93,812,468 bytes | Hugging Face model repository |
| Converted image encoder | 16,680,923 bytes | Float16 Core ML package |
| 8-bit image encoder | 8,505,885 bytes | Core ML package; text encoder excluded |
| Hypothetical Challenge ZIP with 8-bit encoder | 20,515,479 bytes | Current ZIP plus encoder, without labels or text encoder; not a built app |
| Converted-versus-original cosine | 0.99946–0.99982 | Three bundled synthetic meal photos only |
| Food-101 top one | 64/100 | Ten Food-101 validation classes, ten images per class, 101 candidate names |
| Food-101 top five | 86/100 | Same limited sample |
| Balanced Food-101 top one | 292/505 | Five photos from each of all 101 labels |
| Balanced Food-101 top five | 438/505 | Same sample |
| Exploratory gap ≥0.04 | 69/505 kept; 69 correct | Cutoff selected and measured on the same Food-101 sample; not an independent threshold validation |
| CIFAR-10 gap ≥0.04 | 0/100 nonfood suggested | Ten images per class; 32×32 low-resolution negatives, not realistic camera photos |
| Flowers and pets, food-only prompts, gap ≥0.04 | 5/213 false food suggestions | 102 higher-resolution flower photos and 111 pet photos; several dogs became “hot dog” |
| Flowers and pets, 20 added nonfood prompts | 0/213 food labels ranked first | Same selected images and hand-chosen reject prompts; not an independent, broad nonfood validation |
| iOS 26.5 Simulator Core ML probe | 512-value output; 225 ms load, 132 ms inference | One bundled synthetic photo and one simulator run; no physical-device timing |
| UECFoodPix test split, 100 dish prompts + 20 reject prompts | 303/1,000 top names compatible with a visible mask category | Different dataset, with many Japanese and mixed dishes; fixed prompt taxonomy |
| UECFoodPix at prechosen gap ≥0.04 | 40/1,000 food names retained; 34 compatible, 6 incompatible | Independent cutoff check; too many incompatible suggestions for a trusted photo path |

The first 100 real validation photos came from the [ETH Zurich Food-101 dataset](https://data.vision.ee.ethz.ch/cvl/datasets_extra/food-101/) through its Hugging Face mirror. The deterministic offsets in `benchmark_food101.py` sample beignets, pizza, carrot cake, chocolate mousse, frozen yogurt, scallops, onion rings, lobster roll sandwich, filet mignon, and sushi. A direct download of the three validation Parquet shards then enabled the balanced 505-photo check. The [CIFAR-10 author's dataset](https://cave.cs.toronto.edu/kriz/cifar.html) supplied nonfood negatives. The three bundled examples all ranked their matching prompt first, which is too narrow to establish real-world quality.

The converted model is small enough to warrant further work, but a fixed candidate list still excludes unknown meals. The exploratory gap cutoff retains only about 14% of Food-101 photos. A three-versus-two per-class split retained 22/202 holdout photos at the 0.04 cutoff, all correctly labeled, but this is still one dataset and too few accepted examples to establish general precision. The higher-resolution pet and flower failures show why a food-only prompt bank is unsafe; the nonfood prompts were added after inspecting those failures, so their zero false-food count is exploratory. The three bundled examples have labels outside Food-101 and would require additional prompts and validation. Before app integration, evaluate culturally varied mixed dishes, realistic nonfood photos from new sources, independent abstention calibration, on-device latency, VoiceOver/correction flow, prompt vocabulary and licensing, and final packaged size. A correct-looking top label cannot validate ingredients, portion, or carbohydrate content.

The UECFoodPix result supplies an independent cuisine check and contradicts the apparent perfect precision of the earlier Food-101 cutoff: 6 of 40 retained names were incompatible with the visible mask labels. Exact category agreement is an imperfect proxy for whether a suggestion would be useful to a person, but this result does not support app integration. The limited taxonomy and single-dish top prompt also fail to describe many mixed plates. The next candidate needs a stronger image representation and evaluation across meals, nonfood images, and physical-device behavior before it can replace the current unknown result.

## Stronger 22M candidate — October 3, 2026

The [official TinyCLIP model zoo](https://github.com/microsoft/Cream/tree/main/TinyCLIP) reports 53.7% ImageNet zero-shot accuracy for auto-pruned ViT-22M/32 + Text-10M, compared with 41.1% for the 8M candidate. This is a **research-only** check; neither checkpoint is bundled. The 22M checkpoint is 114,214,705 bytes and has SHA-256 `fadfe0486c7eb64208d2cfe4dec08120b284a37a11dc2c63cb5dfbac0ed4f018`. The 22M image encoder has 22,024,993 parameters before any Core ML conversion or compression. Check the checkpoint's redistribution rights and all required notices before any product use; this experiment does not establish a final licensing determination.

For reproducibility, clone `https://github.com/microsoft/Cream.git` at `4a13c4091e78f9abd2160e7e01c02e48c1cf8fb9`, expose `TinyCLIP/src` as `PYTHONPATH`, and put the official `TinyCLIP-auto-ViT-22M-32-Text-10M-LAION400M.pt` release checkpoint in `$MEALMIRROR_MODEL_LAB`. The scripts load the checkpoint with PyTorch's `weights_only=True`, reconstruct the pruned towers with the upstream code, and use the same UECFoodPix test IDs, category prompts, mask threshold, and 20 previously selected reject prompts as the 8M experiment. In addition to the earlier environment, install compatible `torchvision`, `ftfy`, and `timm`. Then run:

```sh
MEALMIRROR_MODEL_LAB="$MEALMIRROR_MODEL_LAB" PYTHONPATH="/path/to/Cream/TinyCLIP/src" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" research/tinyclip/benchmark_tinyclip22_uec.py
MEALMIRROR_MODEL_LAB="$MEALMIRROR_MODEL_LAB" PYTHONPATH="/path/to/Cream/TinyCLIP/src" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" research/tinyclip/benchmark_tinyclip22_nonfood.py
```

| Measure | 22M result | Limit |
| --- | ---: | --- |
| UECFoodPix top name compatible with visible mask category | 387/1,000 | One Japanese/mixed-dish research dataset and a fixed 100-name taxonomy |
| Score gap ≥0.04 | 89 compatible / 103 food names | Threshold already explored with the 8M candidate; not an independent calibration |
| Score gap ≥0.05 | 60 compatible / 64 food names | Only 6.4% of photos received a food name; four still disagreed |
| Oxford flowers with 20 reject prompts | 0 food tops / 102 photos | Reject prompts were selected after prior flower failures |
| Oxford pets with 20 reject prompts | 0 food tops / 111 photos | Reject prompts were selected after prior pet failures |

Two of the four UEC mismatches above the 0.05 gap were semantically close to the mask (salmon meuniere versus grilled salmon, and pork cutlet on rice versus sirloin cutlet). The other two were croquette versus takoyaki and fish-shaped bean-jam pancake versus toast/potage. Category agreement is an imperfect human-usefulness measure, but a strict threshold that removes all observed mismatches in this already-inspected dataset keeps only 27 of 1,000 photos at gap 0.065. Selecting that threshold now would overfit this dataset. The stronger model is therefore **not approved for app integration**. Its uncompressed checkpoint is over the current 25 MB Challenge limit by itself, and no compressed Core ML package, clean ZIP, or physical-device run was measured.

For the Simulator runtime probe, `coremlc compile` produced an iOS 17-compatible `.mlmodelc`. The Swift playground's generated Xcode project produced duplicate Core ML build tasks when a raw `.mlpackage` was placed inside the package. An isolated probe copied the compiled directory as a generic `.coremlasset` resource, restored the `.mlmodelc` extension in temporary storage, and loaded it through `MLModel` plus `VNCoreMLRequest`. This workaround has **not** been incorporated into the candidate or verified from a clean Challenge ZIP.
