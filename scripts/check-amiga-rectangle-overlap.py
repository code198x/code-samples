"""Check native word rectangles, relocated instructions and visible output."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    if spec is None or spec.loader is None:
        raise RuntimeError(file)
    v = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(v)
    return v


V = module("native", "verify-amiga-rectangle-overlap.py")
P = module("png", "check-amiga-command-loops.py")
T = V.T


def glyph(result):
    return (
        [24, 56, 24, 24, 24, 24, 126, 0] if result else [60, 66, 70, 74, 82, 98, 60, 0]
    )


def pixels(c):
    w, h, ch, p = P.png(V.V / c["image"])
    T.require((w, h, ch) == (768, 576, 4), "Wrong native geometry")
    actual = {
        (i // ch % w, i // ch // w)
        for i in range(0, len(p), ch)
        if tuple(p[i : i + 4]) == (255, 255, 255, 255)
    }
    expected = {
        (466 + x * 2 + dx, 136 + y * 2 + dy)
        for y, b in enumerate(glyph(c["result"]))
        for x in range(8)
        if b & (128 >> x)
        for dx in range(2)
        for dy in range(2)
    }
    T.require(actual == expected and len(actual) > 0, "PNG does not show result glyph")


def tables(count_text, table_text):
    cases = V.C.cases(65535)
    T.require(
        count_text == "CASE_COUNT equ " + str(len(cases)) + "\n",
        "Changed case count include",
    )
    expected = "case_table:\n" + "".join(
        "    dc.w " + ",".join(map(str, c["a"] + c["b"])) + "\n" for c in cases
    )
    T.require(table_text == expected, "Changed case table include")


def check(record=None):
    tables((V.F / "cases.inc").read_text(), (V.F / "case-table.inc").read_text())
    r = record if record is not None else json.loads((V.V / "results.json").read_text())
    cfg = json.loads((V.V / "configuration.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("commodore-amiga", "assembly"), "Wrong route"
    )
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source/observer",
    )
    T.require(r["configuration"] == cfg, "Changed configuration")
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing case")
    expected = [c["expected"] for c in V.C.cases(65535)]
    T.require(len(expected) == 184 and 0 in expected and 1 in expected, "Empty oracle")
    for name, c in r["cases"].items():
        T.require(
            c["guards"] == [0xCAFE, 0xBABE] and 0 < c["base"] < 0x80000,
            "Caller did not complete",
        )
        T.require(
            len(c["bytes"]) == len(expected)
            and (c["bytes"] == expected) == (name != "wrong"),
            "Word interval oracle differs",
        )
        if name == "wrong":
            T.require(
                c["bytes"][1] == 1 and c["bytes"][7] == 0, "Missing equality symptom"
            )
        T.require(
            c["result"] == (1 if name in ("demo", "wrong") else 0), "Wrong result"
        )
        raw = zlib.decompress(bytes.fromhex(c["hunk_zlib"]))
        T.require(
            hashlib.sha256(raw).hexdigest() == c["executable_sha256"]
            and len(raw) == c["executable_bytes"],
            "Changed executable",
        )
        body, relocs = V.hunk(raw)
        for i in relocs:
            body[i : i + 4] = (
                int.from_bytes(body[i : i + 4], "big") + c["base"]
            ).to_bytes(4, "big")
        T.require(
            len(c["segments"]) == 3 and c["segments"][0]["first"] == 0,
            "Missing code segments",
        )
        for seg in c["segments"]:
            T.require(
                seg["last"] > seg["first"]
                and seg["bytes"] == list(body[seg["first"] : seg["last"]]),
                "Native relocated code/data differs",
            )
        plane = zlib.decompress(bytes.fromhex(c["plane_zlib"]))
        wanted = bytearray(10240)
        for y, b in enumerate(glyph(c["result"])):
            wanted[1984 + y * 40] = b
        T.require(
            plane == wanted
            and c["display_bytes"] == len(plane)
            and c["state_bytes"] == 16
            and c["code_bytes"] > 0,
            "Plane/costs differ",
        )
        T.require(
            c["server"]["version"] == "0.44.2"
            and T.sha(V.V / c["image"]) == c["image_sha256"],
            "Changed producer/image",
        )
        pixels(c)
    T.require(
        r["cases"]["custom"]["executable_sha256"]
        == r["cases"]["repaired"]["executable_sha256"],
        "Repair differs",
    )


if __name__ == "__main__":
    check()
    print(
        "Amiga rectangles: native word edges, relocation, plane and PNG checks passed"
    )
