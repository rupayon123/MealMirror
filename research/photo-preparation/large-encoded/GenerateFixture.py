#!/usr/bin/env python3
"""Generate one 8000x6000 procedural JPEG; no personal or fetched content."""
from pathlib import Path
import sys

from PIL import Image, ImageDraw


def main() -> int:
    if len(sys.argv) != 2:
        return 2
    output = Path(sys.argv[1])
    if output.exists() or not output.parent.is_dir():
        return 3
    width, height = 8000, 6000
    image = Image.new("RGB", (width, height), (105, 105, 105))
    draw = ImageDraw.Draw(image)
    # Low-frequency scene texture makes the input more than four solid blocks.
    for index in range(64):
        x0 = index * 125
        shade = 70 + (index * 13) % 85
        draw.rectangle((x0, 600, x0 + 124, height - 601), fill=(shade, 112, 160 - shade // 3))
    # Source-image corners, in top-left / top-right / bottom-left / bottom-right order.
    # EXIF orientation 6 should make the displayed corners red / blue / green / yellow.
    # Quarter-size blocks put every 4x4 oracle corner sample well inside a color.
    draw.rectangle((0, 0, 1999, 1499), fill=(20, 40, 230))       # blue
    draw.rectangle((6000, 0, 7999, 1499), fill=(235, 210, 20))   # yellow
    draw.rectangle((0, 4500, 1999, 5999), fill=(230, 30, 30))    # red
    draw.rectangle((6000, 4500, 7999, 5999), fill=(30, 220, 30))  # green
    exif = Image.Exif()
    exif[274] = 6
    with output.open("xb") as stream:
        image.save(stream, format="JPEG", quality=85, subsampling=0,
                   optimize=False, progressive=False, exif=exif.tobytes())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
