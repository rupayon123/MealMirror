import os
from pathlib import Path

import coremltools as ct
import numpy as np
from PIL import Image, ImageOps
import torch
from transformers import CLIPModel, CLIPProcessor


ROOT = Path(os.environ["MEALMIRROR_MODEL_LAB"])
ASSETS = Path(__file__).resolve().parents[2] / "MealMirror.swiftpm/Assets"
model = CLIPModel.from_pretrained(ROOT / "TinyCLIP", local_files_only=True).eval()
processor = CLIPProcessor.from_pretrained(ROOT / "TinyCLIP", local_files_only=True)
prompts = [
    "a photo of chicken biryani with rice",
    "a photo of a grain bowl with vegetables",
    "a photo of eggs toast yogurt and berries for breakfast",
    "a photo of pizza",
    "a photo of a dog",
    "a photo of a night sky",
]
text_inputs = processor(text=prompts, return_tensors="pt", padding=True)
with torch.inference_mode():
    text_features = model.get_text_features(**text_inputs)
    if not isinstance(text_features, torch.Tensor):
        text_features = text_features.pooler_output
    text_features = text_features / text_features.norm(dim=-1, keepdim=True)

for model_name in ("TinyCLIPImageEncoder.mlpackage", "TinyCLIPImageEncoder-int8.mlpackage"):
    compiled = ct.models.MLModel(str(ROOT / model_name), compute_units=ct.ComputeUnit.CPU_ONLY)
    print(model_name)
    for image_name in ("biryani-demo.png", "grain-bowl-demo.png", "breakfast-demo.png"):
        image = Image.open(ASSETS / image_name).convert("RGB")
        prepared = ImageOps.fit(image, (224, 224), method=Image.Resampling.BICUBIC)
        inputs = processor(images=image, return_tensors="pt")
        with torch.inference_mode():
            py_features = model.get_image_features(**inputs)
            if not isinstance(py_features, torch.Tensor):
                py_features = py_features.pooler_output
            py_features = py_features / py_features.norm(dim=-1, keepdim=True)
        ml_features = np.asarray(compiled.predict({"image": prepared})["embedding"]).reshape(1, -1)
        cosine = float(np.dot(py_features.numpy().reshape(-1), ml_features.reshape(-1)))
        scores = ml_features @ text_features.numpy().T
        ranked = np.argsort(-scores[0])
        print(image_name, "cosine", round(cosine, 5), "top", prompts[int(ranked[0])], "gap", round(float(scores[0][ranked[0]]-scores[0][ranked[1]]), 4))
