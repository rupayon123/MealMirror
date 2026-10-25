#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scratch="$(mktemp -d "${TMPDIR:-/tmp}/mealmirror-range-check.XXXXXX")"
trap 'rm -rf "$scratch"' EXIT

xcrun swiftc -swift-version 6 -parse-as-library \
    "$repo_root/MealMirror.swiftpm/MealCore/MealModels.swift" \
    "$repo_root/scripts/RangeDecodingChecks.swift" \
    -o "$scratch/range-checks"
"$scratch/range-checks"
