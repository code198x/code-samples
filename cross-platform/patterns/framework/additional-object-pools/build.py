"""Build the maintained flat images and generated stock-interpreter loaders."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
from pathlib import Path

VARIANTS = ("demo", "custom", "wrong", "repaired", "boundary-one", "boundary-max")


def capacity(source: str) -> int:
    match = re.search(
        r"^POOL_CAPACITY\s*(?:=|equ)\s*(\d+)\s*$", source, re.MULTILINE | re.IGNORECASE
    )
    if match is None or not 1 <= int(match[1]) <= 255:
        raise ValueError("POOL_CAPACITY must be an explicit integer1..255")
    return int(match[1])


def symbols(path: Path) -> dict[str, int]:
    return {
        k: int(v, 16)
        for k, v in re.findall(
            r"^(\w+)\s+(?:=|equ)\s+(?:code\+)?\$(\w+)",
            path.read_text(),
            re.MULTILINE | re.IGNORECASE,
        )
    }


def listing(system: str, data: bytes, c: dict) -> list[str]:
    origin = c["origin"]
    v = c["vars"]
    aa = v + 18
    bb = v + 19
    if system == "bbc-micro":
        start = ["5 MODE 7:HIMEM=&2FFF"]
        poke = f"?({origin}+I)=B"
        call = f"CALL {origin}"
    elif system == "amstrad-cpc":
        start = [
            "5 SYMBOL AFTER 240:SYMBOL 240,60,66,70,74,82,98,66,60:SYMBOL 241,24,56,24,24,24,24,24,126",
            "6 MEMORY &7FFF:MODE 1:INK 0,0:INK 1,26:PAPER 0:PEN 1",
        ]
        poke = f"POKE {origin}+I,B"
        call = f"CALL {origin}"
    elif system == "dragon-32":
        start = ["CLEAR 200,&H5FFF"]
        poke = f"POKE {origin}+I,B"
        call = f"EXEC {origin}"
    else:
        start = ["5 POKE 106,124:GRAPHICS 0"]
        poke = f"POKE {origin}+I,B"
        call = f"X=USR({origin})"
    # Loading and entry are separate commands so the observer can require a real editor return.
    lines = start + [f"10 FOR I=0 TO {len(data) - 1}:READ B:{poke}:NEXT I", "20 END"]
    if system == "dragon-32":
        lines += [
            f'30 A=PEEK({aa}):B=PEEK({bb}):CLS 0:PRINT"POOL";CHR$(48+A);CHR$(48+B);"  "',
            "40 FOR J=0 TO 3:FOR I=0 TO 3",
            "50 IF (I+J)-2*INT((I+J)/2)=A THEN SET(48+I,4+J,1)",
            "60 IF (I+J)-2*INT((I+J)/2)=B THEN SET(56+I,4+J,1)",
            f"70 NEXT I:NEXT J:POKE {v + 32},42:END",
        ]
    for i in range(0, len(data), 12):
        lines.append(
            f"{100 + i // 12 * 10} DATA " + ",".join(map(str, data[i : i + 12]))
        )
    return lines + ["RUN", call]


def build(folder: Path, variant: str, assembler: str) -> None:
    root = Path(__file__).resolve().parents[4]
    c = json.loads(Path(__file__).with_name("machines.json").read_text())[
        folder.relative_to(root).parts[0]
    ]
    cap = capacity((folder / (variant + ".asm")).read_text())
    if not variant.startswith("boundary-") and not 3 <= cap <= 8:
        raise ValueError(
            "This occupancy-display client needs capacity3..8; use the boundary clients for1/255"
        )
    out = folder / "build"
    out.mkdir(exist_ok=True)
    cpu = c["cpu"]
    args = [
        assembler,
        "--dialect",
        {"6502": "acme", "z80": "pasmo", "6809": "lwasm"}[cpu],
    ]
    if cpu == "z80":
        args += ["--cpu", "z80"]
    args += [
        "-I",
        str(folder),
        "--sym=" + str(out / (variant + ".sym")),
        str(folder / (variant + ".asm")),
        "-o",
        str(out / (variant + ".bin")),
    ]
    subprocess.run(args, cwd=folder, check=True, timeout=45)
    data = (out / (variant + ".bin")).read_bytes()
    sym = symbols(out / (variant + ".sym"))
    if not 0 < len(data) < c["limit"] - c["origin"] or sym.get("code_end") != c[
        "origin"
    ] + len(data):
        raise ValueError(
            "Emitted payload/extent overlaps reserved state or is not a flat image"
        )
    (out / (variant + "-load.bas")).write_text(
        "\n".join(listing(folder.relative_to(root).parts[0], data, c)) + "\n"
    )


def main(folder: Path) -> None:
    p = argparse.ArgumentParser()
    p.add_argument("variant", nargs="?", choices=VARIANTS)
    a = p.parse_args()
    for variant in [a.variant] if a.variant else VARIANTS:
        build(folder, variant, os.environ.get("ASM198X", "asm198x"))
