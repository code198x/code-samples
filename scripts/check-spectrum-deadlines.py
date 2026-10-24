"""Validate separate native Spectrum routes and their revealing negative controls."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, file: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    if spec is None or spec.loader is None:
        raise RuntimeError(file)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


A = module("assembly", "verify-spectrum-assembly-deadlines.py")
B = module("basic", "verify-spectrum-basic-deadlines.py")
C = module("generic", "check-dragon-assembly-deadlines.py")
P = module("png", "check-amiga-command-loops.py")
T = A.T


def pixels(case, expected, row, folder: Path, light_ink: bool) -> None:
    p = case["pixels"]
    T.require(
        p["text"] == expected and p["row"] == row and p["font_base"] == 0x3C00,
        "Wrong captured row/text/font",
    )
    T.require(
        set(p["glyphs"]) == {str(ord(c)) for c in expected}
        and all(len(v) == 8 for v in p["glyphs"].values()),
        "Missing native glyph",
    )
    oracle = [[p["glyphs"][str(ord(c))][y] for c in expected] for y in range(8)]
    T.require(p["scanlines"] == oracle, "Native pixels disagree with state")
    width, height, channels, rgba = P.png(folder / case["image"])
    T.require((width, height, channels) == (352, 296, 4), "Wrong native geometry")
    for y in range(8):
        for x in range(len(expected) * 8):
            wanted = bool(oracle[y][x // 8] & (128 >> (x % 8)))
            pos = ((48 + row * 8 + y) * width + 48 + x) * channels
            rgb = rgba[pos : pos + 3]
            actual = min(rgb) > 128 if light_ink else max(rgb) < 128
            T.require(
                wanted == actual and rgba[pos + 3] == 255,
                "PNG differs from the native bitmap/font",
            )


def check_assembly(record=None):
    r = (
        record
        if record is not None
        else json.loads((A.F / "verification/results.json").read_text())
    )
    C.check("sinclair-zx-spectrum", r)
    for variant, c in r["cases"].items():
        T.require(
            (b"\xf9\xc0" in bytes(c["loader_bytes"])) == (variant != "no-entry"),
            "Missing/extra entry line",
        )
        if variant == "no-entry":
            T.require(c["startup"] == [], "Wrong loader control")
            continue
        T.require(
            bool(c["startup"])
            and len(c["startup"]) <= 20
            and c["startup"][-1]["reached"]
            and c["startup"][-1]["pc"] == 32768,
            "Code was not checked at USR entry",
        )
        source = (
            A.fixture(variant == "wrong-boundary")
            if "boundar" in variant
            else (
                A.F
                / {
                    "custom": "customise.asm",
                    "wrong": "wrong-baseline.asm",
                }.get(variant, "demo.asm")
            ).read_text()
        )
        T.require(
            c["entered_source_sha256"] == hashlib.sha256(source.encode()).hexdigest(),
            "Changed compiled source",
        )
        if "boundar" not in variant:
            pixels(
                c,
                "01 00 01" if variant == "wrong" else "03 01 01",
                0,
                A.F / "verification",
                False,
            )
    T.require(
        len(r["cases"]["working"]["loaded_bytes"]) == 393, "Changed measured payload"
    )


def check_basic(record=None):
    r = (
        record
        if record is not None
        else json.loads((B.F / "verification/results.json").read_text())
    )
    cfg = json.loads((B.F / "verification/configuration.json").read_text())
    T.require(
        (r["machine"], r["language"]) == ("sinclair-zx-spectrum", "basic"),
        "Wrong route",
    )
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in B.source_paths()},
        "Changed source/observer",
    )
    T.require(set(r["cases"]) == set(B.VARIANTS), "Missing native variant")
    T.require(
        all(
            r[k] == cfg[k]
            for k in ["emulator_sha256", "firmware_sha256", "build198x_sha256"]
        )
        and cfg["ram_bytes"] == 49152
        and cfg["mailbox"] == 50000,
        "Changed configuration",
    )
    for variant, c in r["cases"].items():
        T.require(c["server"]["version"] == "0.44.2", "Wrong actual emulator")
        text = B.listing(variant)
        T.require(
            c["source_sha256"] == hashlib.sha256(text.encode()).hexdigest(),
            "Changed entered listing",
        )
        lay = c["layout"]
        program = lay["program_bytes"]
        T.require(
            hashlib.sha256(bytes(program)).hexdigest() == c["program_sha256"],
            "Changed native program",
        )
        nums = [int(line.split()[0]) for line in text.splitlines()]
        T.require(
            [l["number"] for l in lay["lines"]] == nums
            and sum(l["bytes"] for l in lay["lines"]) == len(program),
            "Native line inventory differs",
        )
        # Independently parse actual native headers, not the stored count.
        i = 0
        parsed = []
        while i < len(program):
            T.require(i + 4 <= len(program), "Truncated native header")
            number = int.from_bytes(bytes(program[i : i + 2]), "big")
            size = int.from_bytes(bytes(program[i + 2 : i + 4]), "little") + 4
            T.require(
                size >= 5 and i + size <= len(program) and program[i + size - 1] == 13,
                "Native line corrupt",
            )
            parsed.append({"number": number, "bytes": size})
            i += size
        T.require(parsed == lay["lines"], "Native header map differs")
        entries = B.variables(lay["variable_bytes"])
        T.require(
            entries == lay["variables"]
            and lay["variable_extent"] == len(lay["variable_bytes"]),
            "Native variables differ",
        )
        T.require(
            lay["helper_token_bytes"]
            == sum(l["bytes"] for l in parsed if 3000 <= l["number"] <= 3250),
            "Helper token measurement differs",
        )
        T.require(
            lay["memory_limit"] == 49999
            and lay["program_end"] - lay["program_start"] == len(program),
            "Bad memory ownership",
        )
        T.require(
            T.sha(B.F / "verification" / c["image"]) == c["image_sha256"],
            "Changed capture",
        )
        T.require(
            re.search(r"RETURNED\s*5", bytes(c["return_screen"]).decode("ascii"))
            is not None,
            "No interpreter return arithmetic",
        )
        if "boundar" in variant:
            raw = c["bytes"]
            good = variant == "boundaries"
            T.require(
                len(raw) == 105 and raw[0] == 165 and raw[-2:] == [90, 239],
                "Incomplete fixture",
            )
            T.require(
                (raw == A.expected_fixture()) == good and c["oracle_matches"] == good,
                "Unsigned oracle mismatch",
            )
            continue
        T.require(
            lay["helper_token_bytes"] == 290
            and lay["helper_variable_bytes"] == 49
            and len(program) == 1784 + (7 if variant == "wrong" else 0),
            "Measured code/state costs differ",
        )
        actual = {v["name"]: v for v in entries}
        T.require(
            all(
                actual[n]["kind"] == 5 and actual[n]["bytes"] == 7
                for n in ["du", "dc", "dp", "dr", "da", "dx", "de"]
            ),
            "Unexpected numeric representation",
        )
        states = c["samples"]
        by = {s["stage"]: s for s in states}
        T.require(
            [s["stage"] for s in states[:5]]
            == ["initial", "untimed-idle", "untimed-action", "enabled", "idle-progress"]
            and [s["stage"] for s in states[-2:]] == ["disabled", "disabled-idle"],
            "Missing stage",
        )
        for s in states:
            raw = s["raw"]
            T.require(
                len(raw) == 19 and raw[16:19] == [165, 90, 202], "Incomplete observer"
            )
            fields = list(raw[:4]) + [
                int.from_bytes(bytes(raw[i : i + 2]), "little")
                for i in [4, 6, 8, 10, 12]
            ]
            T.require(
                fields
                == [
                    s[n]
                    for n in [
                        "turn",
                        "expiries",
                        "active",
                        "event",
                        "remaining",
                        "clock",
                        "previous",
                        "elapsed",
                        "duration",
                    ]
                ],
                "Native state differs",
            )
            T.require(
                s["duration"] == (100 if variant == "custom" else 200)
                and s["clock"] == s["previous"],
                "Wrong duration/baseline",
            )
        a, b = by["initial"], by["untimed-idle"]
        T.require(
            a["turn"] == b["turn"] == a["active"] == b["active"] == 0
            and a["clock"] != b["clock"],
            "Idle policy",
        )
        a = by["untimed-action"]
        T.require(a["turn"] == 1 and a["active"] == 0, "Untimed action")
        a, b = by["enabled"], by["idle-progress"]
        T.require(
            a["active"] == b["active"] == 1
            and a["turn"] == b["turn"] == 1
            and a["clock"] != b["clock"],
            "Timer progress missing",
        )
        if variant == "wrong":
            e = by["wrong-never-expires"]
            T.require(
                e["turn"] == 1 and e["expiries"] == 0 and e["remaining"] == 200,
                "No baseline-reset fault",
            )
        else:
            T.require(
                0 < b["remaining"] < a["remaining"]
                and a["remaining"] - b["remaining"]
                == (b["clock"] - a["clock"]) % 65536,
                "Elapsed countdown differs",
            )
            e = by["action-restarts"]
            T.require(e["turn"] == 2 and e["active"] == 1, "No restart")
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
            "Disable policy",
        )
        pixels(
            c,
            "TURN 1 E 0 T 1" if variant == "wrong" else "TURN 3 E 1 T 1",
            1,
            B.F / "verification",
            True,
        )
    T.require(
        r["cases"]["working"]["program_sha256"]
        == r["cases"]["repaired"]["program_sha256"],
        "Repair differs from normal",
    )


if __name__ == "__main__":
    check_assembly()
    check_basic()
    print(
        "Spectrum assembly and BASIC deadlines: native bytes, arithmetic, pixels and integration passed"
    )
