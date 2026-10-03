"""Research-only screen of a compact Food-101 MobileNetV3 model.

Set MEALMIRROR_MODEL_LAB to a scratch folder containing the upstream checkout,
Food101 validation parquet, and the Vision research image samples. This never
runs in MealMirror and never copies model weights or photos into the app.
"""

import json
import os
from pathlib import Path

import pyarrow.parquet as pq
import torch
from PIL import Image
from torchvision import models, transforms


root = Path(os.environ["MEALMIRROR_MODEL_LAB"])
source = root / "Food101-MobileNetV3-Source"
parquet = root / "Food101/data/validation-00000-of-00003.parquet"
names = json.loads(pq.read_table(parquet).schema.metadata[b"huggingface"])["info"]["features"]["label"]["names"]
model = models.mobilenet_v3_large(weights=None)
model.classifier[-1] = torch.nn.Linear(model.classifier[-1].in_features, len(names))
model.load_state_dict(
    torch.load(
        source / "artifacts/weights/food101_mobilenetv3_stage2_best_state_dict.pth",
        map_location="cpu",
        weights_only=True,
    )
)
device = "mps" if torch.backends.mps.is_available() else "cpu"
model = model.to(device).eval()
preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])
paths = sorted((root / "vision-validation-200").glob("food-*.jpg"))
paths += sorted((root / "vision-gate-300").glob("pet-*.jpg"))
paths += sorted((root / "vision-gate-300").glob("flower-*.jpg"))
if len(paths) != 400:
    raise RuntimeError(f"Expected 200 meals, 100 pets, and 100 flowers; found {len(paths)}")

rows = []
for start in range(0, len(paths), 16):
    batch = paths[start:start + 16]
    tensor = torch.stack([preprocess(Image.open(path).convert("RGB")) for path in batch]).to(device)
    with torch.inference_mode():
        scores = model(tensor).softmax(dim=-1).cpu()
    for path, score in zip(batch, scores):
        values, indexes = score.topk(3)
        rows.append({
            "image": path.name,
            "group": path.parent.name,
            "top": [
                {"name": names[index], "probability": float(value)}
                for value, index in zip(values, indexes)
            ],
        })
    print(f"Processed {min(start + 16, len(paths))}/{len(paths)}", flush=True)

(root / "food101-mobilenet-vision-validation-results.json").write_text(
    json.dumps(rows, indent=2), encoding="utf-8"
)
