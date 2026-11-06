"""Falsify each layer of the native word-rectangle gate."""

import copy
import hashlib
import importlib.util
import json
import unittest
import zlib
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-amiga-rectangle-overlap.py")
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self):
        C.check()

    def test_falsifications(self):
        original = json.loads((C.V.V / "results.json").read_text())
        for fault in (
            "configuration",
            "case",
            "complete",
            "oracle",
            "wrong",
            "result",
            "code",
            "segments",
            "plane",
            "producer",
            "image",
            "repair",
        ):
            r = copy.deepcopy(original)
            c = r["cases"]["demo"]
            if fault == "configuration":
                r["configuration"]["kickstart_sha256"] = "0" * 64
            elif fault == "case":
                r["cases"].pop("custom")
            elif fault == "complete":
                c["guards"][1] = 0
            elif fault == "oracle":
                c["bytes"][0] ^= 1
            elif fault == "wrong":
                r["cases"]["wrong"]["bytes"][1] = 0
            elif fault == "result":
                c["result"] = 0
            elif fault == "code":
                c["executable_sha256"] = "0" * 64
            elif fault == "segments":
                c["segments"][0]["bytes"][0] ^= 1
            elif fault == "plane":
                c["plane_zlib"] = "789c030000000001"
            elif fault == "producer":
                c["server"]["version"] = "unknown"
            elif fault == "image":
                c["image_sha256"] = "0" * 64
            else:
                r["cases"]["repaired"]["executable_sha256"] = "0" * 64
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, ValueError)),
            ):
                C.check(r)

    def test_forged_program_is_rebuilt(self):
        """A consistent claim of other bytes is caught only by the rebuild."""
        r = json.loads((C.V.V / "results.json").read_text())
        c = r["cases"]["wrong"]
        raw = bytearray(zlib.decompress(bytes.fromhex(c["hunk_zlib"])))
        _, relocs = C.V.hunk(bytes(raw))
        moved = {i + k for i in relocs for k in range(4)}
        i = next(i for i in range(len(raw) - 32) if i not in moved)
        raw[32 + i] ^= 1  # the code hunk's body starts 32 bytes in
        c["hunk_zlib"] = zlib.compress(bytes(raw)).hex()
        c["executable_sha256"] = hashlib.sha256(raw).hexdigest()
        for seg in c["segments"]:
            if seg["first"] <= i < seg["last"]:
                seg["bytes"][i - seg["first"]] ^= 1
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            C.check(r)

    def test_source_digests_are_provenance(self):
        """Changed, added or removed source text alone does not make a record stale."""
        r = json.loads((C.V.V / "results.json").read_text())
        r["sources"] = dict.fromkeys(list(r["sources"])[1:], "0" * 64)
        C.check(r)

    def test_table_include(self):
        with self.assertRaisesRegex(AssertionError, "table"):
            C.tables((C.V.F / "cases.inc").read_text(), "case_table:\n    dc.w 0\n")

    def test_pixels(self):
        r = json.loads((C.V.V / "results.json").read_text())
        c = copy.deepcopy(r["cases"]["demo"])
        c["result"] = 0
        with self.assertRaisesRegex(AssertionError, "PNG"):
            C.pixels(c)


if __name__ == "__main__":
    unittest.main()
