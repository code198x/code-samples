"""Build the original 32-bit-pointer A500 bitmap text reset caller."""

from __future__ import annotations

import argparse
import json
import struct
import subprocess
from pathlib import Path

S = Path(__file__).resolve().parent
ROOT = S.parents[4]


def build(assembler: str, variant: str = "positive") -> tuple[dict, Path]:
    c = json.loads((S / "system.json").read_text())
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/bitmap-text"
    out = folder / "build"
    out.mkdir(exist_ok=True)
    kernel = (S.parent / "m68000.inc").read_text()
    if variant == "glyph-fault":
        needle = "andi.b #$80,d0"
        assert kernel.count(needle) == 1
        kernel = kernel.replace(needle, "andi.b #$40,d0")
    elif variant == "advance-fault":
        needle = "addq.w #8,T+30"
        assert kernel.count(needle) == 1
        kernel = kernel.replace(needle, "addq.w #7,T+30")
    elif variant != "positive":
        raise ValueError(variant)
    (out / "text.inc").write_text(kernel)
    source = (
        (folder / "demo.asm")
        .read_text()
        .replace(
            "../../../../../cross-platform/patterns/rendering/bitmap-text/m68000.inc",
            str(out / "text.inc"),
        )
    )
    source = source.replace(
        "../../../../../cross-platform/patterns/rendering/remaining-primitives/m68000.inc",
        str(S.parents[1] / "remaining-primitives/m68000.inc"),
    ).replace(
        "../../../../../cross-platform/patterns/rendering/bitmap-text/font-m68000.inc",
        str(S.parent / "font-m68000.inc"),
    )
    (out / "selected.asm").write_text(source)
    subprocess.run(
        [
            assembler,
            "--dialect",
            "vasm",
            "--sym",
            "build/selected.asm",
            "-o",
            "build/raw.bin",
        ],
        cwd=folder,
        check=True,
        timeout=45,
    )
    raw = struct.pack(">II", 0x7F000, 0xF80008) + (out / "raw.bin").read_bytes()
    if not 0 < len(raw) <= c["size"]:
        raise ValueError("Fixture exceeds ROM allocation")
    image = out / "fixture.bin"
    image.write_bytes(raw.ljust(c["size"], b"\0"))
    return c, image


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--assembler", default="asm198x")
    a = p.parse_args()
    print(build(a.assembler)[1])
