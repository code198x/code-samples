"""Corrupt retained observations to ensure the ownership gate can reject claims."""

import copy
import hashlib
import importlib.util
import json
import unittest
import zlib
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "check_pool", Path(__file__).with_name("check-object-pool.py")
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class PoolEvidence(unittest.TestCase):
    def test_native(self):
        for system in C.V.SYSTEMS:
            with self.subTest(system=system):
                C.check(system)

    def test_corruptions(self):
        for system in C.V.SYSTEMS:
            source = json.loads(
                (C.V.folder(system) / "verification/results.json").read_text()
            )
            faults = (
                "config",
                "variant",
                "producer",
                "ready",
                "allocation",
                "full",
                "release",
                "register",
                "init",
                "guard",
                "payload",
                "reuse",
                "age",
                "capacity",
                "program",
                "loaded",
                "helper",
                "age-code",
                "ram",
                "image",
                "repair",
            )
            for fault in faults:
                r = copy.deepcopy(source)
                c = r["cases"]["demo"]
                if fault == "config":
                    r["configuration"]["emulator_sha256"] = "0" * 64
                elif fault == "variant":
                    r["cases"].pop("wrong")
                elif fault == "producer":
                    c["server"]["version"] = "unknown"
                elif fault == "ready":
                    c["ready"] = [0]
                elif fault in (
                    "allocation",
                    "full",
                    "release",
                    "register",
                    "init",
                    "guard",
                    "payload",
                ):
                    pos = {
                        "allocation": 2,
                        "full": 2 + 255 * 5,
                        "release": 4,
                        "register": 6,
                        "init": 1282,
                        "guard": 1283,
                        "payload": 1292,
                    }[fault]
                    c["packet"][pos] ^= 1
                elif fault == "reuse":
                    r["cases"]["wrong"]["preview"][4] = 1
                elif fault == "age":
                    c["preview"][6] = 255
                elif fault == "capacity":
                    r["cases"]["custom"]["capacity"] = 8
                elif fault == "program":
                    c["program_sha256"] = "0" * 64
                elif fault == "loaded":
                    c["loaded_bytes"][0] ^= 1
                elif fault == "helper":
                    c["helper_bytes"][0] ^= 1
                elif fault == "age-code":
                    c["age_bytes"][0] ^= 1
                elif fault == "ram":
                    c["state_bytes"] = 0
                elif fault == "image":
                    c["image_sha256"] = "0" * 64
                else:
                    r["cases"]["repaired"]["program_sha256"] = "0" * 64
                with (
                    self.subTest(system=system, fault=fault),
                    self.assertRaises((AssertionError, KeyError, ValueError)),
                ):
                    C.check(system, r)

    def test_forged_program_is_rebuilt(self):
        """A consistent claim of other bytes is caught only by the rebuild."""
        for system in C.V.SYSTEMS:
            r = json.loads(
                (C.V.folder(system) / "verification/results.json").read_text()
            )
            c = r["cases"]["custom"]
            binary = bytearray(zlib.decompress(bytes.fromhex(c["program_zlib"])))
            used = set()
            for prefix in ("helper", "age"):
                start = c[prefix + "_offset"]
                used |= set(range(start, start + c[prefix + "_code_bytes"]))
            i = next(i for i in range(len(c["loaded_bytes"])) if i not in used)
            binary[i + (2 if system == C.V.SYSTEMS[0] else 16)] ^= 1
            c["loaded_bytes"][i] ^= 1
            c["program_zlib"] = zlib.compress(bytes(binary)).hex()
            c["program_sha256"] = hashlib.sha256(binary).hexdigest()
            c["loaded_sha256"] = hashlib.sha256(bytes(c["loaded_bytes"])).hexdigest()
            with (
                self.subTest(system=system),
                self.assertRaisesRegex(AssertionError, "^Program bytes differ"),
            ):
                C.check(system, r)

    def test_source_digests_are_provenance(self):
        """Changed source or script text alone does not make a record stale."""
        for system in C.V.SYSTEMS:
            r = json.loads(
                (C.V.folder(system) / "verification/results.json").read_text()
            )
            r["sources"] = {path: "0" * 64 for path in r["sources"]}
            with self.subTest(system=system):
                C.check(system, r)

    def test_picture_independent_of_claimed_values(self):
        for system in C.V.SYSTEMS:
            c = json.loads(
                (C.V.folder(system) / "verification/results.json").read_text()
            )["cases"]["demo"]
            c["preview"][4] ^= 1
            with self.subTest(system=system), self.assertRaises(AssertionError):
                C.pixels(c, system)


if __name__ == "__main__":
    unittest.main()
