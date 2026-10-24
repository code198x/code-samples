"""Reject changed sources, native input histories, matrix outputs and capture pixels."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, file: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    if spec is None or spec.loader is None:
        raise RuntimeError(file)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


V = module("native", "verify-c64-input-edges.py")
P = module("png", "check-amiga-command-loops.py")
T = V.T


def pixels(case: dict[str, Any], glyphs: dict[str, list[int]]) -> None:
    w, h, ch, rgba = P.png(V.V / case["image"])
    T.require((w, h, ch) == (416, 312, 4), "Wrong PAL capture geometry")
    row = case["capture"]["row"]
    for y in range(8):
        for x in range(21 * 8):
            wanted = bool(glyphs[str(row[x // 8])][y] & (128 >> (x % 8)))
            pos = ((51 + y) * w + 48 + x) * ch
            T.require(
                tuple(rgba[pos : pos + 3]) == ((255, 255, 255) if wanted else (0, 0, 0))
                and rgba[pos + 3] == 255,
                "PNG differs from native screen/font",
            )


def check(record: dict[str, Any] | None = None) -> None:
    r = record if record is not None else json.loads((V.V / "results.json").read_text())
    cfg = json.loads((V.V / "configuration.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("commodore-64", "assembly"), "Wrong route"
    )
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source or observer",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing native case")
    T.require(
        all(
            r[k] == cfg[k]
            for k in ["emulator_sha256", "assembler_sha256", "firmware_sha256"]
        )
        and cfg["model"] == "C64 PAL, stock recorded ROMs, CIA1 exclusive",
        "Configuration differs",
    )
    for variant, c in r["cases"].items():
        T.require(c["server"]["version"] == "0.44.2", "Wrong native emulator")
        data = c["loaded_bytes"]
        T.require(
            len(data) > 0
            and hashlib.sha256(bytes(data)).hexdigest() == c["loaded_sha256"],
            "Loaded code differs",
        )
        text = (
            V.fixture(variant == "wrong-boundary")
            if "boundar" in variant
            else (
                V.F
                / {"custom": "edges-custom.asm", "wrong": "edges-wrong.asm"}.get(
                    variant, "edges-demo.asm"
                )
            ).read_text()
        )
        T.require(
            hashlib.sha256(text.encode()).hexdigest() == c["source_sha256"],
            "Changed selected caller",
        )
        if "boundar" in variant:
            expected = (
                [165]
                + [
                    sum(
                        1 << bit
                        for bit in range(5)
                        if p & (1 << bit) and not n & (1 << bit)
                    )
                    for p in range(32)
                    for n in range(32)
                ]
                + [239]
            )
            T.require(
                len(c["bytes"]) == 1026
                and c["bytes"][0] == 165
                and c["bytes"][-1] == 239,
                "Fixture incomplete",
            )
            T.require(
                (c["bytes"] == expected) == (variant == "boundaries")
                and c["oracle_matches"] == (variant == "boundaries"),
                "Release set-difference oracle differs",
            )
            continue
        T.require(T.sha(V.V / c["image"]) == c["image_sha256"], "Changed capture")
        stages = [
            "idle",
            "press",
            "hold",
            "release",
            "second-press",
            "simultaneous",
            "release-fire",
            "release-all",
            "both-ports",
            "both-hold",
            "both-release",
            "capture",
        ]
        T.require([s["stage"] for s in c["samples"]] == stages, "Missing transition")
        history = [0, 0]
        presses = [0, 0]
        releases = [0, 0]
        actions = 0
        for sample in c["samples"]:
            state = sample["state"]
            T.require(sample["stop"]["reached"], "Caller did not complete")
            for i, current in enumerate(sample["input"]):
                new = current & (31 ^ history[i])
                released = history[i] & (31 ^ current)
                T.require(
                    state[f"joy{i + 1}"] == current
                    and state[f"joy{i + 1}_new"] & ~current == 0
                    and state[f"joy{i + 1}_released"] & current == 0,
                    "Native masks violate input",
                )
                if variant != "wrong":
                    presses[i] += bool(new)
                    releases[i] += bool(released)
                    T.require(
                        [state[f"press_events{i + 1}"], state[f"release_events{i + 1}"]]
                        == [presses[i], releases[i]],
                        "Transition history differs",
                    )
                    if new:
                        T.require(state[f"last_new{i + 1}"] == new, "Wrong press bits")
                    if released:
                        T.require(
                            state[f"last_release{i + 1}"] == released,
                            "Wrong release bits",
                        )
                if i == 1 and new & (4 if variant == "custom" else 16):
                    actions += 1
                history[i] = current
            if variant != "wrong":
                T.require(state["actions"] == actions, "Held input repeated")
            values = [
                state[k]
                for k in [
                    "joy1",
                    "joy1_new",
                    "joy1_released",
                    "joy2",
                    "joy2_new",
                    "joy2_released",
                    "actions",
                ]
            ]
            codes = []
            for value in values:
                codes += [
                    48 + n if n < 10 else n - 9 for n in [value >> 4, value & 15]
                ] + [32]
            T.require(codes == sample["row"], "Screen differs from native state")
        by = {s["stage"]: s["state"] for s in c["samples"]}
        if variant == "wrong":
            T.require(
                by["hold"]["actions"] > by["press"]["actions"]
                and by["capture"]["actions"] > 2
                and by["capture"]["release_events2"] == 0,
                "Missing wrong-history symptom",
            )
        T.require(
            c["capture"] == c["samples"][-1]
            and c["state_bytes"] == 3
            and c["code_bytes"] > 0,
            "Wrong capture or costs",
        )
        pixels(c, cfg["glyphs"])
    T.require(
        r["cases"]["working"]["loaded_sha256"]
        == r["cases"]["repaired"]["loaded_sha256"],
        "Repair differs",
    )


if __name__ == "__main__":
    check()
    print("C64 input edges: native transitions, 1024 release pairs and PNGs passed")
