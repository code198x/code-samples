"""Validate retained loop evidence; this does not rerun the machines.

Each variant's program is rebuilt through the recorder's build(): the Atom
and CPC binaries with the Asm198x release the record pins (rule 1), the
BBC Micro and Electron listings as typed text (rule 2). Source and observer
digests are provenance only.
"""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SYSTEMS = ("acorn-atom", "bbc-micro", "acorn-electron", "amstrad-cpc")
VARIANTS = {"default", "step-two", "nonzero", "wrap", "wrong", "fixed"}
_E = importlib.util.spec_from_file_location(
    "loop_language_bytes", Path(__file__).with_name("evidence_bytes.py")
)
assert _E and _E.loader
E = importlib.util.module_from_spec(_E)
_E.loader.exec_module(E)


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
    out = folder / "verification"
    if record is None:
        record = json.loads((out / "results.json").read_text())
    require(
        record["status"] == "passed" and record["machine_id"] == system,
        "Wrong machine/status",
    )
    require(record["language"] == ("basic" if basic else "assembly"), "Wrong language")
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
    script = root / "scripts/verify-loop-language-gaps.py"
    for variant in sorted(VARIANTS):
        recorded = record["cases"][variant]["program_sha256"]
        if basic:
            output = f"build/evidence/{variant}.bas"
            build = E.function(
                script,
                "build",
                (system, variant, "", "build/evidence"),
                folder,
                (output,),
            )
            E.require_typed(E.rebuild(build, None)[output], recorded, output)
        else:
            output = f"build/evidence/{variant}.bin"
            E.require_program(
                E.function(
                    script,
                    "build",
                    (system, variant, E.ASSEMBLER, "build/evidence"),
                    folder,
                    (output, f"build/evidence/{variant}-loader.bas"),
                ),
                output,
                record["assembler_sha256"],
                recorded_sha256=recorded,
            )
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
