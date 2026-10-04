# MealMirror: Apple technology briefing

Reviewed October 3, 2026. This describes the current public Challenge candidate at commit `3173307` and the next technical direction. It is a technical briefing, not an applicant-written Challenge essay.

## The point to make

MealMirror is an offline, photo-first Swift app playground for people learning to review a meal after a Type 1 diabetes diagnosis. A person can photograph food, review possible clues, correct them, and keep the foods they enjoy. The engineering choice is to separate *what the image might show* from *what a person can confirm*. A photo alone does not establish hidden ingredients, a serving size, carbohydrate grams, or insulin units.

This lines up with Apple's public emphasis on private on-device intelligence, useful fallback when a model is unavailable, and clear control over uncertain AI output. It is an inference about alignment, **not** an Apple endorsement or an award criterion requiring a particular framework. Apple's published Challenge terms judge technical accomplishment, creativity, and applicant-written responses; the public Challenge page also mentions innovation, social impact, and inclusivity. [WWDC25 Foundation Models session](https://developer.apple.com/videos/play/wwdc2025/286/), [WWDC26 Foundation Models session](https://developer.apple.com/videos/play/wwdc2026/241/), [Apple's generative AI design guidance](https://developer.apple.com/design/human-interface-guidelines/generative-ai), [Challenge terms](https://developer.apple.com/swift-student-challenge/policy/), [Challenge overview](https://developer.apple.com/swift-student-challenge/).

## What the submitted code uses today

| Apple technology | Exact role in MealMirror | What to say carefully |
| --- | --- | --- |
| Swift 6 and SwiftUI | Native iPhone/iPad playground, onboarding, photo flow, review, editing, Practice, history, adaptive theme, and localization UI. `MealMirror.swiftpm/Package.swift` sets iOS 17 as its deployment floor. | “The experience is a native Swift app playground.” |
| PhotosUI `PhotosPicker` | Lets a person select a meal image from the system photo picker. | “A selected photo enters the local review flow.” Do not say a photo alone yields a trustworthy carb count. |
| AVFoundation and UIKit camera bridge | Requests camera authorization and presents `UIImagePickerController` for a rear-camera photo on supported hardware. | Physical-device capture and return have not yet been verified. |
| ImageIO, UIKit thumbnails, Swift concurrency | Downsamples a selected image to at most 1,800 pixels on a background queue so preparation does not block the screen. The latest selection wins if images are replaced quickly. | This is local preprocessing, not nutrition analysis. |
| Vision `VNClassifyImageRequest` | Requests image labels locally. A broad `food` label gates further labels; the app maps possible labels to a finite bundled food catalog. It filters a known broken iOS Simulator result. | This is Apple's general image classifier, **not** the Apple Intelligence multimodal Foundation Model and **not** a custom Core ML food model. Apple documents Vision classification as labels/observations, not serving measurements. [Vision API](https://developer.apple.com/documentation/vision/vnclassifyimagerequest). |
| Swift concurrency and cancellation | The image request has a 12-second unavailable fallback; abandoning the task cancels the Vision request and ignores late results. | This prevents a stalled classifier from trapping the meal flow; it is not evidence of fast hardware inference. |
| Local Swift models and catalog | Possible photo and description matches start *excluded*. Only person-confirmed items and portion controls can affect the illustrative range; a trusted manually entered gram amount is marked as user-entered. | Catalog ranges are examples and are not validated nutrition measurements for arbitrary meals. |
| Foundation local storage | Saves reviewed meal name, range, and date in a protected local file excluded from backup; photos are not saved. `UserDefaults` stores language/onboarding choices. | The candidate has no account, required server, photo upload, judge analytics, or CGM integration. Physical airplane-mode verification is still open. |
| Accessibility and localization APIs | VoiceOver labels, Dynamic Type-related layout, Reduce Motion, and right-to-left direction are present in source. Everyday source offers 18 language choices; the Challenge ZIP is English-only under currently published terms. | Do not claim completed accessibility or translation quality until direct QA is done. |

The current ZIP is 12,186,125 bytes and built from a clean extraction with Xcode 26.6 for iOS Simulator. That confirms packaging/building, not broad food recognition or iPhone performance. See [CHALLENGE-READINESS.md](CHALLENGE-READINESS.md).

## What WWDC26 changes, and why it is not yet a shipping claim

At WWDC25, Apple introduced the Foundation Models framework's on-device language model, guided Swift output, tool calling, and offline/private operation. At WWDC26, Apple announced **image attachments for on-device image understanding** and the new **Core AI** path for custom on-device models. Apple's WWDC26 session also introduced an Evaluations framework. These are strong candidates for the next MealMirror experiment because image understanding may handle mixed meals more naturally than a generic scene classifier. [WWDC25 overview](https://developer.apple.com/videos/play/wwdc2025/286/), [WWDC26 framework update](https://developer.apple.com/videos/play/wwdc2026/241/), [WWDC26 Apple Intelligence and Core AI presentation](https://developer.apple.com/videos/play/wwdc2026/382/).

The current candidate **does not call Foundation Models, ship Core AI, or bundle a custom Core ML model**. The installed Xcode 26.6/iOS 26.5 SDK does not expose the documented image-attachment API used in the WWDC26 demonstration. Apple's [Xcode system requirements](https://developer.apple.com/xcode/system-requirements/) list macOS 26.6 or later for Xcode 27, while the development Mac was on macOS 26.4 at the last check. Even after gaining that toolchain, model availability must be checked on the target device; Apple warns that the Foundation Models experience requires compatible Apple Intelligence hardware and settings, and recommends a useful fallback. [Apple generative AI design guidance](https://developer.apple.com/design/human-interface-guidelines/generative-ai).

A multimodal model would be asked for **candidate visible foods and explicit uncertainty**, never a dose or an exact carb count. Each output would be structured, constrained, reviewable, and measured on held-out meals. A model's fluent answer is not proof that it saw a hidden ingredient or knows grams. Apple specifically advises communicating limitations, allowing correction, testing across diverse people and inputs, and avoiding plausible but harmful hallucinations. [Apple generative AI design guidance](https://developer.apple.com/design/human-interface-guidelines/generative-ai).

If an OS-provided model is unavailable or performs poorly, a small, properly licensed custom on-device model could be evaluated with Core ML/Core AI. That path must fit the Challenge ZIP, work without a download, run on hardware, and pass independent tests on mixed and culturally varied meals plus nonfood images. Apple describes Core ML as on-device inference accelerated by CPU, GPU, and Neural Engine. [Core ML overview](https://developer.apple.com/documentation/coreml). Several candidate models were screened and rejected because coverage or false suggestions were inadequate; see [OFFLINE-MODEL-DECISION.md](OFFLINE-MODEL-DECISION.md).

## Questions an Apple developer may ask

**“Is this Apple Intelligence?”** No. The shipping photo path is Apple Vision's general `VNClassifyImageRequest`. WWDC26 multimodal Foundation Models is a planned, gated experiment, not integrated code.

**“Does the meal image give a carb or insulin number?”** No. Image output is a possible food clue, excluded until reviewed. Portions, recipes, hidden ingredients, and carbohydrate grams cannot be established from the picture alone. The app never computes insulin units.

**“Why not use the new model immediately?”** The local Xcode/iOS SDK does not include the WWDC26 image API, and the result must be evaluated on compatible physical hardware before it can be trusted. A photo flow for children and adults also needs a useful fallback on devices without the new model.

**“Does it really work offline?”** The code and ZIP contain local app resources, and no review screen depends on a server. A physical airplane-mode walkthrough of the final ZIP is still pending. The Challenge is judged offline under the currently published terms. [Challenge terms](https://developer.apple.com/swift-student-challenge/policy/).

**“What is the technical contribution?”** The specific work to show is a photo-first native flow with local image preparation, bounded/cancelable Vision inspection, explicit unknown results, person-confirmed food clues, source-aware carb review, protected local history, and a compact offline playground. The applicant must personally understand, review, and substantially contribute to the final work, and disclose all AI assistance under Apple's rules. [Challenge terms](https://developer.apple.com/swift-student-challenge/policy/).

**“What remains before a strong submission?”** Reliable on-device mixed-meal clues, independently measured abstention, physical-iPhone and offline validation, full accessibility review, an honest three-minute demonstration, applicant-owned essays/disclosure, and a final rules check when Apple publishes the next Challenge terms.
