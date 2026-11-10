"""Exercise the pattern-local recorders' records: shrunk, forged and failed."""

import copy
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "evidence", ROOT / "scripts/check-pattern-evidence.py"
)
assert spec and spec.loader
E = importlib.util.module_from_spec(spec)
spec.loader.exec_module(E)


class PatternLocalTests(unittest.TestCase):
    def test_retained_records_match_and_cannot_be_shrunk(self) -> None:
        selection = json.loads(E.LOCAL_SELECTION.read_text())
        report = E.inspect(ROOT, selection, E.LOCAL_BINDINGS)
        self.assertEqual(report["failures"], [])
        for fixture in report["fixtures"]:
            self.assertTrue(fixture.get("programs_rebuilt"), fixture["name"])
        with self.assertRaises(ValueError):
            E.inspect(ROOT, selection[:-1], E.LOCAL_BINDINGS)
        # A fixture with its recorder removed checks nothing, so fails.
        changed = copy.deepcopy(selection)
        del changed[0]["recorder"]
        self.assertTrue(E.inspect(ROOT, changed, E.LOCAL_BINDINGS)["failures"])

    def test_forged_program_and_failed_record_rejected(self) -> None:
        """A record claiming other program bytes fails, as does a failed run."""
        selection = json.loads(E.LOCAL_SELECTION.read_text())
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            for fixture in selection:
                path = root / fixture["record"]
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes((ROOT / fixture["record"]).read_bytes())
            for fixture in selection:
                with self.subTest(fixture=fixture["name"]):
                    path = root / fixture["record"]
                    original = path.read_text()
                    record = json.loads(original)
                    record["programs"][next(iter(record["programs"]))] = "0" * 64
                    path.write_text(json.dumps(record))
                    failures = E.inspect(root, selection, E.LOCAL_BINDINGS)["failures"]
                    self.assertTrue(
                        any(
                            f.startswith(fixture["name"])
                            and "Program bytes differ" in f
                            for f in failures
                        ),
                        failures,
                    )
                    record = json.loads(original)
                    record["status"] = "failed"
                    path.write_text(json.dumps(record))
                    failures = E.inspect(root, selection, E.LOCAL_BINDINGS)["failures"]
                    self.assertTrue(
                        any(f.startswith(fixture["name"]) for f in failures), failures
                    )
                    path.write_text(original)

    def test_records_name_released_tools_without_local_paths(self) -> None:
        for fixture in json.loads(E.LOCAL_SELECTION.read_text()):
            record = json.loads((ROOT / fixture["record"]).read_text())
            with self.subTest(fixture=fixture["name"]):
                tools = record.get("tools", {})
                self.assertIn("assembler", tools)
                assembler = tools["assembler"]
                self.assertEqual(
                    assembler["executable_sha256"], record["assembler_sha256"]
                )
                self.assertTrue(assembler["release"].startswith("https://github.com/"))
                self.assertTrue(
                    tools["emulator"]["release"].startswith("https://github.com/")
                )
                for tool in tools.values():
                    for value in tool.values():
                        self.assertFalse(str(value).startswith("/"), value)


if __name__ == "__main__":
    unittest.main()
