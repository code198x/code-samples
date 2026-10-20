"""Build original reset fixtures for character screens and Electron bitmap drawing."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path

SHARED = Path(__file__).resolve().parent
ROOT = SHARED.parents[3]


def build(system: str, assembler: str, variant: str = "positive") -> tuple[dict, Path]:
    c = next(
        c
        for c in json.loads((SHARED / "systems.json").read_text())
        if c["machine_id"] == system
    )
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/tile-region"
    out = folder / "build"
    out.mkdir(exist_ok=True)
    source = (folder / "demo.asm").read_text()
    electron = system == "acorn-electron"
    kernel_path = (
        SHARED.parent / "bitmap-regions/6502.inc"
        if electron
        else SHARED / (c["cpu"] + ".inc")
    )
    kernel = kernel_path.read_text()
    if variant == "wrong-layout":
        if electron:
            source = source.replace("X_STEP=8", "X_STEP=1")
        else:
            kernel = kernel.replace("adc #SCREEN_COLS", "adc #(SCREEN_COLS-1)").replace(
                "ld de,SCREEN_COLS", "ld de,SCREEN_COLS-1"
            )
    elif variant == "unsafe-destination":
        if c["cpu"] == "6502":
            before = "    cmp NR+4\n    bcs bounds_fit_2\n    rts\nbounds_fit_2:"
            after = "    cmp NR+4\n    jmp bounds_fit_2\nbounds_fit_2:"
        else:
            before = "    cp b\n    jr c,bounds_fit_2\n    ret nz\nbounds_fit_2:"
            after = "    cp b\n    jr bounds_fit_2\nbounds_fit_2:"
        if kernel.count(before) != 1:
            raise ValueError("Unsafe control did not match exactly once")
        kernel = kernel.replace(before, after)
    elif variant.startswith("reject-"):
        i = int(variant.split("-")[1])
        if i not in range(3, 18):
            raise ValueError(variant)
        jump = "jmp" if c["cpu"] == "6502" else "jp"
        if i != 3:
            source = source.replace("case_3:\n", f"case_3:\n    {jump} case_{i}\n")
        if i != 17:
            source = source.replace(
                f"case_{i + 1}:\n", f"    {jump} diagnostic_done\ncase_{i + 1}:\n"
            )
    elif variant != "positive":
        raise ValueError(variant)
    (out / "kernel.inc").write_text(kernel)
    source = source.replace(
        "../../../../../" + str(kernel_path.relative_to(ROOT)), str(out / "kernel.inc")
    )
    (out / "selected.asm").write_text(source)
    subprocess.run(
        [
            assembler,
            "--dialect",
            "acme" if c["cpu"] == "6502" else "pasmo",
            "build/selected.asm",
            "-o",
            "build/raw.bin",
        ],
        cwd=folder,
        check=True,
        timeout=45,
    )
    raw = (out / "raw.bin").read_bytes()
    if not raw or len(raw) > c["size"]:
        raise ValueError("Reset image exceeds allocation")
    image = out / "fixture.bin"
    image.write_bytes(raw.ljust(c["size"], b"\0"))
    # These are original diagnostic font ROMs, never a claim of writable PET/Aquarius glyphs.
    glyphs = bytearray(4096 if system != "mattel-aquarius" else 2048)
    for t in range(4):
        for y in range(8):
            glyphs[t * 8 + y] = sum(
                bool(
                    t == 1
                    and (x + y) % 2 == 0
                    or t == 2
                    and (x in (0, 7) or y in (0, 7))
                    or t == 3
                    and (x == y or x == 7 - y)
                )
                << (7 - x)
                for x in range(8)
            )
    (out / "char.rom").write_bytes(glyphs)
    (out / "basic.rom").write_bytes(bytes(16384 if electron else 8192))
    (out / "editor.rom").write_bytes(bytes(2048))
    return c, image


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", required=True)
    p.add_argument("--assembler", default="asm198x")
    a = p.parse_args()
    print(build(a.system, a.assembler)[1])
