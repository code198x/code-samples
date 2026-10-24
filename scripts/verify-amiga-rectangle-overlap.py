"""Boot the original ADF, run supplied word-edge cases and observe real output."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
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
C = module("cases", "verify-c64-rectangle-overlap.py").C
F = ROOT / "commodore-amiga/patterns/assembly/physics/rectangle-overlap"
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
        ROOT / "scripts/verify-c64-rectangle-overlap.py",
    ]


def hunk(raw):
    words = [int.from_bytes(raw[i : i + 4], "big") for i in range(0, len(raw), 4)]
    T.require(
        len(raw) % 4 == 0 and words[:5] == [1011, 0, 1, 0, 0] and words[6] == 1001,
        "Expected one code hunk",
    )
    size = words[7] * 4
    body = bytearray(raw[32 : 32 + size])
    at = 8 + size // 4
    relocs = []
    T.require(words[at] == 1004, "Expected long relocations")
    at += 1
    while words[at]:
        n = words[at]
        T.require(words[at + 1] == 0, "Unexpected relocation target")
        relocs += words[at + 2 : at + 2 + n]
        at += 2 + n
    T.require(words[at:] == [0, 1010], "Unexpected trailing hunks")
    T.require(
        all(0 <= i <= len(body) - 4 and i % 2 == 0 for i in relocs),
        "Invalid relocation",
    )
    return body, relocs


def run(args, name):
    B = F / "build"
    sym = T.symbols(B / (name + ".sym"))
    exe = (B / name).read_bytes()
    body, relocs = hunk(exe)
    m = T.Machine(
        [
            str(args.emulator),
            "--mcp",
            "--model",
            "a500",
            "--kickstart",
            str(args.kickstart),
            "--disk",
            str(B / (name + ".adf")),
        ]
    )

    def read(addr, n):
        return [
            b
            for i in range(0, n, 128)
            for b in m.call("memory_read", addr=addr + i, len=min(128, n - i))["bytes"]
        ]

    try:
        found = []
        for _ in range(25):
            m.call("run_frames", frames=100)
            hits = m.call("memory_scan", start=0, end=0x80000, value=0x31393858)
            T.require(not hits["truncated"], "Truncated signature scan")
            found = [
                int(x["addr"][1:], 16) - sym["signature"]
                for x in hits["hits"]
                if read(int(x["addr"][1:], 16), 15) == list(b"198XRECTAMIGA!\0")
                and read(int(x["addr"][1:], 16) - sym["signature"] + sym["ready"], 2)
                == [186, 190]
            ]
            if found:
                break
        T.require(len(found) == 1, "No unique completed native caller")
        base = found[0]
        guards = [
            int.from_bytes(bytes(read(base + sym[n], 2)), "big")
            for n in ("completed", "ready")
        ]
        values = read(base + sym["results"], len(C.cases(65535)))
        expected = [c["expected"] for c in C.cases(65535)]
        T.require(
            guards == [0xCAFE, 0xBABE] and (values == expected) == (name != "wrong"),
            "Native word-edge oracle/guards differ",
        )
        relocated = bytearray(body)
        for offset in relocs:
            relocated[offset : offset + 4] = (
                int.from_bytes(body[offset : offset + 4], "big") + base
            ).to_bytes(4, "big")
        segments = []
        for first, last in [
            (0, sym["caller_code_end"]),
            (sym["helper_start"], sym["rect_a"]),
            (sym["example"], sym["program_end"]),
        ]:
            actual = read(base + first, last - first)
            T.require(
                actual == list(relocated[first:last]),
                "Native relocated instruction/data segment differs",
            )
            segments.append({"first": first, "last": last, "bytes": actual})
        result = int.from_bytes(bytes(read(base + sym["result"], 2)), "big")
        plane = read(base + sym["plane"], 10240)
        glyph = (
            [24, 56, 24, 24, 24, 24, 126, 0]
            if result
            else [60, 66, 70, 74, 82, 98, 60, 0]
        )
        wanted = [0] * 10240
        for y, b in enumerate(glyph):
            wanted[1984 + y * 40] = b
        T.require(plane == wanted, "Native plane differs from result")
        m.call("run_frames", frames=3)
        image = V / (name + ".png")
        m.call("save_screenshot", path=str(image))
        return {
            "base": base,
            "guards": guards,
            "bytes": values,
            "result": result,
            "segments": segments,
            "hunk_zlib": zlib.compress(exe).hex(),
            "executable_sha256": hashlib.sha256(exe).hexdigest(),
            "plane_zlib": zlib.compress(bytes(plane)).hex(),
            "image": image.name,
            "image_sha256": T.sha(image),
            "server": m.server["serverInfo"],
            "code_bytes": sym["rect_a"] - sym["boxes_overlap"],
            "state_bytes": 16,
            "display_bytes": 10240,
            "executable_bytes": len(exe),
            "adf_sha256": T.sha(B / (name + ".adf")),
        }
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ("assembler", "build198x", "emulator", "kickstart"):
        p.add_argument("--" + name, type=Path, required=True)
    args = p.parse_args()
    subprocess.run(
        ["python3", str(F / "build.py")],
        check=True,
        timeout=90,
        env=os.environ
        | {"ASM198X": str(args.assembler), "BUILD198X": str(args.build198x)},
    )
    V.mkdir(exist_ok=True)
    cfg = {
        "model": "A500 OCS PAL, Kickstart 1.3, original OFS ADF cold boot",
        "assembler_sha256": T.sha(args.assembler),
        "build198x_sha256": T.sha(args.build198x),
        "emulator_sha256": T.sha(args.emulator),
        "kickstart_sha256": T.sha(args.kickstart),
    }
    (V / "configuration.json").write_text(json.dumps(cfg, indent=2) + "\n")
    r = {
        "system": "commodore-amiga",
        "language": "assembly",
        "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
        "configuration": cfg,
        "cases": {},
    }
    for name in VARIANTS:
        r["cases"][name] = run(args, name)
        (V / "results.json").write_text(json.dumps(r, indent=2) + "\n")
        print(name, "passed", flush=True)


if __name__ == "__main__":
    main()
