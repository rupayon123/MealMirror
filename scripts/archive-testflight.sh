#!/bin/bash
set -euo pipefail

if (( $# != 2 )) || [[ "$1" != /*.xcarchive ]]; then
    echo "Usage: $0 /absolute/path/MealMirror.xcarchive APPLE_TEAM_ID" >&2
    exit 2
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
archive_path="$1"
team_id="$2"
if [[ -e "$archive_path" || -L "$archive_path" ]]; then
    echo "Archive output already exists; choose a new path to preserve its evidence." >&2
    exit 2
fi
sdk_version="$(xcrun --sdk iphoneos --show-sdk-version)"

cd "$repo_root/MealMirror.swiftpm"
# Xcode 27.1's Swift product link passes --sysroot to Clang. Its Darwin SDK
# metadata lookup needs -isysroot as well. Scope this to final products so
# package-core clang -r links do not receive Swift-only driver arguments.
xcodebuild -scheme MealMirror -destination 'generic/platform=iOS' \
    -archivePath "$archive_path" -jobs 1 \
    DEVELOPMENT_TEAM="$team_id" CODE_SIGN_STYLE=Automatic \
    'PRODUCT_SPECIFIC_LDFLAGS=$(inherited) -Xclang-linker -isysroot -Xclang-linker $(SDKROOT)' \
    -allowProvisioningUpdates archive

app_path="$archive_path/Products/Applications/MealMirror.app"
codesign --verify --deep --strict "$app_path"
python3 - "$app_path" "$sdk_version" <<'PY'
import plistlib
import re
import subprocess
import sys
from pathlib import Path

app = Path(sys.argv[1])
expected_sdk = sys.argv[2]
info = plistlib.loads((app / "Info.plist").read_bytes())
if info.get("CFBundleIdentifier") != "com.mealmirror.swiftchallenge":
    raise SystemExit("Unexpected archive bundle identifier.")

header = subprocess.check_output(
    ["xcrun", "vtool", "-show-build", str(app / info["CFBundleExecutable"])],
    text=True,
)

def version(value):
    parts = [int(part) for part in value.split(".")]
    while parts and parts[-1] == 0:
        parts.pop()
    return tuple(parts)

recorded_sdks = re.findall(r"^\s+sdk\s+([\d.]+)\s*$", header, re.MULTILINE)
minimums = re.findall(r"^\s+minos\s+([\d.]+)\s*$", header, re.MULTILINE)
if not recorded_sdks or any(version(v) != version(expected_sdk) for v in recorded_sdks):
    raise SystemExit(f"Executable SDK does not match the selected iPhoneOS SDK: {header}")
if not minimums or any(version(v) != version(info["MinimumOSVersion"]) for v in minimums):
    raise SystemExit(f"Executable deployment target does not match Info.plist: {header}")
if info.get("DTSDKName") != f"iphoneos{expected_sdk}":
    raise SystemExit("Info.plist SDK does not match the selected iPhoneOS SDK.")
print(
    f"Verified MealMirror {info['CFBundleShortVersionString']} ({info['CFBundleVersion']}): "
    f"iOS {info['MinimumOSVersion']} minimum, built with iOS {expected_sdk} SDK."
)
print("Archive only; upload separately after reviewing its evidence.")
PY
