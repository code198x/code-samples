"""ROM-tape-load Spectrum held/press/release callers and an independent mask fixture."""

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
    "spectrum", ROOT / "scripts/verify-spectrum-assembly-deadlines.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing Spectrum tape observer")
A = importlib.util.module_from_spec(spec)
spec.loader.exec_module(A)
T = A.T
F = ROOT / "sinclair-zx-spectrum/patterns/assembly/input/keyboard-reading"
V = F / "verification/edges"
VARIANTS = ("working", "custom", "wrong", "repaired", "boundaries", "wrong-boundary")
KEYS = ("q", "a", "o", "p", "space")


def source_paths() -> list[Path]:
    return (
        [
            F / n
            for n in [
                "edges-demo.asm",
                "edges-custom.asm",
                "edges-wrong.asm",
                "edges-caller.inc",
                "edges-display.inc",
                "edges.inc",
                "Makefile",
            ]
        ]
        + [
            F / "../../framework/input-to-sound/input.inc",
            F / "../../framework/input-to-sound/presses.inc",
            Path(__file__),
        ]
        + A.source_paths()
    )


def fixture(wrong: bool) -> str:
    helper = (F / "edges.inc").read_text()
    if wrong:
        changed = helper.replace("    and c\n", "    or c\n")
        T.require(changed != helper, "Missing mutation")
        helper = changed
    return (
        """    org $8000
start:
    di
    ld sp,$ff00
    ld a,165
    ld (50000),a
    ld hl,50001
    ld d,0
next_previous:
    ld b,0
next_current:
    ld a,d
    call release_bits
    ld (hl),a
    inc hl
    inc b
    ld a,b
    cp 32
    jr nz,next_current
    inc d
    ld a,d
    cp 32
    jr nz,next_previous
    ld a,239
    ld (51025),a
hold:
    jr hold
"""
        + (F / "../../framework/input-to-sound/input.inc").read_text()
        + (F / "../../framework/input-to-sound/presses.inc").read_text()
        + helper
        + "    end start\n"
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
            "pasmo",
            "--cpu",
            "z80",
            "-I",
            str(F),
            "--tapbas",
            "--sym",
            str(out / "demo.asm"),
            "-o",
            str(out / "demo.tap"),
        ],
        check=True,
        capture_output=True,
        timeout=30,
    )
    data = list(A.blocks(out / "demo.tap")[-1][1:-1])
    sym = T.symbols(out / "demo.sym")
    m = T.Machine([str(args.emulator), "--mcp", "--rom", str(args.rom)])
    samples = []
    history = 0
    presses = 0
    releases = 0
    actions = 0

    def advance(n: int) -> None:
        for i in range(0, n, 200):
            m.call("run_frames", frames=min(200, n - i))

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
                {"Key": {"name": name, "pressed": bool(mask & (1 << i))}}
                for i, name in enumerate(KEYS)
            ],
        )
        advance(2)
        a = m.call("run_until_pc", addr=sym["sample"], max_steps=30000)
        T.require(a["reached"], "No sample boundary")
        stop = m.call("run_until_pc", addr=sym["frame_done"], max_steps=10000)
        T.require(stop["reached"], "No finished display")
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
        new = mask & (31 ^ history)
        released = history & (31 ^ mask)
        T.require(state["controls"] == mask, "Native keyboard mask differs")
        if variant != "wrong":
            presses += bool(new)
            releases += bool(released)
            actions += bool(new & (4 if variant == "custom" else 16))
            T.require(
                [state[k] for k in ["press_events", "release_events", "actions"]]
                == [presses, releases, actions],
                "Native event history differs",
            )
            if new:
                T.require(state["last_new"] == new, "Wrong press latch")
            if released:
                T.require(state["last_release"] == released, "Wrong release latch")
        history = mask
        sample = {"stage": stage, "input": mask, "state": state, "stop": stop}
        samples.append(sample)
        print(variant, stage, state, flush=True)
        return sample

    try:
        m.call("load_media", slot="tape-1", kind="tape", path=str(out / "demo.tap"))
        m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
        for _ in range(100):
            advance(100)
            raw = read(50000, 1026) if "boundar" in variant else read(sym["ready"], 1)
            if (
                (raw[0] == 165 and raw[-1] == 239)
                if "boundar" in variant
                else raw == [165]
            ):
                break
        else:
            raise AssertionError("Caller/fixture did not complete startup")
        if "boundar" in variant:
            expected = (
                [165]
                + [
                    sum(
                        1 << bit
                        for bit in range(5)
                        if p & (1 << bit) and not n & (1 << bit)
                    )
                    for p in range(32)
                    for n in range(32)
                ]
                + [239]
            )
            T.require(
                (raw == expected) == (variant == "boundaries"),
                "Release oracle mismatch",
            )
            result = {"bytes": raw, "oracle_matches": raw == expected}
        else:
            for mask, stage in [
                (0, "idle"),
                (16, "press"),
                (16, "hold"),
                (0, "release"),
                (16, "second-press"),
                (20, "simultaneous"),
                (4, "release-fire"),
                (0, "release-all"),
                (31, "all-keys"),
                (31, "all-hold"),
                (0, "all-release"),
            ]:
                observe(mask, stage)
            advance(3)
            final = observe(0, "capture")
            advance(2)
            state = final["state"]
            text = " ".join(
                f"{state[k]:02X}"
                for k in ["controls", "new_presses", "released_controls", "actions"]
            )
            pixels = A.pixels(m, 0, text)
            image = V / (variant + ".png")
            m.call("save_screenshot", path=str(image))
            result = {
                "samples": samples,
                "capture": final,
                "pixels": pixels,
                "image": image.name,
                "image_sha256": T.sha(image),
                "code_bytes": sym["edges_code_end"] - sym["detect_control_edges"],
                "state_bytes": 1,
            }
        # Code prefix ends before any embedded input/observer state.
        prefix = (
            sym["trace"] - 32768
            if "boundar" not in variant
            else sym["hold"] + 2 - 32768
        )
        loaded = read(32768, prefix)
        T.require(loaded == data[:prefix], "ROM-loaded code prefix differs")
        mutable = (
            sorted(
                {
                    sym[name] - 32768
                    for name in [
                        "controls",
                        "previous_controls",
                        "new_presses",
                        "released_controls",
                        "last_new",
                        "last_release",
                        "press_events",
                        "release_events",
                        "actions",
                        "ready",
                    ]
                }
            )
            if "boundar" not in variant
            else []
        )
        loaded_image = read(32768, len(data))
        T.require(
            all(
                a == b
                for i, (a, b) in enumerate(zip(loaded_image, data, strict=True))
                if i not in mutable
            ),
            "Native immutable image differs from TAP",
        )
        return result | {
            "payload": data,
            "loaded_image": loaded_image,
            "mutable_offsets": mutable,
            "payload_bytes": len(data),
            "payload_sha256": hashlib.sha256(bytes(data)).hexdigest(),
            "loaded_prefix": loaded,
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
    for name in ["assembler", "emulator", "rom"]:
        p.add_argument("--" + name, type=Path, required=True)
    p.add_argument("--variants", default=",".join(VARIANTS))
    args = p.parse_args()
    V.mkdir(parents=True, exist_ok=True)
    target = V / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"system": "sinclair-zx-spectrum", "language": "assembly", "cases": {}}
    )
    for v in args.variants.split(","):
        T.require(v in VARIANTS, "Unknown variant")
        r["cases"][v] = run(args, v)
        r.update(
            sources={
                str(p.resolve().relative_to(ROOT)): T.sha(p) for p in source_paths()
            },
            emulator_sha256=T.sha(args.emulator),
            assembler_sha256=T.sha(args.assembler),
            firmware_sha256={args.rom.name: T.sha(args.rom)},
        )
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(v, "passed", flush=True)


if __name__ == "__main__":
    main()
