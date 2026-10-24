"""Check NES serial-input histories, streamed release pairs and original-font output."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import zlib
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


V = module("native", "verify-nes-input-edges.py")
P = module("png", "check-amiga-command-loops.py")
T = V.T
EXPECTED = bytes(
    sum(
        1 << bit
        for bit in range(8)
        if previous & (1 << bit) and not current & (1 << bit)
    )
    for previous in range(256)
    for current in range(256)
)


def pixels(case: dict[str, Any]) -> None:
    w, h, ch, rgba = P.png(V.V / case["image"])
    T.require((w, h, ch) == (256, 240, 4), "Wrong NTSC capture geometry")
    font = [
        int(n)
        for line in (V.F / "edges-font.inc").read_text().splitlines()
        if ".byte " in line
        for n in line.split(".byte ")[1].split(",")
    ]
    T.require(len(font) == 272, "Wrong font extent")
    text = (
        " ".join(
            f"{case['capture']['state'][k]:02X}"
            for k in ["controls", "new_presses", "released_controls", "actions"]
        )
        + " "
    )
    for y in range(8):
        for x in range(len(text) * 8):
            char = text[x // 8]
            tile = 0 if char == " " else int(char, 16) + 1
            wanted = bool(font[tile * 16 + y] & (128 >> (x % 8)))
            pos = ((8 + y) * w + 16 + x) * ch
            T.require(
                (tuple(rgba[pos : pos + 3]) != (0, 0, 0)) == wanted
                and rgba[pos + 3] == 255,
                "PNG differs from native input state/font",
            )


def check(record: dict[str, Any] | None = None) -> None:
    r = record if record is not None else json.loads((V.V / "results.json").read_text())
    cfg = json.loads((V.V / "configuration.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("nintendo-nes", "assembly"), "Wrong route"
    )
    T.require(
        r["sources"]
        == {str(p.resolve().relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source or observer",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing native case")
    T.require(
        all(r[k] == cfg[k] for k in ["emulator_sha256", "assembler_sha256"])
        and cfg["model"] == "NTSC NES, NROM-256, DMC disabled",
        "Wrong configuration",
    )
    for variant, c in r["cases"].items():
        T.require(c["server"]["version"] == "0.44.2", "Wrong emulator")
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
            "Changed selected caller",
        )
        T.require(
            c["cart_sha256"] == cfg["cart_sha256"][variant]
            and c["native_prg_sha256"] == cfg["native_prg_sha256"][variant],
            "Native cartridge/PRG differs",
        )
        if "boundar" in variant:
            raw = zlib.decompress(bytes.fromhex(c["rows_zlib_hex"]))
            T.require(
                len(raw) == 65536
                and c["row_count"] == len(c["stops"]) == 256
                and c["end_guard"] == 165,
                "Release fixture incomplete",
            )
            T.require(
                all(
                    s["reached"] and s["pc"] == c["row_done_pc"] and s["steps"] > 0
                    for s in c["stops"]
                ),
                "Missing completed row",
            )
            mismatches = sum(a != b for a, b in zip(raw, EXPECTED, strict=True))
            good = variant == "boundaries"
            T.require(
                (raw == EXPECTED) == good
                and c["oracle_matches"] == good
                and mismatches == c["mismatches"],
                "Release oracle differs",
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
            "release-a",
            "release-all",
            "all-buttons",
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
            T.require(0 <= mask <= 255, "Input outside byte range")
            new = mask & (255 ^ history)
            released = history & (255 ^ mask)
            T.require(
                sample["stop"]["reached"]
                and state["controls"] == mask
                and state["new_presses"] & ~mask == 0
                and state["released_controls"] & mask == 0,
                "Serial-input masks differ",
            )
            if variant != "wrong":
                presses += bool(new)
                releases += bool(released)
                actions += bool(new & (2 if variant == "custom" else 128))
                T.require(
                    [state[k] for k in ["press_events", "release_events", "actions"]]
                    == [presses, releases, actions],
                    "Event history differs",
                )
                if new:
                    T.require(state["last_new"] == new, "Wrong press mask")
                if released:
                    T.require(state["last_release"] == released, "Wrong release mask")
            history = mask
        by = {s["stage"]: s["state"] for s in c["samples"]}
        if variant == "wrong":
            T.require(
                by["hold"]["actions"] > by["press"]["actions"]
                and by["capture"]["actions"] > 3
                and by["capture"]["release_events"] == 0,
                "Missing history-reset fault",
            )
        T.require(
            c["capture"] == c["samples"][-1]
            and c["code_bytes"] == 32
            and c["state_bytes"] == 2,
            "Wrong costs or capture",
        )
        pixels(c)
    T.require(
        r["cases"]["working"]["cart_sha256"] == r["cases"]["repaired"]["cart_sha256"],
        "Repair differs",
    )


if __name__ == "__main__":
    check()
    print(
        "NES edges: real serial inputs, 65536 release pairs, PRG and PNG checks passed"
    )
