"""Independent glyph-to-pixel specification and separately enumerated span cost."""

from __future__ import annotations

import importlib.util
import itertools
import json
from pathlib import Path
from typing import Any

S = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location(
    "text_bitmap_packing", S.parent / "geometry/model.py"
)
assert spec and spec.loader
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
FONT = json.loads((S / "font.json").read_text())
DEFAULT = bytes(v for k in range(32, 96) for v in FONT["rows"][str(k)])
SYNTHETIC = bytes(
    ((code * 13 + row * 37) ^ (0x81 >> (row % 4))) & 255
    for code in range(256)
    for row in range(8)
)


def evaluate(c: dict, grid: list[bytearray], r: dict[str, Any]) -> dict:
    x, y = r["xy"]
    first = r.get("first", 32)
    count = r.get("count", 64)
    fallback = r.get("fallback", 63)
    clip = r.get("clip", [0, 0, c["width"], c["height"]])
    left, top, right, bottom = clip
    mode = r.get("mode", 0)
    fg = r.get("fg", 1)
    bg = r.get("bg", 0)
    values = r.get("bytes", [])
    limit = r.get("length", len(values)) if r["kind"] == "string" else 1
    font_ptr = r["font_ptr"]
    source_ptr = r["source_ptr"]
    valid = (
        -512 <= x <= 511
        and -512 <= y <= 511
        and mode in (0, 1)
        and 0 <= fg <= c["pen_max"]
        and 0 <= bg <= c["pen_max"]
        and 0 <= left < right <= c["width"]
        and 0 <= top < bottom <= c["height"]
        and 1 <= count <= 256
        and first + count <= 256
        and first <= fallback < first + count
        and font_ptr + 8 * count <= 65536
        and (r["kind"] == "char" or source_ptr + limit <= 65536)
    )
    if not valid:
        return {
            "accepted": False,
            "next_x": x,
            "consumed": 0,
            "missing": 0,
            "writes": 0,
            "calls": 0,
        }
    font = SYNTHETIC if r.get("font") == "synthetic" else DEFAULT
    codes = [r.get("code", 65)] if r["kind"] == "char" else values[:limit]
    assert len(codes) == limit
    missing = 0
    writes = 0
    calls = 0
    for j, code in enumerate(codes):
        if not first <= code < first + count:
            code = fallback
            missing += 1
        rows = font[(code - first) * 8 : (code - first + 1) * 8]
        assert len(rows) == 8
        for row, value in enumerate(rows):
            yy = y + row
            xx = x + j * 8
            bits = [bool(value & (1 << (7 - p))) for p in range(8)]
            # Outcome: assign each visible logical pixel directly. No native shift/run loop.
            for column, ink in enumerate(bits):
                px = xx + column
                if left <= px < right and top <= yy < bottom and (ink or mode):
                    grid[yy][px] = fg if ink else bg
            # Cost: enumerate maximal foreground intervals independently using groupby.
            intervals = [(0, 8)] if mode else []
            for ink, items in itertools.groupby(
                enumerate(bits), key=lambda item: item[1]
            ):
                positions = [p for p, _ in items]
                if ink:
                    intervals.append((positions[0], positions[-1] + 1))
            for a, b in intervals:
                lo = max(left, xx + a)
                hi = min(right, xx + b)
                if top <= yy < bottom and lo < hi:
                    calls += 1
                    writes += len({P.offset(c, p, yy) for p in range(lo, hi)})
    return {
        "accepted": True,
        "next_x": x + limit * 8,
        "consumed": limit,
        "missing": missing,
        "writes": writes,
        "calls": calls,
    }
