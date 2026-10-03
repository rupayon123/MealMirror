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

The first 100 real validation photos came from the [ETH Zurich Food-101 dataset](https://data.vision.ee.ethz.ch/cvl/datasets_extra/food-101/) through its Hugging Face mirror. The deterministic offsets in `benchmark_food101.py` sample beignets, pizza, carrot cake, chocolate mousse, frozen yogurt, scallops, onion rings, lobster roll sandwich, filet mignon, and sushi. A direct download of the three validation Parquet shards then enabled the balanced 505-photo check. The [CIFAR-10 author's dataset](https://cave.cs.toronto.edu/kriz/cifar.html) supplied nonfood negatives. The three bundled examples all ranked their matching prompt first, which is too narrow to establish real-world quality.

The converted model is small enough to warrant further work, but a fixed candidate list still excludes unknown meals. The exploratory gap cutoff retains only about 14% of Food-101 photos and has not been calibrated on an independent sample. Before app integration, evaluate culturally varied mixed dishes and realistic nonfood photos, abstention thresholds, on-device latency, VoiceOver/correction flow, prompt vocabulary and licensing, and final packaged size. A correct-looking top label cannot validate ingredients, portion, or carbohydrate content.
