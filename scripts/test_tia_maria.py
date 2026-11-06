"""Corruption must turn the retained-evidence gate red."""

from __future__ import annotations

import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "records", Path(__file__).with_name("check-tia-maria-records.py")
)
assert SPEC and SPEC.loader
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


BINDINGS = C.SHARED / "bindings.json"


def bound_copy(root: Path) -> dict[str, str]:
    """Copy every bound file and both record folders into `root`."""
    bindings = json.loads((C.ROOT / BINDINGS).read_text())
    for relative in bindings:
        dest = root / relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(C.ROOT / relative, dest)
    for machine, (name, _) in C.V.CONFIG.items():
        relative = Path(machine) / "patterns/assembly/rendering" / name / "verification"
        shutil.copytree(C.ROOT / relative, root / relative, dirs_exist_ok=True)
    shutil.copyfile(C.ROOT / BINDINGS, root / BINDINGS)
    return bindings


def rebind(root: Path, relative: str) -> None:
    """Bind a changed record file, as a consistent forgery would."""
    bindings = json.loads((root / BINDINGS).read_text())
    if relative in bindings:
        bindings[relative] = C.V.T.T.sha(root / relative)
        (root / BINDINGS).write_text(json.dumps(bindings, indent=2) + "\n")


def rewrite(root: Path, relative: str, change: dict) -> None:
    """Change fields of a JSON record and rebind it."""
    path = root / relative
    record = json.loads(path.read_text())
    record.update(change)
    path.write_text(json.dumps(record, indent=2) + "\n")
    rebind(root, relative)


class RetainedEvidence(unittest.TestCase):
    def test_real_records(self) -> None:
        self.assertEqual(C.validate(), 19)

    def test_each_bound_record_is_checked(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            bindings = bound_copy(root)
            self.assertEqual(C.validate(root), 19)
            for relative in filter(C.is_record, bindings):
                p = root / relative
                original = p.read_bytes()
                p.write_bytes(original + b"corrupt")
                with self.subTest(relative=relative), self.assertRaises(AssertionError):
                    C.validate(root)
                p.write_bytes(original)

    def test_source_digests_are_provenance(self) -> None:
        """Changed source or script text alone does not make a record stale."""
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            bindings = bound_copy(root)
            for relative in bindings:
                if not C.is_record(relative):
                    bindings[relative] = "0" * 64
            (root / BINDINGS).write_text(json.dumps(bindings, indent=2) + "\n")
            for case, (machine, name, _) in C.C.CASES.items():
                relative = (
                    f"{machine}/patterns/assembly/rendering/{name}"
                    f"/customise/verification/{case}.json"
                )
                record = json.loads((root / relative).read_text())
                rewrite(
                    root,
                    relative,
                    {"sources": dict.fromkeys(record["sources"], "0" * 64)},
                )
            self.assertEqual(C.validate(root), 19)

    def test_forged_cartridge_is_rebuilt(self) -> None:
        """A consistent claim of other bytes is caught only by the rebuild."""
        forged = {"cart_sha256": "0" * 64}
        for machine, (name, _) in C.V.CONFIG.items():
            folder = f"{machine}/patterns/assembly/rendering/{name}/verification"
            with self.subTest(system=machine), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                bound_copy(root)
                records = json.loads((root / folder / "results.json").read_text())
                records[0].update(forged)
                (root / folder / "results.json").write_text(
                    json.dumps(records, indent=2) + "\n"
                )
                rebind(root, f"{folder}/results.json")
                rewrite(root, f"{folder}/native.json", forged)
                with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
                    C.validate(root)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            bound_copy(root)
            rewrite(
                root,
                "atari-7800/patterns/assembly/rendering/maria-objects"
                "/customise/verification/ships.json",
                forged,
            )
            with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
                C.validate(root)


if __name__ == "__main__":
    unittest.main()
