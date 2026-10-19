"""Execute the BASIC parser under the 48K ROM against independent command rules.

Firmware stays local. These checks qualify the parser's declared input grammar,
not a whole adventure engine, unrestricted character encoding or original hardware.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import random
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "sinclair-zx-spectrum/patterns/basic/input/two-word-parser"
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
VERBS = {
    "LOOK": (1, 0),
    "L": (1, 0),
    "GO": (2, 1),
    "TAKE": (3, 1),
    "GET": (3, 1),
    "DROP": (4, 1),
    "INVENTORY": (5, 0),
    "I": (5, 0),
    "EXAMINE": (6, 1),
    "X": (6, 1),
    "QUIT": (7, 0),
    "HELP": (8, 0),
    "WAIT": (9, 0),
    "SEARCH": (10, 2),
}
NOUNS = {
    "LAMP": 1,
    "LIGHT": 1,
    "KEY": 2,
    "NORTH": 3,
    "N": 3,
    "SOUTH": 4,
    "S": 4,
    "DOOR": 5,
    "ROCK": 6,
}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def oracle(text: str, verbs: dict = VERBS, nouns: dict = NOUNS) -> tuple[int, int, int]:
    if len(text) > 63:
        return 2, 0, 0
    if any(
        c not in " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        for c in text
    ):
        return 3, 0, 0
    words = [w for w in text.upper().split(" ") if w]
    if not words:
        return 1, 0, 0
    if len(words) > 2:
        return 4, 0, 0
    if words[0] not in verbs:
        return 5, 0, 0
    verb, policy = verbs[words[0]]
    if len(words) == 1:
        return (7, 0, 0) if policy == 1 else (0, verb, 0)
    if policy == 0:
        return 8, 0, 0
    if words[1] not in nouns:
        return 6, 0, 0
    return 0, verb, nouns[words[1]]


def canonical(lines: list[str]) -> str:
    import re

    if any(re.search(r"\bFOR\s+[a-zA-Z][a-zA-Z0-9]+\s*=", line) for line in lines):
        raise ValueError("Sinclair FOR needs a single-letter control variable")
    numbers = [int(s.split()[0]) for s in lines if s.strip()]
    if len(numbers) != len(set(numbers)):
        raise ValueError("Overlapping BASIC line ranges")
    return (
        "\n".join(
            f"{int(s.split()[0]):4d} {s.split(maxsplit=1)[1]}"
            for s in sorted(lines, key=lambda s: int(s.split()[0]))
        )
        + "\n"
    )


def boot(
    lines: list[str], out: Path, args: argparse.Namespace, count: int
) -> list[int]:
    out.mkdir(parents=True, exist_ok=True)
    (out / "caller.bas").write_text(canonical(lines))
    r = subprocess.run(
        [
            args.build198x,
            "basic",
            "caller.bas",
            "--machine",
            "sinclair-zx-spectrum",
            "-o",
            "caller.tap",
        ],
        cwd=out,
        capture_output=True,
        text=True,
        timeout=30,
        check=False,
    )
    if r.returncode:
        raise ValueError(r.stdout + r.stderr)
    m = T.Machine([args.emulator, "--mcp", "--rom", str(args.rom)])
    try:
        m.call("load_media", slot="tape-1", kind="tape", path=str(out / "caller.tap"))
        m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
        for _ in range(80):
            m.call("run_frames", frames=250)
            if T.memory(m, 60000) == 202:
                break
        if T.memory(m, 60000) != 202:
            m.call("save_screenshot", path=str(out / "incomplete.png"))
            raise ValueError("ROM-loaded BASIC caller did not finish: " + str(out))
        result = []
        for offset in range(0, count, 256):
            result += m.call(
                "memory_read", addr=52000 + offset, len=min(256, count - offset)
            )["bytes"]
        m.call("save_screenshot", path=str(out / "finished.png"))
    finally:
        m.close()
    (out / "observations.json").write_text(json.dumps(result) + "\n")
    return result


def batch(
    cases: list[str],
    parser: str,
    vocabulary: str,
    out: Path,
    args: argparse.Namespace,
    verbs: dict = VERBS,
    nouns: dict = NOUNS,
    initialise: bool = True,
) -> None:
    lines = ["10 CLEAR 49999: LET pr=0: LET zz=52000"]
    if initialise:
        lines += ["20 GO SUB 6000: IF s<>0 THEN STOP"]
    for i, text in enumerate(cases):
        value = (
            '"' + text + '"'
            if all(32 <= ord(c) <= 126 and c != '"' for c in text)
            else "+".join("CHR$ " + str(ord(c)) for c in text)
        )
        if not value:
            value = '""'
        lines += [
            f"{100 + i * 10} LET a$={value}: LET v=254: LET n=253: GO SUB 5000: POKE zz,s: POKE zz+1,v: POKE zz+2,n: LET zz=zz+3"
        ]
    lines += ['1900 PRINT "Parser checks complete": POKE 60000,202: STOP']
    lines += parser.splitlines() + vocabulary.splitlines()
    data = boot(lines, out, args, len(cases) * 3)
    for i, text in enumerate(cases):
        expected = oracle(text, verbs, nouns) if initialise else (9, 0, 0)
        actual = tuple(data[i * 3 : i * 3 + 3])
        if actual != expected:
            raise ValueError(
                f"Parser result mismatch for {text!r}: expected {expected}, got {actual}"
            )


def command_cases() -> list[str]:
    cases = [
        "",
        " ",
        " " * 63,
        "LOOK",
        "look",
        "  tAkE   LiGhT  ",
        "TAKE",
        "TAKE LAMP EXTRA",
        "TAKE LAMP EXTRA WORD",
        "LOOK LAMP",
        "GO ZEBRA",
        "ZEBRA LAMP",
        "SEARCH",
        "SEARCH KEY",
        "GETTER LAMP",
        "TAKE LAM",
        "TAKE LAMPPOST",
        "LOOK\t",
        "TAKE\nLAMP",
        'TAKE "LAMP"',
        "TAKE LAMP.",
        "LO" + chr(127) + "K",
        "L" + chr(0),
        "L" + " " * 62,
        "L" + " " * 63,
        " " * 64,
        "A" * 13,
        "TAKE " + "A" * 13,
        "TAKE " + "A" * 59,
    ]
    for alias, (_, arity) in VERBS.items():
        cases += [alias.lower() + (" lamp" if arity == 1 else ""), alias + " ROCK"]
    for alias in NOUNS:
        cases += ["TAKE " + alias.lower(), "GO " + alias]
    rng = random.Random(198)
    for _ in range(30):
        words = [
            rng.choice(["look", "TAKE", "gO", "lamp", "KEY", "SEARCH", "xyz", "123"])
            for _ in range(rng.randrange(1, 5))
        ]
        cases.append(
            " " * rng.randrange(3)
            + (" " * rng.randrange(1, 4)).join(words)
            + " " * rng.randrange(3)
        )
    return cases


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
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "results.json").unlink(missing_ok=True)
    parser = (FOLDER / "parser.bas").read_text()
    vocab = (FOLDER / "vocabulary.bas").read_text()
    cases = command_cases()
    for i in range(0, len(cases), 30):
        batch(
            cases[i : i + 30], parser, vocab, args.output / f"commands-{i // 30}", args
        )
    batch(["LOOK"], parser, vocab, args.output / "not-ready", args, initialise=False)
    custom = '7000 DATA 1,1\n7010 DATA "OPEN",17,1\n7020 DATA "BOX",23\n'
    batch(
        ["open box", "OPEN", "LOOK", "OPEN LAMP"],
        parser,
        custom,
        args.output / "custom",
        args,
        {"OPEN": (17, 1)},
        {"BOX": 23},
    )
    boundary = '7000 DATA 1,1\n7010 DATA "ABCDEFGHIJKL",255,2,"MNOPQRSTUVWX",254\n'
    batch(
        ["abcdefghijkl mnopqrstuvwx", "ABCDEFGHIJKL", "ABCDEFGHIJK"],
        parser,
        boundary,
        args.output / "twelve-letter-ids",
        args,
        {"ABCDEFGHIJKL": (255, 2)},
        {"MNOPQRSTUVWX": 254},
    )
    batch(
        ["SEARCH", "SEARCH LAMP"],
        parser,
        '7000 DATA 1,0\n7010 DATA "SEARCH",10,2\n',
        args.output / "no-nouns",
        args,
        {"SEARCH": (10, 2)},
        {},
    )
    maximum = (
        "7000 DATA 32,32\n7010 DATA "
        + ",".join(f'"V{i:02d}",{i + 1},2' for i in range(32))
        + "\n7020 DATA "
        + ",".join(f'"N{i:02d}",{i + 1}' for i in range(32))
        + "\n"
    )
    batch(
        ["v31 n31", "V00 N00", "V31"],
        parser,
        maximum,
        args.output / "maximum-dictionary",
        args,
        {f"V{i:02d}": (i + 1, 2) for i in range(32)},
        {f"N{i:02d}": i + 1 for i in range(32)},
    )
    configs = [
        "7000 DATA 0,0",
        "7000 DATA 33,0",
        "7000 DATA 1.5,0",
        "7000 DATA 1,-1",
        "7000 DATA 1,33",
        '7000 DATA 1,0\n7010 DATA "look",1,0',
        '7000 DATA 1,0\n7010 DATA "",1,0',
        '7000 DATA 1,0\n7010 DATA "LONGWORDABCDE",1,0',
        '7000 DATA 1,0\n7010 DATA "A B",1,0',
        '7000 DATA 1,0\n7010 DATA "LOOK",0,0',
        '7000 DATA 1,0\n7010 DATA "LOOK",256,0',
        '7000 DATA 1,0\n7010 DATA "LOOK",1.5,0',
        '7000 DATA 1,0\n7010 DATA "LOOK",1,3',
        '7000 DATA 2,0\n7010 DATA "LOOK",1,0,"LOOK",2,0',
        '7000 DATA 2,0\n7010 DATA "LOOK",1,0,"L",1,1',
        '7000 DATA 1,2\n7010 DATA "TAKE",1,1,"LAMP",1,"LAMP",2',
        '7000 DATA 1,1\n7010 DATA "TAKE",1,1,"LAMP",0',
    ]
    for i, cfg in enumerate(configs):
        lines = (
            [
                "10 CLEAR 49999: GO SUB 6000: POKE 52000,s: POKE 52001,pr",
                '20 LET a$="LOOK": GO SUB 5000: POKE 52002,s: POKE 52003,v: POKE 52004,n',
                "30 POKE 60000,202: STOP",
            ]
            + parser.splitlines()
            + cfg.splitlines()
        )
        actual = boot(lines, args.output / f"config-{i}", args, 5)
        if actual != [10, 0, 9, 0, 0]:
            raise ValueError(f"Invalid vocabulary {i} accepted: {actual}")
    mutant = parser.replace("wc>2", "wc>3")
    assert mutant != parser
    rejected = False
    try:
        batch(
            ["TAKE LAMP EXTRA"],
            mutant,
            vocab,
            args.output / "negative-extra-word",
            args,
        )
    except ValueError as e:
        if not str(e).startswith("Parser result mismatch"):
            raise
        rejected = True
    if not rejected:
        raise ValueError("Broken extra-word parser passed the oracle")
    report = {
        "status": "passed",
        "command_cases": len(cases),
        "invalid_configurations": len(configs),
        "custom_vocabulary_cases": 12,
        "not_ready_cases": 1,
        "extra_word_mutant_rejected": rejected,
        "sources": {
            str(p.relative_to(ROOT)): sha(p)
            for p in [
                FOLDER / "parser.bas",
                FOLDER / "vocabulary.bas",
                ROOT / "scripts/verify-game-loops.py",
            ]
        },
        "observer_sha256": sha(Path(__file__)),
        "emulator_sha256": sha(Path(args.emulator)),
        "firmware_sha256": sha(args.rom),
        "build198x_sha256": sha(Path(args.build198x)),
        "limits": __doc__,
    }
    (args.output / "results.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
