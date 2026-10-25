#!/usr/bin/env python3
"""Verify that an internal test app preserves its source localization resources.

This is a resource-integrity check, not translation, layout or accessibility QA.
The separate Challenge ZIP deliberately remains English-only.
"""
import argparse
import hashlib
import json
import plistlib
from pathlib import Path
import subprocess


def strings(path):
    return json.loads(subprocess.check_output(
        ['plutil', '-convert', 'json', '-o', '-', str(path)], text=True))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('app', type=Path)
    parser.add_argument('--source', type=Path,
        default=Path(__file__).resolve().parents[1] / 'MealMirror.swiftpm')
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    if args.report and args.report.exists():
        parser.error('Refusing to overwrite a report')
    source = args.source / 'Resources'
    expected = json.loads((source / 'app_strings.json').read_bytes())
    if 'en' not in expected or not all(isinstance(v, dict) and v for v in expected.values()):
        parser.error('Source catalogs must contain populated language tables including English')
    info = plistlib.loads((args.app / 'Info.plist').read_bytes())
    errors = []
    if info.get('CFBundleIdentifier') != 'com.mealmirror.swiftchallenge':
        errors.append('Unexpected app identifier')
    catalog_file = args.app / 'app_strings.json'
    if not catalog_file.is_file():
        errors.append('App catalog missing')
    elif json.loads(catalog_file.read_bytes()) != expected:
        errors.append('App catalog differs from the full source catalogs')
    if set(info.get('CFBundleLocalizations', [])) != set(expected):
        errors.append('App declared languages differ from the full source catalogs')
    actual_directories = {p.name.removesuffix('.lproj') for p in args.app.glob('*.lproj') if p.is_dir()}
    if actual_directories != set(expected):
        errors.append('App language directories differ from the full source catalogs')
    for language, table in sorted(expected.items()):
        for name in ['Localizable.strings', 'InfoPlist.strings']:
            built = args.app / (language + '.lproj') / name
            original = source / (language + '.lproj') / name
            if not built.is_file() or not original.is_file():
                errors.append(f'{language}: missing {name}')
                continue
            expected_strings = table if name == 'Localizable.strings' else strings(original)
            if strings(built) != expected_strings:
                errors.append(f'{language}: changed {name}')
    report = {'build': info.get('CFBundleVersion'), 'languages': sorted(expected),
        'languageCount': len(expected), 'englishKeyCount': len(expected['en']),
        'sourceCatalogSHA256': hashlib.sha256((source / 'app_strings.json').read_bytes()).hexdigest(),
        'builtCatalogSHA256': hashlib.sha256(catalog_file.read_bytes()).hexdigest() if catalog_file.is_file() else None,
        'passed': not errors, 'errors': errors,
        'scope': 'Full-resource internal test app integrity only; no translation accuracy, fallback-free copy, rendered UI or device acceptance.'}
    if args.report:
        args.report.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))
    return int(bool(errors))


if __name__ == '__main__':
    raise SystemExit(main())
