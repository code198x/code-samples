"""Validate native IRQ timer evidence, independent arithmetic and rendered pixels."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, file):
    s = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


V = module("native", "verify-amiga-deadlines.py")
P = module("png", "check-amiga-command-loops.py")
T = V.T


def pixels(c):
    plane = zlib.decompress(bytes.fromhex(c["plane_zlib"]))
    T.require(len(plane) == 10240, "Incomplete bitplane")
    font = [
        int(v.strip().replace("$", "0x"), 0)
        for line in (V.F / "font.inc").read_text().splitlines()
        if "dc.b " in line
        for v in line.split("dc.b ")[1].split(",")
    ]
    text = " ".join(f"{v:04X}" for v in c["display"]) + " "
    for row in range(8):
        for col, char in enumerate(text):
            index = 0 if char == " " else int(char, 16) + 1
            T.require(
                plane[(49 + row) * 40 + 2 + col] == font[index * 8 + row],
                "Bitplane differs from displayed words",
            )
    w, h, ch, p = P.png(V.V / c["image"])
    T.require((w, h, ch) == (768, 576, 4), "Wrong native geometry")
    for y in range(256):
        for x in range(320):
            on = bool(plane[y * 40 + x // 8] & (128 >> (x % 8)))
            for dy in range(2):
                for dx in range(2):
                    pos = ((38 + y * 2 + dy) * w + 82 + x * 2 + dx) * ch
                    T.require(
                        (tuple(p[pos : pos + 3]) == (255, 255, 255)) == on
                        and p[pos + 3] == 255,
                        "PNG differs from native bitplane",
                    )


def check(record=None):
    r = record if record is not None else json.loads((V.V / "results.json").read_text())
    cfg = json.loads((V.V / "configuration.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("commodore-amiga", "assembly"), "Wrong route"
    )
    T.require(
        r["configuration"] == cfg and len(cfg["emulator_sha256"]) == 64,
        "Changed configuration",
    )
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source/observer",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing native case")
    math = [v for row in V.expected_math() for v in row]
    policy = [v for row in V.expected_policy() for v in row]
    T.require(len(math) == 60 and len(policy) == 64, "Incomplete oracle")
    stages = [
        "untimed-initial",
        "untimed-idle",
        "first-action",
        "held-action",
        "release-action",
        "second-action",
        "release-second",
        "enable",
        "held-toggle",
        "release-toggle",
        "renew-action",
        "release-renew",
        "slow-start",
        "slow-expiry",
        "end-slow",
        "renew-before-disable",
        "release-before-disable",
        "disable",
        "release-disable",
        "disabled-idle",
        "reenable",
        "release-reenable",
        "second-expiry",
        "freeze-display",
    ]
    for name, c in r["cases"].items():
        T.require(c["server"]["version"] == "0.44.2", "Unexpected base version")
        exe = zlib.decompress(bytes.fromhex(c["hunk_zlib"]))
        T.require(
            len(exe) == c["executable_bytes"]
            and hashlib.sha256(exe).hexdigest() == c["executable_sha256"],
            "Changed Hunk",
        )
        body, relocs = V.H.hunk(exe)
        relocated = bytearray(body)
        for i in relocs:
            relocated[i : i + 4] = (
                int.from_bytes(body[i : i + 4], "big") + c["base"]
            ).to_bytes(4, "big")
        T.require(len(c["segments"]) >= 2, "No native code readback")
        for seg in c["segments"]:
            T.require(
                seg["last"] > seg["first"]
                and seg["bytes"] == list(relocated[seg["first"] : seg["last"]]),
                "Changed relocated code",
            )
        src = (
            V.lifecycle()
            if name == "lifecycle"
            else V.fixture(name == "wrong-boundary")
            if "boundar" in name
            else (V.F / (name + ".asm")).read_text()
        )
        T.require(
            hashlib.sha256(src.encode()).hexdigest() == c["source_sha256"],
            "Changed caller",
        )
        if name == "lifecycle":
            a = c["words"]
            T.require(
                c["ready"] == 0xCAFE
                and a[:5] == [0, 0, 0, 1, 0]
                and (a[6] - a[5]) % 65536 == 3
                and a[7:] == [1, a[6], 0, 0x4000, 0],
                "IRQ lifecycle differs",
            )
            T.require(
                c["original_vector"] == c["restored_vector"]
                and c["stopped_before"] == c["stopped_after"] == a[8],
                "Clock did not stop/restore",
            )
            continue
        if "boundar" in name:
            a = c["words"]
            equal = a[1:61] == math
            T.require(
                c["ready"] == 0xCAFE
                and len(a) == 126
                and a[0] == 0xA55A
                and a[-1] == 0xCAFE
                and equal == (name == "boundaries")
                and c["math_matches"] == equal
                and c["policy_matches"]
                and a[61:-1] == policy,
                "Independent word oracle differs",
            )
            continue
        T.require([s["stage"] for s in c["samples"]] == stages, "Missing transition")
        by = {s["stage"]: s for s in c["samples"]}
        duration = 50 if name == "custom" else 150
        for s in c["samples"]:
            d = s["deadline"]
            T.require(
                s["stop"]["reached"]
                and s["input"] == s["controls"]
                and s["installed"] == 1
                and len(d) == 7
                and d[0] == duration
                and d[1] <= duration
                and d[2] in (0, 1)
                and d[3] in (0, 1)
                and d[5] == d[6]
                and (s["clock"] - d[6]) % 65536 < 256,
                "Invalid sampled state",
            )
        a, b = by["untimed-initial"], by["untimed-idle"]
        T.require(
            a["turns"] == b["turns"] == a["expiries"] == b["expiries"] == 0
            and a["clock"] != b["clock"],
            "Untimed progression differs",
        )
        T.require(
            by["first-action"]["turns"] == by["held-action"]["turns"] == 1
            and by["second-action"]["turns"] == 2,
            "Held/new press differs",
        )
        T.require(
            by["enable"]["deadline"][2] == by["held-toggle"]["deadline"][2] == 1,
            "Held toggle differs",
        )
        a, b = by["slow-start"], by["slow-expiry"]
        fa, fb = by["untimed-initial"], by["untimed-idle"]
        counts = [
            (b["clock"] - a["clock"]) % 65536,
            (b["updates"] - a["updates"]) % 65536,
            (fb["clock"] - fa["clock"]) % 65536,
            (fb["updates"] - fa["updates"]) % 65536,
        ]
        ticks, updates, ft, fu = counts
        T.require(
            counts
            == [c["slow_ticks"], c["slow_updates"], c["fast_ticks"], c["fast_updates"]]
            and min(counts) > 0
            and ticks > duration
            and ticks * fu > ft * updates,
            "Clock/work distinction differs",
        )
        if name == "wrong":
            T.require(
                b["expiries"] == 0 and b["deadline"][1] == 150, "Missing baseline fault"
            )
        else:
            T.require(
                b["expiries"] > a["expiries"]
                and by["second-expiry"]["expiries"] > by["disabled-idle"]["expiries"],
                "Timer did not expire",
            )
        a, b = by["disable"], by["disabled-idle"]
        T.require(
            (a["turns"], a["expiries"], a["deadline"][2])
            == (b["turns"], b["expiries"], b["deadline"][2])
            and a["deadline"][2] == 0,
            "Disabled timer advanced",
        )
        a = c["capture"]
        T.require(
            a == by["freeze-display"]
            and c["display"] == a["display"]
            and len(c["display"]) == 7
            and 0 < (c["frozen_clock_after"] - a["clock"]) % 65536 < 256
            and c["frozen_deadline_after"][5] != a["deadline"][5],
            "Freeze stopped clock",
        )
        before, after, frames = c["tick_interval"]
        T.require(
            frames == 100 and (after - before) % 65536 == 100, "Frame/IRQ ratio differs"
        )
        T.require(
            c["clock_code_bytes"] > 0
            and c["clock_state_bytes"] == 8
            and c["deadline_code_bytes"] > 0
            and c["deadline_state_bytes"] == 14
            and c["display_bytes"] == 10240
            and c["font_bytes"] == 136,
            "Costs differ",
        )
        T.require(T.sha(V.V / c["image"]) == c["image_sha256"], "Changed capture")
        pixels(c)
    T.require(
        r["cases"]["demo"]["executable_sha256"]
        == r["cases"]["repaired"]["executable_sha256"],
        "Repair differs",
    )


if __name__ == "__main__":
    check()
    print(
        "Amiga deadlines: native IRQ, lifecycle, input, arithmetic, policy and pixels passed"
    )
