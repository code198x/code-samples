"""Run language-specific loops through cold firmware and typed programs."""

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
    "loop_transport", ROOT / "scripts/verify-game-loops.py"
)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Native transport missing")
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
SYSTEMS = ("acorn-atom", "bbc-micro", "acorn-electron", "amstrad-cpc")


def qualify(system: str, args: argparse.Namespace) -> dict[str, Any]:
    basic = system in ("bbc-micro", "acorn-electron")
    family = "acorn-bbc-micro" if system == "bbc-micro" else system
    fw = args.firmware / family
    executable = (
        args.tools / f"emu198x-{family}-aarch64-apple-darwin" / f"emu198x-{family}"
    )
    command = [str(executable), "--mcp"]
    if system == "bbc-micro":
        command += [
            "--mos",
            str(fw / "os.rom"),
            "--rom",
            f"acorn-bbc-basic={fw / 'basic.rom'}",
        ]
    elif system == "acorn-electron":
        command += ["--os", str(fw / "os.rom"), "--basic", str(fw / "basic.rom")]
    else:
        command += ["--rom-dir", str(fw)]
        if system == "acorn-atom":
            command += ["--model", "acorn-atom-full"]
    folder = (
        ROOT
        / system
        / f"patterns/{'basic/framework/turn-loop' if basic else 'assembly/framework/command-loop'}"
    )
    source = ROOT / "bbc-micro/patterns/basic/framework/turn-loop" if basic else folder
    output = folder / "verification"
    output.mkdir(parents=True, exist_ok=True)
    traces: dict[str, Any] = {}
    images: dict[str, str] = {}
    variants = ("default", "step-two", "nonzero", "wrap", "wrong", "fixed")
    original_settings = (source / "settings.inc").read_text() if not basic else ""
    original_dispatch = (source / "dispatch.inc").read_text() if not basic else ""
    try:
        for variant in variants:
            initial = 37 if variant == "nonzero" else 254 if variant == "wrap" else 0
            step = 2 if variant == "step-two" else 1
            if basic:
                caller = (
                    (source / "caller.bas")
                    .read_text()
                    .replace("N%=0:S%=1", f"N%={initial}:S%={step}")
                )
                routines = source / (
                    "mistakes/no-edge.bas" if variant == "wrong" else "routines.bas"
                )
                listing = caller + routines.read_text()
            else:
                settings = (
                    original_settings.replace("INITIAL = 0", f"INITIAL = {initial}")
                    .replace("STEP = 1", f"STEP = {step}")
                    .replace("INITIAL equ 0", f"INITIAL equ {initial}")
                    .replace("STEP equ 1", f"STEP equ {step}")
                )
                (source / "settings.inc").write_text(settings)
                (source / "dispatch.inc").write_text(
                    (source / "mistakes/reset-each-command.inc").read_text()
                    if variant == "wrong"
                    else original_dispatch
                )
                subprocess.run(
                    [
                        "make",
                        f"ASM198X={args.tools / 'asm198x-aarch64-apple-darwin/asm198x'}",
                    ],
                    cwd=folder,
                    check=True,
                    timeout=30,
                    stdout=subprocess.DEVNULL,
                )
                listing = (folder / "build/loader.bas").read_text()
            machine = T.Machine(command)
            try:
                machine.call("run_frames", frames=150)
                result = machine.call(
                    "type_string",
                    text=listing + "RUN\n",
                    hold_frames=2,
                    settle_frames=10,
                )
                T.require(
                    result["chars_typed"] == len(listing) + 4,
                    "Incomplete keyboard entry",
                )
                machine.call("run_frames", frames=20)
                address = (
                    0x3000 if basic else 0x2700 if system == "acorn-atom" else 0x8FF0
                )

                def state(machine: Any = machine, address: int = address) -> list[int]:
                    raw = machine.call("memory_read", addr=address, len=6)["bytes"]
                    T.require(raw[4:] == [165, 90], f"{system}: state boundary changed")
                    return raw[:4]

                def frames(n: int, machine: Any = machine) -> None:
                    machine.call("run_frames", frames=n)

                def key(pressed: bool, machine: Any = machine) -> None:
                    machine.call(
                        "input", events=[{"Key": {"name": "space", "pressed": pressed}}]
                    )
                    frames(8)

                def typed(text: str, machine: Any = machine) -> None:
                    machine.call(
                        "type_string", text=text, hold_frames=2, settle_frames=10
                    )
                    frames(8)

                def capture(
                    label: str, machine: Any = machine, variant: str = variant
                ) -> None:
                    image = output / f"{variant}-{label}.png"
                    machine.call("save_screenshot", path=str(image))
                    images[image.name] = T.sha(image)

                if not basic:
                    for _ in range(24):
                        if state()[1] == step:
                            break
                        frames(10)
                    T.require(state()[1] == step, "Loader did not reach initialisation")
                    frames(60)
                T.require(
                    state()[0] == initial, f"{system}/{variant}: startup {state()}"
                )
                capture("waiting")
                first = state()
                frames(60)
                if not basic:
                    for _ in range(24):
                        if state()[1] == step:
                            break
                        frames(10)
                    T.require(state()[1] == step, "Loader did not reach initialisation")
                    frames(60)
                T.require(state()[0] == initial, "Idle advanced the world")
                rate = None
                if basic:
                    before = state()
                    frames(30)
                    after = state()
                    rate = (
                        (after[1] + 256 * after[2]) - (before[1] + 256 * before[2])
                    ) & 65535
                    T.normal_rate(rate, 30)
                    key(True)
                    held_start = state()[0]
                    frames(30)
                    held_end = state()[0]
                    if variant == "wrong":
                        T.require(
                            held_end != held_start, "Broken edge was not observable"
                        )
                    else:
                        T.require(
                            held_start == (initial + step) & 255
                            and held_end == held_start,
                            f"Held key repeated {state()}",
                        )
                    capture("held")
                    key(False)
                    key(True)
                    second = state()[0]
                    if variant != "wrong":
                        T.require(
                            second == (initial + 2 * step) & 255, "Second press lost"
                        )
                    capture("action")
                    key(False)
                    observations = [initial, held_start, held_end, second]
                else:
                    binary = (folder / "build/demo.bin").read_bytes()
                    base = 0x2800 if system == "acorn-atom" else 0x9000
                    installed = bytes(
                        machine.call("memory_read", addr=base, len=len(binary))["bytes"]
                    )
                    T.require(
                        installed == binary, "Typed loader differs from assembled bytes"
                    )
                    typed("X")
                    T.require(
                        state()[0] == (0 if variant == "wrong" else initial)
                        and state()[2:] == [0, 88],
                        "Rejected command changed state/flag",
                    )
                    observed = []
                    for n in (1, 2):
                        typed("G")
                        expected = (
                            step if variant == "wrong" else (initial + n * step) & 255
                        )
                        T.require(
                            state() == [expected, step, 1, 71],
                            f"Accepted command: {state()}",
                        )
                        observed.append(state()[0])
                        frames(60)
                        T.require(state()[0] == expected, "Idle changed command state")
                    capture("action")
                    observations = [initial, *observed]
                traces[variant] = {
                    "startup": first,
                    "program_sha256": hashlib.sha256(
                        listing.encode() if basic else binary
                    ).hexdigest(),
                    "progression": observations,
                    "updates_per_30_fields": rate,
                }
                print(system, variant, traces[variant], flush=True)
            finally:
                machine.close()
        if basic:
            # A separate cold run isolates the missing-wait error from the edge error.
            machine = T.Machine(command)
            try:
                machine.call("run_frames", frames=150)
                listing = (source / "caller.bas").read_text() + (
                    source / "mistakes/no-wait.bas"
                ).read_text()
                result = machine.call(
                    "type_string",
                    text=listing + "RUN\n",
                    hold_frames=2,
                    settle_frames=10,
                )
                T.require(
                    result["chars_typed"] == len(listing) + 4,
                    "Incomplete faulty listing",
                )

                def count() -> int:
                    raw = machine.call("memory_read", addr=0x3001, len=2)["bytes"]
                    return raw[0] + 256 * raw[1]

                before = count()
                machine.call("run_frames", frames=30)
                delta = (count() - before) & 65535
                rejected = False
                try:
                    T.normal_rate(delta, 30)
                except AssertionError:
                    rejected = True
                T.require(rejected, "No-wait control passed field-rate guard")
                image = output / "no-wait-action.png"
                machine.call("save_screenshot", path=str(image))
                images[image.name] = T.sha(image)
                traces["no-wait"] = {
                    "updates_per_30_fields": delta,
                    "rate_guard_rejected": rejected,
                }
            finally:
                machine.close()
    finally:
        if not basic:
            (source / "settings.inc").write_text(original_settings)
            (source / "dispatch.inc").write_text(original_dispatch)
            subprocess.run(
                [
                    "make",
                    f"ASM198X={args.tools / 'asm198x-aarch64-apple-darwin/asm198x'}",
                ],
                cwd=folder,
                check=True,
                timeout=30,
                stdout=subprocess.DEVNULL,
            )
    paths = [
        p
        for p in source.rglob("*")
        if p.is_file()
        and "build" not in p.parts
        and "verification" not in p.parts
        and p.name != "README.md"
    ]
    if system == "acorn-electron":
        paths += [folder / "qualification-toolchain.json"]
    paths += [
        ROOT / "cross-platform/patterns/framework/command-turns" / f"{cpu}.inc"
        for cpu in ([] if basic else ["6502" if system == "acorn-atom" else "z80"])
    ]
    record = {
        "status": "passed",
        "machine_id": system,
        "language": "basic" if basic else "assembly",
        "startup": "Cold firmware, entire numbered program and RUN typed through keyboard",
        "configuration": {
            "acorn-atom": "Atom full 32 KiB, integer BASIC loader, stock character firmware",
            "bbc-micro": "BBC Model B, MOS and BASIC, MODE 6",
            "acorn-electron": "Electron MOS and BASIC, MODE 6",
            "amstrad-cpc": "CPC464 PAL, Locomotive BASIC loader, MODE 1",
        }[system],
        "cases": traces,
        "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in sorted(paths)},
        "observer_sources": {
            str(Path(__file__).relative_to(ROOT)): T.sha(Path(__file__)),
            "scripts/verify-game-loops.py": T.sha(
                ROOT / "scripts/verify-game-loops.py"
            ),
        },
        "artifacts": images,
        "executable_sha256": T.sha(executable),
        "assembler_sha256": T.sha(args.tools / "asm198x-aarch64-apple-darwin/asm198x"),
        "firmware_sha256": {p.name: T.sha(p) for p in fw.glob("*.rom")},
        "limits": "Selected released native emulator and ROM configuration only; not original hardware, all ROM versions or a complete game budget.",
    }
    (output / "results.json").write_text(json.dumps(record, indent=2) + "\n")
    return record


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tools", type=Path, required=True)
    parser.add_argument("--firmware", type=Path, required=True)
    parser.add_argument("--only", choices=SYSTEMS)
    args = parser.parse_args()
    for system in [args.only] if args.only else SYSTEMS:
        print(json.dumps(qualify(system, args)), flush=True)


if __name__ == "__main__":
    main()
