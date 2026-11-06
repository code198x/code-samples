"""Check retained observations and typed-program bindings; does not rerun emulators.

The BASIC is typed into stock ROM, so its text is the program (rule 2): a
change to a typed file, a REM included, makes the record stale. Observer
script digests are provenance only.
"""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SYSTEMS = ("acorn-atom", "amstrad-cpc")
INPUTS = {
    "caller.bas",
    "customise.bas",
    "routines.bas",
    "mistakes/reset-each-turn.bas",
    "qualification-toolchain.json",
}
_E = importlib.util.spec_from_file_location(
    "turn_record_bytes", ROOT / "scripts/evidence_bytes.py"
)
assert _E and _E.loader
E = importlib.util.module_from_spec(_E)
_E.loader.exec_module(E)


def require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError(message)


def check(system: str, root: Path = ROOT, record: dict[str, Any] | None = None) -> None:
    folder = root / system / "patterns/basic/framework/command-loop"
    out = folder / "verification/reusable"
    if record is None:
        record = json.loads((out / "results.json").read_text())
    prefix = str(folder.relative_to(root))
    require(
        record["status"] == "passed" and record["machine_id"] == system,
        "Missing successful machine observation",
    )
    require(
        set(record["sources"]) == {f"{prefix}/{s}" for s in INPUTS},
        "Incomplete source bindings",
    )
    for p, digest in record["sources"].items():
        if p.endswith(".bas"):
            E.require_typed((root / p).read_bytes(), digest, p)
        else:
            require(
                hashlib.sha256((root / p).read_bytes()).hexdigest() == digest,
                f"Changed toolchain configuration {p}",
            )
    expected = {
        "default": [0, 1, 2],
        "step-two": [0, 2, 4],
        "nonzero": [37, 38, 39],
        "reset-mistake": [0, 1, 1],
    }
    if system == "amstrad-cpc":
        expected["byte-wrap"] = [254, 255, 0]
    require(
        record["traces"] == expected, "Turn progression or fault observation changed"
    )
    require(record["idle_frames_per_observation"] >= 120, "Idle interval missing")
    require(
        record["invalid_command_unchanged_in_working_callers"] is True,
        "Rejected command check missing",
    )
    require(
        record["reset_fault_rejected_by_progression_guard"] is True
        and record["reset_fault_rejected_command_state"] == 0,
        "Fault did not reproduce",
    )
    wanted = {
        f"{variant}-{stage}.png"
        for variant in expected
        for stage in ["waiting", "action-1", "action-2"]
    }
    require(set(record["images"]) == wanted, "Missing native capture")
    for p, digest in record["images"].items():
        data = (out / p).read_bytes()
        require(
            data.startswith(b"\x89PNG\r\n\x1a\n")
            and hashlib.sha256(data).hexdigest() == digest,
            f"Changed capture {p}",
        )
    for key in ["emulator_sha256"]:
        require(len(record[key]) == 64, "Missing executable identity")
    require(bool(record["firmware_sha256"]), "Missing firmware identity")


if __name__ == "__main__":
    for system in SYSTEMS:
        check(system)
        print(system, "bound native evidence checked; no fresh emulator execution")
