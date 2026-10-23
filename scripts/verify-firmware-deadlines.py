"""Execute typed Atom/CPC callers and original reset-ROM arithmetic fixtures.

Supply released tools and your own firmware. No licensed ROM is redistributed.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Missing native transport")
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
SYSTEMS = ("acorn-atom", "amstrad-cpc")
CASES = [
    (100, 65530, 5),
    (100, 10, 10),
    (100, 10, 109),
    (100, 10, 110),
    (100, 10, 111),
    (65535, 0, 65534),
    (65535, 0, 65535),
    (0, 7, 8),
    (1, 0, 0),
    (1, 0, 2),
    (256, 65500, 200),
    (300, 65500, 200),
]


def folder(system: str) -> Path:
    return ROOT / system / "patterns/assembly/framework/turn-deadline"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_paths(system: str) -> list[Path]:
    p = folder(system)
    cpu = "6502" if system == "acorn-atom" else "z80"
    return [
        p / n
        for n in (
            "demo.asm",
            "settings.inc",
            "dispatch.inc",
            "loader.py",
            "Makefile",
            "mistakes/input-gated-expiry.inc",
        )
    ] + [ROOT / f"cross-platform/patterns/framework/elapsed-deadline/{cpu}.inc"]


def expected_arithmetic() -> list[int]:
    expected: list[int] = []
    for duration, previous, now in CASES:
        elapsed = (now - previous) % 65536
        expired = int(duration != 0 and elapsed >= duration)
        remaining = max(0, duration - elapsed) if duration else 0
        active = int(duration != 0 and not expired)
        expected += [
            remaining & 255,
            remaining >> 8,
            active,
            expired,
            elapsed & 255,
            elapsed >> 8,
            now & 255,
            now >> 8,
            165,
            90,
        ]
    return expected + [239]


def arithmetic(system: str, args: argparse.Namespace) -> dict[str, Any]:
    """Independent native arithmetic observations, deliberately separate from stock boot."""
    atom = system == "acorn-atom"
    p = folder(system) / "build/arithmetic"
    p.mkdir(parents=True, exist_ok=True)
    cpu = "6502" if atom else "z80"
    helper = (
        ROOT / f"cross-platform/patterns/framework/elapsed-deadline/{cpu}.inc"
    ).read_text()
    prefix = (
        "DEADLINE = $2000\n* = $d000\n    sei\n    cld\n    ldx #$ff\n    txs\n"
        if atom
        else "DEADLINE equ $4000\norg 0\n    di\n    ld sp,$8fff\n"
    )
    result_base = 0x2100 if atom else 0x4100
    code = prefix
    for index, (duration, previous, now) in enumerate(CASES):
        offset = result_base + index * 10
        if atom:
            code += f"    lda #<{duration}\n    sta DEADLINE\n    lda #>{duration}\n    sta DEADLINE+1\n    lda #<{previous}\n    ldx #>{previous}\n    jsr deadline_init\n    jsr deadline_start\n    lda #165\n    sta DEADLINE+12\n    lda #90\n    sta DEADLINE+13\n    lda #<{now}\n    ldx #>{now}\n    jsr deadline_poll\n"
            for j, source in enumerate([2, 3, 4, 5, 6, 7, 8, 9, 12, 13]):
                code += f"    lda DEADLINE+{source}\n    sta ${offset + j:04x}\n"
        else:
            code += f"    ld hl,{duration}\n    ld (DEADLINE),hl\n    ld hl,{previous}\n    call deadline_init\n    call deadline_start\n    ld a,165\n    ld (DEADLINE+10),a\n    ld a,90\n    ld (DEADLINE+11),a\n    ld hl,{now}\n    call deadline_poll\n"
            for j, source in enumerate([2, 3, 4, 5, 6, 7, 8, 9, 10, 11]):
                code += f"    ld a,(DEADLINE+{source})\n    ld (${offset + j:04x}),a\n"
    end = result_base + len(CASES) * 10
    code += (
        f"    lda #239\n    sta ${end:04x}\nstop: jmp stop\n"
        if atom
        else f"    ld a,239\n    ld (${end:04x}),a\nstop: jr stop\n"
    )
    observations = {}
    for variant in ("working", "wrong-zero-boundary"):
        selected = helper
        if variant != "working":
            selected = (
                helper.replace("    bne deadline_done\n", "    beq deadline_done\n")
                if atom
                else helper.replace(
                    "    jr z,deadline_expired\n", "    jr nz,deadline_expired\n"
                )
            )
            T.require(selected != helper, "Fault did not change helper")
        source = p / (variant + ".asm")
        source.write_text(code + selected)
        raw = p / (variant + ".bin")
        subprocess.run(
            [
                str(args.assembler),
                "--dialect",
                "acme" if atom else "pasmo",
                str(source),
                "-o",
                str(raw),
            ],
            check=True,
            capture_output=True,
            timeout=30,
        )
        program = raw.read_bytes()
        if atom:
            T.require(len(program) < 0x2FFC, "Fixture reaches vectors")
            rom = bytearray(24576)
            rom[0x3000 : 0x3000 + len(program)] = program
            rom[0x5FFC:0x5FFE] = bytes([0, 208])
        else:
            T.require(len(program) < 16384, "Fixture exceeds lower ROM")
            rom = program.ljust(32768, b"\x00")
        image = p / (variant + ".rom")
        image.write_bytes(rom)
        command = [str(executable(system, args)), "--mcp", "--rom", str(image)]
        if atom:
            command += ["--model", "acorn-atom-full"]
        machine = T.Machine(command)
        try:
            machine.call("run_frames", frames=10)
            data = machine.call(
                "memory_read", addr=result_base, len=len(expected_arithmetic())
            )["bytes"]
            T.require(data[-1] == 239, "Arithmetic fixture did not complete")
            equal = data == expected_arithmetic()
            T.require(
                equal == (variant == "working"),
                f"Arithmetic oracle: {system}/{variant}: {data}",
            )
            observations[variant] = {
                "bytes": data,
                "fixture_sha256": sha(image),
                "oracle_matches": equal,
            }
        finally:
            machine.close()
    return {
        "startup": "Original synthetic reset ROM; CPU/RAM arithmetic only, no firmware or video claim",
        "cases": CASES,
        "observations": observations,
    }


def executable(system: str, args: argparse.Namespace) -> Path:
    return args.tools / f"emu198x-{system}-aarch64-apple-darwin" / f"emu198x-{system}"


def public_case(system: str, variant: str, args: argparse.Namespace) -> dict[str, Any]:
    atom = system == "acorn-atom"
    p = folder(system)
    out = p / "verification"
    out.mkdir(exist_ok=True)
    build = p / "build" / variant
    build.mkdir(parents=True, exist_ok=True)
    duration = (
        (50 if atom else 300)
        if variant == "custom-duration"
        else (100 if atom else 600)
    )
    settings = (
        (p / "settings.inc")
        .read_text()
        .replace(
            f"DURATION {'=' if atom else 'equ'} {100 if atom else 600}",
            f"DURATION {'=' if atom else 'equ'} {duration}",
        )
    )
    if variant == "clock-wrap" and atom:
        settings = settings.replace("INITIAL_CLOCK = 0", "INITIAL_CLOCK = 65520")
    (build / "settings.inc").write_text(settings)
    dispatch = p / (
        "mistakes/input-gated-expiry.inc"
        if variant == "wrong-input-gate"
        else "dispatch.inc"
    )
    code = (
        (p / "demo.asm")
        .read_text()
        .replace('"settings.inc"', '"' + str(build / "settings.inc") + '"')
        .replace('"dispatch.inc"', '"' + str(dispatch) + '"')
    )
    code = code.replace(
        '"../../../../../cross-platform/', '"' + str(ROOT / "cross-platform") + "/"
    )
    (build / "selected.asm").write_text(code)
    binary = build / "demo.bin"
    subprocess.run(
        [
            str(args.assembler),
            "--dialect",
            "acme" if atom else "pasmo",
            str(build / "selected.asm"),
            "-o",
            str(binary),
        ],
        check=True,
        capture_output=True,
        timeout=30,
    )
    # Reuse the exact maintained loader generator in an isolated directory.
    (build / "build").mkdir(exist_ok=True)
    (build / "build/demo.bin").write_bytes(binary.read_bytes())
    loader = build / "loader.py"
    loader.write_text((p / "loader.py").read_text())
    subprocess.run(["python3", str(loader)], check=True, timeout=20)
    listing = (build / "build/loader.bas").read_text() + "RUN\n"
    command = [
        str(executable(system, args)),
        "--mcp",
        "--rom-dir",
        str(args.firmware / system),
    ]
    if atom:
        command += ["--model", "acorn-atom-full"]
    machine = T.Machine(command)
    base, state, origin, guard = (
        (0x5F00, 0x5F20, 0x6000, 12) if atom else (0x8FE0, 0x8FC0, 0x9000, 10)
    )
    captures = {}
    try:
        machine.call("run_frames", frames=150)
        # Bound each keyboard RPC; execute RUN only after complete entry.
        lines = listing.splitlines(keepends=True)
        for offset in range(0, len(lines), 12):
            text = "".join(lines[offset : offset + 12])
            entered = machine.call(
                "type_string", text=text, hold_frames=2, settle_frames=10
            )
            T.require(entered["chars_typed"] == len(text), "Incomplete keyboard entry")
        for _ in range(100):
            machine.call("run_frames", frames=10)
            value = machine.call("memory_read", addr=base, len=2)["bytes"]
            if value == [duration & 255, duration >> 8]:
                break
        else:
            raise AssertionError("Typed loader did not initialise duration")
        machine.call("run_frames", frames=20)
        installed = []
        for offset in range(0, len(binary.read_bytes()), 256):
            length = min(256, len(binary.read_bytes()) - offset)
            chunk = machine.call("memory_read", addr=origin + offset, len=length)[
                "bytes"
            ]
            T.require(len(chunk) == length, "Incomplete machine-code readback")
            installed.extend(chunk)
        if bytes(installed) != binary.read_bytes():
            (build / "installed.json").write_text(
                json.dumps(
                    {"installed": installed, "expected": list(binary.read_bytes())}
                )
            )
            raise AssertionError(
                f"Typed code mismatch: {len(installed)} observed bytes / {len(binary.read_bytes())} expected"
            )

        def read() -> dict[str, Any]:
            d = machine.call("memory_read", addr=base, len=guard + 2)["bytes"]
            s = machine.call("memory_read", addr=state, len=10)["bytes"]
            T.require(d[guard:] == [165, 90], "Deadline guard changed")
            return {
                "remaining": d[2] + 256 * d[3],
                "active": d[4],
                "expired": d[5],
                "clock": d[8] + 256 * d[9],
                "turns": s[4] + 256 * s[5],
                "expiries": s[6],
                "guards": d[guard:],
            }

        def frames(count: int) -> None:
            machine.call("run_frames", frames=count)

        def key(name: str, down: bool, count: int = 8) -> None:
            machine.call("input", events=[{"Key": {"name": name, "pressed": down}}])
            frames(count)

        def capture(name: str) -> None:
            image = out / f"{variant}-{name}.png"
            machine.call("save_screenshot", path=str(image))
            captures[image.name] = sha(image)

        idle = read()
        frames(30)
        after_idle = read()
        T.require(
            after_idle["turns"] == idle["turns"] == 0 and not after_idle["active"],
            "Untimed idle consumed a turn",
        )
        delta = (after_idle["clock"] - idle["clock"]) % 65536
        T.require(
            (28 <= delta <= 32) if atom else (174 <= delta <= 186),
            f"Wrong native clock rate: {delta}",
        )
        capture("untimed")
        key("space", True)
        key("space", False)
        untimed_action = read()
        T.require(
            untimed_action["turns"] == 1 and not untimed_action["active"],
            "Untimed action started a timer",
        )
        frames(20)
        T.require(
            read()["turns"] == 1 and not read()["active"],
            "Untimed action changed clock policy",
        )
        capture("untimed-action")
        key("t", True)
        key("t", False)
        start = read()
        T.require(start["active"] == 1, "T did not enable deadline")
        frames(8)
        running = read()
        elapsed = (running["clock"] - start["clock"]) % 65536
        T.require(
            start["remaining"] - running["remaining"] == elapsed
            and running["turns"] == 1,
            "Clock/countdown disagree",
        )
        frames(110 if duration == (100 if atom else 600) else 60)
        expiry = read()
        if variant == "wrong-input-gate":
            T.require(
                expiry["turns"] == 1
                and expiry["expiries"] == 0
                and expiry["active"] == 0
                and expiry["remaining"] == 0,
                "Fault did not reach ignored completed expiry",
            )
            rejected = True
        else:
            T.require(
                expiry["turns"] == 2
                and expiry["expiries"] == 1
                and expiry["active"] == 1,
                f"Deadline did not commit one turn: {expiry}",
            )
            rejected = False
        capture("expiry")
        # Fresh public caller variants prove action restart and timer disable, not the broken one.
        actions = {}
        if not rejected:
            key("space", True)
            key("space", False)
            action = read()
            T.require(
                action["turns"] == 3 and action["remaining"] > duration // 2,
                f"Action did not restart deadline: {action}",
            )
            # CPC consumes firmware-delivered characters, including repeat; Atom uses physical edges.
            if atom:
                key("space", True, 3)
                held_start = read()
                frames(10)
                T.require(
                    read()["turns"] == held_start["turns"], "Held Atom input repeated"
                )
                key("space", False, 3)
            capture("action")
            key("t", True)
            key("t", False)
            stopped = read()
            frames(130)
            T.require(
                read()["turns"] == stopped["turns"] and not read()["active"],
                "Disabled timer advanced world",
            )
            actions = {"restart": action, "disabled": stopped, "disabled_after": read()}
        return {
            "duration": duration,
            "idle": idle,
            "after_idle": after_idle,
            "untimed_action": untimed_action,
            "ticks_in_30_frames": delta,
            "enabled": start,
            "running": running,
            "expiry": expiry,
            "fault_rejected": rejected,
            "actions": actions,
            "captures": captures,
            "binary_sha256": sha(binary),
            "binary_bytes": len(binary.read_bytes()),
            "loader_sha256": sha(build / "build/loader.bas"),
            "server": machine.server["serverInfo"],
        }
    finally:
        machine.close()


def verify(system: str, args: argparse.Namespace) -> None:
    out = folder(system) / "verification"
    out.mkdir(exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    cases = {}
    variants = ["working", "custom-duration", "wrong-input-gate", "repaired"]
    if system == "acorn-atom":
        variants.append("clock-wrap")
    for variant in variants:
        cases[variant] = public_case(system, variant, args)
        print(system, variant, "passed", flush=True)
    arithmetic_result = arithmetic(system, args)
    record = {
        "status": "passed",
        "machine_id": system,
        "language": "assembly",
        "startup": "Cold stock firmware; complete generated BASIC loader entered through keyboard, RUN, installed bytes compared",
        "configuration": "Atom full 32 KiB, PAL field sync"
        if system == "acorn-atom"
        else "CPC464 PAL, firmware interrupts enabled, 300 Hz KL TIME PLEASE",
        "cases": cases,
        "arithmetic": arithmetic_result,
        "sources": {str(p.relative_to(ROOT)): sha(p) for p in source_paths(system)},
        "observers": {
            str(p.relative_to(ROOT)): sha(p)
            for p in [Path(__file__), ROOT / "scripts/verify-game-loops.py"]
        },
        "emulator_sha256": sha(executable(system, args)),
        "assembler_sha256": sha(args.assembler),
        "firmware_sha256": {
            p.name: sha(p)
            for p in sorted((args.firmware / system).glob("*.rom"))
            if p.name in ("atom.rom", "cpc464.rom")
        },
        "limits": "Named emulator configurations; reset arithmetic fixtures are separate from stock firmware callers. Atom counts observed sync edges and loses missed flybacks; CPC uses low 16 firmware ticks and must be serviced within 65536 ticks. No original hardware or full game budget.",
    }
    (out / "results.json").write_text(json.dumps(record, indent=2) + "\n")
    print(system, "complete", flush=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tools", type=Path, required=True)
    parser.add_argument("--firmware", type=Path, required=True)
    parser.add_argument("--system", choices=SYSTEMS, required=True)
    args = parser.parse_args()
    args.tools = args.tools.resolve()
    args.firmware = args.firmware.resolve()
    args.assembler = args.tools / "asm198x-aarch64-apple-darwin/asm198x"
    verify(args.system, args)


if __name__ == "__main__":
    main()
