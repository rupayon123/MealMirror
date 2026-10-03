"""Research-only test of the pruned 22M TinyCLIP checkpoint on UECFoodPix.

Keep the model and UEC images outside the repository. A mask-category match is
only a rough test of a possible food name, never a nutrition estimate.
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
OUT = ROOT / "tinyclip22-uec-results.json"
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


def read_member(archive, name):
    member = archive.extractfile(name)
    if member is None:
        raise RuntimeError(f"Missing dataset member: {name}")
    return member.read()


checkpoint = torch.load(CHECKPOINT, map_location="cpu", weights_only=True)
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

with tarfile.open(ARCHIVE) as archive:
    categories = {}
    for line in read_member(archive, "UECFOODPIX/data/category.txt").decode().splitlines():
        parts = line.strip().split(maxsplit=1)
        if len(parts) == 2 and parts[0].isdecimal():
            categories[int(parts[0])] = parts[1].strip()
    ids = sorted(set(read_member(archive, "UECFOODPIX/data/test1000.txt").decode().split()), key=int)
    assert len(ids) == 1_000
    candidate_ids = sorted(category for category in categories if 1 <= category <= 100)
    prompts = ["a photo of " + categories[category].replace("-", " ") for category in candidate_ids]
    prompts += REJECT_PROMPTS
    tokenizer = get_tokenizer("ViT-B-32")
    with torch.inference_mode():
        text_features = model.encode_text(tokenizer(prompts), normalized=True)

    rows = []
    for start in range(0, len(ids), 16):
        batch = []
        for item_id in ids[start:start + 16]:
            image = Image.open(io.BytesIO(read_member(archive, PREFIX + f"test/img/{item_id}.jpg"))).convert("RGB")
            mask = np.asarray(Image.open(io.BytesIO(read_member(archive, PREFIX + f"test/mask/{item_id}.png"))))
            if mask.ndim == 3:
                mask = mask[:, :, 0]
            labels, areas = np.unique(mask, return_counts=True)
            visible = {int(label) for label, area in zip(labels, areas)
                       if label in candidate_ids and area >= mask.size * 0.01}
            batch.append((item_id, image, visible))
        with torch.inference_mode():
            images = torch.stack([preprocess(image) for _, image, _ in batch])
            features = model.encode_image(images, normalized=True)
            scores = (features @ text_features.T).numpy()
        for (item_id, _, visible), score in zip(batch, scores):
            ranked = np.argsort(-score)
            top = int(ranked[0])
            top_id = candidate_ids[top] if top < len(candidate_ids) else None
            rows.append({
                "image_id": item_id,
                "visible_classes": sorted(visible),
                "top_class": top_id,
                "top_prompt": prompts[top],
                "gap": float(score[ranked[0]] - score[ranked[1]]),
                "compatible": top_id in visible,
            })
        print(f"Processed {min(start + 16, len(ids))}/{len(ids)}", flush=True)

print("images", len(rows), "compatible", sum(row["compatible"] for row in rows))
for gap in (0, 0.02, 0.03, 0.04, 0.05):
    accepted = [row for row in rows if row["top_class"] is not None and row["gap"] >= gap]
    print("gap", gap, "accepted", len(accepted), "compatible", sum(row["compatible"] for row in accepted))
OUT.write_text(json.dumps({"categories": categories, "results": rows}, indent=2))
