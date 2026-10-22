"""Exercise composed routines through real input and native video/audio output.

No host writes establish positive game state. The final negative control disables
collection; it must fail the identical score/consumption guard.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
import sys
import wave
from array import array
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "loops", Path(__file__).with_name("verify-game-loops.py")
)
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
SYSTEMS = {**T.SYSTEMS, "electron": "acorn-electron"}


def pcm_range(path: Path) -> dict:
    with wave.open(str(path)) as stream:
        T.require(stream.getsampwidth() == 2, "Expected 16-bit PCM")
        data = array("h", stream.readframes(stream.getnframes()))
        if sys.byteorder != "little":
            data.byteswap()
        T.require(bool(data), "Empty audio capture")
        channels = stream.getnchannels()
        ranges = [
            max(data[c::channels]) - min(data[c::channels]) for c in range(channels)
        ]
        power = []
        for c in range(channels):
            values = data[c::channels]
            power.append(
                sum(x * x for x in values) / len(values)
                - (sum(values) / len(values)) ** 2
            )
        return {
            "frames": len(data) // channels,
            "rate": stream.getframerate(),
            "channel_ranges": ranges,
            "ac_power": power,
        }


def collected(state: dict) -> None:
    T.require(
        state["score"] == 1 and state["item_active"] == 0, f"Collection failed: {state}"
    )


def verify(name: str, args: argparse.Namespace) -> dict:
    folder = ROOT / SYSTEMS[name] / "patterns/assembly/input/mos-controls"
    subprocess.run(
        ["make", f"BUILD198X={args.build198x}"],
        cwd=folder,
        check=True,
        capture_output=True,
        timeout=60,
    )
    sym = T.symbols(folder / "build/demo.sym")
    out = folder / "build/verification"
    out.mkdir(exist_ok=True)
    executable = args.native / (
        "emu198x-"
        + {"bbc": "acorn-bbc-micro", "electron": "acorn-electron"}.get(name, name)
    )
    ext = {
        "c64": "prg",
        "spectrum": "sna",
        "amiga": "adf",
        "nes": "nes",
        "bbc": "bin",
        "electron": "bin",
    }[name]
    binary = folder / f"build/demo.{ext}"
    command = [str(executable), "--mcp"]
    fw = args.firmware_root
    firmware = []
    startup = ""
    if name == "spectrum":
        firmware = [fw / "sinclair-zx-spectrum-48k/48.rom"]
        command += ["--rom", str(firmware[0])]
        startup = "48K snapshot; TAP is built separately and requires tape execution qualification"
    elif name == "nes":
        command += ["--rom", str(binary), "--region", "ntsc"]
        startup = "NTSC NROM cartridge reset"
    elif name == "c64":
        firmware = [
            fw / "commodore-c64" / n for n in ["basic.rom", "kernal.rom", "chargen.rom"]
        ]
        command += ["--model", "pal", "--rom-dir", str(fw / "commodore-c64")]
        script = out / "import.json"
        snapshot = out / "import.vsf"
        script.write_text(
            json.dumps([{"action": "save_snapshot", "path": str(snapshot)}])
        )
        subprocess.run(
            [
                str(executable),
                "--model",
                "pal",
                "--rom-dir",
                str(fw / "commodore-c64"),
                "--load",
                str(binary),
                "--script",
                str(script),
            ],
            check=True,
            capture_output=True,
            timeout=60,
        )
        startup = (
            "ROM boot and PRG import; snapshot resumes imported BASIC state; typed RUN"
        )
    elif name in ("bbc", "electron"):
        firmware = [
            fw / ("acorn-bbc-micro" if name == "bbc" else "acorn-electron") / n
            for n in ["os.rom", "basic.rom"]
        ]
        command += (
            ["--mos", str(firmware[0]), "--rom", f"acorn-bbc-basic={firmware[1]}"]
            if name == "bbc"
            else ["--os", str(firmware[0]), "--basic", str(firmware[1])]
        )
        startup = "Cold MOS/BASIC boot, DATA loader typed through keyboard, RUN"
    else:
        firmware = [fw / "commodore-amiga/kick13.rom"]
        command += [
            "--model",
            "a500",
            "--kickstart",
            str(firmware[0]),
            "--disk",
            str(binary),
        ]
        startup = "Cold boot original ADF; A500 OCS PAL/Kickstart 1.3"
    machine = T.Machine(command)
    base = 0
    big = name == "amiga"
    width = 2 if big else 1

    def read(label: str) -> int:
        return T.memory(machine, base + sym[label], width, big)

    def state() -> dict:
        return {
            n: read(n)
            for n in [
                "player_x",
                "player_y",
                "score",
                "item_active",
                "pressed",
                "released",
            ]
        }

    def frames(n: int) -> None:
        machine.call("run_frames", frames=n)

    def key(control: str, down: bool) -> None:
        if name in ("spectrum", "bbc", "electron"):
            event = {
                "Key": {
                    "name": {
                        "up": "q",
                        "down": "a",
                        "left": "o",
                        "right": "p",
                        "action": "space",
                    }[control],
                    "pressed": down,
                }
            }
        else:
            event = {
                "Button": {
                    "port": 1 if name == "nes" else 2,
                    "name": ("a" if name == "nes" else "fire")
                    if control == "action"
                    else control,
                    "pressed": down,
                }
            }
        machine.call("input", events=[event])

    def walk_to_item() -> None:
        key("right", True)
        for _ in range(70):
            frames(1)
            if read("player_x") == 9:
                T.require(
                    read("score") == 0 and read("item_active") == 1,
                    "Edge-only contact collected the item",
                )
            if read("player_x") == 10:
                break
        else:
            raise AssertionError("Right input never reached target cell")
        key("right", False)
        frames(2)

    def reset() -> None:
        key("action", False)
        frames(2)
        key("action", True)
        frames(2)
        key("action", False)
        frames(2)
        T.require(
            (read("player_x"), read("player_y"), read("score"), read("item_active"))
            == (2, 5, 0, 1),
            f"Reset failed: {state()}",
        )

    try:
        if name == "spectrum":
            machine.call("load_snapshot", path=str(binary))
            frames(20)
        elif name == "c64":
            machine.call("load_snapshot", path=str(snapshot))
            machine.call("type_string", text="RUN\n", hold_frames=3, settle_frames=15)
        elif name in ("bbc", "electron"):
            frames(150)
            for line in (folder / "build/loader.bas").read_text().splitlines():
                machine.call(
                    "type_string", text=line + "\n", hold_frames=2, settle_frames=2
                )
            machine.call("type_string", text="RUN\n", hold_frames=2, settle_frames=10)
            frames(180)
        elif name == "amiga":
            found = []
            for _ in range(25):
                frames(100)
                scan = machine.call(
                    "memory_scan", start=0, end=0x80000, value=0x31393858
                )
                T.require(not scan["truncated"], "Signature scan truncated")
                for hit in scan["hits"]:
                    candidate = int(hit["addr"][1:], 16) - sym["signature"]
                    if T.memory(machine, candidate + sym["ready"], 2, True) == 0xCAFE:
                        found.append(candidate)
                if found:
                    break
            T.require(len(found) == 1, f"Expected one relocated program: {found}")
            base = found[0]
        else:
            frames(30)
        initial = state()
        T.require(
            (
                initial["player_x"],
                initial["player_y"],
                initial["score"],
                initial["item_active"],
            )
            == (2, 5, 0, 1),
            f"Startup failed: {initial}",
        )
        machine.call("save_screenshot", path=str(out / "ready.png"))
        frames(30)
        T.require(state() == initial, "Idle input changed state")
        machine.call("start_audio_recording", path=str(out / "collect.wav"))
        walk_to_item()
        at_item = state()
        collected(at_item)
        frames(45)
        collected(state())
        T.require(read("score") == 1, "Standing on item collected repeatedly")
        machine.call("stop_audio_recording")
        sound = pcm_range(out / "collect.wav")
        T.require(
            max(sound["channel_ranges"]) > 200, f"No changing audible PCM: {sound}"
        )
        machine.call("save_screenshot", path=str(out / "collected.png"))
        # New press restarts once; holding it must allow subsequent movement.
        key("action", True)
        frames(2)
        T.require(read("score") == 0, "New action did not reset score")
        key("right", True)
        frames(24)
        T.require(read("player_x") > 3, "Held action repeatedly restarted player")
        key("right", False)
        key("action", False)
        frames(2)
        reset()
        bounds = {}
        for control, label, expected in [
            ("left", "player_x", 0),
            ("up", "player_y", 0),
            ("right", "player_x", 15),
            ("down", "player_y", 9),
        ]:
            key(control, True)
            frames(110)
            key(control, False)
            frames(2)
            bounds[control] = read(label)
            T.require(bounds[control] == expected, f"{control} bound failed: {state()}")
        reset()
        # Isolate sound with an explicit diagnostic RAM intervention. The
        # original binary is loaded unchanged; only this negative run patches
        # trigger_sound's first instruction to RTS, then restores it.
        trigger_address = base + sym["trigger_sound"]
        original_opcode = machine.call("memory_read", addr=trigger_address, len=1)[
            "bytes"
        ][0]
        machine.call("poke_byte", addr=trigger_address, value=0x60)
        machine.call("start_audio_recording", path=str(out / "sound-negative.wav"))
        walk_to_item()
        collected(state())
        frames(45)
        machine.call("stop_audio_recording")
        muted = pcm_range(out / "sound-negative.wav")
        T.require(
            max(muted["channel_ranges"]) <= 200, "Omitted MOS sound passed audio guard"
        )
        machine.call("save_screenshot", path=str(out / "sound-negative.png"))
        machine.call("poke_byte", addr=trigger_address, value=original_opcode)
        reset()
        # Disable the real collection path only AFTER all positive checks.
        if name == "nes":
            negative_rules = folder / "negative-rules.inc"
            negative_source = folder / "negative.asm"
            original = (folder / "rules.inc").read_text()
            T.require(
                original.count("jsr boxes_overlap") == 1, "Ambiguous negative control"
            )
            negative_rules.write_text(
                original.replace("jsr boxes_overlap", "clc\n    nop\n    nop")
            )
            negative_source.write_text(
                (folder / "demo.asm")
                .read_text()
                .replace('"rules.inc"', '"negative-rules.inc"')
            )
            try:
                subprocess.run(
                    [
                        "asm198x",
                        "--dialect",
                        "ca65",
                        str(negative_source),
                        "-o",
                        str(out / "negative.nes"),
                    ],
                    check=True,
                    capture_output=True,
                    timeout=30,
                )
            finally:
                negative_rules.unlink()
                negative_source.unlink()
            machine.close()
            machine = T.Machine(
                [
                    str(executable),
                    "--mcp",
                    "--rom",
                    str(out / "negative.nes"),
                    "--region",
                    "ntsc",
                ]
            )
            frames(30)
        else:
            replacement = (
                [0x4E, 0x75] if big else [0xC9] if name == "spectrum" else [0x60]
            )
            for offset, byte in enumerate(replacement):
                machine.call(
                    "poke_byte", addr=base + sym["test_collection"] + offset, value=byte
                )
        walk_to_item()
        try:
            collected(state())
        except AssertionError:
            rejected = True
        else:
            rejected = False
        T.require(rejected, "Broken collection passed the same guard")
        # Include direct source dependencies recursively, preserving shared ownership.
        import re

        dependencies = set()

        def include(path: Path) -> None:
            path = path.resolve()
            if path in dependencies:
                return
            dependencies.add(path)
            for child in re.findall(
                r'(?:include|!source)\s+"([^"]+)"', path.read_text(), re.IGNORECASE
            ):
                include(path.parent / child)

        include(folder / "demo.asm")
        dependencies.add(folder / "Makefile")
        if name in ("bbc", "electron"):
            dependencies.add(folder / "loader.py")
        result = {
            "status": "passed",
            "system": name,
            "startup": startup,
            "server": machine.server.get("serverInfo"),
            "emulator_sha256": T.sha(executable),
            "firmware_sha256": {p.name: T.sha(p) for p in firmware},
            "binary_sha256": T.sha(binary),
            "observer_sha256": T.sha(Path(__file__)),
            "sources": {
                str(p.relative_to(ROOT)): T.sha(p) for p in sorted(dependencies)
            },
            "initial": initial,
            "collected": at_item,
            "bounds": bounds,
            "held_restart_allows_movement": True,
            "audio": sound,
            "sound_negative_rejected": True,
            "sound_negative_intervention": "Diagnostic RAM patch: trigger_sound first opcode to RTS; restored after the muted check",
            "negative_collection_rejected": rejected,
            "limits": "Emulator configuration evidence; audio amplitude establishes changing output, not pitch accuracy or hardware conformance. Cell overlap tests one shared occupied cell; not a pixel-mask test. Snapshot startup on Spectrum is distinct from tape loading.",
        }
        if name == "spectrum" and args.tape:
            args.spectrum = executable
            result["fresh_rom_tape"] = T.tape_start(args, folder, sym)
        target = folder / "verification/results.json"
        target.parent.mkdir(exist_ok=True)
        target.write_text(json.dumps(result, indent=2) + "\n")
        print(
            "PASS",
            name,
            json.dumps({"collected": at_item, "bounds": bounds, "audio": sound}),
            flush=True,
        )
        return result
    finally:
        machine.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument(
        "--firmware-root", type=Path, default=Path.home() / ".emu198x/roms"
    )
    parser.add_argument("--build198x", default="build198x")
    parser.add_argument("--only", choices=("bbc", "electron"))
    parser.add_argument(
        "--tape",
        action="store_true",
        help="Also execute Spectrum TAP from a fresh ROM boot",
    )
    args = parser.parse_args()
    for name in [args.only] if args.only else ("bbc", "electron"):
        verify(name, args)


if __name__ == "__main__":
    main()
