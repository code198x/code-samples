"""Qualify all declared interpreter targets and reject altered observations."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-pools.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)


class Pools(unittest.TestCase):
    def test_native_records_and_negative_controls(self) -> None:
        C.qualify()

    def test_all_occupancy_masks_choose_first_free_slot(self) -> None:
        for cap in [4, 8]:
            for mask in range(256):
                d = dict.fromkeys(C.M.FIELDS, 0)
                d.update(C=cap, M=1)
                for i in range(8):
                    d[f"F{i + 1}"] = int(bool(mask & (1 << i)))
                out = C.M.call(d)
                free = [i for i in range(cap) if not mask & (1 << i)]
                self.assertEqual(out["O"], bool(free))
                self.assertEqual(out["R"], free[0] if free else 255)

    def test_invalid_age_is_atomic_and_release_preserves_payload(self) -> None:
        d = dict.fromkeys(C.M.FIELDS, 0)
        d.update(C=8, M=3, F1=1, F2=1, L1=1, L2=0)
        out = C.M.call(d)
        self.assertEqual(
            (out["E"], out["F1"], out["F2"], out["L1"], out["L2"]), (1, 1, 1, 1, 0)
        )
        d.update(M=2, S=0)
        out = C.M.call(d)
        self.assertEqual((out["F1"], out["L1"], out["O"]), (0, 1, 1))


if __name__ == "__main__":
    unittest.main()
