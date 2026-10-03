import io
import json
import os
from pathlib import Path

import httpx
import numpy as np
from PIL import Image
import torch
from transformers import CLIPModel, CLIPProcessor


ROOT = Path(os.environ["MEALMIRROR_MODEL_LAB"])
model = CLIPModel.from_pretrained(ROOT / "TinyCLIP", local_files_only=True).eval()
processor = CLIPProcessor.from_pretrained(ROOT / "TinyCLIP", local_files_only=True)
api = "https://datasets-server.huggingface.co/rows"
records = []
with httpx.Client(timeout=30, follow_redirects=True) as client:
    for offset in range(100, 25100, 2500):
        response = client.get(api, params={"dataset": "ethz/food101", "config": "default", "split": "validation", "offset": offset, "length": 10})
        response.raise_for_status()
        page = response.json()
        if offset == 100:
            labels = page["features"][1]["type"]["names"]
        records.extend(page["rows"])
    prompts = ["a photo of " + label.replace("_", " ") for label in labels]
    text_inputs = processor(text=prompts, return_tensors="pt", padding=True, truncation=True)
    with torch.inference_mode():
        text_features = model.get_text_features(**text_inputs)
        if not isinstance(text_features, torch.Tensor):
            text_features = text_features.pooler_output
        text_features = text_features / text_features.norm(dim=-1, keepdim=True)
    results = []
    failures = 0
    for record in records:
        row = record["row"]
        try:
            image_response = client.get(row["image"]["src"])
            image_response.raise_for_status()
            image = Image.open(io.BytesIO(image_response.content)).convert("RGB")
            image_inputs = processor(images=image, return_tensors="pt")
            with torch.inference_mode():
                image_features = model.get_image_features(**image_inputs)
                if not isinstance(image_features, torch.Tensor):
                    image_features = image_features.pooler_output
                image_features = image_features / image_features.norm(dim=-1, keepdim=True)
            scores = (image_features @ text_features.T)[0].numpy()
            ranked = np.argsort(-scores)
            results.append({
                "label": labels[row["label"]],
                "top": labels[int(ranked[0])],
                "top5": [labels[int(i)] for i in ranked[:5]],
                "gap": float(scores[ranked[0]] - scores[ranked[1]]),
            })
        except (httpx.HTTPError, OSError) as exc:
            failures += 1
            print("image_error", str(exc)[:150])
top1 = sum(r["label"] == r["top"] for r in results)
top5 = sum(r["label"] in r["top5"] for r in results)
print("samples", len(results), "failures", failures, "unique_labels", len({r["label"] for r in results}))
print("top1", top1, "top5", top5, "median_gap", float(np.median([r["gap"] for r in results])))
print("miss_examples", [(r["label"], r["top"], round(r["gap"], 3)) for r in results if r["label"] != r["top"]][:12])
(ROOT / "food101-results.json").write_text(json.dumps(results, indent=2))
