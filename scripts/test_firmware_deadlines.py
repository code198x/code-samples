"""Prove the retained checker rejects plausible omissions and altered results."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "checker", Path(__file__).with_name("check-firmware-deadlines.py")
)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Missing checker")
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class DeadlineEvidence(unittest.TestCase):
    def test_real_records(self) -> None:
        for machine in C.V.SYSTEMS:
            with self.subTest(machine=machine):
                C.check(machine)

    def test_altered_evidence_is_rejected(self) -> None:
        for machine in C.V.SYSTEMS:
            original = json.loads(
                (C.V.folder(machine) / "verification/results.json").read_text()
            )
            mutations = [
                lambda x: x.update(status="built"),
                lambda x: x.update(machine_id="another-machine"),
                lambda x: x.update(language="basic"),
                lambda x: x.update(sources={}),
                lambda x: x.update(observers={}),
                lambda x: x.update(firmware_sha256={}),
                lambda x: x.update(emulator_sha256=""),
                lambda x: x["cases"].pop("repaired"),
                lambda x: x["cases"]["working"]["untimed_action"].update(active=1),
                lambda x: x["cases"]["working"]["running"].update(remaining=0),
                lambda x: x["cases"]["working"]["expiry"].update(turns=1),
                lambda x: x["cases"]["working"]["actions"]["disabled_after"].update(
                    turns=99
                ),
                lambda x: x["cases"]["working"]["idle"].update(guards=[0, 90]),
                lambda x: x["cases"]["working"].update(captures={}),
                lambda x: x["cases"]["wrong-input-gate"].update(fault_rejected=False),
                lambda x: x["arithmetic"].update(cases=[]),
                lambda x: x["arithmetic"]["observations"]["working"][
                    "bytes"
                ].__setitem__(0, 0),
                lambda x: x["arithmetic"]["observations"]["working"][
                    "bytes"
                ].__setitem__(-1, 0),
                lambda x: x["arithmetic"]["observations"]["wrong-zero-boundary"].update(
                    oracle_matches=True
                ),
            ]
            for index, mutate in enumerate(mutations):
                with self.subTest(machine=machine, mutation=index):
                    bad = copy.deepcopy(original)
                    mutate(bad)
                    with self.assertRaises((ValueError, KeyError)):
                        C.check(machine, bad)


if __name__ == "__main__":
    unittest.main()
