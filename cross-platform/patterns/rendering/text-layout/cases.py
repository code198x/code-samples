"""Boundary, ownership and useful scene cases; no native implementation imports."""

from __future__ import annotations

from typing import Any


def cases(c: dict) -> list[dict]:
    result = []

    def add(name: str, kind: str = "block", **kw: Any) -> None:
        result.append(dict(id=name, kind=kind, **kw))

    for align in range(3):
        add("align-" + str(align), "line", bytes=list(b"READY"), align=align)
        add(
            "odd-gap-" + str(align),
            "line",
            bytes=list(b"READY"),
            align=align,
            rect=[21, 37, 177, 80],
        )
    for length in (0, 1, 21, 22, 23, 44, 255):
        add(
            "length-" + str(length),
            bytes=list(b"A" * length),
            rect=[0, 0, c["width"], c["height"]],
            pitch=8,
        )
    for text, name in [
        (b"\n", "empty-line"),
        (b"A\n\nB\n", "blank-and-trailing"),
        (b"A" * 22 + b"\nB", "exact-then-lf"),
        (b"A\x00\xffB", "fallback"),
        (b"WIDE WORDS KEEP THEIR SPACES", "spaces"),
        (b"A\n" * 20, "many-lines"),
    ]:
        add(name, bytes=list(text))
    for name, rect in [
        ("last-pixel", [c["width"] - 8, c["height"] - 8, 8, 8]),
        ("seven-wide", [0, 0, 7, 8]),
        ("seven-high", [0, 0, 8, 7]),
        ("off-right", [c["width"] - 7, 0, 8, 8]),
        ("off-bottom", [0, c["height"] - 7, 8, 8]),
        ("unsigned-left", [65535, 0, 8, 8]),
        ("huge-width", [0, 0, 65535, 8]),
        ("zero-width", [0, 0, 0, 8]),
    ]:
        add(name, bytes=[65], rect=rect)
    add("atomic-height-reject", bytes=list(b"A\nB"), rect=[21, 37, 80, 8])
    add("oversize-line", "line", bytes=list(b"A" * 23))
    add("pitch-7", bytes=[65], pitch=7)
    add("pitch-255-one", bytes=[65], pitch=255)
    add("pitch-255-two", bytes=[65, 10, 66], pitch=255)
    add("align-invalid", bytes=[65], align=3)
    add("source-wrap", bytes=[65, 66], source_ptr=65535)
    add("empty-pointer-end", bytes=[], source_ptr=65535)
    for name, kw in [
        ("font-zero", {"count": 0}),
        ("bad-fallback", {"fallback": 0}),
        ("bad-pen", {"fg": c["pen_max"] + 1}),
        ("bad-mode", {"mode": 2}),
    ]:
        add(name, bytes=[65], **kw)
    for length in (0, 1, 31, 32, 127, 128, 255):
        add("measure-" + str(length), "measure", length=length)
    if c["pen_max"] == 3:
        for fg in range(4):
            for bg in range(4):
                add(f"packed-{fg}-{bg}", bytes=list(b"CPC\nINK"), fg=fg, bg=bg, mode=1)
    add(
        "custom-scene",
        bytes=list(b"A NARROW PANEL\nWRAPS THIS MESSAGE\nPRESS FIRE"),
        rect=[21, 37, 104, 80],
        align=2,
        pitch=16,
        scene=True,
    )
    return result
