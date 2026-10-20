"""Assemble three original fixtures, including an explicit original 5200 reset stub."""

from __future__ import annotations

import argparse
import json
import struct
import subprocess
from pathlib import Path

S = Path(__file__).resolve().parent
ROOT = S.parents[3]


def build(system: str, assembler: str, variant: str = "positive"):
    c = next(
        c
        for c in json.loads((S / "systems.json").read_text())
        if c["machine_id"] == system
    )
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/pixels-and-boxes"
    out = folder / "build"
    out.mkdir(exist_ok=True)
    name = "oric.inc" if system == "oric" else "antic.inc"
    kernel = (S / name).read_text()
    source = (folder / "demo.asm").read_text()
    if variant == "mask-fault":
        needle = (
            "!byte 32,16,8,4,2,1" if system == "oric" else "!byte 128,64,32,16,8,4,2,1"
        )
        assert kernel.count(needle) == 1
        kernel = kernel.replace(
            needle,
            needle.replace("32,16", "16,32")
            if system == "oric"
            else needle.replace("128,64", "64,128"),
        )
        # Pixel/read entries select BP+26 for outline sides only; alter right-edge mask for single pixels too.
        needle = (
            "!byte 63,31,15,7,3,1"
            if system == "oric"
            else "!byte 255,127,63,31,15,7,3,1"
        )
        assert kernel.count(needle) == 1
        kernel = kernel.replace(
            needle,
            needle.replace("63,31", "31,63")
            if system == "oric"
            else needle.replace("255,127", "127,255"),
        )
    elif variant == "row-fault":
        before, tail = source.split("bitmap_lo:\n")
        lo, after = tail.split("bitmap_hi:\n")
        values = [
            int(x.strip())
            for line in lo.splitlines()
            for x in line.strip().removeprefix("!byte ").split(",")
        ]
        assert len(values) == c["height"]
        values = [(v + 1) & 255 for v in values]
        lo = "".join(
            "    !byte " + ",".join(map(str, values[i : i + 16])) + "\n"
            for i in range(0, len(values), 16)
        )
        source = before + "bitmap_lo:\n" + lo + "bitmap_hi:\n" + after
    elif variant != "positive":
        raise ValueError(variant)
    (out / "kernel.inc").write_text(kernel)
    source = source.replace(
        '"../../../../../cross-platform/patterns/rendering/extended-primitives/'
        + name
        + '"',
        '"' + str(out / "kernel.inc") + '"',
    )
    (out / "selected.asm").write_text(source)
    subprocess.run(
        [
            assembler,
            "--dialect",
            "acme",
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
    if c["machine_id"] == "atari-800xl":
        raw = bytes(8192) + raw
    if not 0 < len(raw) <= c["size"]:
        raise ValueError("Fixture exceeds allocation")
    image = out / "fixture.bin"
    image.write_bytes(raw.ljust(c["size"], b"\0"))
    if c["machine_id"] == "atari-800xl":
        (out / "basic.rom").write_bytes(bytes(8192))
    if c["machine_id"] == "atari-5200":
        bios = bytearray(2048)
        bios[:3] = bytes([0x4C, 0, 0x40])
        bios[-6:] = struct.pack("<HHH", 0xF800, 0xF800, 0xF800)
        (out / "bios.rom").write_bytes(bios)
    return c, image


def command(c, image, native):
    args = [str(native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
    if c["machine_id"] == "atari-800xl":
        args += ["--basic", str(image.parent / "basic.rom")]
    if c["machine_id"] == "atari-5200":
        args += ["--bios", str(image.parent / "bios.rom")]
    return args


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument(
        "--variant", choices=["positive", "mask-fault", "row-fault"], default="positive"
    )
    a = p.parse_args()
    print(build(a.system, a.assembler, a.variant)[1])
