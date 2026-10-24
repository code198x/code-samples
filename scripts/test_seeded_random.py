"""The retained generator checks must reject altered execution claims."""

import copy
import importlib.util
import json
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-seeded-random.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self):
        for system in C.systems():
            with self.subTest(system=system):
                C.check(system)

    def test_falsifications(self):
        for system in C.systems():
            original = json.loads(
                (C.V.folder(system) / "verification/results.json").read_text()
            )
            for fault in (
                "source",
                "config",
                "case",
                "producer",
                "seed",
                "cycle",
                "replay",
                "corrupt-zero",
                "register",
                "preview",
                "code",
                "load",
                "helper",
                "cost",
                "image",
                "repair",
            ):
                r = copy.deepcopy(original)
                c = r["cases"]["demo"]
                if fault == "source":
                    r["sources"][next(iter(r["sources"]))] = "0" * 64
                elif fault == "config":
                    r["configuration"]["emulator_sha256"] = "0" * 64
                elif fault == "case":
                    r["cases"].pop("custom")
                elif fault == "producer":
                    c["server"]["version"] = "unknown"
                elif fault == "seed":
                    c["packet"][1] = 0
                elif fault == "cycle":
                    c["packet"][514] = c["packet"][513]
                elif fault == "replay":
                    c["packet"][776] ^= 1
                elif fault == "corrupt-zero":
                    c["packet"][784] = 1
                elif fault == "register":
                    c["packet"][792] = 0
                elif fault == "preview":
                    r["cases"]["wrong"]["preview"][0] = 1
                elif fault == "code":
                    c["program_sha256"] = "0" * 64
                elif fault == "load":
                    c["loaded_bytes"][0] ^= 1
                elif fault == "helper":
                    c["helper_bytes"][0] ^= 1
                elif fault == "cost":
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

    def test_coupled_picture(self):
        for system in C.systems():
            c = copy.deepcopy(
                json.loads(
                    (C.V.folder(system) / "verification/results.json").read_text()
                )["cases"]["demo"]
            )
            c["preview"][0] ^= 1
            with self.subTest(system=system), self.assertRaises(AssertionError):
                C.pixels(c, system)


if __name__ == "__main__":
    unittest.main()
