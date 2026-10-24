"""Run NES serial-input edges and stream all65,536 pure release pairs from guest RAM."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing transport")
T = importlib.util.module_from_spec(spec)
spec.loader.exec_module(T)
F = ROOT / "nintendo-entertainment-system/patterns/assembly/input/controller-reading"
V = F / "verification/edges"
VARIANTS = ("working", "custom", "wrong", "repaired", "boundaries", "wrong-boundary")
BUTTONS = ("a", "b", "select", "start", "up", "down", "left", "right")


def source_paths() -> list[Path]:
    return [
        F / n
        for n in [
            "edges-demo.asm",
            "edges-custom.asm",
            "edges-wrong.asm",
            "edges-caller.inc",
            "edges-font.inc",
            "edges.inc",
            "Makefile",
        ]
    ] + [
        F / "../../framework/input-to-sound/input.inc",
        F / "../../framework/input-to-sound/presses.inc",
        Path(__file__),
        ROOT / "scripts/verify-game-loops.py",
    ]


def fixture(wrong: bool) -> str:
    helper = (F / "edges.inc").read_text()
    if wrong:
        changed = helper.replace("    and edge_scratch\n", "    ora edge_scratch\n")
        T.require(changed != helper, "Missing mutation")
        helper = changed
    return (
        """.segment "HEADER"
    .byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
.segment "BSS"
previous: .res 1
ready: .res 1
output: .res 256
.segment "CODE"
reset:
    sei
    cld
    ldx #$ff
    txs
    inx
    stx $2000
    stx $2001
    stx $4010
    stx $4015
    stx previous
    stx ready
    lda #$40
    sta $4017
next_previous:
    ldx #0
next_current:
    lda previous
    jsr release_bits
    sta output,x
    inx
    bne next_current
row_done:
    inc previous
    bne next_previous
    lda #165
    sta ready
hold:
    jmp hold
nmi:
irq:
    rti
"""
        + (F / "../../framework/input-to-sound/input.inc").read_text()
        + (F / "../../framework/input-to-sound/presses.inc").read_text()
        + helper
        + """code_end:
.segment "VECTORS"
    .word nmi,reset,irq
.segment "CHARS"
    .res 8192,0
"""
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
            "ca65",
            "-I",
            str(F),
            "--sym",
            str(out / "demo.asm"),
            "-o",
            str(out / "demo.nes"),
        ],
        check=True,
        capture_output=True,
        timeout=30,
    )
    cart = (out / "demo.nes").read_bytes()
    T.require(len(cart) == 40976 and cart[:8] == b"NES\x1a\x02\x01\0\0", "Wrong NROM")
    sym = T.symbols(out / "demo.sym")
    m = T.Machine(
        [
            str(args.emulator),
            "--mcp",
            "--rom",
            str(out / "demo.nes"),
            "--region",
            "ntsc",
        ]
    )
    samples = []
    history = 0
    presses = 0
    releases = 0
    actions = 0

    def advance(n: int) -> None:
        m.call("run_frames", frames=n)

    def read(addr: int, n: int) -> list[int]:
        return [
            b
            for i in range(0, n, 128)
            for b in m.call("memory_read", addr=addr + i, len=min(128, n - i))["bytes"]
        ]

    def observe(mask: int, stage: str) -> dict[str, Any]:
        nonlocal history, presses, releases, actions
        m.call(
            "input",
            events=[
                {
                    "Button": {
                        "port": 1,
                        "name": name,
                        "pressed": bool(mask & (128 >> i)),
                    }
                }
                for i, name in enumerate(BUTTONS)
            ],
        )
        advance(2)
        stop = m.call("run_until_pc", addr=sym["frame_done"], max_steps=30000)
        T.require(stop["reached"], "No completed input/display update")
        state = {
            name: read(sym[name], 1)[0]
            for name in [
                "controls",
                "new_presses",
                "released_controls",
                "last_new",
                "last_release",
                "press_events",
                "release_events",
                "actions",
            ]
        }
        new = mask & (255 ^ history)
        released = history & (255 ^ mask)
        T.require(state["controls"] == mask, "Native serial controller differs")
        if variant != "wrong":
            presses += bool(new)
            releases += bool(released)
            actions += bool(new & (2 if variant == "custom" else 128))
            T.require(
                [state[k] for k in ["press_events", "release_events", "actions"]]
                == [presses, releases, actions],
                "Native event history differs",
            )
            if new:
                T.require(state["last_new"] == new, "Wrong press mask")
            if released:
                T.require(state["last_release"] == released, "Wrong release mask")
        history = mask
        sample = {"stage": stage, "input": mask, "state": state, "stop": stop}
        samples.append(sample)
        print(variant, stage, state, flush=True)
        return sample

    try:
        if "boundar" in variant:
            data = []
            stops = []
            for previous in range(256):
                stop = m.call("run_until_pc", addr=sym["row_done"], max_steps=15000)
                T.require(stop["reached"], "Release row did not complete")
                T.require(
                    read(sym["previous"], 1) == [previous], "Rows skipped or repeated"
                )
                data += read(sym["output"], 256)
                stops.append(stop)
                m.call("step", instructions=1)
            stop = m.call("run_until_pc", addr=sym["hold"], max_steps=100)
            T.require(
                stop["reached"] and read(sym["ready"], 1) == [165],
                "Final release guard incomplete",
            )
            expected = [
                sum(
                    1 << bit
                    for bit in range(8)
                    if p & (1 << bit) and not n & (1 << bit)
                )
                for p in range(256)
                for n in range(256)
            ]
            T.require(
                (data == expected) == (variant == "boundaries"),
                "Release matrix oracle mismatch",
            )
            result = {
                "rows_zlib_hex": zlib.compress(bytes(data)).hex(),
                "row_count": len(stops),
                "stops": stops,
                "row_done_pc": sym["row_done"],
                "end_guard": 165,
                "oracle_matches": data == expected,
                "mismatches": sum(a != b for a, b in zip(data, expected, strict=True)),
            }
        else:
            advance(30)
            T.require(read(sym["ready"], 1) == [165], "Caller did not initialise")
            for mask, stage in [
                (0, "idle"),
                (128, "press"),
                (128, "hold"),
                (0, "release"),
                (128, "second-press"),
                (130, "simultaneous"),
                (2, "release-a"),
                (0, "release-all"),
                (255, "all-buttons"),
                (255, "all-hold"),
                (0, "all-release"),
            ]:
                observe(mask, stage)
            advance(3)
            final = observe(0, "capture")
            advance(2)
            image = V / (variant + ".png")
            m.call("save_screenshot", path=str(image))
            result = {
                "samples": samples,
                "capture": final,
                "image": image.name,
                "image_sha256": T.sha(image),
                "code_bytes": sym["edges_code_end"] - sym["detect_control_edges"],
                "state_bytes": 2,
            }
        loaded = bytes(read(32768, 32768))
        T.require(loaded == cart[16:32784], "Native PRG ROM differs from cartridge")
        return result | {
            "native_prg_sha256": hashlib.sha256(loaded).hexdigest(),
            "cart_sha256": hashlib.sha256(cart).hexdigest(),
            "source_sha256": hashlib.sha256(source.encode()).hexdigest(),
            "code_end": sym["code_end"],
            "server": m.server["serverInfo"],
        }
    except Exception:
        m.call("save_screenshot", path=str(V / "diagnostic.png"))
        raise
    finally:
        m.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    for name in ["assembler", "emulator"]:
        p.add_argument("--" + name, type=Path, required=True)
    p.add_argument("--variants", default=",".join(VARIANTS))
    args = p.parse_args()
    V.mkdir(parents=True, exist_ok=True)
    target = V / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"system": "nintendo-nes", "language": "assembly", "cases": {}}
    )
    for variant in args.variants.split(","):
        T.require(variant in VARIANTS, "Unknown variant")
        r["cases"][variant] = run(args, variant)
        r.update(
            sources={
                str(p.resolve().relative_to(ROOT)): T.sha(p) for p in source_paths()
            },
            emulator_sha256=T.sha(args.emulator),
            assembler_sha256=T.sha(args.assembler),
        )
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(variant, "passed", flush=True)


if __name__ == "__main__":
    main()
