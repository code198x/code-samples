"""Exercise the public CLI against isolated copies, including stale evidence."""

import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHECKER = ROOT / "scripts/check-pattern-evidence.py"
SELECTION = ROOT / "scripts/pattern-evidence.json"
AABB = "cross-platform/patterns/physics/aabb-collision"


class PatternEvidenceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="198x-pattern-evidence-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.fixtures = json.loads(SELECTION.read_text())
        for fixture in self.fixtures:
            for relative in [
                fixture["record"],
                *[b["path"] for b in fixture["bindings"]],
            ]:
                target = self.root / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT / relative, target)
        self.selection = self.root / "selection.json"
        self.save_selection()
        self.output = self.root / "report.json"

    def save_selection(self) -> None:
        self.selection.write_text(json.dumps(self.fixtures))

    def run_check(self, success: bool, diagnostic: str = "") -> dict:
        # The command must replace a stale passing output even on failure.
        self.output.write_text('{"status":"old_pass"}')
        result = subprocess.run(
            [
                sys.executable,
                str(CHECKER),
                "--root",
                str(self.root),
                "--selection",
                str(self.selection),
                "--output",
                str(self.output),
            ],
            capture_output=True,
            text=True,
            timeout=15,
            check=False,
        )
        self.assertEqual(result.returncode, 0 if success else 1, result.stderr)
        report = json.loads(self.output.read_text())
        self.assertEqual(json.loads(result.stdout), report)
        if success:
            self.assertEqual(report["status"], "recorded_inputs_match")
            self.assertEqual(report["fixtures_checked"], 5)
            self.assertEqual(report["bindings_checked"], 18)
            self.assertEqual(report["runtime_execution"], "not performed by this check")
        else:
            self.assertTrue(report["failures"])
            self.assertIn(diagnostic, " ".join(report["failures"]))
            self.assertIn("need revalidation", result.stderr)
        return report

    def test_current_recorded_sources_match(self) -> None:
        self.run_check(True)

    def test_changed_source_and_observer_require_revalidation(self) -> None:
        for relative in [f"{AABB}/aabb.py", f"{AABB}/verification/verify.py"]:
            with self.subTest(path=relative):
                path = self.root / relative
                original = path.read_bytes()
                path.write_bytes(original + b"\n# changed after the recorded run\n")
                self.run_check(False, f"stale recorded input: {relative}")
                path.write_bytes(original)

    def test_missing_record_or_source_fails(self) -> None:
        for relative in [self.fixtures[0]["record"], f"{AABB}/aabb.py"]:
            with self.subTest(path=relative):
                path = self.root / relative
                original = path.read_bytes()
                path.unlink()
                self.run_check(False, relative)
                path.write_bytes(original)

    def test_missing_record_key_and_malformed_hash_fail(self) -> None:
        path = self.root / self.fixtures[0]["record"]
        original = json.loads(path.read_text())
        for value in [None, "not-a-sha256"]:
            with self.subTest(value=value):
                record = json.loads(json.dumps(original))
                if value is None:
                    del record["sources"]["demo.asm"]
                else:
                    record["sources"]["demo.asm"] = value
                path.write_text(json.dumps(record))
                self.run_check(False, "demo.asm")

    def test_empty_or_malformed_record_fails(self) -> None:
        path = self.root / self.fixtures[0]["record"]
        for content in ["{}", "[]", "", "{broken"]:
            with self.subTest(content=content):
                path.write_text(content)
                self.run_check(False)

    def test_empty_missing_and_duplicate_fixture_selection_fail(self) -> None:
        original = self.fixtures
        for selection in [[], original[:-1], [original[0]] * 5]:
            with self.subTest(selection_length=len(selection)):
                self.fixtures = selection
                self.save_selection()
                self.run_check(False, "once each")

    def test_omitted_or_duplicate_binding_fails(self) -> None:
        original = json.loads(json.dumps(self.fixtures))
        for bindings in [
            [],
            original[0]["bindings"][:-1],
            [original[0]["bindings"][0]] * 5,
        ]:
            with self.subTest(binding_count=len(bindings)):
                self.fixtures = json.loads(json.dumps(original))
                self.fixtures[0]["bindings"] = bindings
                self.save_selection()
                self.run_check(False)

    def test_wrong_aabb_result_fails_the_real_observer(self) -> None:
        source = self.root / AABB / "aabb.py"
        code = source.read_text()
        anchor = "return not (ay >= by + bh or ay + ah <= by)"
        self.assertEqual(code.count(anchor), 1)
        source.write_text(code.replace(anchor, "return False"))
        output = self.root / "aabb-output"
        output.mkdir()
        (output / "results.json").write_text('{"status":"old_pass"}')
        result = subprocess.run(
            [
                sys.executable,
                str(self.root / AABB / "verification/verify.py"),
                "--output",
                str(output),
            ],
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Narrow phase differs from occupied pixels", result.stderr)
        self.assertFalse((output / "results.json").exists())


if __name__ == "__main__":
    unittest.main()
