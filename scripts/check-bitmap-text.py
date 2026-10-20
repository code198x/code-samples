"""Recompute complete retained text evidence; missing observations must fail."""

from __future__ import annotations

import argparse
import importlib.util
import json
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "text_observer", ROOT / "scripts/verify-bitmap-text.py"
)
assert spec and spec.loader
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
M = V.M
C = V.C
S = V.S
require = V.require


def check(c, folder=None):
    folder = (
        folder
        or ROOT / c["folder"] / "patterns/assembly/rendering/bitmap-text/verification"
    )
    r = json.loads((folder / "results.json").read_text())
    require(r["machine_id"] == c["machine_id"], "Machine identity differs")
    require(
        r["sources"] == {str(p.relative_to(ROOT)): V.V.T.sha(p) for p in V.sources(c)},
        "Source binding differs",
    )
    tools = {t["tool"]: t for t in json.loads((S / "toolchain.json").read_text())}
    require(
        r["tools"] == {k: tools[k]["binary_sha256"] for k in [c["binary"], "asm198x"]},
        "Tool identity differs",
    )
    used = set()
    for name, digest in r["artifacts"].items():
        require(Path(name).name == name, "Escaped artifact path")
        require(V.V.T.sha(folder / name) == digest, "Artifact checksum differs")

    def memory(o):
        used.add(o["memory"])
        data = zlib.decompress((folder / o["memory"]).read_bytes())
        require(len(data) == c["length"], "Truncated memory")
        return data

    def capture(o, grid, match=True):
        used.add(o["capture"])
        actual = V.V.PNG.raster(folder / o["capture"])
        expected = M.P.frame(c, grid)
        require(actual[0] == expected[0], "Native dimensions differ")
        different = sum(
            actual[1][i : i + 4] != expected[1][i : i + 4]
            for i in range(0, len(actual[1]), 4)
        )
        require(
            different == 0 if match else different > 0,
            "Independent native pixels differ" if match else "Fault is invisible",
        )
        if not match:
            require(different == o["pixel_mismatches"], "Fault pixel count differs")

    p = r["positive"]
    syms = p["symbols"]
    startup = V.normal(
        c,
        {
            "id": "startup",
            "kind": "string",
            "xy": [21, 37],
            "bytes": list(b"PIXEL TEXT"),
            "mode": 1,
            "source_ptr": syms["label_data"],
        },
        syms,
    )
    require(p["startup"]["request"] == startup, "Wrong direct caller")
    require(p["startup"]["mailbox"] == "00ef", "Direct caller incomplete")
    grid = [bytearray(c["width"]) for _ in range(c["height"])]
    expected = M.evaluate(c, grid, startup)
    V.status(c, bytes.fromhex(p["startup"]["context"]), V.inputs(c, startup), expected)
    require(memory(p["startup"]) == M.P.packed(c, grid), "Direct caller memory differs")
    capture(p["startup"], grid)
    expected_guards = p["guards"]
    require(len(expected_guards) == len(V.segments(c)), "Missing guard")
    for i, (_, size) in enumerate(V.segments(c)):
        require(len(bytes.fromhex(expected_guards[i])) == size, "Truncated guard")
        require(
            expected_guards[i]
            == (
                bytes((x * 19 + 71) & 255 for x in range(size)).hex()
                if i < 4
                else p["startup"]["guards"][i]
            ),
            "Initial guard differs",
        )
    require(
        bytes.fromhex(p["synthetic_font"]) == M.SYNTHETIC
        and bytes.fromhex(p["rom_font"]) == M.DEFAULT,
        "Font source differs",
    )
    grid = [
        bytearray((x * 3 + y * 5) % (c["pen_max"] + 1) for x in range(c["width"]))
        for y in range(c["height"])
    ]
    padding = 165 if c["machine_id"] == "amstrad-cpc" else 0
    require(p["padding"] == padding, "Padding baseline differs")
    cases = C.cases(c)
    require(len(p["cases"]) == len(cases) > 0, "Missing executed case")
    scene = False
    for i, (o, case) in enumerate(zip(p["cases"], cases, strict=True)):
        request = V.normal(c, case, syms)
        require(
            o["request"] == request and o["id"] == request["id"],
            "Case identity differs",
        )
        require(
            o["mailbox"] == "00ef" and 0 < o["observed_frames"] <= 1024,
            "Request did not complete",
        )
        require(o["guards"] == expected_guards, "Guard changed")
        require(
            bytes.fromhex(o["source"])
            == bytes(request.get("bytes", [])).ljust(256, b"\xa5"),
            "String source changed",
        )
        require(
            o["font"] == p["synthetic_font"] and o["rom_font"] == p["rom_font"],
            "Font source changed",
        )
        if request.get("scene") and not scene:
            grid = [bytearray(c["width"]) for _ in range(c["height"])]
            scene = True
        expected = M.evaluate(c, grid, request)
        V.status(c, bytes.fromhex(o["context"]), V.inputs(c, request), expected)
        require(
            memory(o) == M.P.packed(c, grid, padding),
            "Independent complete bitmap differs: " + o["id"],
        )
        need = i % 16 == 0 or bool(request.get("scene"))
        require(("capture" in o) == need, "Required native capture missing")
        if need:
            capture(o, grid)
    require(
        set(r["faults"]) == {"glyph-fault", "advance-fault"}, "Missing completed fault"
    )
    for name, o in r["faults"].items():
        request = V.normal(
            c,
            {
                "id": name,
                "kind": "string",
                "xy": [21, 37],
                "bytes": list(b"WAVE"),
                "mode": 1,
            },
            syms,
        )
        require(
            o["request"] == request
            and o["mailbox"] == "00ef"
            and bytes.fromhex(o["context"])[17] == 1,
            "Fault not an accepted completed draw",
        )
        require(
            o["guards"] == o["guard_before"] and 0 < o["observed_frames"] <= 1024,
            "Fault escaped bounds",
        )
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        M.evaluate(c, grid, request)
        different = sum(
            a != b for a, b in zip(memory(o), M.P.packed(c, grid), strict=True)
        )
        require(
            different > 0 and different == o["memory_mismatches"],
            "Fault did not fail memory check",
        )
        capture(o, grid, False)
    require(used == set(r["artifacts"]), "Missing or unreferenced artifact")
    return {"calls": len(cases) + 1, "faults": 2}


def check_all():
    configs = json.loads((S / "systems.json").read_text())
    require(
        len(configs) == 4
        and {c["machine_id"] for c in configs}
        == {"spectrum", "acorn-bbc-micro", "dragon", "amstrad-cpc"},
        "Incomplete text registry",
    )
    return {c["machine_id"]: check(c) for c in configs}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.parse_args()
    for name, result in check_all().items():
        print(name, "PASS", result)
