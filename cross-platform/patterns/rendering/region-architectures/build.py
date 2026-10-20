"""Build original native region reset fixtures without manufacturer firmware."""

from __future__ import annotations

import argparse
import json
import struct
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
    f = ROOT / cfg["folder"] / "patterns/assembly/rendering/tile-region"
    out = f / "build"
    out.mkdir(exist_ok=True)
    cpu = cfg["cpu"]
    source = (f / "demo.asm").read_text()
    kernel_path = (
        (SHARED.parent / "bitmap-regions/6502.inc")
        if cpu == "6502"
        else SHARED / (cpu + ".inc")
    )
    kernel = kernel_path.read_text()
    helper = (SHARED / "blit-plane.inc").read_text() if cpu == "m68000" else ""
    if variant.startswith("blitter"):
        if cpu != "m68000":
            raise ValueError("Blitter variant on wrong CPU")
        source = source.replace("BACKEND equ 0", "BACKEND equ 1")
        variant = variant.removeprefix("blitter").removeprefix("-") or "positive"
    if variant == "unsafe-destination":
        if cpu == "6502":
            needle = "    cmp NR+4\n    bcs bounds_fit_2\n    rts\nbounds_fit_2:"
            replacement = "    cmp NR+4\n    jmp bounds_fit_2\nbounds_fit_2:"
        elif cpu == "sm83":
            needle = "    cp b\n    jr c,bounds_fit_2\n    ret nz\nbounds_fit_2:"
            replacement = "    cp b\n    jr bounds_fit_2\nbounds_fit_2:"
        else:
            needle = "    cmp.b 4(a0),d0\n    bhs bounds_fit_2\n    rts\nbounds_fit_2:"
            replacement = "    cmp.b 4(a0),d0\n    bra bounds_fit_2\nbounds_fit_2:"
        assert kernel.count(needle) == 1
        kernel = kernel.replace(needle, replacement)
    elif variant == "wrong-layout":
        if cpu == "6502":
            before, tail = source.split("bitmap_lo:\n")
            low, after = tail.split("bitmap_hi:\n")
            lines = []
            for line in low.splitlines():
                values = [int(v) for v in line.removeprefix("!byte ").split(",")]
                lines.append("!byte " + ",".join(str((v + 1) & 255) for v in values))
            source = (
                before + "bitmap_lo:\n" + "\n".join(lines) + "\nbitmap_hi:\n" + after
            )
        elif cpu == "sm83":
            assert kernel.count("    ld de,BG_MAP\n") == 1
            kernel = kernel.replace("    ld de,BG_MAP\n", "    ld de,BG_MAP+1\n")
        else:
            assert kernel.count("mulu.w #320,d0") == 1
            kernel = kernel.replace("mulu.w #320,d0", "mulu.w #312,d0")
    elif variant == "short":
        assert cpu == "m68000" and "BACKEND equ 1" in source
        assert helper.count("#$0201,$058") == 1
        helper = helper.replace("#$0201,$058", "#$0101,$058")
    elif variant.startswith("reject-"):
        case = int(variant.split("-")[1])
        if case not in range(3, 18):
            raise ValueError(variant)
        jump = "jp" if cpu == "sm83" else "jmp" if cpu == "6502" else "bra"
        if case != 3:
            source = source.replace("case_3:\n", f"case_3:\n    {jump} case_{case}\n")
        if case != 17:
            source = source.replace(
                f"case_{case + 1}:\n", f"    {jump} diagnostic_done\ncase_{case + 1}:\n"
            )
    elif variant != "positive":
        raise ValueError(variant)
    if cpu == "m68000":
        (out / "blit-plane.inc").write_text(helper)
        kernel = kernel.replace(
            "../../../../../cross-platform/patterns/rendering/region-architectures/blit-plane.inc",
            str(out / "blit-plane.inc"),
        )
    (out / "kernel.inc").write_text(kernel)
    source = source.replace(
        "../../../../../" + str(kernel_path.relative_to(ROOT)), str(out / "kernel.inc")
    )
    (out / "selected.asm").write_text(source)
    dialect = {"6502": "acme", "sm83": "rgbasm", "m68000": "vasm"}[cpu]
    cmd = [assembler, "--dialect", dialect]
    if cpu == "sm83":
        cmd += ["--gb-rom"]
    cmd += ["build/selected.asm", "-o", "build/raw.bin"]
    subprocess.run(cmd, cwd=f, check=True, timeout=45)
    raw = (out / "raw.bin").read_bytes()
    if cpu == "m68000":
        raw = struct.pack(">II", 0x7F000, 0xF80008) + raw
    if cfg["machine_id"] == "atari-800xl":
        raw = bytes(8192) + raw
    if not raw or len(raw) > cfg["size"]:
        raise ValueError("Reset fixture exceeds ROM")
    image = out / "fixture.bin"
    image.write_bytes(raw.ljust(cfg["size"], b"\0"))
    if cfg["machine_id"] == "atari-800xl":
        (out / "basic.rom").write_bytes(bytes(8192))
    return cfg, image


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", required=True)
    p.add_argument("--assembler", default="asm198x")
    a = p.parse_args()
    print(build(a.system, a.assembler)[1])
