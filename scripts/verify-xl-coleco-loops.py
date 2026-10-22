"""Execute independent Atari BASIC/assembly and ColecoVision loop callers."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SHARED = Path("cross-platform/patterns/framework/atari-turn-loops")
FONT = Path("cross-platform/patterns/rendering/bitmap-text/font-z80.inc")
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Native transport missing")
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
CONFIGS = {
    "atari-basic": ("atari-800xl", "basic", "command-loop"),
    "atari-assembly": ("atari-800xl", "assembly", "turn-loop"),
    "coleco": ("coleco-colecovision", "assembly", "turn-loop"),
}
VARIANTS = (
    "working",
    "customise",
    "wrap",
    "nonzero",
    "held-as-press",
    "bad-wait",
    "fixed-edge",
    "fixed-wait",
)


def qualify(key: str, args: argparse.Namespace) -> dict[str, Any]:
    system, language, slug = CONFIGS[key]
    basic = language == "basic"
    coleco = system == "coleco-colecovision"
    rel = Path(system) / f"patterns/{language}/framework/{slug}"
    folder = ROOT / rel
    out = folder / "verification/reusable" if basic else folder / "verification"
    out.mkdir(parents=True, exist_ok=True)
    name = "colecovision" if coleco else "atari-800xl"
    binary = args.tools / f"emu198x-{name}-aarch64-apple-darwin" / f"emu198x-{name}"
    asm = args.tools / "asm198x-aarch64-apple-darwin/asm198x"
    fw = args.firmware / system
    traces: dict[str, Any] = {}
    artifacts: dict[str, str] = {}
    programs: dict[str, str] = {}
    variants = (
        ("working", "customise", "wrap", "nonzero", "reset-mistake", "fixed")
        if basic
        else VARIANTS
    )
    for variant in variants:
        with tempfile.TemporaryDirectory(prefix="xl-coleco-case-") as temp:
            stage = Path(temp)
            target = stage / rel
            shutil.copytree(
                folder, target, ignore=shutil.ignore_patterns("build", "verification")
            )
            initial = 254 if variant == "wrap" else 37 if variant == "nonzero" else 0
            step = 2 if variant == "customise" else 1
            if basic:
                caller = (
                    "mistakes/reset-each-turn.bas"
                    if variant == "reset-mistake"
                    else "customise.bas"
                    if variant == "customise"
                    else "caller.bas"
                )
                listing = (target / caller).read_text().replace(
                    "N=0", f"N={initial}", 1
                ) + (target / "routines.bas").read_text()
                data = listing.encode()
            else:
                shutil.copytree(ROOT / SHARED, stage / SHARED)
                (stage / FONT).parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT / FONT, stage / FONT)
                if variant in ("customise", "wrap", "nonzero"):
                    shutil.copyfile(
                        target / (variant + ".inc"), target / "settings.inc"
                    )
                if variant == "held-as-press":
                    src = (
                        target / "mistakes/held-as-press.inc"
                        if coleco
                        else stage / SHARED / "mistakes/held-as-press.inc"
                    )
                    dst = (
                        target / "edge.inc"
                        if coleco
                        else stage / SHARED / "edge-filter.inc"
                    )
                    shutil.copyfile(src, dst)
                if variant == "bad-wait":
                    shutil.copyfile(
                        target / "mistakes/no-wait.inc", target / "frame.inc"
                    )
                subprocess.run(
                    ["make", f"ASM198X={asm}"],
                    cwd=target,
                    check=True,
                    timeout=30,
                    stdout=subprocess.DEVNULL,
                )
                data = (
                    target / ("build/demo.cv" if coleco else "build/demo.bin")
                ).read_bytes()
                listing = "" if coleco else (target / "build/loader.bas").read_text()
            programs[variant] = hashlib.sha256(data).hexdigest()
            command = [str(binary), "--mcp", "--rom-dir", str(fw)]
            if coleco:
                command += ["--cart", str(target / "build/demo.cv")]
            machine = T.Machine(command)
            try:

                def frames(n: int, machine: Any = machine) -> None:
                    machine.call("run_frames", frames=n)

                def typed(text: str, machine: Any = machine) -> None:
                    result = machine.call("type_string", text=text, settle_frames=60)
                    T.require(
                        result["chars_typed"] == len(text), "Incomplete keyboard entry"
                    )

                def capture(
                    label: str, machine: Any = machine, variant: str = variant
                ) -> None:
                    image = out / f"{variant}-{label}.png"
                    machine.call("save_screenshot", path=str(image))
                    artifacts[image.name] = T.sha(image)

                def screen(field: str = "TURN", machine: Any = machine) -> int:
                    ptr = machine.call("memory_read", addr=0x58, len=2)["bytes"]
                    addr = ptr[0] + 256 * ptr[1]
                    raw = []
                    for offset in range(0, 960, 240):
                        raw += machine.call("memory_read", addr=addr + offset, len=240)[
                            "bytes"
                        ]
                    text = "".join(
                        chr((c & 127) + 32) if (c & 127) < 64 else " " for c in raw
                    )
                    matches = re.findall(field + r"\s*(\d+)", text)
                    T.require(
                        len(matches) == 1, f"Expected one rendered {field}: {text}"
                    )
                    return int(matches[0])

                base = 0x6000 if coleco else 0x6E0

                def state(machine: Any = machine, base: int = base) -> list[int]:
                    raw = machine.call("memory_read", addr=base, len=9)["bytes"]
                    T.require(
                        raw[7:] == [165, 90], "Routine overran its seven-byte context"
                    )
                    return raw[:7]

                def button(pressed: bool, machine: Any = machine) -> None:
                    machine.call(
                        "input",
                        events=[
                            {"Button": {"port": 1, "name": "fire", "pressed": pressed}}
                        ],
                    )
                    frames(8)

                frames(300 if coleco else 900)
                if not coleco:
                    for line in (listing + "RUN\n").splitlines():
                        typed(line + "\n")
                if basic:
                    T.require(
                        screen() == initial and screen("FLAG") == 0, "Wrong startup"
                    )
                    capture("waiting")
                    frames(120)
                    T.require(screen() == initial, "Idle advanced rules")
                    typed("0\n")
                    T.require(
                        screen() == (0 if variant == "reset-mistake" else initial)
                        and screen("FLAG") == 0,
                        "Rejected input changed state/flag",
                    )
                    observed = [initial]
                    for n in (1, 2):
                        typed("1\n")
                        expected = (
                            step
                            if variant == "reset-mistake"
                            else (initial + n * step) & 255
                        )
                        T.require(
                            screen() == expected and screen("FLAG") == 1,
                            "Accepted command wrong",
                        )
                        observed.append(screen())
                        frames(120)
                        T.require(
                            screen() == expected, "Idle after action advanced rules"
                        )
                        capture(f"action-{n}")
                    traces[variant] = {
                        "progression": observed,
                        "rejected_flag": 0,
                        "accepted_flag": 1,
                    }
                else:
                    ready = False
                    for _ in range(40):
                        raw = machine.call("memory_read", addr=base, len=9)["bytes"]
                        if raw[5] == step and raw[7:] == [165, 90]:
                            ready = True
                            break
                        frames(10)
                    T.require(ready, "Native startup did not initialise its context")
                    frames(60)
                    if not coleco:
                        installed = bytes(
                            machine.call("memory_read", addr=0x600, len=len(data))[
                                "bytes"
                            ]
                        )
                        T.require(
                            installed == data,
                            "Typed loader differs from assembled program",
                        )
                    initial_state = state()
                    T.require(initial_state[0] == initial, "Initial counter lost")
                    capture("waiting")
                    before = state()
                    frames(30)
                    after = state()
                    rate = (
                        (after[2] + 256 * after[3]) - (before[2] + 256 * before[3])
                    ) & 65535
                    T.require(after[0] == initial, "Idle advanced rules")
                    if variant == "bad-wait":
                        rejected = False
                        try:
                            T.normal_rate(rate, 30)
                        except AssertionError:
                            rejected = True
                        T.require(rejected, "No-wait fault escaped pacing check")
                    else:
                        T.normal_rate(rate, 30)
                    button(True)
                    pressed = state()
                    capture("pressed")
                    frames(30)
                    held = state()
                    capture("held")
                    button(False)
                    released = state()
                    button(True)
                    second = state()
                    capture("second")
                    if variant == "held-as-press":
                        T.require(held[0] != pressed[0], "Held fault did not repeat")
                    else:
                        T.require(
                            pressed[0] == (initial + step) & 255
                            and held[0] == pressed[0]
                            and second[0] == (initial + 2 * step) & 255,
                            "Press/hold/wrap policy failed",
                        )
                        T.require(
                            held[6] == 0 and released[1] == released[6] == 0,
                            "Release/accepted flags wrong",
                        )
                    T.require(
                        all(s[5] == step for s in [pressed, held, released, second]),
                        "Step clobbered",
                    )
                    traces[variant] = {
                        "states": {
                            "initial": initial_state,
                            "pressed": pressed,
                            "held": held,
                            "released": released,
                            "second": second,
                        },
                        "service_ticks_in_30_frames": rate,
                    }
                print(key, variant, traces[variant], flush=True)
            finally:
                machine.close()
    source_paths = [
        p
        for p in folder.rglob("*")
        if p.is_file()
        and "build" not in p.parts
        and "verification" not in p.parts
        and p.name != "README.md"
    ]
    if not basic:
        source_paths += (
            [ROOT / FONT] if coleco else list((ROOT / SHARED).rglob("*.inc"))
        )
    tools = json.loads((folder / "qualification-toolchain.json").read_text())
    record = {
        "status": "passed",
        "machine_id": system,
        "language": language,
        "configuration": "800XL NTSC, stock OS and Atari BASIC, GRAPHICS 0"
        if not coleco
        else "ColecoVision NTSC, stock BIOS and title-skipping 32 KiB cartridge, polled VDP with IE0 disabled",
        "startup": "Fresh firmware and typed numbered program/RUN"
        if not coleco
        else "Fresh stock BIOS cartridge startup; no host CPU/RAM injection",
        "variants": traces,
        "program_sha256": programs,
        "artifacts": artifacts,
        "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in sorted(source_paths)},
        "observer_sources": {
            str(Path(__file__).relative_to(ROOT)): T.sha(Path(__file__)),
            "scripts/verify-game-loops.py": T.sha(
                ROOT / "scripts/verify-game-loops.py"
            ),
        },
        "emulator_sha256": T.sha(binary),
        "assembler_sha256": T.sha(asm),
        "release_tags": {"emu198x": "v0.44.1", "asm198x": "asm198x-v0.0.71"},
        "firmware_sha256": {
            p.name: T.sha(p)
            for p in (
                [fw / "colecovision.rom"]
                if coleco
                else [fw / "atarixl.rom", fw / "ataribas.rom"]
            )
        },
        "limits": "The named workload, released native tools and supplied firmware only; no PAL or physical-hardware timing qualification.",
    }
    T.require(
        record["emulator_sha256"] == tools["emulator_binary_sha256"],
        "Tool identity drift",
    )
    (out / "results.json").write_text(json.dumps(record, indent=2) + "\n")
    return record


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tools", type=Path, required=True)
    parser.add_argument("--firmware", type=Path, required=True)
    parser.add_argument("--only", choices=CONFIGS)
    args = parser.parse_args()
    for key in [args.only] if args.only else CONFIGS:
        qualify(key, args)


if __name__ == "__main__":
    main()
