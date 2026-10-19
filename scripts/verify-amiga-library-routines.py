"""Boot an original caller and compare actual blitter output with line geometry.

A500 OCS PAL with local Kickstart1.3; no original-hardware conformance claim.
The line oracle permits all eight octant encodings but requires every encoding
produce a different correct reflection. It does not copy the blitter error loop.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "commodore-amiga/patterns/assembly/rendering/blitter-line-draw/line.inc"
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(args: argparse.Namespace) -> dict:
    folder = args.output.resolve()
    folder.mkdir(parents=True, exist_ok=True)
    (folder / "results.json").unlink(missing_ok=True)
    shutil.copy2(SOURCE, folder / "line.inc")
    calls = []
    for n in range(8):
        calls.append(f"""    move.w #31,d0
    move.w #13,d1
    move.w #{n * 4},d2
    move.l #planes,a1
    adda.l #{n * 10240 + 128 * 40 + 20},a1
    moveq #0,d3
    bsr line_draw
    bsr wait_blit""")
    caller = (
        """    section code,code_c
start:
    lea $dff000,a5
    move.w #$7fff,$09a(a5)
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5)
    move.w #$8240,$096(a5)
"""
        + "\n".join(calls)
        + """
    move.w #$cafe,ready
hold: bra.s hold
signature: dc.b "198XLINEAUDIT!",0
    even
ready: dc.w 0
    include "line.inc"
    even
planes: dcb.b 81920,0
"""
    )
    (folder / "demo.asm").write_text(caller)
    for cmd in [
        [
            args.assembler,
            "--dialect",
            "vasm",
            "--exe",
            "--sym=demo.sym",
            "demo.asm",
            "-o",
            "demo",
        ],
        [args.build198x, "adf", "demo", "-o", "demo.adf", "--name", "demo"],
    ]:
        result = subprocess.run(
            cmd, cwd=folder, capture_output=True, text=True, timeout=40, check=False
        )
        T.require(result.returncode == 0, result.stderr or result.stdout)
    sym = T.symbols(folder / "demo.sym")
    machine = T.Machine(
        [
            args.emulator,
            "--mcp",
            "--model",
            "a500",
            "--kickstart",
            str(args.kickstart),
            "--disk",
            str(folder / "demo.adf"),
        ]
    )
    try:
        bases = []
        for _ in range(20):
            machine.call("run_frames", frames=100)
            scan = machine.call("memory_scan", start=0, end=0x80000, value=0x31393858)
            T.require(not scan["truncated"], "Marker scan truncated")
            for hit in scan["hits"]:
                base = int(hit["addr"][1:], 16) - sym["signature"]
                if T.memory(machine, base + sym["ready"], 2, True) == 0xCAFE:
                    bases.append(base)
            if bases:
                break
        T.require(len(bases) == 1, f"Expected one completed blitter caller: {bases}")
        start = bases[0] + sym["planes"]
        raw = bytearray()
        for offset in range(0, 81920, 256):
            raw.extend(
                machine.call("memory_read", addr=start + offset, len=256)["bytes"]
            )
        T.require(len(raw) == 81920, "Truncated bitplane data")
        (folder / "bitplanes.bin").write_bytes(raw)
    finally:
        machine.close()
    # Analytic nearest pixel on a 31-by-13 line, reflected into every octant.
    oracles = set()
    for swap in [False, True]:
        for sx in [-1, 1]:
            for sy in [-1, 1]:
                points = []
                for major in range(32):
                    minor = (2 * 13 * major + 31) // 62
                    x, y = (minor, major) if swap else (major, minor)
                    points.append((160 + sx * x, 128 + sy * y))
                oracles.add(frozenset(points))
    seen = set()
    for n in range(8):
        plane = raw[n * 10240 : (n + 1) * 10240]
        points = frozenset(
            (x, y)
            for y in range(256)
            for x in range(320)
            if plane[y * 40 + x // 8] & (0x80 >> (x % 8))
        )
        T.require(
            points in oracles,
            f"Line geometry mismatch in octant encoding {n * 4}: {len(points)} pixels",
        )
        seen.add(points)
    T.require(seen == oracles, "Octant encodings did not cover eight distinct lines")
    return {
        "status": "passed",
        "octants": 8,
        "pixels_per_line": 32,
        "source_sha256": sha(SOURCE),
        "observer_sha256": sha(Path(__file__)),
        "binary_sha256": sha(folder / "demo"),
        "emulator_sha256": sha(Path(args.emulator)),
        "firmware_sha256": sha(args.kickstart),
        "limits": __doc__,
    }


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--emulator", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument("--build198x", required=True)
    p.add_argument(
        "--kickstart",
        type=Path,
        default=Path.home() / ".emu198x/roms/commodore-amiga/kick13.rom",
    )
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--expect-rejection", action="store_true")
    args = p.parse_args()
    try:
        result = run(args)
    except AssertionError as error:
        if not args.expect_rejection:
            raise
        T.require(
            str(error).startswith("Line geometry mismatch"),
            f"Unrelated regression failure: {error}",
        )
        result = {
            "status": "regression-characterised",
            "failure": str(error),
            "source_sha256": sha(SOURCE),
            "observer_sha256": sha(Path(__file__)),
        }
    else:
        T.require(not args.expect_rejection, "Unfixed line unexpectedly passed")
    (args.output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
