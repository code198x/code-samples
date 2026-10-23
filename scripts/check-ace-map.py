"""Validate Ace FORTH observations rather than trusting the producer's pass flag."""

from __future__ import annotations

import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "ace_maps", ROOT / "scripts/verify-ace-map.py"
)
assert SPEC and SPEC.loader
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)
T = V.T


def validate(record: dict) -> None:
    T.require(
        record["status"] == "passed"
        and record["machine"] == "jupiter-ace"
        and record["language"] == "forth",
        "Wrong qualification",
    )
    T.require(record["sources"] == V.sources(), "Source/observer binding changed")
    T.require(len(V.cases()) == 59, "Missing case inventory")
    T.require(set(record["observations"]) == set(V.VARIANTS), "Missing variant")
    initial = [cell for row in V.ROWS for cell in row] + [165]
    final = initial.copy()
    final[0] = 3
    for variant, data in record["observations"].items():
        T.require(len(data["cases"]) == len(V.cases()), "Incomplete executed cases")
        T.require(data["before_map"] == initial, "Wrong initial map")
        T.require(
            data["properties"] == [0, 1, 2, 5 if variant == "closed-exit" else 4],
            "Wrong property table",
        )
        T.require(data["final_map"] == final, "Final map differs")
        T.require(
            data["dictionary_after"] - data["dictionary_before"]
            == data["dictionary_bytes"]
            and 0 < data["dictionary_bytes"] < 800,
            "Empty/oversized dictionary allocation",
        )
        T.require(
            data["dictionary_after"] < 16384
            and data["room_address"] >= 15424
            and data["flags_address"] + 4 <= data["dictionary_after"],
            "Wrong stock RAM allocation",
        )
        T.require(
            data["ram_top"] == 16384
            and data["dictionary_core_bytes"] + data["dictionary_data_bytes"]
            == data["dictionary_bytes"],
            "RAM or allocation accounting changed",
        )
        T.require(data["stack_sentinel"] == 77, "Caller stack prefix changed")
        allocation_fields = {
            "before": data["dictionary_before"],
            "core": data["dictionary_before"] + data["dictionary_core_bytes"],
            "after": data["dictionary_after"],
            "ram_top": data["ram_top"],
        }
        T.require(
            set(data["allocation_screens"]) == set(allocation_fields),
            "Missing allocation observations",
        )
        for name, wanted in allocation_fields.items():
            raw = bytes.fromhex(data["allocation_screens"][name])
            T.require(len(raw) == 768, "Missing allocation display")
            text = "".join(chr(c & 127) if 32 <= (c & 127) < 127 else " " for c in raw)
            match = re.match(r"\s*(\d+)\s", text)
            T.require(
                match is not None
                and int(match[1]) == wanted
                and "ERROR" not in text.upper(),
                "Allocation claim differs from actual display",
            )
        sentinel_raw = bytes.fromhex(data["stack_screen_hex"])
        T.require(
            len(sentinel_raw) == 768
            and re.match(rb"\s*77\s", sentinel_raw) is not None,
            "Missing stack-prefix observation",
        )
        mismatches = []
        for index, (expected, actual) in enumerate(
            zip(V.cases(), data["cases"], strict=True)
        ):
            T.require(actual["label"] == expected["label"], "Wrong case ordering")
            raw = bytes.fromhex(actual["screen_hex"])
            T.require(
                len(raw) == 768
                and all(isinstance(b, int) and 0 <= b <= 255 for b in raw),
                "Missing/invalid actual display bytes",
            )
            text = "".join(chr(c & 127) if 32 <= (c & 127) < 127 else " " for c in raw)
            match = re.match(
                r"\s*CASE\s+(\d+)\s+FLAG\s+(\d+)\s+VALUE\s+(\d+)\s+STACK\s+(\d+)\s",
                text,
                re.IGNORECASE,
            )
            T.require(
                match is not None
                and "ERROR" not in text.upper()
                and int(match[1]) == index
                and int(match[4]) == 77,
                "No completed display result",
            )
            decoded = [int(match[3]), int(match[2])]
            T.require(actual["actual"] == decoded, "Claim differs from actual screen")
            wanted = expected["expected"]
            if variant == "closed-exit" and expected["label"] == "exit-property":
                wanted = [5, 1]
            if decoded != wanted:
                mismatches.append(expected["label"])
        if variant in ("positive", "closed-exit"):
            T.require(
                not mismatches and data["after_rejected_writes"] == initial,
                "Correct routine failed or corrupted the map",
            )
        elif variant == "wrong-stride":
            T.require("read-0-1" in mismatches, "Wrong stride did not fail")
            T.require(
                data["cases"][7]["actual"] == [2, 1], "Wrong stride symptom changed"
            )
        else:
            T.require(
                "rejected-write-1-7-0" in mismatches
                and data["after_rejected_writes"] != initial,
                "Bypassed write guard did not fail",
            )
    locked = json.loads((ROOT / "docs/ace-map-tools.json").read_text())
    for key in ("emulator_sha256", "firmware_sha256"):
        T.require(record[key] == locked[key], "Tool/ROM identity changed")
        T.require(
            re.fullmatch(r"[0-9a-f]{64}", record[key]) is not None,
            "Bad tool/firmware digest",
        )
    T.require(
        "stock FORTH ROM" in record["configuration"]
        and "original-hardware" in record["limits"],
        "Missing configuration/limits",
    )


def main() -> None:
    record = json.loads((V.FOLDER / "verification/results.json").read_text())
    validate(record)
    print(
        "PASS Ace FORTH: four variants, 59 completed operations each, actual display/memory and source bindings"
    )


if __name__ == "__main__":
    main()
