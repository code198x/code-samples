"""Validate native rectangle evidence against independent geometry and pixels."""

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


V = module("native", "verify-c64-rectangle-overlap.py")
P = module("png", "check-amiga-command-loops.py")
T = V.T


def pixels(c, cfg):
    w, h, ch, rgba = P.png(V.V / c["image"])
    T.require((w, h, ch) == (416, 312, 4), "Wrong capture geometry")
    for cell, code in enumerate(c["row"]):
        glyph = cfg["glyphs"][str(code)]
        for y in range(8):
            for x in range(8):
                pos = ((51 + cell // 40 * 8 + y) * w + 48 + cell % 40 * 8 + x) * ch
                color = (
                    (255, 255, 255, 255) if glyph[y] & (128 >> x) else (0, 0, 0, 255)
                )
                T.require(
                    tuple(rgba[pos : pos + 4]) == color,
                    "PNG does not show native rectangles/result",
                )


def tables(count_text, table_text):
    cases = V.C.cases()
    T.require(
        count_text == "CASE_COUNT = " + str(len(cases)) + "\n",
        "Changed case count include",
    )
    expected = "case_table:\n" + "".join(
        "    !byte " + ",".join(map(str, c["a"] + c["b"])) + "\n" for c in cases
    )
    T.require(table_text == expected, "Changed case table include")


def check(record=None):
    tables((V.F / "cases.inc").read_text(), (V.F / "case-table.inc").read_text())
    r = record if record is not None else json.loads((V.V / "results.json").read_text())
    cfg = json.loads((V.V / "configuration.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("commodore-64", "assembly"), "Wrong route"
    )
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source/observer",
    )
    T.require(
        r["configuration"] == cfg and cfg["model"] == "C64 PAL, stock ROMs",
        "Changed configuration",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing case")
    expected = [c["expected"] for c in V.C.cases()]
    T.require(
        len(expected) == 184 and 0 in expected and 1 in expected,
        "Empty/one-sided oracle",
    )
    for name, c in r["cases"].items():
        T.require(
            c["guards"] == [165, 239] and c["stop"]["reached"],
            "Incomplete native caller",
        )
        T.require(
            len(c["bytes"]) == len(expected) and all(n in (0, 1) for n in c["bytes"]),
            "Invalid native booleans",
        )
        T.require(
            (c["bytes"] == expected) == (name != "wrong"), "Intersection oracle differs"
        )
        if name == "wrong":
            T.require(
                c["bytes"][1] == 1 and c["bytes"][7] == 0,
                "Fault did not distinguish touching/empty",
            )
        T.require(
            c["row"] == V.screen(name)
            and c["result"] == (1 if name in ("demo", "wrong") else 0),
            "Wrong grid/result",
        )
        T.require(
            len(c["loaded_bytes"]) == c["payload_bytes"]
            and hashlib.sha256(bytes([1, 8] + c["loaded_bytes"])).hexdigest()
            == c["loaded_sha256"],
            "Changed loaded program",
        )
        T.require(
            c["helper_code_bytes"] == (76 if name == "wrong" else 68)
            and c["helper_state_bytes"] == 8,
            "Wrong helper costs",
        )
        T.require(c["server"]["version"] == "0.44.2", "Wrong producer")
        T.require(T.sha(V.V / c["image"]) == c["image_sha256"], "Changed image")
        pixels(c, cfg)
    T.require(
        r["cases"]["custom"]["loaded_sha256"]
        == r["cases"]["repaired"]["loaded_sha256"],
        "Repair differs from correct custom caller",
    )


if __name__ == "__main__":
    check()
    print(
        "C64 rectangles: 4 native callers, 184 cases each, common fault and PNGs passed"
    )
