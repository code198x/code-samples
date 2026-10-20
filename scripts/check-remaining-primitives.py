"""Recompute retained linear/interleaved/Chip RAM memory and native-image outcomes."""

from __future__ import annotations

import argparse
import importlib.util
import json
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "extended_observer", ROOT / "scripts/verify-remaining-primitives.py"
)
assert spec and spec.loader
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
M = V.M
S = V.S
require = V.require


def check(c: dict[str, Any], folder: Path | None = None) -> dict[str, Any]:
    folder = (
        folder
        or ROOT
        / c["folder"]
        / "patterns/assembly/rendering/pixels-and-boxes/verification"
    )
    r = json.loads((folder / "results.json").read_text())
    require(r["machine_id"] == c["machine_id"], "Machine identity differs")
    require(
        r["sources"] == {str(p.relative_to(ROOT)): V.V.T.sha(p) for p in V.sources(c)},
        "Source bindings differ",
    )
    tools = {t["tool"]: t for t in json.loads((S / "toolchain.json").read_text())}
    require(
        r["tools"] == {k: tools[k]["binary_sha256"] for k in [c["binary"], "asm198x"]},
        "Tool identity differs",
    )
    used = set()
    for name, digest in r["artifacts"].items():
        require(
            Path(name).name == name and V.V.T.sha(folder / name) == digest,
            "Artifact path/hash differs",
        )

    def memory(o: dict[str, Any]) -> bytes:
        used.add(o["memory"])
        data = zlib.decompress((folder / o["memory"]).read_bytes())
        require(len(data) == c["length"], "Truncated memory")
        return data

    def capture(o: dict[str, Any], data: bytes | bytearray, match: bool = True) -> int:
        used.add(o["capture"])
        actual = V.V.PNG.raster(folder / o["capture"])
        expected = M.frame(c, data)
        require(actual[0] == expected[0], "Native dimensions differ")
        count = sum(
            actual[1][i : i + 4] != expected[1][i : i + 4]
            for i in range(0, len(actual[1]), 4)
        )
        require(
            count == 0 if match else count > 0,
            "Independent native pixels differ" if match else "Fault invisible",
        )
        if not match:
            require(count == o["pixel_mismatches"], "Fault pixel count differs")

    p = r["positive"]
    start = p["startup"]
    request = {"id": "startup", "kind": "box", "coords": [13, 27, 91, 53], "op": 0}
    require(
        start["request"] == request and start["mailbox"] == "00ef",
        "Direct caller did not complete",
    )
    data = M.baseline(c)
    expected = M.evaluate(c, data, request)
    require(memory(start) == bytes(data), "Direct caller bitmap differs")
    capture(start, data)
    actual = bytes.fromhex(start["context"])
    require(
        actual[:9] == V.inputs(c, request)[:9]
        and actual[9] == 1
        and int.from_bytes(actual[40:42], c["order"]) == expected["writes"],
        "Direct caller result differs",
    )
    guards = p["guards"]
    require(len(guards) == len(V.segments(c)), "Missing guard/display list")
    for i, (_, size) in enumerate(V.segments(c)):
        require(len(bytes.fromhex(guards[i])) == size, "Truncated guard")
        require(
            guards[i]
            == (
                bytes((x * 23 + 43) & 255 for x in range(size)).hex()
                if i < 2
                else start["guards"][i]
            ),
            "Initial guard differs",
        )
    cases = V.C.cases(c)
    require(len(p["cases"]) == len(cases) > 0, "Missing executed cases")
    data = M.baseline(c, True)
    scene = False
    for i, (o, request) in enumerate(zip(p["cases"], cases, strict=True)):
        require(
            o["request"] == request and o["id"] == request["id"],
            "Case identity differs",
        )
        require(
            o["mailbox"] == "00ef" and 0 < o["observed_frames"] <= 1024,
            "Request not completed",
        )
        require(o["guards"] == guards, "Guard/display-list changed")
        if request.get("scene") and not scene:
            data = M.baseline(c)
            scene = True
        if "control" in request:
            data[M.offset(c, *request["control"])] = request.get("value", 7)
        expected = M.evaluate(c, data, request)
        V.status(c, bytes.fromhex(o["context"]), V.inputs(c, request), expected)
        require(
            memory(o) == bytes(data), "Complete independent bitmap differs: " + o["id"]
        )
        need = i % 16 == 0 or bool(request.get("scene")) or "control" in request
        require(("capture" in o) == need, "Required capture missing")
        if need:
            capture(o, data)
    require(set(r["faults"]) == {"mask-fault", "row-fault"}, "Missing completed fault")
    for name, o in r["faults"].items():
        request = {"id": name, "kind": "pixel", "coords": [0, 12, 0, 0], "op": 0}
        require(
            o["request"] == request
            and o["mailbox"] == "00ef"
            and bytes.fromhex(o["context"])[9] == 1,
            "Fault not accepted/completed",
        )
        require(
            o["guards"] == o["guard_before"] and 0 < o["observed_frames"] <= 1024,
            "Fault escaped owned allocation",
        )
        data = M.baseline(c)
        M.evaluate(c, data, request)
        errors = sum(a != b for a, b in zip(memory(o), data, strict=True))
        require(
            errors > 0 and errors == o["memory_mismatches"],
            "Fault did not fail memory check",
        )
        capture(o, data, False)
    require(used == set(r["artifacts"]), "Missing/unreferenced artifacts")
    return {"calls": len(cases) + 1, "faults": 2}


def check_all() -> dict[str, Any]:
    configs = json.loads((S / "systems.json").read_text())
    require(
        len(configs) == 4
        and {c["machine_id"] for c in configs}
        == {"acorn-atom", "acorn-electron", "c64", "commodore-amiga"},
        "Incomplete four-machine registry",
    )
    return {c["machine_id"]: check(c) for c in configs}


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.parse_args()
    for name, result in check_all().items():
        print(name, "PASS", result)
