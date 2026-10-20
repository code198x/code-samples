"""Assemble six original reset fixtures using the unchanged MSX glyph include."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path
from typing import Any

SHARED = Path(__file__).resolve().parent
ROOT = SHARED.parents[3]
KERNEL = ROOT / "msx/patterns/assembly/rendering/custom-glyphs/glyphs.inc"


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
    kernel = KERNEL.read_text()
    if variant == "wrong-slot":
        needle = "ld h,0\n    add hl,hl\n    add hl,hl\n    add hl,hl\n    push bc"
        replacement = "ld h,0\n    inc hl\n    add hl,hl\n    add hl,hl\n    add hl,hl\n    push bc"
    elif variant == "wrong-name":
        needle, replacement = "ld de,$1800", "ld de,$1801"
    elif variant != "positive":
        raise ValueError(variant)
    if variant != "positive":
        if kernel.count(needle) != 1:
            raise ValueError("Failure control target changed")
        kernel = kernel.replace(needle, replacement)
    (out / "kernel.inc").write_text(kernel)
    source = (
        (folder / "demo.asm")
        .read_text()
        .replace(
            '"../../../../../msx/patterns/assembly/rendering/custom-glyphs/glyphs.inc"',
            '"' + str(out / "kernel.inc") + '"',
        )
    )
    (out / "selected.asm").write_text(source)
    subprocess.run(
        [
            assembler,
            "--dialect",
            "pasmo",
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
        raise ValueError("Fixture does not fit its original reset ROM")
    image = out / "fixture.bin"
    image.write_bytes(raw.ljust(cfg["size"], b"\0"))
    return cfg, image


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--system", required=True)
    parser.add_argument("--assembler", default="asm198x")
    parser.add_argument(
        "--variant",
        default="positive",
        choices=["positive", "wrong-slot", "wrong-name"],
    )
    args = parser.parse_args()
    print(build(args.system, args.assembler, args.variant)[1])
