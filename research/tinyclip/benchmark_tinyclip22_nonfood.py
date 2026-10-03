"""Research-only realistic nonfood check for the 22M TinyCLIP candidate."""

import io
import json
import os
import tarfile
from argparse import Namespace
from pathlib import Path

import numpy as np
import pyarrow.parquet as pq
from PIL import Image
import torch

from open_clip import create_model_and_transforms, get_tokenizer
from open_clip.model import load_pruned_model


ROOT = Path(os.environ["MEALMIRROR_MODEL_LAB"])
torch.set_num_threads(4)
with tarfile.open(ROOT / "UECFOODPIX.tar") as archive:
    source = archive.extractfile("UECFOODPIX/data/category.txt")
    assert source is not None
    categories = {}
    for line in source.read().decode().splitlines():
        parts = line.strip().split(maxsplit=1)
        if len(parts) == 2 and parts[0].isdecimal():
            categories[int(parts[0])] = parts[1].strip()
food_prompts = ["a photo of " + categories[i].replace("-", " ") for i in range(1, 101)]
reject_prompts = [
    "a photo of a dog", "a photo of a cat", "a photo of a pet animal",
    "a photo of flowers", "a photo of a plant", "a photo of trees",
    "a photo of a person", "a photo of an airplane", "a photo of a car",
    "a photo of a bird", "a photo of a deer", "a photo of a frog",
    "a photo of a horse", "a photo of a ship", "a photo of a truck",
    "a photo of a mountain landscape", "a photo of the sky",
    "a photo of an empty plate", "a photo of a kitchen", "a photo of a toy",
]
prompts = food_prompts + reject_prompts
checkpoint = torch.load(
    ROOT / "TinyCLIP-auto-ViT-22M-32-Text-10M-LAION400M.pt",
    map_location="cpu", weights_only=True,
)
state = {key.replace(".module", ""): value for key, value in checkpoint["state_dict"].items()}
args = Namespace(
    prune_image=True, prune_text=True, sparsity_warmup=1000,
    start_sparsity=0.0, target_sparsity=0.25,
)
model, _, preprocess = create_model_and_transforms("ViT-B-32", args=args)
load_pruned_model(model, state)
model.eval()
with torch.inference_mode():
    model.image_encoder_without_ddp(torch.randn(1, 3, 224, 224))
    model.image_encoder_without_ddp = model.image_encoder_without_ddp.prune()
    model.image_encoder_without_ddp.l0_module = None
    model.text_encoder_without_ddp(torch.randint(0, 100, (1, 77)))
    model.text_encoder_without_ddp = model.text_encoder_without_ddp.prune()
    model.text_encoder_without_ddp.l0_module = None
    text_features = model.encode_text(get_tokenizer("ViT-B-32")(prompts), normalized=True)


def evaluate(name, images):
    rows = []
    for start in range(0, len(images), 16):
        with torch.inference_mode():
            pixels = torch.stack([preprocess(image) for image in images[start:start + 16]])
            scores = (model.encode_image(pixels, normalized=True) @ text_features.T).numpy()
        for score in scores:
            ranked = np.argsort(-score)
            top = int(ranked[0])
            rows.append({
                "top_prompt": prompts[top],
                "food": top < len(food_prompts),
                "gap": float(score[ranked[0]] - score[ranked[1]]),
            })
    print(name, "images", len(rows), "food_top", sum(row["food"] for row in rows))
    for gap in (0.02, 0.03, 0.04, 0.05):
        kept = [row for row in rows if row["food"] and row["gap"] >= gap]
        print(name, "gap", gap, "false_food", len(kept), "examples", [row["top_prompt"] for row in kept[:5]])
    (ROOT / f"tinyclip22-{name}-nonfood-results.json").write_text(json.dumps(rows, indent=2))


flowers = []
parquet = pq.ParquetFile(ROOT / "OxfordFlowers/data/validation-00000-of-00001.parquet")
seen = set()
for group in range(parquet.num_row_groups):
    for row in parquet.read_row_group(group, columns=["image", "label"]).to_pylist():
        if row["label"] not in seen:
            seen.add(row["label"])
            flowers.append(Image.open(io.BytesIO(row["image"]["bytes"])).convert("RGB"))
assert len(flowers) == 102
evaluate("flowers", flowers)

pets = []
parquet = pq.ParquetFile(ROOT / "OxfordPets/data/test-00000-of-00001.parquet")
counts = [0] * 37
for group in range(parquet.num_row_groups):
    for row in parquet.read_row_group(group, columns=["image", "label"]).to_pylist():
        if counts[row["label"]] < 3:
            counts[row["label"]] += 1
            pets.append(Image.open(io.BytesIO(row["image"]["bytes"])).convert("RGB"))
assert len(pets) == 111
evaluate("pets", pets)
