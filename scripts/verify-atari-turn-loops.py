"""Execute Atari turn routines and distinguish their display-service contracts."""

from __future__ import annotations

import argparse
import importlib.util
import json
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SHARED = Path("cross-platform/patterns/framework/atari-turn-loops")
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Cannot load transport")
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
SYSTEMS = {
    "atari-2600": (0x90, "a26", 30),
    "atari-5200": (0x1000, "bin", 900),
    "atari-7800": (0x1900, "bin", 30),
}
VARIANTS = (
    "working",
    "customise",
    "wrap",
    "held-as-press",
    "bad-service",
    "fixed-edge",
    "fixed-service",
)


def run(system: str, tools: Path, firmware_root: Path) -> dict[str, Any]:
    base, extension, boot = SYSTEMS[system]
    rel = Path(system) / "patterns/assembly/framework/turn-loop"
    folder = ROOT / rel
    out = folder / "verification"
    out.mkdir(exist_ok=True)
    artifacts = {}
    binaries = {}
    observations = {}
    for variant in VARIANTS:
        with tempfile.TemporaryDirectory(prefix="atari-loop-") as scratch:
            stage = Path(scratch)
            shutil.copytree(
                ROOT / SHARED,
                stage / SHARED,
                ignore=shutil.ignore_patterns("verification", "build"),
            )
            shutil.copytree(
                folder,
                stage / rel,
                ignore=shutil.ignore_patterns("verification", "build"),
            )
            build = stage / rel
            if variant in ("customise", "wrap"):
                shutil.copyfile(build / f"{variant}.inc", build / "settings.inc")
            if variant == "held-as-press":
                shutil.copyfile(
                    stage / SHARED / "mistakes/held-as-press.inc",
                    stage / SHARED / "edge-filter.inc",
                )
            if variant == "bad-service":
                shutil.copyfile(
                    build
                    / (
                        "mistakes/extra-line.inc"
                        if system == "atari-2600"
                        else "mistakes/no-wait.inc"
                    ),
                    build
                    / ("overscan-count.inc" if system == "atari-2600" else "frame.inc"),
                )
            cart = out / f"{variant}.{extension}"
            sym = out / f"{variant}.sym"
            subprocess.run(
                [
                    str(tools / "asm198x"),
                    "--dialect",
                    "acme",
                    "demo.asm",
                    f"--sym={sym}",
                    "-o",
                    str(cart),
                ],
                cwd=build,
                check=True,
                timeout=30,
                capture_output=True,
            )
            symbols = T.symbols(sym)
            executable = tools / f"emu198x-{system}"
            command = [str(executable), "--mcp", "--cart", str(cart)]
            if system == "atari-5200":
                command += ["--bios", str(firmware_root / "atari-5200/5200.rom")]
            machine = T.Machine(command)
            try:

                def frames(n: int, machine: Any = machine) -> None:
                    machine.call("run_frames", frames=n)

                def state(machine: Any = machine) -> list[int]:
                    raw = machine.call("memory_read", addr=base, len=7)["bytes"]
                    for address in [base - 1, base + 7]:
                        T.require(
                            machine.call("memory_read", addr=address, len=1)["bytes"]
                            == [165],
                            "State allocation guard changed",
                        )
                    return raw

                def capture(
                    label: str, machine: Any = machine, variant: str = variant
                ) -> str:
                    p = out / f"{variant}-{label}.png"
                    machine.call("save_screenshot", path=str(p))
                    artifacts[p.name] = T.sha(p)
                    return artifacts[p.name]

                def button(pressed: bool, machine: Any = machine) -> None:
                    machine.call(
                        "input",
                        events=[
                            {"Button": {"port": 1, "name": "fire", "pressed": pressed}}
                        ],
                    )
                    frames(8)

                def field_period(
                    machine: Any = machine, symbols: dict[str, int] = symbols
                ) -> int:
                    times = []
                    for _ in range(3):
                        hit = machine.call(
                            "run_until_pc", addr=symbols["frame"], max_steps=100000
                        )
                        T.require(hit["reached"], "Field marker not reached")
                        times.append(
                            machine.call("query", path="machine.master_clock")[
                                "result"
                            ]["value"]
                        )
                        machine.call("step", instructions=1)
                    return times[-1] - times[-2]

                frames(boot)
                initial = 254 if variant == "wrap" else 0
                step = 2 if variant == "customise" else 1
                T.require(state()[0] == initial, "Wrong initial state")
                before = state()
                frames(30)
                after = state()
                delta = (
                    (after[2] + 256 * after[3]) - (before[2] + 256 * before[3])
                ) & 65535
                if variant == "bad-service" and system != "atari-2600":
                    T.require(
                        not 28 <= delta <= 31,
                        f"No-wait fault escaped rate guard: {delta}",
                    )
                else:
                    T.normal_rate(delta, 30)
                frames(120)
                T.require(state()[0] == initial, "Idle advanced rules")
                waiting = capture("waiting")
                periods = []
                if system == "atari-2600":
                    periods.append(field_period())
                button(True)
                pressed = state()
                capture("pressed")
                if system == "atari-2600":
                    periods.append(field_period())
                frames(30)
                held = state()
                capture("held")
                if variant == "held-as-press":
                    T.require(
                        held[0] != pressed[0], "Held-input fault escaped edge guard"
                    )
                else:
                    T.require(
                        pressed[0] == (initial + step) % 256 and held[0] == pressed[0],
                        "Press/hold policy failed",
                    )
                    T.require(held[6] == 0, "Held sample marked accepted")
                button(False)
                released = state()
                button(True)
                second = state()
                button(False)
                capture("second")
                if variant != "held-as-press":
                    T.require(
                        released[1] == 0 and released[6] == 0,
                        "Release did not reset edge state",
                    )
                    T.require(
                        second[0] == (initial + 2 * step) % 256, "Second press failed"
                    )
                if system == "atari-2600":
                    want = (263 if variant == "bad-service" else 262) * 228
                    T.require(
                        periods == [want, want],
                        f"Wrong idle/pressed field periods: {periods}",
                    )
                observations[variant] = {
                    "server": machine.server["serverInfo"],
                    "states": {
                        "initial": initial,
                        "pressed": pressed,
                        "held": held,
                        "released": released,
                        "second": second,
                    },
                    "service_ticks_in_30_frames": delta,
                    "period_colour_clocks": periods,
                    "waiting_sha256": waiting,
                }
            finally:
                machine.close()
            binaries[variant] = {
                "sha256": T.sha(cart),
                "bytes": cart.stat().st_size,
                "routine_bytes": symbols["turn_end"] - symbols["init_turn"],
            }
    for fixed in ["fixed-edge", "fixed-service"]:
        T.require(
            binaries[fixed]["sha256"] == binaries["working"]["sha256"],
            "Repaired executable changed",
        )
        for label in ["waiting", "pressed", "held", "second"]:
            T.require(
                artifacts[f"{fixed}-{label}.png"] == artifacts[f"working-{label}.png"],
                "Repaired capture differs",
            )
    inputs = [
        p
        for p in (folder.rglob("*"))
        if p.is_file()
        and "verification" not in p.parts
        and "build" not in p.parts
        and (p.suffix in [".asm", ".inc"] or p.name == "Makefile")
    ]
    inputs += list((ROOT / SHARED).rglob("*.inc")) + [
        ROOT / SHARED / "toolchain.json",
        Path(__file__),
        ROOT / "scripts/verify-game-loops.py",
    ]
    result = {
        "status": "passed",
        "machine_id": system,
        "variants": observations,
        "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in inputs},
        "artifacts": artifacts,
        "binaries": binaries,
        "firmware_sha256": {"5200.rom": T.sha(firmware_root / "atari-5200/5200.rom")}
        if system == "atari-5200"
        else {},
        "emulator_sha256": T.sha(tools / f"emu198x-{system}"),
        "assembler_sha256": T.sha(tools / "asm198x"),
        "limits": "Named NTSC caller only; 5200 uses pinned BIOS; 7800 reset bypasses BIOS authentication. No original-hardware, PAL, arbitrary workload or deadline qualification.",
    }
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tools", type=Path, required=True)
    parser.add_argument(
        "--firmware-root", type=Path, default=Path.home() / ".emu198x/roms"
    )
    parser.add_argument("--only", choices=SYSTEMS)
    args = parser.parse_args()
    for system in [args.only] if args.only else SYSTEMS:
        result = run(system, args.tools.resolve(), args.firmware_root.resolve())
        print(
            system,
            {
                k: (
                    v["states"]["pressed"][0],
                    v["states"]["held"][0],
                    v["service_ticks_in_30_frames"],
                    v["period_colour_clocks"],
                )
                for k, v in result["variants"].items()
            },
            flush=True,
        )


if __name__ == "__main__":
    main()
