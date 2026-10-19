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

    def command_record(self, probe: str = "command-driven") -> dict:
        import hashlib

        source = self.root / "caller.bas"
        source.write_text("10 INPUT A\n")
        proof = {
            "status": "passed",
            "server": {"name": "binary-one"},
            "sources": {"caller.bas": hashlib.sha256(source.read_bytes()).hexdigest()},
            "accepted_command_states": [1, 2],
            "negative_control": {
                "type": "bypass-command",
                "idle_guard_rejected": True,
                "observed_turn": 1,
            },
        }
        self.data["systems"][0].update(
            status="qualified", probe=probe, record="proof.json"
        )
        self.data["systems"][0].pop("next_check")
        return proof

    def retained_check(self, proof: dict) -> tuple[int, int]:
        from unittest.mock import patch

        (self.root / "proof.json").write_text(json.dumps(proof))
        with patch.object(MODULE, "ROOT", self.root):
            return self.check(self.data)

    def test_command_record_needs_a_failing_idle_control(self) -> None:
        proof = self.command_record()
        self.assertEqual(self.retained_check(proof), (1, 1))
        for key, value in [
            ("idle_guard_rejected", False),
            ("observed_turn", 0),
            ("observed_turn", True),
            ("type", "unrecognised"),
        ]:
            with self.subTest(key=key, value=value):
                bad = copy.deepcopy(proof)
                bad["negative_control"][key] = value
                with self.assertRaises(ValueError):
                    self.retained_check(bad)

    def test_numeric_record_needs_both_real_and_rejected_additions(self) -> None:
        proof = self.command_record("numeric-running-total")
        proof["nonzero_initialisation_states"] = [7, 8]
        proof["negative_control"] = {
            "type": "wrong-addition",
            "accepted_turn_guard_rejected": True,
            "observed_turn": 2,
        }
        self.assertEqual(self.retained_check(proof), (1, 1))
        proof["negative_control"]["observed_turn"] = 1
        with self.assertRaises(ValueError):
            self.retained_check(proof)

    def test_changed_source_cannot_keep_a_qualified_claim(self) -> None:
        proof = self.command_record()
        (self.root / "caller.bas").write_text("10 GOTO 10\n")
        with self.assertRaisesRegex(ValueError, "Source missing or changed"):
            self.retained_check(proof)

    def test_missing_accepted_states_cannot_keep_a_qualified_claim(self) -> None:
        proof = self.command_record()
        proof["accepted_command_states"] = []
        with self.assertRaises(ValueError):
            self.retained_check(proof)


if __name__ == "__main__":
    unittest.main()
