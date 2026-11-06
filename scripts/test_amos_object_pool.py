"""Reject corrupted retained original-runtime pool evidence."""
from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("pool_check", Path(__file__).with_name("check-amos-object-pool.py"))
if spec is None or spec.loader is None:
    raise RuntimeError("Missing pool checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class PoolEvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.record = json.loads((C.V.V / "packets.json").read_text())
        # Source and script digests are provenance: rewriting them all is accepted.
        record = copy.deepcopy(cls.record)
        record["sources"] = dict.fromkeys(record["sources"], "0" * 64)
        callers = json.loads((C.V.V / "callers.json").read_text())
        callers["sources"] = dict.fromkeys(callers["sources"], "0" * 64)
        C.check(record, callers)

    def test_actual_native_records(self):
        C.check(self.record)

    def test_corruption_rejected(self):
        def change_packet(record, offset):
            case = record["cases"]["cases"]
            case["packet"][offset] ^= 1
            # Recompute digest: a self-consistent corrupt observation must fail.
            case["packet_sha256"] = hashlib.sha256(bytes(case["packet"])).hexdigest()

        mutations = {
            "missing variant": lambda r: r["cases"].pop("wrong-cases"),
            "forged imported program": lambda r: r["fixture"]["programs"].update({next(iter(r["fixture"]["programs"])): hashlib.sha256(b"forged").hexdigest()}),
            "changed runtime": lambda r: r["configuration"].update(runtime="different"),
            "stale imported source": lambda r: r["fixture"]["programs"].update(cases="0" * 64),
            "empty fixture identity": lambda r: r["fixture"].update(fixture_sha256=""),
            "missing completion": lambda r: change_packet(r, 190467),
            "upper occupancy bit": lambda r: change_packet(r, 28),
            "upper payload bit": lambda r: change_packet(r, 208),
            "invalid slot sign": lambda r: change_packet(r, 24),
            "wrong packet called repaired": lambda r: r["cases"].update({"repaired-cases": copy.deepcopy(r["cases"]["wrong-cases"])}),
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
            "missing single slot": lambda r: r["cases"].pop("single"),
            "wrong reuse": lambda r: r["cases"]["working"]["outputs"].__setitem__(-4, 8),
            "payload cleared": lambda r: r["cases"]["custom"]["outputs"].__setitem__(-2, 0),
            "forged owner program": lambda r: r["cases"]["custom"].update(program_sha256=hashlib.sha256(b"forged").hexdigest()),
            "changed owner capture": lambda r: r["cases"]["wrong"].update(image_sha256="0" * 64),
        }
        for label, mutate in mutations.items():
            with self.subTest(label=label):
                record = copy.deepcopy(original)
                mutate(record)
                with self.assertRaises(AssertionError):
                    C.check(self.record, record)

    def test_forged_imported_program_is_rejected(self):
        """A record claiming other imported AMOS text is caught by the typed-text check."""
        record = copy.deepcopy(self.record)
        first = next(iter(record["fixture"]["programs"]))
        record["fixture"]["programs"][first] = hashlib.sha256(b"forged").hexdigest()
        with self.assertRaisesRegex(AssertionError, "^Typed program differs"):
            C.check(record)


if __name__ == "__main__":
    unittest.main()
