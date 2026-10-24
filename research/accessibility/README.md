# Focused accessibility checks

Recorded October 24, 2026. These are bounded checks, not full accessibility acceptance. [The evidence record](loading-and-welcome-20261024.json) preserves source, protocol, results and screenshot hashes.

## Loading-text contrast

The translucent light-mode launch tagline measured **2.9214:1**, below even the large-text 3:1 threshold. Four loading text roles now use the theme’s existing opaque adaptive ink. All eight source-color pairs meet the chosen conservative **4.5:1** target: light **4.5181:1**, dark **8.0927:1**. Fonts, background colors and artwork are unchanged.

The [source checker](../../scripts/verify-loading-contrast.py) reads the selected foreground styles and color tokens. Independent manual source review confirms their loading-background pairing for this snapshot; it does not parse arbitrary SwiftUI ancestry or opacity. W3C permits lower contrast for large text, so the other opaque bold baseline roles are not blanket WCAG failures. See [W3C’s contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html). Rendered loading text, anti-aliasing and animation behavior remain unverified.

```sh
python3 scripts/verify-loading-contrast.py
```

## Exact build-6 Welcome

The actual English-only ZIP app was inspected in four initial viewports on the separate iOS 27.1 Duo: light/dark, each at standard Large and the system’s maximum accessibility text size. Runtime options were read back before capture; this was not a SwiftUI-only font override. The photo action was visible without action clipping in every frame. At maximum size it reads **Photo**, while the title/body visibly enlarge and wrap.

Body, safety and legal content can extend below the scroll viewport. No tapping, scrolling, direct VoiceOver, precise audit of every custom-font metric, all-screen, iPad/RTL or physical-device pass follows from these frames. The original interactive Photos picker session was preserved. A short earlier build-5 video only captured startup artwork in the inspected frames and supplies no SwiftUI loading or smoothness proof.
