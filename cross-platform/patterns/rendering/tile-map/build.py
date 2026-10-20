"""Build original CPU/RAM diagnostics, without distributing third-party ROMs.

The generated synthetic ROMs replace firmware for a bounded routine test.
They do not establish a stock-OS loader, picture, input path or frame deadline.
"""

from __future__ import annotations

import argparse
import json
import struct
import subprocess
from pathlib import Path

SHARED = Path(__file__).resolve().parent
ROOT = SHARED.parents[3]


def build(system: str, assembler: str) -> tuple[dict, Path]:
    configs = json.loads((SHARED / "native.json").read_text())
    cfg = next(c for c in configs if c["machine_id"] == system)
    folder = ROOT / cfg["folder"] / "patterns/assembly/rendering/tile-map"
    out = folder / "build"
    out.mkdir(exist_ok=True)
    cpu = cfg["cpu"]
    dialect = {"6502": "acme", "z80": "pasmo", "sm83": "rgbasm", "m68000": "vasm"}[cpu]
    command = [
        assembler,
        "--dialect",
        dialect,
        "--sym=build/demo.sym",
        "demo.asm",
        "-o",
        "build/raw.bin",
    ]
    if cpu == "sm83":
        command.insert(3, "--gb-rom")
    result = subprocess.run(
        command, cwd=folder, check=False, capture_output=True, text=True, timeout=45
    )
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)
    raw = (out / "raw.bin").read_bytes()
    kind = cfg["kind"]
    size = cfg["size"]
    if kind == "kickstart":
        payload = struct.pack(">II", cfg["stack"], cfg["origin"]) + raw
    elif kind == "gb":
        payload = raw
    else:
        payload = raw
    if len(payload) > size:
        raise ValueError(
            f"{system}: {len(payload)} bytes exceeds diagnostic image {size}"
        )
    payload = payload.ljust(size, b"\x00")
    if kind == "nes":
        payload = b"NES\x1a" + bytes([1, 1]) + bytes(10) + payload + bytes(8192)
    elif kind in ("sms", "gg", "sg"):
        header = b"TMR SEGA" + bytes(7) + bytes([0x6C if kind == "gg" else 0x4C])
        payload = payload[:0x7FF0] + header
    image = out / "fixture.bin"
    image.write_bytes(payload)
    if kind == "kernal":
        (out / "basic.rom").write_bytes(bytes(8192))
        (out / "chargen.rom").write_bytes(bytes(4096))
    elif kind == "electron":
        (out / "basic.rom").write_bytes(bytes(16384))
    elif kind == "5200":
        bios = bytearray(2048)
        bios[:3] = bytes([0x4C, 0, 0x40])
        bios[-6:] = struct.pack("<HHH", 0xF800, 0xF800, 0xF800)
        (out / "bios.rom").write_bytes(bios)
    return cfg, image.resolve()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", required=True)
    p.add_argument("--assembler", default="asm198x")
    args = p.parse_args()
    cfg, image = build(args.system, args.assembler)
    print(cfg["machine_id"], image.name, image.stat().st_size)


if __name__ == "__main__":
    main()
