"""Independent selected-pixel/byte specification for Oric and ANTIC primitives."""

from __future__ import annotations

from collections import defaultdict


def offset(c, x, y):
    if c["machine_id"] == "oric":
        return y * 40 + 2 + x // 6
    return (y // 102) * 4096 + (y % 102) * 40 + x // 8


def baseline(c, pattern=False):
    data = bytearray(c["length"])
    if c["machine_id"] == "oric":
        data[:] = bytes([64]) * len(data)
        for y in range(200):
            data[y * 40 : y * 40 + 2] = bytes([16, 7])
            for col in range(38):
                data[y * 40 + col + 2] = (
                    64
                    | ((0x15 if (col + y) % 2 else 0x2A) if pattern else 0)
                    | (128 if pattern and (col + y) % 3 == 0 else 0)
                )
    elif pattern:
        data[:] = bytes([165]) * len(data)
        for y in range(c["height"]):
            for col in range(40):
                data[offset(c, col * 8, y)] = (col * 19 + y * 37) & 255
    return data


def evaluate(c, data, r):
    a, b, d, e = r["coords"]
    kind = r["kind"]
    op = r.get("op", 0)
    if kind in ["pixel", "read", "vspan"]:
        d = a + 1
    if kind in ["pixel", "read", "hspan"]:
        e = b + 1
    valid = (
        op in range(3)
        and (kind != "read" or op == 0)
        and 0 <= a < d <= c["width"]
        and 0 <= b < e <= c["height"]
    )
    empty = {"accepted": False, "read": 0, "writes": 0}
    if not valid:
        return empty
    width = 6 if c["machine_id"] == "oric" else 8
    if c["machine_id"] == "oric" and any(
        data[y * 40 + 2 + col] & 64 == 0
        for y in range(b, e)
        for col in range(a // 6, (d - 1) // 6 + 1)
    ):
        return empty
    points = {
        (x, y)
        for y in range(b, e)
        for x in range(a, d)
        if kind != "box" or x in (a, d - 1) or y in (b, e - 1)
    }
    if kind == "read":
        return {
            "accepted": True,
            "read": int(bool(data[offset(c, a, b)] & (1 << (width - 1 - a % width)))),
            "writes": 0,
        }
    masks = defaultdict(int)
    for x, y in points:
        masks[offset(c, x, y)] |= 1 << (width - 1 - x % width)
    for addr, mask in masks.items():
        if op == 0:
            data[addr] |= mask
        elif op == 1:
            data[addr] &= ~mask
        else:
            data[addr] ^= mask
    return {"accepted": True, "read": 0, "writes": len(masks)}


def frame(c, data):
    oric = c["machine_id"] == "oric"
    w, h = (240, 224) if oric else (376, 240)
    bg = (0, 0, 0) if oric else (4, 4, 4)
    fg = (255, 255, 255) if oric else (211, 211, 211)
    out = bytearray(bytes([*bg, 255]) * (w * h))
    left, top = (12, 0) if oric else (28, 24)
    width = 6 if oric else 8
    for y in range(c["height"]):
        for x in range(c["width"]):
            value = data[offset(c, x, y)]
            bit = bool(value & (1 << (width - 1 - x % width)))
            if oric:
                # Qualification uses fixed white ink / black paper. The injected
                # invalid control is code 7 (same ink), whose own six pixels are paper.
                bit = (bit ^ bool(value & 128)) if (value & 127) >= 32 else False
            rgb = fg if bit else bg
            at = ((top + y) * w + left + x) * 4
            out[at : at + 4] = bytes([*rgb, 255])
    return (w, h), bytes(out)
