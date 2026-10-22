"""Run five CBM language routes through stock firmware and real command input.

No state pokes: source initialisers and callers create every observed value.
Assembly PRGs use the emulator's documented importer, then their BASIC SYS stub.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
_spec = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert _spec and _spec.loader
T = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(T)
ROUTES = [
    ("commodore-64", "basic"),
    ("commodore-pet", "basic"),
    ("commodore-pet", "assembly"),
    ("commodore-vic-20", "basic"),
    ("commodore-vic-20", "assembly"),
]
VARIANTS = {
    "working": (0, 1),
    "step-three": (0, 3),
    "wrong-reset": (0, 1),
    "repaired": (0, 1),
    "wrap": (254, 1),
    "nonzero": (100, 255),
}


def decode(raw: list[int]) -> str:
    return "".join(
        chr(c & 127)
        if 32 <= (c & 127) < 64
        else chr((c & 127) + 64)
        if 1 <= (c & 127) <= 26
        else " "
        for c in raw
    )


def execute(system: str, track: str, args: argparse.Namespace) -> None:
    folder = ROOT / system / f"patterns/{track}/framework/command-loop"
    out = folder / "verification/reusable"
    out.mkdir(parents=True, exist_ok=True)
    build = folder / "build"
    build.mkdir(exist_ok=True)
    binary_name = {"commodore-64": "c64"}.get(system, system)
    executable = args.native / ("emu198x-" + binary_name)
    rom = args.firmware_root / ({"commodore-64": "commodore-c64"}.get(system, system))
    command = [str(executable), "--mcp", "--rom-dir", str(rom)]
    if system == "commodore-64":
        command += ["--model", "pal"]
    elif system == "commodore-pet":
        command += ["--columns", "40"]
    else:
        command += ["--region", "pal", "--ram-expansion", "none"]
    screen, length = {
        "commodore-64": (0x400, 1000),
        "commodore-pet": (0x8000, 1000),
        "commodore-vic-20": (0x1E00, 506),
    }[system]
    records = {}
    for variant, (initial, step) in VARIANTS.items():
        case = build / variant
        case.mkdir(exist_ok=True)
        if track == "basic":
            caller = (
                folder
                / (
                    "customise.bas"
                    if variant == "step-three"
                    else "mistakes/reset-each-command.bas"
                    if variant == "wrong-reset"
                    else "caller.bas"
                )
            ).read_text()
            if variant in ("wrap", "nonzero"):
                caller = caller.replace("N=0:S=1", f"N={initial}:S={step}")
            program = caller + (folder / "routines.bas").read_text()
            (case / "entered.bas").write_text(program)
        else:
            caller = (
                folder
                / (
                    "customise.inc"
                    if variant == "step-three"
                    else "mistakes/reset-each-command.inc"
                    if variant == "wrong-reset"
                    else "caller.inc"
                )
            ).read_text()
            if variant in ("wrap", "nonzero"):
                caller = caller.replace(
                    "lda #0\n    sta turn_count", f"lda #{initial}\n    sta turn_count"
                ).replace(
                    "lda #1\n    sta turn_step", f"lda #{step}\n    sta turn_step"
                )
            demo = (folder / "demo.asm").read_text()
            for include in ["caller", "routines", "presentation"]:
                demo = demo.replace(
                    f'    !source "{include}.inc"',
                    caller
                    if include == "caller"
                    else (folder / f"{include}.inc").read_text(),
                )
            (case / "demo.asm").write_text(demo)
            subprocess.run(
                [
                    str(args.assembler),
                    "--dialect",
                    "acme",
                    "--prg",
                    str(case / "demo.asm"),
                    "--sym=" + str(case / "demo.sym"),
                    "-o",
                    str(case / "demo.prg"),
                ],
                check=True,
                capture_output=True,
                timeout=30,
            )
            sym = T.symbols(case / "demo.sym")
        machine = T.Machine(command)
        observations = []
        try:

            def frames(n: int, machine: T.Machine = machine) -> None:
                while n:
                    part = min(n, 250)
                    machine.call("run_frames", frames=part)
                    n -= part

            def typed(text: str, machine: T.Machine = machine) -> None:
                result = machine.call(
                    "type_string", text=text, hold_frames=3, settle_frames=8
                )
                T.require(
                    result["chars_typed"] == len(text), f"Incomplete command: {result}"
                )
                frames(20)

            def observe(
                stage: str,
                expected: int,
                machine: T.Machine = machine,
                variant: str = variant,
                step: int = step,
                observations: list = observations,
                state_address: int | None = sym["turn_count"]
                if track == "assembly"
                else None,
            ) -> None:
                raw = []
                for offset in range(0, length, 128):
                    raw.extend(
                        machine.call(
                            "memory_read",
                            addr=screen + offset,
                            len=min(128, length - offset),
                        )["bytes"]
                    )
                text = decode(raw)
                hits = re.findall(r"TURN\s*(\d+)", text)
                T.require(
                    len(hits) == 1 and int(hits[0]) == expected,
                    f"{system}/{track}/{variant}/{stage}: expected {expected}: {text}",
                )
                native_state = None
                if track == "assembly":
                    native_state = machine.call(
                        "memory_read", addr=state_address, len=3
                    )["bytes"]
                    T.require(
                        native_state[0] == expected and native_state[1] == step,
                        f"Wrong assembly state {native_state}",
                    )
                image = f"{variant}-{stage}.png"
                machine.call("save_screenshot", path=str(out / image))
                observations.append(
                    {
                        "stage": stage,
                        "count": expected,
                        "screen_bytes": raw,
                        "native_state": native_state,
                        "image": image,
                        "image_sha256": T.sha(out / image),
                    }
                )

            frames(150)
            if track == "basic":
                for line in (program + "RUN\n").splitlines():
                    typed(line + "\n")
            else:
                machine.call(
                    "load_media",
                    slot="program-1",
                    kind="program",
                    path=str(case / "demo.prg"),
                )
                frames(150)
            observe("initial", initial)
            frames(120)
            observe("idle", initial)
            typed("A\n" if track == "basic" else "A")
            first = step if variant == "wrong-reset" else (initial + step) % 256
            observe("first", first)
            frames(120)
            observe("idle-after", first)
            typed("X\n" if track == "basic" else "X")
            ignored = 0 if variant == "wrong-reset" else first
            observe("ignored", ignored)
            typed("A\n" if track == "basic" else "A")
            second = step if variant == "wrong-reset" else (first + step) % 256
            observe("second", second)
            typed("Q\n" if track == "basic" else "Q")
            raw = []
            for offset in range(0, length, 128):
                raw.extend(
                    machine.call(
                        "memory_read",
                        addr=screen + offset,
                        len=min(128, length - offset),
                    )["bytes"]
                )
            T.require("READY" in decode(raw), "Q did not return to BASIC")
            records[variant] = {
                "observations": observations,
                "quit_ready": True,
                "entered_sha256": T.sha(
                    case / ("entered.bas" if track == "basic" else "demo.asm")
                ),
            }
            if track == "assembly":
                records[variant]["prg_sha256"] = T.sha(case / "demo.prg")
            print(
                "PASS",
                system,
                track,
                variant,
                [o["count"] for o in observations],
                flush=True,
            )
        finally:
            machine.close()
    input_files = sorted(
        p
        for p in folder.rglob("*")
        if p.is_file()
        and "build" not in p.parts
        and "verification" not in p.parts
        and p.name != "demo.bas"
        and p.suffix in (".bas", ".inc", ".asm")
    )
    lock_path = (
        args.native.parent
        / f"emu198x-{binary_name}-aarch64-apple-darwin-source-lock.json"
    )
    lock = json.loads(lock_path.read_text())
    T.require(
        T.sha(executable) == lock["executable_sha256"],
        "Executable differs from producer lock",
    )
    T.require(
        lock["before_lock_sha256"]
        == lock["after_lock_sha256"]
        == lock["committed_lock_sha256"],
        "Producer lock changed",
    )
    result = {
        "status": "passed",
        "machine": system,
        "track": track,
        "emulator_release": "v0.44.1",
        "producer_source_lock": lock,
        "emulator_sha256": T.sha(executable),
        "firmware_sha256": {p.name: T.sha(p) for p in sorted(rom.glob("*.rom"))},
        "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in input_files},
        "observer_sources": {
            str(p.relative_to(ROOT)): T.sha(p)
            for p in [Path(__file__), ROOT / "scripts/verify-game-loops.py"]
        },
        "configuration": {
            "commodore-64": "PAL C64, BASIC V2",
            "commodore-pet": "40-column PET, pinned BASIC/editor/KERNAL",
            "commodore-vic-20": "PAL VIC-20, unexpanded 5 KiB, BASIC V2",
        }[system],
        "assembler_source_lock": json.loads(
            (
                args.assembler.parent.parent
                / "asm198x-aarch64-apple-darwin-source-lock.json"
            ).read_text()
        )
        if track == "assembly"
        else None,
        "screen_address": screen,
        "screen_length": length,
        "cases": records,
        "limits": "Named stock firmware configuration, native emulator only. BASIC typed from reset; assembly imported PRG then ROM RUN/SYS. Delivered commands, not physical press edges. No original hardware, frame rate, deadline, parser or whole-emulator claim.",
    }
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument("--firmware-root", type=Path, default=Path.home() / ".emu198x/roms")
    p.add_argument("--only", choices=[f"{s}/{t}" for s, t in ROUTES])
    args = p.parse_args()
    for s, t in ROUTES:
        if args.only is None or args.only == f"{s}/{t}":
            execute(s, t, args)
