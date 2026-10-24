"""Independently check native command results, loaded BASIC, costs and pixels."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, file):
    s = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


V = module("native", "verify-c64-adventure-parser.py")
P = module("png", "check-amiga-command-loops.py")
T = V.T


def pixels(c, name):
    w, h, ch, p = P.png(V.V / c["image"])
    T.require((w, h, ch) == (416, 312, 4), "Wrong native geometry")
    foreground, background = (
        ((255, 255, 255), (0, 0, 0))
        if name in ("working", "custom", "wrong", "repaired", "no-nouns")
        else ((120, 104, 192), (64, 49, 141))
    )
    on_count = 0
    for y in range(200):
        for x in range(320):
            code = c["screen"][(y // 8) * 40 + x // 8]
            g = c["visible_glyphs"][str(code)]
            on = bool(g[y % 8] & (128 >> (x % 8)))
            on_count += on
            i = ((51 + y) * w + 48 + x) * ch
            T.require(
                tuple(p[i : i + 3]) == (foreground if on else background)
                and p[i + 3] == 255,
                "PNG differs from native text",
            )
    T.require(on_count > 0, "Blank picture cannot pass")


def check(record=None):
    r = record if record is not None else json.loads((V.V / "results.json").read_text())
    cfg = json.loads((V.V / "configuration.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("commodore-64", "basic")
        and r["configuration"] == cfg,
        "Changed route/configuration",
    )
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source",
    )
    T.require(
        set(r["cases"]) == set(V.VARIANTS) and len(V.commands()) == 62,
        "Missing native cases",
    )
    for name, c in r["cases"].items():
        T.require(c["server"]["version"] == "0.44.2", "Wrong producer")
        prg = bytes(c["prg_bytes"])
        T.require(
            prg[:2] == b"\x01\x08"
            and hashlib.sha256(prg).hexdigest() == c["program_sha256"]
            and c["loaded_bytes"] == list(prg[2:]),
            "Loaded BASIC differs",
        )
        T.require(
            hashlib.sha256(V.source(name).encode()).hexdigest() == c["source_sha256"],
            "Caller source differs",
        )
        m = c["layout"]
        T.require(
            m["program_bytes"] == len(prg) - 2
            and m["scalar_bytes"] == len(m["variables_raw"])
            and m["scalar_bytes"] % 7 == 0
            and m["parser_token_bytes"]
            == sum(size for n, size in m["lines"] if 5000 <= n <= 6560)
            and m["dictionary_token_bytes"]
            == sum(size for n, size in m["lines"] if n >= 7000),
            "Native storage measurements differ",
        )
        # Follow the independently loaded BASIC links, rather than trusting reported costs.
        lines = []
        raw = list(prg[2:])
        at = 0
        while at + 4 < len(raw):
            nxt = int.from_bytes(bytes(raw[at : at + 2]), "little")
            if not nxt:
                break
            n = int.from_bytes(bytes(raw[at + 2 : at + 4]), "little")
            length = nxt - 2049 - at
            T.require(length > 4 and at + length <= len(raw), "Invalid BASIC link")
            lines.append([n, length])
            at += length
        T.require(lines == m["lines"], "Reported token lengths differ from PRG")
        if name == "typed":
            T.require(
                [s["input"] for s in c["samples"]]
                == ["TAKE LAMP", "LOOK", "TAKE LAMPPOST"],
                "Missing typed inputs",
            )
            for s in c["samples"]:
                expected = V.oracle(s["input"])
                T.require(
                    s["result"] == expected
                    and [int(s["layout"]["scalars"][k]) for k in ("S", "V", "N")]
                    == expected,
                    "Typed parser differs",
                )
        elif name == "uninitialised":
            T.require(
                c["bytes"] == [9, 0, 0, 239] and m["scalars"]["S"] == 9,
                "Uninitialised parser accepted input",
            )
        elif name.startswith("bad-") or name in ("duplicate", "alias-policy"):
            T.require(
                c["bytes"] == [10, 0]
                and m["scalars"]["PR"] == 0
                and m["scalars"]["S"] == 10,
                "Malformed dictionary accepted",
            )
        else:
            values = V.selected_commands(name)
            raw = c["bytes"]
            expected = [
                v
                for text in values
                for v in V.oracle(text, name == "custom", name == "no-nouns") + [239]
            ]
            T.require(
                len(raw) == len(expected) and raw[3::4] == [239] * len(values),
                "Incomplete guest results",
            )
            if name == "wrong":
                diffs = [
                    i
                    for i in range(len(values))
                    if raw[i * 4 : i * 4 + 3] != expected[i * 4 : i * 4 + 3]
                ]
                T.require(
                    diffs
                    and all(values[i] == "TAKE LAMPPOST" for i in diffs)
                    and raw[
                        values.index("TAKE LAMPPOST") * 4 : values.index(
                            "TAKE LAMPPOST"
                        )
                        * 4
                        + 3
                    ]
                    == [0, 3, 1],
                    "Prefix fault differs",
                )
            else:
                T.require(raw == expected, "Independent command oracle differs")
            nv, nn = (
                (2, 1)
                if name == "custom"
                else (2, 0)
                if name == "no-nouns"
                else (14, 9)
            )
            T.require(
                m["array_bytes"] == 35 + 13 * (nv + 1) + 8 * (nn + 2)
                and m["scalars"]["JT"] > 0
                and m["scalars"]["PR"] == 1
                and m["allocated_string_bytes"] >= 0,
                "Native dictionary ownership/cost differs",
            )
        T.require(
            len(c["screen"]) == 1000 and T.sha(V.V / c["image"]) == c["image_sha256"],
            "Changed capture",
        )
        pixels(c, name)
    T.require(
        r["cases"]["working"]["program_sha256"]
        == r["cases"]["repaired"]["program_sha256"],
        "Repair differs",
    )


if __name__ == "__main__":
    check()
    print(
        "C64 BASIC parser: native commands, typed INPUT, dictionaries, costs and PNGs passed"
    )
