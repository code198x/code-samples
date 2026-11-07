"""A complete inventory must reject omissions and unsupported green claims."""

import copy
import importlib.util
import json
import shutil
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

        source = self.root / "demo.bas"
        source.write_text("10 INPUT A\n")
        proof = {
            "status": "passed",
            "server": {"name": "binary-one"},
            "sources": {"demo.bas": hashlib.sha256(source.read_bytes()).hexdigest()},
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
        import hashlib
        from unittest.mock import patch

        (self.root / "proof.json").write_text(json.dumps(proof))
        self.data["systems"][0]["record_sha256"] = hashlib.sha256(
            (self.root / "proof.json").read_bytes()
        ).hexdigest()
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

    def test_changed_typed_program_cannot_keep_a_qualified_claim(self) -> None:
        proof = self.command_record()
        (self.root / "demo.bas").write_text("10 GOTO 10\n")
        with self.assertRaisesRegex(AssertionError, "^Typed program differs"):
            self.retained_check(proof)

    def test_script_digests_are_provenance(self) -> None:
        proof = self.command_record()
        proof["sources"]["scripts/verify-command-loops.py"] = "0" * 64
        proof["observer_sha256"] = "0" * 64
        self.assertEqual(self.retained_check(proof), (1, 1))

    def test_tampered_record_fails(self) -> None:
        from unittest.mock import patch

        proof = self.command_record()
        self.assertEqual(self.retained_check(proof), (1, 1))
        proof["negative_control"]["observed_turn"] = 2
        (self.root / "proof.json").write_text(json.dumps(proof))
        with (
            patch.object(MODULE, "ROOT", self.root),
            self.assertRaisesRegex(ValueError, "Record changed"),
        ):
            self.check(self.data)

    def test_missing_accepted_states_cannot_keep_a_qualified_claim(self) -> None:
        proof = self.command_record()
        proof["accepted_command_states"] = []
        with self.assertRaises(ValueError):
            self.retained_check(proof)


class RebuiltProbeProgramTests(unittest.TestCase):
    """A record that lists its programs is judged by rebuilding them."""

    MACHINE = "coleco-colecovision"
    PROBE = "input-driven-with-frame-service"

    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        folder = f"{self.MACHINE}/patterns/assembly/framework/input-loop"
        shutil.copytree(
            ROOT / "scripts",
            self.root / "scripts",
            ignore=shutil.ignore_patterns("__pycache__"),
        )
        shutil.copytree(
            ROOT / folder, self.root / folder, ignore=shutil.ignore_patterns("build")
        )
        self.source = self.root / folder / "demo.asm"
        self.record = json.loads(
            (ROOT / folder / "verification/results.json").read_text()
        )
        # Rebuilds are cached per build; these tests change the sources.
        MODULE.E.rebuild.cache_clear()

    def require(self, record: dict | None = None) -> None:
        MODULE.require_program(
            self.root, self.MACHINE, record or self.record, self.PROBE
        )

    def test_recorded_programs_rebuild_and_a_comment_changes_nothing(self) -> None:
        self.require()
        self.source.write_text(self.source.read_text() + "\n; a comment\n")
        MODULE.E.rebuild.cache_clear()
        self.require()

    def test_changed_operand_fails(self) -> None:
        text = self.source.read_text()
        old = "    ld a,$87"
        self.assertEqual(text.count(old), 1)
        self.source.write_text(text.replace(old, "    ld a,$86"))
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            self.require()

    def test_forged_program_digest_fails(self) -> None:
        forged = copy.deepcopy(self.record)
        forged["programs"]["no-edge.cv"] = "0" * 64
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            self.require(forged)

    def test_programs_without_a_recorder_fail(self) -> None:
        with self.assertRaisesRegex(ValueError, "No recorder"):
            MODULE.require_program(self.root, self.MACHINE, self.record, "frame-paced")

    def test_rebuilt_records_name_released_tools_without_local_paths(self) -> None:
        data = json.loads((ROOT / "docs/probe-coverage.json").read_text())
        rebuilt = 0
        for row in data["systems"]:
            if not row.get("record"):
                continue
            record = json.loads((ROOT / row["record"]).read_text())
            if "programs" not in record:
                continue
            rebuilt += 1
            self.assertIn(row["probe"], MODULE.RECORDERS)
            tools = record["tools"]
            self.assertEqual(
                tools["assembler"]["executable_sha256"], record["assembler_sha256"]
            )
            self.assertEqual(
                tools["emulator"]["executable_sha256"], record["emulator_sha256"]
            )
            for tool in tools.values():
                self.assertTrue(tool["release"].startswith("https://github.com/"))
                for value in tool.values():
                    self.assertFalse(value.startswith("/"), value)
        self.assertGreater(rebuilt, 0)


class RebuiltSegaTurnProgramTests(unittest.TestCase):
    """The Sega turn-deadline records are judged by rebuilding their programs."""

    MACHINE = "sega-master-system"
    PROBE = "untimed-and-timed-turns"

    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        folder = f"{self.MACHINE}/patterns/assembly/framework/turn-deadline"
        shared = "cross-platform/assembly/framework/turn-deadline"
        shutil.copytree(
            ROOT / "scripts",
            self.root / "scripts",
            ignore=shutil.ignore_patterns("__pycache__"),
        )
        for name in (folder, shared):
            shutil.copytree(
                ROOT / name, self.root / name, ignore=shutil.ignore_patterns("build")
            )
        self.source = self.root / folder / "demo.asm"
        self.record = json.loads(
            (ROOT / folder / "verification/results.json").read_text()
        )
        # Rebuilds are cached per build; these tests change the sources.
        MODULE.E.rebuild.cache_clear()

    def require(self, record: dict | None = None) -> None:
        MODULE.require_program(
            self.root, self.MACHINE, record or self.record, self.PROBE
        )

    def test_recorded_programs_rebuild_and_a_comment_changes_nothing(self) -> None:
        self.require()
        self.source.write_text(self.source.read_text() + "\n; a comment\n")
        MODULE.E.rebuild.cache_clear()
        self.require()

    def test_changed_operand_fails(self) -> None:
        text = self.source.read_text()
        old = "    ld a,120"
        self.assertEqual(text.count(old), 1)
        self.source.write_text(text.replace(old, "    ld a,121"))
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            self.require()

    def test_forged_program_digest_fails(self) -> None:
        forged = copy.deepcopy(self.record)
        forged["programs"]["no-edge.sms"] = "0" * 64
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            self.require(forged)

    def test_programs_without_a_recorder_fail(self) -> None:
        with self.assertRaisesRegex(ValueError, "No recorder"):
            MODULE.require_program(self.root, self.MACHINE, self.record, "frame-paced")


if __name__ == "__main__":
    unittest.main()
