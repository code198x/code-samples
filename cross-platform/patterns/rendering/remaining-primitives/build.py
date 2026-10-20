"""Build original reset callers, optionally with real faulty executing kernels."""

from __future__ import annotations

import argparse
import json
import struct
import subprocess
from pathlib import Path
from typing import Any

S = Path(__file__).resolve().parent
ROOT = S.parents[3]


def build(
    system: str, assembler: str, variant: str = "positive"
) -> tuple[dict[str, Any], Path]:
    c = next(
        c
        for c in json.loads((S / "systems.json").read_text())
        if c["machine_id"] == system
    )
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/pixels-and-boxes"
    out = folder / "build"
    out.mkdir(exist_ok=True)
    kernel = (S / (c["cpu"] + ".inc")).read_text()
    source = (folder / "demo.asm").read_text()
    if variant == "mask-fault":
        needle = (
            "!byte 128,64,32,16,8,4,2,1" if c["cpu"] == "6502" else "move.w #$ff,d6"
        )
        assert kernel.count(needle) == 1
        kernel = kernel.replace(
            needle,
            needle.replace("128,64", "64,128")
            if c["cpu"] == "6502"
            else "move.w #$7f,d6",
        )
        if c["cpu"] == "6502":
            needle = "!byte 255,127,63,31,15,7,3,1"
            assert kernel.count(needle) == 1
            kernel = kernel.replace(needle, needle.replace("255,127", "127,255"))
    elif variant == "row-fault":
        if c["cpu"] == "6502":
            before, tail = source.split("bitmap_lo:\n")
            lo, after = tail.split("bitmap_hi:\n")
            values = [
                int(v)
                for line in lo.splitlines()
                for v in line.strip().removeprefix("!byte ").split(",")
            ]
            assert len(values) == c["height"]
            lo = "".join(
                "    !byte "
                + ",".join(str((v + 1) & 255) for v in values[i : i + 16])
                + "\n"
                for i in range(0, len(values), 16)
            )
            source = before + "bitmap_lo:\n" + lo + "bitmap_hi:\n" + after
        else:
            assert kernel.count("mulu.w #40,d0") == 1
            kernel = kernel.replace("mulu.w #40,d0", "mulu.w #39,d0")
    elif variant != "positive":
        raise ValueError(variant)
    (out / "kernel.inc").write_text(kernel)
    source = source.replace(
        "../../../../../cross-platform/patterns/rendering/remaining-primitives/"
        + c["cpu"]
        + ".inc",
        str(out / "kernel.inc"),
    )
    (out / "selected.asm").write_text(source)
    subprocess.run(
        [
            assembler,
            "--dialect",
            "acme" if c["cpu"] == "6502" else "vasm",
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
    if c["cpu"] == "m68000":
        raw = struct.pack(">II", 0x7F000, 0xF80008) + raw
    if not 0 < len(raw) <= c["size"]:
        raise ValueError("Fixture exceeds ROM allocation")
    raw = raw.ljust(c["size"], b"\0")
    if c["machine_id"] == "acorn-atom":
        raw = bytes(8192) + raw
    image = out / "fixture.bin"
    image.write_bytes(raw)
    (out / "basic.rom").write_bytes(
        bytes(16384 if c["machine_id"] == "acorn-electron" else 8192)
    )
    if c["machine_id"] == "c64":
        (out / "chargen.rom").write_bytes(bytes(4096))
    return c, image


def command(c: dict[str, Any], image: Path, native: Path) -> list[str]:
    cmd = [str(native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
    if c["machine_id"] == "acorn-atom":
        cmd += ["--model", "acorn-atom-full"]
    if c["machine_id"] in ["c64", "acorn-electron"]:
        cmd += ["--basic", str(image.parent / "basic.rom")]
    if c["machine_id"] == "c64":
        cmd += ["--chargen", str(image.parent / "chargen.rom"), "--model", "pal"]
    if c["cpu"] == "m68000":
        cmd += ["--model", "a500"]
    return cmd


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", required=True)
    p.add_argument("--assembler", default="asm198x")
    a = p.parse_args()
    print(build(a.system, a.assembler)[1])
