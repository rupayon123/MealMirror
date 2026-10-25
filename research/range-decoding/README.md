# Saved carbohydrate range decoding

Build 14 rejects negative or reversed saved bounds. Synthesized `Codable` previously bypassed the constructor's nonnegative/ordered checks: an exact-source baseline accepted both malformed cases, while a valid range decoded normally. The unchanged probe now rejects both malformed cases and preserves the valid control.

Existing valid `low`/`high` JSON keeps its format. The normal constructor still normalizes values as before; decoding rejects damaged input instead of silently changing a checked amount. Existing store guards stop save/delete writes on unreadable history, and the History error branch shows **Review needed**. That caller behavior was reviewed in source, not newly executed on a real store. One malformed range blocks reading the array until explicit user action; no automatic deletion or repair was added.

Run the portable regression on a Mac with Xcode:

```sh
bash scripts/verify-range-decoding.sh
```

It passed 532 model checks, including all 501 manual whole-gram values from 0 through 500. These are model/schema checks, not nutrition, clinical or app-wide acceptance. The first expanded test harness failed to compile because of a throwing call inside a nonthrowing autoclosure; that retained harness error was corrected separately.

The [delivery receipt](delivery-20261025-build14.json) records the exact ZIP, clean Simulator build, signed archive, internal-only upload processing, independent review and remaining gates. Build 14 has no fresh native full-app journey. The separate encoded-data attempt on an existing processing QA target reached neither its expected argument-guard result nor any image case; its warning/timeouts and preservation checks remain retained.
