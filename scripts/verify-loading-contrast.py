#!/usr/bin/env python3
"""Check four loading-text roles against a conservative 4.5:1 source-color target.

This reads the current Swift color tokens and text styles. It does not validate
rendered fonts, animation frames, other colors/screens or overall accessibility.
Formula: https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

TARGET = 4.5


def sha(data):
    return hashlib.sha256(data).hexdigest()


def hex_rgb(value):
    color = int(value, 16)
    return tuple(((color >> shift) & 255) / 255 for shift in (16, 8, 0))


def luminance(rgb):
    linear = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in rgb]
    return sum(c * weight for c, weight in zip(linear, (0.2126, 0.7152, 0.0722)))


def contrast(first, second):
    lighter, darker = sorted((luminance(first), luminance(second)), reverse=True)
    return (lighter + 0.05) / (darker + 0.05)


def inspect(source_root):
    files = {name: (source_root / "MealMirror.swiftpm" / name).read_bytes()
             for name in ("Theme.swift", "AppShell.swift", "ContentView.swift")}
    text = {name: data.decode("utf-8") for name, data in files.items()}
    palette = {}
    for token in ("ink", "loadingCanvas"):
        pattern = rf"static let {token} = adaptive\(light: rgb\(0x([0-9A-Fa-f]{{6}})\), dark: rgb\(0x([0-9A-Fa-f]{{6}})\)\)"
        matches = re.findall(pattern, text["Theme.swift"])
        if len(matches) != 1:
            raise ValueError(f"Expected one supported {token} declaration")
        palette[token] = dict(zip(("light", "dark"), map(hex_rgb, matches[0])))
    values = re.findall(r"static let actionInk = Color\(red: ([\d.]+), green: ([\d.]+), blue: ([\d.]+)\)", text["Theme.swift"])
    if len(values) != 1:
        raise ValueError("Expected one supported actionInk declaration")
    action = tuple(map(float, values[0]))
    if not all(0 <= c <= 1 for c in action):
        raise ValueError("Color channel outside sRGB range")
    palette["actionInk"] = {mode: action for mode in ("light", "dark")}
    roles = [
        ("launchTitle", "AppShell.swift", 'Text("MealMirror")'),
        ("launchTagline", "AppShell.swift", 'Text(localization.text("A clearer view of your meal"))'),
        ("analysisTitle", "ContentView.swift", 'Text(localization.text("Inspecting on this device…"))'),
        ("analysisTagline", "ContentView.swift", 'Text(localization.text("A clearer view of your meal"))'),
    ]
    rows = []
    for role, filename, marker in roles:
        pattern = re.escape(marker) + r"(?:(?!\bText\().)*?\.foregroundStyle\(CarbInTheme\.(\w+)(?:\.opacity\(([\d.]+)\))?\)"
        component = text[filename]
        if filename == "ContentView.swift":
            component = component.split("private struct AddMealView: View {", 1)[1].split("private struct EstimateView: View {", 1)[0]
        styles = re.findall(pattern, component, re.DOTALL)
        if len(styles) != 1:
            raise ValueError(f"Expected one supported style for {role}")
        token, raw_alpha = styles[0]
        if token not in ("ink", "actionInk"):
            raise ValueError(f"Unsupported text-color token: {token}")
        alpha = float(raw_alpha) if raw_alpha else 1.0
        if not 0 <= alpha <= 1:
            raise ValueError("Opacity outside range")
        for mode in ("light", "dark"):
            background = palette["loadingCanvas"][mode]
            foreground = tuple(alpha * c + (1 - alpha) * b
                               for c, b in zip(palette[token][mode], background))
            ratio = contrast(foreground, background)
            rows.append({"role": role, "appearance": mode, "foregroundToken": token,
                         "opacity": alpha, "foregroundSRGB": foreground,
                         "backgroundSRGB": background, "ratio": ratio, "meetsTarget": ratio >= TARGET})
    assert contrast((0, 0, 0), (1, 1, 1)) == 21
    assert contrast((0, 0, 0), (0, 0, 0)) == 1
    return {"sourceSHA256": {name: sha(data) for name, data in files.items()},
            "target": TARGET, "targetScope": "Conservative source-color target for all four text roles; not a blanket WCAG failure judgment or full accessibility certification.",
            "formula": "WCAG sRGB relative luminance; alpha composited over the specified loading background before luminance; ratios compared without rounding.",
            "cases": rows, "checks": len(rows),
            "failures": sum(not row["meetsTarget"] for row in rows)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    try:
        result = inspect(args.source_root.resolve())
    except (ValueError, IndexError, OSError, UnicodeDecodeError) as error:
        parser.error(str(error))
    print(json.dumps(result, indent=2))
    return 1 if result["failures"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
