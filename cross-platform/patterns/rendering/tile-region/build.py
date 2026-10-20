"""Build original native region diagnostics; never distribute third-party firmware."""

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
    folder = ROOT / cfg["folder"] / "patterns/assembly/rendering/tile-region"
    out = folder / "build"
    out.mkdir(exist_ok=True)
    source = (folder / "demo.asm").read_text()
    kernel = (SHARED / "region.inc").read_text()
    if variant == "wrong-stride":
        assert "NT_STRIDE equ 32" in source
        source = source.replace("NT_STRIDE equ 32", "NT_STRIDE equ 31")
    elif variant == "unsafe-destination":
        needle = "    jr c,region_dest_width_ok\n    ret nz\n"
        assert kernel.count(needle) == 1
        kernel = kernel.replace(needle, "    jr region_dest_width_ok\n")
    elif variant != "positive":
        raise ValueError(variant)
    (out / "region.inc").write_text(kernel)
    source = source.replace(
        '"../../../../../cross-platform/patterns/rendering/tile-region/region.inc"',
        '"' + str((out / "region.inc").resolve()) + '"',
    )
    source = source.replace(
        '"../../../../../cross-platform/patterns/rendering/tile-map/z80.inc"',
        '"' + str(SHARED.parent / "tile-map/z80.inc") + '"',
    )
    (out / "selected.asm").write_text(source)
    result = subprocess.run(
        [assembler, "--dialect", "pasmo", "build/selected.asm", "-o", "build/raw.bin"],
        cwd=folder,
        check=False,
        capture_output=True,
        text=True,
        timeout=45,
    )
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)
    data = (out / "raw.bin").read_bytes()
    if not data or len(data) > cfg["size"]:
        raise ValueError("Diagnostic exceeds declared ROM")
    data = data.ljust(cfg["size"], b"\0")
    if cfg["mode"] in ["sms", "gg"]:
        data = (
            data[:0x7FF0]
            + b"TMR SEGA"
            + bytes(7)
            + bytes([0x6C if cfg["mode"] == "gg" else 0x4C])
        )
    path = out / "fixture.bin"
    path.write_bytes(data)
    return cfg, path


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument(
        "--variant",
        default="positive",
        choices=["positive", "wrong-stride", "unsafe-destination"],
    )
    a = p.parse_args()
    cfg, image = build(a.system, a.assembler, a.variant)
    print(cfg["machine_id"], image.name, image.stat().st_size)


if __name__ == "__main__":
    main()
