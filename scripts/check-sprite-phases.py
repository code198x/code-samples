"""Reject stale phases execution records. This guard does not run a guest."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOLDERS = {
    prefix + "/patterns/assembly/rendering/pre-shifted-sprites/": {
        "phase.inc",
        "phases.inc",
        "demo.asm",
        "Makefile",
    }
    | ({"draw.inc"} if prefix != "commodore-amiga" else set())
    | ({"loader.py"} if prefix == "bbc-micro" else set())
    for prefix in ["sinclair-zx-spectrum", "bbc-micro", "commodore-amiga"]
}
REQUIRED = {prefix + name for prefix, names in FOLDERS.items() for name in names} | {
    "cross-platform/patterns/rendering/pre-shifted-sprites/prepare.py",
    "cross-platform/patterns/rendering/pre-shifted-sprites/sprite.json",
    "cross-platform/patterns/rendering/pre-shifted-sprites/verification/verify.py",
    "scripts/verify-sprite-clipping.py",
    "scripts/verify-sprite-lifecycle.py",
    "scripts/verify-rendering-families.py",
    "scripts/verify-game-loops.py",
    "scripts/verify-z80-library-routines.py",
    "sinclair-zx-spectrum/patterns/assembly/rendering/clipped-sprites/clip.inc",
    "sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-addressing/bitmap-addressing.inc",
    "bbc-micro/patterns/assembly/rendering/clipped-sprites/clip.inc",
    "commodore-amiga/patterns/assembly/rendering/clipped-sprites/clip.inc",
    "commodore-amiga/patterns/assembly/rendering/clipped-sprites/draw.inc",
    "commodore-amiga/patterns/assembly/framework/game-loop/frame.inc",
}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(root: Path, record: dict) -> None:
    expected = {
        "spectrum": {"phases": 8, "draws": 40, "asset_bytes": 784},
        "bbc": {"phases": 8, "draws": 40, "asset_bytes": 784},
        "amiga": {"phases": 16, "draws": 80, "asset_bytes": 2176},
    }
    if record.get("status") != "passed" or record.get("cases") != expected:
        raise ValueError("Missing or failed phases workload")
    controls = record.get("rejected_controls", {})
    if controls != {
        system + "-" + kind: system + " phase bitmap mismatch"
        for system in expected
        for kind in ["phase", "stride", "floor"]
    }:
        raise ValueError("Missing phases failure controls")
    host = record.get("host", {})
    if (
        host.get("status") != "passed"
        or host.get("pixel_samples") != {"spectrum": 3072, "bbc": 3072, "amiga": 8192}
        or host.get("invalid_inputs_rejected") != 5
        or set(host.get("rejected_payload_controls", {}))
        != {s + "-" + k for s in expected for k in ["mask", "image"]}
    ):
        raise ValueError("Missing host pixel and failure workload")
    if set(record.get("sources", {})) != REQUIRED:
        raise ValueError("Missing phases source bindings")
    for path, digest in record["sources"].items():
        if sha(root / path) != digest:
            raise ValueError("Changed phases source: " + path)
    if sha(root / "scripts/verify-sprite-phases.py") != record.get("observer_sha256"):
        raise ValueError("Changed phases observer")
    if set(record.get("captures", {})) != {"spectrum.png", "amiga.png", "bbc.png"}:
        raise ValueError("Missing phases caller captures")
    for name, digest in record["captures"].items():
        if sha(root / "docs/sprite-phases/verification" / name) != digest:
            raise ValueError("Changed phases capture: " + name)


if __name__ == "__main__":
    validate(
        ROOT,
        json.loads((ROOT / "docs/sprite-phases/verification/results.json").read_text()),
    )
    print(
        "Phases source, observer, workload, controls and captures match retained evidence. No fresh runtime execution by this guard."
    )
