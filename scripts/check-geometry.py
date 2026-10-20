"""Recompute retained geometry outcomes, including complete failing controls."""

from __future__ import annotations

import argparse
import importlib.util
import json
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/rendering/geometry"


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ValueError(path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


V = load("geometry_observer", ROOT / "scripts/verify-geometry.py")
M, C, T, PNG = V.M, V.C, V.T, V.PNG
require = V.require


def check_system(c: dict[str, Any], folder: Path | None = None) -> dict[str, int]:
    folder = (
        folder
        or ROOT / c["folder"] / "patterns/assembly/rendering/geometry/verification"
    )
    result = json.loads((folder / "results.json").read_text())
    require(result["machine_id"] == c["machine_id"], "Machine identity differs")
    required_sources = {str(p.relative_to(ROOT)): T.sha(p) for p in V.sources(c)}
    require(
        result["sources"] == required_sources,
        "Source bindings differ or are incomplete",
    )
    tools = {t["tool"]: t for t in json.loads((SHARED / "toolchain.json").read_text())}
    require(
        result["tool_identity"]
        == {key: tools[key]["binary_sha256"] for key in [c["binary"], "asm198x"]},
        "Tool identities differ",
    )
    artifact_names = set()
    for name, digest in result["artifacts"].items():
        require(Path(name).name == name, "Artifact path escaped retained directory")
        require(T.sha(folder / name) == digest, "Artifact checksum differs: " + name)

    def memory(rec):
        artifact_names.add(rec["memory"])
        data = zlib.decompress((folder / rec["memory"]).read_bytes())
        require(len(data) == c["length"], "Snapshot length differs")
        return data

    def capture(rec, grid, match=True):
        if "capture" not in rec:
            return
        artifact_names.add(rec["capture"])
        actual = PNG.raster(folder / rec["capture"])
        expected = M.frame(c, grid)
        require(actual[0] == expected[0], "Native capture dimensions differ")
        different = sum(
            actual[1][i : i + 4] != expected[1][i : i + 4]
            for i in range(0, len(actual[1]), 4)
        )
        require(
            (different == 0) if match else different > 0,
            "Independent native pixels differ" if match else "Fault is not visible",
        )
        if not match:
            require(
                different == rec["pixel_mismatches"],
                "Recorded faulty-pixel count differs",
            )

    p = result["positive"]
    start = p["startup"]
    startup = {
        "id": "startup",
        "kind": "ellipse",
        "coords": [80, 70, 48, 24],
        "op": 0,
        "pen": 1,
    }
    require(start["request"] == startup, "Direct caller case differs")
    grid = [bytearray(c["width"]) for _ in range(c["height"])]
    expect = M.apply(c, grid, startup)
    V.geometry_status(c, bytes.fromhex(start["context"]), V.inputs(c, startup), expect)
    require(memory(start) == M.packed(c, grid), "Direct caller memory differs")
    require("capture" in start, "Missing direct caller capture")
    require(start["mailbox"] == "00ef", "Direct caller not complete")
    capture(start, grid)
    expected_guards = p["guards"]
    require(len(expected_guards) == len(V.segments(c)), "Missing guard segment")
    for i, (_, size) in enumerate(V.segments(c)):
        require(len(bytes.fromhex(expected_guards[i])) == size, "Truncated guard")
        require(
            expected_guards[i]
            == (
                bytes((x * 17 + 53) & 255 for x in range(size)).hex()
                if i < 4
                else start["guards"][i]
            ),
            "Initial guard differs",
        )
    primitive_cases = C.cpc_cases() if c["machine_id"] == "amstrad-cpc" else []
    geometry_cases = C.geometry_cases(c)
    expected_cases = primitive_cases + geometry_cases
    require(
        len(p["cases"]) == len(expected_cases) > 0, "Missing or extra executed call"
    )
    padding = 165 if primitive_cases else 0
    require(p["padding"] == padding, "Unused allocation baseline differs")
    if primitive_cases:
        grid = [
            bytearray(1 if x % 2 == 0 else 2 for x in range(c["width"]))
            for _ in range(c["height"])
        ]
    scene = False
    for i, (rec, r) in enumerate(zip(p["cases"], expected_cases, strict=True)):
        primitive = i < len(primitive_cases)
        require(
            rec["id"] == r["id"] and rec["request"] == r,
            "Wrong or missing call identity",
        )
        require(
            rec["stage"] == ("primitive" if primitive else "geometry"), "Wrong stage"
        )
        require(rec["mailbox"] == "00ef", "Request never completed")
        require(rec["guards"] == expected_guards, "Neighbour guard changed")
        require(
            0 < rec["observed_frames"] <= 1024, "Missing bounded execution observation"
        )
        if i == len(primitive_cases) or (r.get("scene") and not scene):
            grid = [bytearray(c["width"]) for _ in range(c["height"])]
        if r.get("scene"):
            scene = True
        expected = (M.primitive if primitive else M.apply)(c, grid, r)
        data = V.inputs(c, r, primitive)
        if primitive:
            V.primitive_status(c, bytes.fromhex(rec["backend"]), data, expected)
            require(
                rec["context"] == start["context"], "Primitive changed geometry state"
            )
        else:
            V.geometry_status(c, bytes.fromhex(rec["context"]), data, expected)
        require(
            memory(rec) == M.packed(c, grid, padding),
            "Independent complete bitmap differs: " + r["id"],
        )
        j = i if primitive else i - len(primitive_cases)
        expected_capture = (
            j % 32 == 0 or j == len(primitive_cases) - 1
            if primitive
            else j % 32 == 0 or bool(r.get("scene")) or r["coords"][2:] == [1, 255]
        )
        require(
            ("capture" in rec) == expected_capture,
            "Missing or unexpected native capture",
        )
        capture(rec, grid)
    variants = {"curve-fault"} | ({"packing-fault"} if primitive_cases else set())
    require(set(result["faults"]) == variants, "Missing completed faulty control")
    for variant, rec in result["faults"].items():
        primitive = variant == "packing-fault"
        r = {
            "id": variant,
            "kind": "pixel" if primitive else "ellipse",
            "coords": [1, 20, 0, 0] if primitive else [70, 70, 30, 12],
            "op": 0,
            "pen": 3 if primitive else 1,
        }
        require(
            rec["request"] == r, "Fault controls did not run their selected workload"
        )
        require(
            rec["completed"] and rec["accepted"] and rec["mailbox"] == "00ef",
            "Unfinished fault control",
        )
        require(
            (
                bytes.fromhex(rec["backend"])[9]
                if primitive
                else bytes.fromhex(rec["context"])[10]
            )
            == 1,
            "Fault was not an accepted draw",
        )
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        (M.primitive if primitive else M.apply)(c, grid, r)
        actual = memory(rec)
        expected = M.packed(c, grid)
        different = sum(a != b for a, b in zip(actual, expected, strict=True))
        require(
            different > 0 and different == rec["memory_mismatches"],
            "Fault did not fail independent memory check",
        )
        require(rec["guards"] == rec["guard_before"], "Fault escaped bitmap ownership")
        require(len(rec["guards"]) == len(V.segments(c)), "Missing fault guard")
        for raw, (_, length) in zip(rec["guards"], V.segments(c), strict=True):
            require(len(bytes.fromhex(raw)) == length, "Truncated fault guard")
        require(0 < rec["observed_frames"] <= 1024, "Unbounded faulty execution")
        require("capture" in rec, "Fault has no native output")
        capture(rec, grid, False)
    require(
        artifact_names == set(result["artifacts"]), "Missing or unreferenced artifacts"
    )
    return {
        "calls": len(expected_cases) + 1,
        "faults": len(variants),
        "captures": sum("capture" in r for r in p["cases"]) + 1 + len(variants),
    }


def check_all() -> dict[str, dict[str, int]]:
    systems = json.loads((SHARED / "systems.json").read_text())
    require(
        len(systems) == 4
        and {c["machine_id"] for c in systems}
        == {"spectrum", "acorn-bbc-micro", "dragon", "amstrad-cpc"},
        "Incomplete four-machine geometry registry",
    )
    result = {c["machine_id"]: check_system(c) for c in systems}
    require(bool(result), "No executed geometry systems")
    return result


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--output", type=Path)
    a = p.parse_args()
    result = check_all()
    if a.output:
        a.output.parent.mkdir(parents=True, exist_ok=True)
        a.output.write_text(json.dumps(result, indent=2) + "\n")
    for name, r in result.items():
        print(name, "PASS", r)
