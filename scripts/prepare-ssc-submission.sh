#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_path="$repo_root/build/MealMirror-SSC2027.zip"
if (( $# > 0 )); then
    output_path="$1"
fi

python3 - "$repo_root" "$output_path" <<'PY'
import hashlib
import json
import os
import plistlib
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

repo = Path(sys.argv[1])
output = Path(sys.argv[2])
if not output.is_absolute():
    output = repo / output
if output.suffix.lower() != ".zip":
    raise SystemExit("The submission output must be a .zip file.")

package_name = "MealMirror.swiftpm"
fixed_time = (1980, 1, 1, 0, 0, 0)
size_limit = 25_000_000  # Safe under either interpretation of Apple's 25 MB limit.
required = {
    "Package.swift",
    "Info.plist",
    "README.md",
    "AI-AND-ASSET-DISCLOSURE.md",
    "Resources/app_strings.json",
    "Resources/PrivacyInfo.xcprivacy",
    "Resources/en.lproj/InfoPlist.strings",
    "Resources/en.lproj/Localizable.strings",
    "Assets/biryani-demo.png",
    "Assets/grain-bowl-demo.png",
    "Assets/breakfast-demo.png",
    "Fonts/PixelifySans.ttf",
    "Fonts/PixelifySans-OFL.txt",
    "Fonts/Nunito.ttf",
    "Fonts/Nunito-OFL.txt",
}


def include(path: Path) -> bool:
    parts = path.parts
    if any(part.startswith(".") for part in parts):
        # Xcode's .swiftpm workspace and other local development state are regenerated.
        return False
    if len(parts) == 1:
        return path.name in {"Package.swift", "Info.plist", "README.md", "AI-AND-ASSET-DISCLOSURE.md"} or path.suffix == ".swift"
    if parts[0] in {"MealCore", "NavigationCore", "OnboardingCore"}:
        return path.suffix == ".swift"
    if parts[0] == "Assets":
        return path.suffix.lower() in {".png", ".jpg", ".jpeg", ".json"}
    if parts[0] == "Fonts":
        return path.suffix.lower() in {".ttf", ".txt"}
    if parts[0] == "Resources":
        if len(parts) > 1 and parts[1].endswith(".lproj"):
            if parts[1] != "en.lproj":
                return False
            return path.name in {"InfoPlist.strings", "Localizable.strings"}
        return path.as_posix() in {"Resources/app_strings.json", "Resources/PrivacyInfo.xcprivacy"}
    return False


# Git selects the package paths; their bytes come from the current working tree.
# Newly added assets must be staged before they can enter a candidate ZIP.
result = subprocess.run(
    ["git", "-C", str(repo), "ls-files", "-z", "--", package_name],
    check=True,
    capture_output=True,
)
tracked = [os.fsdecode(path) for path in result.stdout.split(b"\0") if path]
if not tracked:
    raise SystemExit("No tracked Swift playground files were found.")

files = {}
for tracked_path in tracked:
    parts = tracked_path.split("/")
    if parts[0] != package_name or any(part in {"", ".", ".."} for part in parts):
        raise SystemExit(f"Unexpected tracked path: {tracked_path}")
    source = repo.joinpath(*parts)
    current = source
    while current != repo:
        if current.is_symlink():
            raise SystemExit(f"Symbolic links are not allowed in the playground: {tracked_path}")
        current = current.parent
    if not source.is_file():
        raise SystemExit(f"Tracked playground file is missing: {tracked_path}")
    relative = Path(*parts[1:])
    if include(relative):
        files[relative.as_posix()] = source.read_bytes()
    elif not (
        relative.parts[0] == ".swiftpm"
        or (
            relative.parts[0] == "Resources"
            and len(relative.parts) > 1
            and relative.parts[1].endswith(".lproj")
            and relative.parts[1] != "en.lproj"
        )
    ):
        raise SystemExit(f"Review the unexpected playground file before packaging: {tracked_path}")

missing = sorted(required - files.keys())
if missing:
    raise SystemExit(f"Required playground files are missing: {', '.join(missing)}")

catalog = json.loads(files["Resources/app_strings.json"])
if not isinstance(catalog, dict) or not isinstance(catalog.get("en"), dict) or not catalog["en"]:
    raise SystemExit("The English string catalog is missing or empty.")
files["Resources/app_strings.json"] = (
    json.dumps({"en": catalog["en"]}, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
).encode("utf-8")

info = plistlib.loads(files["Info.plist"])
info["CFBundleLocalizations"] = ["en"]
files["Info.plist"] = plistlib.dumps(info, sort_keys=False)

for name, data in files.items():
    if ".xcassets/" not in name or not name.endswith("/Contents.json"):
        continue
    manifest = json.loads(data)
    for entry in manifest.get("images", []):
        filename = entry.get("filename")
        if filename and (Path(name).parent / filename).as_posix() not in files:
            raise SystemExit(f"Asset catalog references a missing image: {name}: {filename}")

member_names = {f"{package_name}/{name}" for name in files}
directories = {f"{package_name}/"}
for member in member_names:
    parent = Path(member).parent
    while str(parent) != ".":
        directories.add(parent.as_posix() + "/")
        parent = parent.parent


def zip_info(name: str, directory: bool) -> zipfile.ZipInfo:
    item = zipfile.ZipInfo(name, fixed_time)
    item.create_system = 3
    item.compress_type = zipfile.ZIP_STORED if directory else zipfile.ZIP_DEFLATED
    item.external_attr = ((0o40755 if directory else 0o100644) << 16) | (0x10 if directory else 0)
    return item


output.parent.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory(prefix=".ssc-package-", dir=output.parent) as temporary:
    archive_path = Path(temporary) / "candidate.zip"
    with zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name in sorted(directories | member_names):
            directory = name.endswith("/")
            archive.writestr(
                zip_info(name, directory),
                b"" if directory else files[name[len(package_name) + 1:]],
            )

    archive_bytes = archive_path.stat().st_size
    if archive_bytes > size_limit:
        raise SystemExit(f"Archive is {archive_bytes} bytes, above the 25 MB limit.")

    with zipfile.ZipFile(archive_path) as archive:
        expected = sorted(directories | member_names)
        if archive.namelist() != expected:
            raise SystemExit("Archive member list differs from the prepared playground.")
        if archive.testzip() is not None:
            raise SystemExit("Archive integrity check failed.")
        if set(json.loads(archive.read(f"{package_name}/Resources/app_strings.json"))) != {"en"}:
            raise SystemExit("Archive contains non-English catalog entries.")
        if plistlib.loads(archive.read(f"{package_name}/Info.plist"))["CFBundleLocalizations"] != ["en"]:
            raise SystemExit("Archive declares non-English localizations.")

    digest = hashlib.sha256(archive_path.read_bytes()).hexdigest()
    os.replace(archive_path, output)

print(f"Created {output} ({archive_bytes} bytes, SHA-256 {digest}).")
PY
