"""Run the maintained AABB helper in a guest-owned independent caller."""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


T = module("transport", ROOT / "scripts/verify-game-loops.py")
C = module("cases", ROOT / "cross-platform/patterns/physics/rectangle-overlap/cases.py")
F = ROOT / "commodore-64/patterns/assembly/physics/rectangle-overlap"
V = F / "verification"
VARIANTS = ("demo", "custom", "wrong", "repaired")


def source_paths():
    return [
        F / n
        for n in (
            "demo.asm",
            "custom.asm",
            "wrong.asm",
            "repaired.asm",
            "caller.inc",
            "wrong-touch.inc",
            "build.py",
            "Makefile",
        )
    ] + [
        F / "../../framework/collect-and-respond/collision.inc",
        ROOT / "cross-platform/patterns/physics/rectangle-overlap/cases.py",
        Path(__file__),
        ROOT / "scripts/verify-game-loops.py",
    ]


def screen(variant):
    b = [6, 4, 11, 7] if variant == "demo" else [8, 2, 13, 6]
    a = [2, 2, 8, 6]
    result = int(C.overlap(a, b)) if variant != "wrong" else 1
    row = [48 + result] + [32] * 39
    for y in range(10):
        for x in range(40):
            aa = a[0] <= x < a[2] and a[1] <= y < a[3]
            bb = b[0] <= x < b[2] and b[1] <= y < b[3]
            row.append(24 if aa and bb else 1 if aa else 2 if bb else 32)
    return row


def run(args, variant):
    B = F / "build"
    binary = (B / (variant + ".prg")).read_bytes()
    sym = T.symbols(F / (variant + ".sym"))
    snap = B / (variant + ".vsf")
    script = B / (variant + ".json")
    script.write_text(json.dumps([{"action": "save_snapshot", "path": str(snap)}]))
    subprocess.run(
        [
            str(args.emulator),
            "--model",
            "pal",
            "--rom-dir",
            str(args.firmware),
            "--load",
            str(B / (variant + ".prg")),
            "--script",
            str(script),
        ],
        check=True,
        capture_output=True,
        timeout=60,
    )
    m = T.Machine(
        [str(args.emulator), "--mcp", "--model", "pal", "--rom-dir", str(args.firmware)]
    )

    def read(addr, n):
        return [
            b
            for i in range(0, n, 128)
            for b in m.call("memory_read", addr=addr + i, len=min(128, n - i))["bytes"]
        ]

    try:
        m.call("load_snapshot", path=str(snap))
        origin = int.from_bytes(binary[:2], "little")
        loaded = read(origin, len(binary) - 2)
        T.require(bytes(loaded) == binary[2:], "Loaded program differs before RUN")
        typed = m.call("type_string", text="RUN\n", hold_frames=3, settle_frames=8)
        T.require(typed["chars_typed"] == 4, "RUN incomplete")
        stop = m.call("run_until_pc", addr=sym["hold"], max_steps=300000)
        T.require(stop["reached"], "Guest did not finish cases and drawing")
        values = read(sym["results"], len(C.cases()))
        expected = [c["expected"] for c in C.cases()]
        T.require(
            (values == expected) == (variant != "wrong"), "Independent oracle mismatch"
        )
        guards = [read(sym[n], 1)[0] for n in ("completed", "ready")]
        T.require(guards == [165, 239], "Missing completion guards")
        row = read(1024, 440)
        T.require(row == screen(variant), "Native grid/result differs")
        m.call("run_frames", frames=3)
        image = V / (variant + ".png")
        m.call("save_screenshot", path=str(image))
        return {
            "bytes": values,
            "guards": guards,
            "stop": stop,
            "row": row,
            "result": read(sym["result"], 1)[0],
            "loaded_bytes": loaded,
            "loaded_sha256": T.sha(B / (variant + ".prg")),
            "image": image.name,
            "image_sha256": T.sha(image),
            "helper_code_bytes": sym["rect_a"] - sym["boxes_overlap"],
            "helper_state_bytes": 8,
            "payload_bytes": len(binary) - 2,
            "server": m.server["serverInfo"],
        }
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ("assembler", "emulator", "firmware"):
        p.add_argument("--" + name, type=Path, required=True)
    args = p.parse_args()
    subprocess.run(
        ["python3", str(F / "build.py")],
        check=True,
        env=os.environ | {"ASM198X": str(args.assembler)},
        timeout=60,
    )
    V.mkdir(exist_ok=True)
    cfg = {
        "model": "C64 PAL, stock ROMs",
        "emulator_sha256": T.sha(args.emulator),
        "assembler_sha256": T.sha(args.assembler),
        "firmware_sha256": {
            n: T.sha(args.firmware / n)
            for n in ("basic.rom", "kernal.rom", "chargen.rom")
        },
    }
    font = (args.firmware / "chargen.rom").read_bytes()
    cfg["glyphs"] = {
        str(n): list(font[n * 8 : n * 8 + 8]) for n in (1, 2, 24, 32, 48, 49)
    }
    (V / "configuration.json").write_text(json.dumps(cfg, indent=2) + "\n")
    r = {
        "system": "commodore-64",
        "language": "assembly",
        "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
        "cases": {},
        "configuration": cfg,
    }
    for name in VARIANTS:
        r["cases"][name] = run(args, name)
        (V / "results.json").write_text(json.dumps(r, indent=2) + "\n")
        print(name, "passed", flush=True)


if __name__ == "__main__":
    main()
