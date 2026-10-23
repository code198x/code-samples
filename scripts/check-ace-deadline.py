"""Check retained ROM execution; never treat this as a fresh emulator run."""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "jupiter-ace/patterns/forth/framework/turn-deadline"


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check(
    record: dict[str, Any] | None = None, boundaries: dict[str, Any] | None = None
) -> None:
    if record is None:
        record = json.loads((FOLDER / "verification/native.json").read_text())
    if boundaries is None:
        boundaries = json.loads((FOLDER / "verification/boundaries.json").read_text())
    require(
        record["status"] == "passed"
        and record["machine"] == "jupiter-ace"
        and record["language"] == "forth",
        "Wrong identity/status",
    )
    locked = json.loads((ROOT / "docs/ace-map-tools.json").read_text())
    require(
        record["emulator_sha256"]
        == boundaries["emulator_sha256"]
        == locked["emulator_sha256"]
        and record["firmware_sha256"]
        == boundaries["firmware_sha256"]
        == locked["firmware_sha256"],
        "Wrong runtime identity",
    )
    manifest = json.loads((FOLDER / "verification/sources.json").read_text())
    paths = (
        sorted(FOLDER.glob("*.fth"))
        + sorted((FOLDER / "mistakes").glob("*.fth"))
        + [
            FOLDER / "Makefile",
            ROOT / "scripts/verify-ace-deadline.py",
            ROOT / "scripts/verify-ace-deadline-boundaries.py",
            ROOT / "scripts/verify-game-loops.py",
        ]
    )
    require(
        manifest == {str(p.relative_to(ROOT)): sha(p) for p in paths},
        "Changed source/observer binding",
    )
    require(
        set(record["cases"]) == {"working", "custom", "wrong", "repaired"},
        "Missing native caller",
    )
    for variant, case in record["cases"].items():
        files = [
            "routines.fth",
            "clock.fth",
            "mistakes/reset-baseline.fth" if variant == "wrong" else "service.fth",
            "input.fth",
            "caller.fth",
            "customise.fth" if variant == "custom" else "settings.fth",
        ]
        require(
            case["sources"] == {p: sha(FOLDER / p) for p in files},
            "Wrong entered source recipe",
        )
        require(
            case["ram_top"] == 16384
            and set(case["addresses"]) == {"DU", "DR", "DA", "DP", "DE", "KP"},
            "Wrong stock configuration or missing addresses",
        )
        sizes = case["here_after_files"]
        require(
            set(sizes) == set(files)
            and sizes["routines.fth"] - case["here_before"] == 230,
            "Wrong helper dictionary cost",
        )
        require(
            sizes[files[-1]] == sizes["caller.fth"]
            and case["data_top_after_exit"] == sizes["caller.fth"] + 12,
            "Caller leaked stack on exit",
        )
        states = case["samples"]
        expected_stages = {
            "initial",
            "untimed-idle",
            "untimed-action",
            "held-released-idle",
            "enabled",
            "progress",
            "disabled",
            "disabled-idle",
        } | ({"wrong-no-expiry"} if variant == "wrong" else {"restart", "await-expiry"})
        require(
            expected_stages == {state["stage"] for state in states},
            "Missing or unexpected native sequence stage",
        )
        for state in states:
            raw = bytes.fromhex(state["screen_hex"])
            require(len(raw) == 768, "Truncated screen")
            text = "".join(chr(c & 127) if 32 <= (c & 127) < 127 else " " for c in raw)
            match = re.match(r"\s*TURN\s+(\d+)\s+TIMER\s+(\d+)", text, re.IGNORECASE)
            require(
                match is not None
                and [int(match[1]), int(match[2])]
                == [state["turn"], state["timer_screen"]],
                "Summary disagrees with native screen",
            )
            require(
                state["dictionary"] == sizes["caller.fth"]
                and state["dictionary"] + 12
                <= state["data_top"]
                < state["cpu_sp"]
                <= 16384,
                "Stack/dictionary collision",
            )
            require(
                all(0 <= state["state"][key] <= 65535 for key in case["addresses"]),
                "Out-of-range cell",
            )
            require(
                state["state"]["DU"] == (100 if variant == "custom" else 200),
                "Wrong custom duration",
            )
        stages = {s["stage"]: s for s in states}
        a, b, c = (stages[k] for k in ["initial", "untimed-idle", "untimed-action"])
        require(
            a["turn"] == b["turn"] == 0 and a["state"]["DA"] == b["state"]["DA"] == 0,
            "Untimed idle advanced",
        )
        require(
            (b["clock"] - a["clock"]) % 65536 in range(99, 102),
            "Native frame clock did not advance across idle",
        )
        require(
            c["turn"] == stages["held-released-idle"]["turn"] == 1
            and c["state"]["DA"] == 0,
            "Held key repeated or untimed action armed timer",
        )
        enabled, progress = stages["enabled"], stages["progress"]
        require(
            enabled["state"]["DA"] == 1
            and (progress["clock"] - enabled["clock"]) % 65536 in range(29, 32),
            "Clock/enable failed",
        )
        if variant == "wrong":
            bad = stages["wrong-no-expiry"]
            require(
                (bad["clock"] - enabled["clock"]) % 65536 > 200,
                "Fault not observed beyond deadline",
            )
            require(
                bad["turn"] == 1
                and bad["state"]["DR"] == 200
                and bad["state"]["DE"] == 0
                and bad["state"]["DA"] == 1,
                "Baseline-reset symptom absent",
            )
        else:
            require(
                28 <= enabled["state"]["DR"] - progress["state"]["DR"] <= 33,
                "Deadline progression disagrees with clock window",
            )
            restart = stages["restart"]
            require(
                restart["turn"] == 2
                and restart["state"]["DR"] > progress["state"]["DR"],
                "Active action did not restart",
            )
            expiry = [s for s in states if s["stage"] == "await-expiry"][-1]
            require(
                expiry["turn"] == 3 and expiry["state"]["DA"] == 1,
                "Idle expiry absent or duplicated",
            )
        disabled, stopped = stages["disabled"], stages["disabled-idle"]
        require(
            disabled["state"]["DA"] == stopped["state"]["DA"] == 0
            and disabled["turn"] == stopped["turn"]
            and (stopped["clock"] - disabled["clock"]) % 65536 >= 250,
            "Disabled state advanced or interval missing",
        )
        require(
            sha(FOLDER / "verification" / case["image"]) == case["image_sha256"],
            "Changed native capture",
        )
    require(
        set(boundaries["cases"]) == {"working", "signed-fault"},
        "Missing arithmetic control",
    )
    for name, run in boundaries["cases"].items():
        require(
            run["wrong_signed_compare"] == (name == "signed-fault")
            and len(run["cases"]) == 16,
            "Missing arithmetic cases",
        )
        matches = []
        for index, case in enumerate(run["cases"]):
            previous, now, duration = (case[k] for k in ["previous", "now", "duration"])
            elapsed = (now - previous) % 65536
            expected = [
                int(duration > 0 and elapsed >= duration),
                max(0, duration - elapsed) if duration else 0,
                elapsed,
            ]
            raw = bytes.fromhex(case["screen_hex"])
            text = "".join(chr(c & 127) if 32 <= (c & 127) < 127 else " " for c in raw)
            match = re.match(
                r"\s*FLAG\s+(\d+)\s+LEFT\s+(\d+)\s+DELTA\s+(\d+)\s+CASE\s+(\d+)\s+STACK\s+(\d+)",
                text,
                re.IGNORECASE,
            )
            require(
                len(raw) == 768
                and match is not None
                and int(match[4]) == index == case["index"]
                and int(match[5]) == case["tag"] == 77,
                "Incomplete arithmetic output/tag",
            )
            require(
                list(map(int, match.group(1, 2, 3))) == case["actual"]
                and case["expected"] == expected,
                "Arithmetic summaries disagree with pixels/oracle",
            )
            agrees = case["actual"] == expected
            matches.append(agrees)
            require(
                case["oracle_matches"] == agrees
                and case["data_top"] == run["dictionary"] + 12,
                "False oracle result or stack leak",
            )
        require(
            all(matches) if name == "working" else not all(matches),
            "Signed negative control was not rejected",
        )
        require(
            sha(FOLDER / "verification" / run["image"]) == run["image_sha256"],
            "Changed arithmetic capture",
        )


if __name__ == "__main__":
    check()
    print("Ace FORTH native callers, arithmetic and signed-comparison control passed")
