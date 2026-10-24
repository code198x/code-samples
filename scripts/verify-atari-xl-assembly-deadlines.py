"""Type and run high-RAM Atari 800XL deadline callers under the normal OS."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, file: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    if spec is None or spec.loader is None:
        raise RuntimeError(file)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


T = module("transport", "verify-game-loops.py")
B = module("cases", "verify-dragon-basic-deadlines.py")
F = ROOT / "atari-800xl/patterns/assembly/framework/turn-deadline"
VARIANTS = ("working", "custom", "wrong", "repaired", "boundaries", "wrong-boundary")


def source_paths() -> list[Path]:
    return (
        [
            F / n
            for n in (
                "demo.asm",
                "customise.asm",
                "caller.inc",
                "clock.inc",
                "input.inc",
                "dispatch.inc",
                "mistakes/reset-baseline.asm",
                "mistakes/reset-baseline.inc",
                "Makefile",
                "loader.py",
            )
        ]
        + [
            ROOT / "cross-platform/patterns/framework/elapsed-deadline/6502.inc",
            Path(__file__),
        ]
        + [
            ROOT / "scripts" / n
            for n in (
                "verify-game-loops.py",
                "verify-dragon-basic-deadlines.py",
                "verify-basic-deadlines.py",
            )
        ]
    )


def expected_fixture() -> list[int]:
    out = [165]
    for duration, previous, now in B.CASES:
        elapsed = (now - previous) % 65536
        expired = int(duration > 0 and elapsed >= duration)
        remaining = max(0, duration - elapsed) if duration else 0
        out += (
            list(remaining.to_bytes(2, "little"))
            + [int(duration > 0 and not expired), expired]
            + list(elapsed.to_bytes(2, "little"))
            + list(now.to_bytes(2, "little"))
        )
    return out + [1, 1, 2, 1, 3, 0, 90, 239]


def fixture(wrong: bool = False) -> str:
    helper = (
        ROOT / "cross-platform/patterns/framework/elapsed-deadline/6502.inc"
    ).read_text()
    if wrong:
        changed = helper.replace("    bne deadline_done\n", "    beq deadline_done\n")
        T.require(changed != helper, "Missing wrong-equality mutation")
        helper = changed
    code = """* = $8000
TURN = $8300
EXPIRIES = $8301
KEY = $8302
DEADLINE = $8304
start:
    pla
    php
    txa
    pha
    tya
    pha
    cld
    lda #0
    sta case_index
    lda #1
    sta out_index
    lda #165
    sta output
fixture_next:
    ldx case_index
    lda cases,x
    sta DEADLINE
    lda cases+1,x
    sta DEADLINE+1
    lda cases+2,x
    sta now_temp
    lda cases+3,x
    tax
    lda now_temp
    jsr deadline_init
    jsr deadline_start
    ldx case_index
    lda cases+4,x
    sta now_temp
    lda cases+5,x
    tax
    lda now_temp
    jsr deadline_poll
    ldy #0
fixture_copy:
    lda DEADLINE+2,y
    ldx out_index
    sta output,x
    inc out_index
    iny
    cpy #8
    bne fixture_copy
    lda case_index
    clc
    adc #6
    sta case_index
    cmp #72
    bne fixture_next
    lda #0
    sta TURN
    sta EXPIRIES
    lda #1
    sta DEADLINE+5
    sta KEY
    jsr dispatch
    lda TURN
    sta output+97
    lda EXPIRIES
    sta output+98
    lda #1
    sta DEADLINE+5
    lda #2
    sta KEY
    jsr dispatch
    lda TURN
    sta output+99
    lda DEADLINE+4
    sta output+100
    lda #0
    sta DEADLINE+5
    sta DEADLINE+4
    lda #1
    sta KEY
    jsr dispatch
    lda TURN
    sta output+101
    lda DEADLINE+4
    sta output+102
    lda #90
    sta output+103
    lda #239
    sta output+104
    pla
    tay
    pla
    tax
    lda #0
    sta $d4
    sta $d5
    plp
    rts
"""
    code += helper + (F / "dispatch.inc").read_text()
    code += "case_index: !byte 0\nout_index: !byte 0\nnow_temp: !byte 0\ncases:\n"
    for case in B.CASES:
        code += "    !word " + ",".join(map(str, case)) + "\n"
    return (
        code
        + 'output: !fill 105,0\ncode_end:\n!if code_end > $8300 { !error "Fixture overlaps context" }\n'
    )


def build(assembler: Path, variant: str) -> tuple[Path, list[int], list[str]]:
    out = F / "build" / variant
    out.mkdir(parents=True, exist_ok=True)
    source = (
        fixture(variant == "wrong-boundary")
        if "boundar" in variant
        else (
            F
            / {"custom": "customise.asm", "wrong": "mistakes/reset-baseline.asm"}.get(
                variant, "demo.asm"
            )
        ).read_text()
    )
    (out / "demo.asm").write_text(source)
    subprocess.run(
        [
            str(assembler),
            "--dialect",
            "acme",
            "-I",
            str(F),
            "--sym",
            str(out / "demo.asm"),
            "-o",
            str(out / "demo.bin"),
        ],
        check=True,
        capture_output=True,
        timeout=30,
    )
    data = list((out / "demo.bin").read_bytes())
    T.require(0 < len(data) < 768, "Payload overlaps context")
    spec = importlib.util.spec_from_file_location("loader", F / "loader.py")
    if spec is None or spec.loader is None:
        raise RuntimeError("Missing maintained loader")
    loader = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(loader)
    lines = loader.listing(bytes(data))
    (out / "load.bas").write_text("\n".join(lines) + "\n")
    return out, data, lines


def screen(m: Any) -> dict[str, Any]:
    ptr = m.call("memory_read", addr=88, len=2)["bytes"]
    base = int.from_bytes(bytes(ptr), "little")
    raw = [
        byte
        for i in range(0, 960, 128)
        for byte in m.call("memory_read", addr=base + i, len=min(128, 960 - i))["bytes"]
    ]
    text = "".join(chr((c & 127) + 32) if (c & 127) < 64 else " " for c in raw)
    return {"base": base, "bytes": raw, "text": text}


def capture(m: Any, text: str) -> dict[str, Any]:
    s = screen(m)
    codes = [ord(c) - 32 for c in text]
    T.require(s["bytes"][:8] == codes, "Native text differs from state")
    font = m.call("memory_read", addr=756, len=1)["bytes"][0] * 256
    glyphs = {
        str(c): m.call("memory_read", addr=font + c * 8, len=8)["bytes"]
        for c in set(codes)
    }
    return {
        "screen_base": s["base"],
        "codes": codes,
        "text": text,
        "font_base": font,
        "glyphs": glyphs,
    }


def run(args: argparse.Namespace, variant: str) -> dict[str, Any]:
    out, data, lines = build(args.assembler, variant)
    sym = T.symbols(out / "demo.sym")
    m = T.Machine([str(args.emulator), "--mcp", "--rom-dir", str(args.firmware)])
    frames = 0
    samples = []

    def advance(n: int) -> None:
        nonlocal frames
        for i in range(0, n, 200):
            count = min(200, n - i)
            m.call("run_frames", frames=count)
            frames += count

    def read(addr: int, n: int) -> list[int]:
        return m.call("memory_read", addr=addr, len=n)["bytes"]

    def observe(stage: str) -> dict[str, Any]:
        stop = m.call("run_until_pc", addr=sym["main"], max_steps=100000)
        T.require(stop["reached"], "Main-loop observation point not reached")
        raw = read(0x8300, 20)
        T.require(raw[16:] == [254, 202, 165, 90], "State ownership guard changed")
        s = {
            "stage": stage,
            "frames": frames,
            "raw": raw[:16],
            "turn": raw[0],
            "expiries": raw[1],
            "active": raw[8],
            "remaining": int.from_bytes(bytes(raw[6:8]), "little"),
            "clock": int.from_bytes(bytes(raw[12:14]), "little"),
            "rtc_bytes": read(18, 3),
            "stop": stop,
        }
        samples.append(s)
        print(variant, stage, s, flush=True)
        return s

    def control(name: str, pressed: bool, n: int = 10) -> None:
        event = (
            {"Button": {"port": 1, "name": "fire", "pressed": pressed}}
            if name == "fire"
            else {"Key": {"name": name, "pressed": pressed}}
        )
        m.call("input", events=[event])
        advance(n)

    def tap(name: str) -> None:
        control(name, True)
        control(name, False)

    try:
        advance(900)
        for line in lines[:-1]:
            reply = m.call("type_string", text=line + "\n", settle_frames=60)
            T.require(
                reply["chars_typed"] == len(line) + 1, "Incomplete keyboard loader"
            )
        for _ in range(100):
            advance(10)
            loaded = [
                byte
                for i in range(0, len(data), 128)
                for byte in read(32768 + i, min(128, len(data) - i))
            ]
            if loaded == data:
                break
        T.require(loaded == data, "Loaded bytes differ before USR")
        # The last POKE can finish before NEXT/END returns to the editor.
        # GRAPHICS 0 cleared the old prompt when RUN began: require the new
        # final READY, not an input acknowledgement or just completed bytes.
        for _ in range(100):
            loader_ready = screen(m)
            rows = [
                loader_ready["text"][i : i + 40].strip()
                for i in range(0, 960, 40)
                if loader_ready["text"][i : i + 40].strip()
            ]
            if rows and rows[-1] == "READY":
                break
            advance(2)
        T.require(rows and rows[-1] == "READY", "BASIC loader did not return READY")
        advance(4)
        reservation = {
            "ramtop": read(106, 1),
            "memtop": read(741, 2),
            "savmsc": read(88, 2),
        }
        T.require(
            reservation["ramtop"] == [124]
            and int.from_bytes(bytes(reservation["memtop"]), "little") < 31744
            and int.from_bytes(bytes(reservation["savmsc"]), "little") < 31744,
            "High-RAM reservation failed",
        )
        reply = m.call("type_string", text=lines[-1] + "\n", settle_frames=60)
        T.require(reply["chars_typed"] == len(lines[-1]) + 1, "Incomplete USR command")
        if "boundar" in variant:
            for _ in range(100):
                advance(2)
                raw = read(sym["output"], 105)
                if raw[0] == 165 and raw[-2:] == [90, 239]:
                    break
            T.require(raw[0] == 165 and raw[-2:] == [90, 239], "Fixture incomplete")
            T.require(
                (raw == expected_fixture()) == (variant == "boundaries"),
                "Native unsigned oracle mismatch",
            )
            result = {"bytes": raw, "oracle_matches": raw == expected_fixture()}
        else:
            first = observe("initial")
            advance(60)
            idle = observe("untimed-idle")
            T.require(
                first["turn"] == idle["turn"] == 0 and first["clock"] != idle["clock"],
                "Untimed idle/clock",
            )
            control("fire", True, 60)
            control("fire", False)
            action = observe("untimed-action")
            T.require(
                action["turn"] == 1 and action["active"] == 0, "Held action repeated"
            )
            tap("select")
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
                    0 < progress["remaining"] < enabled["remaining"], "No countdown"
                )
                tap("fire")
                restart = observe("action-restarts")
                T.require(
                    restart["turn"] == 2
                    and restart["remaining"] > progress["remaining"],
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
            advance(2)
            cap = capture(
                m,
                f"{expired['turn']:02X} {expired['expiries']:02X} {expired['active']:02X}",
            )
            image = F / "verification" / (variant + ".png")
            m.call("save_screenshot", path=str(image))
            tap("select")
            disabled = observe("disabled")
            advance(250)
            stopped = observe("disabled-idle")
            T.require(
                not stopped["active"] and stopped["turn"] == disabled["turn"],
                "Disable failed",
            )
            tap("option")
            advance(60)
            result = {"samples": samples, "capture": cap}
        # The loader's USR result must be zero, and the interpreter must still work.
        command = 'PRINT "RETURNED";2+3;" USR";X\n'
        reply = m.call("type_string", text=command, settle_frames=60)
        T.require(reply["chars_typed"] == len(command), "Return typing incomplete")
        advance(60)
        ret = screen(m)
        T.require(
            re.search(r"RETURNED\s*5\s*USR\s*0", ret["text"]) is not None,
            "No balanced return with USR result zero",
        )
        image = F / "verification" / (variant + ".png")
        if "boundar" in variant:
            m.call("save_screenshot", path=str(image))
        return result | {
            "loader_ready": loader_ready,
            "return_screen": ret,
            "reservation": reservation,
            "loaded_bytes": loaded,
            "loaded_sha256": hashlib.sha256(bytes(data)).hexdigest(),
            "entered_source_sha256": T.sha(out / "demo.asm"),
            "loader_sha256": T.sha(out / "load.bas"),
            "server": m.server["serverInfo"],
            "image": image.name,
            "image_sha256": T.sha(image),
        }
    except Exception:
        m.call("save_screenshot", path=str(F / "verification/diagnostic.png"))
        raise
    finally:
        m.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument("--emulator", type=Path, required=True)
    p.add_argument("--firmware", type=Path, required=True)
    p.add_argument("--variants", default=",".join(VARIANTS))
    args = p.parse_args()
    out = F / "verification"
    out.mkdir(parents=True, exist_ok=True)
    target = out / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"machine": "atari-800xl", "language": "assembly", "cases": {}}
    )
    for v in args.variants.split(","):
        T.require(v in VARIANTS, "Unknown variant")
        r["cases"][v] = run(args, v)
        r.update(
            sources={str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
            emulator_sha256=T.sha(args.emulator),
            assembler_sha256=T.sha(args.assembler),
            firmware_sha256={
                n: T.sha(args.firmware / n) for n in ["atarixl.rom", "ataribas.rom"]
            },
        )
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(v, "passed", flush=True)


if __name__ == "__main__":
    main()
