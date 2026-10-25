"""Independent set-based pool observations and capacity-boundary snapshots."""

from __future__ import annotations

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "existing_pool", Path(__file__).parents[1] / "object-pool/oracle.py"
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)


def packet(variant: str) -> list[int]:
    if variant in ["boundary-one", "boundary-max"]:
        capacity = 1 if variant == "boundary-one" else 255
        out = [165, capacity, 147] + [0] * capacity
        for free in [0, 1] if capacity == 1 else [0, 127, 128, 254, 255]:
            live = set(range(capacity)) - {free}
            available = sorted(set(range(capacity)) - live)
            chosen = available[0] if available else capacity
            carry = int(not available)
            if available:
                live.add(chosen)
            after = [int(i in live) for i in range(capacity)]
            released = chosen in live
            if released:
                live.remove(chosen)
            out += (
                [chosen, carry]
                + after
                + [int(not released), 1, 1]
                + [int(i in live) for i in range(capacity)]
                + [147]
            )
        out += [1] * capacity + [254] * capacity + [0] * (2 * capacity)
        return out + [90, 167, 239, 1, 1, 239]
    cap = 4 if variant == "custom" else 8
    wrong = variant == "wrong"
    base = M.packet(cap)
    preview = M.preview(cap, wrong) + [int(wrong)]
    checks = [int(preview[4] == 1), int(preview[8] == 0)]
    return base[:2] + [147] + base[2:] + preview + checks + [239]


def checks(variant: str) -> list[int]:
    return [0, 0] if variant == "wrong" else [1, 1]
