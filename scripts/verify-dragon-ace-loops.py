"""Verify current-release stock-language probes and firmware-hosted assembly."""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, file: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


T = module("transport", "verify-game-loops.py")
B = module("builder", "build-dragon-ace-loops.py")
PCM = module("pcm", "verify-collect-and-respond.py")


def release(args, name: str) -> dict:
    lock = json.loads(
        (args.native / f"{name}-aarch64-apple-darwin-source-lock.json").read_text()
    )
    T.require(
        T.sha(args.native / name) == lock["executable_sha256"],
        "Executable differs from producer lock",
    )
    T.require(
        lock["before_lock_sha256"]
        == lock["after_lock_sha256"]
        == lock["committed_lock_sha256"],
        "Producer Cargo.lock changed",
    )
    T.require(lock["version"] == "0.44.1", "Expected reviewed Emu198x release 0.44.1")
    return lock


def refresh(args) -> None:
    for system, track, suffix, native in [
        ("dragon-32", "basic", "bas", "dragon"),
        ("jupiter-ace", "forth", "fth", "jupiter-ace"),
    ]:
        lock = release(args, "emu198x-" + native)
        for category, script in [
            (
                "framework/command-loop",
                "verify-command-loops.py"
                if track == "basic"
                else "verify-ace-command-loop.py",
            ),
            (
                "capabilities/input-drawing-sound",
                "verify-basic-capabilities.py"
                if track == "basic"
                else "verify-ace-capabilities.py",
            ),
        ]:
            verifier = module("legacy", script)
            if track == "basic":
                result = (
                    verifier.run
                    if category.startswith("framework")
                    else verifier.verify
                )(system, args.native, args.firmware_root)
            else:
                result = verifier.run(
                    args.native, args.firmware_root / "jupiter-ace/ace.rom"
                )
            folder = ROOT / system / "patterns" / track / category
            output = folder / "build/verification"
            retained = folder / "verification"
            retained.mkdir(exist_ok=True)
            result.update(
                emulator_source_commit=lock["source_commit"],
                emulator_release="v0.44.1",
                producer_source_lock=lock,
                track=track,
            )
            result["refresh_observer_sources"] = {
                str(p.relative_to(ROOT)): T.sha(p)
                for p in [
                    Path(__file__),
                    ROOT / "scripts" / script,
                    ROOT / "scripts/verify-game-loops.py",
                ]
            }
            rom = args.firmware_root / (
                "dragon/dragon32.rom" if track == "basic" else "jupiter-ace/ace.rom"
            )
            result["firmware_sha256"] = {rom.name: T.sha(rom)}
            evidence = retained / "current-release"
            evidence.mkdir(exist_ok=True)
            result["captures"] = {}
            for image in output.glob("*.png"):
                if image.name == "failure.png":
                    continue
                dest = evidence / image.name
                shutil.copyfile(image, dest)
                result["captures"][str(dest.relative_to(ROOT))] = T.sha(dest)
            if (output / "sound.wav").exists():
                import wave

                with wave.open(str(output / "sound.wav")) as w:
                    params = w.getparams()
                    pcm = w.readframes(w.getnframes())
                # Keep a small inspectable excerpt; full capture hash binds the run.
                dest = evidence / "sound.wav"
                with wave.open(str(dest), "wb") as w:
                    w.setparams(params)
                    w.writeframes(pcm[: 48000 * params.nchannels * params.sampwidth])
                result["audio_capture"] = {
                    "path": str(dest.relative_to(ROOT)),
                    "sha256": T.sha(dest),
                    "full_sha256": T.sha(output / "sound.wav"),
                }
            (retained / "results.json").write_text(json.dumps(result, indent=2) + "\n")
            print("REFRESH PASS", system, category, flush=True)


def assembly(args, system: str) -> None:
    dragon = system == "dragon-32"
    name = "dragon" if dragon else system
    lock = release(args, "emu198x-" + name)
    alock = json.loads(
        (args.native / "asm198x-aarch64-apple-darwin-source-lock.json").read_text()
    )
    T.require(
        T.sha(args.assembler) == alock["executable_sha256"],
        "Assembler differs from producer lock",
    )
    T.require(
        alock["before_lock_sha256"]
        == alock["after_lock_sha256"]
        == alock["committed_lock_sha256"],
        "Assembler producer lock changed",
    )
    rom = args.firmware_root / name / ("dragon32.rom" if dragon else "ace.rom")
    command = [str(args.native / ("emu198x-" + name)), "--mcp", "--rom", str(rom)]
    folder = ROOT / system / "patterns/assembly/framework/command-loop"
    retained = folder / "verification"
    retained.mkdir(exist_ok=True)
    screen = 0x400 if dragon else 0x2400
    base = 0x7000 if dragon else 0x3D00
    cases = {}
    for variant in B.VARIANTS:
        out, data, lines = B.build(system, args.assembler, variant)
        m = T.Machine(command)
        observations = []

        def ram(addr: int, size: int, m=m) -> list[int]:
            return m.call("memory_read", addr=addr, len=size)["bytes"]

        def type_text(text: str, m=m) -> None:
            r = m.call("type_string", text=text, settle_frames=20)
            T.require(r["chars_typed"] == len(text), "Incomplete source/input")

        def capture(
            stage: str, m=m, variant=variant, observations=observations, ram=ram
        ) -> int:
            raw = ram(screen, 160)
            codes = [x & 63 if dragon else x & 127 for x in raw]
            text = "".join(chr(x + 64) if dragon and x < 32 else chr(x) for x in codes)
            match = re.match(r"TURN \$([0-9A-F]{2})", text)
            T.require(match is not None, f"No rendered count: {text}")
            count = int(match[1], 16)
            dest = retained / variant
            dest.mkdir(exist_ok=True)
            image = dest / (stage + ".png")
            m.call("save_screenshot", path=str(image))
            observations.append(
                {
                    "stage": stage,
                    "count": count,
                    "screen": raw,
                    "capture": str(image.relative_to(ROOT)),
                    "capture_sha256": T.sha(image),
                }
            )
            return count

        def key(pressed: bool, m=m) -> None:
            m.call("input", events=[{"Key": {"name": "1", "pressed": pressed}}])
            m.call("run_frames", frames=60)

        try:
            m.call("run_frames", frames=150)
            for line in lines:
                type_text(line + "\n")
            m.call("run_frames", frames=120)
            loaded = []
            for offset in range(0, len(data), 256):
                loaded += ram(base + offset, min(256, len(data) - offset))
            T.require(
                bytes(loaded) == data,
                f"Keyboard loader differs from assembled payload: {[(i, x, y) for i, (x, y) in enumerate(zip(loaded, data)) if x != y][:12]}",
            )
            type_text(("CLS:EXEC &H7000" if dragon else "CLS TURNS") + "\n")
            m.call("run_frames", frames=60)
            capture("initial")
            m.call("run_frames", frames=120)
            capture("idle")
            m.call("start_audio_recording", path=str(out / "sound.wav"))
            key(True)
            m.call("stop_audio_recording")
            capture("first")
            m.call("run_frames", frames=120)
            capture("held")
            key(False)
            type_text("0")
            m.call("run_frames", frames=30)
            capture("ignored")
            key(True)
            key(False)
            capture("second")
            # Quit returns through RTS (Dragon) or JP(IY) (Ace), then run real firmware arithmetic.
            type_text("Q")
            m.call("run_frames", frames=30)
            type_text(
                'PRINT "RETURNED";2+3\n'
                if dragon
                else ': CHECKBACK ." RETURNED " 2 3 + . ; CHECKBACK\n'
            )
            return_raw = []
            for offset in range(0, 512 if dragon else 768, 256):
                return_raw += ram(screen + offset, 256)
            codes = [v & 63 if dragon else v & 127 for v in return_raw]
            return_text = "".join(
                chr(v + 64) if dragon and v < 32 else chr(v) for v in codes
            )
            T.require(
                re.search(r"RETURNED\s*5", return_text, re.IGNORECASE) is not None,
                f"Did not return to interpreter arithmetic: {return_text}",
            )
            info = PCM.pcm_range(out / "sound.wav")
            cases[variant] = {
                "observations": observations,
                "audio": info,
                "audio_sha256": T.sha(out / "sound.wav"),
                "loaded_sha256": T.sha(out / "demo.bin"),
                "loaded_bytes": loaded,
                "returned_screen": return_raw,
                "returned_to_interpreter": True,
            }
            if variant in ("working", "no-sound"):
                shutil.copyfile(out / "sound.wav", retained / (variant + "-sound.wav"))
            initial = B.VARIANTS[variant].get("INITIAL", 0)
            step = B.VARIANTS[variant].get("STEP", 1)
            expected = [
                initial,
                initial,
                (initial + step) % 256,
                (initial + step) % 256,
                (initial + step) % 256,
                (initial + 2 * step) % 256,
            ]
            if variant == "wrong-reset":
                expected = [0] * 6
            T.require(
                [o["count"] for o in observations] == expected,
                f"{variant}: wrong state sequence",
            )
            box = [
                observations[0]["screen"][i] & (63 if dragon else 127)
                for i in [64, 65, 66, 96, 97, 98, 128, 129, 130]
            ]
            T.require(
                box
                == (
                    [24, 24, 24, 24, 32, 24, 24, 24, 24]
                    if dragon
                    else [88, 88, 88, 88, 32, 88, 88, 88, 88]
                )
                if variant != "no-drawing"
                else box
                != (
                    [24, 24, 24, 24, 32, 24, 24, 24, 24]
                    if dragon
                    else [88, 88, 88, 88, 32, 88, 88, 88, 88]
                ),
                "Drawing check failed",
            )
            print(
                "ASSEMBLY PASS",
                system,
                variant,
                [o["count"] for o in observations],
                info["channel_ranges"],
                flush=True,
            )
            server = m.server["serverInfo"]
        finally:
            m.close()
    T.require(
        cases["wrong-reset"]["observations"][2]["count"]
        != cases["working"]["observations"][2]["count"],
        "Wrong-reset passed normal guard",
    )
    good = cases["working"]["audio"]
    bad = cases["no-sound"]["audio"]
    T.require(
        max(good["channel_ranges"]) > 200
        and max(good["ac_power"]) > max(1000, 4 * max(bad["ac_power"])),
        "Omitted sound passed audio guard",
    )
    paths = [
        p
        for p in folder.rglob("*")
        if p.suffix in (".asm", ".inc") and "build" not in p.relative_to(folder).parts
    ]
    result = {
        "status": "passed",
        "machine": system,
        "track": "assembly",
        "server": server,
        "emulator_release": "v0.44.1",
        "producer_source_lock": lock,
        "assembler_source_lock": alock,
        "firmware_sha256": {rom.name: T.sha(rom)},
        "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in paths},
        "observer_sources": {
            str(p.relative_to(ROOT)): T.sha(p)
            for p in [
                Path(__file__),
                ROOT / "scripts/build-dragon-ace-loops.py",
                ROOT / "scripts/verify-game-loops.py",
                ROOT / "scripts/verify-collect-and-respond.py",
            ]
        },
        "cases": cases,
        "limits": "Stock Dragon 32 PAL / 3 KiB Ace firmware-hosted keyboard-loaded code; byte state and text cells, blocking pulses. No pitch accuracy, original hardware, frame pacing or whole-emulator claim.",
    }
    (retained / "results.json").write_text(json.dumps(result, indent=2) + "\n")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument("--firmware-root", type=Path, default=Path.home() / ".emu198x/roms")
    p.add_argument("--only", choices=["refresh", "dragon-32", "jupiter-ace"])
    args = p.parse_args()
    args.native = args.native.resolve()
    args.assembler = args.assembler.resolve()
    if args.only in (None, "refresh"):
        refresh(args)
    for system in ["dragon-32", "jupiter-ace"]:
        if args.only in (None, system):
            assembly(args, system)


if __name__ == "__main__":
    main()
