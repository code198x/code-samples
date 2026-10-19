"""Run 1 KiB ZX80/ZX81 BASIC callers via their different keyword keyboards."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "transport", Path(__file__).with_name("verify-game-loops.py")
)
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
OBSERVER = T.sha(Path(__file__))
KEYS = {
    "sinclair-zx80": {"LET": "k", "CLS": "c", "PRINT": "o", "INPUT": "i", "GOTO": "g"},
    "sinclair-zx81": {"LET": "l", "CLS": "v", "PRINT": "p", "INPUT": "i", "GOTO": "g"},
}


def run(system: str, native: Path, firmware_root: Path) -> dict:
    folder = ROOT / system / "patterns/basic/framework/command-loop"
    output = folder / "build/verification"
    output.mkdir(parents=True, exist_ok=True)
    source = (folder / "demo.bas").read_text()
    executable = native / ("emu198x-" + system)
    firmware = (
        firmware_root / system / ("zx80.rom" if system.endswith("80") else "zx81.rom")
    )
    machine = None

    def key(name: str) -> None:
        machine.call("press_key", key=name, hold_frames=10)
        machine.call("run_frames", frames=30)

    def characters(text: str) -> None:
        for ch in text.lower():
            if ch in "=+":
                machine.call(
                    "press_keys",
                    keys=["shift", "l" if ch == "=" else "k"],
                    hold_frames=10,
                )
                machine.call("run_frames", frames=30)
            else:
                key(ch)

    def boot(program: str) -> None:
        nonlocal machine
        if machine is not None:
            machine.close()
        machine = T.Machine(
            [str(executable), "--mcp", "--rom", str(firmware), "--ram-bytes", "1024"]
        )
        machine.call("run_frames", frames=150)
        for line in program.splitlines():
            number, keyword, *argument = line.split(maxsplit=2)
            characters(number)
            key(KEYS[system][keyword])
            if argument:
                characters(argument[0])
            key("enter")
        key("r")
        key("enter")
        machine.call("run_frames", frames=60)

    def state() -> int:
        pointer = machine.call("memory_read", addr=0x400C, len=2)["bytes"]
        address = pointer[0] + 256 * pointer[1]
        raw = machine.call("memory_read", addr=address, len=80)["bytes"]
        # Both ROMs put the printed counter on the first display line. Read
        # D_FILE each time; editing/input can relocate it. Ignore the editor
        # cursor below, and never search arbitrary RAM for a convenient digit.
        T.require(raw[0] == 118, "D_FILE must start with NEWLINE")
        end = raw.index(118, 1)
        digits = raw[1:end]
        T.require(
            bool(digits) and all(28 <= ch <= 37 for ch in digits),
            f"Expected the printed numeric counter, got {digits}",
        )
        return int("".join(str(ch - 28) for ch in digits))

    def submit(value: str) -> None:
        characters(value)
        key("enter")

    try:
        boot(source)
        T.require(state() == 0, "Caller did not initialise its own counter")
        machine.call("run_frames", frames=120)
        T.require(state() == 0, "Idle changed the counter")
        submit("0")
        T.require(state() == 0, "Zero input changed the running total")
        submit("1")
        T.require(state() == 1, "One submitted unit must add one")
        machine.call("run_frames", frames=120)
        T.require(state() == 1, "Waiting changed the running total")
        machine.call("save_screenshot", path=str(output / "one-turn.png"))
        submit("1")
        T.require(state() == 2, "Second submitted unit must add one")
        machine.call("save_screenshot", path=str(output / "two-turns.png"))
        server = machine.server.get("serverInfo")
        T.require(source.count("N=0") == 1, "Ambiguous nonzero initialisation variant")
        boot(source.replace("N=0", "N=7"))
        T.require(state() == 7, "Nonzero initialiser did not execute")
        submit("1")
        T.require(state() == 8, "Nonzero running total did not advance")
        T.require(source.count("N=N+A") == 1, "Ambiguous wrong-addition control")
        boot(source.replace("N=N+A", "N=N+A+A"))
        T.require(state() == 0, "Negative caller failed before the relevant guard")
        submit("1")
        observed = state()
        try:
            T.require(observed == 1, "One submitted unit must add one")
        except AssertionError:
            rejected = True
        else:
            rejected = False
        T.require(rejected, "Wrong-addition control passed the positive guard")
        result = {
            "status": "passed",
            "machine_id": system,
            "server": server,
            "configuration": "Stock PAL ROM, 1024 bytes RAM, keyword keyboard entry",
            "startup_kind": "stock-basic-keyword-entry",
            "idle_frames": 120,
            "accepted_command_states": [1, 2],
            "nonzero_initialisation_states": [7, 8],
            "negative_control": {
                "type": "wrong-addition",
                "accepted_turn_guard_rejected": True,
                "observed_turn": observed,
            },
            "keyboard_pacing": {"hold_frames": 10, "release_frames": 30},
            "firmware_sha256": T.sha(firmware),
            "emulator_sha256": T.sha(executable),
            "emulator_source_commit": "6cc5d5f9e7fe6507a079f237bc44da0dc95fe25c",
            "sources": {
                str((folder / "demo.bas").relative_to(ROOT)): T.sha(
                    folder / "demo.bas"
                ),
                str(Path(__file__).relative_to(ROOT)): OBSERVER,
                "scripts/verify-game-loops.py": T.sha(
                    ROOT / "scripts/verify-game-loops.py"
                ),
            },
            "limits": "An untimed numeric running total: submitted values are added, not restricted to 0/1. ROM-serviced input and display, no real-time or physical-hardware claim.",
        }
        (output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
        return result
    finally:
        if machine is not None and machine.process.poll() is None:
            machine.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument(
        "--firmware-root", type=Path, default=Path.home() / ".emu198x/roms"
    )
    parser.add_argument("--only", choices=KEYS)
    args = parser.parse_args()
    for system in [args.only] if args.only else KEYS:
        result = run(system, args.native.resolve(), args.firmware_root.resolve())
        print(system, result["status"], result["negative_control"], flush=True)


if __name__ == "__main__":
    main()
