"""Native boundary calls; snapshot the complete allocation around every request."""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
import tempfile
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "native", Path(__file__).with_name("verify-tia-maria.py")
)
assert SPEC and SPEC.loader
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)


def check(system: str, tools: Path) -> dict:
    name, ext = V.CONFIG[system]
    folder = V.ROOT / system / "patterns/assembly/rendering" / name
    is_tia = system == "atari-2600"
    context = "PF" if is_tia else "ML"
    # Each rejected call is surrounded by an independent whole-allocation snapshot.
    cases = (
        [(2, 20), (3, 24), (4, 2)]
        if is_tia
        else [(4, 0), (4, 32), (5, 8), (6, 153), (6, 160), (2, 255)]
    )
    blocks = []
    for index, (offset, value) in enumerate(cases):
        setup = (
            [(2, 0), (3, 0), (4, 1)] if is_tia else [(2, 0), (4, 2), (5, 0), (6, 32)]
        )
        setup.append((offset, value))
        code = ""
        for target, val in setup:
            code += f"    lda #{val}\n    sta {context}+{target}\n"
        blocks.append(
            code
            + f"before_{index}:\n    jsr "
            + ("pf_cell" if is_tia else "maria_append")
            + f"\nafter_{index}:\n"
        )
    if is_tia:
        # Invalid opaque stamps must not partly draw rows before discovering bad data.
        for index, (x, y, source) in enumerate(
            [(16, 0, "glyph"), (0, 18, "glyph"), (0, 0, "invalid_glyph")], len(cases)
        ):
            blocks.append(
                f"    lda #{x}\n    sta PF+2\n    lda #{y}\n    sta PF+3\n    lda #<{source}\n    sta PF\n    lda #>{source}\n    sta PF+1\nbefore_{index}:\n    jsr pf_stamp\nafter_{index}:\n"
            )
        count = len(cases) + 3
    else:
        count = len(cases)
        # Two remaining capacity slots are valid; the next append must reject.
        blocks.append(
            "    lda #0\n    sta ML+2\n    lda #32\n    sta ML+6\n    jsr maria_append\n    jsr maria_append\n"
            + f"before_{count}:\n    jsr maria_append\nafter_{count}:\n"
        )
        count += 1
    if is_tia:
        blocks.append("""
    ldx #71
    lda #$ff
seed_picture:
    sta PF_BUFFER,x
    dex
    bpl seed_picture
    jsr pf_clear
positive_clear:
    lda #0
    sta PF+2
    sta PF+3
    lda #1
    sta PF+4
    jsr pf_cell
positive_set:
    lda #0
    sta PF+4
    jsr pf_cell
positive_erase:
    lda #<glyph
    sta PF
    lda #>glyph
    sta PF+1
    lda #15
    sta PF+2
    lda #17
    sta PF+3
    jsr pf_stamp
positive_stamp:
""")
    else:
        blocks.append("""
    jsr maria_begin
positive_clear:
    lda #225
    sta ML+2
    lda #31
    sta ML+4
    lda #7
    sta ML+5
    lda #36
    sta ML+6
    jsr maria_append
positive_edge:
""")
    with tempfile.TemporaryDirectory(prefix="tia-maria-bounds-") as tmp:
        stage = Path(tmp)
        for path in folder.iterdir():
            if path.is_file():
                (stage / path.name).write_bytes(path.read_bytes())
        demo = stage / "demo.asm"
        text = demo.read_text().replace(
            "ready:", "".join(blocks) + "bounds_done:\n    jmp bounds_done\nready:"
        )
        if is_tia:
            text = text.replace(
                "glyph:\n", "invalid_glyph:\n    !byte 1,1,1,1,1,1,32\nglyph:\n"
            )
        demo.write_text(text)
        subprocess.run(
            ["make", f"ASM198X={tools / 'asm198x'}"],
            cwd=stage,
            check=True,
            capture_output=True,
            timeout=60,
        )
        syms = V.T.T.symbols(stage / "build/demo.sym")
        machine = V.T.T.Machine(
            [
                str(tools / f"emu198x-{system}"),
                "--mcp",
                "--cart",
                str(stage / f"build/demo.{ext}"),
            ]
        )
        try:
            for index in range(count):
                V.require(
                    machine.call(
                        "run_until_pc", addr=syms[f"before_{index}"], max_steps=100000
                    )["reached"],
                    "Before marker",
                )
                addr, size = (0x80, 72) if is_tia else (0x1900, 256)
                before = machine.call("memory_read", addr=addr, len=size)["bytes"]
                V.require(
                    machine.call(
                        "run_until_pc", addr=syms[f"after_{index}"], max_steps=1000
                    )["reached"],
                    "After marker",
                )
                after = machine.call("memory_read", addr=addr, len=size)["bytes"]
                V.require(
                    before == after,
                    f"{system} rejected case {index} changed allocation",
                )
                V.require(
                    V.T.T.memory(machine, syms[context] + (5 if is_tia else 8)) == 0,
                    "Rejection status",
                )

            def reach(label: str) -> None:
                V.require(
                    machine.call("run_until_pc", addr=syms[label], max_steps=100000)[
                        "reached"
                    ],
                    label,
                )

            reach("positive_clear")
            if is_tia:
                V.require(
                    machine.call("memory_read", addr=0x80, len=72)["bytes"] == [0] * 72,
                    "Clear seeded picture",
                )
                reach("positive_set")
                V.require(
                    machine.call("memory_read", addr=0x80, len=72)["bytes"]
                    == [16] + [0] * 71,
                    "Set first cell",
                )
                reach("positive_erase")
                V.require(
                    machine.call("memory_read", addr=0x80, len=72)["bytes"] == [0] * 72,
                    "Erase first cell",
                )
                reach("positive_stamp")
                expected = [0] * 72
                for y, bits in enumerate(V.GLYPH):
                    for x in range(5):
                        if bits & (1 << (4 - x)):
                            expected[(17 + y) * 3 + 2] |= 1 << (x + 3)
                V.require(
                    machine.call("memory_read", addr=0x80, len=72)["bytes"] == expected,
                    "Last-fitting stamp",
                )
                V.require(
                    V.T.T.memory(machine, syms[context] + 5) == 1, "Stamp accepted"
                )
            else:
                V.require(
                    machine.call("memory_read", addr=0x1900, len=2)["bytes"] == [0, 0],
                    "Begin terminates stale list",
                )
                V.require(
                    V.T.T.memory(machine, syms[context] + 7) == 0, "Begin resets count"
                )
                reach("positive_edge")
                expected = [225, 225, syms["graphics"] >> 8, 36, 0, 0]
                V.require(
                    machine.call("memory_read", addr=0x1900, len=6)["bytes"]
                    == expected,
                    "Maximum width/palette and exact source/visible end",
                )
                V.require(
                    V.T.T.memory(machine, syms[context] + 8) == 1, "Edge accepted"
                )
            return {
                "system": system,
                "rejected_calls": count,
                "positive_contracts": 4 if is_tia else 2,
                "whole_allocation_unchanged": True,
            }
        finally:
            machine.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--tools", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    result = [check(system, args.tools) for system in V.CONFIG]
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(result)
