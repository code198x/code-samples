"""Check complete generated callers, independently of selected-operation probes."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "ace_pool_check", ROOT / "scripts/check-ace-object-pool.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing retained pool checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
V, T = C.V, C.T
B = V.module("pool_builder", V.F / "build.py")
PRODUCER = ROOT / "scripts/verify-ace-object-pool-callers.py"


def check_group(group: str, r: dict[str, Any]) -> None:
    T.require(
        group in B.VARIANTS and r.get("complete") is True and r["group"] == group,
        "Missing or different generated caller",
    )
    T.require(
        r["producer_sha256"] == T.sha(PRODUCER)
        and r["sources"] == V.sources()
        and r["configuration"]
        == json.loads((ROOT / "docs/ace-map-tools.json").read_text()),
        "Changed caller, source or original runtime",
    )
    files = [
        "routines.fth",
        "storage.fth",
        "caller.fth",
        {"custom": "customise.fth", "single": "single.fth"}.get(group, "settings.fth"),
    ]
    T.require(
        r["files"] == files
        and r["sizes"] == dict(zip(files, (16116, 16169, 16279, 16279), strict=True))
        and r["before"] == 15460
        and r["here"] == 16279
        and r["addresses"] == C.ADDRESS,
        "Wrong generated caller load or RAM layout",
    )
    loaded = "".join((V.F / f).read_text() for f in files)
    program = B.program(group)
    T.require(
        program.startswith(loaded)
        and r["entered_source_sha256"]
        == hashlib.sha256(loaded.encode("ascii")).hexdigest()
        and r["program_sha256"] == hashlib.sha256(program.encode("ascii")).hexdigest(),
        "Generated program differs from typed source",
    )
    demo = program[len(loaded) :].splitlines()
    T.require(
        r["demo_lines"] == demo and len(demo) == len(r["caller_rows"]) == 14,
        "Missing or extra complete program lines",
    )
    entered = [": NUMBER CLS U. ;"] + loaded.splitlines() + ["77"] + demo + ["NUMBER"]
    T.require(r["entered_lines"] == entered, "Wrong complete native entry recipe")
    initial = bytes.fromhex(r["dictionary_before_hex"])
    T.require(len(initial) == 819, "Truncated compiled program")
    normal = bytearray(initial)
    pc = C.ADDRESS["PC"] - 15460
    capacity = {"custom": 4, "single": 1}.get(group, 8)
    T.require(
        int.from_bytes(normal[pc : pc + 2], "little") == capacity,
        "Wrong caller capacity",
    )
    normal[pc : pc + 2] = b"\x08\x00"
    T.require(
        hashlib.sha256(normal).hexdigest() == C.INITIAL_SHA,
        "Compiled caller differs from original producer image",
    )
    state = {n: capacity if n == "PC" else 0 for n in C.C.NAMES}
    flags, payload = [77] * 8 + [99], [60] * 8 + [65535]
    for line, row in zip(demo, r["caller_rows"], strict=True):
        if line == "PNEW U.":
            T.require(
                C.C.step(state, flags, 16279, "init", capacity, 16128) == [1],
                "Invalid caller init",
            )
        elif line.startswith("NEWOBJ DROP DROP"):
            slot, ok = C.C.step(state, flags, 16279, "get")
            if ok:
                payload[slot] = 60
        elif line == "0 PREL DROP":
            C.C.step(state, flags, 16279, "release", 0)
        T.require(
            row["line"] == line
            and row["state"] == state
            and row["flags"] == flags
            and row["payload"] == payload,
            "Complete caller state or array mismatch",
        )
        T.require(
            row["data_top"] == 16293
            and row["prefix"] == 77
            and 16293 < row["cpu_sp"] <= 16384,
            "Complete caller stack leak or collision",
        )
        expected = bytearray(initial)
        for name, value in state.items():
            offset = C.ADDRESS[name] - 15460
            expected[offset : offset + 2] = value.to_bytes(2, "little")
        offset = C.ADDRESS["SLOTS"] - 15460
        expected[offset : offset + 9] = bytes(flags)
        offset = C.ADDRESS["PAYLOAD"] - 15460
        expected[offset : offset + 18] = b"".join(
            v.to_bytes(2, "little") for v in payload
        )
        T.require(
            bytes.fromhex(row["dictionary_hex"]) == expected,
            "Complete caller compiled/data bytes differ",
        )
    C.capture("callers-" + group, r, state)
    raw = bytes.fromhex(r["capture"]["pixels"]["video_hex"])
    text = "".join(chr(c & 127) if 32 <= c & 127 < 127 else " " for c in raw)
    T.require(
        re.search(r"\b60\b.*?\b99\b.*?\b65535\b", text) is not None,
        "Missing actual printed payload or guards",
    )
    final = r["final_stack"]
    raw = bytes.fromhex(final["screen_hex"])
    text = "".join(chr(c & 127) if 32 <= c & 127 < 127 else " " for c in raw)
    T.require(
        final["dictionary"] == 16279
        and final["data_top"] == 16291
        and len(raw) == 768
        and re.match(r"\s*77\s", text) is not None,
        "Final prefix or empty data stack differs",
    )


def check(records: dict[str, dict[str, Any]] | None = None) -> None:
    records = (
        records
        if records is not None
        else {
            g: json.loads((V.V / ("callers-" + g + ".json")).read_text())
            for g in B.VARIANTS
        }
    )
    T.require(set(records) == set(B.VARIANTS), "Missing complete generated caller boot")
    T.require(
        B.program("working") == B.program("repaired") != B.program("wrong"),
        "Repair or mistake is ineffective",
    )
    for group in B.VARIANTS:
        check_group(group, records[group])


if __name__ == "__main__":
    check()
    print("Ace pool: all five complete generated original-ROM callers passed")
