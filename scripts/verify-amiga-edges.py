"""Execute all 1,024 held/previous masks through the Amiga edge adapter.

CPU/state fixture on A500 PAL. Hardware decoding remains the maintained reader's
separate evidence; these calls consume an already sampled controls word.
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
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


SOURCES = [
    ROOT / "commodore-amiga/patterns/assembly/input/joystick-edge-detection/edges.inc",
    ROOT / "commodore-amiga/patterns/assembly/framework/input-to-sound/input.inc",
]


def build(assembler: str, builder: str, out: Path) -> bytes:
    """Write and build the edge caller's disk in out; return the expected output."""
    out.mkdir(parents=True, exist_ok=True)
    sources = SOURCES
    masks = [
        sum(bit for n, bit in enumerate([0x100, 1, 0x200, 2, 0x10]) if value & (1 << n))
        for value in range(32)
    ]
    body = "    section code,code_c\nstart:\n    lea output,a0\n"
    expected = bytearray()
    for previous in masks:
        for held in masks:
            body += f"    move.w #{previous},joy_prev\n    move.w #{held},controls\n    bsr detect_joystick_edges\n    move.w d0,(a0)+\n    move.w joy_prev,(a0)+\n"
            # Set difference is independent of the adapter's NOT/AND instruction sequence.
            edge = sum(
                bit
                for bit in [0x100, 1, 0x200, 2, 0x10]
                if held & bit and not previous & bit
            )
            expected += edge.to_bytes(2, "big") + held.to_bytes(2, "big")
    body += (
        '    move.w #$cafe,ready\nhold: bra.s hold\nsignature: dc.b "198XEDGES!"\n    even\nready: dc.w 0\n'
        + "\n".join(s.read_text() for s in sources)
        + "\noutput: dcb.b 4096,0\n"
    )
    (out / "demo.asm").write_text(body)
    for command in [
        [
            assembler,
            "--dialect",
            "vasm",
            "--exe",
            "--sym=demo.sym",
            "demo.asm",
            "-o",
            "demo",
        ],
        [builder, "adf", "demo", "-o", "demo.adf", "--name", "demo"],
    ]:
        subprocess.run(
            command, cwd=out, capture_output=True, text=True, timeout=40, check=True
        )
    return bytes(expected)


def build_programs(assembler: str, builder: str, output: str) -> None:
    """Build the caller's disk into output/demo.adf, without the emulator."""
    build(assembler, builder, Path(output).resolve())


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--emulator", required=True)
    p.add_argument("--build198x", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument("--output", type=Path, required=True)
    p.add_argument(
        "--kickstart",
        type=Path,
        default=Path.home() / ".emu198x/roms/commodore-amiga/kick13.rom",
    )
    args = p.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    expected = build(args.assembler, args.build198x, out)
    sources = SOURCES
    sym = T.symbols(out / "demo.sym")
    m = T.Machine(
        [
            args.emulator,
            "--mcp",
            "--model",
            "a500",
            "--kickstart",
            str(args.kickstart),
            "--disk",
            str(out / "demo.adf"),
        ]
    )
    try:
        bases = []
        for _ in range(20):
            m.call("run_frames", frames=100)
            scan = m.call("memory_scan", start=0, end=0x80000, value=0x31393858)
            T.require(not scan["truncated"], "Truncated marker scan")
            bases = [
                int(h["addr"][1:], 16) - sym["signature"]
                for h in scan["hits"]
                if T.memory(
                    m, int(h["addr"][1:], 16) - sym["signature"] + sym["ready"], 2, True
                )
                == 0xCAFE
            ]
            if bases:
                break
        T.require(len(bases) == 1, "Caller did not finish uniquely")
        raw = bytearray()
        for offset in range(0, 4096, 256):
            raw.extend(
                m.call("memory_read", addr=bases[0] + sym["output"] + offset, len=256)[
                    "bytes"
                ]
            )
        T.require(raw == expected, "Edge or updated-history mismatch")
        T.require(any(raw), "Empty output cannot pass")
    finally:
        m.close()
    report = {
        "status": "passed",
        "cases": 1024,
        "sources": {str(s.relative_to(ROOT)): sha(s) for s in sources},
        "observer_sha256": sha(Path(__file__)),
        "emulator_sha256": sha(Path(args.emulator)),
        "firmware_sha256": sha(args.kickstart),
        "assembler_sha256": sha(Path(shutil.which(args.assembler) or args.assembler)),
        "build198x_sha256": sha(Path(args.build198x)),
        # The disk the machine boots, so the checker can rebuild it.
        "programs": {"demo.adf": sha(out / "demo.adf")},
        "limits": __doc__,
    }
    (out / "results.json").write_text(json.dumps(report, indent=2) + "\n")
    print("PASS all 1,024 edge/history transitions")


if __name__ == "__main__":
    main()
