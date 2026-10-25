# Synthetic encoded-photo fixtures

Four 320 by 240 JPEG quadrant images created for MealMirror testing, reused byte-for-byte from the October 25 hosted UIKit probe. They contain no meal or personal photo. EXIF orientations are 1, 2, 6 and 8. The fixed SHA-256 values are in `../../verify-encoded-catalyst.py`.

The Catalyst checks retain the earlier hosted test's bounds, truncated-input and fixed corner expectations. They add explicit `UIImage.scale == 1` assertions. The earlier Simulator host control did not reach its assertions; passing Catalyst command-line checks do not turn it into a passing iOS test.

Run from the repository root:

```sh
python3 scripts/verify-encoded-catalyst.py --output /absolute/new/external/path
```

The driver extracts the actual encoded-Data function without replacing UIKit. It requires an Apple Silicon Mac with Xcode's Mac Catalyst SDK. It creates only a new external output directory and makes no app, Simulator, photo-library, model or network calls.
