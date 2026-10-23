"""Execute Jupiter Ace Z80 deadlines through a generated FORTH keyboard loader."""

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
PIX = module("ace_pixels", "verify-ace-deadline.py")
F = ROOT / "jupiter-ace/patterns/assembly/framework/turn-deadline"
VARIANTS = ("working", "custom", "wrong", "repaired", "boundaries", "wrong-boundary")


def source_paths():
    return [
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
    ] + [
        ROOT / "cross-platform/patterns/framework/elapsed-deadline/z80.inc",
        Path(__file__),
        ROOT / "scripts/verify-dragon-basic-deadlines.py",
        ROOT / "scripts/verify-basic-deadlines.py",
        ROOT / "scripts/verify-game-loops.py",
        ROOT / "scripts/verify-ace-deadline.py",
        ROOT / "scripts/check-amiga-command-loops.py",
    ]


def command(args):
    exe = args.tools / "emu198x-jupiter-ace-aarch64-apple-darwin/emu198x-jupiter-ace"
    rom = args.firmware / "jupiter-ace/ace.rom"
    return [str(exe), "--mcp", "--rom", str(rom)], exe, rom


def fixture(wrong=False):
    helper = (
        ROOT / "cross-platform/patterns/framework/elapsed-deadline/z80.inc"
    ).read_text()
    if wrong:
        helper = helper.replace("    jr z,deadline_expired\n", "")
    text = """    org $3D00
start:
    push bc
    push de
    push hl
    ld ix,cases
    ld bc,output
    ld a,165
    ld (bc),a
    inc bc
    ld a,12
    ld (count),a
fixture_next:
    ld l,(ix+0)
    ld h,(ix+1)
    ld (DEADLINE),hl
    ld l,(ix+2)
    ld h,(ix+3)
    call deadline_init
    call deadline_start
    ld l,(ix+4)
    ld h,(ix+5)
    call deadline_poll
    ld de,6
    add ix,de
    ld de,DEADLINE+2
    ld a,8
    ld (copy_count),a
fixture_copy:
    ld a,(de)
    ld (bc),a
    inc de
    inc bc
    ld hl,copy_count
    dec (hl)
    jr nz,fixture_copy
    ld hl,count
    dec (hl)
    jr nz,fixture_next
; Controlled simultaneous-command cases, separate from real keyboard timing.
    xor a
    ld (TURN),a
    ld (EXPIRIES),a
    inc a
    ld (DEADLINE+5),a
    ld (KEY),a
    call dispatch
    ld a,(TURN)
    ld (bc),a
    inc bc
    ld a,(EXPIRIES)
    ld (bc),a
    inc bc
    ld a,2
    ld (KEY),a
    ld a,1
    ld (DEADLINE+5),a
    call dispatch
    ld a,(TURN)
    ld (bc),a
    inc bc
    ld a,(DEADLINE+4)
    ld (bc),a
    inc bc
    xor a
    ld (DEADLINE+5),a
    ld (DEADLINE+4),a
    inc a
    ld (KEY),a
    call dispatch
    ld a,(TURN)
    ld (bc),a
    inc bc
    ld a,(DEADLINE+4)
    ld (bc),a
    inc bc
    ld a,90
    ld (bc),a
    inc bc
    ld a,239
    ld (bc),a
    pop hl
    pop de
    pop bc
    jp (iy)
"""
    # IX is restored around native execution just like the ROM expects.
    text = text.replace("    push bc\n", "    push ix\n    push bc\n", 1).replace(
        "    jp (iy)", "    pop ix\n    jp (iy)"
    )
    text += (
        helper
        + (F / "dispatch.inc").read_text()
        + "count: db 0\ncopy_count: db 0\nTURN: db 0\nEXPIRIES: db 0\nKEY: db 0\nDEADLINE: defs 10,0\ncases:\n"
    )
    text += "".join("    dw " + ",".join(map(str, c)) + "\n" for c in B.CASES)
    return text + "output: defs 105,0\ncode_end:\n"


def expected_fixture():
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
            "pasmo",
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
    T.require(0 < len(data) < 600, "Payload overlaps caller state")
    spec = importlib.util.spec_from_file_location("loader", F / "loader.py")
    loader = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(loader)
    lines = loader.listing(data)
    (out / "load.fth").write_text("\n".join(lines) + "\n")
    return out, data, lines


def run(args, variant):
    out, data, lines = build(args.assembler, variant)
    cmd, _exe, _rom = command(args)
    symbols = T.symbols(out / "demo.sym")
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
        raw = read(symbols["TURN"], 14)
        sample = {
            "stage": stage,
            "frames": frames,
            "raw": raw,
            "turn": raw[0],
            "expiries": raw[1],
            "active": raw[8],
            "remaining": int.from_bytes(bytes(raw[6:8]), "little"),
            "clock": int.from_bytes(bytes(raw[12:14]), "little"),
            "cpu": m.call("query_cpu")["registers"],
            "workspace": read(0x3C37, 6),
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
        loader_steps = []
        for index, line in enumerate(lines[:-1]):
            result = m.call(
                "type_string", text=line + "\n", hold_frames=3, settle_frames=8
            )
            T.require(
                result["chars_typed"] == len(line) + 1,
                "Incomplete injected keyboard text",
            )
            # Type completion is not interpreter completion: inspect native HERE
            # and the consumed data stack before injecting the next FORTH line.
            expected = (
                15616 + min(max(index - 3, 0) * 8, len(data)) if index >= 3 else None
            )
            if expected is not None:
                for waited in range(201):
                    pointers = read(0x3C37, 6)
                    here = int.from_bytes(bytes(pointers[:2]), "little")
                    spare = int.from_bytes(bytes(pointers[4:6]), "little")
                    if here == expected and spare == here + 12:
                        break
                    T.require(
                        here <= expected,
                        "FORTH dictionary advanced beyond intended data",
                    )
                    advance(1)
                T.require(
                    here == expected and spare == here + 12,
                    "FORTH failed to finish loader line",
                )
                prefix = []
                for offset in range(0, expected - 15616, 128):
                    prefix += read(15616 + offset, min(128, expected - 15616 - offset))
                T.require(
                    bytes(prefix) == data[: expected - 15616],
                    "Compiled prefix differs before next loader line",
                )
                loader_steps.append(
                    {
                        "line": index,
                        "waited_frames": waited,
                        "here": here,
                        "spare": spare,
                        "compiled_bytes": len(prefix),
                    }
                )
            advance(8)
        for _ in range(100):
            advance(10)
            loaded = []
            for offset in range(0, len(data), 128):
                loaded += read(0x3D00 + offset, min(128, len(data) - offset))
            if bytes(loaded) == data:
                break
        T.require(
            bytes(loaded) == data,
            "Loaded Z80 code differs after bounded loader completion",
        )
        result = m.call(
            "type_string", text=lines[-1] + "\n", hold_frames=3, settle_frames=8
        )
        T.require(result["chars_typed"] == len(lines[-1]) + 1, "Incomplete EXEC")
        advance(10)
        if "boundar" in variant:
            for _ in range(100):
                advance(2)
                raw = read(symbols["output"], len(expected_fixture()))
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
            key("2")
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
                    and expired["remaining"] == 200,
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
            advance(2)
            m.call("save_screenshot", path=str(F / "verification" / (variant + ".png")))
            capture = PIX.capture_check(m, F / "verification" / (variant + ".png"))
            want = "01 00 01" if variant == "wrong" else "03 01 01"
            T.require(
                bytes.fromhex(capture["video_hex"])[:8] == want.encode(),
                "Status pixels are not the expected complete strip",
            )
            key("2")
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
                text=': CHECKBACK ." RETURNED " 2 3 + . ; CHECKBACK\n',
                hold_frames=3,
                settle_frames=8,
            )
            T.require(
                result["chars_typed"]
                == len(': CHECKBACK ." RETURNED " 2 3 + . ; CHECKBACK\n'),
                "Return check typing incomplete",
            )
            advance(30)
            screen = []
            for i in range(0, 768, 128):
                screen += read(0x2400 + i, 128)
            text = "".join(chr(v & 127) for v in screen)
            import re

            T.require(
                re.search(r"RETURNED\s*5", text, re.IGNORECASE),
                "No return to FORTH arithmetic",
            )
            result = {
                "samples": samples,
                "return_screen": screen,
                "exit_workspace": read(0x3C37, 6),
                "capture": capture,
            }
        image = F / "verification" / (variant + ".png")
        if "boundar" in variant:
            m.call("save_screenshot", path=str(image))
        return result | {
            "loaded_bytes": loaded,
            "loader_steps": loader_steps,
            "ram_top": int.from_bytes(bytes(read(0x3C18, 2)), "little"),
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
        else {"machine": "jupiter-ace", "language": "assembly", "cases": {}}
    )
    _cmd, exe, rom = command(args)
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
