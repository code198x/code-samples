"""Failure controls for retained source/evidence coverage, without guest ROMs."""

from __future__ import annotations

import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "guard", ROOT / "scripts/check-tilemaps.py"
)
assert spec and spec.loader
G = importlib.util.module_from_spec(spec)
spec.loader.exec_module(G)


class EvidenceFailures(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        files = {
            "docs/tilemaps/coverage.json",
            "docs/capability-coverage.json",
            "scripts/check-tilemaps.py",
            "scripts/verify-tilemaps.py",
            "scripts/verify-native-tilemaps.py",
            "scripts/verify-game-loops.py",
            "cross-platform/patterns/rendering/tile-map/native.json",
        }
        inventory = json.loads((ROOT / "docs/tilemaps/coverage.json").read_text())
        for row in inventory["systems"]:
            files.add(row["record"])
            record = json.loads((ROOT / row["record"]).read_text())
            files.update(record["sources"])
            folder = ROOT / row["implementation"] / "verification"
            files.update(
                str(p.relative_to(ROOT)) for p in folder.iterdir() if p.is_file()
            )
        for file in files:
            target = self.root / file
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / file, target)
        self.inventory = inventory

    def tearDown(self) -> None:
        self.temp.cleanup()

    def save(self) -> None:
        (self.root / "docs/tilemaps/coverage.json").write_text(
            json.dumps(self.inventory)
        )

    def test_missing_machine_fails(self) -> None:
        self.inventory["systems"].pop()
        self.save()
        with self.assertRaisesRegex(ValueError, "complete registry"):
            G.verify(self.root)

    def test_changed_routine_fails(self) -> None:
        row = next(
            r for r in self.inventory["systems"] if r["kind"] == "basic-numeric-map"
        )
        p = self.root / row["implementation"] / "routines.bas"
        p.write_text(p.read_text() + "1600 END\n")
        with self.assertRaisesRegex(ValueError, "routines differ"):
            G.verify(self.root)

    def record(self, kind: str) -> tuple[dict, Path, dict]:
        row = next(r for r in self.inventory["systems"] if r["kind"] == kind)
        path = self.root / row["record"]
        return row, path, json.loads(path.read_text())

    def test_changed_typed_demo_fails(self) -> None:
        row, _, _ = self.record("basic-numeric-map")
        p = self.root / row["implementation"] / "demo.bas"
        p.write_text(p.read_text().replace("D=R*W+C", "D=R*W+C+0"))
        with self.assertRaisesRegex(AssertionError, "^Typed program differs"):
            G.verify(self.root)

    def test_forged_program_is_rebuilt(self) -> None:
        """A record claiming another program is caught only by the byte check."""
        for kind, message in [
            ("native-byte-map", "^Program bytes differ"),
            ("basic-numeric-map", "^Typed program differs"),
        ]:
            row, path, record = self.record(kind)
            original = path.read_text()
            if kind == "native-byte-map":
                record["fixture_sha256"] = "0" * 64
            else:
                record["sources"][row["implementation"] + "/demo.bas"] = "0" * 64
            path.write_text(json.dumps(record))
            with (
                self.subTest(kind=kind),
                self.assertRaisesRegex(AssertionError, message),
            ):
                G.verify(self.root)
            path.write_text(original)

    def test_source_digests_are_provenance(self) -> None:
        """Rewritten recorder and source digests leave the evidence valid."""
        for row in self.inventory["systems"]:
            path = self.root / row["record"]
            record = json.loads(path.read_text())
            demo = row["implementation"] + "/demo.bas"
            record["sources"] = {
                name: digest if name == demo else "0" * 64
                for name, digest in record["sources"].items()
            }
            record["observer_sha256"] = record["transport_sha256"] = "0" * 64
            path.write_text(json.dumps(record))
        self.assertEqual(G.verify(self.root), {"basic": 10, "native": 20})

    def test_uncompleted_negative_fails(self) -> None:
        row = next(
            r for r in self.inventory["systems"] if r["kind"] == "native-byte-map"
        )
        p = self.root / row["implementation"] / "verification/wrong-stride.json"
        d = json.loads(p.read_text())
        d["bytes"][-1] = 0
        p.write_text(json.dumps(d))
        with self.assertRaisesRegex(ValueError, "negative control"):
            G.verify(self.root)

    def test_synthetic_rom_does_not_prove_stock_loader(self) -> None:
        row = next(
            r for r in self.inventory["systems"] if r["kind"] == "native-byte-map"
        )
        row["stock_loader"] = "stock-interpreter-keyboard"
        self.save()
        with self.assertRaisesRegex(ValueError, "widened native claim"):
            G.verify(self.root)

    def test_missing_case_group_fails(self) -> None:
        row = next(
            r for r in self.inventory["systems"] if r["kind"] == "basic-numeric-map"
        )
        p = self.root / row["record"]
        d = json.loads(p.read_text())
        d["case_counts"].pop("writes")
        p.write_text(json.dumps(d))
        with self.assertRaisesRegex(ValueError, "case group"):
            G.verify(self.root)


class OricReadback(unittest.TestCase):
    """Reject damaged entry instead of mistaking a ROM error for a good result."""

    @classmethod
    def setUpClass(cls) -> None:
        cls.entry = G.module("oric_entry_test", ROOT / "scripts/tilemap_oric_entry.py")

    def test_readback_detokenises_without_changing_quoted_text(self) -> None:
        raw = bytearray(4096)
        body = b' \x80 "END"'
        following = 0x501 + 5 + len(body)
        raw[:4] = following.to_bytes(2, "little") + (10).to_bytes(2, "little")
        raw[4 : 4 + len(body)] = body

        class Machine:
            def call(self, method: str, **args):
                self_method = method
                assert self_method == "memory_read"
                offset = args["addr"] - 0x501
                return {"bytes": list(raw[offset : offset + args["len"]])}

        self.assertEqual(self.entry.accepted(Machine(), ["PRINT"]), {10: 'PRINT"END"'})
        raw[0:2] = (0x500).to_bytes(2, "little")
        with self.assertRaisesRegex(ValueError, "Invalid Oric line link"):
            self.entry.accepted(Machine(), ["PRINT"])

    def test_repair_waits_for_rom_and_rechecks_exact_source(self) -> None:
        from unittest.mock import patch

        events = []

        class Machine:
            def call(self, method: str, **args):
                events.append((method, args))

        accepted = [{10: "BROKEN"}, {4: "PRINTCHR$(17);", 10: "PRINT1"}]
        with (
            patch.object(self.entry, "keywords", return_value=[]),
            patch.object(self.entry, "accepted", side_effect=accepted),
        ):
            count = self.entry.ensure(
                Machine(),
                "10 PRINT 1\n",
                Path("unused.rom"),
                lambda line: events.append(("type", line)),
            )
        self.assertEqual(count, 2)
        self.assertEqual(
            [e for e in events if e[0] == "type"],
            [("type", "4 PRINT CHR$(17);"), ("type", "10 PRINT 1")],
        )
        for i, event in enumerate(events):
            if event[0] == "type":
                self.assertEqual(events[i + 1], ("run_frames", {"frames": 120}))

    def test_failed_entry_stops_after_bounded_retries(self) -> None:
        from unittest.mock import patch

        class Machine:
            def call(self, method: str, **args):
                pass

        with (
            patch.object(self.entry, "keywords", return_value=[]),
            patch.object(self.entry, "accepted", return_value={}),
            self.assertRaisesRegex(ValueError, "keyboard source still differs"),
        ):
            self.entry.ensure(
                Machine(), "10 PRINT 1\n", Path("unused.rom"), lambda line: None
            )


if __name__ == "__main__":
    unittest.main()
