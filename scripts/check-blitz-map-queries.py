"""Gate independently compiled Blitz map operations and their native pictures."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "native", ROOT / "scripts/verify-blitz-map-queries.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
T = V.T


def unpack(raw, count):
    T.require(
        len(raw) == count * 168 + 8 and raw[-8:] == [26, 43, 60, 77, 0, 0, 0, 239],
        "Incomplete allocation/caller",
    )
    values = []
    for i in range(count):
        row = raw[i * 168 : (i + 1) * 168]
        T.require(row[164:168] == [0, 0, 165, 90], "Incomplete map operation")
        values.append(
            [
                int.from_bytes(bytes(row[j : j + 4]), "big", signed=True)
                for j in range(0, 164, 4)
            ]
        )
    return values


def check(record=None):
    r = record if record is not None else json.loads((V.V / "results.json").read_text())
    cfg = json.loads((V.V / "configuration.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("commodore-amiga", "blitz"), "Wrong route"
    )
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source/observer",
    )
    T.require(
        r["configuration"] == cfg and "Blitz BASIC 2.10" in cfg["model"],
        "Changed runtime configuration",
    )
    T.require(set(r["cases"]) == set(V.B.VARIANTS), "Missing native case")
    identities = {
        n: hashlib.sha256(V.B.program(n).encode()).hexdigest() for n in V.B.VARIANTS
    }
    T.require(
        r["fixture"]["program_sha256"] == identities
        and len(r["fixture"]["fixture_sha256"]) == 64,
        "Stale source fixture",
    )
    count = len(V.B.C.cases())
    T.require(count == 64, "Empty/incomplete independent caller")
    for name, c in r["cases"].items():
        T.require(
            c["program_sha256"] == identities[name]
            and c["server"]["version"] == "0.44.2",
            "Wrong source/program/producer",
        )
        image = V.V / c["image"]
        T.require(T.sha(image) == c["image_sha256"], "Changed capture")
        if name == "small":
            T.require(c["outputs"] == [1, 1, 2], "Small caller differs")
            actual = [
                V.A.number(image, 288, 120, 2),
                V.A.number(image, 304, 160, 2),
                V.A.number(image, 416, 200, 2),
            ]
            T.require(actual == c["outputs"], "Small caller pixels differ")
            continue
        T.require(
            c["count"] == count
            and c["allocation_bytes"] == count * 168 + 8
            and 0 < c["base"] < 2 * 1024 * 1024 - c["allocation_bytes"],
            "Wrong completion/allocation",
        )
        values = unpack(c["bytes"], count)
        T.require(values == c["values"], "Native byte decoding differs")
        expected = V.B.C.expected(name == "custom")
        T.require(
            (values == expected) == (name != "wrong"), "Independent map oracle differs"
        )
        T.require(all(v[-1] == 99 for v in values), "Map guard was overwritten")
        if name == "wrong":
            T.require(
                values[7][1] == 1 and expected[7][1] == 3, "Wrong-stride symptom absent"
            )
        T.require(
            T.sha(V.V / c["quit_image"]) == c["quit_image_sha256"],
            "Changed quit capture",
        )
        T.require(
            V.A.number(image, 288, 200) == c["base"]
            and V.A.number(image, 288, 240) == c["allocation_bytes"]
            and V.A.number(image, 304, 120, 3) == count,
            "Native display/bank differs",
        )
        prop = 1 if name == "custom" else 2
        T.require(
            c["exit_property"] == prop and V.A.number(image, 288, 160, 2) == prop,
            "Property customisation not visible",
        )
        T.require(
            V.A.number(image, 192, 280, 10) == 123456789,
            "Unexpected native font fixture",
        )
    T.require(
        identities["working"] == identities["repaired"],
        "Repair does not restore original source",
    )


if __name__ == "__main__":
    check()
    print(
        "Blitz maps: compiled native query cases, complete map/guard snapshots and pixels passed"
    )
