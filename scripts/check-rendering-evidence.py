"""Reject stale or incomplete retained rendering evidence; does not execute code.

A record is stale when its programs' bytes change. The guard rebuilds every
fixture through the recorder's own programs() and every caller through its
Makefile, with the Asm198x release the record pins, and compares the bytes
with the record. Source and observer digests are provenance only.
"""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
RECORDER = "scripts/verify-rendering-families.py"
EVIDENCE = "docs/rendering-families/verification"

SPEC = importlib.util.spec_from_file_location(
    "rendering_bytes", Path(__file__).with_name("evidence_bytes.py")
)
assert SPEC and SPEC.loader
E = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(E)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def recorder(root: Path) -> Any:
    spec = importlib.util.spec_from_file_location("rendering_recorder", root / RECORDER)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def require_programs(root: Path, record: dict) -> None:
    """Rebuild every pinned program with the pinned assembler and compare bytes."""
    pin = record.get("tools", {}).get("assembler")
    if not pin:
        raise ValueError("Missing rendering assembler pin")
    recorded = recorder(root)
    fixtures = record.get("fixture_programs", {})
    callers = record.get("caller_programs", {})
    expected_callers = {
        str((folder / name).relative_to(recorded.ROOT))
        for folder, name in recorded.CALLER_PROGRAMS
    }
    if set(fixtures) != set(recorded.fixture_programs()) or set(callers) != (
        expected_callers
    ):
        raise ValueError("Missing rendering program bindings")
    out = root / "build/evidence/rendering-families"
    out.mkdir(parents=True, exist_ok=True)
    build = E.function(
        root / RECORDER,
        "programs",
        (E.ASSEMBLER, str(out)),
        out,
        tuple(sorted(fixtures)),
    )
    for name, digest in sorted(fixtures.items()):
        E.require_program(build, name, pin, recorded_sha256=digest)
    for path, digest in sorted(callers.items()):
        folder, _, name = path.partition("/build/")
        output = "build/" + name
        E.require_program(
            E.make(root / folder, (output,)), output, pin, recorded_sha256=digest
        )


def validate(root: Path, record: dict) -> None:
    if record.get("status") != "passed" or record.get("routine_cases") != {
        "spectrum": 7,
        "nes": 11,
        "bbc": 5,
    }:
        raise ValueError("Missing or failed rendering case groups")
    if set(record.get("mutants_rejected", [])) != {"spectrum", "nes", "bbc"}:
        raise ValueError("Missing rendering negative controls")
    captures = record.get("captures", {})
    if set(captures) != {"spectrum.png", "nes.png", "bbc.png"}:
        raise ValueError("Missing complete-caller captures")
    for name, digest in captures.items():
        if sha(root / EVIDENCE / name) != digest:
            raise ValueError("Changed caller capture: " + name)
    require_programs(root, record)


if __name__ == "__main__":
    validate(ROOT, json.loads((ROOT / EVIDENCE / "results.json").read_text()))
    print(
        "Rendering programs rebuild to the recorded bytes; case groups, controls and "
        "captures match retained evidence. No runtime execution by this guard."
    )
