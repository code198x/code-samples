"""The Spectrum release evidence gate must reject false observations."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "check", ROOT / "scripts/check-spectrum-input-edges.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self) -> None:
        C.check()

    def test_falsifications(self) -> None:
        original = json.loads((C.V.V / "results.json").read_text())
        for fault in [
            "case",
            "producer",
            "firmware",
            "code",
            "input",
            "history",
            "mutable",
            "capture",
            "matrix",
            "wrong-control",
            "repair",
        ]:
            r = copy.deepcopy(original)
            c = r["cases"]["working"]
            if fault == "case":
                r["cases"].pop("custom")
            elif fault == "producer":
                r["emulator_sha256"] = "0" * 64
            elif fault == "firmware":
                r["firmware_sha256"]["48.rom"] = "0" * 64
            elif fault == "code":
                c["payload"][0] ^= 1
            elif fault == "input":
                c["samples"][1]["state"]["controls"] = 0
            elif fault == "history":
                c["samples"][2]["state"]["press_events"] = 2
            elif fault == "mutable":
                c["mutable_offsets"] = []
            elif fault == "capture":
                c["image_sha256"] = "0" * 64
            elif fault == "matrix":
                r["cases"]["boundaries"]["bytes"][17] ^= 1
            elif fault == "wrong-control":
                r["cases"]["wrong-boundary"]["oracle_matches"] = True
            else:
                r["cases"]["repaired"]["payload_sha256"] = "0" * 64
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, IndexError, ValueError)),
            ):
                C.check(r)

    def test_pixels(self) -> None:
        r = json.loads((C.V.V / "results.json").read_text())
        c = copy.deepcopy(r["cases"]["working"])
        c["pixels"]["glyphs"]["48"][0] ^= 128
        c["pixels"]["scanlines"] = [
            [c["pixels"]["glyphs"][str(ord(char))][y] for char in c["pixels"]["text"]]
            for y in range(8)
        ]
        with self.assertRaisesRegex(AssertionError, "PNG"):
            C.pixels(c)

    def test_forged_program_is_rebuilt(self) -> None:
        """A consistent claim of other bytes is caught only by the rebuild."""
        original = C.V.V
        with tempfile.TemporaryDirectory() as temp:
            copy_ = Path(temp) / "verification"
            shutil.copytree(original, copy_)
            r = json.loads((copy_ / "results.json").read_text())
            cfg = json.loads((copy_ / "configuration.json").read_text())
            c = r["cases"]["custom"]
            i = next(
                i for i in range(len(c["payload"])) if i not in c["mutable_offsets"]
            )
            c["payload"][i] ^= 1
            c["loaded_image"][i] ^= 1
            if i < len(c["loaded_prefix"]):
                c["loaded_prefix"][i] ^= 1
            digest = hashlib.sha256(bytes(c["payload"])).hexdigest()
            c["payload_sha256"] = cfg["payload_sha256"]["custom"] = digest
            (copy_ / "configuration.json").write_text(json.dumps(cfg))
            C.V.V = copy_
            try:
                with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
                    C.check(r)
            finally:
                C.V.V = original

    def test_source_digests_are_provenance(self) -> None:
        """Changed, added or removed source text alone does not make a record stale."""
        r = json.loads((C.V.V / "results.json").read_text())
        r["sources"] = dict.fromkeys(list(r["sources"])[1:], "0" * 64)
        for c in r["cases"].values():
            c["source_sha256"] = "0" * 64
        C.check(r)


if __name__ == "__main__":
    unittest.main()
