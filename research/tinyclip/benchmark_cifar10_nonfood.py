import json
import os
from pathlib import Path
import pickle
import tarfile

import numpy as np
from PIL import Image
import torch
from transformers import CLIPModel, CLIPProcessor


ROOT = Path(os.environ["MEALMIRROR_MODEL_LAB"])
torch.set_num_threads(4)
with tarfile.open(ROOT / "cifar-10-python.tar.gz", "r:gz") as archive:
    content = archive.extractfile("cifar-10-batches-py/test_batch").read()
    test = pickle.loads(content, encoding="bytes")

metadata = json.loads(__import__("pyarrow.parquet", fromlist=["ParquetFile"]).ParquetFile(
    sorted((ROOT / "Food101/data").glob("validation-*.parquet"))[0]
).schema_arrow.metadata[b"huggingface"])
labels = metadata["info"]["features"]["label"]["names"]
prompts = ["a photo of " + label.replace("_", " ") for label in labels]
model = CLIPModel.from_pretrained(ROOT / "TinyCLIP", local_files_only=True).eval()
processor = CLIPProcessor.from_pretrained(ROOT / "TinyCLIP", local_files_only=True)
text_inputs = processor(text=prompts, return_tensors="pt", padding=True, truncation=True)
with torch.inference_mode():
    text_features = model.get_text_features(**text_inputs)
    if not isinstance(text_features, torch.Tensor):
        text_features = text_features.pooler_output
    text_features = text_features / text_features.norm(dim=-1, keepdim=True)

selected = []
counts = [0] * 10
for label, pixels in zip(test[b"labels"], test[b"data"]):
    if counts[label] >= 10:
        continue
    counts[label] += 1
    image = Image.fromarray(pixels.reshape(3, 32, 32).transpose(1, 2, 0))
    selected.append((label, image))
    if all(count == 10 for count in counts):
        break

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
            "cifar_label": label,
            "top_food": labels[int(ranked[0])],
            "top_score": float(score[ranked[0]]),
            "gap": float(score[ranked[0]] - score[ranked[1]]),
        })
print("samples", len(results), "classes", counts)
for threshold in (0.02, 0.03, 0.04, 0.05):
    print("gap", threshold, "false_food_suggestions", sum(r["gap"] >= threshold for r in results))
print("examples", [(r["cifar_label"], r["top_food"], round(r["gap"], 3)) for r in results[:12]])
(ROOT / "cifar10-nonfood-results.json").write_text(json.dumps(results, indent=2))
