"""Prove the retained rendering inventory rejects incomplete or altered evidence."""

from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "records", Path(__file__).with_name("check-basic-rendering.py")
)
R = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(R)


class RenderingRecords(unittest.TestCase):
    def test_complete_inventory(self) -> None:
        self.assertEqual(R.check(), 24)

    def changed_record(self, change) -> None:
        manifest = json.loads((R.ROOT / "docs/basic-rendering.json").read_text())
        route = next(r for r in manifest["routes"] if r["kind"] == "pixel-box")
        record = json.loads((R.ROOT / route["record"]).read_text())
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            # Symlink all immutable inputs, replace only the record being falsified.
            for child in R.ROOT.iterdir():
                if child.name == route["system"]:
                    continue
                (root / child.name).symlink_to(
                    child, target_is_directory=child.is_dir()
                )
            folder = root / route["folder"]
            folder.mkdir(parents=True)
            source = R.ROOT / route["folder"]
            for child in source.iterdir():
                if child.name == "verification":
                    continue
                (folder / child.name).symlink_to(
                    child, target_is_directory=child.is_dir()
                )
            retained = folder / "verification"
            retained.mkdir()
            for child in (source / "verification").iterdir():
                if child.name == "results.json":
                    continue
                (retained / child.name).symlink_to(
                    child, target_is_directory=child.is_dir()
                )
            (root / route["record"]).write_text(json.dumps(record))
            R.check_record(root, route)
            change(record)
            (root / route["record"]).write_text(json.dumps(record))
            with self.assertRaises((ValueError, KeyError)):
                R.check_record(root, route)

    def test_missing_raster_match(self) -> None:
        self.changed_record(lambda r: r.update(independent_full_raster_match=False))

    def test_zero_cases(self) -> None:
        self.changed_record(lambda r: r.update(bounds_cases=0))

    def test_source_changed(self) -> None:
        self.changed_record(
            lambda r: r["sources"].update({next(iter(r["sources"])): "0" * 64})
        )

    def test_observer_changed(self) -> None:
        self.changed_record(lambda r: r.update(observer_sha256="0" * 64))

    def test_native_transport_changed(self) -> None:
        self.changed_record(lambda r: r.update(native_transport_sha256="0" * 64))

    def test_missing_firmware(self) -> None:
        self.changed_record(lambda r: r.update(firmware={}))

    def test_wrong_tool(self) -> None:
        self.changed_record(lambda r: r["producer"].update(version="0.0.0"))

    def test_mutated_producer_lock(self) -> None:
        self.changed_record(lambda r: r["producer"].update(after_lock_sha256="0" * 64))

    def test_omitted_draw_not_rejected(self) -> None:
        self.changed_record(lambda r: r.update(omitted_draw_rejected=False))

    def test_wrong_units_not_rejected(self) -> None:
        self.changed_record(lambda r: r.update(wrong_units_rejected=False))

    def test_edge_cases_missing(self) -> None:
        self.changed_record(lambda r: r.update(edge_and_one_cell_boxes=False))

    def test_capture_changed(self) -> None:
        self.changed_record(lambda r: r["captures"].update({"demo.png": "0" * 64}))

    def test_missing_callers(self) -> None:
        self.changed_record(lambda r: r.update(callers={}))

    def test_incomplete_inventory(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / "docs").mkdir()
            (root / "docs/basic-rendering.json").write_text('{"routes":[]}')
            with self.assertRaises(ValueError):
                R.check(root)


if __name__ == "__main__":
    unittest.main()
