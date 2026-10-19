"""Run the counted-byte Z80 parser against the same independent command oracle.

48K RAM snapshot, synthetic ROM, DI, code/stack in uncontended RAM. This is not
ROM keyboard, timing/contention, original-hardware or complete-game evidence.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "sinclair-zx-spectrum/patterns/assembly/input/two-word-parser"


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


O = load("oracle", ROOT / "scripts/verify-adventure-parser.py")
E = load("cpu", ROOT / "scripts/verify-z80-library-routines.py")
V = load("vocabulary", FOLDER / "generate_vocabulary.py")


def batch(
    cases: list[str],
    code: str,
    tables: str,
    out: Path,
    args: argparse.Namespace,
    init: bool = True,
    verbs: dict = O.VERBS,
    nouns: dict = O.NOUNS,
) -> None:
    body = "    call parser_init\n" if init else ""
    text = "    org $a0fc\n"
    size = 0
    for i, value in enumerate(cases):
        body += f"    ld a,254\n    ld (verb_id),a\n    ld a,253\n    ld (noun_id),a\n    ld hl,message_{i}\n    ld bc,{len(value)}\n    call parse_command\n    ld (${0xB000 + i * 3:04x}),a\n    ld a,(verb_id)\n    ld (${0xB001 + i * 3:04x}),a\n    ld a,(noun_id)\n    ld (${0xB002 + i * 3:04x}),a\n"
        # Guard byte after every counted span must not be read or written.
        text += (
            f"message_{i}: defb "
            + ",".join(map(str, value.encode("latin1") + b"\xff"))
            + "\n"
        )
        size += len(value) + 1
    actual = E.execute(
        out,
        E.caller(body, code + "\n" + tables, text),
        [(0xB000, len(cases) * 3), (0xA0FC, size)],
        args,
    )
    expected = []
    for value in cases:
        expected += list(O.oracle(value, verbs, nouns) if init else (9, 0, 0))
    if actual[0] != expected:
        raise ValueError(
            "Z80 command result mismatch: "
            + str(
                list(
                    zip(
                        cases,
                        [
                            tuple(actual[0][i : i + 3])
                            for i in range(0, len(expected), 3)
                        ],
                    )
                )
            )
        )
    if bytes(actual[1]) != b"".join(v.encode("latin1") + b"\xff" for v in cases):
        raise ValueError("Input or guard byte changed")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--emulator", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "results.json").unlink(missing_ok=True)
    code = (FOLDER / "parser.inc").read_text()
    tables = V.compile_tables(json.loads((FOLDER / "vocabulary.json").read_text()))
    cases = O.command_cases() + [
        "L" + chr(255),
        "LOOK" + chr(128),
        "L" + " " * 254,
        "L" + " " * 255,
    ]
    for i in range(0, len(cases), 10):
        batch(
            cases[i : i + 10], code, tables, args.output / f"commands-{i // 10}", args
        )
    batch(["LOOK"], code, tables, args.output / "not-ready", args, init=False)
    custom = V.compile_tables(
        {
            "verbs": [{"word": "OPEN", "id": 17, "noun_policy": 1}],
            "nouns": [{"word": "BOX", "id": 23}],
        }
    )
    batch(
        ["open box", "OPEN", "LOOK", "OPEN LAMP"],
        code,
        custom,
        args.output / "custom",
        args,
        verbs={"OPEN": (17, 1)},
        nouns={"BOX": 23},
    )
    mutant = code.replace(
        "    cp 3\n    jp nc,parse_extra", "    cp 4\n    jp nc,parse_extra"
    )
    assert mutant != code
    rejected = False
    try:
        batch(
            ["TAKE LAMP EXTRA"],
            mutant,
            tables,
            args.output / "negative-extra-word",
            args,
        )
    except ValueError as error:
        if not str(error).startswith("Z80 command result mismatch"):
            raise
        rejected = True
    if not rejected:
        raise ValueError("Extra-word mutant passed")
    symbols = O.T.symbols(args.output / "commands-0/caller.sym")
    report = {
        "status": "passed",
        "command_cases": len(cases),
        "not_ready_cases": 1,
        "custom_vocabulary_cases": 4,
        "extra_word_mutant_rejected": True,
        "parser_code_bytes": symbols["parser_code_end"] - symbols["parser_begin"],
        "parser_state_bytes": symbols["parser_end"] - symbols["parser_code_end"],
        "sources": {
            str(p.relative_to(ROOT)): O.sha(p)
            for p in [
                FOLDER / "parser.inc",
                FOLDER / "vocabulary.json",
                FOLDER / "generate_vocabulary.py",
                ROOT / "scripts/verify-z80-library-routines.py",
                ROOT / "scripts/verify-adventure-parser.py",
                ROOT / "scripts/verify-game-loops.py",
            ]
        },
        "observer_sha256": O.sha(Path(__file__)),
        "emulator_sha256": O.sha(Path(args.emulator)),
        "limits": __doc__,
    }
    (args.output / "results.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
