"""Validate retained loop evidence; this does not rerun the machines."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SYSTEMS = ("acorn-atom", "bbc-micro", "acorn-electron", "amstrad-cpc")
VARIANTS = {"default", "step-two", "nonzero", "wrap", "wrong", "fixed"}


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def folder_for(system: str, root: Path = ROOT) -> Path:
    language = (
        "basic/framework/turn-loop"
        if system in ("bbc-micro", "acorn-electron")
        else "assembly/framework/command-loop"
    )
    return root / system / "patterns" / language


def check(system: str, record: dict[str, Any] | None = None, root: Path = ROOT) -> None:
    require(system in SYSTEMS, "Unknown machine")
    basic = system in ("bbc-micro", "acorn-electron")
    folder = folder_for(system, root)
    source = folder_for("bbc-micro", root) if system == "acorn-electron" else folder
    out = folder / "verification"
    if record is None:
        record = json.loads((out / "results.json").read_text())
    require(
        record["status"] == "passed" and record["machine_id"] == system,
        "Wrong machine/status",
    )
    require(record["language"] == ("basic" if basic else "assembly"), "Wrong language")
    paths = {
        str(p.relative_to(root))
        for p in source.rglob("*")
        if p.is_file()
        and "build" not in p.parts
        and "verification" not in p.parts
        and p.name != "README.md"
    }
    if system == "acorn-electron":
        paths.add(str((folder / "qualification-toolchain.json").relative_to(root)))
    if not basic:
        cpu = "6502" if system == "acorn-atom" else "z80"
        paths.add(f"cross-platform/patterns/framework/command-turns/{cpu}.inc")
    require(set(record["sources"]) == paths, "Incomplete source bindings")
    observers = {"scripts/verify-loop-language-gaps.py", "scripts/verify-game-loops.py"}
    require(
        set(record["observer_sources"]) == observers, "Incomplete observer bindings"
    )
    for name, digest in {**record["sources"], **record["observer_sources"]}.items():
        require(
            hashlib.sha256((root / name).read_bytes()).hexdigest() == digest,
            "Changed source: " + name,
        )
    tools = json.loads((folder / "qualification-toolchain.json").read_text())
    require(
        record["executable_sha256"] == tools["emulator_binary_sha256"],
        "Wrong emulator identity",
    )
    require(
        record["assembler_sha256"] == tools["assembler_binary_sha256"],
        "Wrong assembler identity",
    )
    require(
        bool(record["firmware_sha256"])
        and all(len(d) == 64 for d in record["firmware_sha256"].values()),
        "Missing firmware identity",
    )
    expected_cases = VARIANTS | ({"no-wait"} if basic else set())
    require(set(record["cases"]) == expected_cases, "Incomplete native cases")
    labels = ("waiting", "held", "action") if basic else ("waiting", "action")
    expected_images = {f"{v}-{label}.png" for v in VARIANTS for label in labels}
    if basic:
        expected_images.add("no-wait-action.png")
    require(set(record["artifacts"]) == expected_images, "Incomplete native captures")
    for name, digest in record["artifacts"].items():
        data = (out / name).read_bytes()
        require(
            data.startswith(b"\x89PNG\r\n\x1a\n")
            and hashlib.sha256(data).hexdigest() == digest,
            "Altered capture: " + name,
        )
    require(
        record["artifacts"]["default-action.png"]
        != record["artifacts"]["default-waiting.png"],
        "No visible progression",
    )
    for variant in VARIANTS:
        data = record["cases"][variant]
        initial = 37 if variant == "nonzero" else 254 if variant == "wrap" else 0
        step = 2 if variant == "step-two" else 1
        require(
            len(data["startup"]) == 4 and data["startup"][0] == initial, "Wrong startup"
        )
        observed = data["progression"]
        if basic:
            require(
                data["updates_per_30_fields"] in range(28, 32), "Field pacing failed"
            )
            if variant == "wrong":
                require(
                    len(observed) == 4 and observed[2] != observed[1],
                    "Held-key fault not observed",
                )
            else:
                require(
                    observed
                    == [
                        initial,
                        (initial + step) & 255,
                        (initial + step) & 255,
                        (initial + 2 * step) & 255,
                    ],
                    "Press/hold/wrap policy failed",
                )
        else:
            expected = (
                [initial, step, step]
                if variant == "wrong"
                else [initial, (initial + step) & 255, (initial + 2 * step) & 255]
            )
            require(observed == expected, "Command progression failed")
    if basic:
        fault = record["cases"]["no-wait"]
        require(
            fault["rate_guard_rejected"] is True
            and fault["updates_per_30_fields"] not in range(28, 32),
            "No-wait fault escaped",
        )


if __name__ == "__main__":
    for machine in SYSTEMS:
        check(machine)
    print("Four language-specific loop records and controls match their inputs")
