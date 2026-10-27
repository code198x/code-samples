"""Gate full original-compiled pool contexts, owner data, guards and pixels."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "pool_native", ROOT / "scripts/verify-blitz-object-pool.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing native pool verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
T, C, D, L = V.T, V.C, V.D, V.L
SMALL = ("small", "working", "custom", "single", "wrong", "repaired")
FIXTURE = "85368e6161e74c16224c22d845b8335ef7310e02a62d82c556f124325da43a6d"


def check(record: dict[str, Any] | None = None) -> None:
    r = record if record is not None else json.loads((V.V / "results.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("commodore-amiga", "blitz"), "Wrong route"
    )
    T.require(
        r["configuration"] == V.A.config(), "Changed original runtime configuration"
    )
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed pool qualification source",
    )
    T.require(
        len(C.cases()) == len(set(C.cases())) == 768
        and C.RECORD_BYTES == 496
        and len(C.packet()) == 380936,
        "Empty or incomplete full pool model",
    )
    T.require(
        [len(D.cases(e)) for e in (False, True)] == [46, 6]
        and [len(D.packet(e)) for e in (False, True)] == [5344, 704]
        and len(L.cases()) == 3
        and len(L.packet()) == 464,
        "Incomplete domain or lifetime model",
    )
    T.require(
        set(r["cases"]) == set(V.B.VARIANTS) and len(r["cases"]) == 12,
        "Missing native pool import",
    )
    identities = {
        n: hashlib.sha256(V.B.program(n).encode("ascii")).hexdigest()
        for n in V.B.VARIANTS
    }
    T.require(
        r["fixture"]["program_sha256"] == identities
        and r["fixture"]["fixture_sha256"] == FIXTURE,
        "Changed source-bound pool fixture",
    )
    T.require(
        identities["small"] == identities["working"] == identities["repaired"]
        and identities["cases"] == identities["repaired-cases"]
        and identities["cases"] != identities["wrong-cases"],
        "Wrong or repair source identity differs",
    )
    for name in V.B.VARIANTS:
        c = r["cases"][name]
        T.require(
            c["program_sha256"] == identities[name]
            and c["server"] == {"name": "emu198x-amiga", "version": "0.44.1"},
            "Changed native pool program or producer",
        )
        T.require(
            c["image"] == "caller-" + name + ".png"
            and c["quit_image"] == "caller-" + name + "-quit.png",
            "Wrong native capture selection",
        )
        T.require(
            T.sha(V.V / c["image"]) == c["image_sha256"]
            and T.sha(V.V / c["quit_image"]) == c["quit_image_sha256"]
            and c["image_sha256"] != c["quit_image_sha256"],
            "Changed native result or exit capture",
        )
        if name in SMALL:
            T.require(c["outputs"] == V.expected(name), "Native small owner differs")
            continue
        packet, count, stride = V.model(name)
        raw = bytes(c["packet"])
        T.require(
            c["case_count"] == count and c["record_bytes"] == stride,
            "Incomplete native pool traversal",
        )
        T.require(
            c["allocated_observer_bytes"] == len(packet) == len(raw)
            and 0 < c["bank_address"] < 2 * 1024 * 1024 - len(raw),
            "Invalid native pool allocation",
        )
        T.require(
            hashlib.sha256(raw).hexdigest() == c["packet_sha256"] and raw == packet,
            "Full native pool packet differs",
        )
    T.require(
        r["cases"]["cases"]["packet"] == r["cases"]["repaired-cases"]["packet"]
        and r["cases"]["cases"]["packet"] != r["cases"]["wrong-cases"]["packet"],
        "Native release fault or repair not exposed",
    )
    for name, c in r["cases"].items():
        image = V.V / c["image"]
        if name in SMALL:
            T.require(
                [V.A.number(image, x, y, 3) for x, y in V.positions(name)]
                == c["outputs"],
                "Small owner pixels differ",
            )
            continue
        T.require(
            V.A.number(image, 304, 120, 3) == c["case_count"]
            and V.A.number(image, 288, 160, 2) == 0,
            "Native pool completion pixels differ",
        )
        T.require(
            V.A.number(image, 288, 200) == c["bank_address"]
            and V.A.number(image, 288, 240) == c["allocated_observer_bytes"]
            and V.A.number(image, 192, 280, 10) == 123456789,
            "Native pool bank or font pixels differ",
        )


if __name__ == "__main__":
    check()
    print(
        "Blitz pool: all 12 original imports, complete integer contexts/owner arrays, guards and pixels passed"
    )
