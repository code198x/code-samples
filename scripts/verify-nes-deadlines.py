"""Run real NMI-clock turns plus independent guest-owned arithmetic/policy callers."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    if spec is None or spec.loader is None:
        raise RuntimeError(file)
    v = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(v)
    return v


T = module("transport", "verify-game-loops.py")
A = module("vectors", "verify-firmware-deadlines.py")
F = ROOT / "nintendo-entertainment-system/patterns/assembly/framework/turn-deadline"
V = F / "verification"
VARIANTS = ("demo", "custom", "wrong", "repaired", "boundaries", "wrong-boundary")
BUTTONS = ("a", "b", "select", "start", "up", "down", "left", "right")


def source_paths():
    return [
        F / n
        for n in (
            "demo.asm",
            "custom.asm",
            "wrong.asm",
            "repaired.asm",
            "caller.inc",
            "clock.inc",
            "Makefile",
            "../game-loop/frame.inc",
            "../input-to-sound/input.inc",
            "../input-to-sound/presses.inc",
            "../../input/controller-reading/edges-font.inc",
        )
    ] + [
        ROOT / "bbc-micro/patterns/assembly/framework/turn-deadline/dispatch.inc",
        ROOT / "cross-platform/patterns/framework/elapsed-deadline/6502.inc",
        Path(__file__),
        ROOT / "scripts/verify-game-loops.py",
        ROOT / "scripts/verify-firmware-deadlines.py",
    ]


def expected_math():
    out = []
    for duration, previous, now in A.CASES:
        elapsed = (now - previous) % 65536
        expired = int(duration > 0 and elapsed >= duration)
        left = max(0, duration - elapsed) if duration else 0
        out += [
            expired,
            int(duration > 0 and not expired),
            left % 256,
            left // 256,
            elapsed % 256,
            elapsed // 256,
            now % 256,
            now // 256,
        ]
    return out


def expected_policy():
    out = []
    for expired in (0, 1):
        for active in (0, 1):
            for command in range(4):
                turn = timeout = 0
                left = 90 if active else 0
                if expired:
                    turn = timeout = 1
                    on = 1
                    left = 180
                elif command & 2:
                    on = 1 - active
                    left = 180 if on else 0
                elif command & 1:
                    turn = 1
                    on = active
                    left = 180 if active else 0
                else:
                    on = active
                out += [turn, 0, timeout, on, left % 256, left // 256]
    return out


def fixture(wrong):
    math_count = len(expected_math())
    policy_count = len(expected_policy())
    length = math_count + policy_count + 2
    text = f""".segment "HEADER"
    .byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
.segment "BSS"
DEADLINE: .res 12
STATE: .res 10
output: .res {length}
.segment "CODE"
reset:
    sei
    cld
    ldx #$ff
    txs
    lda #0
    sta $2000
    sta $2001
    sta $4010
    sta $4015
    lda #$40
    sta $4017
    lda #165
    sta output
"""

    def word(value, field):
        return f"    lda #{value % 256}\n    sta {field}\n    lda #{value // 256}\n    sta {field}+1\n"

    def sample(value):
        return f"    lda #{value % 256}\n    ldx #{value // 256}\n"

    for i, (duration, previous, now) in enumerate(A.CASES):
        text += (
            word(duration, "DEADLINE")
            + sample(previous)
            + "    jsr deadline_init\n    jsr deadline_start\n"
            + sample(now)
            + "    jsr POLL_ROUTINE\n"
        )
        for offset, field in enumerate(
            (
                "DEADLINE+5",
                "DEADLINE+4",
                "DEADLINE+2",
                "DEADLINE+3",
                "DEADLINE+6",
                "DEADLINE+7",
                "DEADLINE+8",
                "DEADLINE+9",
            )
        ):
            text += f"    lda {field}\n    sta output+{1 + i * 8 + offset}\n"
    index = 0
    for expired in (0, 1):
        for active in (0, 1):
            for command in range(4):
                text += "    lda #0\n    ldx #9\n"
                label = "clear_state_" + str(index)
                text += f"{label}:\n    sta STATE,x\n    dex\n    bpl {label}\n"
                text += word(180, "DEADLINE") + word(90 if active else 0, "DEADLINE+2")
                text += f"    lda #{active}\n    sta DEADLINE+4\n    lda #{expired}\n    sta DEADLINE+5\n    lda #{command}\n    sta STATE+8\n    jsr dispatch\n"
                for offset, field in enumerate(
                    (
                        "STATE+4",
                        "STATE+5",
                        "STATE+6",
                        "DEADLINE+4",
                        "DEADLINE+2",
                        "DEADLINE+3",
                    )
                ):
                    text += f"    lda {field}\n    sta output+{1 + math_count + index * 6 + offset}\n"
                index += 1
    text += f"""    lda #239
    sta output+{length - 1}
hold: jmp hold
commit_turn:
    inc STATE+4
    bne turn_committed
    inc STATE+5
turn_committed:
    inc STATE+7
    rts
nmi:
irq:
    rti
"""
    text += (
        ROOT / "bbc-micro/patterns/assembly/framework/turn-deadline/dispatch.inc"
    ).read_text()
    text += (
        ROOT / "cross-platform/patterns/framework/elapsed-deadline/6502.inc"
    ).read_text()
    text += (
        "POLL_ROUTINE:\n"
        + ("    sta DEADLINE+8\n    stx DEADLINE+9\n" if wrong else "")
        + '    jmp deadline_poll\ncode_end:\n.segment "VECTORS"\n    .word nmi,reset,irq\n.segment "CHARS"\n    .res 8192,0\n'
    )
    return text


def run(args, name):
    B = F / "build" / name
    B.mkdir(exist_ok=True, parents=True)
    source = (
        fixture(name == "wrong-boundary")
        if "boundar" in name
        else (F / (name + ".asm")).read_text()
    )
    (B / "demo.asm").write_text(source)
    subprocess.run(
        [
            str(args.assembler),
            "--dialect",
            "ca65",
            "-I",
            str(F),
            "--sym",
            str(B / "demo.asm"),
            "-o",
            str(B / "demo.nes"),
        ],
        check=True,
        capture_output=True,
        timeout=30,
    )
    sym = T.symbols(B / "demo.sym")
    cart = (B / "demo.nes").read_bytes()
    T.require(len(cart) == 40976, "Wrong NROM layout")
    m = T.Machine(
        [str(args.emulator), "--mcp", "--rom", str(B / "demo.nes"), "--region", "ntsc"]
    )

    def read(addr, n):
        return [
            b
            for i in range(0, n, 128)
            for b in m.call("memory_read", addr=addr + i, len=min(128, n - i))["bytes"]
        ]

    def advance(n):
        for i in range(0, n, 100):
            count = min(100, n - i)
            r = m.call("run_frames", frames=count)
            T.require(
                r["frames"] == count and r["stop_reason"] == "ReachedTarget",
                "Incomplete native frame run",
            )

    samples = []

    def observe(mask, stage, extra=2):
        events = [
            {"Button": {"port": 1, "name": button, "pressed": bool(mask & (128 >> i))}}
            for i, button in enumerate(BUTTONS)
        ]
        m.call("input", events=events)
        advance(extra)
        start = m.call("run_until_pc", addr=sym["main_loop"], max_steps=150000)
        stop = m.call("run_until_pc", addr=sym["frame_done"], max_steps=150000)
        T.require(start["reached"] and stop["reached"], "Turn frame did not complete")
        state = read(sym["STATE"], 10)
        dl = read(sym["DEADLINE"], 12)
        clock = read(sym["frame_clock"], 1)[0] + 256 * read(sym["frame_high"], 1)[0]
        s = {
            "stage": stage,
            "input": mask,
            "state": state,
            "deadline": dl,
            "clock": clock,
            "controls": read(sym["controls"], 1)[0],
            "display": read(sym["display_row"], 8),
            "stop": stop,
        }
        T.require(s["controls"] == mask, "Native serial input differs")
        samples.append(s)
        print(name, stage, state, dl, clock, flush=True)
        return s

    try:
        if "boundar" in name:
            stop = m.call("run_until_pc", addr=sym["hold"], max_steps=500000)
            T.require(stop["reached"], "Fixture did not complete")
            raw = read(sym["output"], len(expected_math()) + len(expected_policy()) + 2)
            T.require(raw[0] == 165 and raw[-1] == 239, "No fixture guards")
            math = raw[1 : 1 + len(expected_math())]
            policy = raw[1 + len(expected_math()) : -1]
            T.require(
                (math == expected_math()) == (name == "boundaries")
                and policy == expected_policy(),
                "Independent arithmetic/policy oracle differs",
            )
            result = {
                "bytes": raw,
                "stop": stop,
                "math_matches": math == expected_math(),
                "policy_matches": True,
            }
        else:
            advance(30)
            T.require(read(sym["ready"], 1) == [165], "Caller did not start")
            initial = observe(0, "untimed-initial")
            advance(30)
            idle = observe(0, "untimed-idle")
            T.require(
                idle["state"][4:7] == initial["state"][4:7] == [0, 0, 0]
                and idle["clock"] != initial["clock"],
                "Untimed game advanced/clock stopped",
            )
            press = observe(128, "first-action")
            advance(30)
            held = observe(128, "held-action")
            T.require(
                press["state"][4:6] == held["state"][4:6] == [1, 0],
                "Held A repeated a turn",
            )
            observe(0, "release-action")
            second = observe(128, "second-action")
            T.require(second["state"][4] == 2, "Second press missing")
            observe(0, "release-second")
            enabled = observe(32, "enable")
            advance(10)
            on_hold = observe(32, "held-select")
            T.require(
                enabled["deadline"][4] == on_hold["deadline"][4] == 1,
                "Select repeated/timer not enabled",
            )
            observe(0, "release-select")
            observe(128, "renew-action")
            observe(0, "release-renew")
            before = observe(64, "slow-start")
            duration = 60 if name == "custom" else 180
            advance(duration + 30)
            slow = observe(64, "slow-expiry")
            ticks = (slow["clock"] - before["clock"]) % 65536
            updates = (
                int.from_bytes(bytes(slow["state"][:2]), "little")
                - int.from_bytes(bytes(before["state"][:2]), "little")
            ) % 65536
            fast_ticks = (idle["clock"] - initial["clock"]) % 65536
            fast_updates = (
                int.from_bytes(bytes(idle["state"][:2]), "little")
                - int.from_bytes(bytes(initial["state"][:2]), "little")
            ) % 65536
            T.require(
                fast_ticks > 0
                and fast_updates > 0
                and updates > 0
                and ticks > duration
                and ticks * fast_updates > fast_ticks * updates,
                "Slow work did not cost more ticks per update than the measured fast path",
            )
            if name == "wrong":
                T.require(
                    slow["state"][6] == 0 and slow["deadline"][2:4] == [180, 0],
                    "Missing reset-baseline symptom",
                )
            else:
                T.require(
                    slow["state"][6] > before["state"][6],
                    "Timer stopped during game work",
                )
            observe(0, "end-slow")
            observe(128, "renew-before-disable")
            observe(0, "release-before-disable")
            disabled = observe(32, "disable")
            T.require(disabled["deadline"][4] == 0, "Timer did not disable")
            observe(0, "release-disable")
            advance(duration + 30)
            off = observe(0, "disabled-idle")
            T.require(
                off["state"][4:7] == disabled["state"][4:7] and off["deadline"][4] == 0,
                "Disabled timer advanced",
            )
            observe(32, "reenable")
            observe(0, "release-reenable")
            advance(duration + 30)
            expired = observe(0, "second-expiry")
            if name != "wrong":
                T.require(
                    expired["state"][6] > off["state"][6], "Reenabled deadline failed"
                )
            final = observe(16, "freeze-display", extra=4)
            advance(3)
            display = read(sym["display_row"], 8)
            T.require(
                display == final["display"], "Start did not freeze only the display"
            )
            frozen_clock_after = (
                read(sym["frame_clock"], 1)[0] + 256 * read(sym["frame_high"], 1)[0]
            )
            frozen_deadline_after = read(sym["DEADLINE"], 12)
            T.require(
                0 < (frozen_clock_after - final["clock"]) % 65536 < 256
                and frozen_deadline_after[8:10] != final["deadline"][8:10],
                "Display freeze stopped clock/deadline service",
            )
            T.require(
                read(sym["frame_high"], 1)[0] > 0,
                "Clock high-byte carry was not exercised",
            )
            image = V / (name + ".png")
            m.call("save_screenshot", path=str(image))
            result = {
                "samples": samples,
                "capture": final,
                "display": display,
                "frozen_clock_after": frozen_clock_after,
                "frozen_deadline_after": frozen_deadline_after,
                "slow_ticks": ticks,
                "slow_updates": updates,
                "fast_ticks": fast_ticks,
                "fast_updates": fast_updates,
                "image": image.name,
                "image_sha256": T.sha(image),
                "caller_state_bytes": sym["caller_state_end"] - sym["DEADLINE"],
                "clock_code_bytes": sym["read_clock_end"] - sym["clock_tick"],
                "clock_state_bytes": 5,
                "deadline_code_bytes": sym["deadline_code_end"] - sym["deadline_init"],
                "deadline_state_bytes": 12,
                "code_prefix_bytes": sym["code_end"] - sym["reset"],
                "font_bytes": 272,
            }
        loaded = read(32768, 32768)
        T.require(bytes(loaded) == cart[16:32784], "Native immutable PRG ROM differs")
        return result | {
            "source_sha256": hashlib.sha256(source.encode()).hexdigest(),
            "cartridge_sha256": T.sha(B / "demo.nes"),
            "loaded_prg_sha256": hashlib.sha256(bytes(loaded)).hexdigest(),
            "loaded_prg_bytes": loaded,
            "server": m.server["serverInfo"],
        }
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for n in ("assembler", "emulator"):
        p.add_argument("--" + n, type=Path, required=True)
    p.add_argument("--variants", default=",".join(VARIANTS))
    args = p.parse_args()
    V.mkdir(exist_ok=True)
    cfg = {
        "model": "NES NTSC NROM-256, original CHR font, DMC disabled, NMI 16-bit frame clock",
        "assembler_sha256": T.sha(args.assembler),
        "emulator_sha256": T.sha(args.emulator),
    }
    (V / "configuration.json").write_text(json.dumps(cfg, indent=2) + "\n")
    target = V / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"system": "nintendo-nes", "language": "assembly", "cases": {}}
    )
    r.update(
        configuration=cfg,
        sources={str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
    )
    for name in args.variants.split(","):
        T.require(name in VARIANTS, "Unknown case")
        r["cases"][name] = run(args, name)
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(name, "passed", flush=True)


if __name__ == "__main__":
    main()
