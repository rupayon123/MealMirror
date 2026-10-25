#!/usr/bin/env python3
"""Verify current photo-load invalidation mechanics with declared native Mac spies.

Run from the repository root:
  python3 scripts/verify-photo-load.py --output /path/outside/repository/new-check

Requires a Mac with Swift 6. No Simulator, PhotosUI/UIKit, images, models, UI,
production data or network. The committed fixture contains no production loading
implementation: this driver extracts the current methods byte-for-byte at run time.
"""
from __future__ import annotations

import argparse
import datetime as dt
import difflib
import hashlib
import json
from pathlib import Path
import subprocess
import sys


BASELINE_PROTOCOL_SHA256 = "5d2674bdfd9af0ec51a8798c84c59fb03cab49fbb98eafe0773897deb93eca5d"
FROZEN_FIXTURE_BODY_SHA256 = "95ca37322bae73d7f00200d98e8a9c9cd30b7e34ab1eb1317738e1dae9a23057"
CASE_CONTRACT = json.loads(r'''{
  "scope": "Foundation-only native Mac deterministic photo loading algorithm mechanics with declared transfer, image, preparation and append spies. No Simulator, UIImage/CoreImage implementation, image decoding, model, UI lifecycle, production data or memory/performance proof.",
  "instrumentation": "One external outer capturedTask = assignment before the original Task expression; entire Task expression/closure and following function bytes unchanged. invalidatePendingPhotoLoad copied exactly.",
  "declaredSpies": {
    "PhotosPickerItem": "Transfers are fixed per ID and may await explicit continuations, return encoded ID Data, nil or throw. No PhotosUI or real image.",
    "UIImage": "Sendable ID-only value.",
    "MealPhotoPreparation": "Records ID/maxPixelSize, then fixed success/nil behind explicit continuations. Does not decode images.",
    "appendPersonalPhotos": "Records IDs/role and calls the actual invalidatePendingPhotoLoad, matching the downstream token/busy reset contract only. Does not exercise capacity, localization, inputSource, picker clearing or SwiftUI bindings.",
    "cancelPendingAnalysis": "No-op outside the loading algorithm; no model/analysis task."
  },
  "frozenCases": [
    {
      "id": "invalidatedDuringTransfer_completedB",
      "sequence": "Hold A1 transfer in three-item A; invalidate A; complete B; release A1; await A.",
      "expect": [
        "No A1 decode starts after invalidation during transfer.",
        "No transfer or decode starts for A2/A3.",
        "Only B appends; no stale state write/error/busy reset changes completed B."
      ]
    },
    {
      "id": "invalidatedDuringDecode_activeB",
      "sequence": "A1 transfer succeeds; hold A1 decode; invalidate A; start B and hold B transfer; release A1; await A; inspect B; release/await B.",
      "expect": [
        "Already-started A1 decode may finish; no A2/A3 transfer or decode starts.",
        "A never appends; active B retains busy=true and no stale state writes/error.",
        "After release B completes and is the only appended batch."
      ]
    },
    {
      "id": "staleTransferFailure_completedB",
      "sequence": "Hold failing A1 transfer; invalidate; complete B; release A1 failure.",
      "expect": [
        "No stale error/busy reset/append/state write after B completes.",
        "No A decode or A2/A3 transfer."
      ]
    },
    {
      "id": "staleDecodeFailure_completedB",
      "sequence": "Hold A1 decode returning nil; invalidate; complete B; release nil decode.",
      "expect": [
        "No stale error/busy reset/append/state write after B completes.",
        "No A2/A3 transfer/decode."
      ]
    },
    {
      "id": "activeFoodSuccess",
      "sequence": "Complete active two-item food batch.",
      "expect": [
        "Both images append in order once; busy clears; no error.",
        "Both preparation requests use1800."
      ]
    },
    {
      "id": "activeLabelSuccess",
      "sequence": "Complete active one-item label batch.",
      "expect": [
        "One label appends once; busy clears; no error.",
        "Preparation uses2400."
      ]
    },
    {
      "id": "activeTransferFailure",
      "sequence": "Active transfer throws.",
      "expect": [
        "No append/decode; busy clears; error is shown."
      ]
    },
    {
      "id": "activeDecodeFailure",
      "sequence": "Active decode returns nil.",
      "expect": [
        "No append; busy clears; error is shown; exactly one preparation."
      ]
    }
  ],
  "ordering": "Explicit actor witnesses and checked-continuation releases only; no sleeps used for ordering.",
  "bounds": {
    "processWatchdogSeconds": 20,
    "hostCompileTimeoutSeconds": 30,
    "hostRunTimeoutSeconds": 30
  },
  "failurePolicy": "Write complete raw JSON then exit1 if any frozen expectation fails. Baseline failures are retained, not edited into passes. No retries.",
  "knownLimits": [
    "No actual SwiftUI @State lifetime, NavigationStack disappearance, camera authorization, picker behavior, decoding cancellation, OS compute cancellation or physical-device result.",
    "Stopping future spy requests is distinct from interrupting a transfer/decode already in flight."
  ]
}''')


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n")


def extract(source: bytes, start: bytes, end: bytes) -> bytes:
    if source.count(start) != 1 or source.count(end) != 1:
        raise RuntimeError("Source method boundaries changed; review extraction before running")
    first = source.index(start)
    last = source.index(end, first)
    method = source[first:last]
    if method.count(b"    private func ") != 1 or not method.rstrip().endswith(b"}"):
        raise RuntimeError("Extraction is not one complete method")
    return method


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True, help="New output directory outside the repository")
    args = parser.parse_args()
    if sys.platform != "darwin":
        parser.error("This check requires native Mac Foundation and Swift 6")
    repository = Path(__file__).resolve().parents[1]
    output = args.output.expanduser().resolve()
    if output == repository or repository in output.parents:
        parser.error("--output must be outside the repository and submission package")
    if output.exists():
        parser.error("Refusing an existing output path; use a new directory")
    output.mkdir(parents=True, exist_ok=False)
    source_path = repository / "MealMirror.swiftpm/ContentView.swift"
    fixture_path = repository / "scripts/verify-photo-load.swift"
    driver_path = Path(__file__).resolve()
    source, fixture, driver = source_path.read_bytes(), fixture_path.read_bytes(), driver_path.read_bytes()
    body_start = fixture.index(b"import Darwin\n")
    if sha(fixture[body_start:]) != FROZEN_FIXTURE_BODY_SHA256:
        raise RuntimeError("Frozen fixture body changed; review case/order/expectation changes first")
    load = extract(source, b"    private func loadSelectedPhotos(", b"    private func selectDemo(")
    invalidate = extract(source, b"    private func invalidatePendingPhotoLoad()", b"    private func cancelPendingAnalysis()")
    task_line = b"        Task { @MainActor in"
    if load.count(task_line) != 1 or b"capturedTask" in load:
        raise RuntimeError("Expected exactly one uninstrumented loading Task")
    instrumented = load.replace(task_line, b"        capturedTask = Task { @MainActor in", 1)
    task_start = b"Task { @MainActor in"
    if load[load.index(task_start):] != instrumented[instrumented.index(task_start):]:
        raise RuntimeError("Task expression/closure identity was not preserved")
    marker = b"// __EXTRACTED_METHODS__"
    if fixture.count(marker) != 1:
        raise RuntimeError("Fixture insertion marker is not unique")
    assembled = fixture.replace(marker, instrumented + b"\n" + invalidate)
    (output / "loadSelectedPhotos.original.swift.txt").write_bytes(load)
    (output / "invalidatePendingPhotoLoad.original.swift.txt").write_bytes(invalidate)
    (output / "loadSelectedPhotos.instrumented.swift.txt").write_bytes(instrumented)
    (output / "verify-photo-load.swift").write_bytes(fixture)
    (output / "verify-photo-load.py").write_bytes(driver)
    assembled_path = output / "PhotoLoadProbe.swift"
    assembled_path.write_bytes(assembled)
    (output / "task-handle-only.diff").write_text("".join(difflib.unified_diff(
        load.decode().splitlines(True), instrumented.decode().splitlines(True),
        fromfile="actual-loadSelectedPhotos", tofile="external-task-handle-capture")))
    commit = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=repository, text=True).strip()
    contract_bytes = json.dumps(CASE_CONTRACT, sort_keys=True, separators=(",", ":")).encode()
    protocol = dict(CASE_CONTRACT)
    protocol.update({"schemaVersion": 1, "recordedAtUTC": dt.datetime.now(dt.timezone.utc).isoformat(),
        "sourceCommit": commit, "baselineFrozenProtocolSHA256": BASELINE_PROTOCOL_SHA256,
        "caseContractCanonicalSHA256": sha(contract_bytes), "expectedCaseCount": 8, "expectedCheckCount": 36,
        "source": {"repositoryRelativePath": "MealMirror.swiftpm/ContentView.swift",
                   "fileSHA256": sha(source), "loadSelectedPhotosSHA256": sha(load),
                   "invalidatePendingPhotoLoadSHA256": sha(invalidate)},
        "driverSHA256": sha(driver), "fixtureSHA256": sha(fixture),
        "frozenFixtureBodySHA256": FROZEN_FIXTURE_BODY_SHA256})
    write_json(output / "frozen-protocol.json", protocol)
    fidelity = {"sourceFileSHA256": sha(source), "originalLoadSHA256": sha(load),
        "originalInvalidationSHA256": sha(invalidate), "instrumentedLoadSHA256": sha(instrumented),
        "assembledSHA256": sha(assembled), "driverSHA256": sha(driver), "fixtureSHA256": sha(fixture),
        "protocolSHA256": sha((output / "frozen-protocol.json").read_bytes()),
        "taskExpressionAndClosureBytesUnchanged": True, "invalidateMethodBytesUnchanged": True,
        "transformation": "One outer capturedTask = assignment; no other production-method changes.",
        "caseOrderAndExpectations": "Frozen baseline fixture body and case contract; unchanged.",
        "dependencyScope": CASE_CONTRACT["declaredSpies"]}
    write_json(output / "pre-execution-fidelity.json", fidelity)

    def run(stage: str, argv: list[str], timeout: int) -> subprocess.CompletedProcess[str]:
        started = dt.datetime.now(dt.timezone.utc).isoformat()
        try:
            result = subprocess.run(argv, capture_output=True, text=True, timeout=timeout)
        except subprocess.TimeoutExpired as error:
            write_json(output / f"{stage}.json", {"argv": argv, "startedAtUTC": started,
                "timedOut": True, "timeoutSeconds": timeout, "attemptCount": 1})
            raise RuntimeError(f"{stage} exceeded its timeout; no retry") from error
        (output / f"{stage}.stdout.log").write_text(result.stdout)
        (output / f"{stage}.stderr.log").write_text(result.stderr)
        write_json(output / f"{stage}.json", {"argv": argv, "startedAtUTC": started,
            "finishedAtUTC": dt.datetime.now(dt.timezone.utc).isoformat(), "exitCode": result.returncode,
            "attemptCount": 1, "timedOut": False, "stdout": f"{stage}.stdout.log", "stderr": f"{stage}.stderr.log"})
        return result

    binary = output / "photo-load-probe"
    compile_result = run("compile", ["xcrun", "--sdk", "macosx", "swiftc", "-swift-version", "6",
        "-parse-as-library", str(assembled_path), "-o", str(binary)], CASE_CONTRACT["bounds"]["hostCompileTimeoutSeconds"])
    if compile_result.returncode:
        raise RuntimeError("Compilation failed; inspect retained logs")
    report_path = output / "results.json"
    execution = run("execute", [str(binary), str(report_path)], CASE_CONTRACT["bounds"]["hostRunTimeoutSeconds"])
    if not report_path.is_file():
        raise RuntimeError("Execution did not write a completed report; inspect retained logs")
    report = json.loads(report_path.read_text())
    expected_ids = [case["id"] for case in CASE_CONTRACT["frozenCases"]]
    if (report.get("phase") != "completed" or report.get("caseCount") != 8
            or report.get("checkCount") != 36 or [case["id"] for case in report["cases"]] != expected_ids):
        raise RuntimeError("Report phase/count/order differs from the frozen cases")
    observed_checks = [check for case in report["cases"] for check in case["checks"]]
    failure_count = sum(check.get("passed") is not True for check in observed_checks)
    if len(observed_checks) != 36 or report.get("failureCount") != failure_count or len(report["failures"]) != failure_count:
        raise RuntimeError("Report assertion counts are inconsistent")
    if source_path.read_bytes() != source or fixture_path.read_bytes() != fixture or driver_path.read_bytes() != driver:
        raise RuntimeError("Source/fixture/driver changed during verification; cannot certify current bytes")
    if assembled_path.read_bytes() != assembled:
        raise RuntimeError("Assembled source changed during verification")
    passed = execution.returncode == 0 and failure_count == 0
    write_json(output / "verification.json", {"phase": "completed", "passed": passed,
        "sourceCommit": commit, "sourceFileSHA256": sha(source), "loadSelectedPhotosSHA256": sha(load),
        "invalidatePendingPhotoLoadSHA256": sha(invalidate), "driverSHA256": sha(driver),
        "fixtureSHA256": sha(fixture), "assembledSHA256": sha(assembled),
        "protocolSHA256": fidelity["protocolSHA256"], "caseContractCanonicalSHA256": sha(contract_bytes),
        "resultsSHA256": sha(report_path.read_bytes()), "compileExitCode": compile_result.returncode,
        "executionExitCode": execution.returncode, "caseCount": 8, "checkCount": 36,
        "failureCount": failure_count, "attemptCount": 1, "sourceAndInputsUnchanged": True,
        "taskClosureByteIdentityPreserved": True, "scope": CASE_CONTRACT["scope"], "limits": CASE_CONTRACT["knownLimits"]})
    print(execution.stdout.strip())
    print(f"Evidence: {output}")
    return 0 if passed else 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"Photo-load verification failed: {error}", file=sys.stderr)
        sys.exit(1)
