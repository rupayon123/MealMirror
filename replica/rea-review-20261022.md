# REA evidence review — October 22, 2026

## Result and scope

REA **6.7.0** was used to statically inspect MealMirror's archived app. Its artifact inventory completed successfully. REA's separate macOS plist and Mach-O helpers timed out; their failures are retained and are not passing evidence. Public RxFood HTML supplied product facts only. This work did not inspect RxFood's native app, models, private APIs, account, traffic, or executable JavaScript.

The verified upstream is [morluto/rea](https://github.com/morluto/rea), linked from [rea.tools](https://rea.tools). The isolated npm installation lives outside this repository at `../../tools/rea`; lifecycle scripts were disabled. The installed package and lockfile identify `rea-agents@6.7.0`, repository `git+https://github.com/morluto/rea.git`, and npm integrity:

```text
sha512-yhIx2ioJYYT1C/tONfYeitC6LhnKmCh+ZwRUOgYuhSc733lGhkkt73zhug9WmLgxoMdKuqIYGCoBfD4fXkOhFw==
```

Node 22.23.1 satisfies its engine range. Installation occupied approximately 242 MiB including the isolated npm cache. No REA setup, MCP registration, global skill, native analysis engine, or account was configured.

## Commands and retained evidence

Raw output is outside the repository in `../../outputs/rea-rxfood-20261022/`. With `WORKSPACE` set to the containing workspace, equivalent commands are:

```sh
npm install --prefix "$WORKSPACE/tools/rea" --cache "$WORKSPACE/tools/rea/npm-cache" --ignore-scripts --no-audit --no-fund --save-exact rea-agents@6.7.0
REA_CLI="$WORKSPACE/tools/rea/node_modules/rea-agents/scripts/rea.mjs"
MM_APP="$WORKSPACE/outputs/license-cleared-20261022/MealMirror-2.xcarchive/Products/Applications/MealMirror.app"
node "$REA_CLI" --version
node "$REA_CLI" --help
node "$REA_CLI" inspect-artifact --schema
node "$REA_CLI" inspect-artifact "$MM_APP" --format json --full-output
node "$REA_CLI" inspect-plist "$MM_APP" --format json --full-output
node "$REA_CLI" inspect-macho "$MM_APP/MealMirror" --format json --full-output
```

The first schema attempt used `inventory-artifact`, which this CLI does not expose; its error was retained before selecting the documented `inspect-artifact` command. The two public pages were fetched once each with `curl --max-time 30 --max-filesize 5242880 --fail --silent --show-error --location`, saved as HTML, and read with a parser that ignores script/style content. No downloaded target code ran.

| Evidence | SHA-256 |
| --- | --- |
| REA `mealmirror-artifact.json` | `24029e6a2631c607e01e8a6b451d8d6b5411b65f96693649140eb5ebe9bf0718` |
| App executable `MealMirror` | `8b4b8d434aa2961815d2279bb8ed4675bea2655560e972a8bd3ac68770fa3da1` |
| App `Info.plist` | `e26f2d661418b4fca888565785c291c7470fc276c7e6045059bec5766c9cb1a4` |
| `rxfood-dexcom.html` — 231,284 bytes | `b979c59323dcf8722dc5c4747be43e0997b88b4e035d3b4c5d3c272f6bbf5230` |
| `rxfood-patient.html` — 120,089 bytes | `7f63a5dc81f68f76cb500fceb4c92da08d64b42f22ef59cc43602eaaf07cd515` |

`evidence-manifest.json` records raw-file hashes and sizes; `mealmirror-plist.json` and `mealmirror-macho.json` retain failures. `native-helper-cleanup.txt` records that all six reported helper PIDs were absent at the subsequent check; no process was signaled.

## What the evidence establishes

- REA's `rea-artifact-graph` provider inventoried **71 nodes/occurrences and 70 edges**, reporting complete container-entry coverage and no integrity contradictions. Its directory identity is `0de88c869a5902a48da7245a51b05d209ea8ba37d1dcedf7254b9878f8c6d057`; graph identity is `6861858edbe25c4ad314990fbb26629437e9f1ae9416b0be0dbb12ac47828c91`. These are REA's directory/graph identities, not the Challenge ZIP checksum or an Apple signature verification.
- That exact app contains `Info.plist`, `PrivacyInfo.xcprivacy`, a Mach-O executable, fonts, three bundled practice-meal photos, `app_strings.json`, and **18 localization resource directories**. A separate direct `plistlib` read confirms version 1.0/build 2, minimum iOS 17, iPhone/iPad families, and 18 declared localizations. Resource presence does not establish translation quality or runtime accessibility.
- The [RxFood Dexcom page](https://rxfood.com/dexcom) advertises estimated food/portion/net-carbohydrate results, a food/glucose timeline with optional insulin and exercise entries, and glucose-range filtering. It requires Dexcom account sign-in and expressly excludes its carbohydrate estimates from treatment or dosing use. These are vendor claims, not independently measured accuracy or observed app screens.
- The [RxFood patient page](https://rxfood.com/patient) describes invitation/prescription access and acknowledges that hidden contents in wraps, smoothies, and some homemade soups limit photo interpretation. The [current App Store listing](https://apps.apple.com/us/app/rxfood/id1482235880) declares English/French and does not declare accessibility capabilities. That omission is not evidence that accessibility is absent.

## Prioritized MealMirror work

1. **Prove the offline correction loop on the exact package.** Measure photo → uncertainty/unknown → user confirmation → saved review without an account or network. Include denied permissions and unavailable analysis. Static packaging cannot establish this behavior.
2. **Make mixed-food recovery easy.** Use the existing extra food views, nutrition-label slot, and meal description to ask for information a photo cannot reveal. Keep every visual clue excluded until confirmed and retain the source of each entered carbohydrate value. Evaluate wraps, soups, smoothies, mixed dishes, and varied cuisines without claiming arbitrary-meal accuracy.
3. **Add recent-meal reuse after confirmation provenance is preserved.** Reuse a person's verified food choices as a fresh editable review; require them to reconfirm portions/current package values. This is already an open row in `features.csv` and a concrete route to lower repeated-entry effort.
4. **Turn localization resources into verified usability.** Check all 18 choices for missing strings, formatting, VoiceOver order, large text, and right-to-left layout. The relevant comparison is measured completion/comprehension, not the number of resource folders.
5. **Keep CGM connections truthful and separate from offline claims.** Public vendor-supported access and real consent remain prerequisites. A bundled demo must not imply a live Dexcom/Libre connection or calculated insulin advice.

No feature-matrix completion state changed: this investigation adds static artifact evidence and refreshed public facts, not runtime feature validation or proof of superiority.

## Provider limitation

Both native-helper commands exited 1 after a 60,000 ms operation timeout and reported `cleanup_incomplete` / `platform_binary_environment_withheld`. REA supplied no plist or Mach-O findings from those commands. No further native-provider request was made. The successful artifact provider does not parse all resource semantics, execute the app, validate meal recognition, establish clinical safety, prove offline network behavior, or verify Apple signing. Website HTML is not RxFood's shipped native app.
