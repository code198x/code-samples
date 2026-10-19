"""Reject stale lifecycle execution records. This guard does not run a guest."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOLDERS = {
    "sinclair-zx-spectrum/patterns/assembly/rendering/sprite-lifecycle/": {
        "background.inc",
        "shapes.inc",
        "demo.asm",
        "Makefile",
    },
    "bbc-micro/patterns/assembly/rendering/sprite-lifecycle/": {
        "background.inc",
        "demo.asm",
        "loader.py",
        "Makefile",
    },
    "commodore-amiga/patterns/assembly/rendering/sprite-lifecycle/": {
        "bob.inc",
        "shapes.inc",
        "demo.asm",
        "Makefile",
    },
}
REQUIRED = {prefix + name for prefix, names in FOLDERS.items() for name in names} | {
    "sinclair-zx-spectrum/patterns/assembly/rendering/masked-sprites/masked.inc",
    "sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-addressing/bitmap-addressing.inc",
    "bbc-micro/patterns/assembly/rendering/masked-sprites/masked.inc",
    "commodore-amiga/patterns/assembly/framework/game-loop/frame.inc",
    "scripts/verify-rendering-families.py",
    "scripts/verify-game-loops.py",
    "scripts/verify-z80-library-routines.py",
}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(root: Path, record: dict) -> None:
    if record.get("status") != "passed" or record.get("cases") != {
        "spectrum": {"rectangles": 7, "overlaps": 4},
        "amiga": {"rectangles": 7, "overlaps": 1},
        "bbc": {"overlaps": 3},
    }:
        raise ValueError("Missing or failed lifecycle workload")
    if set(record.get("rejected_controls", {})) != {
        "spectrum-save",
        "spectrum-order",
        "amiga-mask",
        "amiga-order",
        "bbc-order",
    }:
        raise ValueError("Missing lifecycle failure controls")
    if set(record.get("sources", {})) != REQUIRED:
        raise ValueError("Missing lifecycle source bindings")
    for path, digest in record["sources"].items():
        if sha(root / path) != digest:
            raise ValueError("Changed lifecycle source: " + path)
    if sha(root / "scripts/verify-sprite-lifecycle.py") != record.get(
        "observer_sha256"
    ):
        raise ValueError("Changed lifecycle observer")
    if set(record.get("captures", {})) != {"spectrum.png", "amiga.png", "bbc.png"}:
        raise ValueError("Missing lifecycle caller captures")
    for name, digest in record["captures"].items():
        if sha(root / "docs/sprite-lifecycle/verification" / name) != digest:
            raise ValueError("Changed lifecycle capture: " + name)


if __name__ == "__main__":
    validate(
        ROOT,
        json.loads(
            (ROOT / "docs/sprite-lifecycle/verification/results.json").read_text()
        ),
    )
    print(
        "Lifecycle source, observer, workload, controls and captures match retained evidence. No fresh runtime execution by this guard."
    )
