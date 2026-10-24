"""Qualify the C64 release wrapper with real ports and a guest-owned second caller."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing native transport")
T = importlib.util.module_from_spec(spec)
spec.loader.exec_module(T)
F = ROOT / "commodore-64/patterns/assembly/input/joystick-reading"
V = F / "verification/edges"
VARIANTS = ("working", "custom", "wrong", "repaired", "boundaries", "wrong-boundary")
NAMES = ("up", "down", "left", "right", "fire")


def source_paths() -> list[Path]:
    return [
        F / n
        for n in (
            "edges-demo.asm",
            "edges-custom.asm",
            "edges-wrong.asm",
            "edges-caller.inc",
            "edges-wrong.inc",
            "edges.inc",
            "joystick.inc",
            "Makefile",
        )
    ] + [Path(__file__), ROOT / "scripts/verify-game-loops.py"]


def fixture(wrong: bool) -> str:
    helper = (F / "edges.inc").read_text()
    if wrong:
        replaced = helper.replace(
            "    and joy_edge_scratch\n", "    ora joy_edge_scratch\n"
        )
        T.require(replaced != helper, "Wrong release mutation missing")
        helper = replaced
    return (
        """* = $0801
    !byte $0b,$08,$0a,$00,$9e
    !text "2064"
    !byte 0,0,0
* = $0810
start:
    sei
    lda #0
    sta previous
    lda #<$c001
    sta $fb
    lda #>$c001
    sta $fc
    lda #165
    sta $c000
    ldy #0
next_previous:
    ldx #0
next_current:
    lda previous
    jsr joy_release_bits
    sta ($fb),y
    inc $fb
    bne no_carry
    inc $fc
no_carry:
    inx
    cpx #32
    bne next_current
    inc previous
    lda previous
    cmp #32
    bne next_previous
    lda #239
    sta $c401
hold:
    jmp hold
previous: !byte 0
"""
        + (F / "joystick.inc").read_text()
        + helper
    )


def run(args: argparse.Namespace, variant: str) -> dict[str, Any]:
    out = F / "build/edges" / variant
    out.mkdir(parents=True, exist_ok=True)
    source = (
        fixture(variant == "wrong-boundary")
        if "boundar" in variant
        else (
            F
            / {"custom": "edges-custom.asm", "wrong": "edges-wrong.asm"}.get(
                variant, "edges-demo.asm"
            )
        ).read_text()
    )
    (out / "demo.asm").write_text(source)
    subprocess.run(
        [
            str(args.assembler),
            "--dialect",
            "acme",
            "--prg",
            "-I",
            str(F),
            "--sym",
            str(out / "demo.asm"),
            "-o",
            str(out / "demo.prg"),
        ],
        check=True,
        capture_output=True,
        timeout=30,
    )
    sym = T.symbols(out / "demo.sym")
    exe = args.emulator
    script = out / "import.json"
    snapshot = out / "import.vsf"
    script.write_text(json.dumps([{"action": "save_snapshot", "path": str(snapshot)}]))
    subprocess.run(
        [
            str(exe),
            "--model",
            "pal",
            "--rom-dir",
            str(args.firmware),
            "--load",
            str(out / "demo.prg"),
            "--script",
            str(script),
        ],
        check=True,
        capture_output=True,
        timeout=60,
    )
    m = T.Machine(
        [str(exe), "--mcp", "--model", "pal", "--rom-dir", str(args.firmware)]
    )
    samples = []
    history = [0, 0]
    presses = [0, 0]
    releases = [0, 0]
    actions = 0

    def read(addr: int, n: int) -> list[int]:
        return [
            b
            for i in range(0, n, 128)
            for b in m.call("memory_read", addr=addr + i, len=min(128, n - i))["bytes"]
        ]

    def observe(one: int, two: int, stage: str) -> dict[str, Any]:
        events = [
            {"Button": {"port": port, "name": name, "pressed": bool(mask & (1 << bit))}}
            for port, mask in ((1, one), (2, two))
            for bit, name in enumerate(NAMES)
        ]
        m.call("input", events=events)
        # Native frame execution dispatches queued host events before sampling.
        m.call("run_frames", frames=2)
        stop = m.call("run_until_pc", addr=sym["sample"], max_steps=30000)
        T.require(stop["reached"], "Sample boundary not reached")
        done = m.call("run_until_pc", addr=sym["frame_done"], max_steps=10000)
        T.require(done["reached"], "Display boundary not reached")
        names = (
            "joy1",
            "joy1_new",
            "joy1_released",
            "joy2",
            "joy2_new",
            "joy2_released",
            "actions",
            "last_new1",
            "last_release1",
            "last_new2",
            "last_release2",
            "press_events1",
            "release_events1",
            "press_events2",
            "release_events2",
        )
        state = {name: read(sym[name], 1)[0] for name in names}
        nonlocal actions
        current = [one, two]
        for i in range(2):
            new = current[i] & (31 ^ history[i])
            released = history[i] & (31 ^ current[i])
            T.require(
                state[f"joy{i + 1}"] == current[i],
                "Native port does not match supplied buttons",
            )
            if variant != "wrong":
                presses[i] += bool(new)
                releases[i] += bool(released)
                T.require(
                    state[f"press_events{i + 1}"] == presses[i]
                    and state[f"release_events{i + 1}"] == releases[i],
                    "Native event history differs",
                )
                if new:
                    T.require(
                        state[f"last_new{i + 1}"] == new, "New-press latch differs"
                    )
                if released:
                    T.require(
                        state[f"last_release{i + 1}"] == released,
                        "Release latch differs",
                    )
            if i == 1 and new & (4 if variant == "custom" else 16):
                actions += 1
            history[i] = current[i]
        if variant != "wrong":
            T.require(state["actions"] == actions, "A held input repeated an action")
        row = read(1024, 21)
        sample = {
            "stage": stage,
            "input": [one, two],
            "state": state,
            "row": row,
            "stop": done,
        }
        samples.append(sample)
        print(variant, stage, state, flush=True)
        return sample

    try:
        m.call("load_snapshot", path=str(snapshot))
        binary = (out / "demo.prg").read_bytes()
        origin = int.from_bytes(binary[:2], "little")
        loaded = read(origin, len(binary) - 2)
        T.require(bytes(loaded) == binary[2:], "Imported program differs before RUN")
        typed = m.call("type_string", text="RUN\n", hold_frames=3, settle_frames=8)
        T.require(typed["chars_typed"] == 4, "RUN incomplete")
        m.call("run_frames", frames=30)
        if "boundar" in variant:
            raw = read(0xC000, 1026)
            T.require(raw[0] == 165 and raw[-1] == 239, "Release fixture incomplete")
            expected = (
                [165]
                + [
                    sum(
                        1 << bit
                        for bit in range(5)
                        if previous & (1 << bit) and not current & (1 << bit)
                    )
                    for previous in range(32)
                    for current in range(32)
                ]
                + [239]
            )
            T.require(
                (raw == expected) == (variant == "boundaries"),
                "Release oracle mismatch",
            )
            result = {"bytes": raw, "oracle_matches": raw == expected}
        else:
            T.require(read(sym["ready"], 1) == [165], "Caller did not initialise")
            for one, two, stage in [
                (0, 0, "idle"),
                (0, 16, "press"),
                (0, 16, "hold"),
                (0, 0, "release"),
                (0, 16, "second-press"),
                (0, 20, "simultaneous"),
                (0, 4, "release-fire"),
                (0, 0, "release-all"),
                (21, 10, "both-ports"),
                (21, 10, "both-hold"),
                (0, 0, "both-release"),
            ]:
                observe(one, two, stage)
            # A stable idle display makes PNG comparison independent of beam timing.
            m.call("run_frames", frames=3)
            final = observe(0, 0, "capture")
            image = V / (variant + ".png")
            m.call("run_frames", frames=2)
            m.call("save_screenshot", path=str(image))
            result = {
                "samples": samples,
                "capture": final,
                "image": image.name,
                "image_sha256": T.sha(image),
                "code_bytes": sym["joy_edges_code_end"] - sym["joy_edges_init"],
                "state_bytes": 3,
            }
        return result | {
            "loaded_sha256": hashlib.sha256(bytes(loaded)).hexdigest(),
            "loaded_bytes": loaded,
            "source_sha256": hashlib.sha256(source.encode()).hexdigest(),
            "server": m.server["serverInfo"],
        }
    except Exception:
        m.call("save_screenshot", path=str(V / "diagnostic.png"))
        raise
    finally:
        m.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    for name in ("assembler", "emulator", "firmware"):
        p.add_argument("--" + name, type=Path, required=True)
    p.add_argument("--variants", default=",".join(VARIANTS))
    args = p.parse_args()
    V.mkdir(parents=True, exist_ok=True)
    target = V / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"system": "commodore-64", "language": "assembly", "cases": {}}
    )
    for variant in args.variants.split(","):
        T.require(variant in VARIANTS, "Unknown variant")
        r["cases"][variant] = run(args, variant)
        r.update(
            sources={str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
            emulator_sha256=T.sha(args.emulator),
            assembler_sha256=T.sha(args.assembler),
            firmware_sha256={
                n: T.sha(args.firmware / n)
                for n in ["basic.rom", "kernal.rom", "chargen.rom"]
            },
        )
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(variant, "passed", flush=True)


if __name__ == "__main__":
    main()
