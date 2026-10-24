"""Recheck Atari 800XL native deadline state, loaded bytes and actual PNG pixels."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import re
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


V = module("native", "verify-atari-xl-assembly-deadlines.py")
T = V.T
P = module("png", "check-amiga-command-loops.py")


def pixels(case: dict[str, Any], text: str) -> None:
    cap = case["capture"]
    codes = [ord(c) - 32 for c in text]
    T.require(
        cap["text"] == text and cap["codes"] == codes and cap["font_base"] == 57344,
        "Wrong native screen/font",
    )
    T.require(
        set(cap["glyphs"]) == {str(c) for c in codes}
        and all(len(g) == 8 for g in cap["glyphs"].values()),
        "Missing native glyph",
    )
    w, h, channels, rgba = P.png(V.F / "verification" / case["image"])
    T.require((w, h, channels) == (376, 240, 4), "Wrong capture geometry")
    x0, y0 = 28, 24
    pos = (y0 * w + x0 + 16) * channels
    paper = tuple(rgba[pos : pos + 3])
    for y in range(8):
        for x in range(64):
            wanted = bool(cap["glyphs"][str(codes[x // 8])][y] & (128 >> (x % 8)))
            pos = ((y0 + y) * w + x0 + x) * channels
            rgb = tuple(rgba[pos : pos + 3])
            actual = rgb != paper
            T.require(
                wanted == actual and rgba[pos + 3] == 255,
                "PNG differs from native glyphs",
            )


def check(record: dict[str, Any] | None = None) -> None:
    r = (
        record
        if record is not None
        else json.loads((V.F / "verification/results.json").read_text())
    )
    cfg = json.loads((V.F / "verification/configuration.json").read_text())
    T.require(
        (r["machine"], r["language"]) == ("atari-800xl", "assembly"), "Wrong route"
    )
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source or observer",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing native caller")
    T.require(
        all(
            r[k] == cfg[k]
            for k in ["emulator_sha256", "assembler_sha256", "firmware_sha256"]
        )
        and cfg["ramtop_page"] == 124
        and cfg["reserved_gap"] == 1024,
        "Wrong configuration",
    )
    for variant, c in r["cases"].items():
        T.require(c["server"]["version"] == "0.44.2", "Wrong actual emulator")
        data = c["loaded_bytes"]
        T.require(
            0 < len(data) < 768
            and hashlib.sha256(bytes(data)).hexdigest() == c["loaded_sha256"],
            "Loaded bytes differ",
        )
        source = (
            V.fixture(variant == "wrong-boundary")
            if "boundar" in variant
            else (
                V.F
                / {
                    "custom": "customise.asm",
                    "wrong": "mistakes/reset-baseline.asm",
                }.get(variant, "demo.asm")
            ).read_text()
        )
        T.require(
            c["entered_source_sha256"] == hashlib.sha256(source.encode()).hexdigest(),
            "Changed selected program",
        )
        reserve = c["reservation"]
        loader = c["loader_ready"]
        loader_text = "".join(
            chr((v & 127) + 32) if (v & 127) < 64 else " " for v in loader["bytes"]
        )
        loader_rows = [
            loader_text[i : i + 40].strip()
            for i in range(0, 960, 40)
            if loader_text[i : i + 40].strip()
        ]
        T.require(
            loader_text == loader["text"] and loader_rows[-1:] == ["READY"],
            "BASIC loader did not finish before USR",
        )
        base = int.from_bytes(bytes(reserve["savmsc"]), "little")
        T.require(
            reserve["ramtop"] == [124]
            and int.from_bytes(bytes(reserve["memtop"]), "little") < base
            and base + 960 <= 31744,
            "Screen/code reservation overlaps",
        )
        T.require(
            T.sha(V.F / "verification" / c["image"]) == c["image_sha256"],
            "Changed capture",
        )
        ret = c["return_screen"]
        actual = "".join(
            chr((v & 127) + 32) if (v & 127) < 64 else " " for v in ret["bytes"]
        )
        T.require(
            actual == ret["text"]
            and re.search(r"RETURNED\s*5\s*USR\s*0", actual) is not None,
            "No balanced interpreter return/result",
        )
        if "boundar" in variant:
            raw = c["bytes"]
            good = variant == "boundaries"
            T.require(
                len(raw) == 105 and raw[0] == 165 and raw[-2:] == [90, 239],
                "Incomplete second caller",
            )
            T.require(
                (raw == V.expected_fixture()) == good and c["oracle_matches"] == good,
                "Wrong unsigned oracle",
            )
            continue
        T.require(
            len(data) == (430 if variant == "wrong" else 424), "Changed measured image"
        )
        states = c["samples"]
        by = {s["stage"]: s for s in states}
        T.require(
            [s["stage"] for s in states[:5]]
            == ["initial", "untimed-idle", "untimed-action", "enabled", "idle-progress"]
            and [s["stage"] for s in states[-2:]] == ["disabled", "disabled-idle"],
            "Missing native stage",
        )
        for s in states:
            raw = s["raw"]
            T.require(len(raw) == 16, "Wrong context footprint")
            T.require(
                s["stop"]["reached"] and s["stop"]["pc"] == 32822,
                "Unfinished native update",
            )
            fields = [
                raw[0],
                raw[1],
                raw[8],
                int.from_bytes(bytes(raw[6:8]), "little"),
                int.from_bytes(bytes(raw[12:14]), "little"),
            ]
            T.require(
                fields
                == [s[k] for k in ["turn", "expiries", "active", "remaining", "clock"]],
                "Native state differs",
            )
            T.require(
                int.from_bytes(bytes(raw[4:6]), "little")
                == (120 if variant == "custom" else 240),
                "Wrong duration",
            )
        a, b = by["initial"], by["untimed-idle"]
        T.require(
            a["turn"] == b["turn"] == a["active"] == b["active"] == 0
            and a["clock"] != b["clock"],
            "Untimed policy/clock failed",
        )
        a = by["untimed-action"]
        T.require(a["turn"] == 1 and a["active"] == 0, "Held action repeated")
        a, b = by["enabled"], by["idle-progress"]
        T.require(
            a["active"] == b["active"] == 1
            and a["turn"] == b["turn"] == 1
            and a["clock"] != b["clock"],
            "No advancing timer",
        )
        if variant == "wrong":
            e = by["wrong-never-expires"]
            T.require(
                e["turn"] == 1 and e["expiries"] == 0 and e["remaining"] == 240,
                "No wrong-baseline symptom",
            )
        else:
            T.require(
                0 < b["remaining"] < a["remaining"]
                and a["remaining"] - b["remaining"]
                == (b["clock"] - a["clock"]) % 65536,
                "Elapsed countdown differs",
            )
            e = by["action-restarts"]
            T.require(
                e["turn"] == 2 and e["active"] == 1 and e["remaining"] > b["remaining"],
                "Restart failed",
            )
            e = states[-3]
            T.require(
                e["turn"] == 3 and e["expiries"] == e["active"] == 1,
                "No automatic turn",
            )
        a, b = states[-2:]
        T.require(
            a["active"] == b["active"] == 0
            and a["turn"] == b["turn"]
            and b["frames"] - a["frames"] >= 250,
            "Disable failed",
        )
        T.require(
            c["capture"]["screen_base"] == base, "Capture used a different display"
        )
        pixels(c, "01 00 01" if variant == "wrong" else "03 01 01")
    T.require(
        r["cases"]["working"]["loaded_bytes"] == r["cases"]["repaired"]["loaded_bytes"],
        "Repair differs from normal",
    )


if __name__ == "__main__":
    check()
    print(
        "Atari 800XL assembly deadlines: bytes, reservation, arithmetic, input, return and PNGs passed"
    )
