"""The native ownership/flow evidence gate must reject altered observations."""

import copy
import importlib.util
import json
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-worldkit.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self):
        for topic, system in C.targets():
            C.V.TOPIC = topic
            with self.subTest(system=system):
                C.check(topic, system)

    def test_falsifications(self):
        for topic, system in C.targets():
            C.V.TOPIC = topic
            original = json.loads(
                (C.V.folder(system) / "verification/results.json").read_text()
            )
            for fault in (
                (
                    "source",
                    "config",
                    "case",
                    "producer",
                    "packet-header",
                    "packet-body",
                    "packet-tail",
                    "completion",
                    "observation",
                    "preview",
                    "code",
                    "load",
                    "helper",
                    "cost",
                    "static-data",
                    "image",
                    "repair",
                )
                + (("startup",) if system == "sinclair-zx-spectrum" else ())
                + ()
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
                elif fault == "packet-header":
                    c["packet"][1] ^= 1
                elif fault == "packet-body":
                    c["packet"][10] ^= 1
                elif fault == "packet-tail":
                    c["packet"][-2] ^= 1
                elif fault == "completion":
                    c["packet"][-1] = 0
                elif fault == "observation":
                    c["packet"][6] ^= 1
                elif fault == "preview":
                    r["cases"]["wrong"]["preview"][4] ^= 1
                elif fault == "code":
                    c["program_sha256"] = "0" * 64
                elif fault == "load":
                    c["loaded_bytes"][0] ^= 1
                elif fault == "helper":
                    c["helper_bytes"][0] ^= 1
                elif fault == "cost":
                    c["state_bytes"] = 0
                elif fault == "static-data":
                    c["static_data_bytes"] ^= 1
                elif fault == "image":
                    c["image_sha256"] = "0" * 64
                elif fault == "age":
                    c["age_bytes"][0] ^= 1
                elif fault == "startup":
                    c["startup"][-1]["reached"] = False
                else:
                    r["cases"]["repaired"]["program_sha256"] = "0" * 64
                with (
                    self.subTest(system=system, fault=fault),
                    self.assertRaises((AssertionError, KeyError, ValueError)),
                ):
                    C.check(topic, system, r)

    def test_coupled_picture(self):
        for topic, system in C.targets():
            C.V.TOPIC = topic
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
