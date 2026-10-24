# Photo-load invalidation checks

Recorded October 24, 2026. This is a native Mac Foundation check of extracted loading methods, using declared transfer/preparation spies. Source, method, script, fixture, protocol and result hashes are in [the evidence record](invalidation-20261024.json). Raw artifacts remain outside the repository and submission package.

## Reproduction and correction

The frozen baseline completed eight cases and 36 checks, with **three failed expectations across two cases**. After invalidation during the first transfer, the old batch still requested preparation for that item and transfer/preparation for its remaining items. Invalidation during preparation also allowed later items to start. Existing guards already protected the newer batch from stale appends, errors and busy-state writes.

The correction checks the token before each transfer, between transfer and preparation, and after preparation. The same frozen cases, ordering and expectations then passed **36/36**, with compile and execution exits 0. The baseline's execution exit 1 and failures are preserved. Active food/label success, failure handling and forwarded size-limit arguments remained correct.

## Reusable check

Run from the repository root with a new directory outside the checkout:

```sh
python3 scripts/verify-photo-load.py --output /path/outside/repository/new-check
```

The [driver](../../scripts/verify-photo-load.py) extracts the current methods byte-identically. Its only method instrumentation is an outer Task-handle assignment for awaiting completion; each actual Task expression/closure remains unchanged. The [fixture](../../scripts/verify-photo-load.swift) contains the declared spies and frozen checks, without a production loading implementation copy. Actor witnesses and continuation releases control ordering; there are no ordering sleeps. A separate existing-output invocation exited 2 before compilation/execution and left the prior receipt unchanged.

## Limits

These are ID-only transfer, image and preparation spies. The append spy records IDs/role and reproduces only token invalidation/busy clearing, not full app state. This does not exercise PhotosUI/UIKit, real decoding, camera authorization, SwiftUI state lifetime, navigation/disappearance or physical devices. Preventing later work does not interrupt work already in progress. No measured memory/performance improvement is established; the [earlier preparation memory limitation](../photo-preparation/README.md) remains open. This is unit evidence, not an app-package or distribution check.

## Exact build-6 delivery

The separate [delivery receipt](delivery-20261024.json) records the deterministic English-only ZIP, clean arm64 Simulator build/install/launch, four initial Welcome viewports and matching signed archive/internal-only upload. Apple reports processing; server compliance, internal status, existing-group Testing and phone installation remain unverified. The method-level checks above do not supply that package or distribution evidence.

## Meal-entry exit guard, build 7

[Teardown source evidence](teardown-20261024.md) records five fixed native surrogate cases/30 checks, with 17 overlapping original failures and zero candidate failures. It does not establish actual SwiftUI state lifetime or camera/navigation sequencing. [Build-7 delivery](teardown-delivery-20261024.json) separately records the exact package and testing scope.
