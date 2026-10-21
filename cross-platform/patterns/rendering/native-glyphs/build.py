"""Build original C64, CHR-RAM NES and Sega Mode 4 qualification callers."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path
from typing import Any

SHARED = Path(__file__).resolve().parent
ROOT = SHARED.parents[3]


def master_nes(raw: bytes) -> bytes:
    if raw[:8] != b"NES\x1a" + bytes([2, 0, 1, 0]):
        raise ValueError("Expected NROM-256/CHR-RAM, vertical mirroring")
    # The current NES linker reserves an empty default CHARS segment even
    # when the explicit iNES header declares zero CHR-ROM banks. Master only
    # declared PRG bytes; reject nonzero/unknown surplus instead of silently
    # deleting asset data. CHR-RAM comes from the zero-bank header, not padding.
    if len(raw) not in (32784, 40976) or any(raw[32784:]):
        raise ValueError("Unexpected or nonempty undeclared CHR data")
    return raw[:32784]


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
    kernel = (
        SHARED / "mode4.inc" if cfg["cpu"] == "z80" else folder / "glyphs.inc"
    ).read_text()
    if variant == "wrong-slot":
        needle, replacement = (
            ("ld hl,(P+2)\n    add hl,hl", "ld hl,(P+2)\n    inc hl\n    add hl,hl")
            if cfg["cpu"] == "z80"
            else ("lda G+2\n    asl", "lda G+2\n    eor #1\n    asl")
        )
    elif variant == "wrong-name":
        needle, replacement = (
            (
                "ld hl,(P+8)\n    add hl,hl\n    ld de,$3800",
                "ld hl,(P+8)\n    add hl,hl\n    ld de,$3801",
            )
            if cfg["cpu"] == "z80"
            else (
                f"adc #>{8192 if system == 'nes' else 1024}",
                f"adc #>{8448 if system == 'nes' else 1280}",
            )
        )
    elif variant != "positive":
        raise ValueError(variant)
    if variant != "positive":
        if kernel.count(needle) != 1:
            raise ValueError("Failure-control target changed")
        kernel = kernel.replace(needle, replacement)
    (out / "kernel.inc").write_text(kernel)
    source = (
        (folder / "demo.asm")
        .read_text()
        .replace('"glyphs.inc"', '"' + str(out / "kernel.inc") + '"')
    )
    (out / "selected.asm").write_text(source)
    dialect = "pasmo" if cfg["cpu"] == "z80" else "ca65" if system == "nes" else "acme"
    subprocess.run(
        [
            assembler,
            "--dialect",
            dialect,
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
    if system == "nes":
        data = master_nes(raw)
    else:
        if not raw or len(raw) > cfg["size"]:
            raise ValueError("Fixture does not fit original ROM")
        data = raw.ljust(cfg["size"], b"\0")
        if cfg["cpu"] == "z80":
            header = (
                b"TMR SEGA"
                + bytes(7)
                + bytes([0x6C if system == "sega-game-gear" else 0x4C])
            )
            data = data[:0x7FF0] + header
    image = out / "fixture.bin"
    image.write_bytes(data)
    if system == "c64":
        (out / "basic.rom").write_bytes(bytes(8192))
        (out / "chargen.rom").write_bytes(bytes(4096))
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
