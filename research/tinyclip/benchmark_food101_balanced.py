import io
import json
import os
from pathlib import Path

import numpy as np
import pyarrow.parquet as pq
from PIL import Image
import torch
from transformers import CLIPModel, CLIPProcessor


ROOT = Path(os.environ["MEALMIRROR_MODEL_LAB"])
DATA = ROOT / "Food101/data"
CHECKPOINT = ROOT / "TinyCLIP"
SELECT = {25, 75, 125, 175, 225}
torch.set_num_threads(4)

files = sorted(DATA.glob("validation-*.parquet"))
assert len(files) == 3
metadata = json.loads(pq.ParquetFile(files[0]).schema_arrow.metadata[b"huggingface"])
labels = metadata["info"]["features"]["label"]["names"]
prompts = ["a photo of " + label.replace("_", " ") for label in labels]
model = CLIPModel.from_pretrained(CHECKPOINT, local_files_only=True).eval()
processor = CLIPProcessor.from_pretrained(CHECKPOINT, local_files_only=True)
text_inputs = processor(text=prompts, return_tensors="pt", padding=True, truncation=True)
with torch.inference_mode():
    text_features = model.get_text_features(**text_inputs)
    if not isinstance(text_features, torch.Tensor):
        text_features = text_features.pooler_output
    text_features = text_features / text_features.norm(dim=-1, keepdim=True)

selected = []
seen = [0] * len(labels)
for file in files:
    parquet = pq.ParquetFile(file)
    for group in range(parquet.num_row_groups):
        rows = parquet.read_row_group(group, columns=["image", "label"]).to_pylist()
        for row in rows:
            label = row["label"]
            ordinal = seen[label]
            seen[label] += 1
            if ordinal in SELECT:
                selected.append((label, Image.open(io.BytesIO(row["image"]["bytes"])).convert("RGB")))
assert len(selected) == 505, len(selected)
assert all(count == 250 for count in seen), set(seen)

results = []
for start in range(0, len(selected), 16):
    batch = selected[start:start+16]
    image_inputs = processor(images=[image for _, image in batch], return_tensors="pt")
    with torch.inference_mode():
        features = model.get_image_features(**image_inputs)
        if not isinstance(features, torch.Tensor):
            features = features.pooler_output
        features = features / features.norm(dim=-1, keepdim=True)
        scores = features @ text_features.T
    for (label, _), score in zip(batch, scores.numpy()):
        ranked = np.argsort(-score)
        results.append({
            "label": labels[label],
            "top": labels[int(ranked[0])],
            "top5": [labels[int(i)] for i in ranked[:5]],
            "gap": float(score[ranked[0]] - score[ranked[1]]),
            "top_score": float(score[ranked[0]]),
        })
correct = sum(row["label"] == row["top"] for row in results)
top5 = sum(row["label"] in row["top5"] for row in results)
print("samples", len(results), "classes", len(set(row["label"] for row in results)))
print("top1", correct, "top5", top5)
for threshold in (0.02, 0.03, 0.04, 0.05):
    kept = [row for row in results if row["gap"] >= threshold]
    right = sum(row["label"] == row["top"] for row in kept)
    print("gap", threshold, "kept", len(kept), "correct", right)
print("miss_examples", [(r["label"], r["top"]) for r in results if r["label"] != r["top"]][:12])
(ROOT / "food101-balanced-results.json").write_text(json.dumps(results, indent=2))
