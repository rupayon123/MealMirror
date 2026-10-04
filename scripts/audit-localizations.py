#!/usr/bin/env python3
"""Check MealMirror's source catalogs without treating translations as reviewed."""

import argparse
import collections
import json
import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1] / "MealMirror.swiftpm" / "Resources"
FORMAT_TOKEN = re.compile(r"%(?:\d+\$)?(?:lld|ld|@|d|f|s)")


def placeholders(value: str) -> collections.Counter[str]:
    return collections.Counter(
        re.sub(r"^%\d+\$", "%", token)
        for token in FORMAT_TOKEN.findall(value.replace("%%", ""))
    )


def read_strings(path: Path) -> dict[str, str]:
    result = subprocess.run(
        ["plutil", "-convert", "json", "-o", "-", str(path)],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--fail-on-english-fallback",
        action="store_true",
        help="Require all non-English values to differ from English; use only after review",
    )
    args = parser.parse_args()

    catalogs = json.loads((ROOT / "app_strings.json").read_text(encoding="utf-8"))
    if "en" not in catalogs:
        raise SystemExit("English catalog is missing")

    english = catalogs["en"]
    expected_keys = set(english)
    language_directories = {path.name.removesuffix(".lproj"): path for path in ROOT.glob("*.lproj")}
    errors: list[str] = []
    fallback_counts: dict[str, int] = {}

    if set(catalogs) != set(language_directories):
        errors.append(
            f"Catalog languages {sorted(catalogs)} differ from .lproj languages {sorted(language_directories)}"
        )

    for language, translations in sorted(catalogs.items()):
        missing = expected_keys - set(translations)
        extra = set(translations) - expected_keys
        if missing or extra:
            errors.append(f"{language}: {len(missing)} missing and {len(extra)} extra JSON keys")
        directory = language_directories.get(language)
        strings_file = directory / "Localizable.strings" if directory else None
        if strings_file is None or not strings_file.is_file():
            errors.append(f"{language}: Localizable.strings missing")
            continue
        strings = read_strings(strings_file)
        if strings != translations:
            changed = [key for key in expected_keys & set(strings) & set(translations) if strings[key] != translations[key]]
            errors.append(
                f"{language}: JSON/.strings mismatch ({len(set(translations) - set(strings))} missing, "
                f"{len(set(strings) - set(translations))} extra, {len(changed)} changed values)"
            )
        for key in expected_keys & set(translations):
            if placeholders(english[key]) != placeholders(translations[key]):
                errors.append(f"{language}: format placeholders differ for {key!r}")
        if language != "en":
            fallback_counts[language] = sum(
                translations.get(key) == english[key] and any(character.isalpha() for character in key)
                for key in expected_keys
            )

    print(f"Languages: {len(catalogs)}; English keys: {len(expected_keys)}")
    print("English-identical non-English values (includes names and intentional loanwords):")
    for language, count in sorted(fallback_counts.items()):
        print(f"  {language}: {count}")
    if args.fail_on_english_fallback and any(fallback_counts.values()):
        errors.append("Non-English catalogs still contain English-identical values")
    for error in errors:
        print(f"ERROR: {error}")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
