"""Qualify KERNAL-facing timed turns on C64 and stock VIC-20.

Guest programs create all state. Load through the native PRG importer and SYS.
No debugger writes. Arithmetic fixtures use explicit guest-owned clock values.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
_spec = importlib.util.spec_from_file_location(
    "mos", ROOT / "scripts/verify-mos-deadlines.py"
)
if _spec is None or _spec.loader is None:
    raise RuntimeError("Missing maintained MOS observer")
M = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(M)
T = M.T
SYSTEMS = ("commodore-64", "commodore-vic-20")
VARIANTS = (
    "working",
    "custom-duration",
    "wrong-input-gate",
    "repaired",
    "boundaries",
    "wrong-boundary",
    "wrong-midnight",
)
CLOCK_CASES = (
    (0, 1),
    (65535, 65536),
    (65530, 65545),
    (5183999, 0),
    (5183990, 12),
    (0x123456, 0x123499),
)


def source_paths(system: str) -> list[Path]:
    shared = ROOT / "commodore-64/patterns/assembly/framework/turn-deadline"
    own = ROOT / system / "patterns/assembly/framework/turn-deadline"
    return sorted(
        {
            *(
                shared / n
                for n in (
                    "demo.asm",
                    "settings.inc",
                    "clock.inc",
                    "input.inc",
                    "Makefile",
                )
            ),
            *(own / n for n in ("demo.asm", "settings.inc", "Makefile")),
            ROOT / "bbc-micro/patterns/assembly/framework/turn-deadline/dispatch.inc",
            ROOT
            / "bbc-micro/patterns/assembly/framework/turn-deadline/mistakes/input-gated-expiry.inc",
            ROOT / "cross-platform/patterns/framework/elapsed-deadline/6502.inc",
            Path(__file__),
            ROOT / "scripts/verify-mos-deadlines.py",
            ROOT / "scripts/verify-firmware-deadlines.py",
            ROOT / "scripts/verify-game-loops.py",
        }
    )


def expected_fixture() -> list[int]:
    result = M.V.expected_arithmetic()[:-1]
    for previous, now in CLOCK_CASES:
        result += list(
            ((previous + (now - previous) % 5184000) % 65536).to_bytes(2, "little")
        )
    return result + [1, 1, 1, 1, 1, 1, 0, 0, 0, 239]


def build(system: str, variant: str, assembler: Path) -> tuple[Path, dict[str, Any]]:
    folder = ROOT / system / "patterns/assembly/framework/turn-deadline"
    p = folder / "build" / variant
    p.mkdir(parents=True, exist_ok=True)
    settings = (folder / "settings.inc").read_text()
    if variant == "custom-duration":
        settings = settings.replace("DURATION = 240", "DURATION = 120")
    shared = ROOT / "commodore-64/patterns/assembly/framework/turn-deadline"
    helper = (
        ROOT / "cross-platform/patterns/framework/elapsed-deadline/6502.inc"
    ).read_text()
    clock = (shared / "clock.inc").read_text()
    if variant == "wrong-boundary":
        changed = helper.replace("    bne deadline_done\n", "    beq deadline_done\n")
        T.require(changed != helper, "Missing equality mutation")
        helper = changed
    if variant == "wrong-midnight":
        changed = clock.replace("    adc #$1a", "    adc #0")
        T.require(changed != clock, "Missing midnight mutation")
        clock = changed
    code = (folder / "demo.asm").read_text()
    if variant in ("boundaries", "wrong-boundary", "wrong-midnight"):
        code = code[: code.index("start:")] + "start:\n    cld\n    cli\n"
        for i, (duration, previous, now) in enumerate(M.V.CASES):
            code += f"    lda #<{duration}\n    sta DEADLINE\n    lda #>{duration}\n    sta DEADLINE+1\n    lda #<{previous}\n    ldx #>{previous}\n    jsr deadline_init\n    jsr deadline_start\n    lda #165\n    sta DEADLINE+12\n    lda #90\n    sta DEADLINE+13\n    lda #<{now}\n    ldx #>{now}\n    jsr deadline_poll\n"
            for j, offset in enumerate([2, 3, 4, 5, 6, 7, 8, 9, 12, 13]):
                code += (
                    f"    lda DEADLINE+{offset}\n    sta ${0x1B00 + i * 10 + j:04x}\n"
                )
        for i, (previous, now) in enumerate(CLOCK_CASES):
            code += f"    lda #0\n    ldx #7\nclear_adapter_{i}:\n    sta CLOCK,x\n    dex\n    bpl clear_adapter_{i}\n"
            for value in (previous, now):
                code += f"    lda #{value & 255}\n    ldx #{(value >> 8) & 255}\n    ldy #{value >> 16}\n    jsr normalise_clock\n"
            code += f"    sta ${0x1B78 + 2 * i:04x}\n    stx ${0x1B79 + 2 * i:04x}\n"
        for i, (keys, expired) in enumerate(((1, 1), (2, 1), (3, 0))):
            code += f"    lda #0\n    ldx #9\nclear_dispatch_{i}:\n    sta STATE,x\n    dex\n    bpl clear_dispatch_{i}\n    lda #10\n    sta DEADLINE\n    lda #0\n    sta DEADLINE+1\n    tax\n    jsr deadline_init\n    jsr deadline_start\n    lda #{keys}\n    sta STATE+8\n    lda #{expired}\n    sta DEADLINE+5\n    jsr dispatch\n    lda STATE+4\n    sta ${0x1B84 + 3 * i:04x}\n    lda STATE+6\n    sta ${0x1B85 + 3 * i:04x}\n    lda DEADLINE+4\n    sta ${0x1B86 + 3 * i:04x}\n"
        dispatch = (
            ROOT / "bbc-micro/patterns/assembly/framework/turn-deadline/dispatch.inc"
        ).read_text()
        commit = (
            (folder / "demo.asm")
            .read_text()
            .split("commit_turn:\n")[1]
            .split('!source "clock.inc"')[0]
            .split('!source "../../../../../commodore-64')[0]
        )
        code += (
            "    lda #239\n    sta $1b8d\nstop: jmp stop\ncommit_turn:\n"
            + commit
            + dispatch
            + helper
            + clock
        )
    else:
        for name, text in (
            ("clock.inc", clock),
            ("input.inc", (shared / "input.inc").read_text()),
        ):
            code = code.replace(f'!source "{name}"', text).replace(
                f'!source "../../../../../commodore-64/patterns/assembly/framework/turn-deadline/{name}"',
                text,
            )
        dispatch = (
            ROOT
            / "bbc-micro/patterns/assembly/framework/turn-deadline"
            / (
                "mistakes/input-gated-expiry.inc"
                if variant == "wrong-input-gate"
                else "dispatch.inc"
            )
        )
        code = code.replace(
            '!source "../../../../../bbc-micro/patterns/assembly/framework/turn-deadline/dispatch.inc"',
            dispatch.read_text(),
        )
        code = code.replace(
            '!source "../../../../../cross-platform/patterns/framework/elapsed-deadline/6502.inc"',
            helper,
        )
    code = code.replace('!source "settings.inc"', settings)
    (p / "selected.asm").write_text(code)
    subprocess.run(
        [
            str(assembler),
            "--dialect",
            "acme",
            "--prg",
            str(p / "selected.asm"),
            "--sym=" + str(p / "demo.sym"),
            "-o",
            str(p / "demo.prg"),
        ],
        check=True,
        capture_output=True,
        timeout=30,
    )
    sym = T.symbols(p / "demo.sym")
    return p, {
        "prg_sha256": T.sha(p / "demo.prg"),
        "prg_bytes": (p / "demo.prg").stat().st_size,
        "helper_bytes": sym["deadline_done"] + 1 - sym["deadline_init"],
        "adapter_bytes": sym["clock_end"] - sym["sample_clock"],
    }


def execute(system: str, variant: str, args: argparse.Namespace) -> dict[str, Any]:
    p, metrics = build(system, variant, args.assembler)
    name = "c64" if system == "commodore-64" else system
    exe = args.tools / f"emu198x-{name}-aarch64-apple-darwin" / f"emu198x-{name}"
    rom = args.c64_rom if system == "commodore-64" else args.vic_rom
    command = [str(exe), "--mcp", "--rom-dir", str(rom)] + (
        ["--model", "pal"]
        if system == "commodore-64"
        else ["--region", "pal", "--ram-expansion", "none"]
    )
    out = ROOT / system / "patterns/assembly/framework/turn-deadline/verification"
    out.mkdir(parents=True, exist_ok=True)
    if system == "commodore-64":
        snapshot = p / "import.vsf"
        script = p / "import.json"
        script.write_text(
            json.dumps([{"action": "save_snapshot", "path": str(snapshot)}])
        )
        subprocess.run(
            [
                str(exe),
                "--model",
                "pal",
                "--rom-dir",
                str(rom),
                "--load",
                str(p / "demo.prg"),
                "--script",
                str(script),
            ],
            check=True,
            capture_output=True,
            timeout=60,
        )
    machine = T.Machine(command)
    dbase = 0xC000 if system == "commodore-64" else 0x1C00
    total = 0
    try:

        def frames(n: int) -> None:
            nonlocal total
            while n:
                part = min(250, n)
                machine.call("run_frames", frames=part)
                total += part
                n -= part

        frames(150)
        if system == "commodore-64":
            machine.call("load_snapshot", path=str(snapshot))
            typed = machine.call(
                "type_string", text="RUN\n", hold_frames=3, settle_frames=8
            )
            T.require(typed["chars_typed"] == 4, "Incomplete RUN")
        else:
            machine.call(
                "load_media", slot="program-1", kind="program", path=str(p / "demo.prg")
            )
        frames(150)
        image = out / f"{variant}.png"
        machine.call("save_screenshot", path=str(image))
        expected = (p / "demo.prg").read_bytes()
        address = int.from_bytes(expected[:2], "little")
        actual = []
        for off in range(0, len(expected) - 2, 256):
            size = min(256, len(expected) - 2 - off)
            actual += machine.call("memory_read", addr=address + off, len=size)["bytes"]
        T.require(
            bytes(actual) == expected[2:],
            f"Loaded executable differs: {[(hex(address + i), a, b) for i, (a, b) in enumerate(zip(actual, expected[2:])) if a != b][:16]}",
        )
        if variant in ("boundaries", "wrong-boundary", "wrong-midnight"):
            data = machine.call("memory_read", addr=0x1B00, len=142)["bytes"]
            T.require(len(data) == 142 and data[-1] == 239, "Fixture incomplete")
            equal = data == expected_fixture()
            T.require(
                equal == (variant == "boundaries"), f"Arithmetic control wrong: {data}"
            )
            result = {"fixture": data, "oracle_matches": equal}
        else:
            observations = []

            def observe(stage: str) -> dict[str, Any]:
                d = machine.call("memory_read", addr=dbase, len=14)["bytes"]
                s = machine.call("memory_read", addr=dbase + 32, len=10)["bytes"]
                T.require(
                    len(d) == 14 and len(s) == 10 and d[12:] == [165, 90],
                    "Guard damaged",
                )
                state = {
                    "stage": stage,
                    "frames": total,
                    "duration": d[0] + 256 * d[1],
                    "remaining": d[2] + 256 * d[3],
                    "active": d[4],
                    "expired": d[5],
                    "clock": d[8] + 256 * d[9],
                    "elapsed": d[6] + 256 * d[7],
                    "turns": s[4] + 256 * s[5],
                    "expiries": s[6],
                    "guards": d[12:],
                }
                observations.append(state)
                return state

            def tap(key: str) -> None:
                for down in (True, False):
                    machine.call(
                        "input", events=[{"Key": {"name": key, "pressed": down}}]
                    )
                    frames(4)

            idle = observe("idle")
            frames(30)
            after = observe("idle-after")
            ticks = (after["clock"] - idle["clock"]) % 65536
            T.require(
                idle["turns"] == after["turns"] == 0
                and after["active"] == 0
                and 28 <= ticks <= 38,
                f"Untimed or clock wrong: {after}, ticks {ticks}",
            )
            tap("space")
            action = observe("untimed-action")
            T.require(
                action["turns"] == 1 and action["active"] == 0, "Untimed action wrong"
            )
            tap("t")
            start = observe("enabled")
            frames(20)
            progress = observe("progress")
            T.require(
                start["active"] == progress["active"] == 1
                and progress["turns"] == 1
                and start["remaining"] - progress["remaining"]
                == (progress["clock"] - start["clock"]) % 65536,
                "Countdown mismatch",
            )
            frames(240 if variant != "custom-duration" else 120)
            expiry = observe("expiry")
            wrong = variant == "wrong-input-gate"
            T.require(
                (expiry["turns"], expiry["expiries"], expiry["active"])
                == ((1, 0, 0) if wrong else (2, 1, 1)),
                f"Idle expiry wrong: {expiry}",
            )
            machine.call("save_screenshot", path=str(image))
            if not wrong:
                tap("space")
                restart = observe("restart")
                T.require(
                    restart["turns"] == 3
                    and restart["remaining"] > restart["duration"] // 2,
                    "Action did not restart",
                )
                tap("t")
                stopped = observe("disabled")
                frames(300)
                stopped_after = observe("disabled-after")
                T.require(
                    stopped["active"] == stopped_after["active"] == 0
                    and stopped["turns"] == stopped_after["turns"],
                    "Disabled timer advanced",
                )
            result = {"observations": observations, "ticks_in_30_fields": ticks}
        return {
            **metrics,
            **result,
            "image": image.name,
            "image_sha256": T.sha(image),
            "server": machine.server["serverInfo"],
            "emulator_sha256": T.sha(exe),
            "firmware_sha256": {f.name: T.sha(f) for f in rom.glob("*.rom")},
            "load_route": "Boot/import snapshot, typed RUN/SYS"
            if system == "commodore-64"
            else "PRG importer, stock BASIC RUN/SYS",
            "region": "PAL",
            "ram": "64 KiB" if system == "commodore-64" else "5 KiB, unexpanded",
        }
    finally:
        machine.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--tools", type=Path, required=True)
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument("--c64-rom", type=Path, required=True)
    p.add_argument("--vic-rom", type=Path, required=True)
    p.add_argument("--systems", default=",".join(SYSTEMS))
    p.add_argument("--variants", default=",".join(VARIANTS))
    args = p.parse_args()
    for system in args.systems.split(","):
        T.require(system in SYSTEMS, "Unknown system")
        out = (
            ROOT
            / system
            / "patterns/assembly/framework/turn-deadline/verification/results.json"
        )
        results = (
            json.loads(out.read_text())
            if out.exists()
            else {
                "machine": system,
                "language": "assembly",
                "status": "native-checked",
                "cases": {},
            }
        )
        for variant in args.variants.split(","):
            T.require(variant in VARIANTS, "Unknown variant")
            results["cases"][variant] = execute(system, variant, args)
            results["sources"] = {
                str(f.relative_to(ROOT)): T.sha(f) for f in source_paths(system)
            }
            results["assembler_sha256"] = T.sha(args.assembler)
            results["assembler_release"] = "0.0.72"
            results["emulator_release"] = "0.44.2"
            out.write_text(json.dumps(results, indent=2) + "\n")
            print(system, variant, "passed", flush=True)


if __name__ == "__main__":
    main()
