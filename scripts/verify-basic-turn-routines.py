"""Qualify callable BASIC turn updates through firmware keyboard entry.

Complete programs concatenate a maintained caller and routines.bas. Deliberately
broken callers remain separate. No emulator state is injected by the observer.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "loop_transport", ROOT / "scripts/verify-game-loops.py"
)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Cannot load native transport")
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
SYSTEMS = ("acorn-atom", "amstrad-cpc")


def run(system: str, native: Path, firmware_root: Path) -> dict[str, Any]:
    folder = ROOT / system / "patterns/basic/framework/command-loop"
    out = folder / "verification/reusable"
    out.mkdir(parents=True, exist_ok=True)
    executable = native / f"emu198x-{system}-aarch64-apple-darwin" / f"emu198x-{system}"
    firmware = firmware_root / system
    atom = system == "acorn-atom"
    traces = {}
    images = {}
    server = None
    for name, caller, initial, expected in [
        ("default", "caller.bas", 0, [1, 2]),
        ("step-two", "customise.bas", 0, [2, 4]),
        ("nonzero", "caller.bas", 37, [38, 39]),
        ("reset-mistake", "mistakes/reset-each-turn.bas", 0, [1, 1]),
    ] + ([] if atom else [("byte-wrap", "caller.bas", 254, [255, 0])]):
        listing = (folder / caller).read_text()
        T.require(listing.count("N=0") >= 1, "Initialiser missing")
        # Replace only startup; the maintained fault must keep resetting N.
        listing = listing.replace("N=0", f"N={initial}", 1)
        listing += (folder / "routines.bas").read_text()
        machine = T.Machine([str(executable), "--mcp", "--rom-dir", str(firmware)])
        try:
            server = machine.server["serverInfo"]

            def type_text(text: str, machine: Any = machine) -> None:
                result = machine.call("type_string", text=text)
                T.require(
                    result["chars_typed"] == len(text), "Incomplete keyboard entry"
                )
                machine.call("run_frames", frames=10)

            def state(field: str = "TURN", machine: Any = machine) -> int:
                if not atom:
                    return machine.call(
                        "memory_read", addr=40000 if field == "TURN" else 40001, len=1
                    )["bytes"][0]
                raw = []
                for offset in (0, 256):
                    raw += machine.call("memory_read", addr=0x8000 + offset, len=256)[
                        "bytes"
                    ]
                text = "".join(
                    chr(c & 63)
                    if 32 <= (c & 63) < 64
                    else chr((c & 63) + 64)
                    if 1 <= (c & 63) <= 26
                    else " "
                    for c in raw
                )
                values = re.findall(field + r"\s*(\d+)", text)
                T.require(len(values) == 1, f"Expected one displayed counter: {text}")
                return int(values[0])

            def capture(label: str, machine: Any = machine, name: str = name) -> str:
                image = out / f"{name}-{label}.png"
                machine.call("save_screenshot", path=str(image))
                images[image.name] = T.sha(image)
                return images[image.name]

            machine.call("run_frames", frames=150)
            type_text(listing + "RUN\n")
            T.require(state() == initial, f"{name}: startup")
            T.require(state("FLAG") == 0, f"{name}: initial acceptance flag")
            before = capture("waiting")
            machine.call("run_frames", frames=120)
            T.require(state() == initial, f"{name}: advanced while idle")
            type_text("0\n" if atom else "NO\n")
            T.require(state() == initial, f"{name}: invalid command changed state")
            observed = [state()]
            for i, value in enumerate(expected):
                type_text("1\n" if atom else "GO\n")
                T.require(state("FLAG") == 1, f"{name}: accepted flag")
                observed.append(state())
                T.require(
                    observed[-1] == value,
                    f"{name}: expected {value}, got {observed[-1]}",
                )
                machine.call("run_frames", frames=120)
                T.require(state() == value, f"{name}: idle after action")
                capture(f"action-{i + 1}")
            type_text("0\n" if atom else "NO\n")
            T.require(
                state() == (0 if name == "reset-mistake" else expected[-1])
                and state("FLAG") == 0,
                f"{name}: rejection did not clear flag",
            )
            if name == "default":
                T.require(
                    before != images[f"{name}-action-1.png"],
                    "Rendered output did not change",
                )
            traces[name] = observed
        finally:
            machine.close()
    T.require(
        traces["reset-mistake"] != traces["default"],
        "Fault escaped the progression guard",
    )
    sources = [
        "caller.bas",
        "customise.bas",
        "routines.bas",
        "mistakes/reset-each-turn.bas",
        "qualification-toolchain.json",
    ]
    record = {
        "status": "passed",
        "machine_id": system,
        "server": server,
        "configuration": "Base Atom integer BASIC, 2.5 KiB RAM"
        if atom
        else "CPC464 PAL, Locomotive BASIC, MODE 1",
        "startup": "Cold firmware boot; complete caller plus routines and RUN typed through keyboard",
        "traces": traces,
        "idle_frames_per_observation": 120,
        "invalid_command_unchanged_in_working_callers": True,
        "reset_fault_rejected_command_state": 0,
        "reset_fault_rejected_by_progression_guard": True,
        "sources": {
            str((folder / s).relative_to(ROOT)): T.sha(folder / s) for s in sources
        },
        "observer_sources": {
            str(Path(__file__).relative_to(ROOT)): T.sha(Path(__file__)),
            "scripts/verify-game-loops.py": T.sha(
                ROOT / "scripts/verify-game-loops.py"
            ),
        },
        "program_sha256": {
            name: T.sha(folder / name) for name in ["caller.bas", "customise.bas"]
        },
        "firmware_sha256": {
            f.name: T.sha(f)
            for f in [firmware / ("atom.rom" if atom else "cpc464.rom")]
        },
        "emulator_sha256": T.sha(executable),
        "images": images,
        "limits": "Untimed line-input turns; no deadline, frame rate, audio servicing or original-hardware claim. CPC byte is caller-owned observation storage at 40000/40001 above MEMORY 39999.",
    }
    (out / "results.json").write_text(json.dumps(record, indent=2) + "\n")
    return record


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument(
        "--firmware-root", type=Path, default=Path.home() / ".emu198x/roms"
    )
    parser.add_argument("--only", choices=SYSTEMS)
    args = parser.parse_args()
    for system in [args.only] if args.only else SYSTEMS:
        record = run(system, args.native.resolve(), args.firmware_root.resolve())
        print(system, record["traces"], flush=True)


if __name__ == "__main__":
    main()
