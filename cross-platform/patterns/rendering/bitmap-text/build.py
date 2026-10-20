"""Build original reset callers; faults change actual executed instructions."""

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
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/bitmap-text"
    out = folder / "build"
    out.mkdir(exist_ok=True)
    code = (SHARED / (c["cpu"] + ".inc")).read_text()
    if variant == "glyph-fault":
        needle = {
            "z80": "    and $80",
            "6502": "    and #$80",
            "6809": "    anda #$80",
        }[c["cpu"]]
        assert code.count(needle) == 1
        code = code.replace(needle, needle.replace("80", "40"))
    elif variant == "advance-fault":
        start = code.index(
            "\ntext_next_glyph" + ("" if c["cpu"] == "6809" else ":") + "\n"
        )
        before, after = code[:start], code[start:]
        needle = {"z80": "ld de,$0008", "6502": "adc #$08", "6809": "addd #$0008"}[
            c["cpu"]
        ]
        assert after.count(needle) >= 1
        after = after.replace(needle, needle.replace("8", "7"), 1)
        code = before + after
    elif variant != "positive":
        raise ValueError(variant)
    (out / "text.inc").write_text(code)
    source = (folder / "demo.asm").read_text()
    source = source.replace(
        '"../../../../../cross-platform/patterns/rendering/bitmap-text/'
        + c["cpu"]
        + '.inc"',
        '"' + str(out / "text.inc") + '"',
    )
    for category, name in [
        ("drawing-foundations", c["cpu"] + ".inc"),
        ("geometry", "cpc.inc"),
        ("bitmap-text", "font-" + c["cpu"] + ".inc"),
    ]:
        source = source.replace(
            '"../../../../../cross-platform/patterns/rendering/'
            + category
            + "/"
            + name
            + '"',
            '"' + str(SHARED.parent / category / name) + '"',
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
            {"z80": "pasmo", "6502": "acme", "6809": "lwasm"}[c["cpu"]],
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
    if not 0 < len(raw) <= c["size"]:
        raise ValueError("Fixture exceeds ROM allocation")
    data = bytearray(raw.ljust(c["size"], b"\0"))
    if c["cpu"] == "6809":
        for at in range(len(data) - 16, len(data), 2):
            data[at : at + 2] = c["origin"].to_bytes(2, "big")
    image = out / "fixture.bin"
    image.write_bytes(data)
    return c, image


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument(
        "--variant",
        choices=["positive", "glyph-fault", "advance-fault"],
        default="positive",
    )
    a = p.parse_args()
    print(build(a.system, a.assembler, a.variant)[1])
