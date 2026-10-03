# TinyCLIP offline feasibility experiment

This is **research only**. The Challenge app does not bundle this model or use these scripts. The model card labels the checkpoint MIT; confirm all model and dataset rights again before redistribution. Do not treat a food name as a carbohydrate or insulin estimate.

## Reproduce on Apple silicon

Set `MEALMIRROR_MODEL_LAB` to a scratch directory outside this repository. With Python 3.11 and `uv` installed:

```sh
uv venv --python 3.11 "$MEALMIRROR_MODEL_LAB/.venv"
uv pip install --python "$MEALMIRROR_MODEL_LAB/.venv/bin/python" torch==2.14.1 transformers==5.18.0 coremltools==9.0 safetensors==0.8.0 pillow==12.3.0 httpx==0.28.1
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" -c 'from huggingface_hub import snapshot_download; import os; snapshot_download("wkcn/TinyCLIP-ViT-8M-16-Text-3M-YFCC15M", revision="a2a8c6eaa2549ad66eb7c31b85022bf58273a26c", allow_patterns=["config.json", "model.safetensors", "preprocessor_config.json", "tokenizer.json"], local_dir=os.environ["MEALMIRROR_MODEL_LAB"] + "/TinyCLIP")'
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" research/tinyclip/convert.py
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" research/tinyclip/verify.py
HF_HOME="$MEALMIRROR_MODEL_LAB/hf-cache" "$MEALMIRROR_MODEL_LAB/.venv/bin/python" research/tinyclip/benchmark_food101.py
```

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

The 100 real validation photos came from the [ETH Zurich Food-101 dataset](https://data.vision.ee.ethz.ch/cvl/datasets_extra/food-101/) through its Hugging Face mirror. The deterministic offsets in `benchmark_food101.py` sample beignets, pizza, carrot cake, chocolate mousse, frozen yogurt, scallops, onion rings, lobster roll sandwich, filet mignon, and sushi. A later attempt to sample one photo from every class received HTTP 429 before completion; no balanced 101-class result exists. The three bundled examples all ranked their matching prompt first, which is too narrow to establish real-world quality.

The converted model is small enough to warrant further work, but a fixed candidate list still excludes unknown meals. Before app integration, evaluate culturally varied mixed dishes and nonfood photos, abstention thresholds, on-device latency, VoiceOver/correction flow, prompt vocabulary and licensing, and final packaged size. A correct-looking top label cannot validate ingredients, portion, or carbohydrate content.
