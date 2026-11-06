"""Reject stale phases execution records. This guard does not run a guest.

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
RECORDER = "scripts/verify-sprite-phases.py"
EVIDENCE = "docs/sprite-phases/verification"

SPEC = importlib.util.spec_from_file_location(
    "phases_bytes", Path(__file__).with_name("evidence_bytes.py")
)
assert SPEC and SPEC.loader
E = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(E)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def recorder(root: Path) -> Any:
    spec = importlib.util.spec_from_file_location("phases_recorder", root / RECORDER)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def require_programs(root: Path, record: dict) -> None:
    """Rebuild every pinned program with the pinned tools and compare bytes."""
    tools = record.get("tools", {})
    pin, builder = tools.get("assembler"), tools.get("build198x")
    if not pin or not builder:
        raise ValueError("Missing phases tool pins")
    fixtures = record.get("fixture_programs", {})
    if set(fixtures) != set(recorder(root).fixture_programs()):
        raise ValueError("Missing phases program bindings")
    out = root / "build/evidence/sprite-phases"
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
    if set(record.get("captures", {})) != {"spectrum.png", "amiga.png", "bbc.png"}:
        raise ValueError("Missing phases caller captures")
    for name, digest in record["captures"].items():
        if sha(root / EVIDENCE / name) != digest:
            raise ValueError("Changed phases capture: " + name)
    require_programs(root, record)


if __name__ == "__main__":
    validate(ROOT, json.loads((ROOT / EVIDENCE / "results.json").read_text()))
    print(
        "Phases programs rebuild to the recorded bytes; workload, controls and "
        "captures match retained evidence. No fresh runtime execution by this guard."
    )
