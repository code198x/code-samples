"""Build standalone layout callers; faults replace maintained executable fragments."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path

SHARED = Path(__file__).resolve().parent
ROOT = SHARED.parents[3]
VARIANTS = [
    "positive",
    "customise",
    "width-fault",
    "origin-fault",
    "width-fixed",
    "origin-fixed",
    "break-fault",
    "break-fixed",
]


def fragment(text: str, name: str) -> str:
    return text.split("; BEGIN " + name + "\n", 1)[1].split("; END " + name, 1)[0]


def build(system: str, assembler: str, variant: str = "positive") -> tuple[dict, Path]:
    if variant not in VARIANTS:
        raise ValueError(variant)
    c = next(
        c
        for c in json.loads((SHARED / "systems.json").read_text())
        if c["machine_id"] == system
    )
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/word-wrap"
    out = folder / "build" / variant
    out.mkdir(parents=True, exist_ok=True)

    def expand(path: Path) -> str:
        text = path.read_text()
        if path == SHARED / (c["cpu"] + ".inc") and "-" in variant:
            fault, state = variant.split("-")
            f = (SHARED / "mistakes" / (c["cpu"] + "-" + fault + ".inc")).read_text()
            good, wrong = fragment(f, "FIX"), fragment(f, "WRONG")
            assert text.count(good) == 1
            text = text.replace(good, wrong)
            if state == "fixed":
                assert text.count(wrong) == 1
                text = text.replace(wrong, good)
        return re.sub(
            r'^\s*(?:!source|include) "([^"]+)"\s*$',
            lambda m: expand((path.parent / m[1]).resolve()),
            text,
            flags=re.MULTILINE,
        )

    selected = folder / ("customise.asm" if variant == "customise" else "demo.asm")
    (out / "selected.asm").write_text(expand(selected))
    subprocess.run(
        [
            assembler,
            "--dialect",
            {"z80": "pasmo", "6502": "acme", "6809": "lwasm"}[c["cpu"]],
            "--sym",
            str(out / "selected.asm"),
            "-o",
            str(out / "raw.bin"),
        ],
        cwd=folder,
        check=True,
        timeout=45,
    )
    data = (out / "raw.bin").read_bytes()
    if not 0 < len(data) <= c["size"]:
        raise ValueError("Caller exceeds its ROM allocation")
    image = bytearray(data.ljust(c["size"], b"\0"))
    if c["cpu"] == "6809":
        for at in range(len(image) - 16, len(image), 2):
            image[at : at + 2] = c["origin"].to_bytes(2, "big")
    path = out / "fixture.bin"
    path.write_bytes(image)
    return c, path


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument("--variant", choices=VARIANTS, default="positive")
    args = p.parse_args()
    print(build(args.system, args.assembler, args.variant)[1])
