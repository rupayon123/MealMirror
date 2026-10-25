#!/usr/bin/env python3
"""Small exact-source encoded-Data checks on real Mac Catalyst UIKit.

Runs a command-line process, not UIApplication/XCTest, Simulator or MealMirror.
No app install, photo library, model, network, user-data or settings operations.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time


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
    source_path = repo / 'MealMirror.swiftpm/MealAnalysisEngine.swift'
    fixture_path = repo / 'scripts/verify-encoded-catalyst.swift'
    source, fixture = source_path.read_bytes(), fixture_path.read_bytes()
    start = b'    static func downsampledImage(from data: Data, maxPixelSize: Int = 1_800) -> UIImage? {'
    end = b'\n    static func downsampledImage(from image: UIImage,'
    if source.count(start) != 1 or source.count(end) != 1:
        raise RuntimeError('Review changed extraction boundaries')
    block = source[source.index(start):source.index(end)].rstrip()
    assembled = b'import Foundation\nimport UIKit\nimport ImageIO\nenum MealPhotoPreparation {\n' + block + b'\n}\n' + fixture
    (out / 'Probe.swift').write_bytes(assembled)
    expected = {
        'fixture-o1.jpeg': '9cd8660cd18d598eee23b43ed16dcca1e076b3d641adcda03e1831080ba025b5',
        'fixture-o2.jpeg': 'e0f1ff1f2f6f436e1fc588a7f09d417e1d7ad2410906d48a5761ba21a97893f7',
        'fixture-o6.jpeg': 'ad133b58cfa5cf5d3c4bc627dcaf53881b4d6bc69f0ae4f7fb8f279bdd4b31c5',
        'fixture-o8.jpeg': '1ec0a0c5a425dff39bbf83ef6d7799236f49a81946ede08b4827a0345ac55e4f'}
    fixtures = repo / 'scripts/fixtures/encoded-small'
    assert {name: sha((fixtures / name).read_bytes()) for name in expected} == expected
    sdk = subprocess.check_output(['xcrun', '--sdk', 'macosx', '--show-sdk-path'], text=True).strip()
    protocol = {'engineSHA256': sha(source), 'functionSHA256': sha(block),
        'fixtureSHA256': sha(fixture), 'assembledSHA256': sha(assembled),
        'driverSHA256': sha(Path(__file__).read_bytes()), 'inputsSHA256': expected,
        'extraction': 'Exact encoded Data function bytes; only imports/enum shell added. Real UIKit UIImage, not an adapter.',
        'target': 'arm64-apple-ios17.0-macabi', 'sdk': sdk,
        'expectedChecks': 35, 'caseGroups': ['smallEncodedBounds', 'emptyAndTruncatedData', 'smallEncodedOrientation'],
        'scope': 'Mac Catalyst command-line API checks only, not app-host/iOS/physical/picker/48MP/memory-budget or recognition acceptance.'}
    (out / 'protocol.json').write_text(json.dumps(protocol, indent=2) + '\n')
    compile_cmd = ['xcrun', 'swiftc', '-parse-as-library', '-swift-version', '5',
        '-target', protocol['target'], '-sdk', sdk, '-F', sdk + '/System/iOSSupport/System/Library/Frameworks',
        '-I', sdk + '/System/iOSSupport/usr/include', str(out / 'Probe.swift'), '-o', str(out / 'probe')]
    for name, cmd, limit in [('compile', compile_cmd, 90),
            ('execute', [str(out / 'probe'), str(fixtures), str(out / 'results.json')], 30)]:
        started = time.monotonic()
        try:
            result = subprocess.run(cmd, capture_output=True, timeout=limit)
        except subprocess.TimeoutExpired as error:
            (out / (name + '.stdout')).write_bytes(error.stdout or b'')
            (out / (name + '.stderr')).write_bytes(error.stderr or b'')
            (out / (name + '.json')).write_text(json.dumps({'timedOut': True, 'limitSeconds': limit}) + '\n')
            return 124
        (out / (name + '.stdout')).write_bytes(result.stdout)
        (out / (name + '.stderr')).write_bytes(result.stderr)
        (out / (name + '.json')).write_text(json.dumps({'command': cmd, 'exitCode': result.returncode,
            'seconds': time.monotonic() - started}) + '\n')
        if result.returncode:
            print(name + ' failed; inspect retained evidence')
            return 1
    report = json.loads((out / 'results.json').read_text())
    assert report['macCatalyst'] is True and report['appHosted'] is False
    assert report['checkCount'] == len(report['checks']) == 35
    assert len({c['id'] for c in report['checks']}) == 35
    assert report['failureCount'] == sum(c['passed'] is not True for c in report['checks']) == 0
    assert source_path.read_bytes() == source and fixture_path.read_bytes() == fixture
    assert {name: sha((fixtures / name).read_bytes()) for name in expected} == expected
    assert (out / 'Probe.swift').read_bytes() == assembled
    (out / 'binary-sha256.txt').write_text(sha((out / 'probe').read_bytes()) + '\n')
    print('Real Mac Catalyst UIKit: three small-image groups, 35 checks, zero failures')
    return 0


if __name__ == '__main__':
    sys.exit(main())
