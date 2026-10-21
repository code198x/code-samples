"""Independent advance-sum layout and per-pixel proportional glyph oracle."""

from __future__ import annotations

import importlib.util
import itertools
import json
from pathlib import Path

S = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location(
    "proportional_bitmap", S.parent / "bitmap-text/model.py"
)
assert spec and spec.loader
TEXT = importlib.util.module_from_spec(spec)
spec.loader.exec_module(TEXT)
FONT = json.loads((S / "font.json").read_text())
DEFAULT = bytes(v for code in range(32, 96) for v in FONT["rows"][str(code)])
WIDTHS = bytes(FONT["widths"])


def evaluate(c: dict, grid: list[bytearray], r: dict, fault: str | None = None) -> dict:
    out = {
        "accepted": False,
        "consumed": 0,
        "lines": 0,
        "last_count": 0,
        "measured": 0,
        "first_x": 0,
        "last_x": 0,
        "last_y": 0,
        "calls": 0,
        "writes": 0,
    }
    data = r.get("bytes", [])
    length = r.get("length", len(data))
    left, top, width, height = r.get("rect", [21, 37, 176, 80])
    align, pitch, spacing = r.get("align", 1), r.get("pitch", 12), r.get("spacing", 1)
    first, count, fallback = (
        r.get("first", 32),
        r.get("count", 64),
        r.get("fallback", 63),
    )
    if not (
        width >= 8
        and height >= 8
        and 0 <= left
        and 0 <= top
        and left + width <= c["width"]
        and top + height <= c["height"]
        and align in (0, 1, 2)
        and 8 <= pitch <= 255
        and r["source_ptr"] + length <= 65536
        and r["metric_ptr"] + count <= 65536
        and 0 <= spacing <= 2
    ):
        return out
    if not TEXT.evaluate(
        c,
        [bytearray(c["width"]) for _ in range(c["height"])],
        dict(
            r,
            xy=[left, top],
            clip=[left, top, left + width, top + height],
            kind="string",
            length=0,
            bytes=[],
        ),
    )["accepted"]:
        return out
    # The execution fixtures use the original 64-glyph font and matching metric allocation.
    assert len(data) == length
    metrics = list(r.get("metric_values", WIDTHS)[:count])
    if len(metrics) != count or any(not 1 <= v <= 8 - spacing for v in metrics):
        return out
    resolved = [v if first <= v < first + count else fallback for v in data]
    advances = [metrics[v - first] + spacing for v in resolved]
    if r["kind"] == "measure":
        out.update(accepted=True, measured=sum(advances))
        return out
    spans = []
    if length and r["kind"] == "line":
        spans = [(0, length)]
    else:
        a = 0
        while a < length:
            b = a
            while b < length and data[b] != 10 and sum(advances[a : b + 1]) <= width:
                b += 1
            resume = b
            if b < length:
                if data[b] in (10, 32):
                    resume = b + 1
                else:
                    spaces = [i for i in range(a + 1, b) if data[i] == 32]
                    if spaces:
                        b = spaces[-1]
                        resume = b + 1
            if resume == a:
                return out
            spans.append((a, b))
            a = resume
    if any(sum(advances[a:b]) > width for a, b in spans) or (
        spans and (len(spans) - 1) * pitch + 8 > height
    ):
        return out
    out["accepted"] = True
    for row, (a, b) in enumerate(spans):
        line_width = sum(advances[a:b])
        free = width - line_width
        x = left + (0 if align == 0 else free if align == 2 else free // 2)
        y = top + row * pitch
        if row == 0:
            out["first_x"] = x
        out.update(last_x=x + line_width, last_y=y, last_count=b - a)
        out["measured"] = max(out["measured"], line_width)
        for i in range(a, b):
            code = resolved[i]
            advance = advances[i]
            rows = DEFAULT[(code - first) * 8 : (code - first + 1) * 8]
            fg, bg, mode = r.get("fg", 1), r.get("bg", 0), r.get("mode", 0)
            for yy, v in enumerate(rows, y):
                bits = [bool(v & (128 >> p)) for p in range(advance)]
                for col, ink in enumerate(bits):
                    if ink or mode:
                        grid[yy][x + col] = fg if ink else bg
                intervals = [(0, advance)] if mode else []
                for ink, items in itertools.groupby(
                    enumerate(bits), key=lambda item: item[1]
                ):
                    positions = [p for p, _ in items]
                    if ink:
                        intervals.append((positions[0], positions[-1] + 1))
                out["calls"] += len(intervals)
                out["writes"] += sum(
                    len({TEXT.P.offset(c, p, yy) for p in range(x + lo, x + hi)})
                    for lo, hi in intervals
                )
            x += 8 if fault == "advance" else advance
    out.update(consumed=length, lines=len(spans))
    return out
