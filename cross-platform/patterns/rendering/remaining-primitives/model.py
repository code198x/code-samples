"""Independent selected-pixel specification; no native span iterator is reused."""

from __future__ import annotations

from collections import defaultdict
from typing import Any


def offset(c: dict[str, Any], x: int, y: int) -> int:
    if c["machine_id"] in ["acorn-electron", "c64"]:
        return (y // 8) * 320 + (x // 8) * 8 + y % 8
    return y * (c["width"] // 8) + x // 8


def baseline(c: dict[str, Any], pattern: bool = False) -> bytearray:
    data = bytearray([165 if pattern else 0] * c["length"])
    if pattern:
        for y in range(c["height"]):
            for b in range(c["width"] // 8):
                data[offset(c, b * 8, y)] = (b * 19 + y * 37) & 255
    return data


def evaluate(
    c: dict[str, Any], data: bytes | bytearray, r: dict[str, Any]
) -> dict[str, Any]:
    a, b, d, e = r["coords"]
    kind = r["kind"]
    op = r.get("op", 0)
    if kind in ["pixel", "read", "vspan"]:
        d = a + 1
    if kind in ["pixel", "read", "hspan"]:
        e = b + 1
    if not (
        op in range(3)
        and (kind != "read" or op == 0)
        and 0 <= a < d <= c["width"]
        and 0 <= b < e <= c["height"]
    ):
        return {"accepted": False, "read": 0, "writes": 0}
    if kind == "read":
        return {
            "accepted": True,
            "read": int(bool(data[offset(c, a, b)] & (128 >> (a % 8)))),
            "writes": 0,
        }
    masks = defaultdict(int)
    for y in range(b, e):
        for x in range(a, d):
            if kind != "box" or x in (a, d - 1) or y in (b, e - 1):
                masks[offset(c, x, y)] |= 128 >> (x % 8)
    for at, mask in masks.items():
        if op == 0:
            data[at] |= mask
        elif op == 1:
            data[at] &= ~mask
        else:
            data[at] ^= mask
    return {"accepted": True, "read": 0, "writes": len(masks)}


def frame(c: dict[str, Any], data: bytes | bytearray) -> tuple[tuple[int, int], bytes]:
    w, h, left, top, sx, sy = {
        "acorn-atom": (372, 288, 60, 48, 1, 1),
        "acorn-electron": (640, 256, 0, 0, 2, 1),
        "c64": (416, 312, 48, 51, 1, 1),
        "commodore-amiga": (768, 576, 82, 38, 2, 2),
    }[c["machine_id"]]
    atom = c["machine_id"] == "acorn-atom"
    border = (0, 64, 0) if atom else (0, 0, 0)
    bg = (0, 32, 0) if atom else border
    fg = (29, 170, 29) if atom else (255, 255, 255)
    out = bytearray(bytes([*border, 255]) * (w * h))
    for y in range(c["height"]):
        line = bytearray()
        for x in range(c["width"]):
            rgb = fg if data[offset(c, x, y)] & (128 >> (x % 8)) else bg
            line += bytes([*rgb, 255]) * sx
        for dy in range(sy):
            at = ((top + y * sy + dy) * w + left) * 4
            out[at : at + len(line)] = line
    return (w, h), bytes(out)
