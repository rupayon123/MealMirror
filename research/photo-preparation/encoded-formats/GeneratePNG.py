#!/usr/bin/env python3
"""Create one rights-free 3200x2400 RGB PNG for PNG and HEIC encoding."""
from pathlib import Path
import sys

from PIL import Image, ImageDraw


def main() -> int:
    if len(sys.argv) != 2:
        return 2
    output = Path(sys.argv[1])
    if output.exists() or not output.parent.is_dir():
        return 3
    width, height = 3200, 2400
    image = Image.new("RGB", (width, height), (105, 105, 105))
    draw = ImageDraw.Draw(image)
    for index in range(32):
        x0 = index * 100
        shade = 70 + (index * 13) % 85
        draw.rectangle((x0, 300, x0 + 99, height - 301),
                       fill=(shade, 112, 160 - shade // 3))
    # Quarter-width and quarter-height blocks cover each 4x4 oracle corner.
    draw.rectangle((0, 0, 799, 599), fill=(20, 40, 230))       # blue
    draw.rectangle((2400, 0, 3199, 599), fill=(235, 210, 20))   # yellow
    draw.rectangle((0, 1800, 799, 2399), fill=(230, 30, 30))    # red
    draw.rectangle((2400, 1800, 3199, 2399), fill=(30, 220, 30))  # green
    with output.open("xb") as stream:
        image.save(stream, format="PNG", compress_level=6, optimize=False)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
