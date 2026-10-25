#!/usr/bin/env python3
"""Check recognition-study metadata without opening images or contacting sources.

A pass checks declared bookkeeping, not image rights, label truth, reviewer
identity, perceptual duplicates, coverage, model quality or submission readiness.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

IDENTIFIER = re.compile(r"[A-Za-z0-9][A-Za-z0-9_-]{0,63}\Z")
SHA256 = re.compile(r"[0-9a-f]{64}\Z")
SPLITS = {"development", "training", "calibration", "evaluation", "reserved"}
EXPOSURES = {"development_exposed", "reserved_untouched", "eligible_new", "unknown"}
ACTIVE = {"training", "calibration", "evaluation"}


def identifier(value):
    return isinstance(value, str) and IDENTIFIER.fullmatch(value) is not None


def choice(value, choices):
    return isinstance(value, str) and value in choices


def validate(manifest, ledger=None, require_reviewed=False):
    errors, warnings = [], []

    def issue(target, code, row=None):
        target.append({"code": code, "row": row})

    if not isinstance(manifest, dict) or type(manifest.get("schemaVersion")) is not int or manifest.get("schemaVersion") != 1:
        return {"passed": False, "errors": [{"code": "schemaVersion", "row": None}], "warnings": []}
    if not identifier(manifest.get("datasetID")):
        issue(errors, "datasetID")
    samples = manifest.get("samples")
    if not isinstance(samples, list) or not samples or len(samples) > 100_000:
        return {"passed": False, "errors": [{"code": "samples", "row": None}], "warnings": []}
    if ledger is None:
        issue(errors if require_reviewed else warnings, "projectExposureLedgerMissing")
        ledger = {}
    if not isinstance(ledger, dict) or any(
        not isinstance(k, str) or SHA256.fullmatch(k) is None or not choice(v, {"development_exposed", "reserved_untouched"})
        for k, v in ledger.items()
    ):
        issue(errors, "projectExposureLedgerInvalid")
        ledger = {}

    ids, hashes, groups = set(), {}, {}
    counts = Counter()
    for index, sample in enumerate(samples):
        row = index + 1
        if not isinstance(sample, dict):
            issue(errors, "sampleObject", row)
            continue
        sample_id, digest, split = sample.get("id"), sample.get("sha256"), sample.get("split")
        if not identifier(sample_id):
            issue(errors, "sampleID", row)
        elif sample_id in ids:
            issue(errors, "duplicateID", row)
        else:
            ids.add(sample_id)
        if not isinstance(digest, str) or SHA256.fullmatch(digest) is None:
            issue(errors, "sha256", row)
            digest = None
        elif digest in hashes:
            issue(errors, "duplicateImageHash", row)
        else:
            hashes[digest] = row
        if not isinstance(split, str) or split not in SPLITS:
            issue(errors, "split", row)
            split = None
        else:
            counts[split] += 1
        for field in ["assetGroup", "sceneGroup", "photographerGroup"]:
            value = sample.get(field)
            if not identifier(value) or value.lower() in {"unknown", "pending", "na"}:
                issue(errors, field, row)
                continue
            key = (field, value)
            if split is not None and key in groups and groups[key] != split:
                issue(errors, field + "CrossesSplits", row)
            elif split is not None:
                groups[key] = split
        exposure = sample.get("projectExposure")
        if not isinstance(exposure, str) or exposure not in EXPOSURES:
            issue(errors, "projectExposure", row)
        elif exposure == "development_exposed" and split != "development":
            issue(errors, "exposedOutsideDevelopment", row)
        elif exposure == "reserved_untouched" and split != "reserved":
            issue(errors, "reservedOutsideReserved", row)
        elif exposure == "unknown" and split in ACTIVE:
            issue(errors, "unknownExposureInActiveSplit", row)
        known = ledger.get(digest)
        if known is not None and known != exposure:
            issue(errors, "declaredExposureContradictsLedger", row)

        rights, label = sample.get("rights"), sample.get("label")
        if not isinstance(rights, dict) or not choice(rights.get("review"), {"pending", "recorded", "rejected"}):
            issue(errors, "rightsSchema", row)
            rights = {}
        for field in ["training", "calibration", "evaluation", "derivedModelDistribution"]:
            if rights.get(field) is not None and type(rights[field]) is not bool:
                issue(errors, "rightsBoolean", row)
        if not isinstance(label, dict) or not choice(label.get("value"), {"food_like", "nonfood", "uncertain", "unreviewed"}) or not choice(label.get("review"), {"unreviewed", "ai_annotation", "provisional_human", "qualified_human"}):
            issue(errors, "labelSchema", row)
            label = {}
        if split in ACTIVE:
            target = errors if require_reviewed else warnings
            if rights.get("review") == "rejected":
                issue(errors, "rightsRejected", row)
            applicable = split
            if rights.get(applicable) is False:
                issue(errors, "rightsUseDenied", row)
            if rights.get("review") != "recorded" or rights.get(applicable) is not True or not identifier(rights.get("record")):
                issue(target, "rightsMetadataIncomplete", row)
            if split in {"training", "calibration"}:
                if rights.get("derivedModelDistribution") is False:
                    issue(errors, "modelDistributionDenied", row)
                if rights.get("derivedModelDistribution") is not True:
                    issue(target, "modelDistributionMetadataIncomplete", row)
            if label.get("review") != "qualified_human" or label.get("value") == "unreviewed" or not identifier(label.get("record")):
                issue(target, "labelMetadataIncomplete", row)
    return {"passed": not errors, "recordCount": len(samples), "countsBySplit": dict(sorted(counts.items())),
        "mode": "reviewed-metadata" if require_reviewed else "draft",
        "errors": errors, "warnings": warnings,
        "scope": "Declared metadata integrity only. No image/hash verification, rights proof, human review authentication, perceptual deduplication, coverage or model acceptance."}


def reject_duplicate_keys(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("Duplicate JSON key")
        result[key] = value
    return result


def load(path):
    with path.open("rb") as source:
        data = source.read(5_000_001)
    if len(data) > 5_000_000:
        raise ValueError("Metadata exceeds the five-million-byte limit")
    def invalid_constant(_):
        raise ValueError("Nonstandard JSON number")
    return json.loads(data, object_pairs_hook=reject_duplicate_keys, parse_constant=invalid_constant), hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--exposure-ledger", type=Path)
    parser.add_argument("--require-reviewed-metadata", action="store_true")
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    try:
        manifest, digest = load(args.manifest)
        ledger, ledger_digest = load(args.exposure_ledger) if args.exposure_ledger else (None, None)
        result = validate(manifest, ledger, args.require_reviewed_metadata)
        result.update({"manifestSHA256": digest, "exposureLedgerSHA256": ledger_digest})
    except (ValueError, OSError) as error:
        result = {"passed": False, "errors": [{"code": type(error).__name__, "row": None}], "warnings": []}
    if args.report:
        with args.report.open("x", encoding="utf-8") as report:
            report.write(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))
    return int(not result["passed"])


if __name__ == "__main__":
    raise SystemExit(main())
