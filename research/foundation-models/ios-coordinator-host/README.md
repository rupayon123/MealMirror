# Production coordinator in an iOS app host

The [October 27 receipt](../coordinator-host-20261027.json) records one small SwiftUI diagnostic app on the isolated iPhone Duo/iOS 27.1 Simulator. All eight checks passed in 16.653 seconds: the actual local model supplied bounded name clues, real Vision OCR read the separate synthetic three-line label, the description matched an excluded reference item, and no carbohydrate component or total was automatically included.

`Host.swift` matches the executed source. It calls the production `MealAnalysisEngine.analyze` with three copies of one exposed demo image, a separately rendered synthetic label and the description `rice`. The label's `37 g` is test text, not a meal measurement. The test app has its own identifier/container, writes its own result and exits. It does not call the saved-history store. Its source and compiled dependencies are bound in the receipt; executables and diagnostic app bundles remain private local outputs.

The compiled engine, LocalPhotoAI, models, photo policy and MealCore files were byte-identical to candidate23 source. The language/catalog prefix is also exact; unused language-preference/UI code is omitted. No model, OCR request, UIImage, continuation gate or analysis type was replaced by a spy. Apple model names are recorded as uncertain output, with no semantic acceptance score.

The first manual host build had mismatched link SDK metadata and was not run. The subsequent build used the existing Darwin SDK-link correction and was verified as iOS Simulator/minimum27.0/SDK27.1 before install. A separate Mac Catalyst command-line attempt had already failed its exact OCR check. Both results are retained. Platform, lifecycle and runtime context differ, so the successful host does not identify the cause of the command-line failure.

This checks the engine coordinator in a test host. MealMirror's actual camera/picker, navigation, correction/Save/history, accessibility, language and physical offline journeys remain separate gates. The host source is outside the submission playground and ZIP.
