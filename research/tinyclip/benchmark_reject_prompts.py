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
torch.set_num_threads(4)
parquet = pq.ParquetFile(sorted((ROOT / "Food101/data").glob("validation-*.parquet"))[0])
metadata = json.loads(parquet.schema_arrow.metadata[b"huggingface"])
labels = metadata["info"]["features"]["label"]["names"]
food_prompts = ["a photo of " + label.replace("_", " ") for label in labels]
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
model = CLIPModel.from_pretrained(ROOT / "TinyCLIP", local_files_only=True).eval()
processor = CLIPProcessor.from_pretrained(ROOT / "TinyCLIP", local_files_only=True)
text_inputs = processor(text=prompts, return_tensors="pt", padding=True, truncation=True)
with torch.inference_mode():
    text_features = model.get_text_features(**text_inputs)
    if not isinstance(text_features, torch.Tensor): text_features = text_features.pooler_output
    text_features = text_features / text_features.norm(dim=-1, keepdim=True)

def evaluate(items):
    results = []
    for start in range(0, len(items), 16):
        batch = items[start:start+16]
        image_inputs = processor(images=[image for _, image in batch], return_tensors="pt")
        with torch.inference_mode():
            features = model.get_image_features(**image_inputs)
            if not isinstance(features, torch.Tensor): features = features.pooler_output
            features = features / features.norm(dim=-1, keepdim=True)
            scores = features @ text_features.T
        for (label, _), score in zip(batch, scores.numpy()):
            ranked = np.argsort(-score)
            top = int(ranked[0])
            results.append({"label":label,"top":prompts[top],"food":top<len(labels),"correct":top==label if label is not None else False,"gap":float(score[ranked[0]]-score[ranked[1]]),"score":float(score[ranked[0]])})
    return results

food=[]
seen=[0]*len(labels)
for file in sorted((ROOT/"Food101/data").glob("validation-*.parquet")):
    pf=pq.ParquetFile(file)
    for group in range(pf.num_row_groups):
        for row in pf.read_row_group(group,columns=["image","label"]).to_pylist():
            label=row["label"]
            ordinal=seen[label];seen[label]+=1
            if ordinal in (25,75,125,175,225): food.append((label,Image.open(io.BytesIO(row["image"]["bytes"])).convert("RGB")))
assert len(food)==505
flowers=[]
pf=pq.ParquetFile(ROOT/"OxfordFlowers/data/validation-00000-of-00001.parquet")
seen=set()
for group in range(pf.num_row_groups):
    for row in pf.read_row_group(group,columns=["image","label"]).to_pylist():
        if row["label"] not in seen:
            seen.add(row["label"])
            flowers.append((None,Image.open(io.BytesIO(row["image"]["bytes"])).convert("RGB")))
assert len(flowers)==102
pets=[]
pf=pq.ParquetFile(ROOT/"OxfordPets/data/test-00000-of-00001.parquet")
counts=[0]*37
for group in range(pf.num_row_groups):
    for row in pf.read_row_group(group,columns=["image","label"]).to_pylist():
        if counts[row["label"]]<3:
            counts[row["label"]]+=1
            pets.append((None,Image.open(io.BytesIO(row["image"]["bytes"])).convert("RGB")))
assert len(pets)==111

for name,items in [("food",food),("flowers",flowers),("pets",pets)]:
    results=evaluate(items)
    print(name,"samples",len(results),"food_top",sum(x["food"] for x in results),"correct_food",sum(x["correct"] for x in results))
    for threshold in (0,0.02,0.03,0.04,0.05):
        kept=[x for x in results if x["food"] and x["gap"]>=threshold]
        print(name,"gap",threshold,"food_suggestions",len(kept),"correct",sum(x["correct"] for x in kept))
    print(name,"bad",[(x["top"],round(x["gap"],3)) for x in results if x["food"] and x["gap"]>=0.04 and not x["correct"]][:6])
    (ROOT/f"{name}-reject-results.json").write_text(json.dumps(results,indent=2))
