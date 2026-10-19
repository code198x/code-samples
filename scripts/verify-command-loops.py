"""Run an untimed command loop through real CBM firmware and keyboard input."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "loop_transport", Path(__file__).with_name("verify-game-loops.py")
)
TRANSPORT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(TRANSPORT)
OBSERVER_SHA = TRANSPORT.sha(Path(__file__))
TRANSPORT_SHA = TRANSPORT.sha(ROOT / "scripts/verify-game-loops.py")
SYSTEMS = {
    "commodore-vic-20": (0x1E00, 506),
    "commodore-pet": (0x8000, 1000),
    "amstrad-cpc": (40000, 1),
    "msx": (40000, 1),
    "atari-800xl": (0, 960),
    "spectravideo-svi-328": (40000, 1),
    "acorn-atom": (0x8000, 512),
    "mattel-aquarius": (0x3000, 1000),
    "dragon-32": (0x0400, 512),
    "oric-atmos": (0xBB80, 1120),
}


def run(system: str, native: Path, firmware_root: Path) -> dict:
    folder = ROOT / system / "patterns/basic/framework/command-loop"
    out = folder / "build/verification"
    out.mkdir(parents=True, exist_ok=True)
    source = (folder / "demo.bas").read_text()
    executable = native / ("emu198x-" + {"dragon-32": "dragon"}.get(system, system))
    firmware = firmware_root / {"dragon-32": "dragon", "oric-atmos": "oric"}.get(
        system, system
    )
    command = [str(executable), "--mcp", "--rom-dir", str(firmware)]
    if system == "msx":
        firmware = firmware_root / "microsoft-msx"
        command = [str(executable), "--mcp", "--bios", str(firmware / "msx.rom")]
    machine = TRANSPORT.Machine(command)
    start, length = SYSTEMS[system]

    accepted = (
        "1\n"
        if system in ("dragon-32", "oric-atmos", "acorn-atom", "atari-800xl")
        else "GO\n"
    )
    invalid = (
        "0\n"
        if system in ("dragon-32", "oric-atmos", "acorn-atom", "atari-800xl")
        else "NO\n"
    )

    def state() -> int:
        if length == 1:
            return machine.call("memory_read", addr=start, len=1)["bytes"][0]
        address = start
        if system == "atari-800xl":
            pointer = machine.call("memory_read", addr=0x58, len=2)["bytes"]
            address = pointer[0] + 256 * pointer[1]
        raw = []
        for offset in range(0, length, 256):
            raw.extend(
                machine.call(
                    "memory_read", addr=address + offset, len=min(256, length - offset)
                )["bytes"]
            )
        if system in ("dragon-32", "acorn-atom"):
            raw = [c & 63 for c in raw]
        text = "".join(
            chr(c & 127)
            if 32 <= (c & 127) < 64
            else chr((c & 127) + 64)
            if 1 <= (c & 127) <= 26
            else " "
            for c in raw
        )
        if system in ("oric-atmos", "mattel-aquarius"):
            text = "".join(chr(c & 127) if 32 <= (c & 127) < 127 else " " for c in raw)
        if system == "atari-800xl":
            text = "".join(chr((c & 127) + 32) if (c & 127) < 64 else " " for c in raw)
        matches = re.findall(r"TURN\s*(\d+)", text, re.IGNORECASE)
        TRANSPORT.require(
            bool(matches) if system == "mattel-aquarius" else len(matches) == 1,
            f"Expected one rendered turn counter: {text}",
        )
        return int(matches[-1])

    def type_text(text: str) -> None:
        typed = machine.call("type_string", text=text)
        TRANSPORT.require(
            typed["chars_typed"] == len(text), f"Incomplete keyboard entry: {typed}"
        )
        machine.call("run_frames", frames=10)

    def boot(program: str) -> None:
        machine.call(
            "run_frames",
            frames=900 if system in ("spectravideo-svi-328", "atari-800xl") else 150,
        )
        if system == "mattel-aquarius":
            type_text("\n")
        if system == "atari-800xl":
            for line in (program + "RUN\n").splitlines():
                typed = machine.call("type_string", text=line + "\n", settle_frames=60)
                TRANSPORT.require(
                    typed["chars_typed"] == len(line) + 1, "Incomplete Atari line"
                )
        else:
            type_text(program + "RUN\n")

    try:
        boot(source)
        TRANSPORT.require(state() == 0, "Program did not initialise its own state")
        machine.call("run_frames", frames=120)
        TRANSPORT.require(state() == 0, "Rule state advanced without a command")
        machine.call("save_screenshot", path=str(out / "waiting.png"))
        type_text(invalid)
        TRANSPORT.require(state() == 0, "Invalid command changed rule state")
        type_text(accepted)
        TRANSPORT.require(state() == 1, "First accepted command did not advance once")
        machine.call("run_frames", frames=120)
        TRANSPORT.require(state() == 1, "Waiting after a turn changed state")
        machine.call("save_screenshot", path=str(out / "one-turn.png"))
        type_text(accepted)
        TRANSPORT.require(state() == 2, "Second command did not advance exactly once")
        machine.call("save_screenshot", path=str(out / "two-turns.png"))
        server = machine.server.get("serverInfo")
        machine.close()
        # A zero-valued initialiser could be silently lost because some BASICs
        # default an undefined numeric variable to zero. Test a nonzero source
        # initial condition too, through the same cold keyboard entry path.
        machine = TRANSPORT.Machine(command)
        initial = "20 N=0:POKE 40000,0" if length == 1 else "10 N=0"
        replacement = "20 N=37:POKE 40000,37" if length == 1 else "10 N=37"
        TRANSPORT.require(
            source.count(initial) == 1, "Ambiguous nonzero initialisation"
        )
        boot(source.replace(initial, replacement))
        TRANSPORT.require(
            state() == 37, "Source initialiser did not reach the running program"
        )
        type_text(accepted)
        TRANSPORT.require(
            state() == 38, "Nonzero source did not preserve the update rule"
        )
        machine.close()
        wrap_states = None
        if length == 1:
            # Change only the program's initial condition; no host state writes.
            initial = "20 N=0:POKE 40000,0"
            TRANSPORT.require(
                source.count(initial) == 1, "Ambiguous wrap initialisation"
            )
            machine = TRANSPORT.Machine(command)
            boot(source.replace(initial, "20 N=254:POKE 40000,254"))
            wrap_states = [state()]
            type_text(accepted)
            wrap_states.append(state())
            type_text(accepted)
            wrap_states.append(state())
            TRANSPORT.require(
                wrap_states == [254, 255, 0], f"Counter did not wrap: {wrap_states}"
            )
            machine.close()
        numeric = system in ("dragon-32", "oric-atmos", "acorn-atom", "atari-800xl")
        input_line = (
            "30 INPUT A" if numeric else "40 INPUT A$" if length == 1 else "30 INPUT A$"
        )
        next_line = "50" if length == 1 else "40"
        input_number = 40 if length == 1 else 30
        TRANSPORT.require(source.count(input_line) == 1, "Ambiguous command mutation")
        machine = TRANSPORT.Machine(command)
        separator = ";" if system == "acorn-atom" else ":"
        assignment = "A=1" if numeric else 'A$="GO"'
        variable = "A" if numeric else "A$"
        bypass = f"{input_number} IF N=0 THEN {assignment}{separator}GOTO {next_line}\n{input_number + 5} INPUT {variable}"
        boot(source.replace(input_line, bypass))
        machine.call("run_frames", frames=120)
        negative_count = state()
        TRANSPORT.require(negative_count != 0, "Bypassed input passed idle-state guard")
        firmware_names = ["basic.rom", "kernal.rom", "chargen.rom"]
        if system == "commodore-pet":
            firmware_names.append("editor.rom")
        elif system == "amstrad-cpc":
            firmware_names = ["cpc464.rom"]
        elif system == "msx":
            firmware_names = ["msx.rom"]
        elif system == "atari-800xl":
            firmware_names = ["atarixl.rom", "ataribas.rom"]
        elif system == "spectravideo-svi-328":
            firmware_names = ["svi-328.rom"]
        elif system == "dragon-32":
            firmware_names = ["dragon32.rom"]
        elif system == "oric-atmos":
            firmware_names = ["oric.rom"]
        elif system == "acorn-atom":
            firmware_names = ["atom.rom"]
        elif system == "mattel-aquarius":
            firmware_names = ["aquarius.rom", "aquarius-char.rom"]
        result = {
            "status": "passed",
            "machine_id": {
                "msx": "microsoft-msx1",
                "dragon-32": "dragon",
                "oric-atmos": "oric",
            }.get(system, system),
            "server": server,
            "configuration": {
                "commodore-vic-20": "PAL VIC-20, unexpanded",
                "commodore-pet": "40-column PET",
                "amstrad-cpc": "CPC464 PAL, MODE 1",
                "msx": "MSX1 NTSC, pinned MSX BASIC/BIOS",
                "atari-800xl": "800XL NTSC, pinned OS/BASIC, GRAPHICS 0",
                "spectravideo-svi-328": "SVI-328 NTSC, typed-semicolon fix at emulator commit ab2e82189561dbd09150952f6818ef47278353f6",
                "acorn-atom": "Atom base, fixed Space mapping at emulator commit 7b16f8b7f86ae8f37ab3f1bf69f9b0d23a89fbb4",
                "mattel-aquarius": "Aquarius default configuration",
                "dragon-32": "Dragon 32 PAL",
                "oric-atmos": "Oric Atmos",
            }[system],
            "startup": "Fresh firmware reset; complete numbered BASIC program and RUN typed through keyboard",
            "idle_frames_before_and_after_command": 120,
            "invalid_command_state": 0,
            "accepted_command_states": [1, 2],
            "nonzero_initialisation_states": [37, 38],
            "byte_counter_wrap": wrap_states,
            "screen_ram": {
                "start": "SAVMSC ($58/$59)" if system == "atari-800xl" else start,
                "bytes": length,
                "decoder": "reserved byte above BASIC HIMEM"
                if length == 1
                else {
                    "acorn-atom": "MC6847 six-bit display codes",
                    "dragon-32": "MC6847 six-bit display codes",
                    "oric-atmos": "ASCII text, inverse bit masked",
                    "mattel-aquarius": "ASCII text, inverse bit masked; newest TURN line",
                    "atari-800xl": "ANTIC internal screen codes, inverse bit masked; live SAVMSC",
                }.get(system, "PETSCII screen codes, inverse bit masked"),
            },
            "negative_control": {
                "type": "bypass-command",
                "idle_guard_rejected": True,
                "observed_turn": negative_count,
            },
            "firmware_sha256": {
                name: TRANSPORT.sha(firmware / name) for name in firmware_names
            },
            "emulator_sha256": TRANSPORT.sha(executable),
            "emulator_source_commit": {
                "acorn-atom": "7b16f8b7f86ae8f37ab3f1bf69f9b0d23a89fbb4",
                "spectravideo-svi-328": "ab2e82189561dbd09150952f6818ef47278353f6",
            }.get(system, "6cc5d5f9e7fe6507a079f237bc44da0dc95fe25c"),
            "sources": {
                str((folder / "demo.bas").relative_to(ROOT)): hashlib.sha256(
                    source.encode()
                ).hexdigest(),
                str(Path(__file__).relative_to(ROOT)): OBSERVER_SHA,
                "scripts/verify-game-loops.py": TRANSPORT_SHA,
            },
            "limits": "Untimed numeric turn state and line-input/display path only. Firmware clocks/IRQs continue; no deadline, joystick, frame pacing, original-hardware or complete emulator claim.",
        }
        (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
        return result
    finally:
        if machine.process.poll() is None:
            machine.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument(
        "--firmware-root", type=Path, default=Path.home() / ".emu198x/roms"
    )
    parser.add_argument("--only", choices=SYSTEMS)
    args = parser.parse_args()
    for system in [args.only] if args.only else SYSTEMS:
        result = run(system, args.native.resolve(), args.firmware_root.resolve())
        print(system, result["status"], result["negative_control"], flush=True)


if __name__ == "__main__":
    main()
