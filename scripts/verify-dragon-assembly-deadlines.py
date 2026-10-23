"""Execute Dragon 6809 deadlines through a generated BASIC keyboard loader."""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


T = module("transport", "verify-game-loops.py")
B = module("basic", "verify-dragon-basic-deadlines.py")
F = ROOT / "dragon-32/patterns/assembly/framework/turn-deadline"
VARIANTS = ("working", "custom", "wrong", "repaired", "boundaries", "wrong-boundary")


def source_paths():
    return [
        F / n
        for n in (
            "demo.asm",
            "customise.asm",
            "caller.inc",
            "clock.inc",
            "deadline.inc",
            "dispatch.inc",
            "mistakes/reset-baseline.asm",
            "mistakes/reset-baseline.inc",
            "Makefile",
        )
    ] + [
        Path(__file__),
        ROOT / "scripts/verify-dragon-basic-deadlines.py",
        ROOT / "scripts/verify-game-loops.py",
    ]


def fixture(wrong=False):
    helper = (F / "deadline.inc").read_text()
    if wrong:
        # Exact zero deliberately stays active; overshoot still expires.
        helper = helper.replace("    beq deadline_expired\n", "")
    text = """    org $7000
TURN equ $7200
EXPIRIES equ $7201
KEY equ $7202
start:
    pshs cc,dp,d,x,y,u
    ldu #cases
    ldy #$7301
    lda #165
    sta $7300
    lda #12
    sta $7203
fixture_next:
    ldx #$7210
    ldd ,u++
    std ,x
    ldd ,u++
    jsr deadline_init
    jsr deadline_start
    ldd ,u++
    jsr deadline_poll
    ldd 2,x
    std ,y++
    ldd 6,x
    std ,y++
    lda 4,x
    sta ,y+
    lda 5,x
    sta ,y+
    dec $7203
    bne fixture_next
; Three policy cases: simultaneous expiry+1, expiry+T, untimed 1.
    clr TURN
    clr EXPIRIES
    lda #1
    sta 5,x
    lda #'1'
    sta KEY
    jsr dispatch
    lda TURN
    sta ,y+
    lda EXPIRIES
    sta ,y+
    lda #'T'
    sta KEY
    lda #1
    sta 5,x
    jsr dispatch
    lda TURN
    sta ,y+
    lda 4,x
    sta ,y+
    clr 5,x
    clr 4,x
    lda #'1'
    sta KEY
    jsr dispatch
    lda TURN
    sta ,y+
    lda 4,x
    sta ,y+
    lda #90
    sta ,y+
    lda #239
    sta ,y
    puls cc,dp,d,x,y,u,pc
"""
    text += helper + (F / "dispatch.inc").read_text() + "cases:\n"
    text += "".join("    fdb " + ",".join(map(str, c)) + "\n" for c in B.CASES)
    return text


def expected_fixture():
    out = [165]
    for duration, previous, now in B.CASES:
        elapsed = (now - previous) % 65536
        expired = int(duration > 0 and elapsed >= duration)
        out += (
            list((max(0, duration - elapsed) if duration else 0).to_bytes(2, "big"))
            + list(elapsed.to_bytes(2, "big"))
            + [int(duration > 0 and not expired), expired]
        )
    return out + [1, 1, 2, 1, 3, 0, 90, 239]


def build(assembler, variant):
    out = F / "build" / variant
    out.mkdir(parents=True, exist_ok=True)
    text = (
        fixture(variant == "wrong-boundary")
        if "boundar" in variant
        else (
            F
            / (
                {"custom": "customise.asm", "wrong": "mistakes/reset-baseline.asm"}.get(
                    variant, "demo.asm"
                )
            )
        ).read_text()
    )
    (out / "demo.asm").write_text(text)
    subprocess.run(
        [
            str(assembler),
            "--dialect",
            "lwasm",
            "-I",
            str(F),
            "--sym",
            str(out / "demo.asm"),
            "-o",
            str(out / "demo.bin"),
        ],
        check=True,
        timeout=30,
        capture_output=True,
    )
    data = (out / "demo.bin").read_bytes()
    T.require(0 < len(data) < 512, "Payload overlaps caller state")
    lines = [
        "CLEAR 200,&H6FFF",
        f"10 FOR I=0 TO {len(data) - 1}:READ A:POKE &H7000+I,A:NEXT",
        "20 END",
    ]
    lines += [
        f"{100 + i} DATA " + ",".join(map(str, data[i : i + 16]))
        for i in range(0, len(data), 16)
    ]
    lines += ["RUN", "CLS:EXEC &H7000"]
    (out / "load.bas").write_text("\n".join(lines) + "\n")
    return out, data, lines


def run(args, variant):
    out, data, lines = build(args.assembler, variant)
    cmd, _exe, _rom = B.command("dragon-32", args)
    m = T.Machine(cmd)
    samples = []
    frames = 0

    def advance(n):
        nonlocal frames
        while n:
            step = min(200, n)
            m.call("run_frames", frames=step)
            frames += step
            n -= step

    def read(addr, n):
        return m.call("memory_read", addr=addr, len=n)["bytes"]

    def observe(stage):
        raw = read(0x7200, 28)
        sample = {
            "stage": stage,
            "frames": frames,
            "raw": raw,
            "turn": raw[0],
            "expiries": raw[1],
            "active": raw[20],
            "remaining": int.from_bytes(bytes(raw[18:20]), "big"),
            "clock": int.from_bytes(bytes(raw[24:26]), "big"),
        }
        samples.append(sample)
        print(variant, stage, sample, flush=True)
        return sample

    def key(name):
        m.call("input", events=[{"Key": {"name": name, "pressed": True}}])
        advance(3)
        m.call("input", events=[{"Key": {"name": name, "pressed": False}}])
        advance(8)

    try:
        advance(150)
        for line in lines[:-1]:
            result = m.call(
                "type_string", text=line + "\n", hold_frames=3, settle_frames=8
            )
            T.require(
                result["chars_typed"] == len(line) + 1, "Incomplete keyboard loader"
            )
        for _ in range(100):
            advance(10)
            loaded = []
            for offset in range(0, len(data), 128):
                loaded += read(0x7000 + offset, min(128, len(data) - offset))
            if bytes(loaded) == data:
                break
        T.require(
            bytes(loaded) == data,
            "Loaded 6809 code differs after bounded loader completion",
        )
        advance(5)
        result = m.call(
            "type_string", text=lines[-1] + "\n", hold_frames=3, settle_frames=8
        )
        T.require(result["chars_typed"] == len(lines[-1]) + 1, "Incomplete EXEC")
        advance(10)
        if "boundar" in variant:
            for _ in range(100):
                advance(2)
                raw = read(0x7300, len(expected_fixture()))
                if raw[0] == 165 and raw[-2:] == [90, 239]:
                    break
            T.require(raw[0] == 165 and raw[-2:] == [90, 239], "Fixture incomplete")
            T.require(
                (raw == expected_fixture()) == (variant == "boundaries"),
                "Native fixture/oracle mismatch",
            )
            result = {"bytes": raw, "oracle_matches": raw == expected_fixture()}
        else:
            first = observe("initial")
            advance(60)
            idle = observe("untimed-idle")
            T.require(
                first["turn"] == idle["turn"] == 0 and idle["clock"] != first["clock"],
                "Idle or clock wrong",
            )
            key("1")
            action = observe("untimed-action")
            T.require(action["turn"] == 1 and not action["active"], "Untimed action")
            key("t")
            enabled = observe("enabled")
            advance(30)
            progress = observe("idle-progress")
            T.require(enabled["active"] == progress["active"] == 1, "No active timer")
            if variant == "wrong":
                advance(300)
                expired = observe("wrong-never-expires")
                T.require(
                    expired["turn"] == 1
                    and expired["expiries"] == 0
                    and expired["remaining"] == 240,
                    "Baseline fault absent",
                )
            else:
                T.require(
                    progress["remaining"] < enabled["remaining"], "No elapsed time"
                )
                key("1")
                restarted = observe("action-restarts")
                T.require(
                    restarted["turn"] == 2
                    and restarted["remaining"] > progress["remaining"],
                    "Restart failed",
                )
                for _ in range(60):
                    advance(5)
                    expired = observe("await-expiry")
                    if expired["expiries"]:
                        break
                T.require(
                    expired["turn"] == 3 and expired["expiries"] == 1,
                    "Automatic turn failed",
                )
            m.call("save_screenshot", path=str(F / "verification" / (variant + ".png")))
            key("t")
            disabled = observe("disabled")
            advance(250)
            stopped = observe("disabled-idle")
            T.require(
                not stopped["active"] and stopped["turn"] == disabled["turn"],
                "Disable failed",
            )
            key("q")
            result = m.call(
                "type_string",
                text='PRINT "RETURNED";2+3\n',
                hold_frames=3,
                settle_frames=8,
            )
            T.require(result["chars_typed"] == 21, "Return check typing incomplete")
            advance(30)
            screen = []
            for i in range(0, 512, 128):
                screen += read(0x400 + i, 128)
            text = "".join(
                chr((v & 63) + 64) if (v & 63) < 32 else chr(v & 63) for v in screen
            )
            import re

            T.require(re.search(r"RETURNED\s*5", text), "No return to BASIC")
            result = {"samples": samples, "return_screen": screen}
        image = F / "verification" / (variant + ".png")
        if "boundar" in variant:
            m.call("save_screenshot", path=str(image))
        return result | {
            "loaded_bytes": loaded,
            "loaded_sha256": T.sha(out / "demo.bin"),
            "entered_source_sha256": T.sha(out / "demo.asm"),
            "server": m.server["serverInfo"],
            "image": image.name,
            "image_sha256": T.sha(image),
        }
    except Exception:
        m.call("save_screenshot", path=str(F / "verification/diagnostic.png"))
        raise
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument("--tools", type=Path, required=True)
    p.add_argument("--firmware", type=Path, required=True)
    p.add_argument("--variants", default=",".join(VARIANTS))
    args = p.parse_args()
    target = F / "verification/results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"machine": "dragon-32", "language": "assembly", "cases": {}}
    )
    _cmd, exe, rom = B.command("dragon-32", args)
    for variant in args.variants.split(","):
        T.require(variant in VARIANTS, "Unknown variant")
        r["cases"][variant] = run(args, variant)
        r.update(
            sources={str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
            emulator_sha256=T.sha(exe),
            firmware_sha256={rom.name: T.sha(rom)},
            assembler_sha256=T.sha(args.assembler),
        )
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(variant, "passed", flush=True)


if __name__ == "__main__":
    main()
