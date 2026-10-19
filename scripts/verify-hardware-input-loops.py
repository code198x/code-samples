"""Separate turn state from display servicing on original hardware callers."""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "turn_transport", Path(__file__).with_name("verify-sega-turns.py")
)
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
OBSERVER = T.sha(Path(__file__))
PACK_SPEC = importlib.util.spec_from_file_location(
    "stock_pack", Path(__file__).with_name("build-stock-probe.py")
)
PACK = importlib.util.module_from_spec(PACK_SPEC)
PACK_SPEC.loader.exec_module(PACK)
CONFIGS = {
    "nintendo-game-boy": {
        "binary": "emu198x-game-boy",
        "extension": "gb",
        "flag": "--rom",
        "ram": 0xC000,
        "button": "a",
        "dialect": "rgbasm",
        "finalise": ["--gb-rom"],
        "model": "DMG default reset, no boot ROM",
    },
    "atari-2600": {
        "binary": "emu198x-atari-2600",
        "extension": "a26",
        "flag": "--cart",
        "ram": 0x80,
        "button": "fire",
        "dialect": "acme",
        "finalise": [],
        "model": "NTSC 4 KiB cartridge",
    },
    "atari-5200": {
        "binary": "emu198x-atari-5200",
        "extension": "bin",
        "flag": "--cart",
        "ram": 0x1000,
        "button": "fire",
        "dialect": "acme",
        "finalise": [],
        "model": "NTSC 32 KiB cartridge, pinned BIOS",
        "boot": 900,
        "firmware": "atari-5200/5200.rom",
    },
    "atari-7800": {
        "binary": "emu198x-atari-7800",
        "extension": "bin",
        "flag": "--cart",
        "ram": 0x1900,
        "button": "fire",
        "dialect": "acme",
        "finalise": [],
        "model": "NTSC 48 KiB cartridge reset without BIOS authentication",
    },
    "coleco-colecovision": {
        "binary": "emu198x-colecovision",
        "extension": "cv",
        "flag": "--cart",
        "ram": 0x6000,
        "button": "fire",
        "dialect": "pasmo",
        "finalise": [],
        "model": "NTSC ColecoVision, pinned BIOS, title-skipping cartridge",
        "boot": 300,
        "firmware": "coleco-colecovision/colecovision.rom",
    },
    "sord-m5": {
        "binary": "emu198x-sord-m5",
        "extension": "bin",
        "flag": "--cart",
        "ram": 0x7000,
        "button": "space",
        "key": True,
        "dialect": "pasmo",
        "finalise": [],
        "model": "Sord M5 NTSC, monitor-started cartridge",
        "boot": 300,
        "firmware": "sord-m5/sord-m5.rom",
        "firmware_flag": "--rom",
    },
    "memotech-mtx": {
        "binary": "emu198x-memotech-mtx",
        "extension": "bin",
        "flag": None,
        "ram": 0xDF00,
        "button": "space",
        "key": True,
        "dialect": "pasmo",
        "finalise": [],
        "model": "MTX500 PAL, stock OS/BASIC, typed DATA/POKE loader and USR($E000)",
        "startup_kind": "stock-basic-poke-usr",
        "boot": 300,
        "firmware": "memotech-mtx/mtx.rom",
        "firmware_flag": "--rom",
    },
    "tatung-einstein": {
        "binary": "emu198x-tatung-einstein",
        "extension": "dsk",
        "flag": None,
        "ram": 0x8000,
        "button": "space",
        "key": True,
        "dialect": "pasmo",
        "finalise": [],
        "model": "Einstein TC-01 PAL, stock MOS 1.2, Ctrl-BREAK disk boot",
        "startup_kind": "stock-mos-disk-boot",
        "boot": 300,
        "firmware": "tatung-einstein/einstein.rom",
        "firmware_flag": "--rom",
        "emulator_source_commit": "57a7453eeb3452d9f2be7ba4a453c13baa521a58",
    },
}


def run(system: str, native: Path, firmware_root: Path) -> dict:
    cfg = CONFIGS[system]
    folder = (
        ROOT / system / "patterns/assembly/framework" / cfg.get("folder", "input-loop")
    )
    subprocess.run(["make"], cwd=folder, check=True, timeout=30)
    cart = folder / ("build/demo." + cfg["extension"])
    executable = native / cfg["binary"]
    output = folder / "build/verification"
    output.mkdir(exist_ok=True)
    source = (folder / "demo.asm").read_text()

    def command_for(path: Path) -> list[str]:
        command = [str(executable), "--mcp"]
        if cfg["flag"]:
            command += [cfg["flag"], str(path)]
        if cfg.get("firmware"):
            command += [
                cfg.get("firmware_flag", "--bios"),
                str(firmware_root / cfg["firmware"]),
            ]
        return command

    command = command_for(cart)
    machine = T.Machine(command)

    def boot(path: Path) -> None:
        frames(cfg.get("boot", 30))
        if system == "memotech-mtx":
            loader = PACK.basic_loader(path.read_bytes())
            for line in loader.splitlines():
                typed = machine.call("type_string", text=line + "\n", settle_frames=60)
                T.require(
                    typed["chars_typed"] == len(line) + 1,
                    "Incomplete BASIC loader entry",
                )
            machine.call("type_string", text="RUN\n", settle_frames=120)
            actual = machine.call("memory_read", addr=0xE000, len=path.stat().st_size)[
                "bytes"
            ]
            T.require(
                actual == list(path.read_bytes()),
                "BASIC did not load the complete caller",
            )
        elif system == "tatung-einstein":
            machine.call("load_media", slot="floppy-0", kind="disk", path=str(path))
            for key, pressed, count in [
                ("control", True, 3),
                ("break", True, 6),
                ("break", False, 30),
                ("control", False, 300),
            ]:
                machine.call(
                    "input", events=[{"Key": {"name": key, "pressed": pressed}}]
                )
                frames(count)
            # Sector 0 follows the two DSK headers. Match the CPU-visible load,
            # then use counters and input guards to prove it executed.
            expected = path.read_bytes()[0x200:0x400]
            actual = bytes(machine.call("memory_read", addr=0x9000, len=256)["bytes"])
            actual += bytes(machine.call("memory_read", addr=0x9100, len=256)["bytes"])
            T.require(actual == expected, "MOS did not load the complete boot sector")

    def state() -> list[int]:
        return machine.call("memory_read", addr=cfg["ram"], len=4)["bytes"]

    def ticks() -> int:
        b = state()
        return b[2] + 256 * b[3]

    def frames(n: int) -> None:
        machine.call("run_frames", frames=n)

    def action(pressed: bool) -> None:
        event = (
            {"Key": {"name": cfg["button"], "pressed": pressed}}
            if cfg.get("key")
            else {"Button": {"port": 1, "name": cfg["button"], "pressed": pressed}}
        )
        machine.call("input", events=[event])
        frames(8)

    def capture(name: str) -> tuple[bytes, bytes]:
        p = output / (name + ".png")
        machine.call("save_screenshot", path=str(p))
        return T.raster(p)

    try:
        boot(cart)
        T.require(state()[0] == 0, "Caller did not start at turn zero")
        before = ticks()
        frames(30)
        delta = (ticks() - before) & 65535
        T.transport.normal_rate(delta, 30)
        frames(120)
        T.require(state()[0] == 0, "Rule state changed without input")
        even = capture("waiting")
        action(True)
        T.require(state()[0] == 1, "Press did not commit one turn")
        frames(120)
        T.require(state()[0] == 1, "Held button repeated a turn")
        odd = capture("one-turn")
        action(False)
        action(True)
        T.require(state()[0] == 2, "Second press did not commit one turn")
        action(False)
        again = capture("two-turns")
        T.require(even[0] == odd[0] == again[0], "Capture geometry changed")
        T.require(
            even[1] != odd[1] and even[1] == again[1],
            "Visible turn feedback did not change and restore",
        )
        server = machine.server.get("serverInfo")
        machine.close()
        controls = {}
        if system == "nintendo-game-boy":
            mutations = [
                ("no-wait", "    call wait_frame", "    nop\n    nop\n    nop"),
                ("no-edge", "    cpl\n    and b", "    ld a,b\n    nop"),
            ]
        elif system == "atari-2600":
            mutations = [
                ("no-wait", "    sta $02", "    nop"),
                ("no-edge", "    and $84", "    lda $84"),
            ]
        elif cfg["dialect"] == "pasmo":
            mutations = [
                ("no-wait", "    call wait_frame", "    nop\n    nop\n    nop"),
                ("no-edge", "    cpl\n    and b", "    ld a,b\n    nop"),
            ]
        else:
            mutations = [
                ("no-wait", "    jsr wait_frame", "    nop\n    nop\n    nop"),
                ("no-edge", "    and current", "    lda current"),
            ]
        for kind, old, new in mutations:
            expected = 7 if system == "atari-2600" and kind == "no-wait" else 1
            # Each static WSYNC write is replaced, including those in loops.
            if system == "atari-2600" and kind == "no-wait":
                expected = source.count(old)
                T.require(expected > 0, "No scanline waits to mutate")
            T.require(source.count(old) == expected, f"Ambiguous {kind} mutation")
            mutant = folder / "negative-control.asm"
            negative_cart = output / (kind + "." + cfg["extension"])
            assembled = (
                output / (kind + ".bin")
                if system == "tatung-einstein"
                else negative_cart
            )
            mutant.write_text(source.replace(old, new))
            try:
                subprocess.run(
                    [
                        "asm198x",
                        "--dialect",
                        cfg["dialect"],
                        *cfg["finalise"],
                        str(mutant),
                        "-o",
                        str(assembled),
                    ],
                    cwd=folder,
                    check=True,
                    timeout=30,
                    capture_output=True,
                )
            finally:
                mutant.unlink()
            if system == "tatung-einstein":
                negative_cart.write_bytes(PACK.einstein_disk(assembled.read_bytes()))
            machine = T.Machine(command_for(negative_cart))
            boot(negative_cart)
            if kind == "no-wait":
                before = ticks()
                frames(10)
                observed = (ticks() - before) & 65535
                try:
                    T.transport.normal_rate(observed, 10)
                except AssertionError:
                    rejected = True
                else:
                    rejected = False
            else:
                action(True)
                first = state()[0]
                frames(30)
                observed = (state()[0] - first) & 255
                rejected = observed != 0
            T.require(rejected, f"{kind} passed the corresponding positive guard")
            controls[kind] = {
                "rejected": True,
                "observed_delta": observed,
                "binary_sha256": T.sha(negative_cart),
            }
            machine.close()
        result = {
            "status": "passed",
            "machine_id": system,
            "server": server,
            "configuration": cfg["model"],
            "startup_kind": cfg.get("startup_kind", "cartridge-reset"),
            "normal_ticks_in_30_frames": delta,
            "idle_frames": 120,
            "held_frames": 120,
            "accepted_press_states": [1, 2],
            "visible_feedback": {"changed": True, "restored": True},
            "negative_controls": controls,
            "firmware_sha256": {cfg["firmware"]: T.sha(firmware_root / cfg["firmware"])}
            if cfg.get("firmware")
            else {},
            "emulator_source_commit": cfg.get(
                "emulator_source_commit", "6cc5d5f9e7fe6507a079f237bc44da0dc95fe25c"
            ),
            "binary_sha256": T.sha(cart),
            "emulator_sha256": T.sha(executable),
            "sources": {
                str((folder / "demo.asm").relative_to(ROOT)): T.sha(
                    folder / "demo.asm"
                ),
                str((folder / "Makefile").relative_to(ROOT)): T.sha(
                    folder / "Makefile"
                ),
                str(Path(__file__).relative_to(ROOT)): OBSERVER,
                "scripts/verify-sega-turns.py": T.sha(
                    ROOT / "scripts/verify-sega-turns.py"
                ),
                "scripts/verify-game-loops.py": T.sha(
                    ROOT / "scripts/verify-game-loops.py"
                ),
            },
            "limits": "Named native configuration; untimed press-driven rules plus continuous display servicing. Not a deadline, hardware or whole-emulator qualification.",
        }
        if system in ("memotech-mtx", "tatung-einstein"):
            result["sources"]["scripts/build-stock-probe.py"] = T.sha(
                ROOT / "scripts/build-stock-probe.py"
            )
        (output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
        return result
    finally:
        if machine.process.poll() is None:
            machine.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument("--only", choices=CONFIGS)
    parser.add_argument(
        "--firmware-root", type=Path, default=Path.home() / ".emu198x/roms"
    )
    args = parser.parse_args()
    for system in [args.only] if args.only else CONFIGS:
        result = run(system, args.native.resolve(), args.firmware_root.resolve())
        print(system, result["status"], result["negative_controls"], flush=True)


if __name__ == "__main__":
    main()
