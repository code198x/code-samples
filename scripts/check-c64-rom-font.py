"""Check ROM-font proof without redistributing the complete licensed character ROM."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, file):
    s = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


V = module("native", "verify-c64-rom-font.py")
P = module("png", "check-amiga-command-loops.py")
T = V.T


def pixels(c):
    w, h, ch, p = P.png(V.V / c["image"])
    T.require((w, h, ch) == (416, 312, 4), "Wrong C64 native geometry")
    for y in range(200):
        for x in range(320):
            code = c["screen"][(y // 8) * 40 + x // 8]
            glyph = c["visible_glyphs"][str(code)]
            on = bool(glyph[y % 8] & (128 >> (x % 8)))
            i = ((y + 51) * w + x + 48) * ch
            T.require(
                (tuple(p[i : i + 3]) != (0, 0, 0)) == on and p[i + 3] == 255,
                "PNG differs from displayed glyph",
            )


def check(record=None):
    r = record if record is not None else json.loads((V.V / "results.json").read_text())
    cfg = json.loads((V.V / "configuration.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("commodore-64", "assembly")
        and r["configuration"] == cfg,
        "Changed configuration/route",
    )
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing case")
    for name, c in r["cases"].items():
        T.require(c["server"]["version"] == "0.44.2", "Wrong producer")
        prg = bytes(c["prg_bytes"])
        T.require(
            prg[:2] == b"\x01\x08"
            and V.digest(prg) == c["program_sha256"]
            and c["loaded_bytes"] == list(prg[2:]),
            "PRG identity differs",
        )
        src = (
            V.fixture()
            if name == "rom-boundaries"
            else (V.F / (name + ".asm")).read_text()
        )
        T.require(V.digest(src.encode()) == c["source_sha256"], "Caller differs")
        if name == "rom-boundaries":
            T.require(len(c["boundaries"]) == 6, "Incomplete boundaries")
            for i, b in enumerate(c["boundaries"]):
                row = b["row"]
                port = (53, 53, 53, 55, 52, 53)[i]
                ddr = (47, 46, 47, 47, 47, 47)[i]
                T.require(
                    b["stop"]["reached"]
                    and row[:3] == ([0, 0, 0] if i < 4 else [1, 0, 8])
                    and row[3] & 15 == port & 15
                    and row[4] & 13 == 13
                    and row[5] == ddr
                    and row[6:] == [165, 239],
                    "Boundary state differs",
                )
                expected = (
                    V.digest([165] * 2048) if i < 4 else cfg["rom_halves"][int(i == 5)]
                )
                T.require(
                    b["font_sha256"] == expected, "Rejected write/selected ROM differs"
                )
            continue
        a = c["initial"]
        half = int(name == "rom-custom")
        T.require(
            a["stop"]["reached"]
            and a["status"] == 1
            and a["writes"] == [0, 8]
            and a["port"] & 15 == 5,
            "Init state differs",
        )
        T.require(
            c["expected_initial_sha256"] == cfg["rom_halves"][half], "Wrong ROM half"
        )
        equal = [
            a["font_sha256"] == c["expected_initial_sha256"],
            c["installed_sha256"] == c["expected_installed_sha256"],
            c["patched_sha256"] == c["expected_patched_sha256"],
        ]
        T.require(
            equal == [name != "rom-wrong"] * 3,
            "Wrong-bank fault/repair not distinguished",
        )
        screen = V.BANNER + [32] * (1024 - len(V.BANNER))
        T.require(a["screen_sha256"] == V.digest(screen), "Initializer changed screen")
        screen[82:84] = [1, 1]
        T.require(
            c["screen"] == screen
            and c["visible_glyphs"]["1"] == list(V.PATTERNS[8:])
            and c["changes"] == 1,
            "Shared replacement/hold differs",
        )
        T.require(
            c["guards"] == [[165] * 16] * 2
            and c["inputs"][2:] == [1, 1, 1, 83, 0]
            and c["wrapper_code_bytes"] == 102,
            "Guards/input/cost differs",
        )
        T.require(T.sha(V.V / c["image"]) == c["image_sha256"], "Changed image")
        pixels(c)
    T.require(
        r["cases"]["rom-demo"]["program_sha256"]
        == r["cases"]["rom-repaired"]["program_sha256"],
        "Repair differs",
    )


if __name__ == "__main__":
    check()
    print("C64 ROM font: stock load, selected half, state, replacement and PNGs passed")
