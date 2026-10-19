"""Check a stock Jupiter Ace FORTH word through its real keyboard/display."""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "transport", Path(__file__).with_name("verify-game-loops.py")
)
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
OBSERVER = T.sha(Path(__file__))


def run(native: Path, firmware: Path) -> dict:
    folder = ROOT / "jupiter-ace/patterns/forth/framework/command-loop"
    source = (folder / "demo.fth").read_text()
    output = folder / "build/verification"
    output.mkdir(parents=True, exist_ok=True)
    executable = native / "emu198x-jupiter-ace"
    command = [str(executable), "--mcp", "--rom", str(firmware)]
    machine = T.Machine(command)

    def state() -> int:
        raw = []
        for offset in range(0, 768, 256):
            raw.extend(
                machine.call("memory_read", addr=0x2400 + offset, len=256)["bytes"]
            )
        text = "".join(chr(c & 127) if 32 <= (c & 127) < 127 else " " for c in raw)
        matches = re.findall(r"TURN\s+(\d+)", text, re.IGNORECASE)
        T.require(len(matches) == 1, f"Expected one rendered counter: {text}")
        return int(matches[0])

    def type_text(text: str) -> None:
        result = machine.call("type_string", text=text, settle_frames=60)
        T.require(result["chars_typed"] == len(text), "Incomplete keyboard input")

    def boot(program: str) -> None:
        machine.call("run_frames", frames=150)
        # Let each accepted source line compile before entering the next one.
        for line in program.splitlines():
            type_text(line + "\n")

    try:
        boot(source)
        T.require(state() == 0, "Word did not start at turn zero")
        machine.call("run_frames", frames=120)
        T.require(state() == 0, "Rules advanced without input")
        type_text("0")
        T.require(state() == 0, "Ignored key changed the turn")
        type_text("1")
        T.require(state() == 1, "First action did not advance once")
        machine.call("save_screenshot", path=str(output / "one-turn.png"))
        machine.call("input", events=[{"Key": {"name": "1", "pressed": True}}])
        machine.call("run_frames", frames=30)
        T.require(state() == 2, "Second action did not advance once")
        machine.call("run_frames", frames=120)
        T.require(state() == 2, "Held key repeated a turn")
        machine.call("input", events=[{"Key": {"name": "1", "pressed": False}}])
        machine.call("run_frames", frames=10)
        machine.call("save_screenshot", path=str(output / "two-turns.png"))
        server = machine.server.get("serverInfo")
        machine.close()
        T.require(source.count("NEWKEY 49 =") == 1, "Ambiguous negative mutation")
        mutant = source.replace("NEWKEY 49 =", "DUP 0= IF 49 ELSE NEWKEY THEN 49 =")
        machine = T.Machine(command)
        boot(mutant)
        negative = state()
        T.require(negative != 0, "Fabricated first key passed the idle guard")
        result = {
            "status": "passed",
            "machine_id": "jupiter-ace",
            "server": server,
            "configuration": "Stock 3 KiB Jupiter Ace, pinned FORTH ROM",
            "startup": "Fresh ROM boot; definitions entered line by line with compile settling, then TURNS",
            "idle_frames": 120,
            "held_key_frames": 120,
            "accepted_command_states": [1, 2],
            "negative_control": {
                "type": "bypass-key",
                "idle_guard_rejected": True,
                "observed_turn": negative,
            },
            "firmware_sha256": {"forth": T.sha(firmware)},
            "emulator_sha256": T.sha(executable),
            "emulator_source_commit": "6cc5d5f9e7fe6507a079f237bc44da0dc95fe25c",
            "sources": {
                str((folder / "demo.fth").relative_to(ROOT)): T.sha(
                    folder / "demo.fth"
                ),
                str(Path(__file__).relative_to(ROOT)): OBSERVER,
                "scripts/verify-game-loops.py": T.sha(
                    ROOT / "scripts/verify-game-loops.py"
                ),
            },
            "limits": "Untimed FORTH key/display path, one cell of state. No frame clock, deadline, original-hardware or whole-emulator claim.",
        }
        (output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
        return result
    finally:
        if machine.process.poll() is None:
            machine.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", required=True, type=Path)
    parser.add_argument(
        "--firmware",
        type=Path,
        default=Path.home() / ".emu198x/roms/jupiter-ace/ace.rom",
    )
    args = parser.parse_args()
    print(json.dumps(run(args.native.resolve(), args.firmware.resolve()), indent=2))


if __name__ == "__main__":
    main()
