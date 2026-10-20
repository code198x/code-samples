"""Build original bitmap diagnostics; no third-party firmware is distributed."""

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
    kernel = (SHARED / (cfg["cpu"] + ".inc")).read_text()
    if variant == "unsafe-destination":
        if cfg["cpu"] == "6502":
            needle = "    cmp NR+4\n    bcs bounds_fit_2\n    rts\nbounds_fit_2:"
            replacement = "    cmp NR+4\n    jmp bounds_fit_2\nbounds_fit_2:"
        elif cfg["cpu"] == "z80":
            needle = "    cp b\n    jr c,bounds_fit_2\n    ret nz\nbounds_fit_2:"
            replacement = "    cp b\n    jr bounds_fit_2\nbounds_fit_2:"
        else:
            needle = "    cmpa NR+4\n    bhs bounds_fit_2\n    rts\nbounds_fit_2"
            replacement = "    cmpa NR+4\n    bra bounds_fit_2\nbounds_fit_2"
        assert kernel.count(needle) == 1
        kernel = kernel.replace(needle, replacement)
    elif variant == "wrong-layout":
        # Perturb actual scanline addresses, not a captured expected value.
        marker = "bitmap_lo:" + ("\n" if cfg["cpu"] != "6809" else "")
        if cfg["cpu"] == "6809":
            marker = "bitmap_lo\n"
        before, after = source.split(marker)
        low, tail = after.split(
            "bitmap_hi" + (":" if cfg["cpu"] != "6809" else "") + "\n"
        )
        directive = (
            "!byte" if cfg["cpu"] == "6502" else "db" if cfg["cpu"] == "z80" else "fcb"
        )
        lines = []
        for line in low.splitlines():
            vals = [
                int(v) for v in line.strip().removeprefix(directive).strip().split(",")
            ]
            lines.append(
                "    " + directive + " " + ",".join(str((v + 1) & 255) for v in vals)
            )
        source = (
            before
            + marker
            + "\n".join(lines)
            + "\nbitmap_hi"
            + (":" if cfg["cpu"] != "6809" else "")
            + "\n"
            + tail
        )
    elif variant.startswith("reject-"):
        case = int(variant.split("-")[1])
        if case not in range(3, 18):
            raise ValueError(variant)
        colon = "" if cfg["cpu"] == "6809" else ":"
        jump = "jp" if cfg["cpu"] == "z80" else "jmp"
        start = "case_3" + colon + "\n"
        source = (
            source.replace(start, start + f"    {jump} case_{case}\n")
            if case != 3
            else source
        )
        if case != 17:
            stop = f"case_{case + 1}" + colon + "\n"
            source = source.replace(stop, f"    {jump} diagnostic_done\n" + stop)
    elif variant != "positive":
        raise ValueError(variant)
    (out / "kernel.inc").write_text(kernel)
    source = source.replace(
        f"../../../../../cross-platform/patterns/rendering/bitmap-regions/{cfg['cpu']}.inc",
        str(out / "kernel.inc"),
    )
    (out / "selected.asm").write_text(source)
    dialect = {"6502": "acme", "z80": "pasmo", "6809": "lwasm"}[cfg["cpu"]]
    subprocess.run(
        [assembler, "--dialect", dialect, "build/selected.asm", "-o", "build/raw.bin"],
        cwd=folder,
        check=True,
        timeout=45,
    )
    data = (out / "raw.bin").read_bytes()
    if not data or len(data) > cfg["size"]:
        raise ValueError("Image outside ROM allocation")
    data = data.ljust(cfg["size"], b"\0")
    if cfg["cpu"] == "6809":
        data = data[:-14] + bytes([0x80, 0]) * 7
    if cfg["machine_id"] == "acorn-atom":
        data = bytes(8192) + data
    image = out / "fixture.bin"
    image.write_bytes(data)
    return cfg, image


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", required=True)
    p.add_argument("--assembler", default="asm198x")
    a = p.parse_args()
    print(build(a.system, a.assembler)[1])
