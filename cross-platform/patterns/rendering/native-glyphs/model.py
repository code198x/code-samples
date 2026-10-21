"""Logical slot/plane/cell oracle, independent of the native upload routines."""

from __future__ import annotations

from typing import Any

VARIANTS = ("positive", "wrong-slot", "wrong-name")
CAPTURES = {0, 1, 5, 6}


def asset(c: dict[str, Any], count: int, start: int = 0) -> bytes:
    result = bytearray()
    for number in range(start, start + count):
        grid = []
        for row in range(8):
            line = []
            for column in range(8):
                if c["bpg"] == 8:
                    value = int(column == row or column == 7 - row or row == number % 8)
                else:
                    value = (
                        (column + row + number) % 4
                        if c["bpg"] == 16
                        else (column + 3 * row + number) % 16
                    )
                line.append(value)
            grid.append(line)
        planes = 1 if c["bpg"] == 8 else 2 if c["bpg"] == 16 else 4
        encoded = [
            [
                sum(((grid[y][x] >> p) & 1) * (2 ** (7 - x)) for x in range(8))
                for y in range(8)
            ]
            for p in range(planes)
        ]
        if planes == 4:
            result.extend(encoded[p][y] for y in range(8) for p in range(4))
        else:
            result.extend(value for plane in encoded for value in plane)
    return bytes(result)


def source(c: dict[str, Any]) -> bytes:
    return asset(c, 3, 17)


def bulk(c: dict[str, Any]) -> bytes:
    return asset(c, c["slots"] if c["cpu"] == "z80" else 255)


def expand_nes(data: bytearray) -> None:
    for address in range(0x2000, 0x3F00):
        data[address] = data[0x2000 + (address - 0x2000) % 0x800]
    for address in range(0x3F00, 0x4000):
        slot = (address - 0x3F00) % 32
        if slot in [16, 20, 24, 28]:
            slot -= 16
        data[address] = data[0x3F00 + slot]


def initial(c: dict[str, Any]) -> bytearray:
    if c["machine_id"] == "c64":
        data = bytearray(2048 + 1024 + 1024 + 32)
        data[2048 + 1000 : 2048 + 1024] = bytes([165]) * 24
        data[2048 + 1024 : 2048 + 2048] = bytes([1]) * 1024
        data[-32:] = bytes([165]) * 32
        font_offset, name_offset = 0, 2048
    else:
        data = bytearray(16384)
        if c["machine_id"] == "nes":
            data[0x1000:0x1020] = bytes([165]) * 32
            data[0x2400:0x2420] = bytes([165]) * 32
            data[0x23C0:0x2400] = bytes([228]) * 64
            data[0x3F00:0x3F20] = bytes([15, 18, 33, 48]) * 8
            font_offset, name_offset = 0, 0x2000
        else:
            data[0x3E00:0x3E10] = bytes([165]) * 16
            data[0x3F00] = 208
            font_offset, name_offset = 0, 0x3800
    bpg = c["bpg"]
    data[font_offset + bpg : font_offset + 3 * bpg] = asset(c, 2)
    n = c["first_cell"]
    step = 2 if c["cpu"] == "z80" else 1
    for cell in [n, n + 1]:
        data[name_offset + cell * step] = 1
    if c["machine_id"] == "nes":
        expand_nes(data)
    return data


def cases(c: dict[str, Any]) -> list[dict[str, int | str]]:
    slots = c["slots"]
    cells = c["cols"] * c["rows"]
    visible = c["first_cell"]
    maximum = 65535 if c["cpu"] == "z80" else 255
    items = [
        ("replace", 1, maximum, 0, 0, 0),
        ("select", 0, 0, 2, visible, 0),
        ("replace", 1, 0, 0, 0, 0),
        ("install", 0, 1, 0, 0, 0),
        ("install", slots - 1, 1, 0, 0, 0),
        ("select", 0, 0, slots - 1, visible + 2, 0),
        ("select", 0, 0, slots - 1, cells - 1, 0),
        ("install", slots - 2, 2, 0, 0, 0),
        ("install", slots - 1, 2, 0, 0, 0),
        ("install", 0, 0, 0, 0, 0),
        ("select", 0, 0, 0, cells, 0),
        ("select", 0, 0, 0, 65535, 0),
        ("install", slots - 1, maximum, 0, 0, 0),
        ("replace", slots - 1, 0, 0, 0, 0),
    ]
    if c["cpu"] == "z80":
        items += [
            ("install", 255, 2, 0, 0, 0),
            ("install", 256, 1, 0, 0, 0),
            ("select", 0, 0, 256, visible, 0),
            ("install", 448, 1, 0, 0, 0),
            ("install", 65535, 1, 0, 0, 0),
            ("select", 0, 0, 448, visible, 0),
            ("select", 0, 0, 65535, visible, 0),
            ("bulk", 0, 448, 0, 0, 0),
            ("bulk", 192, 256, 0, 0, 0),
            ("bulk", 1, 448, 0, 0, 0),
        ]
        for flags in [0, 2, 4, 6, 8, 10, 12, 16, 30, 1, 32, 255]:
            items.append(("select", 0, 0, 447, visible, flags))
    else:
        items += [("bulk", 0, 255, 0, 0, 0), ("bulk", 1, 255, 0, 0, 0)]
    items += [
        ("init", 0, 0, 0, 0, 0),
        ("replace", 1, 0, 0, 0, 0),
        ("select", 0, 0, 1, visible, 0),
        ("select", 0, 0, 1, visible + 1, 0),
    ]
    return [
        {"kind": k, "first": f, "count": n, "code": g, "cell": x, "attrs": a}
        for k, f, n, g, x, a in items
    ]


def apply(c: dict[str, Any], data: bytearray, call: dict[str, Any]) -> tuple[bool, int]:
    cells = c["cols"] * c["rows"]
    bpg = c["bpg"]
    name = (
        2048
        if c["machine_id"] == "c64"
        else 0x2000
        if c["machine_id"] == "nes"
        else 0x3800
    )
    step = 2 if c["cpu"] == "z80" else 1
    if call["kind"] == "init":
        data[: c["slots"] * bpg] = bytes(c["slots"] * bpg)
        data[name : name + cells * step] = bytes(cells * step)
        accepted, writes = True, c["slots"] * bpg + cells * step
    elif call["kind"] == "select":
        accepted = (
            call["cell"] < cells
            and call["code"] < c["slots"]
            and (c["cpu"] != "z80" or call["attrs"] & 0xE1 == 0)
        )
        writes = step if accepted else 0
        if accepted:
            at = name + call["cell"] * step
            data[at] = call["code"] & 255
            if step == 2:
                data[at + 1] = (call["code"] >> 8) | call["attrs"]
    else:
        n = 1 if call["kind"] == "replace" else call["count"]
        accepted = n > 0 and call["first"] + n <= c["slots"]
        writes = n * bpg if accepted else 0
        if accepted:
            at = call["first"] * bpg
            data[at : at + writes] = (bulk(c) if call["kind"] == "bulk" else source(c))[
                :writes
            ]
    if c["machine_id"] == "nes":
        expand_nes(data)
    return accepted, writes


def rgba(c: dict[str, Any], data: bytes | bytearray) -> tuple[tuple[int, int], bytes]:
    ident = c["machine_id"]
    w, h, ox, oy = (
        (416, 312, 48, 51)
        if ident == "c64"
        else (256, 240, 0, 0)
        if ident == "nes"
        else (160, 144, -48, -24)
        if ident == "sega-game-gear"
        else (280, 240, 12, 25)
    )
    output = bytearray(bytes([0, 0, 0, 255]) * (w * h))
    name = 2048 if ident == "c64" else 0x2000 if ident == "nes" else 0x3800
    for cell in range(c["cols"] * c["rows"]):
        attrs = 0
        code = data[name + cell * (2 if c["cpu"] == "z80" else 1)]
        if c["cpu"] == "z80":
            attrs = data[name + cell * 2 + 1]
            code |= (attrs & 1) << 8
        for y in range(8):
            for x in range(8):
                dx = ox + (cell % c["cols"]) * 8 + x
                dy = oy + (cell // c["cols"]) * 8 + y
                if not (0 <= dx < w and 0 <= dy < h):
                    continue
                sx = 7 - x if attrs & 2 else x
                sy = 7 - y if attrs & 4 else y
                base = code * c["bpg"]
                bit = 7 - sx
                if ident == "c64":
                    value = (data[base + sy] >> bit) & 1
                    rgb = (255, 255, 255) if value else (0, 0, 0)
                elif ident == "nes":
                    value = ((data[base + sy] >> bit) & 1) | (
                        ((data[base + 8 + sy] >> bit) & 1) << 1
                    )
                    rgb = [(0, 0, 0), (66, 64, 255), (100, 176, 255), (255, 254, 255)][
                        value
                    ]
                else:
                    value = sum(
                        ((data[base + sy * 4 + p] >> bit) & 1) << p for p in range(4)
                    )
                    n = value if not attrs & 8 else 0 if value == 0 else 15 - value
                    levels = (
                        [0, 85, 170, 255]
                        if ident == "sega-game-gear"
                        else [0, 89, 174, 255]
                    )
                    rgb = (levels[n % 4], levels[n // 4], levels[n % 4])
                at = (dy * w + dx) * 4
                output[at : at + 4] = bytes([*rgb, 255])
    return (w, h), bytes(output)
