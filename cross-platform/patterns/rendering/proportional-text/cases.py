"""Boundary, ownership and useful scene cases; no native implementation imports."""

from __future__ import annotations

from typing import Any


def cases(c: dict) -> list[dict]:
    result = []

    def add(name: str, kind: str = "block", **kw: Any) -> None:
        result.append(dict(id=name, kind=kind, **kw))

    for align in range(3):
        add("align-" + str(align), "line", bytes=list(b"I! WIDE"), align=align)
        add(
            "odd-gap-" + str(align),
            "line",
            bytes=list(b"I! WIDE"),
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
        add(
            "measure-" + str(length),
            "measure",
            length=length,
            bytes=list(b"I! W" * 64)[:length],
        )
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
    for name, text, columns in [
        ("word-at-edge", b"ONE TWO THREE", 7),
        ("space-at-edge", b"ONE TWO", 3),
        ("word-backtrack", b"ONE THREE FIVE", 7),
        ("overlong-word", b"SUPERCALIFRAGILISTIC", 5),
        ("one-column", b"AB CD E", 1),
        ("leading-spaces", b"  ONE TWO", 5),
        ("repeated-spaces", b"ONE   TWO THREE", 7),
        ("only-spaces", b" " * 19, 5),
        ("trailing-spaces", b"ONE TWO   ", 7),
        ("word-exact-lf", b"ONE TWO\nTHREE", 7),
        ("word-blank-lf", b"ONE\n\nTWO\n", 4),
        ("word-no-terminator", b"ONE\x00TWO\xffTHREE", 7),
        ("full-255-spaces", b" " * 255, 31),
        ("full-255-words", (b"A BC DEF " * 29)[:255], 31),
    ]:
        add(name, bytes=list(text), rect=[0, 0, columns * 8, c["height"]], pitch=8)
    add(
        "word-atomic-reject",
        bytes=list(b"ONE THREE FIVE"),
        rect=[21, 37, 56, 16],
        pitch=12,
    )
    for text in [
        b"IIIIII",
        b"WWWWWW",
        b"I! WIDE",
        b"",
        bytes(range(32, 96)),
        b"\x00\xff?!",
    ]:
        add("metric-string-" + text.hex(), "measure", bytes=list(text))
    for space in (0, 2, 3, 255):
        add("spacing-" + str(space), bytes=list(b"I! WIDE"), spacing=space)
    add("metric-pointer-wrap", bytes=[65], metric_ptr=65535)
    add("tiny-panel-reject", bytes=[87], rect=[21, 37, 8, 8], spacing=2)
    for metric in (0, 8, 9):
        widths = [5] * 64
        widths[33] = metric
        add(
            "invalid-metric-" + str(metric),
            bytes=[65],
            metric_ptr=c["data"] + 512,
            metric_values=widths,
        )
    widths = [5] * 64
    widths[33] = 2
    add(
        "custom-metric-clip",
        bytes=list(b"AAAA"),
        metric_ptr=c["data"] + 512,
        metric_values=widths,
        scene=True,
    )
    for phase in range(8):
        add(
            "phase-" + str(phase),
            "line",
            bytes=list(b"I! WIDE"),
            rect=[16 + phase, 37, 176, 8],
            mode=1,
        )
    add("all-metrics", "measure", bytes=list(range(32, 96)))
    return result


def diagnostic(variant: str) -> list[dict]:
    """A bounded visible symptom for each maintained faulty executable."""
    if False:
        return [
            {
                "id": variant,
                "kind": "block",
                "bytes": list(b"ONE THREE FIVE"),
                "mode": 1,
                "rect": [21, 37, 56, 80],
                "scene": True,
            }
        ]
    return [
        {
            "id": variant,
            "kind": "line",
            "bytes": list(b"READY"),
            "mode": 1,
            "rect": [21, 37, 176, 80],
        }
    ]
