"""Compare stock-BASIC tile queries and text regions with independent outputs.

Loads source through each machine's real keyboard. Restricted ROMs stay local.
This checks BASIC text regions, not native graphical tile/scrolling adapters.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
OBSERVER_SHA = T.sha(Path(__file__))
TRANSPORT_SHA = T.sha(ROOT / "scripts/verify-game-loops.py")
SYSTEMS = [
    "acorn-atom",
    "amstrad-cpc",
    "atari-800xl",
    "commodore-pet",
    "commodore-vic-20",
    "dragon-32",
    "mattel-aquarius",
    "msx",
    "oric-atmos",
    "spectravideo-svi-328",
]
ALIASES = {"dragon-32": "dragon", "msx": "microsoft-msx", "oric-atmos": "oric"}


def raster(path: Path) -> tuple[tuple[int, int], bytes]:
    """Decode PNG filters before comparing every pixel of the native capture."""
    data = path.read_bytes()
    T.require(data[:8] == b"\x89PNG\r\n\x1a\n", "Not a PNG")
    at = 8
    chunks = []
    width = height = channels = 0
    while at < len(data):
        length = struct.unpack_from(">I", data, at)[0]
        kind, payload = data[at + 4 : at + 8], data[at + 8 : at + 8 + length]
        if kind == b"IHDR":
            width, height, depth, colour, _, _, interlace = struct.unpack(
                ">IIBBBBB", payload
            )
            T.require(
                depth == 8 and colour in (2, 6) and interlace == 0,
                "Unsupported capture format",
            )
            channels = 3 if colour == 2 else 4
        elif kind == b"IDAT":
            chunks.append(payload)
        at += length + 12
    T.require(width > 0 and height > 0 and bool(chunks), "Empty capture")
    raw = zlib.decompress(b"".join(chunks))
    stride = width * channels
    previous = bytearray(stride)
    rows = []
    for y in range(height):
        method = raw[y * (stride + 1)]
        row = bytearray(raw[y * (stride + 1) + 1 : (y + 1) * (stride + 1)])
        T.require(method in range(5), "Unknown PNG filter")
        for x in range(stride):
            a = row[x - channels] if x >= channels else 0
            b = previous[x]
            c = previous[x - channels] if x >= channels else 0
            predictor = 0
            if method == 1:
                predictor = a
            elif method == 2:
                predictor = b
            elif method == 3:
                predictor = (a + b) // 2
            elif method == 4:
                p = a + b - c
                distances = [abs(p - a), abs(p - b), abs(p - c)]
                predictor = (a, b, c)[distances.index(min(distances))]
            row[x] = (row[x] + predictor) & 255
        rows.append(bytes(row))
        previous = row
    return (width, height), b"".join(rows)


def printed(system: str, expression: str, newline: bool = True) -> str:
    if system == "acorn-atom":
        return "PRINT " + expression.replace(";", ",") + ("'" if newline else "")
    return "PRINT " + expression + ("" if newline else ";")


def demo_reference(system: str, source: str) -> str:
    body = ['"BEFORE"']
    before = ["11111111", "10000001", "10020001", "10003001", "10000001", "11111111"]
    body += [json.dumps(row) for row in before]
    body += ['"TILE";2;" FLAGS";2', '"AFTER"']
    body += [json.dumps(row.replace("10020001", "10030001")) for row in before]
    body += ['"DONE"']
    return (
        "\n".join(
            [line for line in source.splitlines() if int(line.split()[0]) == 5]
            + [
                f"{90 + i * 10} {printed(system, value)}"
                for i, value in enumerate(body)
            ]
            + ["900 END"]
        )
        + "\n"
    )


def cases(
    system: str, source: str, kind: str, reference: bool = False
) -> tuple[str, int]:
    """Independent caller expectations; use a non-square logical map for reads."""
    atom = system == "acorn-atom"
    code = []
    expected = []
    count = 0
    m = [
        1
        if y in (0, 5) or x in (0, 7)
        else 2
        if (x, y) == (3, 2)
        else 3
        if (x, y) == (4, 3)
        else 0
        for y in range(6)
        for x in range(8)
    ]

    def add(actual: str, expression: str | None = None) -> None:
        code.append(actual)
        if expression is not None:
            expected.append(printed(system, expression))

    def number_line(actual: str, values: list[int | float]) -> None:
        nonlocal count
        add(actual, ";".join(map(str, values)))
        count += 1

    if kind == "queries":
        code += [
            "W=7:H=5",
            "FOR R=0 TO H-1",
            "FOR C=0 TO W-1",
            "GOSUB 1000",
            "PRINT CHR$(65+E);CHR$(66+T);",
            "NEXT C",
            "PRINT",
            "NEXT R",
        ]
        for row in range(5):
            text = "".join("B" + chr(66 + m[row * 7 + c]) for c in range(7))
            if system in ("mattel-aquarius", "msx", "spectravideo-svi-328"):
                # These keyboards' typed literal letters and CHR$ byte codes select different
                # cases. Expect the byte codes emitted by this caller directly.
                for offset in range(0, len(text), 4):
                    codes = ";".join(
                        f"CHR$({ord(ch)})" for ch in text[offset : offset + 4]
                    )
                    expected.append(
                        printed(system, codes, newline=offset + 4 >= len(text))
                    )
            else:
                expected.append(printed(system, json.dumps(text)))
        count += 35
        points = [(-1, 0), (0, -1), (7, 0), (0, 5), (255, 255)]
        if not atom:
            points += [(1.5, 0), (0, 1.5)]
        for c, r in points:
            number_line(f"C={c}:R={r}:GOSUB 1000:PRINT E;T", [0, -1])
        code += ["P(2)=7", "FOR T=0 TO L", "GOSUB 1200", "PRINT F;", "NEXT T", "PRINT"]
        expected.append(printed(system, "0;1;7;4"))
        count += 4
        for tile in [-1, 4]:
            number_line(f"T={tile}:GOSUB 1200:PRINT E;F", [0, -1])
    elif kind == "writes":
        for c, r, v in [
            (-1, 0, 3),
            (0, -1, 3),
            (8, 0, 3),
            (0, 6, 3),
            (0, 0, -1),
            (0, 0, 4),
        ] + ([] if atom else [(0, 0, 1.5)]):
            number_line(f"C={c}:R={r}:V={v}:GOSUB 1100:PRINT E", [0])
        # Read every cell after rejected writes: no silent change is allowed.
        code += [
            "FOR R=0 TO H-1",
            "FOR C=0 TO W-1",
            "GOSUB 1000",
            "PRINT CHR$(48+T);",
            "NEXT C",
            "PRINT",
            "NEXT R",
        ]
        expected += [
            printed(
                system, json.dumps("".join(str(t) for t in m[row * 8 : row * 8 + 8]))
            )
            for row in range(6)
        ]
        count += 48
        number_line("C=0:R=0:V=3:GOSUB 1100:GOSUB 1000:PRINT E;T", [1, 3])
        number_line("C=3:R=2:GOSUB 1000:PRINT E;T", [1, 2])
    elif kind == "pixels":
        points = [(0, 0), (7, 7), (8, 8), (63, 47), (64, 0), (-1, 0), (0, -1), (0, 48)]
        if not atom:
            points += [(7.9, 15.9)]
        for x, y in points:
            if x < 0 or y < 0:
                values = [0, -1, -1, -1]
            else:
                c, r = int(x // 8), int(y // 8)
                valid = 0 <= c < 8 and 0 <= r < 6
                values = [int(valid), c, r, m[r * 8 + c] if valid else -1]
            number_line(f"X={x}:Y={y}:GOSUB 1300:PRINT E;C;R;T", values)
        number_line("S=0:X=0:Y=0:GOSUB 1300:PRINT E;C;R;T", [0, -1, -1, -1])
    elif kind == "region":
        for q, u, a, b in [
            (-1, 0, 2, 2),
            (0, -1, 2, 2),
            (0, 0, 0, 2),
            (0, 0, 2, 0),
            (7, 0, 2, 2),
            (0, 5, 2, 2),
        ] + ([] if atom else [(0.5, 0, 2, 2)]):
            number_line(f"Q={q}:U={u}:A={a}:B={b}:GOSUB 1400:PRINT E", [0])
        add("Q=2:U=1:A=3:B=2:GOSUB 1400")
        expected += [printed(system, '"000"'), printed(system, '"020"')]
        number_line("PRINT E", [1])
    else:
        raise ValueError(kind)
    if atom:
        code = [
            s.replace("P(", "PP(")
            .replace("PRINT CHR$(65+E);CHR$(66+T);", "PRINT $(65+E),$(66+T)")
            .replace("PRINT CHR$(48+T);", "PRINT $(48+T)")
            .replace("PRINT E;T", "PRINT E,T'")
            .replace("PRINT E;F", "PRINT E,F'")
            .replace("PRINT E;C;R;T", "PRINT E,C,R,T'")
            .replace(
                "PRINT E",
                "PRINT E'" if s == "PRINT E" or s.endswith(":PRINT E") else "PRINT E",
            )
            for s in code
        ]
        code = [s.replace("PRINT F;", "PRINT F,") for s in code]
        code = ["PRINT'" if s == "PRINT" else s for s in code]
        # Integer BASIC has no INT or fractional input cases.
        code = [s.replace(":", ";") for s in code]
    body = expected if reference else code
    prefix = [
        line
        for line in source.splitlines()
        if int(line.split()[0]) == 5 or (not reference and int(line.split()[0]) < 90)
    ]
    # Keep query outputs compact; the completion marker is handled by the runner.
    program = prefix + [f"{90 + i * 10} {s}" for i, s in enumerate(body)]
    program += ["880 " + printed(system, '"DONE"'), "900 END"]
    if not reference:
        program += [
            line for line in source.splitlines() if int(line.split()[0]) >= 1000
        ]
    return "\n".join(program) + "\n", count


def completed(machine, system: str) -> tuple[bool, str]:
    if system in ("amstrad-cpc", "msx", "spectravideo-svi-328"):
        value = machine.call("memory_read", addr=40000, len=1)["bytes"]
        return value == [239], str(value)
    else:
        address, length, width = {
            "acorn-atom": (0x8000, 512, 32),
            "atari-800xl": (0, 960, 40),
            "commodore-pet": (0x8000, 1000, 40),
            "commodore-vic-20": (0x1E00, 506, 22),
            "dragon-32": (0x0400, 512, 32),
            "mattel-aquarius": (0x3000, 1000, 40),
            "oric-atmos": (0xBB80, 1120, 40),
        }[system]
        if system == "atari-800xl":
            ptr = machine.call("memory_read", addr=0x58, len=2)["bytes"]
            address = ptr[0] + 256 * ptr[1]
        raw = []
        for offset in range(0, length, 200):
            raw += machine.call(
                "memory_read",
                addr=address + offset,
                len=min(200, length - offset),
            )["bytes"]
        text = ""
        for value in raw:
            value &= 63 if system in ("acorn-atom", "dragon-32") else 127
            if system == "atari-800xl":
                ch = chr(value + 32) if value < 64 else " "
            elif system in ("oric-atmos", "mattel-aquarius"):
                ch = chr(value) if 32 <= value < 127 else " "
            else:
                ch = (
                    chr(value + 64)
                    if 1 <= value <= 26
                    else chr(value)
                    if 32 <= value < 64
                    else " "
                )
            text += ch
        lines = "\n".join(text[i : i + width] for i in range(0, length, width))
        return bool(re.search(r"(?mi)^ *DONE *$", lines)), lines


def verify(system: str, args: argparse.Namespace) -> dict:
    folder = ROOT / system / "patterns/basic/rendering/tile-map"
    out = folder / "build/verification"
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    name = {"msx": "msx", "dragon-32": "dragon"}.get(system, system)
    executable = args.native / f"emu198x-{name}"
    if not executable.is_file():
        executable = (
            args.native / f"emu198x-{name}-aarch64-apple-darwin" / f"emu198x-{name}"
        )
    firmware = args.firmware_root / ALIASES.get(system, system)
    command = [str(executable), "--mcp", "--rom-dir", str(firmware)]
    if system == "msx":
        command = [str(executable), "--mcp", "--bios", str(firmware / "msx.rom")]

    entry = None
    entry_repairs = []
    if system == "oric-atmos":
        entry_spec = importlib.util.spec_from_file_location(
            "oric_entry", ROOT / "scripts/tilemap_oric_entry.py"
        )
        assert entry_spec and entry_spec.loader
        entry = importlib.util.module_from_spec(entry_spec)
        entry_spec.loader.exec_module(entry)
        entry_sha = T.sha(ROOT / "scripts/tilemap_oric_entry.py")

    def run(source: str, label: str) -> tuple[tuple[int, int], bytes]:
        # Reserve one completion byte only in this verification caller.
        if system in ("amstrad-cpc", "msx", "spectravideo-svi-328"):
            reserve = "MEMORY 39999" if system == "amstrad-cpc" else "CLEAR 200,39999"
            lines = ["1 " + reserve, "2 POKE 40000,0"]
            for line in source.splitlines():
                if line.endswith(" END"):
                    number = int(line.split()[0])
                    lines.append(f"{number - 1} POKE 40000,239")
                lines.append(line)
            source = "\n".join(lines) + "\n"
        # Hold after the final output so ROM prompts and blinking cursors cannot
        # make two identical pictures differ. The distributed caller still ENDs.
        source = (
            "\n".join(
                f"{line.split()[0]} GOTO {line.split()[0]}"
                if line.endswith(" END")
                else line
                for line in source.splitlines()
            )
            + "\n"
        )
        selected_command = command.copy()
        if system == "mattel-aquarius" and label not in (
            "demo",
            "reference",
            "wrong-stride",
        ):
            selected_command += ["--expansion-kb", "16"]
        machine = T.Machine(selected_command)
        try:
            machine.call(
                "run_frames",
                frames=900
                if system in ("spectravideo-svi-328", "atari-800xl")
                else 150,
            )
            if system == "mattel-aquarius":
                machine.call("type_string", text="\n", settle_frames=60)

            def type_line(line: str) -> None:
                timing = {"hold_frames": 3} if entry else {}
                reply = machine.call(
                    "type_string", text=line + "\n", settle_frames=3, **timing
                )
                T.require(
                    reply["chars_typed"] == len(line) + 1, f"Incomplete entry: {line}"
                )

            for line in source.splitlines():
                type_line(line)
            if entry:
                entry_repairs.append(
                    entry.ensure(machine, source, firmware / "oric.rom", type_line)
                )
            machine.call("type_string", text="RUN\n", settle_frames=3)
            done = False
            detail = ""
            for _ in range(30):
                machine.call("run_frames", frames=60)
                done, detail = completed(machine, system)
                if done:
                    break
            T.require(done, f"{system} {label}: caller did not complete: {detail}")
            machine.call("run_frames", frames=2)
            capture = (out / f"{label}.png").resolve()
            machine.call("save_screenshot", path=str(capture))
            print(system, label, flush=True)
            return raster(capture)
        finally:
            machine.close()

    source = (folder / "demo.bas").read_text()
    routines = (folder / "routines.bas").read_text()
    T.require(
        source[source.index("1000 E=") :] == routines,
        "Distributed routines differ from executed caller",
    )
    actual = run(source, "demo")
    reference = run(demo_reference(system, source), "reference")
    T.require(
        actual == reference,
        f"{system}: text-region output differs from independent PRINT reference",
    )
    needle = "D=R*W+C"
    T.require(source.count(needle) == 1, "Ambiguous stride mutant")
    wrong = run(source.replace(needle, "D=R*(W-1)+C"), "wrong-stride")
    T.require(wrong != reference, f"{system}: wrong stride was not rejected")
    counts = {}
    for kind in ["queries", "writes", "pixels", "region"]:
        program, counts[kind] = cases(system, source, kind)
        expected, _ = cases(system, source, kind, reference=True)
        T.require(
            run(program, kind) == run(expected, kind + "-reference"),
            f"{system}: {kind} differs from independent expectations",
        )
    result = {
        "case_counts": counts,
        "status": "passed",
        "system": system,
        "configuration": "Stock BASIC; keyboard-loaded text-region caller"
        + (
            "; demo unexpanded, larger query harness uses 16 KB expansion"
            if system == "mattel-aquarius"
            else ""
        ),
        "sources": {
            str(p.relative_to(ROOT)): T.sha(p)
            for p in [folder / "demo.bas", folder / "routines.bas"]
        },
        "observer_sha256": OBSERVER_SHA,
        "transport_sha256": TRANSPORT_SHA,
        "emulator_sha256": T.sha(executable),
        "firmware": {p.name: T.sha(p) for p in firmware.glob("*.rom")},
        "demo_matches_independent_text_reference": True,
        "wrong_stride_rejected": True,
        "comparison": "Whole decoded native capture; verification caller holds after output before any ROM prompt",
        "limits": "Text-cell rendering, not native bitmap/tile hardware, scrolling, frame timing or original-hardware verification.",
    }
    if entry:
        result["sources"]["scripts/tilemap_oric_entry.py"] = entry_sha
        result["keyboard_readback_repairs"] = entry_repairs
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print("PASS", system, flush=True)
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument(
        "--firmware-root", type=Path, default=Path.home() / ".emu198x/roms"
    )
    parser.add_argument("--only", choices=SYSTEMS)
    args = parser.parse_args()
    for system in [args.only] if args.only else SYSTEMS:
        verify(system, args)


if __name__ == "__main__":
    main()
