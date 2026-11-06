"""Reject stale clipping execution records. This guard does not run a guest.

A record is stale when its programs' bytes change. The guard rebuilds every
fixture through the recorder's own programs(), with the Asm198x and
build198x releases the record pins, and compares the bytes with the record.
Source and observer digests are provenance only.
"""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
RECORDER = "scripts/verify-sprite-clipping.py"
EVIDENCE = "docs/sprite-clipping/verification"

SPEC = importlib.util.spec_from_file_location(
    "clipping_bytes", Path(__file__).with_name("evidence_bytes.py")
)
assert SPEC and SPEC.loader
E = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(E)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def recorder(root: Path) -> Any:
    spec = importlib.util.spec_from_file_location("clipping_recorder", root / RECORDER)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def require_programs(root: Path, record: dict) -> None:
    """Rebuild every pinned program with the pinned tools and compare bytes."""
    tools = record.get("tools", {})
    pin, builder = tools.get("assembler"), tools.get("build198x")
    if not pin or not builder:
        raise ValueError("Missing clipping tool pins")
    fixtures = record.get("fixture_programs", {})
    if set(fixtures) != set(recorder(root).fixture_programs()):
        raise ValueError("Missing clipping program bindings")
    out = root / "build/evidence/sprite-clipping"
    out.mkdir(parents=True, exist_ok=True)
    build = E.function(
        root / RECORDER,
        "programs",
        (E.ASSEMBLER, E.BUILDER, str(out)),
        out,
        tuple(sorted(fixtures)),
    )
    for name, digest in sorted(fixtures.items()):
        E.require_program(build, name, pin, recorded_sha256=digest, build198x=builder)


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
    if set(record.get("captures", {})) != {"spectrum.png", "amiga.png", "bbc.png"}:
        raise ValueError("Missing clipping caller captures")
    for name, digest in record["captures"].items():
        if sha(root / EVIDENCE / name) != digest:
            raise ValueError("Changed clipping capture: " + name)
    require_programs(root, record)


if __name__ == "__main__":
    validate(ROOT, json.loads((ROOT / EVIDENCE / "results.json").read_text()))
    print(
        "Clipping programs rebuild to the recorded bytes; workload, controls and "
        "captures match retained evidence. No fresh runtime execution by this guard."
    )
