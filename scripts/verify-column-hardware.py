"""Qualify sampled input, drawn primitives and actual sound separately."""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, filename: str):
    spec = importlib.util.spec_from_file_location(
        name, Path(__file__).with_name(filename)
    )
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


H = module("hardware", "verify-hardware-input-loops.py")
A = module("composition", "verify-collect-and-respond.py")
T = H.T
CONFIGS = {
    s: dict(H.CONFIGS[s])
    for s in [
        "coleco-colecovision",
        "sord-m5",
        "memotech-mtx",
        "tatung-einstein",
        "atari-2600",
        "atari-5200",
        "atari-7800",
        "nintendo-game-boy",
    ]
}
for system, ext in [
    ("sega-sg-1000", "sg"),
    ("sega-master-system", "sms"),
    ("sega-game-gear", "gg"),
]:
    CONFIGS[system] = {
        "binary": "emu198x-" + system,
        "extension": ext,
        "flag": "--cart",
        "ram": 0xC000,
        "button": "button1",
        "dialect": "pasmo",
        "finalise": [],
        "model": "NTSC stock cartridge configuration",
    }


def verify(system: str, native: Path, firmware_root: Path) -> dict:
    cfg = CONFIGS[system]
    folder = ROOT / system / "patterns/assembly/input/read-action"
    subprocess.run(["make"], cwd=folder, check=True, capture_output=True, timeout=60)
    cart = folder / ("build/demo." + cfg["extension"])
    out = folder / "build/verification"
    out.mkdir(exist_ok=True)
    executable = native / cfg["binary"]
    command = [str(executable), "--mcp"]
    if cfg["flag"]:
        command += [cfg["flag"], str(cart)]
    firmware = firmware_root / cfg["firmware"] if cfg.get("firmware") else None
    if firmware:
        command += [cfg.get("firmware_flag", "--bios"), str(firmware)]

    def capture(machine, label: str):
        path = out / (label + ".png")
        machine.call("save_screenshot", path=str(path))
        return T.raster(path)

    def start(path: Path):
        cmd = command.copy()
        if cfg["flag"]:
            cmd[cmd.index(cfg["flag"]) + 1] = str(path)
        machine = T.Machine(cmd)
        try:
            machine.call("run_frames", frames=cfg.get("boot", 60))
            if system == "memotech-mtx":
                for line in H.PACK.basic_loader(path.read_bytes()).splitlines():
                    reply = machine.call(
                        "type_string", text=line + "\n", settle_frames=60
                    )
                    T.require(
                        reply["chars_typed"] == len(line) + 1,
                        "Incomplete MTX source entry",
                    )
                machine.call("type_string", text="RUN\n", settle_frames=120)
                expected = list(path.read_bytes())
                for _ in range(30):
                    actual = []
                    for offset in range(0, len(expected), 256):
                        actual += machine.call(
                            "memory_read",
                            addr=0xE000 + offset,
                            len=min(256, len(expected) - offset),
                        )["bytes"]
                    if actual == expected:
                        break
                    machine.call("run_frames", frames=20)
                if actual != expected:
                    machine.call(
                        "save_screenshot", path=str(out / "loader-failure.png")
                    )
                T.require(
                    actual == expected,
                    f"Stock MTX loader did not load caller: {[(i, a, b) for i, (a, b) in enumerate(zip(actual, expected, strict=True)) if a != b][:12]}",
                )
            elif system == "tatung-einstein":
                machine.call("load_media", slot="floppy-0", kind="disk", path=str(path))
                for key, down, frames in [
                    ("control", True, 3),
                    ("break", True, 6),
                    ("break", False, 30),
                    ("control", False, 300),
                ]:
                    machine.call(
                        "input", events=[{"Key": {"name": key, "pressed": down}}]
                    )
                    machine.call("run_frames", frames=frames)
                loaded = bytes(
                    machine.call("memory_read", addr=0x9000, len=256)["bytes"]
                    + machine.call("memory_read", addr=0x9100, len=256)["bytes"]
                )
                T.require(
                    loaded == path.read_bytes()[0x200:0x400],
                    "MOS did not load original sector",
                )
            machine.call("run_frames", frames=30)
            return machine
        except BaseException:
            machine.close()
            raise

    observations = []

    def state(machine) -> int:
        raw = machine.call("memory_read", addr=cfg["ram"], len=1)["bytes"]
        observations.append({"address": cfg["ram"], "bytes": raw, "count": raw[0]})
        return raw[0]

    def action(machine, down: bool) -> None:
        event = (
            {"Key": {"name": cfg["button"], "pressed": down}}
            if cfg.get("key")
            else {"Button": {"port": 1, "name": cfg["button"], "pressed": down}}
        )
        machine.call("input", events=[event])
        machine.call("run_frames", frames=2)

    def drawing_guard(even, odd) -> None:
        T.require(
            even[0] == odd[0] and even[1] != odd[1],
            "Drawing did not change the picture",
        )

    def sound_guard(info: dict) -> None:
        T.require(max(info["channel_ranges"]) > 200, f"No changing PCM output: {info}")

    machine = start(cart)
    try:
        T.require(state(machine) == 0, "Caller did not initialise")
        machine.call("run_frames", frames=60)
        T.require(state(machine) == 0, "Input advanced while idle")
        even = capture(machine, "ready")
        machine.call("start_audio_recording", path=str(out / "sound.wav"))
        action(machine, True)
        T.require(state(machine) == 1, "Input press not sampled once")
        machine.call("run_frames", frames=30)
        machine.call("stop_audio_recording")
        T.require(state(machine) == 1, "Held input repeated")
        sound = A.pcm_range(out / "sound.wav")
        sound_guard(sound)
        odd = capture(machine, "pressed")
        drawing_guard(even, odd)
        action(machine, False)
        action(machine, True)
        T.require(state(machine) == 2, "Release/new press did not advance once")
        action(machine, False)
        restored = capture(machine, "second-press")
        T.require(even == restored, "Glyph did not return to original position")
        server = machine.server.get("serverInfo")
        machine.close()
        negatives = {}
        for capability, call in [
            ("drawing", "draw_picture"),
            ("sound", "trigger_sound"),
        ]:
            source = (folder / "demo.asm").read_text()
            old = ("    jsr " if cfg["dialect"] == "acme" else "    call ") + call
            T.require(source.count(old) == 1, "Ambiguous negative call")
            mutated = folder / "negative.asm"
            binary = out / (
                capability
                + (".bin" if system == "tatung-einstein" else "." + cfg["extension"])
            )
            intervention = "omit " + call
            negative_picture = folder / "negative-picture.inc"
            if system == "atari-2600" and capability == "drawing":
                # Removing this call shortens the software field, producing
                # an alpha-row change unrelated to the playfield write.
                picture = (folder / "picture.inc").read_text()
                T.require(picture.count("sta $0e") == 1, "Expected one PF1 write")
                negative_picture.write_text(picture.replace("sta $0e", "sta $86"))
                mutated.write_text(
                    source.replace('"picture.inc"', '"negative-picture.inc"')
                )
                intervention = (
                    "redirect PF1 write to unused RIOT RAM, preserving instruction cost"
                )
            else:
                mutated.write_text(source.replace(old, "    nop\n    nop\n    nop"))
            try:
                subprocess.run(
                    [
                        "asm198x",
                        "--dialect",
                        cfg["dialect"],
                        *cfg["finalise"],
                        str(mutated),
                        "-o",
                        str(binary),
                    ],
                    cwd=folder,
                    check=True,
                    capture_output=True,
                    timeout=30,
                )
            finally:
                mutated.unlink()
                if negative_picture.exists():
                    negative_picture.unlink()
            if system.startswith("sega"):
                subprocess.run(
                    ["python3", str(ROOT / "scripts/build-sega-probe.py"), str(binary)],
                    check=True,
                    capture_output=True,
                )
            if system == "tatung-einstein":
                packaged = binary.with_suffix(".dsk")
                packaged.write_bytes(H.PACK.einstein_disk(binary.read_bytes()))
                binary = packaged
            machine = start(binary)
            before = capture(machine, capability + "-negative-before")
            machine.call(
                "start_audio_recording", path=str(out / (capability + "-negative.wav"))
            )
            action(machine, True)
            machine.call("run_frames", frames=30)
            machine.call("stop_audio_recording")
            T.require(state(machine) == 1, "Negative failed before capability guard")
            after = capture(machine, capability + "-negative-after")
            try:
                if capability == "drawing":
                    drawing_guard(before, after)
                else:
                    sound_guard(A.pcm_range(out / (capability + "-negative.wav")))
            except AssertionError:
                rejected = True
            else:
                rejected = False
            T.require(rejected, f"Omitted {capability} passed the same guard")
            negatives[capability] = {
                "intervention": intervention,
                "same_guard_rejected": rejected,
            }
            machine.close()
        result = {
            "status": "passed",
            "machine_id": system,
            "configuration": cfg["model"],
            "server": server,
            "sources": {
                str(p.relative_to(ROOT)): T.sha(p)
                for p in [
                    folder / "demo.asm",
                    folder / "sample.inc",
                    folder / "picture.inc",
                    folder / "sound.inc",
                    folder / "Makefile",
                ]
            },
            "observer_sha256": T.sha(Path(__file__)),
            "emulator_sha256": T.sha(executable),
            "binary_sha256": T.sha(cart),
            "firmware_sha256": T.sha(firmware) if firmware else None,
            "observations": observations,
            "input": "idle, press once, held without repeat, release and second press",
            "drawing": {
                "atari-2600": "TIA playfield bar changes position and restores; fixed backdrop",
                "atari-5200": "ANTIC mode8 bitmap block changes position and restores; fixed backdrop",
                "atari-7800": "MARIA direct object column changes position and restores; fixed backdrop",
                "nintendo-game-boy": "Background tile changes position and restores; fixed palette",
            }.get(system, "VRAM glyph changes position and restores; fixed backdrop"),
            "sound": sound,
            "negative_controls": negatives,
            "limits": "Configuration-specific native emulator evidence. No original-hardware or pitch-accuracy claim. Startup uses stock firmware/cartridge entry; MTX DATA/POKE/USR and Einstein MOS disk boot remain distinct from cassette/CPM loading.",
        }
        record = folder / "verification/results.json"
        record.parent.mkdir(exist_ok=True)
        record.write_text(json.dumps(result, indent=2) + "\n")
        print("PASS", system, sound, flush=True)
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
    parser.add_argument("--only", choices=CONFIGS)
    args = parser.parse_args()
    for system in [args.only] if args.only else CONFIGS:
        verify(system, args.native, args.firmware_root)


if __name__ == "__main__":
    main()
