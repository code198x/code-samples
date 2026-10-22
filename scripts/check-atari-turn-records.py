"""Check retained Atari observations and inputs, without fresh machine execution."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "atari_loops", ROOT / "scripts/verify-atari-turn-loops.py"
)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Cannot load verifier")
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def check(system: str, record: dict[str, Any] | None = None, root: Path = ROOT) -> None:
    folder = root / system / "patterns/assembly/framework/turn-loop"
    out = folder / "verification"
    if record is None:
        record = json.loads((out / "results.json").read_text())
    require(
        record["status"] == "passed" and record["machine_id"] == system,
        "Wrong machine/status",
    )
    inputs = {
        str(p.relative_to(root))
        for p in folder.rglob("*")
        if p.is_file()
        and "verification" not in p.parts
        and "build" not in p.parts
        and (p.suffix in [".asm", ".inc"] or p.name == "Makefile")
    }
    inputs |= {str(p.relative_to(root)) for p in (root / V.SHARED).rglob("*.inc")}
    inputs |= {
        str(V.SHARED / "toolchain.json"),
        "scripts/verify-atari-turn-loops.py",
        "scripts/verify-game-loops.py",
    }
    require(set(record["sources"]) == inputs, "Incomplete source bindings")
    for name, digest in record["sources"].items():
        require(
            hashlib.sha256((root / name).read_bytes()).hexdigest() == digest,
            "Changed source " + name,
        )
    require(set(record["variants"]) == set(V.VARIANTS), "Missing completed variant")
    require(set(record["binaries"]) == set(V.VARIANTS), "Missing executable identity")
    expected_images = {
        f"{v}-{label}.png"
        for v in V.VARIANTS
        for label in ["waiting", "pressed", "held", "second"]
    }
    require(set(record["artifacts"]) == expected_images, "Missing native capture")
    for name, digest in record["artifacts"].items():
        data = (out / name).read_bytes()
        require(
            data.startswith(b"\x89PNG\r\n\x1a\n")
            and hashlib.sha256(data).hexdigest() == digest,
            "Changed native capture " + name,
        )
    for variant, data in record["variants"].items():
        s = data["states"]
        step = 2 if variant == "customise" else 1
        initial = 254 if variant == "wrap" else 0
        require(s["initial"] == initial, "Wrong initial condition")
        for state in [s["pressed"], s["held"], s["released"], s["second"]]:
            require(
                len(state) == 7
                and all(isinstance(n, int) and 0 <= n <= 255 for n in state),
                "Incomplete native state",
            )
            require(state[5] == step, "Step state clobbered")
        if variant == "held-as-press":
            require(s["held"][0] != s["pressed"][0], "Fault did not repeat held action")
        else:
            require(
                s["pressed"][0] == (initial + step) % 256
                and s["held"][0] == s["pressed"][0]
                and s["second"][0] == (initial + 2 * step) % 256,
                "Turn/hold/wrap policy failed",
            )
            require(
                s["held"][6] == 0 and s["released"][1] == s["released"][6] == 0,
                "Held/released flags wrong",
            )
        delta = data["service_ticks_in_30_frames"]
        if variant == "bad-service" and system != "atari-2600":
            require(not 28 <= delta <= 31, "No-wait fault escaped")
        else:
            require(28 <= delta <= 31, "Wrong display-service rate")
        period = data["period_colour_clocks"]
        if system == "atari-2600":
            require(
                period == [(263 if variant == "bad-service" else 262) * 228] * 2,
                "Wrong idle/pressed field period",
            )
        else:
            require(period == [], "Unmeasured field period claimed")
        binary = record["binaries"][variant]
        require(
            binary["bytes"]
            == {"atari-2600": 4096, "atari-5200": 32768, "atari-7800": 49152}[system]
            and len(binary["sha256"]) == 64,
            "Invalid binary identity",
        )
        require(binary["routine_bytes"] > 0, "No compiled routine")
    for fixed in ["fixed-edge", "fixed-service"]:
        require(
            record["binaries"][fixed] == record["binaries"]["working"],
            "Repaired executable differs",
        )
        for label in ["waiting", "pressed", "held", "second"]:
            require(
                record["artifacts"][f"{fixed}-{label}.png"]
                == record["artifacts"][f"working-{label}.png"],
                "Repair failed to restore image",
            )
    tools = json.loads((root / V.SHARED / "toolchain.json").read_text())
    for name, digest in [
        ("asm198x", record["assembler_sha256"]),
        (f"emu198x-{system}", record["emulator_sha256"]),
    ]:
        require(
            next(t["binary_sha256"] for t in tools if t["tool"] == name) == digest,
            "Wrong qualification tool",
        )
    require(
        bool(record["firmware_sha256"]) == (system == "atari-5200"),
        "Missing/unexpected firmware",
    )


if __name__ == "__main__":
    for system in V.SYSTEMS:
        check(system)
        print(system, "bound native evidence checked; no fresh execution")
