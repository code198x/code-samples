"""Check retained Atom/CPC deadline observations and exact source bindings.

This reads evidence; it does not execute an emulator or establish hardware timing.
"""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "deadline_verifier", ROOT / "scripts/verify-firmware-deadlines.py"
)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Missing native verifier")
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def check(system: str, record: dict[str, Any] | None = None) -> None:
    require(system in V.SYSTEMS, "Unknown machine")
    if record is None:
        record = json.loads(
            (V.folder(system) / "verification/results.json").read_text()
        )
    require(
        record["status"] == "passed"
        and record["machine_id"] == system
        and record["language"] == "assembly",
        "Wrong machine/language/status",
    )
    expected_sources = {
        str(p.relative_to(ROOT)): V.sha(p) for p in V.source_paths(system)
    }
    require(record["sources"] == expected_sources, "Changed or missing source bindings")
    observers = {
        str(p.relative_to(ROOT)): V.sha(p)
        for p in [
            ROOT / "scripts/verify-firmware-deadlines.py",
            ROOT / "scripts/verify-game-loops.py",
        ]
    }
    require(record["observers"] == observers, "Changed or missing observer bindings")
    for key in ("emulator_sha256", "assembler_sha256"):
        digest = record[key]
        require(
            len(digest) == 64 and all(c in "0123456789abcdef" for c in digest),
            "Missing tool identity",
        )
    firmware_name = "atom.rom" if system == "acorn-atom" else "cpc464.rom"
    require(
        set(record["firmware_sha256"]) == {firmware_name}
        and len(record["firmware_sha256"][firmware_name]) == 64,
        "Missing firmware identity",
    )
    atom = system == "acorn-atom"
    variants = {"working", "custom-duration", "wrong-input-gate", "repaired"} | (
        {"clock-wrap"} if atom else set()
    )
    require(set(record["cases"]) == variants, "Incomplete native cases")
    for variant, case in record["cases"].items():
        duration = (
            (50 if atom else 300)
            if variant == "custom-duration"
            else (100 if atom else 600)
        )
        require(case["duration"] == duration, "Wrong selected duration")
        require(
            case["binary_bytes"] > 0
            and len(case["binary_sha256"]) == len(case["loader_sha256"]) == 64,
            "Missing built caller identity",
        )
        before, after = case["idle"], case["after_idle"]
        require(
            before["turns"] == after["turns"] == 0
            and before["active"] == after["active"] == 0,
            "Untimed idle advanced",
        )
        ticks = (after["clock"] - before["clock"]) % 65536
        require(
            ticks == case["ticks_in_30_frames"]
            and ((28 <= ticks <= 32) if atom else (174 <= ticks <= 186)),
            "Wrong clock observation",
        )
        require(
            case["untimed_action"]["turns"] == 1
            and case["untimed_action"]["active"] == 0,
            "Untimed action enabled deadline",
        )
        enabled, running = case["enabled"], case["running"]
        require(
            enabled["active"] == running["active"] == 1
            and enabled["turns"] == running["turns"] == 1,
            "Input/time progression confused",
        )
        elapsed = (running["clock"] - enabled["clock"]) % 65536
        require(
            elapsed > 0 and enabled["remaining"] - running["remaining"] == elapsed,
            "Clock/countdown disagree",
        )
        expiry = case["expiry"]
        wrong = variant == "wrong-input-gate"
        require(case["fault_rejected"] == wrong, "Wrong fault status")
        if wrong:
            require(
                expiry["turns"] == 1
                and expiry["expiries"] == expiry["active"] == expiry["remaining"] == 0
                and not case["actions"],
                "Fault did not reach ignored expiry",
            )
        else:
            require(
                expiry["turns"] == 2 and expiry["expiries"] == expiry["active"] == 1,
                "Missing no-input expiry",
            )
            action = case["actions"]["restart"]
            require(
                action["turns"] == 3
                and duration // 2 < action["remaining"] <= duration,
                "Missing action restart",
            )
            stopped, later = (
                case["actions"]["disabled"],
                case["actions"]["disabled_after"],
            )
            require(
                stopped["active"] == later["active"] == 0
                and stopped["turns"] == later["turns"],
                "Disabled timer advanced",
            )
        states = [
            before,
            after,
            case["untimed_action"],
            enabled,
            running,
            expiry,
            *case["actions"].values(),
        ]
        require(
            all(s["guards"] == [165, 90] for s in states), "Corrupted caller guards"
        )
        expected_images = {
            f"{variant}-{label}.png"
            for label in ["untimed", "untimed-action", "expiry"]
            + ([] if wrong else ["action"])
        }
        require(set(case["captures"]) == expected_images, "Incomplete native captures")
        for name, digest in case["captures"].items():
            path = V.folder(system) / "verification" / name
            require(
                path.read_bytes().startswith(b"\x89PNG\r\n\x1a\n")
                and V.sha(path) == digest,
                "Changed capture",
            )
        require(
            case["captures"][f"{variant}-untimed.png"]
            != case["captures"][f"{variant}-untimed-action.png"],
            "No visible action change",
        )
    arithmetic = record["arithmetic"]
    require(arithmetic["cases"] == [list(c) for c in V.CASES], "Wrong arithmetic cases")
    require(
        set(arithmetic["observations"]) == {"working", "wrong-zero-boundary"},
        "Incomplete arithmetic controls",
    )
    for variant, observation in arithmetic["observations"].items():
        good = variant == "working"
        require(
            len(observation["bytes"]) == len(V.expected_arithmetic())
            and observation["bytes"][-1] == 239,
            "Incomplete CPU fixture",
        )
        require(
            observation["oracle_matches"] == good
            and (observation["bytes"] == V.expected_arithmetic()) == good,
            "Arithmetic control outcome disagrees",
        )
        require(len(observation["fixture_sha256"]) == 64, "Missing fixture identity")


if __name__ == "__main__":
    for name in V.SYSTEMS:
        check(name)
        print(name, "retained deadline evidence passed")
