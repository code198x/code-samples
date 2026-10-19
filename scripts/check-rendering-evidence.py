"""Reject stale or incomplete retained rendering evidence; does not execute code."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PREFIXES = {
    "sp": "sinclair-zx-spectrum/patterns/assembly/rendering/software-scrolling/",
    "nes": "nintendo-entertainment-system/patterns/assembly/rendering/nametable-scrolling/",
    "bbc": "bbc-micro/patterns/assembly/rendering/masked-sprites/",
}
REQUIRED = {
    *(PREFIXES["sp"] + p for p in ["scroll.inc", "demo.asm", "Makefile"]),
    *(PREFIXES["nes"] + p for p in ["scroll.inc", "demo.asm", "Makefile"]),
    *(PREFIXES["bbc"] + p for p in ["masked.inc", "demo.asm", "loader.py", "Makefile"]),
    "sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-addressing/bitmap-addressing.inc",
    "nintendo-entertainment-system/patterns/assembly/rendering/multi-sprite-oam/oam.inc",
    "scripts/verify-game-loops.py",
    "scripts/verify-z80-library-routines.py",
}


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def validate(root: Path, record: dict) -> None:
    if record.get("status") != "passed" or record.get("routine_cases") != {
        "spectrum": 7,
        "nes": 10,
        "bbc": 5,
    }:
        raise ValueError("Missing or failed rendering case groups")
    if set(record.get("mutants_rejected", [])) != {"spectrum", "nes", "bbc"}:
        raise ValueError("Missing rendering negative controls")
    if set(record.get("sources", {})) != REQUIRED:
        raise ValueError("Incomplete rendering source/observer bindings")
    for path, digest in record["sources"].items():
        if sha(root / path) != digest:
            raise ValueError("Changed rendering source: " + path)
    if sha(root / "scripts/verify-rendering-families.py") != record.get(
        "observer_sha256"
    ):
        raise ValueError("Changed rendering execution observer")
    captures = record.get("captures", {})
    if set(captures) != {"spectrum.png", "nes.png", "bbc.png"}:
        raise ValueError("Missing complete-caller captures")
    for name, digest in captures.items():
        if sha(root / "docs/rendering-families/verification" / name) != digest:
            raise ValueError("Changed caller capture: " + name)


if __name__ == "__main__":
    validate(
        ROOT,
        json.loads(
            (ROOT / "docs/rendering-families/verification/results.json").read_text()
        ),
    )
    print(
        "Rendering sources, observers, case groups, controls and captures match retained evidence. No runtime execution by this guard."
    )
