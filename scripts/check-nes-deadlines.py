"""Check native optional-turn evidence, elapsed arithmetic, policy and frozen pictures."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    if spec is None or spec.loader is None:
        raise RuntimeError(file)
    v = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(v)
    return v


V = module("native", "verify-nes-deadlines.py")
P = module("png", "check-amiga-command-loops.py")
T = V.T


def font():
    return [
        int(n)
        for line in (V.F / "../../input/controller-reading/edges-font.inc")
        .read_text()
        .splitlines()
        if ".byte " in line
        for n in line.split(".byte ")[1].split(",")
    ]


def pixels(c):
    w, h, ch, p = P.png(V.V / c["image"])
    T.require((w, h, ch) == (256, 240, 4), "Wrong native geometry")
    f = font()
    text = " ".join(f"{v:02X}" for v in c["display"]) + " "
    for y in range(8):
        for x in range(len(text) * 8):
            char = text[x // 8]
            tile = 0 if char == " " else int(char, 16) + 1
            wanted = bool(f[tile * 16 + y] & (128 >> (x % 8)))
            pos = ((8 + y) * w + 16 + x) * ch
            T.require(
                (tuple(p[pos : pos + 3]) != (0, 0, 0)) == wanted and p[pos + 3] == 255,
                "PNG differs from frozen native row/font",
            )


def check(record=None):
    r = record if record is not None else json.loads((V.V / "results.json").read_text())
    cfg = json.loads((V.V / "configuration.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("nintendo-nes", "assembly"), "Wrong route"
    )
    T.require(r["configuration"] == cfg, "Changed native configuration")
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source/observer",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing native case")
    T.require(
        len(V.expected_math()) == 96 and len(V.expected_policy()) == 96,
        "Incomplete independent fixture coverage",
    )
    stages = [
        "untimed-initial",
        "untimed-idle",
        "first-action",
        "held-action",
        "release-action",
        "second-action",
        "release-second",
        "enable",
        "held-select",
        "release-select",
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
        T.require(c["server"]["version"] == "0.44.2", "Wrong producer")
        prg = bytes(c["loaded_prg_bytes"])
        T.require(
            len(prg) == 32768
            and hashlib.sha256(prg).hexdigest() == c["loaded_prg_sha256"],
            "Native PRG differs",
        )
        f = bytes(font()) if "boundar" not in name else b""
        cart = b"NES\x1a" + bytes([2, 1]) + bytes(10) + prg + f + bytes(8192 - len(f))
        T.require(
            hashlib.sha256(cart).hexdigest() == c["cartridge_sha256"],
            "Cartridge/CHR differs",
        )
        src = (
            V.fixture(name == "wrong-boundary")
            if "boundar" in name
            else (V.F / (name + ".asm")).read_text()
        )
        T.require(
            hashlib.sha256(src.encode()).hexdigest() == c["source_sha256"],
            "Changed selected caller",
        )
        if "boundar" in name:
            raw = c["bytes"]
            expected = V.expected_math()
            T.require(
                c["stop"]["reached"]
                and len(raw) == len(expected) + len(V.expected_policy()) + 2
                and raw[0] == 165
                and raw[-1] == 239,
                "Incomplete fixture",
            )
            equal = raw[1 : 1 + len(expected)] == expected
            T.require(
                equal == (name == "boundaries")
                and c["math_matches"] == equal
                and c["policy_matches"]
                and raw[1 + len(expected) : -1] == V.expected_policy(),
                "Independent wrap/countdown/policy oracle differs",
            )
            continue
        T.require(
            [s["stage"] for s in c["samples"]] == stages, "Missing native transition"
        )
        by = {s["stage"]: s for s in c["samples"]}
        duration = 60 if name == "custom" else 180
        for s in c["samples"]:
            dl = s["deadline"]
            st = s["state"]
            T.require(
                s["stop"]["reached"]
                and s["input"] == s["controls"]
                and len(st) == 10
                and len(dl) == 12,
                "Incomplete frame/input",
            )
            T.require(
                dl[:2] == [duration, 0]
                and dl[4] in (0, 1)
                and dl[5] in (0, 1)
                and int.from_bytes(bytes(dl[2:4]), "little") <= duration
                and dl[8:10] == dl[10:12],
                "Invalid deadline state",
            )
            sampled = int.from_bytes(bytes(dl[8:10]), "little")
            T.require(
                (s["clock"] - sampled) % 65536 < 256, "Sample clock is incoherent/stale"
            )
        T.require(
            by["untimed-initial"]["state"][4:7]
            == by["untimed-idle"]["state"][4:7]
            == [0, 0, 0]
            and by["untimed-initial"]["clock"] != by["untimed-idle"]["clock"],
            "Untimed/clock contract differs",
        )
        T.require(
            by["first-action"]["state"][4:6]
            == by["held-action"]["state"][4:6]
            == [1, 0]
            and by["second-action"]["state"][4] == 2,
            "Held action repeated/new action missing",
        )
        T.require(
            by["enable"]["deadline"][4] == by["held-select"]["deadline"][4] == 1,
            "Toggle repeat/enable differs",
        )
        slow_a, slow_b = by["slow-start"], by["slow-expiry"]
        fast_a, fast_b = by["untimed-initial"], by["untimed-idle"]
        ticks = (slow_b["clock"] - slow_a["clock"]) % 65536
        updates = (
            int.from_bytes(bytes(slow_b["state"][:2]), "little")
            - int.from_bytes(bytes(slow_a["state"][:2]), "little")
        ) % 65536
        fast_ticks = (fast_b["clock"] - fast_a["clock"]) % 65536
        fast_updates = (
            int.from_bytes(bytes(fast_b["state"][:2]), "little")
            - int.from_bytes(bytes(fast_a["state"][:2]), "little")
        ) % 65536
        T.require(
            [ticks, updates, fast_ticks, fast_updates]
            == [c["slow_ticks"], c["slow_updates"], c["fast_ticks"], c["fast_updates"]]
            and min(ticks, updates, fast_ticks, fast_updates) > 0
            and ticks > duration
            and ticks * fast_updates > fast_ticks * updates,
            "Measured work/clock distinction differs",
        )
        if name == "wrong":
            T.require(
                slow_b["state"][6] == 0 and slow_b["deadline"][2:4] == [180, 0],
                "Reset-baseline symptom missing",
            )
        else:
            T.require(
                slow_b["state"][6] > slow_a["state"][6]
                and by["second-expiry"]["state"][6] > by["disabled-idle"]["state"][6],
                "Timer failed under work/reenable",
            )
        T.require(
            by["disable"]["deadline"][4] == by["disabled-idle"]["deadline"][4] == 0
            and by["disable"]["state"][4:7] == by["disabled-idle"]["state"][4:7],
            "Disabled timer advanced",
        )
        T.require(
            c["capture"] == by["freeze-display"]
            and c["display"] == c["capture"]["display"]
            and len(c["display"]) == 8
            and c["capture"]["clock"] > 255,
            "Display latch/high carry differs",
        )
        T.require(
            0 < (c["frozen_clock_after"] - c["capture"]["clock"]) % 65536 < 256
            and c["frozen_deadline_after"][8:10] != c["capture"]["deadline"][8:10],
            "Display freeze stopped timer service",
        )
        T.require(
            c["caller_state_bytes"] == 39
            and c["clock_state_bytes"] == 5
            and c["deadline_state_bytes"] == 12
            and c["font_bytes"] == 272
            and c["clock_code_bytes"] > 0
            and c["deadline_code_bytes"] > 0
            and c["code_prefix_bytes"] > 0,
            "Costs differ",
        )
        T.require(T.sha(V.V / c["image"]) == c["image_sha256"], "Changed capture")
        pixels(c)
    T.require(
        r["cases"]["demo"]["cartridge_sha256"]
        == r["cases"]["repaired"]["cartridge_sha256"],
        "Repair differs",
    )


if __name__ == "__main__":
    check()
    print(
        "NES deadlines: native NMI/work/input events, independent math/policy and PNGs passed"
    )
