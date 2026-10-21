"""Independent destination expectations for the four complete callers."""

from __future__ import annotations


def expected(c: dict) -> tuple[bytes, list[int]]:
    zx = c["id"].startswith("sinclair-")
    zx80 = c["id"].endswith("zx80")
    aq = c["id"] == "mattel-aquarius"
    widths = ([10, 10, 10] + [0] * 19) if zx80 else [32] * 22
    if zx:
        raw = bytearray([118]) + bytearray(
            v for n in widths[: 3 if zx80 else 22] for v in [*([0] * n), 118]
        )
    else:
        raw = bytearray([32] * 1024 + ([240] * 1024 if aq else []))
    flags = []
    for x, y, count, kind in c["cases"]:
        fits = bool(
            count
            and x < c["cols"]
            and y < c["rows"]
            and count <= c["cols"] - x
            and kind != 1
            and not (aq and x == y == 0)
        )
        if zx and y < 22:
            fits = fits and x + count <= widths[y]
        flags.append(128 + fits)
        if fits:
            at = 1 + sum(n + 1 for n in widths[:y]) + x if zx else y * 40 + x
            codes = (
                [166]
                if kind == 2
                else (
                    [38, 39, 40, 41, 42, 43] * 7
                    if zx
                    else (
                        [1, 2, 3, 4, 5, 6] * 7
                        if c["cpu"] == "6502"
                        else [65, 66, 67, 68, 69, 70] * 7
                    )
                )
            )[:count]
            raw[at : at + count] = bytes(codes)
            if aq:
                raw[at + 1024 : at + 1024 + count] = bytes([31] * count)
    return bytes(raw), flags
