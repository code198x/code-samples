"""Run the counted-byte Z80 parser against the same independent command oracle.

48K RAM snapshot, synthetic ROM, DI, code/stack in uncontended RAM. This is not
ROM keyboard, timing/contention, original-hardware or complete-game evidence.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import shutil
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


def program(cases: list[str], code: str, tables: str, init: bool = True) -> str:
    """The caller that parses each case into $B000 onwards."""
    body = "    call parser_init\n" if init else ""
    text = "    org $a0fc\n"
    for i, value in enumerate(cases):
        body += f"    ld a,254\n    ld (verb_id),a\n    ld a,253\n    ld (noun_id),a\n    ld hl,message_{i}\n    ld bc,{len(value)}\n    call parse_command\n    ld (${0xB000 + i * 3:04x}),a\n    ld a,(verb_id)\n    ld (${0xB001 + i * 3:04x}),a\n    ld a,(noun_id)\n    ld (${0xB002 + i * 3:04x}),a\n"
        # Guard byte after every counted span must not be read or written.
        text += (
            f"message_{i}: defb "
            + ",".join(map(str, value.encode("latin1") + b"\xff"))
            + "\n"
        )
    return E.caller(body, code + "\n" + tables, text)


def jobs() -> list[dict]:
    """Every caller the recorder runs, in order, with its oracle."""
    code = (FOLDER / "parser.inc").read_text()
    tables = V.compile_tables(json.loads((FOLDER / "vocabulary.json").read_text()))
    cases = command_cases()
    out = [
        {
            "name": f"commands-{i // 10}",
            "cases": cases[i : i + 10],
            "code": code,
            "tables": tables,
        }
        for i in range(0, len(cases), 10)
    ]
    out.append(
        {
            "name": "not-ready",
            "cases": ["LOOK"],
            "code": code,
            "tables": tables,
            "init": False,
        }
    )
    out.append(
        {
            "name": "custom",
            "cases": ["open box", "OPEN", "LOOK", "OPEN LAMP"],
            "code": code,
            "tables": V.compile_tables(
                {
                    "verbs": [{"word": "OPEN", "id": 17, "noun_policy": 1}],
                    "nouns": [{"word": "BOX", "id": 23}],
                }
            ),
            "verbs": {"OPEN": (17, 1)},
            "nouns": {"BOX": 23},
        }
    )
    mutant = code.replace(
        "    cp 3\n    jp nc,parse_extra", "    cp 4\n    jp nc,parse_extra"
    )
    assert mutant != code
    out.append(
        {
            "name": "negative-extra-word",
            "cases": ["TAKE LAMP EXTRA"],
            "code": mutant,
            "tables": tables,
            "mutant": True,
        }
    )
    return out


def command_cases() -> list[str]:
    return O.command_cases() + [
        "L" + chr(255),
        "LOOK" + chr(128),
        "L" + " " * 254,
        "L" + " " * 255,
    ]


def build_programs(assembler: str, output: str) -> None:
    """Assemble every caller into output/<job>/caller.sna, without the emulator."""
    for job in jobs():
        E.assemble(
            Path(output) / job["name"],
            program(job["cases"], job["code"], job["tables"], job.get("init", True)),
            assembler,
        )


def batch(job: dict, out: Path, args: argparse.Namespace) -> None:
    cases = job["cases"]
    init = job.get("init", True)
    verbs = job.get("verbs", O.VERBS)
    nouns = job.get("nouns", O.NOUNS)
    size = sum(len(value) + 1 for value in cases)
    actual = E.execute(
        out,
        program(cases, job["code"], job["tables"], init),
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
    cases = command_cases()
    rejected = False
    for job in jobs():
        if not job.get("mutant"):
            batch(job, args.output / job["name"], args)
            continue
        try:
            batch(job, args.output / job["name"], args)
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
        "assembler_sha256": O.sha(Path(shutil.which(args.assembler) or args.assembler)),
        # Each caller snapshot the machine loads, so the checker can rebuild it.
        "programs": {
            f"{job['name']}/caller.sna": O.sha(args.output / job["name"] / "caller.sna")
            for job in jobs()
        },
        "limits": __doc__,
    }
    (args.output / "results.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
