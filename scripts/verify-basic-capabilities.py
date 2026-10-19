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
    folder = ROOT / system / "patterns/basic/capabilities/input-drawing-sound"
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
    invalid = "0\n" if accepted == "1\n" else "NO\n"

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

    def counter(machine) -> int:
        start, length = C.SYSTEMS[system]
        if length == 1:
            return machine.call("memory_read", addr=start, len=1)["bytes"][0]
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
        return int(matches[-1])

    def audible(info: dict) -> None:
        T.require(
            max(info["channel_ranges"]) > 200
            and max(info["ac_power"]) > max(1000, 4 * max(baseline["ac_power"])),
            f"No program sound above keyboard baseline: {info}; baseline={baseline}",
        )

    machine = start(source)
    try:
        T.require(counter(machine) == 0, "Caller did not initialise")
        ready = capture(machine, "ready")
        machine.call("start_audio_recording", path=str(out / "keyboard-baseline.wav"))
        type_text(machine, invalid)
        machine.call("stop_audio_recording")
        baseline = A.pcm_range(out / "keyboard-baseline.wav")
        T.require(counter(machine) == 0, "Invalid command advanced state")
        machine.call("start_audio_recording", path=str(out / "sound.wav"))
        type_text(machine, accepted)
        machine.call("stop_audio_recording")
        T.require(counter(machine) == 1, "Accepted input failed")
        sound = A.pcm_range(out / "sound.wav") if "GOSUB 2000" in source else None
        if sound:
            audible(sound)
        capture(machine, "accepted")
        server = machine.server.get("serverInfo")
        machine.close()
        T.require(source.count("GOSUB 1000") == 1, "Ambiguous drawing call")
        no_draw = source.replace("GOSUB 1000", "REM DRAW OMITTED")
        machine = start(no_draw)
        T.require(counter(machine) == 0, "Drawing negative failed before guard")
        omitted = capture(machine, "drawing-negative")
        T.require(
            ready[0] == omitted[0] and ready[1] != omitted[1],
            "Drawing produced no visible difference",
        )
        machine.close()
        sound_rejected = None
        if sound:
            T.require(source.count("GOSUB 2000") == 1, "Ambiguous sound call")
            machine = start(
                source.replace(":GOSUB 2000", "").replace(";GOSUB 2000", "")
            )
            machine.call("start_audio_recording", path=str(out / "sound-negative.wav"))
            type_text(machine, accepted)
            machine.call("stop_audio_recording")
            T.require(counter(machine) == 1, "Sound negative failed before guard")
            negative_sound = A.pcm_range(out / "sound-negative.wav")
            try:
                audible(negative_sound)
            except AssertionError:
                sound_rejected = True
            else:
                sound_rejected = False
            T.require(
                sound_rejected,
                f"Omitted sound passed guard (keyboard/ROM output may be audible): {negative_sound}",
            )
        result = {
            "status": "passed",
            "system": system,
            "configuration": "Stock BASIC and current command-loop firmware configuration",
            "server": server,
            "sources": {
                str(folder.relative_to(ROOT) / "demo.bas"): T.sha(folder / "demo.bas")
            },
            "observer_sha256": T.sha(Path(__file__)),
            "emulator_sha256": T.sha(executable),
            "input": "Blocking command input: invalid leaves count unchanged; accepted advances once",
            "drawing": "PRINT renders a three-row text-cell box; omitted call changes the picture",
            "sound": sound,
            "keyboard_baseline": baseline,
            "sound_negative_rejected": sound_rejected,
            "limits": "Configuration-specific native emulator observations; not non-blocking controls, a sprite renderer, pitch accuracy or original hardware. Audio omitted where a separate hardware caller is still needed.",
        }
        record = folder / "verification/results.json"
        record.parent.mkdir(exist_ok=True)
        record.write_text(json.dumps(result, indent=2) + "\n")
        print("PASS", system, sound, flush=True)
        return result
    except Exception:
        if machine.process.poll() is None:
            machine.call("save_screenshot", path=str(out / "failure.png"))
        raise
    finally:
        if machine.process.poll() is None:
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
