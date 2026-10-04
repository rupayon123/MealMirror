"""Research-only FoodSeg103 MobileNet screen; prints aggregate counts only.

The checkpoint and copyrighted images are supplied from an external scratch
directory. This script does not save images, model weights, or per-image output.
"""

import argparse
import hashlib
import io
import random
import tarfile
from pathlib import Path

import pyarrow.parquet as parquet
import segmentation_models_pytorch as smp
import torch
from PIL import Image
from torchvision import transforms


CHECKSUMS = {
    "model": "6ecc4da2210d8a2128f6a79670d40f25c8f5ffbf11b3358689669c431896600f",
    "uec": "5a9fe296879d9f853dcca258d367dc0f18f1c9468c311e00cfbe5e1ad704580b",
    "flowers": "d72669b43d5793df254526a59527c9f58fa7c243cffb43725b177ffda4f4adaa",
    "pets": "0997d4744ee6740e96f17f56b40b97c70076a4e4dad565bc63d0ffd03906f754",
}


def check_sha256(path: Path, expected: str) -> None:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    if digest.hexdigest() != expected:
        raise ValueError(f"SHA-256 mismatch: {path}")


def uec_photos(archive_path: Path):
    with tarfile.open(archive_path) as archive:
        listing = archive.extractfile("UECFOODPIX/data/test1000.txt")
        if listing is None:
            raise ValueError("UECFoodPix test list is missing")
        test_ids = listing.read().decode("utf-8").split()
        remaining = sorted(set(test_ids) - set(test_ids[:100]), key=int)
        selected = random.Random(20271003).sample(remaining, 200)
        for image_id in selected:
            member = archive.extractfile(
                f"UECFOODPIX/data/UECFoodPIX/test/img/{image_id}.jpg"
            )
            if member is None:
                raise ValueError(f"Missing UECFoodPix image {image_id}")
            yield Image.open(io.BytesIO(member.read())).convert("RGB")


def oxford_photos(parquet_path: Path):
    count = 0
    for batch in parquet.ParquetFile(parquet_path).iter_batches(batch_size=16):
        for row in batch.to_pylist():
            yield Image.open(io.BytesIO(row["image"]["bytes"])).convert("RGB")
            count += 1
            if count == 100:
                return
    raise ValueError(f"Expected at least 100 images in {parquet_path}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--uec-tar", type=Path, required=True)
    parser.add_argument("--flowers-parquet", type=Path, required=True)
    parser.add_argument("--pets-parquet", type=Path, required=True)
    parser.add_argument("--device", choices=["mps", "cpu"], default="mps")
    args = parser.parse_args()

    paths = {
        "model": args.model,
        "uec": args.uec_tar,
        "flowers": args.flowers_parquet,
        "pets": args.pets_parquet,
    }
    for name, path in paths.items():
        check_sha256(path, CHECKSUMS[name])
    if args.device == "mps" and not torch.backends.mps.is_available():
        raise RuntimeError("MPS is unavailable; rerun with --device cpu")

    model = smp.DeepLabV3Plus(
        encoder_name="mobilenet_v2", encoder_weights=None, in_channels=3, classes=104
    )
    state = torch.load(args.model, map_location="cpu", weights_only=True)
    model.load_state_dict(state)
    model = model.to(args.device).eval()
    preprocess = transforms.Compose(
        [
            transforms.Resize(512),
            transforms.CenterCrop(512),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ]
    )
    groups = [
        ("UECFoodPix meal", uec_photos(args.uec_tar)),
        ("Oxford pet", oxford_photos(args.pets_parquet)),
        ("Oxford flower", oxford_photos(args.flowers_parquet)),
    ]
    print("group,images,food_pixels_gt_5_percent,food_pixels_gt_50_percent")
    for name, photos in groups:
        fractions = []
        batch = []
        for photo in photos:
            batch.append(preprocess(photo))
            if len(batch) == 4:
                with torch.inference_mode():
                    pred = model(torch.stack(batch).to(args.device)).argmax(1)
                fractions.extend((pred != 0).float().mean(dim=(1, 2)).cpu().tolist())
                batch = []
        if batch:
            with torch.inference_mode():
                pred = model(torch.stack(batch).to(args.device)).argmax(1)
            fractions.extend((pred != 0).float().mean(dim=(1, 2)).cpu().tolist())
        print(
            f"{name},{len(fractions)},{sum(value > 0.05 for value in fractions)},"
            f"{sum(value > 0.50 for value in fractions)}"
        )


if __name__ == "__main__":
    main()
