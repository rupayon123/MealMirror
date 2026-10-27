# Current production photo-AI diagnostic

The [October 27 receipt](../current-catalyst-20261027.json) records two direct runs of the unchanged build-23 `LocalPhotoAI`, compiled with real Mac Catalyst UIKit and Foundation Models. Apple’s default model reported available with vision and guided generation. The exposed demo returned name clues, the synthetic blank returned no clues, three duplicate views produced one bounded name list, and a pending request returned its cancelled fallback promptly. None is an independent recognition or physical offline acceptance test.

`Probe.swift` is byte-identical to the executed extended harness. `Preparation.swift` contains the exact production preparation enum and orientation extension with imports. It is a frozen extraction, so compare its receipt hashes against current production before reusing it after an engine change. No model, framework, UIImage, cancellation gate or name policy is mocked. The first probe failed compilation because it omitted the existing orientation extension; that failure remains recorded.

The process is not a UIKit app host. Its timings measure this Mac and these exposed/synthetic inputs only. Cancellation observes the caller’s return, not eventual termination of Apple’s work. Repeated images are not different camera views. No quantities, nutrition accuracy or insulin doses are tested or accepted.

## Reproduce the same narrow diagnostic

Use a compatible Xcode/macOS toolchain and review the receipt/source hashes first. These commands create a fresh external output directory, compile the repository’s real MealCore and LocalPhotoAI sources, and run the probe. They do not change settings or use personal photos. The probe refuses to replace its result file and has a 50-second watchdog. Run from the repository root:

```bash
mm_ai_probe_dir="$(mktemp -d)"
mm_ai_sdk="$(xcrun --sdk macosx --show-sdk-path)"
mkdir "$mm_ai_probe_dir/Assets"
cp MealMirror.swiftpm/Assets/grain-bowl-demo.png "$mm_ai_probe_dir/Assets/"

xcrun swiftc -swift-version 6 -parse-as-library \
  -target arm64-apple-ios27.0-macabi -sdk "$mm_ai_sdk" \
  -F "$mm_ai_sdk/System/iOSSupport/System/Library/Frameworks" \
  -I "$mm_ai_sdk/System/iOSSupport/usr/include" \
  -emit-module -emit-library -module-name MealCore \
  MealMirror.swiftpm/MealCore/*.swift \
  -emit-module-path "$mm_ai_probe_dir/MealCore.swiftmodule" \
  -o "$mm_ai_probe_dir/libMealCore.dylib"

xcrun swiftc -swift-version 6 -parse-as-library \
  -target arm64-apple-ios27.0-macabi -sdk "$mm_ai_sdk" \
  -F "$mm_ai_sdk/System/iOSSupport/System/Library/Frameworks" \
  -I "$mm_ai_sdk/System/iOSSupport/usr/include" \
  -I "$mm_ai_probe_dir" -L "$mm_ai_probe_dir" -lMealCore \
  -Xlinker -rpath -Xlinker "$mm_ai_probe_dir" \
  MealMirror.swiftpm/LocalPhotoAI.swift \
  research/foundation-models/catalyst-current/Preparation.swift \
  research/foundation-models/catalyst-current/Probe.swift \
  -o "$mm_ai_probe_dir/probe"

"$mm_ai_probe_dir/probe" "$mm_ai_probe_dir"
```

Inspect `results.json` and the actual terminal status. An `inspected` result is a completed request, not proof that a returned food name is correct. An unavailable result must remain visible as such. This diagnostic is outside the app and submission ZIP.
