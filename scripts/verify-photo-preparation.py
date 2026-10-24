#!/usr/bin/env python3
"""Verify actual photo preparation in a provided, already booted iOS Simulator.

Example from the repository root:
  python3 scripts/verify-photo-preparation.py --simulator UUID \
      --output /absolute/path/outside/repository/new-check-folder

No app install, app lifecycle, UI action, model, network or production-data access.
No copied production implementation is committed: the actual enum is extracted
byte-for-byte at runtime and compiled with only the procedural Swift fixtures.
"""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import uuid


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", required=True, help="UUID of an already booted iOS Simulator")
    parser.add_argument("--output", type=Path, required=True, help="New output directory outside the repository")
    args = parser.parse_args()
    try:
        simulator = str(uuid.UUID(args.simulator)).upper()
    except ValueError:
        parser.error("--simulator must be a UUID")
    repository = Path(__file__).resolve().parents[1]
    output = args.output.expanduser().resolve()
    if output == repository or repository in output.parents:
        parser.error("--output must be outside the repository and submission package")
    if output.exists():
        parser.error("Refusing an existing output path; use a new directory")
    output.mkdir(parents=True, exist_ok=False)
    source_path = repository / "MealMirror.swiftpm/MealAnalysisEngine.swift"
    fixture_path = repository / "scripts/verify-photo-preparation.swift"
    source = source_path.read_bytes()
    fixture = fixture_path.read_bytes()
    start_marker = b"enum MealPhotoPreparation {"
    end_marker = b"\nenum VisionPhotoInspector {"
    if source.count(start_marker) != 1 or source.count(end_marker) != 1:
        raise RuntimeError("Preparation enum boundaries changed; review extraction before running")
    start = source.index(start_marker)
    end = source.index(end_marker, start)
    block = source[start:end]
    if not block.rstrip().endswith(b"}"):
        raise RuntimeError("Preparation enum extraction is incomplete")
    (output / "actual-enum.swift.txt").write_bytes(block)
    imports = b"import CoreImage\nimport Foundation\nimport ImageIO\nimport UIKit\n\n"
    extracted = output / "ActualMealPhotoPreparation.swift"
    extracted.write_bytes(imports + block + b"\n")
    fixture_copy = output / "PhotoPreparationFixtures.swift"
    fixture_copy.write_bytes(fixture)
    protocol = {
        "schemaVersion": 1,
        "recordedAtUTC": dt.datetime.now(dt.timezone.utc).isoformat(),
        "scope": "Source-derived direct iOS Simulator process; no production app install, lifecycle, UI, model, network or production data.",
        "sourceFile": "MealMirror.swiftpm/MealAnalysisEngine.swift",
        "sourceFileSHA256": sha(source),
        "exactEnumSHA256": sha(block),
        "fixtureFile": "scripts/verify-photo-preparation.swift",
        "fixtureSHA256": sha(fixture),
        "driverSHA256": sha(Path(__file__).read_bytes()),
        "extraction": "Byte-identical actual enum; imports prefixed outside the enum for standalone compilation. Fixture copied unchanged. No implementation substitutions.",
        "geometry": {"caseCount": 64, "sourcePixels": [1920, 1280],
                     "origins": [[0, 0], [100, -50], [100.25, 50.5], [-100.25, -50.5]],
                     "orientationRawValues": list(range(8)), "scales": [1, 2], "pixelLimit": 768,
                     "cornerComponentTolerance": 12, "referenceDistinctnessMinimum": 64,
                     "displayAspectDifferenceMaximum": 0.005},
        "additionalCases": {"mealAndLabelCallerLimits": 4, "publicConstructorScaleCases": 8,
                            "invalidExtentDataAndLimitCases": 7},
        "assertions": ["All geometry/caller cases produce positive CGImage dimensions within the requested bound.",
                       "Valid UIImage scales and orientation metadata are preserved.",
                       "Four opaque, distinct, orientation-aware reference corner samples and display aspect meet fixed tolerances.",
                       "Actually nonfinite/nonpositive image scales return nil on CI and CG paths; UIKit normalization of zero/negative requests is observed, not mistaken for an invalid actual scale.",
                       "Infinite/empty CI extents, invalid image data and invalid maximum sizes return nil."],
        "limits": ["Corner sampling is not full pixel equivalence or off-center marker coverage.",
                   "Procedural fixtures are not real camera/Photos decoder or memory/performance evaluation.",
                   "No exact-app UI, physical device, model accuracy, offline isolation or OS compute-cancellation claim."],
        "execution": "One standalone process, 20-second process watchdog and 30-second host timeout; no retries."
    }
    write_json(output / "protocol.json", protocol)

    def run(stage: str, argv: list[str], timeout: int = 30) -> subprocess.CompletedProcess[str]:
        started = dt.datetime.now(dt.timezone.utc).isoformat()
        try:
            result = subprocess.run(argv, capture_output=True, text=True, timeout=timeout)
            (output / f"{stage}.stdout.log").write_text(result.stdout)
            (output / f"{stage}.stderr.log").write_text(result.stderr)
            write_json(output / f"{stage}.json", {"argv": argv, "startedAtUTC": started,
                "finishedAtUTC": dt.datetime.now(dt.timezone.utc).isoformat(),
                "exitCode": result.returncode, "attemptCount": 1,
                "stdout": f"{stage}.stdout.log", "stderr": f"{stage}.stderr.log"})
        except subprocess.TimeoutExpired as error:
            write_json(output / f"{stage}.json", {"argv": argv, "startedAtUTC": started,
                "timedOut": True, "timeoutSeconds": timeout, "attemptCount": 1})
            raise RuntimeError(f"{stage} exceeded its timeout") from error
        if result.returncode:
            raise RuntimeError(f"{stage} failed ({result.returncode}); inspect retained logs")
        return result

    devices = json.loads(run("simulator-list", ["xcrun", "simctl", "list", "devices", "--json"]).stdout)
    matches = [(runtime, device) for runtime, entries in devices["devices"].items() for device in entries
               if device["udid"].upper() == simulator]
    if len(matches) != 1 or matches[0][1]["state"] != "Booted" or not matches[0][1].get("isAvailable"):
        raise RuntimeError("The provided Simulator must already be available and booted; no device state was changed")
    if ".iOS-" not in matches[0][0]:
        raise RuntimeError("The provided Simulator must use an iOS runtime")
    sdk = run("sdk-path", ["xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"]).stdout.strip()
    binary = output / "verify-photo-preparation-ios"
    run("compile", ["xcrun", "--sdk", "iphonesimulator", "swiftc", "-swift-version", "6",
        "-parse-as-library", "-sdk", sdk, "-target", "arm64-apple-ios17.0-simulator",
        "-module-cache-path", str(output / "ModuleCache"), str(extracted), str(fixture_copy), "-o", str(binary)])
    macho = run("binary-platform", ["xcrun", "vtool", "-show-build", str(binary)]).stdout
    if "IOSSIMULATOR" not in macho:
        raise RuntimeError("Compiled binary is not marked IOSSIMULATOR")
    report_path = output / "results.json"
    execution = run("execute", ["xcrun", "simctl", "spawn", simulator, str(binary), str(report_path)])
    report = json.loads(report_path.read_text())
    counts = {"geometryCaseCount": 64, "callerLimitCaseCount": 4,
              "malformedScaleCaseCount": 8, "invalidInputCaseCount": 7, "failureCount": 0}
    if report.get("phase") != "completed" or any(report.get(key) != value for key, value in counts.items()):
        raise RuntimeError("Result phase/count/assertion check failed; inspect results.json")
    if source_path.read_bytes() != source or fixture_path.read_bytes() != fixture:
        raise RuntimeError("Source or fixture changed during verification; results cannot certify current bytes")
    if extracted.read_bytes() != imports + block + b"\n" or fixture_copy.read_bytes() != fixture:
        raise RuntimeError("Standalone inputs changed during verification")
    write_json(output / "verification.json", {"phase": "completed", "passed": True,
        "sourceFileSHA256": sha(source), "exactEnumSHA256": sha(block),
        "fixtureSHA256": sha(fixture), "binarySHA256": sha(binary.read_bytes()),
        "protocolSHA256": sha((output / "protocol.json").read_bytes()),
        "resultsSHA256": sha(report_path.read_bytes()), "counts": counts,
        "runtimeIdentifier": matches[0][0], "simulatorName": matches[0][1]["name"],
        "scope": protocol["scope"], "limits": protocol["limits"], "attemptCount": 1})
    print(execution.stdout.strip())
    print(f"Evidence: {output}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"Photo preparation verification failed: {error}", file=sys.stderr)
        sys.exit(1)
