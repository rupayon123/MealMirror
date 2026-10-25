#!/usr/bin/env python3
"""Synthetic metadata checks only; no actual photos, rights or human labels."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
TOOL = Path(__file__).with_name("validate-recognition-manifest.py")
spec = importlib.util.spec_from_file_location("recognition_manifest", TOOL)
tool = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tool)


def sample(number, split):
    return {"id": f"fixture-{number}", "sha256": hashlib.sha256(str(number).encode()).hexdigest(),
        "split": split, "assetGroup": f"asset-{number}", "sceneGroup": f"scene-{number}",
        "photographerGroup": f"photographer-{number}", "projectExposure": "eligible_new",
        "rights": {"review": "recorded", "training": True, "calibration": True, "evaluation": True,
            "derivedModelDistribution": True, "record": "mock-rights"},
        "label": {"value": "food_like", "review": "qualified_human", "record": "mock-label"}}


class ManifestChecks(unittest.TestCase):
    def setUp(self):
        self.data = {"schemaVersion": 1, "datasetID": "synthetic-metadata-only",
            "samples": [sample(1, "training"), sample(2, "calibration"), sample(3, "evaluation")]}

    def result(self, strict=True, ledger=None):
        return tool.validate(self.data, {} if ledger is None else ledger, strict)

    def rejects(self, code, **kwargs):
        result = self.result(**kwargs)
        self.assertFalse(result["passed"])
        self.assertIn(code, {x["code"] for x in result["errors"]})

    def test_valid_metadata(self):
        self.assertTrue(self.result()["passed"])

    def test_duplicate_id(self):
        self.data["samples"][1]["id"] = self.data["samples"][0]["id"]
        self.rejects("duplicateID")

    def test_duplicate_hash(self):
        self.data["samples"][1]["sha256"] = self.data["samples"][0]["sha256"]
        self.rejects("duplicateImageHash")

    def test_all_group_leaks(self):
        for field in ["assetGroup", "sceneGroup", "photographerGroup"]:
            with self.subTest(field=field):
                data = copy.deepcopy(self.data)
                data["samples"][1][field] = data["samples"][0][field]
                result = tool.validate(data, {}, True)
                self.assertFalse(result["passed"])
                self.assertIn(field + "CrossesSplits", {x["code"] for x in result["errors"]})

    def test_same_group_within_split(self):
        self.data["samples"][1]["split"] = "training"
        self.data["samples"][1]["sceneGroup"] = self.data["samples"][0]["sceneGroup"]
        self.assertTrue(self.result()["passed"])

    def test_exposed_evaluation(self):
        self.data["samples"][2]["projectExposure"] = "development_exposed"
        self.rejects("exposedOutsideDevelopment")

    def test_reserved_training(self):
        self.data["samples"][0]["projectExposure"] = "reserved_untouched"
        self.rejects("reservedOutsideReserved")

    def test_unknown_training(self):
        self.data["samples"][0]["projectExposure"] = "unknown"
        self.rejects("unknownExposureInActiveSplit")

    def test_ledger_contradiction(self):
        digest = self.data["samples"][0]["sha256"]
        self.rejects("declaredExposureContradictsLedger", ledger={digest: "reserved_untouched"})

    def test_missing_ledger(self):
        result = tool.validate(self.data, None, True)
        self.assertFalse(result["passed"])
        self.assertIn("projectExposureLedgerMissing", {x["code"] for x in result["errors"]})

    def test_pending_draft_is_warning(self):
        self.data["samples"][0]["rights"]["review"] = "pending"
        self.data["samples"][0]["label"]["review"] = "ai_annotation"
        result = self.result(strict=False)
        self.assertTrue(result["passed"])
        self.assertTrue(result["warnings"])
        self.rejects("rightsMetadataIncomplete")

    def test_rejected_rights_always_fail(self):
        self.data["samples"][0]["rights"]["review"] = "rejected"
        self.rejects("rightsRejected", strict=False)

    def test_missing_model_distribution_assertion(self):
        self.data["samples"][0]["rights"]["derivedModelDistribution"] = None
        self.rejects("modelDistributionMetadataIncomplete")

    def test_explicit_use_denials_fail_both_modes(self):
        for index, permission in enumerate(["training", "calibration", "evaluation"]):
            for strict in [False, True]:
                with self.subTest(permission=permission, strict=strict):
                    data = copy.deepcopy(self.data)
                    data["samples"][index]["rights"][permission] = False
                    result = tool.validate(data, {}, strict)
                    self.assertFalse(result["passed"])
                    self.assertIn("rightsUseDenied", {x["code"] for x in result["errors"]})

    def test_distribution_denials_fail_both_modes(self):
        for index in [0, 1]:
            for strict in [False, True]:
                data = copy.deepcopy(self.data)
                data["samples"][index]["rights"]["derivedModelDistribution"] = False
                result = tool.validate(data, {}, strict)
                self.assertFalse(result["passed"])
                self.assertIn("modelDistributionDenied", {x["code"] for x in result["errors"]})

    def test_calibration_requires_own_permission(self):
        del self.data["samples"][1]["rights"]["calibration"]
        self.rejects("rightsMetadataIncomplete")
        self.assertTrue(self.result(strict=False)["passed"])

    def test_calibration_requires_distribution_assertion(self):
        self.data["samples"][1]["rights"]["derivedModelDistribution"] = None
        self.rejects("modelDistributionMetadataIncomplete")
        self.assertTrue(self.result(strict=False)["passed"])

    def test_ai_annotation_is_not_reviewed_label(self):
        self.data["samples"][2]["label"]["review"] = "ai_annotation"
        self.rejects("labelMetadataIncomplete")

    def test_boolean_is_not_permission_integer(self):
        self.data["samples"][0]["rights"]["training"] = 1
        self.rejects("rightsBoolean")

    def test_malformed_nested_values(self):
        self.data["samples"][0]["rights"]["review"] = []
        self.data["samples"][1]["label"]["value"] = {}
        self.rejects("rightsSchema")
        self.rejects("labelSchema")
        self.rejects("projectExposureLedgerInvalid", ledger={"0" * 64: []})

    def test_empty_and_boolean_schema(self):
        self.assertFalse(tool.validate({"schemaVersion": 1, "samples": []})["passed"])
        self.data["schemaVersion"] = True
        self.rejects("schemaVersion")

    def test_bad_hash_and_group(self):
        self.data["samples"][0]["sha256"] = "private caption"
        self.data["samples"][0]["assetGroup"] = "unknown"
        self.rejects("sha256")
        self.rejects("assetGroup")

    def test_duplicate_and_nonstandard_json(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "metadata.json"
            for text in ['{"schemaVersion":1,"schemaVersion":1}', '{"value":NaN}']:
                path.write_text(text)
                with self.assertRaises(ValueError):
                    tool.load(path)

    def test_cli_does_not_overwrite_or_mutate_input(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            manifest, ledger, report = root / "manifest.json", root / "ledger.json", root / "report.json"
            manifest.write_text(json.dumps(self.data)); ledger.write_text("{}")
            original = manifest.read_bytes()
            command = [sys.executable, str(TOOL), str(manifest), "--exposure-ledger", str(ledger),
                "--require-reviewed-metadata", "--report", str(report)]
            first = subprocess.run(command, capture_output=True, timeout=10)
            self.assertEqual(first.returncode, 0)
            self.assertTrue(json.loads(report.read_text())["passed"])
            retained = report.read_bytes()
            second = subprocess.run(command, capture_output=True, timeout=10)
            self.assertNotEqual(second.returncode, 0)
            self.assertEqual(report.read_bytes(), retained)
            self.assertEqual(manifest.read_bytes(), original)


if __name__ == "__main__":
    unittest.main(verbosity=2)
