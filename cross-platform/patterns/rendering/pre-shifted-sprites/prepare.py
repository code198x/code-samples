"""Prepare original 16x16 three-state artwork for aligned masked renderers.

No image packages: . is transparent, 0 opaque black, 1 opaque ink.
Eight byte phases for Spectrum/BBC; sixteen word phases for Amiga.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


def validate(rows: object) -> list[str]:
    if (
        not isinstance(rows, list)
        or len(rows) != 16
        or any(
            not isinstance(row, str) or len(row) != 16 or set(row) - set(".01")
            for row in rows
        )
    ):
        raise ValueError("Expected sixteen rows of sixteen . / 0 / 1 samples")
    return rows


def phases(rows: list[str], system: str) -> list[tuple[bytes, bytes]]:
    validate(rows)
    if system not in ["spectrum", "bbc", "amiga"]:
        raise ValueError("Unknown target")
    bits = 16 if system == "amiga" else 8
    width = 32 if system == "amiga" else 24
    result = []
    for shift in range(bits):
        mask = bytearray()
        image = bytearray()
        for row in rows:
            opaque = int("".join("0" if v == "." else "1" for v in row), 2) << (
                width - 16 - shift
            )
            ink = int("".join("1" if v == "1" else "0" for v in row), 2) << (
                width - 16 - shift
            )
            m = opaque if system == "amiga" else ((1 << width) - 1) ^ opaque
            mask.extend(m.to_bytes(width // 8, "big"))
            image.extend(ink.to_bytes(width // 8, "big"))
        result.append((bytes(mask), bytes(image)))
    return result


def assembly(rows: list[str], system: str, prefix: str = "sprite") -> str:
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", prefix):
        raise ValueError("Prefix must be an assembly identifier")
    prepared = phases(rows, system)
    lines = [
        "; SPDX-License-Identifier: MIT",
        "; Generated from original sprite.json by prepare.py. Regenerate, do not hand-edit.",
        "assets_begin:",
        "phase_table:",
    ]
    if system == "amiga":
        lines += [f"    dc.l phase_{n}_mask,phase_{n}_image" for n in range(16)]
    else:
        directive = "defw" if system == "spectrum" else "!word"
        lines += [f"    {directive} phase_{n}" for n in range(8)]
    for n, (mask, image) in enumerate(prepared):
        if system == "amiga":
            for label, data in [("mask", mask), ("image", image)]:
                lines.append(f"phase_{n}_{label}:")
                for i in range(0, len(data), 16):
                    lines.append("    dc.b " + ",".join(map(str, data[i : i + 16])))
        else:
            data = bytes(v for pair in zip(mask, image, strict=True) for v in pair)
            lines.append(f"phase_{n}:")
            for i in range(0, len(data), 16):
                lines.append(
                    "    "
                    + ("defb" if system == "spectrum" else "!byte")
                    + " "
                    + ",".join(map(str, data[i : i + 16]))
                )
    lines.append("assets_end:")
    text = "\n".join(lines) + "\n"
    return re.sub(
        r"\b(?:assets_begin|assets_end|phase_table|phase_\d+(?:_mask|_image)?)\b",
        lambda m: prefix + "_" + m[0],
        text,
    )


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("source", type=Path)
    p.add_argument("--system", choices=["spectrum", "bbc", "amiga"], required=True)
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--prefix", default="sprite")
    p.add_argument("--check", action="store_true")
    a = p.parse_args()
    text = assembly(validate(json.loads(a.source.read_text())), a.system, a.prefix)
    if a.check:
        if not a.output.is_file() or a.output.read_text() != text:
            raise ValueError("Generated assembly differs: " + str(a.output))
    else:
        a.output.write_text(text)


if __name__ == "__main__":
    main()
