"""Validate original-runtime map records without treating host execution as native proof."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "native", ROOT / "scripts/verify-amos-map-queries.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
T = V.T


def unpack(raw, count):
    T.require(
        len(raw) == count * 48 + 2 and raw[-2:] == [202, 254],
        "Incomplete allocation/caller",
    )
    values = []
    for i in range(count):
        row = raw[i * 48 : (i + 1) * 48]
        T.require(row[46:48] == [165, 90], "Incomplete map operation")
        fields = [
            int.from_bytes(bytes(row[j : j + 2]), "big", signed=j in (2, 6, 8))
            for j in range(0, 10, 2)
        ]
        values.append(fields + row[10:46])
    return values


def check(record=None):
    r = record if record is not None else json.loads((V.V / "results.json").read_text())
    cfg = json.loads((V.V / "configuration.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("commodore-amiga", "amos"), "Wrong route"
    )
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source/observer",
    )
    T.require(
        r["configuration"] == cfg and "AMOS Professional 2.00" in cfg["model"],
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
        if name == "small":
            T.require(
                c["program_sha256"] == identities[name]
                and c["server"]["version"] == "0.44.2",
                "Wrong small caller source/producer",
            )
            T.require(
                c["outputs"] == [1, 1, 2]
                and T.sha(V.V / c["image"]) == c["image_sha256"],
                "Small caller/capture differs",
            )
            actual = [
                V.A.number(V.V / c["image"], 388, 50, 2),
                V.A.number(V.V / c["image"], 420, 66, 2),
                V.A.number(V.V / c["image"], 644, 82, 2),
            ]
            T.require(actual == c["outputs"], "Small caller pixels differ")
            continue
        T.require(
            c["count"] == count
            and c["allocation_bytes"] == count * 48 + 2
            and 0 < c["base"] < 2 * 1024 * 1024 - c["allocation_bytes"],
            "Wrong completion/allocation",
        )
        T.require(
            c["program_sha256"] == identities[name]
            and c["server"]["version"] == "0.44.2",
            "Wrong source/program/producer",
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
        for k in ("image", "quit_image"):
            T.require(T.sha(V.V / c[k]) == c[k + "_sha256"], "Changed capture")
        image = V.V / c["image"]
        T.require(
            V.A.number(image, 388, 98) == c["base"]
            and V.A.number(image, 388, 114, 5) == c["allocation_bytes"]
            and V.A.number(image, 388, 66, 3) == count,
            "Native display/bank differs",
        )
        prop = 1 if name == "custom" else 2
        T.require(
            c["exit_property"] == prop and V.A.number(image, 388, 82, 2) == prop,
            "Property customisation not visible",
        )
    T.require(
        identities["working"] == identities["repaired"],
        "Repair does not restore original source",
    )


if __name__ == "__main__":
    check()
    print(
        "AMOS maps: native read/write/property/conversion cases and unchanged-map guards passed"
    )
