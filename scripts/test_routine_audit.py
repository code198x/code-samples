"""Exercise missing, altered and empty audit inputs without touching real samples."""

import copy
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(name, filename):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / filename)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


E = load("evidence", "check-pattern-evidence.py")
A = load("audit", "audit-pattern-library.py")


class AuditTests(unittest.TestCase):
    def test_retained_eight_records_match_and_cannot_be_shrunk(self):
        selection = json.loads(E.AUDIT_SELECTION.read_text())
        report = E.inspect(ROOT, selection, E.AUDIT_BINDINGS)
        self.assertEqual(report["failures"], [])
        self.assertGreater(report["bindings_checked"], 28)
        with self.assertRaises(ValueError):
            E.inspect(ROOT, selection[:-1], E.AUDIT_BINDINGS)
        changed = copy.deepcopy(selection)
        changed[0]["bindings"].pop()
        self.assertTrue(E.inspect(ROOT, changed, E.AUDIT_BINDINGS)["failures"])

    def test_changed_routine_or_observer_and_failed_record_rejected(self):
        selection = json.loads(E.AUDIT_SELECTION.read_text())
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            for fixture in selection:
                for name in [
                    fixture["record"],
                    *[b["path"] for b in fixture["bindings"]],
                ]:
                    p = root / name
                    p.parent.mkdir(parents=True, exist_ok=True)
                    p.write_bytes((ROOT / name).read_bytes())
            for binding in selection[0]["bindings"][:2]:
                path = root / binding["path"]
                before = path.read_bytes()
                path.write_bytes(before + b"\n; changed\n")
                self.assertTrue(
                    E.inspect(root, selection, E.AUDIT_BINDINGS)["failures"]
                )
                path.write_bytes(before)
            path = root / selection[0]["record"]
            record = json.loads(path.read_text())
            record["status"] = "failed"
            path.write_text(json.dumps(record))
            self.assertTrue(E.inspect(root, selection, E.AUDIT_BINDINGS)["failures"])

    def test_structural_audit_requires_real_source_and_excerpt(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            samples = root / "samples"
            website = root / "website"
            samples.mkdir()
            pages = website / "src/content/patterns"
            pages.mkdir(parents=True)
            with self.assertRaisesRegex(ValueError, "No Pattern Library pages"):
                A.inspect(samples, website)
            page = pages / "example.mdx"
            page.write_text(
                '<CodeFromFile src="routine.inc" from="start:" to="end:" />'
            )
            self.assertTrue(A.inspect(samples, website)["failures"])
            source = samples / "routine.inc"
            source.write_text("start:\n ret\nend:\n")
            self.assertEqual(A.inspect(samples, website)["failures"], [])
            source.write_text("start:\n ret\n")
            self.assertTrue(A.inspect(samples, website)["failures"])
            source.write_text('start:\n include "missing.inc"\nend:\n')
            self.assertTrue(A.inspect(samples, website)["failures"])
            source.write_text('start:\n include "routine.inc"\nend:\n')
            self.assertTrue(A.inspect(samples, website)["failures"])
            page.write_text('<CodeFromFile src="../outside.inc" />')
            self.assertTrue(A.inspect(samples, website)["failures"])


if __name__ == "__main__":
    unittest.main()
