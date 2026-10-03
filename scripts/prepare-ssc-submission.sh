#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_dir="$repo_root/MealMirror.swiftpm"
output_path="${1:-$repo_root/build/MealMirror-SSC2027.zip}"
if [[ "$output_path" != /* ]]; then
    output_path="$repo_root/$output_path"
fi
output_dir="$(dirname "$output_path")"
output_name="$(basename "$output_path")"

if [[ ! -f "$package_dir/Package.swift" || ! -f "$package_dir/Resources/app_strings.json" ]]; then
    echo "MealMirror.swiftpm is missing required package files." >&2
    exit 1
fi

mkdir -p "$output_dir"
temporary_dir="$(/usr/bin/mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT
submission_dir="$temporary_dir/MealMirror.swiftpm"
/usr/bin/ditto "$package_dir" "$submission_dir"

find "$submission_dir" -name .DS_Store -type f -delete
find "$submission_dir" -name xcuserdata -type d -prune -exec rm -rf {} +
find "$submission_dir/Resources" -mindepth 1 -maxdepth 1 -type d -name '*.lproj' ! -name 'en.lproj' -exec rm -rf {} +

python3 - "$submission_dir" <<'PY'
import json
import plistlib
import sys
from pathlib import Path

package = Path(sys.argv[1])
strings_path = package / "Resources" / "app_strings.json"
with strings_path.open(encoding="utf-8") as stream:
    catalog = json.load(stream)
if "en" not in catalog:
    raise SystemExit("English localization is missing.")
strings_path.write_text(json.dumps({"en": catalog["en"]}, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")

plist_path = package / "Info.plist"
with plist_path.open("rb") as stream:
    info = plistlib.load(stream)
info["CFBundleLocalizations"] = ["en"]
with plist_path.open("wb") as stream:
    plistlib.dump(info, stream, sort_keys=False)
PY

temporary_archive="$temporary_dir/$output_name"
(
    cd "$temporary_dir"
    /usr/bin/zip -q -r "$temporary_archive" MealMirror.swiftpm
)

archive_bytes="$(/usr/bin/stat -f%z "$temporary_archive")"
if (( archive_bytes > 26214400 )); then
    echo "Archive is larger than Apple's currently published 25 MB limit." >&2
    exit 1
fi

python3 - "$temporary_archive" <<'PY'
import json
import stat
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as archive:
    names = archive.namelist()
    if len(names) != len(set(names)):
        raise SystemExit("Archive contains duplicate paths.")
    if "MealMirror.swiftpm/Package.swift" not in names:
        raise SystemExit("Archive is missing the Swift package.")
    for entry in archive.infolist():
        name = entry.filename
        if not name.startswith("MealMirror.swiftpm/") or ".." in name.split("/"):
            raise SystemExit(f"Unexpected archive path: {name}")
        if stat.S_ISLNK(entry.external_attr >> 16):
            raise SystemExit(f"Archive contains a symbolic link: {name}")
        if any(part in {".git", "xcuserdata", ".DS_Store"} for part in name.split("/")):
            raise SystemExit(f"Archive contains development state: {name}")
        if ".lproj" in name and "Resources/en.lproj/" not in name:
            raise SystemExit(f"Archive contains a non-English localization: {name}")
    catalog = json.loads(archive.read("MealMirror.swiftpm/Resources/app_strings.json"))
    if set(catalog) != {"en"}:
        raise SystemExit("Archive contains non-English catalog entries.")
    bad_member = archive.testzip()
    if bad_member is not None:
        raise SystemExit(f"Archive integrity check failed: {bad_member}")
PY

mv -f "$temporary_archive" "$output_path"
echo "Created $output_path ($archive_bytes bytes)."
