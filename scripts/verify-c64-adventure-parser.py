"""Qualify the C64 BASIC parser through stock firmware and independent command rules."""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, file):
    s = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


A = module("adventure", "verify-adventure-parser.py")
T = A.T
F = ROOT / "commodore-64/patterns/basic/input/two-word-parser"
V = F / "verification"
VARIANTS = (
    "working",
    "custom",
    "wrong",
    "repaired",
    "typed",
    "no-nouns",
    "bad-count",
    "bad-word",
    "bad-id",
    "bad-policy",
    "duplicate",
    "alias-policy",
    "uninitialised",
)


def source_paths():
    return [
        F / n
        for n in (
            "caller.bas",
            "parser.bas",
            "vocabulary.bas",
            "custom-vocabulary.bas",
            "wrong-rule.bas",
            "Makefile",
        )
    ] + [
        Path(__file__),
        ROOT / "scripts/verify-adventure-parser.py",
        ROOT / "scripts/verify-game-loops.py",
    ]


def commands():
    values = [
        "",
        " ",
        "  ",
        "LOOK",
        "L",
        "TAKE LAMP",
        "GET LIGHT",
        " TAKE   LAMP ",
        "LOOK LAMP",
        "TAKE",
        "SEARCH",
        "SEARCH DOOR",
        "GO NORTH",
        "GO N",
        "INVENTORY",
        "WAIT",
        "X KEY",
        "QUIT",
        "BOGUS",
        "TAKE BOGUS",
        "TAKE LAMPPOST",
        "LOOKOUT",
        "TAKE LAMP KEY",
        "LOOK !",
        "TAKE LAMP!",
        "A" * 13,
        "TAKE " + "B" * 13,
        " " * 63,
        " " * 64,
        "0",
        "TAKE 0",
        "LOOK\t",
        "TAKE\nLAMP",
        "LOOK,LAMP",
        "TAKE-LAMP",
        "TAKE  LAMP  ",
    ]
    values += list(A.VERBS) + ["TAKE " + n for n in A.NOUNS]
    values += [
        "".join(chr(ord(c) + 128) if "A" <= c <= "Z" else c for c in "TAKE LAMP"),
        "take lamp",
        "LOOK" + chr(160),
    ]
    return values


def oracle(text, custom=False, no_nouns=False):
    if len(text) > 63:
        return [2, 0, 0]
    normal = ""
    for c in text:
        n = ord(c)
        n = n - 128 if 193 <= n <= 218 else n
        if n != 32 and not 48 <= n <= 57 and not 65 <= n <= 90:
            return [3, 0, 0]
        normal += chr(n)
    verbs = {"LOOK": (1, 0), "TURN": (51, 1)} if custom else A.VERBS
    nouns = {} if no_nouns else {"COG": 52} if custom else A.NOUNS
    return list(A.oracle(normal, verbs, nouns))


def vocabulary(name):
    if name == "custom":
        return (F / "custom-vocabulary.bas").read_text()
    if name == "no-nouns":
        return '7000 DATA 2,0\n7010 DATA "LOOK",1,0,"TAKE",3,1\n'
    errors = {
        "bad-count": "7000 DATA 0,0\n",
        "bad-word": '7000 DATA 1,0\n7010 DATA "LOOK!",1,0\n',
        "bad-id": '7000 DATA 1,0\n7010 DATA "LOOK",0,0\n',
        "bad-policy": '7000 DATA 1,0\n7010 DATA "LOOK",1,3\n',
        "duplicate": '7000 DATA 2,0\n7010 DATA "LOOK",1,0,"LOOK",2,0\n',
        "alias-policy": '7000 DATA 2,0\n7010 DATA "LOOK",1,0,"L",1,1\n',
    }
    return errors.get(name, (F / "vocabulary.bas").read_text())


def selected_commands(name):
    return (
        ["LOOK", "TURN COG", "TURN", "TURN LAMP", "LOOK COG"]
        if name == "custom"
        else ["LOOK", "TAKE LAMP"]
        if name == "no-nouns"
        else commands()
    )


def canonical(text):
    lines = [line for line in text.splitlines() if line.strip()]
    numbers = [int(l.split()[0]) for l in lines]
    T.require(len(set(numbers)) == len(numbers), "Duplicate line")
    return "\n".join(sorted(lines, key=lambda l: int(l.split()[0]))) + "\n"


def source(name):
    parser = (F / "parser.bas").read_text()
    if name == "wrong":
        parser = parser.replace(
            "5330 IF O$=E$(I) THEN NI=Z(I)", (F / "wrong-rule.bas").read_text().strip()
        )
    if name == "uninitialised":
        caller = '10 A$="LOOK":GOSUB 5000\n20 POKE 49152,S:POKE 49153,V:POKE 49154,N:POKE 49155,239:POKE 53247,239\n30 PRINT "STATUS";S\n40 GOTO 40\n'
    elif name == "typed":
        caller = (F / "caller.bas").read_text()
    elif name.startswith("bad-") or name in ("duplicate", "alias-policy"):
        caller = '10 RESTORE:GOSUB 6000\n20 POKE 49152,S:POKE 49153,PR:POKE 53247,239\n30 PRINT "DICTIONARY STATUS";S\n40 GOTO 40\n'
    else:
        caller = "10 POKE 53280,0:POKE 53281,0:PRINT CHR$(147);CHR$(5)\n20 RESTORE:GOSUB 6000\n30 IF PR<>1 THEN END\n35 J0=TI\n"
        for i, text in enumerate(selected_commands(name)):
            expr = (
                ('"' + text + '"')
                if all(32 <= ord(c) <= 90 and c != '"' for c in text)
                else '""' + "".join("+CHR$(" + str(ord(c)) + ")" for c in text)
            )
            caller += f"{100 + i * 2} A$={expr}:GOSUB 5000\n{101 + i * 2} POKE {49152 + i * 4},S:POKE {49153 + i * 4},V:POKE {49154 + i * 4},N:POKE {49155 + i * 4},239\n"
        final = "TURN COG" if name == "custom" else "TAKE LAMPPOST"
        caller += f'1980 JT=TI-J0\n1981 IF JT<0 THEN JT=JT+5184000\n1990 A$="{final}":GOSUB 5000\n2000 ZC=FRE(0):PRINT "{final}":PRINT "STATUS";S;"VERB";V;"NOUN";N\n2010 POKE 53247,239\n2020 GOTO 2020\n'
    return canonical(caller + parser + vocabulary(name))


def number(v):
    if v[0] == 0:
        return 0
    mantissa = 1 + int.from_bytes(bytes([v[1] & 127] + v[2:]), "big") / (2**31)
    return (-1 if v[1] & 128 else 1) * mantissa * (2 ** (v[0] - 129))


def run(args, name):
    out = F / "build/verification" / name
    out.mkdir(parents=True, exist_ok=True)
    src = source(name)
    (out / "program.bas").write_text(src)
    subprocess.run(
        [
            str(args.build198x),
            "basic",
            str(out / "program.bas"),
            "--machine",
            "commodore-c64",
            "-o",
            str(out / "demo.prg"),
        ],
        check=True,
        capture_output=True,
        timeout=30,
    )
    prg = (out / "demo.prg").read_bytes()
    snapshot = out / "import.vsf"
    script = out / "import.json"
    script.write_text(json.dumps([{"action": "save_snapshot", "path": str(snapshot)}]))
    subprocess.run(
        [
            str(args.emulator),
            "--model",
            "pal",
            "--rom-dir",
            str(args.firmware),
            "--load",
            str(out / "demo.prg"),
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

    def read(a, n):
        return [
            v
            for i in range(0, n, 128)
            for v in m.call("memory_read", addr=a + i, len=min(128, n - i))["bytes"]
        ]

    def layout():
        w = read(0x2B, 14)
        word = lambda i: int.from_bytes(bytes(w[i : i + 2]), "little")
        start, end, ary, strings, free = word(0), word(2), word(4), word(6), word(8)
        memtop = int.from_bytes(bytes(read(0x37, 2)), "little")
        raw = read(end, ary - end)
        scalars = {}
        for i in range(0, len(raw), 7):
            v = raw[i : i + 7]
            if len(v) == 7 and not (v[0] & 128 or v[1] & 128):
                scalars["".join(chr(n) for n in v[:2] if n)] = number(v[2:])
        token = read(start, end - start)
        lines = []
        at = 0
        while at + 4 < len(token):
            next_line = int.from_bytes(bytes(token[at : at + 2]), "little")
            if not next_line:
                break
            n = int.from_bytes(bytes(token[at + 2 : at + 4]), "little")
            length = next_line - start - at
            T.require(
                length > 4 and at + length <= len(token), "Invalid native BASIC line"
            )
            lines.append([n, length])
            at += length
        return {
            "program_bytes": end - start,
            "scalar_bytes": ary - end,
            "array_bytes": strings - ary,
            "allocated_string_bytes": memtop - free,
            "variables_raw": raw,
            "scalars": scalars,
            "lines": lines,
            "parser_token_bytes": sum(
                length for n, length in lines if 5000 <= n <= 6560
            ),
            "dictionary_token_bytes": sum(length for n, length in lines if n >= 7000),
        }

    try:
        m.call("load_snapshot", path=str(snapshot))
        loaded = read(2049, len(prg) - 2)
        T.require(loaded == list(prg[2:]), "Loaded tokenized program differs")
        m.call("type_string", text="RUN\n", hold_frames=3, settle_frames=8)
        samples = []
        if name == "typed":
            for _ in range(40):
                m.call("run_frames", frames=50)
                current = layout()
                if current["scalars"].get("PR") == 1:
                    break
            T.require(
                current["scalars"].get("PR") == 1,
                "Typed caller dictionary did not initialise",
            )
            m.call("run_frames", frames=50)
            for text in ("TAKE LAMP", "LOOK", "TAKE LAMPPOST"):
                typed = m.call(
                    "type_string", text=text + "\n", hold_frames=3, settle_frames=8
                )
                T.require(typed["chars_typed"] == len(text) + 1, "Incomplete command")
                m.call("run_frames", frames=70)
                state = layout()
                a = [int(state["scalars"][k]) for k in ("S", "V", "N")]
                T.require(a == oracle(text), "Typed INPUT parser result differs")
                samples.append({"input": text, "result": a, "layout": state})
            result = {"samples": samples, "layout": samples[-1]["layout"]}
        else:
            for _ in range(80):
                m.call("run_frames", frames=50)
                if read(53247, 1) == [239]:
                    break
            T.require(read(53247, 1) == [239], "Native caller did not complete")
            count = (
                2
                if name.startswith("bad-") or name in ("duplicate", "alias-policy")
                else 4
                if name == "uninitialised"
                else len(selected_commands(name)) * 4
            )
            raw = read(49152, count)
            if name == "uninitialised":
                T.require(raw == [9, 0, 0, 239], "Uninitialised parser accepted input")
            elif count == 2:
                T.require(raw == [10, 0], "Bad dictionary accepted")
            else:
                expected = [
                    v
                    for text in selected_commands(name)
                    for v in oracle(text, name == "custom", name == "no-nouns") + [239]
                ]
                equal = raw == expected
                T.require(
                    equal == (name != "wrong"), "Native parser/prefix control differs"
                )
            result = {"bytes": raw, "layout": layout()}
        screen = read(1024, 1000)
        rom = (args.firmware / "chargen.rom").read_bytes()
        glyphs = {str(c): list(rom[c * 8 : c * 8 + 8]) for c in set(screen)}
        image = V / (name + ".png")
        m.call("run_frames", frames=3)
        m.call("save_screenshot", path=str(image))
        return result | {
            "prg_bytes": list(prg),
            "loaded_bytes": loaded,
            "program_sha256": A.sha(out / "demo.prg"),
            "source_sha256": __import__("hashlib").sha256(src.encode()).hexdigest(),
            "screen": screen,
            "visible_glyphs": glyphs,
            "image": image.name,
            "image_sha256": T.sha(image),
            "server": m.server["serverInfo"],
        }
    except Exception:
        m.call("save_screenshot", path=str(V / (name + "-diagnostic.png")))
        (V / (name + "-diagnostic.json")).write_text(
            json.dumps(
                {
                    "screen": read(1024, 1000),
                    "parser_bank": read(49152, 16),
                    "layout": layout(),
                },
                indent=2,
            )
        )
        raise
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for n in ("build198x", "emulator", "firmware"):
        p.add_argument("--" + n, type=Path, required=True)
    p.add_argument("--variants", default=",".join(VARIANTS))
    a = p.parse_args()
    V.mkdir(exist_ok=True)
    cfg = {n + "_sha256": T.sha(getattr(a, n)) for n in ("build198x", "emulator")}
    cfg["roms"] = {
        n: T.sha(a.firmware / n) for n in ("basic.rom", "kernal.rom", "chargen.rom")
    }
    (V / "configuration.json").write_text(json.dumps(cfg, indent=2) + "\n")
    target = V / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"system": "commodore-64", "language": "basic", "cases": {}}
    )
    r.update(
        configuration=cfg,
        sources={str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
    )
    for name in a.variants.split(","):
        T.require(name in VARIANTS, "Unknown variant")
        r["cases"][name] = run(a, name)
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(name, "passed", flush=True)


if __name__ == "__main__":
    main()
