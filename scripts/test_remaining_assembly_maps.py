"""Prove that incomplete, stale and falsified native records fail."""

from __future__ import annotations

import argparse
import copy
import importlib.util
import json
import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location(
    "map_check", Path(__file__).with_name("check-remaining-assembly-maps.py")
)
assert SPEC and SPEC.loader
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class MapRecords(unittest.TestCase):
    def test_default_assembler_uses_path(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            binary = Path(directory) / "asm198x"
            binary.write_text("#!/bin/sh\nexit 0\n")
            binary.chmod(0o755)
            resolved = []

            def observe(_config: dict, args: argparse.Namespace) -> None:
                resolved.append(args.assembler)

            with (
                patch.dict(os.environ, {"PATH": directory}),
                patch(
                    "sys.argv",
                    [
                        "verify-assembly-map-gaps",
                        "--native",
                        directory,
                        "--only",
                        "amstrad-cpc",
                    ],
                ),
                patch.object(C.V, "verify", observe),
            ):
                C.V.main()
            self.assertEqual(resolved, [str(binary.resolve())])

    def test_real_records(self) -> None:
        C.main()

    def test_m6809_boundaries(self) -> None:
        edges = C.V.load("map_boundaries", C.ROOT / "scripts/verify-m6809-map-edges.py")
        record = json.loads((edges.FOLDER / "verification/boundaries.json").read_text())
        edges.validate(record)
        for index in range(len(edges.CASES)):
            altered = copy.deepcopy(record)
            altered["actual"][index * edges.STRIDE] ^= 1
            with self.subTest(case=index), self.assertRaises(AssertionError):
                edges.validate(altered)
        for key in ("actual", "cases", "sources", "fixture_sha256"):
            altered = copy.deepcopy(record)
            altered[key] = (
                [] if key in ("actual", "cases") else {} if key == "sources" else ""
            )
            with self.subTest(field=key), self.assertRaises(AssertionError):
                edges.validate(altered)

    def test_falsifications(self) -> None:
        for cfg in json.loads(C.V.CONFIG.read_text()):
            original = json.loads(
                (C.V.folder(cfg) / "verification/results.json").read_text()
            )
            mutations = {
                "language": lambda r: r.update(language="basic"),
                "machine": lambda r: r.update(machine="other"),
                "ram": lambda r: r["configuration"].update(results=0),
                "source": lambda r: r["sources"].update({"missing": "0" * 64}),
                "wrong read": lambda r: r["observations"]["positive"].__setitem__(
                    0, 99
                ),
                "incomplete": lambda r: r["observations"]["positive"].__setitem__(
                    -1, 0
                ),
                "missing control": lambda r: r["observations"].pop("wrong-stride"),
                "control passes": lambda r: r["observations"].update(
                    {"write-without-valid": r["observations"]["positive"]}
                ),
                "same fixture": lambda r: r["fixtures"].update(
                    {"wrong-stride": r["fixtures"]["positive"]}
                ),
                "limits": lambda r: r.update(limits=""),
                "missing customisation": lambda r: r["observations"].pop("closed-exit"),
                "customisation unchanged": lambda r: r["observations"].update(
                    {"closed-exit": r["observations"]["positive"]}
                ),
                "customisation damaged a cell": lambda r: r["observations"][
                    "closed-exit"
                ].__setitem__(0, 99),
                "customisation footprint": lambda r: r["customisation"].update(
                    changed_fixture_bytes=2
                ),
            }
            for name, mutate in mutations.items():
                with self.subTest(system=cfg["system"], fault=name):
                    altered = copy.deepcopy(original)
                    mutate(altered)
                    with self.assertRaises(
                        (RuntimeError, ValueError, AssertionError, KeyError)
                    ):
                        C.validate(cfg, altered)


if __name__ == "__main__":
    unittest.main()
