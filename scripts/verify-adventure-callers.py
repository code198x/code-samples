"""ROM-load the unmodified BASIC adventure and Z80 command inspector; type commands.

Pixel text is decoded from the configured ROM font; Z80 results are read from
named state. These are paced keyboard tests, not a guarantee for every typing speed.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASIC = ROOT / "sinclair-zx-spectrum/patterns/basic/input/two-word-parser"
ASM = ROOT / "sinclair-zx-spectrum/patterns/assembly/input/two-word-parser"


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


O = load("oracle", ROOT / "scripts/verify-adventure-parser.py")
P = load("pixels", ROOT / "scripts/verify-basic-library-routines.py")
T = O.T


def text(m, rom: bytes) -> str:
    bitmap = bytearray()
    for offset in range(0, 6144, 256):
        bitmap.extend(m.call("memory_read", addr=0x4000 + offset, len=256)["bytes"])
    glyphs = {rom[0x3C00 + c * 8 : 0x3C00 + c * 8 + 8]: chr(c) for c in range(32, 128)}
    rows = []
    for row in range(22):
        line = ""
        for column in range(32):
            glyph = bytes(
                bitmap[P.addr(row * 8 + s, column) - 0x4000] for s in range(8)
            )
            line += glyphs.get(glyph, "?")
        rows.append(line.rstrip())
    return "\n".join(rows)


def command(m, value: str, basic: bool = True) -> None:
    m.call("type_string", text=value, hold_frames=3, settle_frames=20)
    m.call("press_key", key="enter", hold_frames=3)
    m.call("run_frames", frames=150)
    if basic:
        for _ in range(200):
            if T.memory(m, 23621, 2) == 100:
                m.call("run_frames", frames=20)
                if T.memory(m, 23621, 2) == 100:
                    return
            m.call("run_frames", frames=25)
        raise ValueError("BASIC command did not return to INPUT line100")


def boot(folder: Path, tap: Path, args):
    m = T.Machine([args.emulator, "--mcp", "--rom", str(args.rom)])
    try:
        m.call("load_media", slot="tape-1", kind="tape", path=str(tap))
        m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
        for _ in range(60):
            m.call("run_frames", frames=250)
            if folder == ASM:
                symbols = T.symbols(ASM / "build/demo.sym")
                ready = T.memory(m, symbols["ready"], 2) == 0xCAFE
            else:
                ready = (
                    "THE LANTERN ROOM" in text(m, args.rom.read_bytes())
                    and T.memory(m, 23621, 2) == 100
                )
            if ready:
                m.call("run_frames", frames=100)
                break
        else:
            raise ValueError("Caller never reached its input prompt")
    except BaseException:
        m.close()
        raise
    return m


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--emulator", required=True)
    p.add_argument("--build198x", required=True)
    p.add_argument(
        "--rom",
        type=Path,
        default=Path.home() / ".emu198x/roms/sinclair-zx-spectrum-48k/48.rom",
    )
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    subprocess.run(
        ["make", "BUILD198X=" + args.build198x],
        cwd=BASIC,
        check=True,
        capture_output=True,
        text=True,
        timeout=30,
    )
    subprocess.run(
        ["make"], cwd=ASM, check=True, capture_output=True, text=True, timeout=30
    )
    rom = args.rom.read_bytes()
    checks = []
    m = boot(BASIC, BASIC / "build/demo.tap", args)
    try:
        seen = text(m, rom)
        if "THE LANTERN ROOM" not in seen:
            raise ValueError("Adventure did not reach its first prompt: " + seen)
        for i, (value, expected) in enumerate(
            [
                ("TAKE KEY", "cannot see"),
                ("GET LIGHT", "Taken."),
                ("EXAMINE LAMP", "no switch"),
                ("GO NORTH", "narrow hall"),
                ("GO NORTH", "locked"),
                ("TAKE KEY", "Taken."),
                ("GO NORTH", "courtyard"),
                ("INVENTORY", "small key"),
                ("GO SOUTH", "narrow hall"),
                ("DROP KEY", "Dropped."),
                ("GO NORTH", "courtyard"),
                ("TAKE LAM", "do not know the noun"),
                ("LOOK EXTRA", "does not take a noun"),
            ]
        ):
            command(m, value)
            seen = text(m, rom)
            (out / f"basic-{i}.txt").write_text(seen)
            if expected not in seen:
                m.call("save_screenshot", path=str(out / f"basic-{i}-failed.png"))
                raise ValueError(
                    f"Adventure command {value!r} missing {expected!r}: {seen}"
                )
            checks.append({"caller": "BASIC", "command": value, "visible": expected})
        m.call("save_screenshot", path=str(out / "basic-parser-error.png"))
        command(m, "LOOK")
        m.call("save_screenshot", path=str(out / "basic-adventure.png"))
    finally:
        m.close()
    # A caller variation with two visible objects of the same noun class must
    # refuse to choose arbitrarily. The parser itself remains unchanged.
    altered = (
        (BASIC / "build/program.bas")
        .read_text()
        .replace("LET l(2)=2: LET c(2)=2", "LET l(2)=1: LET c(2)=1")
    )
    if altered == (BASIC / "build/program.bas").read_text():
        raise ValueError("Ambiguity control did not alter the caller")
    (out / "ambiguity.bas").write_text(altered)
    subprocess.run(
        [
            args.build198x,
            "basic",
            "ambiguity.bas",
            "--machine",
            "sinclair-zx-spectrum",
            "-o",
            "ambiguity.tap",
        ],
        cwd=out,
        check=True,
        capture_output=True,
        text=True,
        timeout=30,
    )
    m = boot(out, out / "ambiguity.tap", args)
    try:
        command(m, "TAKE LAMP")
        seen = text(m, rom)
        if "Two match" not in seen:
            raise ValueError("Ambiguous objects were not refused: " + seen)
        checks.append(
            {
                "caller": "BASIC ambiguity variation",
                "command": "TAKE LAMP",
                "visible": "Two match",
            }
        )
        m.call("save_screenshot", path=str(out / "basic-ambiguity.png"))
    finally:
        m.close()
    sym = T.symbols(ASM / "build/demo.sym")
    m = boot(ASM, ASM / "build/demo.tap", args)
    try:
        T.require(T.memory(m, sym["ready"], 2) == 0xCAFE, "Inspector not ready")
        for value in [
            "take lamp",
            "LOOK",
            "TAKE",
            "TAKE LAMP EXTRA",
            "SEARCH",
            "GO ROCK",
        ]:
            command(m, value, basic=False)
            actual = tuple(
                T.memory(m, sym[n]) for n in ["parse_status", "verb_id", "noun_id"]
            )
            expected = O.oracle(value)
            if actual != expected:
                raise ValueError(f"Inspector {value!r}: {actual}, expected {expected}")
            checks.append({"caller": "Z80", "command": value, "result": actual})
        # Fill the real editor and reject a 64th character rather than execute
        # a truncated prefix. Deletion then clears that overflow state.
        command(m, "L" + " " * 63, basic=False)
        if T.memory(m, sym["parse_status"]) != 2:
            raise ValueError("Inspector executed a truncated input")
        command(m, "TAKE LAMP", basic=False)
        m.call("save_screenshot", path=str(out / "z80-inspector.png"))
        T.require(
            T.memory(m, sym["verb_id"]) == 3 and T.memory(m, sym["noun_id"]) == 1,
            "Inspector did not recover after overflow",
        )
    finally:
        m.close()
    sources = [
        BASIC / "demo.bas",
        BASIC / "parser.bas",
        BASIC / "vocabulary.bas",
        BASIC / "Makefile",
        ASM / "demo.asm",
        ASM / "parser.inc",
        ASM / "vocabulary.json",
        ASM / "generate_vocabulary.py",
        ASM / "Makefile",
        ASM / "../../framework/game-loop/frame.inc",
        ASM / "../../rendering/character-printing/characters.inc",
        ASM / "../../rendering/numeric-display/numeric.inc",
    ]
    sources += [
        ROOT / "scripts/verify-adventure-parser.py",
        ROOT / "scripts/verify-basic-library-routines.py",
        ROOT / "scripts/verify-game-loops.py",
    ]
    report = {
        "status": "passed",
        "checks": checks,
        "editor_overflow_rejected": True,
        "sources": {str(p.resolve().relative_to(ROOT)): O.sha(p) for p in sources},
        "observer_sha256": O.sha(Path(__file__)),
        "emulator_sha256": O.sha(Path(args.emulator)),
        "firmware_sha256": O.sha(args.rom),
        "limits": __doc__,
    }
    (out / "results.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
