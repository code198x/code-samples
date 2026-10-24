"""Check Spectrum native keyboard histories, complete TAP image and capture pixels."""

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


V = module("native", "verify-spectrum-input-edges.py")
P = module("png", "check-amiga-command-loops.py")
T = V.T


def pixels(case: dict[str, Any]) -> None:
    cap = case["pixels"]
    text = cap["text"]
    glyphs = cap["glyphs"]
    scan = cap["scanlines"]
    T.require(
        scan == [[glyphs[str(ord(c))][y] for c in text] for y in range(8)],
        "Native bitmap differs from font",
    )
    w, h, ch, rgba = P.png(V.V / case["image"])
    T.require((w, h, ch) == (352, 296, 4), "Wrong PAL screenshot")
    pos = (48 * w + 48 + 16) * ch
    paper = tuple(rgba[pos : pos + 3])
    for y in range(8):
        for x in range(len(text) * 8):
            wanted = bool(scan[y][x // 8] & (128 >> (x % 8)))
            pos = ((48 + y) * w + 48 + x) * ch
            T.require(
                (tuple(rgba[pos : pos + 3]) != paper) == wanted
                and rgba[pos + 3] == 255,
                "PNG differs from native bitmap",
            )


def check(record: dict[str, Any] | None = None) -> None:
    r = record if record is not None else json.loads((V.V / "results.json").read_text())
    cfg = json.loads((V.V / "configuration.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("sinclair-zx-spectrum", "assembly"),
        "Wrong route",
    )
    T.require(
        r["sources"]
        == {str(p.resolve().relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source or observer",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing caller")
    T.require(
        all(
            r[k] == cfg[k]
            for k in ["emulator_sha256", "assembler_sha256", "firmware_sha256"]
        )
        and cfg["model"] == "48K PAL, stock recorded ROM",
        "Wrong configuration",
    )
    for variant, c in r["cases"].items():
        T.require(c["server"]["version"] == "0.44.2", "Wrong native emulator")
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
            c["source_sha256"] == hashlib.sha256(text.encode()).hexdigest(),
            "Changed caller",
        )
        payload = c["payload"]
        loaded = c["loaded_image"]
        mutable = c["mutable_offsets"]
        T.require(
            len(payload) == len(loaded) == c["payload_bytes"]
            and hashlib.sha256(bytes(payload)).hexdigest()
            == c["payload_sha256"]
            == cfg["payload_sha256"][variant],
            "Payload differs",
        )
        T.require(
            len(mutable) == (0 if "boundar" in variant else 10)
            and len(set(mutable)) == len(mutable)
            and all(0 <= i < len(payload) for i in mutable),
            "Wrong mutable extent",
        )
        T.require(
            all(
                a == b
                for i, (a, b) in enumerate(zip(payload, loaded, strict=True))
                if i not in mutable
            )
            and c["loaded_prefix"] == loaded[: len(c["loaded_prefix"])],
            "Native immutable image differs",
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
                "Set-difference oracle mismatch",
            )
            continue
        T.require(T.sha(V.V / c["image"]) == c["image_sha256"], "Changed image")
        stages = [
            "idle",
            "press",
            "hold",
            "release",
            "second-press",
            "simultaneous",
            "release-fire",
            "release-all",
            "all-keys",
            "all-hold",
            "all-release",
            "capture",
        ]
        T.require([s["stage"] for s in c["samples"]] == stages, "Missing transition")
        history = 0
        presses = 0
        releases = 0
        actions = 0
        for sample in c["samples"]:
            state = sample["state"]
            mask = sample["input"]
            new = mask & (31 ^ history)
            released = history & (31 ^ mask)
            T.require(
                sample["stop"]["reached"]
                and state["controls"] == mask
                and state["new_presses"] & ~mask == 0
                and state["released_controls"] & mask == 0,
                "Native masks differ",
            )
            if variant != "wrong":
                presses += bool(new)
                releases += bool(released)
                actions += bool(new & (4 if variant == "custom" else 16))
                T.require(
                    [state[k] for k in ["press_events", "release_events", "actions"]]
                    == [presses, releases, actions],
                    "Native history differs",
                )
                if new:
                    T.require(state["last_new"] == new, "Wrong new bits")
                if released:
                    T.require(state["last_release"] == released, "Wrong release bits")
            history = mask
        by = {s["stage"]: s["state"] for s in c["samples"]}
        if variant == "wrong":
            T.require(
                by["hold"]["actions"] > by["press"]["actions"]
                and by["capture"]["actions"] > 3
                and by["capture"]["release_events"] == 0,
                "Missing wrong-history symptom",
            )
        T.require(
            c["capture"] == c["samples"][-1]
            and c["state_bytes"] == 1
            and c["code_bytes"] > 0,
            "Wrong capture or costs",
        )
        expected = " ".join(
            f"{c['capture']['state'][k]:02X}"
            for k in ["controls", "new_presses", "released_controls", "actions"]
        )
        T.require(
            c["pixels"]["text"] == expected and c["pixels"]["font_base"] == 15360,
            "Wrong native text/font",
        )
        pixels(c)
    T.require(
        r["cases"]["working"]["payload_sha256"]
        == r["cases"]["repaired"]["payload_sha256"],
        "Repair differs",
    )


if __name__ == "__main__":
    check()
    print(
        "Spectrum input edges: native keyboard, 1024 masks, immutable TAP image and PNGs passed"
    )
