"""Cold-boot shared MOS callers independently on BBC Micro and Electron.

Supply released tools and lawful firmware; entry uses only the keyboard.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "bbc-micro/patterns/assembly/framework/turn-deadline"
spec = importlib.util.spec_from_file_location(
    "firmware_deadlines", ROOT / "scripts/verify-firmware-deadlines.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing existing firmware deadline observer")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
T = V.T
SYSTEMS = ("bbc-micro", "acorn-electron")
VARIANTS = (
    "working",
    "custom-duration",
    "wrong-input-gate",
    "repaired",
    "boundaries",
    "wrong-boundary",
)


def source_paths() -> list[Path]:
    return [
        FOLDER / n
        for n in [
            "demo.asm",
            "settings.inc",
            "clock.inc",
            "input.inc",
            "dispatch.inc",
            "loader.py",
            "Makefile",
            "mistakes/input-gated-expiry.inc",
        ]
    ] + [
        ROOT / "cross-platform/patterns/framework/elapsed-deadline/6502.inc",
        ROOT / "scripts/verify-firmware-deadlines.py",
        ROOT / "scripts/verify-game-loops.py",
        Path(__file__),
    ]


def build(variant: str, assembler: Path) -> tuple[Path, dict[str, Any]]:
    p = FOLDER / "build" / variant
    p.mkdir(parents=True, exist_ok=True)
    settings = (FOLDER / "settings.inc").read_text()
    if variant == "custom-duration":
        settings = settings.replace("DURATION = 400", "DURATION = 200")
    (p / "settings.inc").write_text(settings)
    helper = (
        ROOT / "cross-platform/patterns/framework/elapsed-deadline/6502.inc"
    ).read_text()
    if variant in ("boundaries", "wrong-boundary"):
        code = '!source "settings.inc"\n* = $3000\n    cld\n    cli\n'
        for i, (duration, previous, now) in enumerate(V.CASES):
            code += f"    lda #<{duration}\n    sta DEADLINE\n    lda #>{duration}\n    sta DEADLINE+1\n    lda #<{previous}\n    ldx #>{previous}\n    jsr deadline_init\n    jsr deadline_start\n    lda #165\n    sta DEADLINE+12\n    lda #90\n    sta DEADLINE+13\n    lda #<{now}\n    ldx #>{now}\n    jsr deadline_poll\n"
            for j, offset in enumerate([2, 3, 4, 5, 6, 7, 8, 9, 12, 13]):
                code += (
                    f"    lda DEADLINE+{offset}\n    sta ${0x2E00 + i * 10 + j:04x}\n"
                )
        code += "    lda #239\n    sta $2e78\nstop: jmp stop\n"
        if variant == "wrong-boundary":
            changed = helper.replace(
                "    bne deadline_done\n", "    beq deadline_done\n"
            )
            T.require(changed != helper, "Fault did not change equality branch")
            helper = changed
        code += helper
    else:
        code = (FOLDER / "demo.asm").read_text()
        code = code.replace(
            '!source "settings.inc"', '!source "' + str(p / "settings.inc") + '"'
        )
        for name in ["clock.inc", "input.inc", "dispatch.inc"]:
            selected = FOLDER / (
                "mistakes/input-gated-expiry.inc"
                if name == "dispatch.inc" and variant == "wrong-input-gate"
                else name
            )
            code = code.replace('"' + name + '"', '"' + str(selected) + '"')
        code = code.replace(
            '!source "../../../../../cross-platform/patterns/framework/elapsed-deadline/6502.inc"',
            helper,
        )
    # The boundary caller uses the same settings and helper, no MOS clock claims.
    code = code.replace(
        '!source "settings.inc"', '!source "' + str(p / "settings.inc") + '"'
    )
    (p / "selected.asm").write_text(code)
    binary = p / "build/demo.bin"
    binary.parent.mkdir(exist_ok=True)
    subprocess.run(
        [
            str(assembler),
            "--dialect",
            "acme",
            str(p / "selected.asm"),
            "-o",
            str(binary),
            "--sym=" + str(p / "symbols.sym"),
        ],
        check=True,
        capture_output=True,
        timeout=30,
    )
    (p / "loader.py").write_text((FOLDER / "loader.py").read_text())
    subprocess.run(["python3", str(p / "loader.py")], check=True, timeout=20)
    sym = T.symbols(p / "symbols.sym")
    return p, {
        "binary_sha256": T.sha(binary),
        "binary_bytes": binary.stat().st_size,
        "loader_sha256": T.sha(p / "build/loader.bas"),
        "helper_bytes": sym["deadline_done"] + 1 - sym["deadline_init"],
        "clock_bytes": sym.get("sample_keys", 0) - sym.get("sample_clock", 0)
        if "sample_clock" in sym
        else 0,
    }


def execute(system: str, variant: str, args: argparse.Namespace) -> dict[str, Any]:
    p, metrics = build(variant, args.assembler)
    electron = system == "acorn-electron"
    name = "acorn-electron" if electron else "acorn-bbc-micro"
    exe = args.tools / f"emu198x-{name}-aarch64-apple-darwin" / f"emu198x-{name}"
    rom = args.firmware / name
    command = [str(exe), "--mcp"] + (
        ["--os", str(rom / "os.rom"), "--basic", str(rom / "basic.rom")]
        if electron
        else [
            "--mos",
            str(rom / "os.rom"),
            "--rom",
            f"acorn-bbc-basic={rom / 'basic.rom'}",
        ]
    )
    machine = T.Machine(command)
    out = ROOT / system / "patterns/assembly/framework/turn-deadline/verification"
    out.mkdir(parents=True, exist_ok=True)
    try:
        machine.call("run_frames", frames=150)
        for line in (p / "build/loader.bas").read_text().splitlines():
            r = machine.call(
                "type_string", text=line + "\n", hold_frames=2, settle_frames=3
            )
            T.require(r["chars_typed"] == len(line) + 1, "Incomplete typed line")
        machine.call("type_string", text="RUN\n", hold_frames=2, settle_frames=10)
        expected = (p / "build/demo.bin").read_bytes()
        for _ in range(120):
            machine.call("run_frames", frames=10)
            actual = []
            for off in range(0, len(expected), 256):
                size = min(256, len(expected) - off)
                chunk = machine.call("memory_read", addr=0x3000 + off, len=size)[
                    "bytes"
                ]
                T.require(len(chunk) == size, "Short code read")
                actual += chunk
            if bytes(actual) == expected:
                break
        else:
            machine.call("save_screenshot", path=str(out / "loader-failure.png"))
            raise AssertionError("Typed loader did not install complete executable")
        samples = []
        frames_total = 0

        def frames(n: int) -> None:
            nonlocal frames_total
            machine.call("run_frames", frames=n)
            frames_total += n

        def key(name: str, down: bool, n: int = 3) -> None:
            machine.call("input", events=[{"Key": {"name": name, "pressed": down}}])
            frames(n)

        def tap(name: str) -> None:
            key(name, True)
            key(name, False)

        def read() -> dict[str, Any]:
            d = machine.call("memory_read", addr=0x2F00, len=14)["bytes"]
            s = machine.call("memory_read", addr=0x2F20, len=10)["bytes"]
            T.require(d[12:] == [165, 90], "Deadline guard overwritten")
            return {
                "duration": d[0] + 256 * d[1],
                "remaining": d[2] + 256 * d[3],
                "active": d[4],
                "expired": d[5],
                "elapsed": d[6] + 256 * d[7],
                "clock": d[8] + 256 * d[9],
                "turns": s[4] + 256 * s[5],
                "expiries": s[6],
                "held": s[3],
                "guards": d[12:],
            }

        def observe(stage: str) -> dict[str, Any]:
            state = read()
            image = out / f"{variant}-{stage}.png"
            machine.call("save_screenshot", path=str(image))
            samples.append(
                {
                    "stage": stage,
                    "frames": frames_total,
                    **state,
                    "image": image.name,
                    "image_sha256": T.sha(image),
                }
            )
            return state

        if variant in ("boundaries", "wrong-boundary"):
            frames(20)
            data = machine.call("memory_read", addr=0x2E00, len=121)["bytes"]
            T.require(
                len(data) == 121 and data[-1] == 239, "Arithmetic caller incomplete"
            )
            equal = data == V.expected_arithmetic()
            T.require(
                equal == (variant == "boundaries"),
                "Native arithmetic control disagrees",
            )
            image = out / f"{variant}.png"
            machine.call("save_screenshot", path=str(image))
            result = {
                "bytes": data,
                "oracle_matches": equal,
                "image": image.name,
                "image_sha256": T.sha(image),
            }
        else:
            frames(10)
            idle = observe("idle")
            frames(30)
            after = observe("idle-after")
            T.require(
                idle["turns"] == after["turns"] == 0
                and idle["active"] == after["active"] == 0,
                "Untimed idle advanced",
            )
            ticks = (after["clock"] - idle["clock"]) % 65536
            T.require(58 <= ticks <= 62, f"Not centisecond clock: {ticks} in 30 fields")
            tap("space")
            action = observe("untimed-action")
            T.require(
                action["turns"] == 1 and action["active"] == 0,
                "Untimed action started clock",
            )
            tap("t")
            start = observe("enabled")
            frames(20)
            running = observe("progress")
            T.require(
                start["active"] == running["active"] == 1 and running["turns"] == 1,
                "Timer did not enable",
            )
            T.require(
                start["remaining"] - running["remaining"]
                == (running["clock"] - start["clock"]) % 65536,
                "Clock/countdown disagree",
            )
            frames(210 if variant != "custom-duration" else 110)
            expiry = observe("expiry")
            wrong = variant == "wrong-input-gate"
            T.require(
                (expiry["turns"], expiry["expiries"], expiry["active"])
                == ((1, 0, 0) if wrong else (2, 1, 1)),
                f"No-input expiry wrong: {expiry}",
            )
            if not wrong:
                tap("space")
                restart = observe("restart")
                T.require(
                    restart["turns"] == 3
                    and restart["remaining"] > restart["duration"] // 2,
                    "No restart",
                )
                key("space", True)
                held = observe("held-start")
                frames(20)
                held_after = observe("held-after")
                T.require(held_after["turns"] == held["turns"], "Held key repeated")
                key("space", False)
                tap("t")
                stopped = observe("disabled")
                frames(240)
                stopped_after = observe("disabled-after")
                T.require(
                    stopped["active"] == stopped_after["active"] == 0
                    and stopped["turns"] == stopped_after["turns"],
                    "Disabled timer advanced",
                )
            result = {"samples": samples, "ticks_in_30_fields": ticks}
        return {
            **metrics,
            **result,
            "server": machine.server["serverInfo"],
            "emulator_sha256": T.sha(exe),
            "firmware_sha256": {n: T.sha(rom / n) for n in ["os.rom", "basic.rom"]},
        }
    finally:
        machine.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--tools", type=Path, required=True)
    p.add_argument("--firmware", type=Path, required=True)
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument("--systems", default=",".join(SYSTEMS))
    p.add_argument("--variants", default=",".join(VARIANTS))
    a = p.parse_args()
    for system in a.systems.split(","):
        T.require(system in SYSTEMS, "Unknown system")
        out = (
            ROOT
            / system
            / "patterns/assembly/framework/turn-deadline/verification/results.json"
        )
        r = (
            json.loads(out.read_text())
            if out.exists()
            else {
                "status": "native-checked",
                "machine": system,
                "language": "assembly",
                "cases": {},
            }
        )
        for variant in a.variants.split(","):
            T.require(variant in VARIANTS, "Unknown variant")
            r["cases"][variant] = execute(system, variant, a)
            r["sources"] = {str(f.relative_to(ROOT)): T.sha(f) for f in source_paths()}
            r["assembler_sha256"] = T.sha(a.assembler)
            out.write_text(json.dumps(r, indent=2) + "\n")
            print(system, variant, "passed", flush=True)


if __name__ == "__main__":
    main()
