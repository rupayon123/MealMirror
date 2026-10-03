"""Research-only regional food-name check on the fixed UECFoodPix test split.

The four overlapping views and 0.05 score-gap rule are set before this run.
They are not trained or tuned here. A mask match is only a rough proxy for a
useful food clue; no result is a carbohydrate or treatment estimate.
"""

import io
import json
import os
import tarfile
from argparse import Namespace
from pathlib import Path

import numpy as np
from PIL import Image
import torch

from open_clip import create_model_and_transforms, get_tokenizer
from open_clip.model import load_pruned_model


ROOT = Path(os.environ["MEALMIRROR_MODEL_LAB"])
ARCHIVE = ROOT / "UECFOODPIX.tar"
CHECKPOINT = ROOT / "TinyCLIP-auto-ViT-22M-32-Text-10M-LAION400M.pt"
OUT = ROOT / "tinyclip22-uec-regions-results.json"
PREFIX = "UECFOODPIX/data/UECFoodPIX/"
GAP = 0.05
REJECT_PROMPTS = [
    "a photo of a dog", "a photo of a cat", "a photo of a pet animal",
    "a photo of flowers", "a photo of a plant", "a photo of trees",
    "a photo of a person", "a photo of an airplane", "a photo of a car",
    "a photo of a bird", "a photo of a deer", "a photo of a frog",
    "a photo of a horse", "a photo of a ship", "a photo of a truck",
    "a photo of a mountain landscape", "a photo of the sky",
    "a photo of an empty plate", "a photo of a kitchen", "a photo of a toy",
]
torch.set_num_threads(4)


def member_bytes(archive, name):
    source = archive.extractfile(name)
    if source is None:
        raise RuntimeError(f"Missing dataset member: {name}")
    return source.read()


def views(image, mask):
    width, height = image.size
    crop_width, crop_height = round(width * 0.75), round(height * 0.75)
    for name, left, top in (
        ("upper_left", 0, 0),
        ("upper_right", width - crop_width, 0),
        ("lower_left", 0, height - crop_height),
        ("lower_right", width - crop_width, height - crop_height),
    ):
        box = (left, top, left + crop_width, top + crop_height)
        crop_mask = mask[top:top + crop_height, left:left + crop_width]
        labels, areas = np.unique(crop_mask, return_counts=True)
        visible = {int(label) for label, area in zip(labels, areas)
                   if 1 <= label <= 100 and area >= crop_mask.size * 0.01}
        yield name, image.crop(box), visible


checkpoint = torch.load(CHECKPOINT, map_location="cpu", weights_only=True)
state = {key.replace(".module", ""): value for key, value in checkpoint["state_dict"].items()}
args = Namespace(prune_image=True, prune_text=True, sparsity_warmup=1000,
                 start_sparsity=0.0, target_sparsity=0.25)
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

with tarfile.open(ARCHIVE) as archive:
    categories = {}
    for line in member_bytes(archive, "UECFOODPIX/data/category.txt").decode().splitlines():
        parts = line.strip().split(maxsplit=1)
        if len(parts) == 2 and parts[0].isdecimal():
            categories[int(parts[0])] = parts[1].strip()
    ids = sorted(set(member_bytes(archive, "UECFOODPIX/data/test1000.txt").decode().split()), key=int)
    assert len(ids) == 1_000
    candidate_ids = sorted(category for category in categories if 1 <= category <= 100)
    prompts = ["a photo of " + categories[category].replace("-", " ") for category in candidate_ids]
    prompts += REJECT_PROMPTS
    tokenizer = get_tokenizer("ViT-B-32")
    with torch.inference_mode():
        text_features = model.encode_text(tokenizer(prompts), normalized=True)

    rows = []
    for start in range(0, len(ids), 4):
        batch = []
        for item_id in ids[start:start + 4]:
            image = Image.open(io.BytesIO(member_bytes(archive, PREFIX + f"test/img/{item_id}.jpg"))).convert("RGB")
            mask = np.asarray(Image.open(io.BytesIO(member_bytes(archive, PREFIX + f"test/mask/{item_id}.png"))))
            if mask.ndim == 3:
                mask = mask[:, :, 0]
            for name, crop, visible in views(image, mask):
                batch.append((item_id, name, crop, visible))
        with torch.inference_mode():
            pixels = torch.stack([preprocess(crop) for _, _, crop, _ in batch])
            scores = (model.encode_image(pixels, normalized=True) @ text_features.T).numpy()
        for (item_id, name, _, visible), score in zip(batch, scores):
            ranked = np.argsort(-score)
            top = int(ranked[0])
            gap = float(score[ranked[0]] - score[ranked[1]])
            food_id = candidate_ids[top] if top < len(candidate_ids) else None
            rows.append({
                "image_id": item_id,
                "view": name,
                "visible_classes_in_view": sorted(visible),
                "top_class": food_id,
                "gap": gap,
                "suggested": food_id is not None and gap >= GAP,
                "compatible": food_id in visible,
            })
        if (start + 4) % 100 == 0:
            print(f"Processed {start + 4}/{len(ids)}", flush=True)

accepted = [row for row in rows if row["suggested"]]
by_image = {}
for row in accepted:
    by_image.setdefault(row["image_id"], []).append(row)
summary = {
    "images": len(ids),
    "views": len(rows),
    "gap": GAP,
    "accepted_views": len(accepted),
    "compatible_views": sum(row["compatible"] for row in accepted),
    "images_with_any_suggestion": len(by_image),
    "images_with_any_compatible_suggestion": sum(any(row["compatible"] for row in group) for group in by_image.values()),
    "images_with_any_incompatible_suggestion": sum(any(not row["compatible"] for row in group) for group in by_image.values()),
}
print(json.dumps(summary, indent=2))
OUT.write_text(json.dumps({"summary": summary, "results": rows}, indent=2))
