"""Gate the independently executed BASIC and assembly rectangle routes."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    if spec is None or spec.loader is None:
        raise RuntimeError(file)
    v = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(v)
    return v


V = module("native", "verify-spectrum-rectangle-overlap.py")
P = module("png", "check-amiga-command-loops.py")
T = V.T


def pixels(c, lang):
    p = c["pixels"]
    text = str(c["result"])
    T.require(
        p["text"] == text and p["row"] == 0 and p["font_base"] == 15360,
        "Wrong rendered result/font",
    )
    wanted = [[p["glyphs"][str(ord(char))][y] for char in text] for y in range(8)]
    T.require(p["scanlines"] == wanted, "Native scanlines differ from result")
    w, h, ch, rgba = P.png(_image_root / c["image"])
    T.require((w, h, ch) == (352, 296, 4), "Wrong native geometry")
    for y, line in enumerate(wanted):
        for cell, bits in enumerate(line):
            for x in range(8):
                pos = ((48 + y) * w + 48 + cell * 8 + x) * ch
                ink, paper = (
                    ((0, 0, 0, 255), (194, 194, 194, 255))
                    if lang == "assembly"
                    else ((194, 194, 194, 255), (0, 0, 0, 255))
                )
                color = ink if bits & (128 >> x) else paper
                T.require(
                    tuple(rgba[pos : pos + 4]) == color,
                    "PNG differs from native result",
                )


def tables(count_text, table_text):
    cases = V.C.cases()
    T.require(
        count_text == "CASE_COUNT equ " + str(len(cases)) + "\n",
        "Changed case count include",
    )
    expected = "case_table:\n" + "".join(
        "    defb " + ",".join(map(str, c["a"] + c["b"])) + "\n" for c in cases
    )
    T.require(table_text == expected, "Changed case table include")


def check(lang, record=None):
    F = V.FS["assembly"]
    tables((F / "cases.inc").read_text(), (F / "case-table.inc").read_text())
    global _image_root
    _image_root = V.FS[lang] / "verification"
    r = (
        record
        if record is not None
        else json.loads((_image_root / "results.json").read_text())
    )
    cfg = json.loads((_image_root / "configuration.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("sinclair-zx-spectrum", lang), "Wrong route"
    )
    T.require(
        r["sources"]
        == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths(lang)},
        "Changed source/observer",
    )
    T.require(
        r["configuration"] == cfg and cfg["model"] == "Spectrum 48K PAL stock ROM",
        "Changed configuration",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing case")
    for name, c in r["cases"].items():
        T.require(
            len(c["loaded_bytes"]) > 0
            and hashlib.sha256(bytes(c["loaded_bytes"])).hexdigest()
            == c["payload_sha256"],
            "Changed loaded program",
        )
        T.require(c["server"]["version"] == "0.44.2", "Wrong producer")
        if lang == "assembly" or name == "boundaries":
            expected = (
                [c["expected"] for c in V.C.cases()]
                if lang == "assembly"
                else [c["expected"] + 1 for c in V.basic_cases()]
            )
            T.require(
                c["guards"] == [165, 239] and c["expected"] == expected,
                "Wrong guards/oracle",
            )
            T.require(
                len(c["bytes"]) == len(expected)
                and (c["bytes"] == expected) == (name != "wrong"),
                "Native geometry oracle differs",
            )
            if name == "wrong":
                T.require(
                    c["bytes"][1] == 1 and c["bytes"][7] == 0, "Wrong fault symptom"
                )
        if lang == "assembly":
            T.require(
                any(s["reached"] for s in c["stops"])
                and c["costs"]["state_bytes"] == 8
                and c["costs"]["code_bytes"] > 0,
                "No entry/costs",
            )
        else:
            T.require(
                c["costs"]["token_bytes"] == len(c["loaded_bytes"])
                and c["costs"]["variable_bytes"] > 0,
                "Wrong BASIC costs",
            )
        if name != "boundaries":
            T.require(
                c["result"] == (1 if name in ("demo", "wrong") else 0), "Wrong result"
            )
            if lang == "basic":
                T.require(
                    c["guards"] == [c["result"] + 1, 165], "BASIC caller incomplete"
                )
            T.require(
                T.sha(_image_root / c["image"]) == c["image_sha256"], "Changed image"
            )
            pixels(c, lang)
    T.require(
        r["cases"]["custom"]["payload_sha256"]
        == r["cases"]["repaired"]["payload_sha256"],
        "Repair differs",
    )


if __name__ == "__main__":
    for lang in V.FS:
        check(lang)
    print(
        "Spectrum rectangle routes: native cases, independent oracle, source/code/pixel gates passed"
    )
