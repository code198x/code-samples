"""Corruptions must fail for each independent language route."""

import copy
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-spectrum-rectangle-overlap.py")
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self):
        for lang in C.V.FS:
            C.check(lang)

    def test_table_include(self):
        F = C.V.FS["assembly"]
        with self.assertRaisesRegex(AssertionError, "table"):
            C.tables((F / "cases.inc").read_text(), "case_table:\n    defb 0\n")

    def test_falsifications(self):
        for lang, F in C.V.FS.items():
            original = json.loads((F / "verification/results.json").read_text())
            for fault in (
                "source",
                "configuration",
                "case",
                "complete",
                "oracle",
                "code",
                "result",
                "producer",
                "image",
                "repair",
                "pixels",
            ):
                r = copy.deepcopy(original)
                c = r["cases"]["demo"]
                if fault == "source":
                    r["sources"][next(iter(r["sources"]))] = "0" * 64
                elif fault == "configuration":
                    r["configuration"]["rom_sha256"] = "0" * 64
                elif fault == "case":
                    r["cases"].pop("custom")
                elif fault == "complete":
                    r["cases"]["boundaries"]["guards"][1] = 0
                elif fault == "oracle":
                    r["cases"]["boundaries"]["bytes"][0] ^= 1
                elif fault == "code":
                    c["loaded_bytes"][0] ^= 1
                elif fault == "result":
                    c["result"] = 0
                elif fault == "producer":
                    c["server"]["version"] = "unknown"
                elif fault == "image":
                    c["image_sha256"] = "0" * 64
                elif fault == "repair":
                    r["cases"]["repaired"]["payload_sha256"] = "0" * 64
                else:
                    c["pixels"]["glyphs"]["49"][0] ^= 128
                    c["pixels"]["scanlines"][0][0] ^= 128
                with (
                    self.subTest(lang=lang, fault=fault),
                    self.assertRaises((AssertionError, KeyError, ValueError)),
                ):
                    C.check(lang, r)


if __name__ == "__main__":
    unittest.main()
