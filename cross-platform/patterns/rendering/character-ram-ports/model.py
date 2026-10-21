"""Independent logical characters, name placement and inverse-pixel oracle."""

from __future__ import annotations

from typing import Any

VARIANTS = ("positive", "wrong-slot", "wrong-name")


def asset(c: dict[str, Any], count: int, start: int = 0) -> bytes:
    width = 6 if c["machine_id"] == "oric" else 8
    return bytes(
        sum(
            (1 << (width - 1 - x))
            for x in range(width)
            if x == y % width or x == width - 1 - y % width or y == n % 8
        )
        for n in range(start, start + count)
        for y in range(8)
    )


def source(c: dict[str, Any]) -> bytes:
    return asset(c, 3, 17)


def bulk(c: dict[str, Any]) -> bytes:
    return asset(c, c["slots"])


def spans(c: dict[str, Any]) -> list[tuple[int, int]]:
    if c["machine_id"] == "oric":
        return [
            (0xB400, 1024),
            (0xBB80, 1120),
            (0xB800, 16),
            (0xBB70, 16),
            (0xBFE0, 16),
        ]
    if c["machine_id"] == "jupiter-ace":
        return [(0x2C00, 1024), (0x2400, 1024), (0x3C00, 16)]
    return [
        (0x4000, 1024),
        (0x5000, 960),
        (0x3FF0, 16),
        (0x4400, 16),
        (0x4FF0, 16),
        (0x53C0, 16),
        (0x3000, 32),
    ]


def name_offset(c: dict[str, Any], cell: int) -> int:
    return 1024 + (
        cell // 37 * 40 + cell % 37 + 3 if c["machine_id"] == "oric" else cell
    )


def initial(c: dict[str, Any]) -> bytearray:
    data = bytearray(sum(length for _, length in spans(c)))
    if c["machine_id"] == "oric":
        data[:256] = bytes([165]) * 256
        for row in range(28):
            data[1024 + row * 40 : 1024 + (row + 1) * 40] = (
                bytes([16, 7, 26]) + bytes([32]) * 37
            )
        data[2144:] = bytes([165]) * 48
    elif c["machine_id"] == "jupiter-ace":
        data[1792:] = bytes([165]) * 272
    else:
        data[1984:2048] = bytes([165]) * 64
        data[2048:] = (
            bytes([0x70, 0x70, 0x70, 0x42, 0, 0x50])
            + bytes([2]) * 23
            + bytes([0x41, 0, 0x30])
        )
    first = c["first"] + 1
    data[first * 8 : (first + 2) * 8] = asset(c, 2)
    for cell in [c["first_cell"], c["first_cell"] + 1]:
        data[name_offset(c, cell)] = first
    return data


def cases(c: dict[str, Any]) -> list[dict[str, Any]]:
    first = c["first"]
    end = first + c["slots"]
    visible = c["first_cell"]
    cells = c["cols"] * c["rows"]
    items = [
        ("replace", first + 1, 255, 0, 0),
        ("select", 0, 0, first + 2, visible),
        ("replace", first + 1, 0, 0, 0),
        ("install", first, 1, 0, 0),
        ("install", end - 1, 1, 0, 0),
        ("select", 0, 0, end - 1, visible + 2),
        ("select", 0, 0, end - 1, cells - 1),
        ("select", 0, 0, end - 1 + 128, visible + 2),
        ("install", end - 2, 2, 0, 0),
        ("install", end - 1, 2, 0, 0),
        ("install", first, 0, 0, 0),
        ("replace", end, 0, 0, 0),
        ("install", 255, 2, 0, 0),
        ("select", 0, 0, first + 1, cells),
        ("select", 0, 0, first + 1, 65535),
        ("bulk", first, c["slots"], 0, 0),
        ("select", 0, 0, first + 1 + 128, visible),
        ("init", 0, 0, 0, 0),
        ("replace", first + 1, 0, 0, 0),
        ("select", 0, 0, first + 1, visible),
        ("select", 0, 0, first + 1, visible + 1),
    ]
    if first:
        items += [
            ("install", first - 1, 1, 0, 0),
            ("select", 0, 0, 31, visible),
            ("select", 0, 0, 159, visible),
            ("select", 0, 0, 160, visible),
            ("select", 0, 0, 255, visible),
            ("select", 0, 0, first + 1, 36),
            ("select", 0, 0, first + 1, 37),
        ]
    return [
        {"kind": k, "first": f, "count": n, "code": g, "cell": x}
        for k, f, n, g, x in items
    ]


def apply(c: dict[str, Any], data: bytearray, call: dict[str, Any]) -> tuple[bool, int]:
    kind = call["kind"]
    first, count, cell, code = (call[k] for k in ["first", "count", "cell", "code"])
    if kind == "init":
        start = c["first"] * 8
        data[start:1024] = bytes(1024 - start)
        for i in range(c["cols"] * c["rows"]):
            data[name_offset(c, i)] = 32 if c["first"] else 0
        return True, c["slots"] * 8 + c["cols"] * c["rows"]
    if kind == "select":
        if cell >= c["cols"] * c["rows"] or (c["first"] and code & 127 < 32):
            return False, 0
        data[name_offset(c, cell)] = code
        return True, 1
    count = 1 if kind == "replace" else count
    if not count or first < c["first"] or first + count > 128:
        return False, 0
    size = count * 8
    data[first * 8 : (first + count) * 8] = (bulk(c) if kind == "bulk" else source(c))[
        :size
    ]
    return True, size


def rgba(c: dict[str, Any], data: bytearray) -> tuple[tuple[int, int], bytes]:
    ident = c["machine_id"]
    w, h, left, top = (
        (320, 288, 32, 48)
        if ident == "jupiter-ace"
        else (240, 224, 18, 0)
        if ident == "oric"
        else (376, 240, 28, 24)
    )
    bg = (4, 4, 4) if ident == "atari-800xl" else (0, 0, 0)
    fg = (
        (211, 211, 211)
        if ident == "atari-800xl"
        else (255, 255, 255)
        if ident == "oric"
        else (207, 207, 207)
    )
    out = bytearray(bytes([*bg, 255]) * (w * h))
    width = 6 if ident == "oric" else 8
    for cell in range(c["cols"] * c["rows"]):
        code = data[name_offset(c, cell)]
        for y in range(8):
            row = data[(code & 127) * 8 + y]
            for x in range(width):
                on = bool(row & (1 << (width - 1 - x))) ^ bool(code & 128)
                at = (
                    (top + cell // c["cols"] * 8 + y) * w
                    + left
                    + cell % c["cols"] * width
                    + x
                ) * 4
                out[at : at + 4] = bytes([*(fg if on else bg), 255])
    return (w, h), bytes(out)
