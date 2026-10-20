"""Assemble complete original reset callers; normal routines need no mailbox."""

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
    folder = ROOT / cfg["folder"] / "patterns/assembly/rendering/geometry"
    out = folder / "build"
    out.mkdir(exist_ok=True)
    source = (folder / "demo.asm").read_text()
    geometry = (SHARED / (cfg["cpu"] + ".inc")).read_text()
    if variant == "curve-fault":
        # Alias squared axes in actual executing code, yielding a wrong ellipse.
        needle = "g_b2" + (" = " if cfg["cpu"] == "6502" else " equ ") + "G+84"
        assert geometry.count(needle) == 1
        geometry = geometry.replace(needle, needle[:-2] + "80")
    elif variant not in ("positive", "packing-fault"):
        raise ValueError(variant)
    (out / "geometry.inc").write_text(geometry)
    source = source.replace(
        '"../../../../../cross-platform/patterns/rendering/geometry/'
        + cfg["cpu"]
        + '.inc"',
        '"' + str(out / "geometry.inc") + '"',
    )
    if variant == "packing-fault":
        if system != "amstrad-cpc":
            raise ValueError("Packed-pen control requires CPC")
        kernel = (SHARED / "cpc.inc").read_text()
        needle = "db $ff,$77,$33,$11"
        assert kernel.count(needle) == 1
        (out / "cpc.inc").write_text(kernel.replace(needle, "db $ff,$7b,$33,$11"))
        source = source.replace(
            '"../../../../../cross-platform/patterns/rendering/geometry/cpc.inc"',
            '"' + str(out / "cpc.inc") + '"',
        )
    for file in ["drawing-foundations/" + cfg["cpu"] + ".inc", "geometry/cpc.inc"]:
        source = source.replace(
            '"../../../../../cross-platform/patterns/rendering/' + file + '"',
            '"' + str(SHARED.parent / file) + '"',
        )
    source = source.replace(
        '"../bitmap-addressing/bitmap-addressing.inc"',
        '"' + str(folder.parent / "bitmap-addressing/bitmap-addressing.inc") + '"',
    )
    (out / "selected.asm").write_text(source)
    subprocess.run(
        [
            assembler,
            "--dialect",
            {"6502": "acme", "z80": "pasmo", "6809": "lwasm"}[cfg["cpu"]],
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
        raise ValueError(
            f"{system}: fixture exceeds declared ROM allocation: {len(raw)}"
        )
    data = bytearray(raw.ljust(cfg["size"], b"\0"))
    if cfg["cpu"] == "6809":
        for at in range(len(data) - 16, len(data), 2):
            data[at : at + 2] = cfg["origin"].to_bytes(2, "big")
    image = out / "fixture.bin"
    image.write_bytes(data)
    return cfg, image


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument(
        "--variant",
        choices=["positive", "curve-fault", "packing-fault"],
        default="positive",
    )
    a = p.parse_args()
    print(build(a.system, a.assembler, a.variant)[1])
