"""Decode retained ZX BASIC execution; reject empty, stale and altered evidence."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "zx_maps", ROOT / "scripts/verify-zx-basic-map.py"
)
assert SPEC and SPEC.loader
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)
T = V.T


def decode(raw: list, system: str) -> str:
    chars = {
        0: " ",
        26: ",",
        27: ".",
        118: "\n",
        **{28 + i: str(i) for i in range(10)},
        **{38 + i: chr(65 + i) for i in range(26)},
    }
    chars[18 if system.endswith("80") else 22] = "-"
    return "".join(chars.get(b, "?") for b in raw)


def expected_call(case: dict, data: list, variant: str) -> list:
    """Contract model with two explicit faults; independent of BASIC text."""
    op, c, r, value = case["arguments"]
    valid = lambda c, r: c == int(c) and r == int(r) and 0 <= c < 7 and 0 <= r < 5
    tile, flag, e = 77, -1, 0
    if op == 2:
        tile = value
        if value == int(value) and 0 <= value <= 3:
            e = 1
            flag = [0, 1, 2, 5 if variant == "closed-exit" else 4][int(value)]
    elif op in (0, 1):
        if op == 1 and (value != int(value) or not 0 <= value <= 3):
            return [0, tile, flag, c, r]
        tile = -1
        offset = 0
        if valid(c, r):
            offset = int(r) * (6 if variant == "wrong-stride" else 7) + int(c)
            tile = data[offset]
            e = 1
        if op == 1 and (e or variant == "write-without-valid"):
            data[offset] = int(value)
            tile = value
    else:
        size = value if op == 4 else 8
        if size < 1 or size != int(size) or c < 0 or r < 0 or c > 32767 or r > 32767:
            return [0, -1, -1, -1, -1]
        c, r = math.floor(c / size), math.floor(r / size)
        tile = -1
        if valid(c, r):
            e = 1
            tile = data[r * (6 if variant == "wrong-stride" else 7) + c]
    return [e, tile, flag, c, r]


def validate(record: dict) -> None:
    system = record["machine"]
    T.require(
        system in V.SYSTEMS
        and record["language"] == "basic"
        and record["status"] == "passed",
        "Wrong qualification",
    )
    T.require(
        record["ram_bytes"] == 16384
        and record["configuration"]
        == "Stock BASIC ROM, PAL, 16384 bytes RAM, keyword keyboard entry",
        "Wrong ROM/RAM/startup contract",
    )
    T.require(record["sources"] == V.sources(system), "Changed source/observer binding")
    T.require(set(record["variants"]) == set(V.VARIANTS), "Missing execution variant")
    locked = json.loads((ROOT / "docs/zx-basic-map-tools.json").read_text())[system]
    for name in ("emulator_sha256", "firmware_sha256"):
        T.require(
            record[name] == locked[name]
            and re.fullmatch(r"[0-9a-f]{64}", record[name]) is not None,
            "Wrong emulator/firmware identity",
        )
    T.require(
        "original-hardware" in record["limits"] and "1 KiB" in record["limits"],
        "Missing limits",
    )
    expected_count = 64 if system.endswith("80") else 71
    T.require(len(V.cases(system)) == expected_count, "Missing contract inventory")
    for variant, run in record["variants"].items():
        T.require(len(run["cases"]) == expected_count, "Missing completed calls")
        routine = V.folder(system) / (
            "mistakes/" + variant + ".bas"
            if variant in ("wrong-stride", "write-without-valid")
            else "routines.bas"
        )
        room = (V.folder(system) / "room.bas").read_text()
        if variant == "closed-exit":
            room = room.replace(
                (V.folder(system) / "customise.bas").read_text().replace("=5", "=4"),
                (V.folder(system) / "customise.bas").read_text(),
            )
        program = V.harness(system) + routine.read_text() + room
        T.require(
            run["program_sha256"] == hashlib.sha256(program.encode()).hexdigest(),
            "Wrong executed listing",
        )
        T.require(run["server"]["version"] == "0.44.1", "Wrong runtime version")
        data = [tile for row in V.ROWS for tile in row] + [9]
        for index, (case, actual) in enumerate(
            zip(V.cases(system), run["cases"], strict=True)
        ):
            T.require(case["label"] == actual["label"], "Wrong call order")
            raw = list(bytes.fromhex(actual["display_hex"]))
            T.require(len(raw) == 793 and raw[0] == 118, "Missing D_FILE")
            T.require(
                0x4000 <= actual["display_address"] <= 0x8000 - len(raw),
                "D_FILE outside 16 KiB RAM",
            )
            text = decode(raw, system)
            match = re.match(
                r"\n(\d+),([\d.-]+),([\d.-]+),([\d.-]+)\s*\n([\d.-]+),([\d.-]+)\s*\n([0-9\s]+)",
                text,
            )
            T.require(
                match is not None and int(match[1]) == index, "Stale/incomplete result"
            )
            decoded = [float(match[i]) for i in range(2, 7)]
            T.require(
                decoded == actual["actual"], "Claim differs from displayed result"
            )
            expected = expected_call(case, data, variant)
            if variant in ("positive", "closed-exit"):
                wanted = case["expected"].copy()
                if variant == "closed-exit" and case["label"] == "property-3":
                    wanted[2] = 5
                T.require(
                    expected == wanted, "Reference model and contract cases disagree"
                )
            T.require(decoded == expected, "BASIC call differs from the contract")
            shown_map = [int(c) for c in "".join(match[7].split())]
            T.require(
                shown_map == actual["map"] == data,
                "Map/guard differs from actual output or expected write",
            )
        T.require(
            run["cases"][7]["actual"][1] == (2 if variant == "wrong-stride" else 3),
            "Wrong-stride symptom did not execute",
        )
        rejected = next(c for c in run["cases"] if c["label"] == "reject-write-7-0-1")
        T.require(
            rejected["map"][0] == (1 if variant == "write-without-valid" else 0),
            "Missing/unchanged write fault",
        )
    demo = record["demo"]
    raw = list(bytes.fromhex(demo["display_hex"]))
    T.require(
        len(raw) == 793 and 0x4000 <= demo["display_address"] <= 0x8000 - len(raw),
        "Missing demo display",
    )
    T.require(
        re.match(
            r"\nTILE 3\s*\nFLAGS 4\s*\nCHANGED 3\s*\nWORLD 6,4\s*\nTILE 2",
            decode(raw, system),
        )
        is not None,
        "Public caller did not complete",
    )


def validate_captures(system: str, captures: dict | None = None) -> None:
    p = V.folder(system) / "verification"
    manifest = (
        captures
        if captures is not None
        else json.loads((p / "captures.json").read_text())
    )
    expected = {
        f"{variant}-{label}.png"
        for variant in V.VARIANTS
        for label in (
            "read-0-1",
            "reject-write-7-0-1",
            "property-3",
            "world-55-39",
            "readback",
        )
    } | {"demo.png"}
    T.require(set(manifest) == expected, "Missing/extra native captures")
    for name, digest in manifest.items():
        image = p / name
        raw = image.read_bytes()
        T.require(
            raw[:8] == bytes.fromhex("89504e470d0a1a0a")
            and int.from_bytes(raw[16:20], "big") == 384
            and int.from_bytes(raw[20:24], "big") == 288,
            "Not a native-size PNG",
        )
        T.require(T.sha(image) == digest, "Native capture changed")


def main() -> None:
    for system in V.SYSTEMS:
        validate(
            json.loads((V.folder(system) / "verification/results.json").read_text())
        )
        validate_captures(system)
        print(
            "PASS",
            system,
            "BASIC: four variants, indexed calls, whole-map output and public caller",
        )


if __name__ == "__main__":
    main()
