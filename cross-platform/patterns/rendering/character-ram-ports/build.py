"""Build original Ace, Oric TEXT and Atari ANTIC 2 callers."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path
from typing import Any

SHARED = Path(__file__).resolve().parent
ROOT = SHARED.parents[3]


def build(
    system: str, assembler: str, variant: str = "positive"
) -> tuple[dict[str, Any], Path]:
    cfg = next(
        c
        for c in json.loads((SHARED / "systems.json").read_text())
        if c["machine_id"] == system
    )
    folder = ROOT / cfg["folder"] / "patterns/assembly/rendering/custom-glyphs"
    out = folder / "build"
    out.mkdir(exist_ok=True)
    kernel = (folder / "glyphs.inc").read_text()
    if variant == "wrong-slot":
        needle, replacement = (
            ("    ld a,(G+2)\n    ld l,a", "    ld a,(G+2)\n    xor 1\n    ld l,a")
            if cfg["cpu"] == "z80"
            else ("    lda G+2\n    asl", "    lda G+2\n    eor #1\n    asl")
        )
    elif variant == "wrong-name":
        needle, replacement = (
            ("    ld hl,(G+5)\n    ld de,$2400", "    ld hl,(G+5)\n    ld de,$2401")
            if cfg["cpu"] == "z80"
            else ("cell_ok:\n    lda G+5", "cell_ok:\n    lda G+5")
            if system == "oric"
            else ("adc #>20480", "adc #>20736")
        )
        if system == "oric":
            needle = "    lda #<$bb83\n    sta G+12\n    lda #>$bb83\n    sta G+13\nfind_row:"
            replacement = needle.replace("$bb83", "$bb84")
    elif variant != "positive":
        raise ValueError(variant)
    if variant != "positive":
        if kernel.count(needle) != 1:
            raise ValueError("Failure-control target changed")
        kernel = kernel.replace(needle, replacement)
    (out / "kernel.inc").write_text(kernel)
    (out / "selected.asm").write_text(
        (folder / "demo.asm")
        .read_text()
        .replace('"glyphs.inc"', '"' + str(out / "kernel.inc") + '"')
    )
    subprocess.run(
        [
            assembler,
            "--dialect",
            "pasmo" if cfg["cpu"] == "z80" else "acme",
            "--sym",
            "build/selected.asm",
            "-o",
            "build/raw.bin",
        ],
        cwd=folder,
        check=True,
        timeout=45,
    )
    raw = (out / "raw.bin").read_bytes()
    if not raw or len(raw) > cfg["size"]:
        raise ValueError("Original fixture does not fit ROM")
    raw = raw.ljust(cfg["size"], b"\0")
    if system == "atari-800xl":
        raw = bytes(8192) + raw
        (out / "basic.rom").write_bytes(bytes(8192))
    image = out / "fixture.bin"
    image.write_bytes(raw)
    return cfg, image


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument(
        "--variant",
        default="positive",
        choices=["positive", "wrong-slot", "wrong-name"],
    )
    a = p.parse_args()
    print(build(a.system, a.assembler, a.variant)[1])
