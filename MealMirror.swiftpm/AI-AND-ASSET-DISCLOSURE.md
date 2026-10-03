# AI and asset disclosure working record

This is a project-history checklist for the applicant, not a Challenge essay. Apple requires AI assistance to be fully disclosed and expects significant individual contribution and technical understanding. The applicant must verify the complete project history and final archive before answering Apple's form.

## Assistance in this candidate

- Codex assisted with Swift code review and edits, SwiftUI screen and state changes, local image-classification investigation, copy, package preparation, and submission-readiness documentation. The project existed before this assistance; the applicant must describe their own prior work and their individual contribution accurately.
- The candidate uses Apple's on-device Vision `VNClassifyImageRequest` to request image labels. The app maps matching labels to a small, local food catalog. Possible matches begin excluded and never set portion size or carbohydrate grams. On October 3, 2026, an independent iOS 26.5 Simulator probe returned the same unrelated scene labels for all three bundled meal photos on CPU; GPU and default requests failed to create an Espresso context. MealMirror now marks that known bad result as an unavailable inspection and shows no range. macOS Vision recognized the biryani photo, but physical iPhone/iPad behavior remains unverified.
- OpenAI image generation created the three illustrative Practice meal images in `Assets/biryani-demo.png`, `Assets/grain-bowl-demo.png`, and `Assets/breakfast-demo.png`. They are synthetic examples, not photographs of measured servings and not nutrition evidence.
- The user supplied the pixel pot/MM emblem. OpenAI image generation was used at the user's direction to refine the supplied artwork's crop, relative scale, and steam highlight for the app icon and launch mark. The final asset remains based on the user's selected art; it is not the earlier, separate generated logo concept, which was rejected and is not bundled. The applicant should compare the final image files with the original reference and update this description if the delivered edit differs.
- The Swift package has no external Swift package dependency. Recheck asset provenance, source history, and any prior tools, templates, or third-party material that are not listed here.

## Applicant-owned checks

- Inspect the final `.swiftpm` and archive and confirm each listed AI-assisted change and asset. Update this record if the final files or project history differ.
- Review every AI-assisted code and copy change; revise and understand the finished work. Be able to explain the SwiftUI flow, offline behavior, photo-classification path and its limits, local catalog mapping, why possible photo matches start excluded, uncertainty handling, and protected local storage.
- Confirm the right to use the supplied emblem and every other bundled resource. Explain the user-supplied logo and AI-assisted visual edit, generated practice images, any third-party or open-source material, and applicable rights or license where Apple's form requires it.
- Disclose every AI tool and its project use accurately, including the three generated Practice images and the discarded logo exploration if Apple's question covers the development process.
- Make substantial individual contributions and ensure the final playground is the applicant's own individual work under the rules for the applicable Challenge year. Write all application essays personally. Verify eligibility and enrollment proof before submitting.
