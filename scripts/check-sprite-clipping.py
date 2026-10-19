"""Reject stale clipping execution records. This guard does not run a guest."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOLDERS = {
    prefix + "/patterns/assembly/rendering/clipped-sprites/": {
        "clip.inc",
        "draw.inc",
        "shapes.inc",
        "demo.asm",
        "Makefile",
    }
    | ({"loader.py"} if prefix == "bbc-micro" else set())
    for prefix in ["sinclair-zx-spectrum", "bbc-micro", "commodore-amiga"]
}
REQUIRED = {prefix + name for prefix, names in FOLDERS.items() for name in names} | {
    "sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-addressing/bitmap-addressing.inc",
    "commodore-amiga/patterns/assembly/framework/game-loop/frame.inc",
    "scripts/verify-sprite-lifecycle.py",
    "scripts/verify-rendering-families.py",
    "scripts/verify-game-loops.py",
    "scripts/verify-z80-library-routines.py",
}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(root: Path, record: dict) -> None:
    if record.get("status") != "passed" or record.get("cases") != {
        system: {"axis_cases": 220, "native_scenes": 1, "objects_per_scene": 9}
        for system in ["spectrum", "bbc", "amiga"]
    }:
        raise ValueError("Missing or failed clipping workload")
    controls = record.get("rejected_controls", {})
    if set(controls) != {
        system + "-" + kind
        for system in ["spectrum", "bbc", "amiga"]
        for kind in ["axis", "source-crop"]
    } or not all(
        isinstance(value, str) and "mismatch" in value for value in controls.values()
    ):
        raise ValueError("Missing clipping failure controls")
    if set(record.get("sources", {})) != REQUIRED:
        raise ValueError("Missing clipping source bindings")
    for path, digest in record["sources"].items():
        if sha(root / path) != digest:
            raise ValueError("Changed clipping source: " + path)
    if sha(root / "scripts/verify-sprite-clipping.py") != record.get("observer_sha256"):
        raise ValueError("Changed clipping observer")
    if set(record.get("captures", {})) != {"spectrum.png", "amiga.png", "bbc.png"}:
        raise ValueError("Missing clipping caller captures")
    for name, digest in record["captures"].items():
        if sha(root / "docs/sprite-clipping/verification" / name) != digest:
            raise ValueError("Changed clipping capture: " + name)


if __name__ == "__main__":
    validate(
        ROOT,
        json.loads(
            (ROOT / "docs/sprite-clipping/verification/results.json").read_text()
        ),
    )
    print(
        "Clipping source, observer, workload, controls and captures match retained evidence. No fresh runtime execution by this guard."
    )
