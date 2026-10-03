"""Research-only out-of-dataset meal photo check; never ships in the app.

Uses the official UECFoodPix test split and its segmentation masks. The fixed
0.04 score gap comes from the earlier Food-101 experiment; this script does not
fit a new threshold. A top label counts as compatible when its class occupies
at least one percent of the image mask. This is a name check, not nutrition.
"""

import io
import json
import os
import tarfile
from collections import Counter
from pathlib import Path

import numpy as np
from PIL import Image
import torch
from transformers import CLIPModel, CLIPProcessor


ROOT = Path(os.environ["MEALMIRROR_MODEL_LAB"])
ARCHIVE = ROOT / "UECFOODPIX.tar"
OUT = ROOT / "uecfoodpix-results.json"
PREFIX = "UECFOODPIX/data/UECFoodPIX/"
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


def read_member(archive: tarfile.TarFile, name: str) -> bytes:
    member = archive.extractfile(name)
    if member is None:
        raise RuntimeError(f"Missing dataset member: {name}")
    return member.read()


with tarfile.open(ARCHIVE) as archive:
    categories = {}
    for line in read_member(archive, "UECFOODPIX/data/category.txt").decode("utf-8").splitlines():
        parts = line.strip().split(maxsplit=1)
        if len(parts) == 2 and parts[0].isdecimal():
            categories[int(parts[0])] = parts[1].strip()
    assert len(categories) >= 100, len(categories)
    test_ids = read_member(archive, "UECFOODPIX/data/test1000.txt").decode("utf-8").splitlines()
    test_ids = sorted(set(item.strip() for item in test_ids if item.strip()), key=int)
    assert len(test_ids) >= 900, len(test_ids)

    candidate_ids = sorted(category for category in categories if 1 <= category <= 100)
    prompts = ["a photo of " + categories[category].replace("-", " ") for category in candidate_ids]
    prompts += REJECT_PROMPTS
    model = CLIPModel.from_pretrained(ROOT / "TinyCLIP", local_files_only=True).eval()
    processor = CLIPProcessor.from_pretrained(ROOT / "TinyCLIP", local_files_only=True)
    text_inputs = processor(text=prompts, return_tensors="pt", padding=True, truncation=True)
    with torch.inference_mode():
        text_features = model.get_text_features(**text_inputs)
        if not isinstance(text_features, torch.Tensor):
            text_features = text_features.pooler_output
        text_features = text_features / text_features.norm(dim=-1, keepdim=True)

    rows = []
    for start in range(0, len(test_ids), 16):
        batch = []
        for item_id in test_ids[start:start + 16]:
            image = Image.open(io.BytesIO(read_member(archive, PREFIX + f"test/img/{item_id}.jpg"))).convert("RGB")
            mask = Image.open(io.BytesIO(read_member(archive, PREFIX + f"test/mask/{item_id}.png")))
            mask_values = np.asarray(mask)
            if mask_values.ndim == 3:
                mask_values = mask_values[:, :, 0]
            labels, areas = np.unique(mask_values, return_counts=True)
            visible_ids = {int(label) for label, area in zip(labels, areas)
                           if label in candidate_ids and area >= mask_values.size * 0.01}
            batch.append((item_id, image, visible_ids))
        image_inputs = processor(images=[image for _, image, _ in batch], return_tensors="pt")
        with torch.inference_mode():
            features = model.get_image_features(**image_inputs)
            if not isinstance(features, torch.Tensor):
                features = features.pooler_output
            features = features / features.norm(dim=-1, keepdim=True)
            scores = (features @ text_features.T).numpy()
        for (item_id, _, visible_ids), score in zip(batch, scores):
            ranked = np.argsort(-score)
            top = int(ranked[0])
            top_id = candidate_ids[top] if top < len(candidate_ids) else None
            rows.append({
                "image_id": item_id,
                "visible_classes": sorted(visible_ids),
                "top_class": top_id,
                "top_prompt": prompts[top],
                "gap": float(score[ranked[0]] - score[ranked[1]]),
                "compatible": top_id in visible_ids,
            })
        print(f"Processed {min(start + 16, len(test_ids))}/{len(test_ids)}", flush=True)

accepted = [row for row in rows if row["top_class"] is not None and row["gap"] >= 0.04]
print("images", len(rows), "mask_classes", len(set(c for row in rows for c in row["visible_classes"])))
print("top_food", sum(row["top_class"] is not None for row in rows))
print("top_compatible", sum(row["compatible"] for row in rows))
print("accepted_gap_004", len(accepted), "compatible", sum(row["compatible"] for row in accepted))
print("accepted_wrong_examples", [(row["image_id"], row["top_prompt"], row["visible_classes"])
      for row in accepted if not row["compatible"]][:12])
print("most_common_top", Counter(row["top_prompt"] for row in rows).most_common(10))
OUT.write_text(json.dumps({"categories": categories, "results": rows}, indent=2))
