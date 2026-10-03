"""Extract a fixed Vision validation sample outside the repository.

Usage: python select_uec_validation.py UECFOODPIX.tar /scratch/validation-200
The 200 IDs exclude the first 100 listed in UECFoodPix test1000.txt, which
were already inspected while choosing the app's broad-food threshold.
"""

import json
import random
import sys
import tarfile
from pathlib import Path


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("Usage: select_uec_validation.py UECFOODPIX.tar output-directory")
    archive_path = Path(sys.argv[1])
    output = Path(sys.argv[2])
    output.mkdir(parents=True, exist_ok=True)

    with tarfile.open(archive_path) as archive:
        member = archive.extractfile("UECFOODPIX/data/test1000.txt")
        if member is None:
            raise RuntimeError("UECFoodPix test list is missing")
        test_ids = member.read().decode("utf-8").split()
        development = set(test_ids[:100])
        remaining = sorted(set(test_ids) - development, key=int)
        selected = random.Random(20271003).sample(remaining, 200)
        for index, image_id in enumerate(selected):
            photo = archive.extractfile(
                f"UECFOODPIX/data/UECFoodPIX/test/img/{image_id}.jpg"
            )
            if photo is None:
                raise RuntimeError(f"Missing image {image_id}")
            (output / f"food-{index:03d}.jpg").write_bytes(photo.read())

    (output / "manifest.json").write_text(
        json.dumps({"seed": 20271003, "source": "UECFoodPix test1000.txt excluding first 100 entries", "ids": selected}, indent=2),
        encoding="utf-8",
    )
    print(f"Extracted {len(selected)} research photos to {output}")


if __name__ == "__main__":
    main()
