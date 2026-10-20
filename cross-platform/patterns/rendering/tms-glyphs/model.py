"""Independent picture/name oracle: flat logical slots, no VDP write routine."""

from __future__ import annotations

from typing import Any

ORIGINAL = bytes(
    [129, 66, 36, 24, 24, 36, 66, 129, 255, 129, 165, 129, 165, 153, 129, 255]
)
SOURCE = bytes(((i * 37 + 11) ^ (i // 8) * 19) & 255 for i in range(24))
BULK = bytes((i * 17 + 3) & 255 for i in range(2040))
VARIANTS = ("positive", "wrong-slot", "wrong-name")


def initial() -> bytearray:
    data = bytearray(16384)
    data[8:24] = ORIGINAL
    data[0x800:0x810] = bytes([165]) * 16
    data[0x1800 + 66 : 0x1800 + 68] = bytes([1, 1])
    data[0x1B00] = 208
    data[0x2000:0x2020] = bytes([241]) * 32
    return data


def cases() -> list[dict[str, Any]]:
    calls = [
        ("replace", 1, 99, 0, 0),
        ("select", 0, 0, 2, 66),
        ("replace", 1, 0, 0, 0),
        ("install", 0, 1, 0, 0),
        ("install", 255, 1, 0, 0),
        ("select", 0, 0, 255, 767),
        ("install", 254, 2, 0, 0),
        ("install", 255, 2, 0, 0),
        ("install", 0, 0, 0, 0),
        ("select", 0, 0, 0, 768),
        ("select", 0, 0, 0, 65535),
        ("install", 255, 255, 0, 0),
        ("replace", 255, 0, 0, 0),
        ("select", 0, 0, 7, 65),
        ("select", 0, 0, 8, 64),
        ("bulk", 0, 255, 0, 0),
        ("bulk", 1, 255, 0, 0),
        ("select", 0, 0, 0, 0),
        ("select", 0, 0, 255, 766),
        ("init", 0, 0, 0, 0),
        ("replace", 1, 255, 0, 0),
        ("select", 0, 0, 1, 66),
        ("select", 0, 0, 1, 67),
        ("select", 0, 0, 1, 32),
    ]
    return [
        {"kind": k, "first": s, "count": n, "code": g, "cell": c}
        for k, s, n, g, c in calls
    ]


def apply(memory: bytearray, call: dict[str, Any]) -> tuple[bool, int]:
    kind = call["kind"]
    if kind == "init":
        memory[:2048] = bytes(2048)
        memory[0x1800:0x1B00] = bytes(768)
        return True, 2816
    if kind == "select":
        if call["cell"] >= 768:
            return False, 0
        memory[0x1800 + call["cell"]] = call["code"]
        return True, 1
    n = 1 if kind == "replace" else call["count"]
    if n == 0 or call["first"] + n > 256:
        return False, 0
    start = call["first"] * 8
    memory[start : start + n * 8] = (BULK if kind == "bulk" else SOURCE)[: n * 8]
    return True, n * 8


def pixels(
    cfg: dict[str, Any], memory: bytes | bytearray
) -> tuple[tuple[int, int], bytes]:
    pal = cfg["machine_id"] in ["memotech-mtx", "tatung-einstein"]
    w, h, ox, oy = (278, 288, 11, 51) if pal else (280, 240, 12, 25)
    image = bytearray(bytes([0, 0, 0, 255]) * (w * h))
    for cell in range(768):
        code = memory[0x1800 + cell]
        for row in range(8):
            bits = memory[code * 8 + row]
            for x in range(8):
                value = 255 if bits & (128 >> x) else 0
                at = ((oy + (cell // 32) * 8 + row) * w + ox + (cell % 32) * 8 + x) * 4
                image[at : at + 4] = bytes([value, value, value, 255])
    return (w, h), bytes(image)
