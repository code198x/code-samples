"""Independent layout specification; existing per-pixel font oracle draws results."""

from __future__ import annotations

import importlib.util
from pathlib import Path

S = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location(
    "layout_text_oracle", S.parent / "bitmap-text/model.py"
)
assert spec and spec.loader
TEXT = importlib.util.module_from_spec(spec)
spec.loader.exec_module(TEXT)


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
    if r["kind"] == "measure":
        out.update(accepted=True, measured=length * 8)
        return out
    left, top, width, height = r.get("rect", [21, 37, 176, 80])
    align, pitch = r.get("align", 1), r.get("pitch", 12)
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
    ):
        return out
    cfg = dict(
        r,
        xy=[left, top],
        clip=[left, top, left + width, top + height],
        kind="string",
        length=0,
        bytes=[],
    )
    declaration = TEXT.evaluate(
        c, [bytearray(c["width"]) for _ in range(c["height"])], cfg
    )
    if not declaration["accepted"]:
        return out
    assert len(data) == length
    # Plan using slices and delimiter positions, independent of the native loop.
    spans = []
    if length and r["kind"] == "line":
        spans = [(0, length)]
    elif length:
        position = 0
        while position < length:
            limit = min(length, position + width // 8)
            newlines = [i for i in range(position, limit) if data[i] == 10]
            end = newlines[0] if newlines else limit
            spans.append((position, end))
            position = end + (end < length and data[end] == 10)
    advance = 4 if fault == "width" else 8
    if any((b - a) * advance > width for a, b in spans) or (
        spans and (len(spans) - 1) * pitch + 8 > height
    ):
        return out
    out["accepted"] = True
    for row, (a, b) in enumerate(spans):
        line_width = (b - a) * advance
        free = width - line_width
        offset = 0 if align == 0 else free if align == 2 else free // 2
        x = (0 if fault == "origin" else left) + offset
        y = top + row * pitch
        draw = TEXT.evaluate(
            c,
            grid,
            dict(
                r,
                kind="string",
                bytes=data[a:b],
                length=b - a,
                xy=[x, y],
                clip=[left, top, left + width, top + height],
                source_ptr=r["source_ptr"] + a,
            ),
        )
        assert draw["accepted"]
        if row == 0:
            out["first_x"] = x
        out["measured"] = max(out["measured"], line_width)
        out.update(last_x=x + line_width, last_y=y, last_count=b - a)
        out["calls"] += draw["calls"]
        out["writes"] += draw["writes"]
    out.update(consumed=length, lines=len(spans))
    return out
