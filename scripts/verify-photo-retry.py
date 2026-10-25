#!/usr/bin/env python3
"""Check current-token photo failure cleanup with explicit Foundation-only spies.

Uses the existing frozen loading suite plus six food/label failure cases. Selection
IDs model the Equatable empty-to-selected transition; no PhotosUI identity, picker
presentation, real decoding, existing meal attachment, or native UI proof.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--source-revision', default='WORKTREE')
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    out = args.output.resolve()
    if sys.platform != 'darwin' or out.exists() or out == repo or repo in out.parents:
        parser.error('Use a new external output directory on this Mac')
    out.mkdir(parents=True)
    module_path = repo / 'scripts/verify-photo-load.py'
    spec = importlib.util.spec_from_file_location('original_load_checks', module_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    source = ((repo / 'MealMirror.swiftpm/ContentView.swift').read_bytes()
              if args.source_revision == 'WORKTREE' else subprocess.check_output(
                  ['git', 'show', args.source_revision + ':MealMirror.swiftpm/ContentView.swift'], cwd=repo))
    fixture = (repo / 'scripts/verify-photo-load.swift').read_bytes()
    assert sha(fixture[fixture.index(b'import Darwin\n'):]) == module.FROZEN_FIXTURE_BODY_SHA256
    load = module.extract(source, b'    private func loadSelectedPhotos(', b'    private func selectDemo(')
    invalidate = module.extract(source, b'    private func invalidatePendingPhotoLoad()', b'    private func cancelPendingAnalysis()')
    task_line = b'        Task { @MainActor in'
    assert load.count(task_line) == 1
    observed_load = load.replace(task_line, b'        capturedTask = Task { @MainActor in', 1)
    assert load[load.index(b'Task { @MainActor in'):] == observed_load[observed_load.index(b'Task { @MainActor in'):]
    text = fixture.decode()

    def replace(old, new):
        nonlocal text
        assert text.count(old) == 1, old
        text = text.replace(old, new, 1)

    # Explicit spy changes: seed current picker IDs, include them in snapshots,
    # and mirror the already-existing successful appender's selection cleanup.
    replace('    let stateWrites: Int\n', '    let stateWrites: Int\n    let foodSelection: [String]\n    let labelSelection: [String]\n')
    for role in ['food', 'label']:
        replace(f'    private var {role}PickerItems: [PhotosPickerItem] = []\n',
                f'    private var {role}PickerItems: [PhotosPickerItem] = [] {{ didSet {{ stateWrites += 1 }} }}\n')
    replace('        loadSelectedPhotos(ids.map { PhotosPickerItem(id: $0) }, role: role)',
            '''        let selected = ids.map { PhotosPickerItem(id: $0) }
        if role == .food { foodPickerItems = selected } else { labelPickerItems = selected }
        loadSelectedPhotos(selected, role: role)''')
    replace('                      appends: appends, stateWrites: stateWrites)',
            '''                      appends: appends, stateWrites: stateWrites,
                      foodSelection: foodPickerItems.map(\.id), labelSelection: labelPickerItems.map(\.id))''')
    replace('        appends.append(AppendEvent(ids: images.map(\.id), role: role))',
            '''        foodPickerItems = []
        labelPickerItems = []
        appends.append(AppendEvent(ids: images.map(\.id), role: role))''')
    extra_cases = r'''
        for role in [MealPhotoRole.food, .label] {
            for outcome in ["throw", "missing", "decode"] {
                let id = "retryState_" + role.rawValue + "_" + outcome, p = id + "/"
                let failedID = p + "F1"
                let plan = Plan(transferOutcome: outcome == "throw" ? .failure : outcome == "missing" ? .missing : .data,
                                decodeSucceeds: outcome != "decode")
                await backend.install([p + "seed": Plan(), failedID: plan])
                let h = PhotoLoadHarness(), seed = h.begin([p + "seed"], role: role)
                await seed.value
                let before = h.snapshot()
                let failed = h.begin([failedID], role: role)
                await failed.value
                let final = h.snapshot(), calls = await backend.calls(prefix: p)
                let selectedIDs = role == .food ? final.foodSelection : final.labelSelection
                suite.record(id, calls: calls, checks: [
                    ("Both transient picker selections are empty", final.foodSelection.isEmpty && final.labelSelection.isEmpty),
                    ("Identical selected IDs can form a new change", selectedIDs != [failedID]),
                    ("Failed batch adds no append event", final.appends == before.appends),
                    ("Current failure clears busy", !final.busy),
                    ("Current failure reports an error", final.error != nil)
                ], state: final)
            }
        }

'''
    replace('        let checkCount = suite.cases.reduce', extra_cases + '        let checkCount = suite.cases.reduce')
    replace('// __EXTRACTED_METHODS__', (observed_load + b'\n' + invalidate).decode())
    assembled = text.encode()
    (out / 'Probe.swift').write_bytes(assembled)
    (out / 'load.original.swift.txt').write_bytes(load)
    protocol = {
        'scope': __doc__, 'sourceRevision': args.source_revision,
        'sourceSHA256': sha(source), 'loadMethodSHA256': sha(load),
        'fixtureSHA256': sha(fixture), 'assembledSHA256': sha(assembled),
        'driverSHA256': sha(Path(__file__).read_bytes()),
        'existingCases': 8, 'newCases': 6, 'expectedChecks': 66,
        'spies': 'Existing explicit continuation-based ID-only spies; selection IDs seeded and included in state snapshots; append spy clears transient selections as production success already does.',
        'fidelity': 'Only outer capturedTask assignment added to production loading method. Invalidation copied byte-for-byte.',
        'failurePolicy': 'One compile and execution per source, retain failures; no ordering sleeps or retries.',
        'bounds': {'compileSeconds': 60, 'executionSeconds': 30, 'internalWatchdogSeconds': 20}}
    (out / 'protocol.json').write_text(json.dumps(protocol, indent=2) + '\n')
    for name, cmd, timeout in [
        ('compile', ['xcrun', '--sdk', 'macosx', 'swiftc', '-swift-version', '6', '-parse-as-library', str(out / 'Probe.swift'), '-o', str(out / 'probe')], 60),
        ('execute', [str(out / 'probe'), str(out / 'results.json')], 30)]:
        result = subprocess.run(cmd, capture_output=True, timeout=timeout)
        (out / (name + '.stdout.log')).write_bytes(result.stdout)
        (out / (name + '.stderr.log')).write_bytes(result.stderr)
        (out / (name + '.json')).write_text(json.dumps({'exitCode': result.returncode, 'timedOut': False}) + '\n')
        if name == 'compile' and result.returncode:
            raise RuntimeError('Compilation failed; retained logs')
    report = json.loads((out / 'results.json').read_text())
    assert report['phase'] == 'completed' and report['caseCount'] == 14 and report['checkCount'] == 66
    assert sha((out / 'Probe.swift').read_bytes()) == protocol['assembledSHA256']
    assert (repo / 'scripts/verify-photo-load.swift').read_bytes() == fixture
    if args.source_revision == 'WORKTREE':
        assert (repo / 'MealMirror.swiftpm/ContentView.swift').read_bytes() == source
    print(f"{report['caseCount']} cases, {report['checkCount']} checks, {report['failureCount']} failed expectations")
    return result.returncode


if __name__ == '__main__':
    sys.exit(main())
