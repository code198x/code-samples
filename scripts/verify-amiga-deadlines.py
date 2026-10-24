"""Cold-boot optional Amiga turns, pure word arithmetic and IRQ-clock lifecycle."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
import zlib
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
N = module("vectors", "verify-nes-deadlines.py")
H = module("hunk", "verify-amiga-rectangle-overlap.py")
F = ROOT / "commodore-amiga/patterns/assembly/framework/turn-deadline"
V = F / "verification"
VARIANTS = (
    "demo",
    "custom",
    "wrong",
    "repaired",
    "boundaries",
    "wrong-boundary",
    "lifecycle",
)
BUTTONS = (("up", 256), ("down", 1), ("left", 512), ("right", 2), ("fire", 16))


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
            "policy.inc",
            "display.inc",
            "font.inc",
            "Makefile",
            "../input-to-sound/input.inc",
            "../../input/joystick-edge-detection/edges.inc",
        )
    ] + [
        ROOT / "cross-platform/patterns/framework/elapsed-deadline/m68000.inc",
        Path(__file__),
        ROOT / "scripts/verify-game-loops.py",
        ROOT / "scripts/verify-nes-deadlines.py",
        ROOT / "scripts/verify-firmware-deadlines.py",
        ROOT / "scripts/verify-amiga-rectangle-overlap.py",
        ROOT / "scripts/verify-c64-rectangle-overlap.py",
        ROOT / "cross-platform/patterns/physics/rectangle-overlap/cases.py",
    ]


def expected_math():
    return [
        [
            int(d > 0 and (n - p) % 65536 >= d),
            int(d > 0 and (n - p) % 65536 < d),
            max(0, d - (n - p) % 65536) if d else 0,
            (n - p) % 65536,
            n,
        ]
        for d, p, n in N.A.CASES
    ]


def expected_policy():
    old = N.expected_policy()
    return [
        [v[0] + 256 * v[1], v[2], v[3], v[4] + 256 * v[5]]
        for v in [old[i : i + 6] for i in range(0, len(old), 6)]
    ]


def fixture(wrong):
    count = sum(len(x) for x in expected_math() + expected_policy())
    size = count * 2 + 4
    text = "    section code,code_c\nstart:\n    move.w #$a55a,output\n"
    offset = 2
    for duration, previous, now in N.A.CASES:
        text += f"    lea deadline,a0\n    move.w #{duration},(a0)\n    move.w #{previous},d0\n    bsr deadline_init\n    bsr deadline_start\n    move.w #{now},d0\n    bsr POLL_ROUTINE\n"
        for field in (6, 4, 2, 8, 10):
            text += f"    move.w {field}(a0),output+{offset}\n"
            offset += 2
    for expired in (0, 1):
        for active in (0, 1):
            for command in range(4):
                mask = (16 if command & 1 else 0) | (256 if command & 2 else 0)
                text += f"    lea deadline,a0\n    move.w #180,(a0)\n    move.w #{90 if active else 0},2(a0)\n    move.w #{active},4(a0)\n    move.w #{expired},6(a0)\n    clr.w turns\n    clr.w expiries\n    move.w #{mask},pressed\n    bsr dispatch\n"
                for field in ("turns", "expiries", "deadline+4", "deadline+2"):
                    text += f"    move.w {field},output+{offset}\n"
                    offset += 2
    text += (
        f"""    move.w #$cafe,output+{size - 2}
    move.w #$cafe,ready
hold: bra hold
commit_turn:
    addq.w #1,turns
    rts
fixture_code_end:
signature: dc.b "198XAMIGACASES!",0
    even
ready: dc.w 0
turns: dc.w 0
expiries: dc.w 0
pressed: dc.w 0
deadline: dcb.w 7,0
output: dcb.b {size},0
    even
    include "policy.inc"
policy_code_end:
    include "../../../../../cross-platform/patterns/framework/elapsed-deadline/m68000.inc"
deadline_code_end:
POLL_ROUTINE:
"""
        + ("    move.w d0,10(a0)\n" if wrong else "")
        + "    bra deadline_poll\nprogram_end:\n"
    )
    return text


def lifecycle():
    return """    section code,code_c
start:
    lea $dff000,a5
    move.w #$7fff,$09a(a5)
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5)
    move.l $6c,original_vector
    bsr clock_stop
    move.w d0,output
    bsr clock_install
    move.w d0,output+2
    move.w #$c040,$09a(a5)
    bsr clock_install
    move.w d0,output+4
    move.w #$7fff,$09a(a5)
    move.w #$c000,$09a(a5)
    bsr clock_install
    move.w d0,output+6
    bsr clock_install
    move.w d0,output+8
    bsr read_clock
    move.w d0,output+10
    bsr wait_clock_frame
    bsr wait_clock_frame
    bsr wait_clock_frame
    bsr read_clock
    move.w d0,output+12
    bsr clock_stop
    move.w d0,output+14
    bsr read_clock
    move.w d0,output+16
    bsr clock_stop
    move.w d0,output+18
    move.w $01c(a5),output+20
    move.w clock_installed,output+22
    move.l $6c,restored_vector
    move.w #$cafe,ready
hold: bra hold
lifecycle_code_end:
signature: dc.b "198XAMIGACASES!",0
    even
ready: dc.w 0
original_vector: dc.l 0
restored_vector: dc.l 0
output: dcb.w 12,0
    include "clock.inc"
program_end:
"""


def build(args, name):
    B = F / "build/verification" / name
    B.mkdir(exist_ok=True, parents=True)
    src = (
        lifecycle()
        if name == "lifecycle"
        else fixture(name == "wrong-boundary")
        if "boundar" in name
        else (F / (name + ".asm")).read_text()
    )
    (B / "demo.asm").write_text(src)
    subprocess.run(
        [
            str(args.assembler),
            "--dialect",
            "vasm",
            "--exe",
            "-I",
            str(F),
            "--sym=" + str(B / "demo.sym"),
            str(B / "demo.asm"),
            "-o",
            str(B / "demo"),
        ],
        check=True,
        capture_output=True,
        timeout=30,
    )
    subprocess.run(
        [
            str(args.build198x),
            "adf",
            str(B / "demo"),
            "-o",
            str(B / "demo.adf"),
            "--name",
            "demo",
            "--volume",
            "Timers",
        ],
        check=True,
        capture_output=True,
        timeout=30,
    )
    return B, src


def run(args, name):
    B, src = build(args, name)
    sym = T.symbols(B / "demo.sym")
    exe = (B / "demo").read_bytes()
    body, relocs = H.hunk(exe)
    m = T.Machine(
        [
            str(args.emulator),
            "--mcp",
            "--model",
            "a500",
            "--kickstart",
            str(args.kickstart),
            "--disk",
            str(B / "demo.adf"),
        ]
    )

    def read(addr, n):
        return [
            b
            for i in range(0, n, 128)
            for b in m.call("memory_read", addr=addr + i, len=min(128, n - i))["bytes"]
        ]

    def words(addr, n):
        return [
            int.from_bytes(bytes(v), "big")
            for v in [read(addr + i * 2, 2) for i in range(n)]
        ]

    def field(n):
        return words(base + sym[n], 1)[0]

    def advance(n):
        for i in range(0, n, 100):
            frames = min(100, n - i)
            r = m.call("run_frames", frames=frames)
            T.require(
                r["frames"] == frames and r["stop_reason"] == "ReachedTarget",
                "Incomplete frame run",
            )

    samples = []

    def observe(mask, stage, extra=2):
        m.call(
            "input",
            events=[
                {"Button": {"port": 2, "name": n, "pressed": bool(mask & bit)}}
                for n, bit in BUTTONS
            ],
        )
        advance(extra)
        first = m.call("run_until_pc", addr=base + sym["main_loop"], max_steps=200000)
        stop = m.call("run_until_pc", addr=base + sym["frame_done"], max_steps=200000)
        T.require(first["reached"] and stop["reached"], "Update did not complete")
        s = {
            "stage": stage,
            "input": mask,
            "controls": field("controls"),
            "turns": field("turns"),
            "expiries": field("expiries"),
            "updates": field("updates"),
            "clock": field("clock_ticks"),
            "installed": field("clock_installed"),
            "deadline": words(base + sym["deadline"], 7),
            "display": words(base + sym["display_row"], 7),
            "stop": stop,
        }
        T.require(s["controls"] == mask, "Native joystick differs")
        samples.append(s)
        print(name, stage, s, flush=True)
        return s

    try:
        found = []
        tag = (
            b"198XAMIGATIMER!\0"
            if name in ("demo", "custom", "wrong", "repaired")
            else b"198XAMIGACASES!\0"
        )
        for _ in range(25):
            advance(100)
            scan = m.call("memory_scan", start=0, end=0x80000, value=0x31393858)
            T.require(not scan["truncated"], "Truncated marker scan")
            found = [
                int(h["addr"][1:], 16) - sym["signature"]
                for h in scan["hits"]
                if read(int(h["addr"][1:], 16), len(tag)) == list(tag)
                and read(int(h["addr"][1:], 16) - sym["signature"] + sym["ready"], 2)
                == [202, 254]
            ]
            if found:
                break
        T.require(len(found) == 1, "No unique completed cold-boot caller")
        base = found[0]
        if name == "lifecycle":
            raw = words(base + sym["output"], 12)
            original = read(base + sym["original_vector"], 4)
            restored = read(base + sym["restored_vector"], 4)
            T.require(
                raw[:5] == [0, 0, 0, 1, 0]
                and (raw[6] - raw[5]) % 65536 == 3
                and raw[7:] == [1, raw[6], 0, 16384, 0]
                and original == restored == read(0x6C, 4),
                "IRQ lifecycle/ownership differs",
            )
            before = field("clock_ticks")
            advance(50)
            after = field("clock_ticks")
            T.require(before == after == raw[8], "Stopped IRQ counter advanced")
            result = {
                "words": raw,
                "original_vector": original,
                "restored_vector": restored,
                "stopped_before": before,
                "stopped_after": after,
                "ready": field("ready"),
            }
            spans = [
                (0, sym["lifecycle_code_end"]),
                (sym["clock_install"], sym["clock_code_end"]),
            ]
        elif "boundar" in name:
            raw = words(
                base + sym["output"],
                2 + sum(len(v) for v in expected_math() + expected_policy()),
            )
            math = [v for row in expected_math() for v in row]
            policy = [v for row in expected_policy() for v in row]
            T.require(
                raw[0] == 0xA55A
                and raw[-1] == 0xCAFE
                and (raw[1 : 1 + len(math)] == math) == (name == "boundaries")
                and raw[1 + len(math) : -1] == policy,
                "Independent word math/policy oracle differs",
            )
            result = {
                "words": raw,
                "ready": field("ready"),
                "math_matches": name == "boundaries",
                "policy_matches": True,
            }
            spans = [
                (0, sym["fixture_code_end"]),
                (sym["dispatch"], sym["policy_code_end"]),
                (sym["deadline_init"], sym["deadline_code_end"]),
                (sym["POLL_ROUTINE"], sym["program_end"]),
            ]
        else:
            T.require(
                field("updates") > 3 and field("clock_installed") == 1,
                "IRQ clock game did not advance",
            )
            T.require(
                int.from_bytes(bytes(read(0x6C, 4)), "big")
                == base + sym["clock_handler"],
                "Wrong level3 vector owner",
            )
            tick_before = field("clock_ticks")
            advance(100)
            tick_after = field("clock_ticks")
            T.require(
                (tick_after - tick_before) % 65536 == 100,
                "Native 100-frame interval did not yield 100 IRQ ticks",
            )
            a = observe(0, "untimed-initial")
            advance(30)
            b = observe(0, "untimed-idle")
            T.require(
                a["turns"] == b["turns"] == a["expiries"] == b["expiries"] == 0
                and a["clock"] != b["clock"],
                "Untimed game/clock differs",
            )
            p = observe(16, "first-action")
            advance(30)
            h = observe(16, "held-action")
            T.require(p["turns"] == h["turns"] == 1, "Held fire repeated a turn")
            observe(0, "release-action")
            second = observe(16, "second-action")
            T.require(second["turns"] == 2, "Second press missing")
            observe(0, "release-second")
            e = observe(256, "enable")
            advance(10)
            held = observe(256, "held-toggle")
            T.require(
                e["deadline"][2] == held["deadline"][2] == 1,
                "Toggle repeated/not enabled",
            )
            observe(0, "release-toggle")
            observe(16, "renew-action")
            observe(0, "release-renew")
            slow_a = observe(2, "slow-start")
            duration = 50 if name == "custom" else 150
            advance(duration + 30)
            slow_b = observe(2, "slow-expiry")
            ticks = (slow_b["clock"] - slow_a["clock"]) % 65536
            updates = (slow_b["updates"] - slow_a["updates"]) % 65536
            fast_ticks = (b["clock"] - a["clock"]) % 65536
            fast_updates = (b["updates"] - a["updates"]) % 65536
            T.require(
                min(ticks, updates, fast_ticks, fast_updates) > 0
                and ticks > duration
                and ticks * fast_updates > fast_ticks * updates,
                "Busy work did not distinguish ticks/updates",
            )
            if name == "wrong":
                T.require(
                    slow_b["expiries"] == 0 and slow_b["deadline"][1] == 150,
                    "Missing baseline fault",
                )
            else:
                T.require(
                    slow_b["expiries"] > slow_a["expiries"],
                    "Timer stopped under game work",
                )
            observe(0, "end-slow")
            observe(16, "renew-before-disable")
            observe(0, "release-before-disable")
            off = observe(256, "disable")
            T.require(off["deadline"][2] == 0, "Timer did not disable")
            observe(0, "release-disable")
            advance(duration + 30)
            idle = observe(0, "disabled-idle")
            T.require(
                (idle["turns"], idle["expiries"], idle["deadline"][2])
                == (off["turns"], off["expiries"], 0),
                "Disabled deadline advanced",
            )
            observe(256, "reenable")
            observe(0, "release-reenable")
            advance(duration + 30)
            expired = observe(0, "second-expiry")
            if name != "wrong":
                T.require(
                    expired["expiries"] > idle["expiries"], "Reenabled timer failed"
                )
            final = observe(512, "freeze-display", extra=4)
            advance(3)
            display = words(base + sym["display_row"], 7)
            clock_after = field("clock_ticks")
            dl_after = words(base + sym["deadline"], 7)
            T.require(
                display == final["display"]
                and 0 < (clock_after - final["clock"]) % 65536 < 256
                and dl_after[5] != final["deadline"][5],
                "Display freeze stopped timer service",
            )
            plane = read(base + sym["plane"], 10240)
            image = V / (name + ".png")
            m.call("save_screenshot", path=str(image))
            result = {
                "samples": samples,
                "capture": final,
                "display": display,
                "frozen_clock_after": clock_after,
                "frozen_deadline_after": dl_after,
                "tick_interval": [tick_before, tick_after, 100],
                "slow_ticks": ticks,
                "slow_updates": updates,
                "fast_ticks": fast_ticks,
                "fast_updates": fast_updates,
                "plane_zlib": zlib.compress(bytes(plane)).hex(),
                "image": image.name,
                "image_sha256": T.sha(image),
                "clock_code_bytes": sym["clock_code_end"] - sym["clock_install"],
                "clock_state_bytes": 8,
                "deadline_code_bytes": sym["deadline_code_end"] - sym["deadline_init"],
                "deadline_state_bytes": 14,
                "display_bytes": 10240,
                "font_bytes": 136,
            }
            spans = [
                (0, sym["caller_code_end"]),
                (sym["clock_install"], sym["clock_code_end"]),
                (sym["dispatch"], sym["policy_code_end"]),
                (sym["deadline_init"], sym["deadline_code_end"]),
                (sym["POLL_ROUTINE"], sym["controls"]),
                (sym["read_joystick_edge"], sym["joy_prev"]),
                (sym["put_glyph"], sym["program_end"]),
            ]
        relocated = bytearray(body)
        for i in relocs:
            relocated[i : i + 4] = (
                int.from_bytes(body[i : i + 4], "big") + base
            ).to_bytes(4, "big")
        segments = []
        for first, last in spans:
            actual = read(base + first, last - first)
            T.require(
                actual == list(relocated[first:last]),
                "Relocated code/static data differs",
            )
            segments.append({"first": first, "last": last, "bytes": actual})
        return result | {
            "base": base,
            "segments": segments,
            "source_sha256": hashlib.sha256(src.encode()).hexdigest(),
            "hunk_zlib": zlib.compress(exe).hex(),
            "executable_sha256": hashlib.sha256(exe).hexdigest(),
            "executable_bytes": len(exe),
            "adf_sha256": T.sha(B / "demo.adf"),
            "server": m.server["serverInfo"],
        }
    except Exception:
        m.call("save_screenshot", path=str(V / (name + "-diagnostic.png")))
        raise
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for n in ("assembler", "build198x", "emulator", "kickstart"):
        p.add_argument("--" + n, type=Path, required=True)
    p.add_argument("--variants", default=",".join(VARIANTS))
    p.add_argument("--producer-note", required=True)
    args = p.parse_args()
    V.mkdir(exist_ok=True)
    cfg = {
        "model": "A500 68000 OCS PAL, Kickstart1.3 cold OFS ADF, exclusive level3 VBlank clock",
        "producer_note": args.producer_note,
        "assembler_sha256": T.sha(args.assembler),
        "build198x_sha256": T.sha(args.build198x),
        "emulator_sha256": T.sha(args.emulator),
        "kickstart_sha256": T.sha(args.kickstart),
    }
    (V / "configuration.json").write_text(json.dumps(cfg, indent=2) + "\n")
    target = V / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"system": "commodore-amiga", "language": "assembly", "cases": {}}
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
