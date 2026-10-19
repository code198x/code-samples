"""A complete inventory must reject omissions and unsupported green claims."""

import copy
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "probe_check", ROOT / "scripts/check-probe-coverage.py"
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class ProbeCoverageTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.registry = self.root / "systems.toml"
        self.manifest = self.root / "coverage.json"
        self.registry.write_text('[[system]]\nmachine_id="one"\ncrate="binary-one"\n')
        import hashlib

        self.data = {
            "registry": {
                "sha256": hashlib.sha256(self.registry.read_bytes()).hexdigest()
            },
            "systems": [
                {
                    "machine_id": "one",
                    "crate": "binary-one",
                    "status": "planned",
                    "next_check": "Run input caller",
                }
            ],
        }

    def check(self, data: dict) -> tuple[int, int]:
        self.manifest.write_text(json.dumps(data))
        return MODULE.check(self.manifest, self.registry)

    def test_planned_inventory_is_not_execution_evidence(self) -> None:
        self.assertEqual(self.check(self.data), (1, 0))

    def test_missing_duplicate_and_wrong_crate_all_fail(self) -> None:
        for kind in ("missing", "duplicate", "crate"):
            with self.subTest(kind=kind):
                data = copy.deepcopy(self.data)
                if kind == "missing":
                    data["systems"] = []
                elif kind == "duplicate":
                    data["systems"] *= 2
                else:
                    data["systems"][0]["crate"] = "other"
                with self.assertRaises(ValueError):
                    self.check(data)

    def test_registry_change_requires_review(self) -> None:
        self.registry.write_text(self.registry.read_text() + "\n# revised\n")
        with self.assertRaisesRegex(ValueError, "Registry changed"):
            self.check(self.data)

    def test_qualified_claim_cannot_use_missing_record(self) -> None:
        self.data["systems"][0].update(status="qualified", record="absent-results.json")
        with self.assertRaises(FileNotFoundError):
            self.check(self.data)


if __name__ == "__main__":
    unittest.main()
