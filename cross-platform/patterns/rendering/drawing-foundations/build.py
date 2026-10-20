"""Assemble six original reset callers, without redistributing system firmware."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path

SHARED = Path(__file__).resolve().parent
ROOT = SHARED.parents[3]


def build(system: str, assembler: str, variant: str = "positive") -> tuple[dict, Path]:
    cfg = next(
        c
        for c in json.loads((SHARED / "systems.json").read_text())
        if c["machine_id"] == system
    )
    folder = ROOT / cfg["folder"] / "patterns/assembly/rendering" / cfg["family"]
    out = folder / "build"
    out.mkdir(exist_ok=True)
    source = (folder / "demo.asm").read_text()
    if cfg["family"] == "pixels-and-boxes":
        inc = SHARED / (cfg["cpu"] + ".inc")
    else:
        inc = folder / "glyphs.inc"
    kernel = inc.read_text()
    if variant == "fault":
        if cfg["family"] == "pixels-and-boxes":
            needle = "128,64,32,16,8,4,2,1"
            assert kernel.count(needle) == 1
            kernel = kernel.replace(needle, "64,128,32,16,8,4,2,1")
        else:
            # Perturb the actual slot destination, never an expected observation.
            needle, replacement = {
                "6502": ("adc #$10", "adc #$11"),
                "z80": (
                    "ld h,0\n    add hl,hl\n    add hl,hl\n    add hl,hl\n    push bc",
                    "ld h,0\n    inc hl\n    add hl,hl\n    add hl,hl\n    add hl,hl\n    push bc",
                ),
                "sm83": ("ld de,$8000", "ld de,$8010"),
            }[cfg["cpu"]]
            assert kernel.count(needle) == 1
            kernel = kernel.replace(needle, replacement)
    elif variant != "positive":
        raise ValueError(variant)
    (out / "kernel.inc").write_text(kernel)
    original = (
        "glyphs.inc"
        if cfg["family"] == "custom-glyphs"
        else "../../../../../cross-platform/patterns/rendering/drawing-foundations/"
        + cfg["cpu"]
        + ".inc"
    )
    source = source.replace('"' + original + '"', '"' + str(out / "kernel.inc") + '"')
    # Keep relative helper includes anchored at the maintained caller, not build/.
    source = source.replace(
        '"../bitmap-addressing/bitmap-addressing.inc"',
        '"' + str(folder.parent / "bitmap-addressing/bitmap-addressing.inc") + '"',
    )
    (out / "selected.asm").write_text(source)
    cmd = [
        assembler,
        "--dialect",
        {"6502": "acme", "z80": "pasmo", "6809": "lwasm", "sm83": "rgbasm"}[cfg["cpu"]],
        "--sym",
    ]
    if cfg["cpu"] == "sm83":
        cmd += ["--gb-rom"]
    cmd += ["build/selected.asm", "-o", "build/raw.bin"]
    subprocess.run(cmd, cwd=folder, check=True, timeout=45)
    raw = (out / "raw.bin").read_bytes()
    if not raw or len(raw) > cfg["size"]:
        raise ValueError("Fixture does not fit ROM")
    data = bytearray(raw.ljust(cfg["size"], b"\0"))
    if cfg["cpu"] == "6809":
        for i in range(len(data) - 16, len(data), 2):
            data[i : i + 2] = cfg["origin"].to_bytes(2, "big")
    image = out / "fixture.bin"
    image.write_bytes(data)
    if system == "commodore-vic-20":
        (out / "basic.rom").write_bytes(bytes(8192))
        (out / "chargen.rom").write_bytes(bytes(4096))
    return cfg, image


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument("--variant", default="positive", choices=["positive", "fault"])
    a = p.parse_args()
    print(build(a.system, a.assembler, a.variant)[1])
