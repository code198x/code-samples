"""Independent raster and packing model: closed-form lines and implicit ellipses.

The emulator executes incremental machine arithmetic. This reference recomputes
ellipse F(x+1,y+1) with Python integers, and rounds line coordinates directly.
It never imports the assembled routines, their mask tables or generated output.
"""

from __future__ import annotations

from collections import defaultdict
from typing import Any


def line(a: int, b: int, c: int, d: int, omit_last: bool) -> set[tuple[int, int]]:
    original_end = c, d
    if (a, b) > (c, d):
        a, b, c, d = c, d, a, b
    dx, dy = c - a, abs(d - b)
    sy = 1 if b <= d else -1
    if dx == dy == 0:
        result = {(a, b)}
    elif dx >= dy:
        result = {
            (a + i, b + sy * ((2 * i * dy + dx) // (2 * dx))) for i in range(dx + 1)
        }
    else:
        result = {
            (a + (2 * i * dx + dy) // (2 * dy), b + sy * i) for i in range(dy + 1)
        }
    if omit_last:
        result.discard(original_end)
    return result


def ellipse(a: int, b: int, rx: int, ry: int) -> set[tuple[int, int]]:
    if rx == 0:
        return {(a, y) for y in range(b - ry, b + ry + 1)}
    if ry == 0:
        return {(x, b) for x in range(a - rx, a + rx + 1)}
    points: set[tuple[int, int]] = set()
    x, y = -rx, 0
    a2, b2 = rx * rx, ry * ry
    while x <= 0:
        points.update((a + sx * x, b + sy * y) for sx in [-1, 1] for sy in [-1, 1])
        # Evaluate the implicit ellipse at the next diagonal grid location.
        decision = 2 * (b2 * (x + 1) ** 2 + a2 * (y + 1) ** 2 - a2 * b2)
        step_x = decision >= b2 * (2 * x + 1)
        step_y = decision <= a2 * (2 * y + 1)
        if not (step_x or step_y):
            raise AssertionError("Reference curve did not progress")
        x += step_x
        y += step_y
    points.update((a, b + sign * i) for i in range(y + 1, ry + 1) for sign in [-1, 1])
    return points


def geometry(
    c: dict[str, Any], r: dict[str, Any]
) -> tuple[bool, set[tuple[int, int]], int, int]:
    a, b, d, e = r["coords"]
    op = r["op"]
    flags = r.get("flags", 0)
    pen = r.get("pen", 1)
    left, top, right, bottom = r.get("clip", (0, 0, c["width"], c["height"]))
    valid = (
        op in range(3)
        and 0 <= pen <= c["pen_max"]
        and -512 <= a <= 511
        and -512 <= b <= 511
        and 0 <= left < right <= c["width"]
        and 0 <= top < bottom <= c["height"]
    )
    kind = r["kind"]
    if kind == "line":
        valid &= flags in (0, 1) and -512 <= d <= 511 and -512 <= e <= 511
    else:
        valid &= (
            flags == 0
            and 0 <= d <= 255
            and (kind in ["circle", "fill_circle"] or 0 <= e <= 255)
        )
    if not valid:
        return False, set(), 0, 0
    if kind == "line":
        all_points = line(a, b, d, e, bool(flags))
    else:
        ry = d if kind in ["circle", "fill_circle"] else e
        all_points = ellipse(a, b, d, ry)
        if kind.startswith("fill_"):
            rows: dict[int, list[int]] = defaultdict(list)
            for x, y in all_points:
                rows[y].append(x)
            all_points = {
                (x, y) for y, xs in rows.items() for x in range(min(xs), max(xs) + 1)
            }
    points = {(x, y) for x, y in all_points if left <= x < right and top <= y < bottom}
    if not points:
        return True, points, 0, 0
    axes = (kind == "line" and (a == d or b == e)) or (
        kind != "line"
        and (d == 0 or (kind not in ["circle", "fill_circle"] and e == 0))
    )
    if axes:
        calls = 1
        writes = len({offset(c, x, y) for x, y in points})
    elif kind.startswith("fill_"):
        calls = len({y for _, y in points})
        writes = len({offset(c, x, y) for x, y in points})
    else:
        calls = len(points)
        writes = calls
    return True, points, calls, writes


def offset(c: dict[str, Any], x: int, y: int) -> int:
    ident = c["machine_id"]
    if ident == "spectrum":
        return (y // 64) * 2048 + (y % 8) * 256 + ((y % 64) // 8) * 32 + x // 8
    if ident == "acorn-bbc-micro":
        return (y // 8) * 320 + (x // 8) * 8 + y % 8
    if ident == "amstrad-cpc":
        return (y % 8) * 2048 + (y // 8) * 80 + x // 4
    return y * 32 + x // 8


def packed(c: dict[str, Any], grid: list[bytearray], padding: int = 0) -> bytes:
    data = bytearray([padding]) * c["length"]
    for y, row in enumerate(grid):
        for x, pen in enumerate(row):
            if x % (4 if c["machine_id"] == "amstrad-cpc" else 8) == 0:
                data[offset(c, x, y)] = 0
            if c["machine_id"] == "amstrad-cpc":
                data[offset(c, x, y)] |= ((pen & 1) << (7 - x % 4)) | (
                    ((pen >> 1) & 1) << (3 - x % 4)
                )
            elif pen:
                data[offset(c, x, y)] |= 128 >> (x % 8)
    return bytes(data)


def apply(
    c: dict[str, Any], grid: list[bytearray], r: dict[str, Any]
) -> dict[str, Any]:
    accepted, points, calls, writes = geometry(c, r)
    for x, y in points:
        pen = r.get("pen", 1) if c["machine_id"] == "amstrad-cpc" else 1
        grid[y][x] = pen if r["op"] == 0 else 0 if r["op"] == 1 else grid[y][x] ^ pen
    return {
        "accepted": accepted,
        "calls": calls,
        "writes": writes,
        "pixels": len(points),
    }


def frame(c: dict[str, Any], grid: list[bytearray]) -> tuple[tuple[int, int], bytes]:
    ident = c["machine_id"]
    w, h, left, top, sx, sy, border, palette = {
        "spectrum": (352, 296, 48, 48, 1, 1, (0, 0, 0), [(0, 0, 0), (194, 194, 194)]),
        "acorn-bbc-micro": (
            640,
            512,
            0,
            0,
            2,
            2,
            (0, 0, 0),
            [(0, 0, 0), (255, 255, 255)],
        ),
        "dragon": (744, 312, 120, 63, 2, 1, (5, 5, 5), [(0, 16, 0), (29, 170, 29)]),
        "amstrad-cpc": (
            832,
            288,
            96,
            48,
            2,
            1,
            (0, 0, 0),
            [(0, 0, 0), (255, 255, 255), (0, 255, 0), (0, 0, 255)],
        ),
    }[ident]
    out = bytearray(bytes([*border, 255]) * (w * h))
    for y, row in enumerate(grid):
        for x, p in enumerate(row):
            rgba = bytes([*palette[p], 255])
            for yy in range(sy):
                for xx in range(sx):
                    at = ((top + y * sy + yy) * w + left + x * sx + xx) * 4
                    out[at : at + 4] = rgba
    return (w, h), bytes(out)


def primitive(
    c: dict[str, Any], grid: list[bytearray], r: dict[str, Any]
) -> dict[str, Any]:
    x, y, end_x, end_y = r["coords"]
    kind = r["kind"]
    op = r["op"]
    pen = r.get("pen", 1)
    if kind in ["pixel", "read", "vspan"]:
        end_x = x + 1
    if kind in ["pixel", "read", "hspan"]:
        end_y = y + 1
    valid = (
        op in range(3)
        and pen in range(4)
        and 0 <= x < end_x <= c["width"]
        and 0 <= y < end_y <= c["height"]
    )
    points = (
        {
            (xx, yy)
            for yy in range(y, end_y)
            for xx in range(x, end_x)
            if kind != "box" or yy in (y, end_y - 1) or xx in (x, end_x - 1)
        }
        if valid
        else set()
    )
    value = grid[y][x] if valid and kind == "read" else 0
    if kind != "read":
        for xx, yy in points:
            grid[yy][xx] = pen if op == 0 else 0 if op == 1 else grid[yy][xx] ^ pen
    return {
        "accepted": valid,
        "read": value,
        "writes": 0
        if kind == "read"
        else len({offset(c, xx, yy) for xx, yy in points}),
    }
