"""Validate complete original-compiler chunks, owner results and native pixels."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
import importlib.util

spec = importlib.util.spec_from_file_location(
    "flow_native", ROOT / "scripts/verify-blitz-game-flow.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing native verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
T, C = V.T, V.C
FIXTURE = "cca54db825fbbc0505643eefdede21eb23a37ff599c4a1cc3437f592f6cce873"


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
        "Changed qualification source",
    )
    T.require(
        len(C.cases()) == 366
        and len(set(C.cases())) == 366
        and C.RECORD_BYTES == 48
        and len(C.packet()) == 17576,
        "Empty or incomplete independent model",
    )
    T.require(
        [len(rows) for rows in C.chunks()] == [64, 64, 64, 64, 64, 46],
        "Incomplete model chunks",
    )
    T.require(
        set(r["cases"]) == set(V.B.VARIANTS) and len(r["cases"]) == 11,
        "Missing native imports",
    )
    identities = {
        name: hashlib.sha256(V.B.program(name).encode("ascii")).hexdigest()
        for name in V.B.VARIANTS
    }
    T.require(
        r["fixture"] == {"fixture_sha256": FIXTURE, "program_sha256": identities},
        "Changed source-bound fixture",
    )
    T.require(
        identities["small"] == identities["working"] == identities["repaired"]
        and identities["wrong"] != identities["working"],
        "Repair or deliberate fault source differs",
    )
    chunks = []
    for name in V.B.VARIANTS:
        c = r["cases"][name]
        T.require(
            c["program_sha256"] == identities[name]
            and c["server"] == {"name": "emu198x-amiga", "version": "0.44.1"},
            "Changed native program or producer",
        )
        T.require(
            c["image"] == "caller-" + name + ".png"
            and c["quit_image"] == "caller-" + name + "-quit.png",
            "Wrong capture selection",
        )
        T.require(
            T.sha(V.V / c["image"]) == c["image_sha256"]
            and T.sha(V.V / c["quit_image"]) == c["quit_image_sha256"]
            and c["image_sha256"] != c["quit_image_sha256"],
            "Changed native or exit capture",
        )
        if name.startswith("cases-"):
            index = int(name.split("-")[1])
            raw = bytes(c["packet"])
            T.require(
                c["chunk_index"] == index
                and c["start_case"] == index * 64
                and c["case_count"] == len(C.chunks()[index])
                and c["total_case_count"] == 366
                and c["record_bytes"] == 48,
                "Missing, swapped or duplicate chunk",
            )
            T.require(
                c["allocated_observer_bytes"] == len(raw) == len(C.packet(index))
                and 0 < c["bank_address"] < 2 * 1024 * 1024 - len(raw),
                "Invalid native bank allocation",
            )
            T.require(
                hashlib.sha256(raw).hexdigest() == c["packet_sha256"]
                and raw == C.packet(index),
                "Full native packet differs",
            )
            chunks.append(raw[:-8])
        else:
            T.require(c["outputs"] == V.expected(name), "Native owner result differs")
    T.require(
        b"".join(chunks) + C.MARKER + C.DONE == C.packet(),
        "Incomplete joined native observations",
    )
    T.require(
        r["cases"]["working"]["outputs"] == [4, 2, 1, 2, 3, 6]
        and r["cases"]["wrong"]["outputs"] == [0, 3, 1, 2, 3, 2],
        "Resume fault not exposed",
    )
    # Decode actual retained pixels only after all complete records and identities pass.
    for name, c in r["cases"].items():
        image = V.V / c["image"]
        if not name.startswith("cases-"):
            T.require(
                [V.A.number(image, x, y, 3) for x, y in V.positions()] == c["outputs"],
                "Native owner pixels differ",
            )
            continue
        index = c["chunk_index"]
        last_changed = int.from_bytes(
            C.record(*C.chunks()[index][-1])[16:20], "big", signed=True
        )
        T.require(
            V.A.number(image, 304, 120, 3) == c["case_count"]
            and V.A.number(image, 336, 160, 2) == last_changed,
            "Native count or pulse pixels differ",
        )
        T.require(
            V.A.number(image, 288, 200) == c["bank_address"]
            and V.A.number(image, 288, 240) == c["allocated_observer_bytes"],
            "Native bank pixels differ",
        )
        T.require(
            V.A.number(image, 192, 280, 10) == 123456789, "Original native font differs"
        )


if __name__ == "__main__":
    check()
    print(
        "Blitz game flow: all 366 full native records, six compiler chunks, five owners and pixels passed"
    )
