"""Reject corrupted retained original-runtime game-flow evidence."""
from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("flow_check", Path(__file__).with_name("check-amos-game-flow.py"))
if spec is None or spec.loader is None:
    raise RuntimeError("Missing game-flow checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class FlowEvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.record = json.loads((C.V.V / "packets.json").read_text())
        C.check(cls.record)

    def test_actual_native_records(self):
        C.check(self.record)

    def test_corruption_rejected(self):
        def change_packet(record, offset):
            case = record["cases"]["cases"]
            case["packet"][offset] ^= 1
            # Recompute digest: a self-consistent corrupt observation must fail.
            case["packet_sha256"] = hashlib.sha256(bytes(case["packet"])).hexdigest()

        mutations = {
            "missing variant": lambda r: r["cases"].pop("cases"),
            "changed source": lambda r: r["sources"].update({next(iter(r["sources"])): "0" * 64}),
            "changed runtime": lambda r: r["configuration"].update(runtime="different"),
            "stale imported source": lambda r: r["fixture"]["programs"].update(cases="0" * 64),
            "empty fixture identity": lambda r: r["fixture"].update(fixture_sha256=""),
            "missing completion": lambda r: change_packet(r, 17283),
            "upper state bit": lambda r: change_packet(r, 8),
            "upper payload bit": lambda r: change_packet(r, 32),
            "stale entry pulse": lambda r: change_packet(r, 16),
            "zero case count": lambda r: r["cases"]["cases"].update(case_count=0),
            "wrong allocation": lambda r: r["cases"]["cases"].update(allocated_observer_bytes=1),
            "wrong producer": lambda r: r["cases"]["cases"]["server"].update(version="0"),
            "changed capture": lambda r: r["cases"]["cases"].update(image_sha256="0" * 64),
            "wrong bank address": lambda r: r["cases"]["cases"].update(bank_address=1),
        }
        for label, mutate in mutations.items():
            with self.subTest(label=label):
                record = copy.deepcopy(self.record)
                mutate(record)
                with self.assertRaises(AssertionError):
                    C.check(record)


    def test_owner_corruption_rejected(self):
        original = json.loads((C.V.V / "callers.json").read_text())
        mutations = {
            "missing repair": lambda r: r["cases"].pop("repaired"),
            "reset on resume": lambda r: r["cases"]["working"].update(outputs=[0, 3, 1, 2, 3, 2]),
            "changed health": lambda r: r["cases"]["custom"]["outputs"].__setitem__(4, 3),
            "changed owner source": lambda r: r["sources"].update({next(iter(r["sources"])): "0" * 64}),
            "changed owner capture": lambda r: r["cases"]["wrong"].update(image_sha256="0" * 64),
        }
        for label, mutate in mutations.items():
            with self.subTest(label=label):
                record = copy.deepcopy(original)
                mutate(record)
                with self.assertRaises(AssertionError):
                    C.check(self.record, record)


if __name__ == "__main__":
    unittest.main()
