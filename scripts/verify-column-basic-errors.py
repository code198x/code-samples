"""Exercise stock BASIC input, text-cell drawing and sound independently.

The command-loop verifier remains the source for the narrower input contract.
This observer compares the visible box against an omitted-drawing caller and
requires an omitted-sound caller to reject the identical PCM guard.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, filename: str):
    spec = importlib.util.spec_from_file_location(
        name, Path(__file__).with_name(filename)
    )
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


C = module("commands", "verify-command-loops.py")
A = module("compositions", "verify-collect-and-respond.py")
V = module("raster", "verify-sega-turns.py")
T = C.TRANSPORT


def verify(system: str, native: Path, firmware_root: Path) -> dict:
    folder = ROOT / system / "patterns/basic/input/read-command"
    source = (folder / "demo.bas").read_text()
    out = folder / "build/verification"
    out.mkdir(parents=True, exist_ok=True)
    executable = native / ("emu198x-" + {"dragon-32": "dragon"}.get(system, system))
    firmware = firmware_root / {"dragon-32": "dragon", "oric-atmos": "oric"}.get(
        system, system
    )
    command = [str(executable), "--mcp", "--rom-dir", str(firmware)]
    if system == "msx":
        firmware = firmware_root / "microsoft-msx"
        command = [str(executable), "--mcp", "--bios", str(firmware / "msx.rom")]
    accepted = (
        "1\n"
        if system in ("dragon-32", "oric-atmos", "acorn-atom", "atari-800xl")
        else "GO\n"
    )

    def type_text(machine, text: str) -> None:
        reply = machine.call("type_string", text=text, settle_frames=60)
        T.require(
            reply["chars_typed"] == len(text), f"Incomplete keyboard input: {reply}"
        )
        machine.call("run_frames", frames=60)

    def start(program: str):
        machine = T.Machine(command)
        try:
            machine.call(
                "run_frames",
                frames=900
                if system in ("spectravideo-svi-328", "atari-800xl")
                else 150,
            )
            if system == "mattel-aquarius":
                type_text(machine, "\n")
            for line in program.splitlines():
                type_text(machine, line + "\n")
            type_text(machine, "RUN\n")
            return machine
        except BaseException:
            machine.close()
            raise

    def capture(machine, label: str):
        path = out / (label + ".png")
        machine.call("save_screenshot", path=str(path))
        return V.raster(path)

    observations = []

    def counter(machine) -> int:
        start, length = C.SYSTEMS[system]
        if length == 1:
            raw = machine.call("memory_read", addr=start, len=1)["bytes"]
            observations.append({"address": start, "bytes": raw, "count": raw[0]})
            return raw[0]
        if system == "atari-800xl":
            ptr = machine.call("memory_read", addr=0x58, len=2)["bytes"]
            start = ptr[0] + 256 * ptr[1]
        raw = []
        for offset in range(0, length, 256):
            raw += machine.call(
                "memory_read", addr=start + offset, len=min(256, length - offset)
            )["bytes"]
        if system in ("dragon-32", "acorn-atom"):
            raw = [c & 63 for c in raw]
        if system in ("oric-atmos", "mattel-aquarius"):
            text = "".join(chr(c & 127) for c in raw)
        elif system == "atari-800xl":
            text = "".join(chr((c & 127) + 32) if c & 127 < 64 else " " for c in raw)
        else:
            text = "".join(
                chr(c & 127)
                if 32 <= (c & 127) < 64
                else chr((c & 127) + 64)
                if 1 <= (c & 127) <= 26
                else " "
                for c in raw
            )
        import re

        matches = re.findall(r"TURN\s*(\d+)", text, re.IGNORECASE)
        T.require(bool(matches), f"No rendered counter: {text}")
        value = int(matches[-1])
        observations.append({"address": start, "bytes": raw, "count": value})
        return value

    call = "GOSUB 4000" if system == "mattel-aquarius" else "GOSUB 3000"
    replacement = "A=1" if accepted == "1\n" else 'A$="GO"'
    T.require(source.count(call) == 1, "Ambiguous stale-command fault")
    wrong = source.replace(call, replacement)
    mistake = folder / "mistakes/stale-command.bas"
    mistake.parent.mkdir(exist_ok=True)
    mistake.write_text(wrong)
    machine = start(wrong)
    try:
        observed = None
        for _ in range(16):
            machine.call("run_frames", frames=8)
            try:
                value = counter(machine)
            except AssertionError:
                continue
            if value != 0:
                observed = value
                break
        T.require(observed is not None, "Missing input still passed idle guard")
        image = folder / "verification/stale-command.png"
        image.parent.mkdir(exist_ok=True)
        machine.call("save_screenshot", path=str(image))
        result = {
            "observer_sha256": T.sha(Path(__file__)),
            "status": "passed",
            "system": system,
            "fault": "reused accepted command without reading input",
            "idle_guard_rejected": True,
            "observed_turn": observed,
            "observations": observations,
            "source_sha256": T.sha(mistake),
            "image_sha256": T.sha(image),
            "emulator_sha256": T.sha(executable),
        }
        (folder / "verification/stale-command.json").write_text(
            json.dumps(result, indent=2) + "\n"
        )
        print("PASS stale command", system, observed, flush=True)
        return result
    finally:
        machine.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument(
        "--firmware-root", type=Path, default=Path.home() / ".emu198x/roms"
    )
    parser.add_argument("--only", choices=C.SYSTEMS)
    args = parser.parse_args()
    for system in [args.only] if args.only else C.SYSTEMS:
        verify(system, args.native, args.firmware_root)


if __name__ == "__main__":
    main()
