# Procedural feature fixtures

These two generated 360 by 360 PNGs contain colored quadrants (F01) and diagonal grayscale bands (F02). They are test fixtures, not food photographs or nutrition evidence. Their exact hashes are recorded in `../../recognition-architecture/native-cgimage-20261025.json`.

`../NativeMacCGFeatureProbe.swift` is the exact external research source tested on native macOS 27 with Xcode 27.1. It takes an absolute fixture-directory path and a new, existing output directory. It has a 45-second whole-batch watchdog and performs the fixed A1/F01, B/F02, A2/F01 sequence once, stopping at the first failed criterion. Compile with Swift 5 language mode and `-parse-as-library`; use a host bound of 180 seconds for compilation and 60 seconds for execution, as in the recorded protocol.

The diagnostic passed only its fixed numerical conditions on the recorded Mac. It is not bundled in MealMirror and does not establish food recognition, physical iPhone behavior, calibrated uncertainty or model-representation equivalence. Keep the earlier failed CIImage and Simulator evidence separate.
