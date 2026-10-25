#!/usr/bin/env python3
"""Verify the actual photo transfer helper with synthetic native Mac providers.

Requires Mac Swift 6 and the PhotosUI/SwiftUI SDK. No library or image is read.
One case uses the actual 15-second timer; all worker/cancellation holds are released.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    out = args.output.resolve()
    if sys.platform != 'darwin' or out.exists() or out == repo or repo in out.parents:
        parser.error('Use a new external output directory on this Mac')
    out.mkdir(parents=True)
    source_path = repo / 'MealMirror.swiftpm/PhotoDataTransfer.swift'
    fixture_path = repo / 'scripts/PhotoDataTransferChecks.swift'
    source, fixture = source_path.read_bytes(), fixture_path.read_bytes()
    combined = source + b'\n' + fixture
    (out / 'Probe.swift').write_bytes(combined)
    protocol = {'sourceSHA256': sha(source), 'fixtureSHA256': sha(fixture),
        'assembledSHA256': sha(combined), 'driverSHA256': sha(Path(__file__).read_bytes()),
        'sourceTransformation': 'None. Complete actual helper bytes followed by fixture bytes in one file for private gate access.',
        'caseIDs': ['synchronousData', 'synchronousNil', 'providerError', 'duplicateReply', 'preCancelled',
                    'cancelBeforeProgressReturns', 'blockingCancellationHandler', 'actualFifteenSecondDeadline',
                    'timeoutBeforeRegistration', 'successBeforeCancellation'], 'expectedChecks': 19,
        'bounds': {'compileSeconds': 60, 'executionSeconds': 70, 'internalWatchdogSeconds': 60},
        'scope': 'Native Foundation task/lock/timer/Progress with synthetic providers; PhotosUI wrapper compiles but actual picker transfer, images, UI, OS compute stop and physical offline behavior unverified.',
        'ordering': 'Actor witnesses and explicit semaphore releases; real15s deadline once, no ordering sleeps or retries.'}
    (out / 'protocol.json').write_text(json.dumps(protocol, indent=2) + '\n')
    for name, cmd, limit in [
        ('compile', ['xcrun', '--sdk', 'macosx', 'swiftc', '-swift-version', '6', '-parse-as-library', str(out / 'Probe.swift'), '-o', str(out / 'probe')], 60),
        ('execute', [str(out / 'probe'), str(out / 'results.json')], 70)]:
        try:
            result = subprocess.run(cmd, capture_output=True, timeout=limit)
        except subprocess.TimeoutExpired as error:
            (out / (name + '.stdout.log')).write_bytes(error.stdout or b'')
            (out / (name + '.stderr.log')).write_bytes(error.stderr or b'')
            (out / (name + '.json')).write_text(json.dumps({'timedOut': True, 'limitSeconds': limit}) + '\n')
            return 124
        (out / (name + '.stdout.log')).write_bytes(result.stdout)
        (out / (name + '.stderr.log')).write_bytes(result.stderr)
        (out / (name + '.json')).write_text(json.dumps({'exitCode': result.returncode, 'timedOut': False}) + '\n')
        if result.returncode:
            print(name + ' failed; inspect retained logs')
            return result.returncode
    report = json.loads((out / 'results.json').read_text())
    assert [c['id'] for c in report['cases']] == protocol['caseIDs']
    checks = [check for case in report['cases'] for check in case['checks']]
    assert report['caseCount'] == 10 and report['checkCount'] == len(checks) == 19
    assert report['failureCount'] == sum(c['passed'] is not True for c in checks) == 0
    assert source_path.read_bytes() == source and fixture_path.read_bytes() == fixture
    assert (out / 'Probe.swift').read_bytes() == combined
    print('10 cases, 19 checks, zero failed expectations; source and inputs unchanged')
    return 0


if __name__ == '__main__':
    sys.exit(main())
