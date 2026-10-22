"""Check retained language-specific loop evidence, without fresh emulation."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
CONFIGS = {
    "atari-basic": ("atari-800xl", "basic", "command-loop"),
    "atari-assembly": ("atari-800xl", "assembly", "turn-loop"),
    "coleco": ("coleco-colecovision", "assembly", "turn-loop"),
}
ASM_VARIANTS = {
    "working",
    "customise",
    "wrap",
    "nonzero",
    "held-as-press",
    "bad-wait",
    "fixed-edge",
    "fixed-wait",
}
BASIC_VARIANTS = {"working", "customise", "wrap", "nonzero", "reset-mistake", "fixed"}
SHARED = "cross-platform/patterns/framework/atari-turn-loops"
FONT = "cross-platform/patterns/rendering/bitmap-text/font-z80.inc"


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def paths(key: str, root: Path = ROOT) -> tuple[Path, Path]:
    system, language, slug = CONFIGS[key]
    folder = root / system / f"patterns/{language}/framework/{slug}"
    return folder, folder / (
        "verification/reusable" if language == "basic" else "verification"
    )


def check(key: str, record: dict[str, Any] | None = None, root: Path = ROOT) -> None:
    folder, output = paths(key, root)
    system, language, _ = CONFIGS[key]
    basic = language == "basic"
    if record is None:
        record = json.loads((output / "results.json").read_text())
    require(
        record["status"] == "passed"
        and record["machine_id"] == system
        and record["language"] == language,
        "Wrong configuration/status",
    )
    inputs = {
        str(p.relative_to(root))
        for p in folder.rglob("*")
        if p.is_file()
        and "build" not in p.parts
        and "verification" not in p.parts
        and p.name != "README.md"
    }
    if not basic:
        inputs |= (
            {FONT}
            if key == "coleco"
            else {str(p.relative_to(root)) for p in (root / SHARED).rglob("*.inc")}
        )
    require(set(record["sources"]) == inputs, "Incomplete source bindings")
    require(
        set(record["observer_sources"])
        == {"scripts/verify-xl-coleco-loops.py", "scripts/verify-game-loops.py"},
        "Incomplete observer bindings",
    )
    for name, digest in {**record["sources"], **record["observer_sources"]}.items():
        require(
            hashlib.sha256((root / name).read_bytes()).hexdigest() == digest,
            "Changed source: " + name,
        )
    tools = json.loads((folder / "qualification-toolchain.json").read_text())
    require(
        record["emulator_sha256"] == tools["emulator_binary_sha256"]
        and record["assembler_sha256"] == tools["assembler_binary_sha256"],
        "Wrong tool identity",
    )
    require(
        record["release_tags"] == {"emu198x": "v0.44.1", "asm198x": "asm198x-v0.0.71"},
        "Wrong release combination",
    )
    require(
        set(record["firmware_sha256"])
        == (
            {"colecovision.rom"} if key == "coleco" else {"atarixl.rom", "ataribas.rom"}
        )
        and all(len(d) == 64 for d in record["firmware_sha256"].values()),
        "Missing firmware bindings",
    )
    variants = BASIC_VARIANTS if basic else ASM_VARIANTS
    require(
        set(record["variants"]) == set(record["program_sha256"]) == variants,
        "Incomplete native cases/program identities",
    )
    require(
        all(len(d) == 64 for d in record["program_sha256"].values()),
        "Invalid program identity",
    )
    labels = (
        ("waiting", "action-1", "action-2")
        if basic
        else ("waiting", "pressed", "held", "second")
    )
    require(
        set(record["artifacts"])
        == {f"{v}-{label}.png" for v in variants for label in labels},
        "Incomplete native captures",
    )
    for name, digest in record["artifacts"].items():
        data = (output / name).read_bytes()
        require(
            data.startswith(b"\x89PNG\r\n\x1a\n")
            and hashlib.sha256(data).hexdigest() == digest,
            "Altered capture: " + name,
        )
    for variant in variants:
        data = record["variants"][variant]
        step = 2 if variant == "customise" else 1
        initial = 254 if variant == "wrap" else 37 if variant == "nonzero" else 0
        if basic:
            expected = (
                [initial, step, step]
                if variant == "reset-mistake"
                else [initial, (initial + step) & 255, (initial + 2 * step) & 255]
            )
            require(
                data["progression"] == expected
                and data["rejected_flag"] == 0
                and data["accepted_flag"] == 1,
                "Command progression/flags failed",
            )
        else:
            states = data["states"]
            require(
                set(states) == {"initial", "pressed", "held", "released", "second"},
                "Missing native state",
            )
            require(
                all(
                    len(s) == 7
                    and all(isinstance(n, int) and 0 <= n <= 255 for n in s)
                    and s[5] == step
                    for s in states.values()
                ),
                "Wrong context/step",
            )
            require(states["initial"][0] == initial, "Wrong initial counter")
            if variant == "held-as-press":
                require(
                    states["held"][0] != states["pressed"][0],
                    "Held fault did not repeat",
                )
            else:
                require(
                    states["pressed"][0] == (initial + step) & 255
                    and states["held"][0] == states["pressed"][0]
                    and states["second"][0] == (initial + 2 * step) & 255,
                    "Press/hold/wrap policy failed",
                )
                require(
                    states["held"][6] == 0
                    and states["released"][1] == states["released"][6] == 0,
                    "Release/accepted flags failed",
                )
            if variant == "bad-wait":
                require(
                    data["service_ticks_in_30_frames"] not in range(28, 32),
                    "No-wait fault escaped",
                )
            else:
                require(
                    data["service_ticks_in_30_frames"] in range(28, 32),
                    "Field service rate failed",
                )
    good = record["program_sha256"]["working"]
    for repaired in ("fixed",) if basic else ("fixed-edge", "fixed-wait"):
        require(
            record["program_sha256"][repaired] == good,
            "Repair differs from the working program",
        )
    require(record["program_sha256"]["customise"] != good, "Customisation never built")


if __name__ == "__main__":
    for name in CONFIGS:
        check(name)
    print(
        "Three language-specific loop records and faulty/fixed controls match their inputs"
    )
