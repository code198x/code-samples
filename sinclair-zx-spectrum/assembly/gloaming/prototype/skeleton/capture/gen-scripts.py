#!/usr/bin/env python3
"""Gloaming route skeleton — generate the per-unit gate scripts.

One script per unit: boot the unit's .sna, drive the named proof shot,
save it to artefacts/ (not committed). Poke addresses are derived from
each unit's .sym file (the m1 suite's rule: never hardcode addresses —
layout shifts between builds).

Unit 20's script is the proven m1-won.script.json with paths rewritten:
the build is byte-identical to gloaming-m1.sna, so the choreography and
poke addresses transfer as-is.

Run from this directory:  python3 gen-scripts.py
"""

import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent          # skeleton/capture
SKEL = HERE.parent                              # skeleton
PROTO = SKEL.parent                             # prototype
ART = HERE / "artefacts"
ART.mkdir(exist_ok=True)


def sym(unit: str, name: str) -> int:
    text = (SKEL / f"{unit}.sym").read_text()
    m = re.search(rf"^{name}\s+EQU\s+0([0-9A-F]+)H$", text, re.M)
    assert m, f"{name} not in {unit}.sym"
    return int(m.group(1), 16)


def load(unit: str) -> dict:
    return {"action": "load_snapshot", "path": str(SKEL / f"{unit}.sna")}


def run(n: int) -> dict:
    return {"action": "run_frames", "frames": n}


def key(name: str, pressed: bool) -> dict:
    return {"action": "input",
            "events": [{"Key": {"name": name, "pressed": pressed}}]}


def shot(name: str) -> dict:
    return {"action": "save_screenshot", "path": str(ART / f"{name}.png")}


def poke(addr: int, value: int) -> dict:
    return {"action": "poke_byte", "addr": addr, "value": value}


def hold(k: str, frames: int, settle: int = 5) -> list:
    return [key(k, True), run(frames), key(k, False), run(settle)]


SCRIPTS: dict[str, list] = {}

# Phase A — a square at dusk
SCRIPTS["unit-01"] = [load("unit-01"), run(20), shot("u01-square")]
SCRIPTS["unit-02"] = [load("unit-02"), run(20), shot("u02-texture")]
SCRIPTS["unit-03"] = [load("unit-03"), run(20), shot("u03-lamplighter")]
SCRIPTS["unit-04"] = [load("unit-04"), run(50), shot("u04-steady-a"),
                      run(100), shot("u04-steady-b")]
# the probe cell's ink pixels are invisible over an empty bitmap; a
# 12-frame gap always crosses a paper-bit boundary of the counting attr.
# The video is the real proof: three seconds of the heartbeat, watched.
SCRIPTS["unit-04-pulse"] = [load("unit-04-pulse"), run(50), shot("u04-pulse-a"),
                            run(12), shot("u04-pulse-b"),
                            {"action": "start_video_recording",
                             "path": str(ART / "u04-pulse.mp4")},
                            run(150),
                            {"action": "stop_video_recording"}]

# Phase B — movement done honestly (the detour run)
SCRIPTS["unit-05"] = [load("unit-05"), run(20), shot("u05-idle"),
                      key("O", True), run(10), shot("u05-glow"),
                      key("O", False)]

WALK_SHORT = hold("A", 8) + hold("O", 6) + [run(10)]
SCRIPTS["unit-06"] = [load("unit-06"), run(20)] + WALK_SHORT + [shot("u06-gouge")]
SCRIPTS["unit-07"] = [load("unit-07"), run(20)] + WALK_SHORT + [shot("u07-tamed")]
SCRIPTS["unit-08"] = [load("unit-08"), run(20)] + WALK_SHORT + [shot("u08-intact")]

SCRIPTS["unit-09"] = [load("unit-09"), run(20)] + hold("Q", 40) + hold("O", 55) + \
                     [shot("u09-blocked")]
SCRIPTS["unit-10"] = [load("unit-10"), run(20)] + hold("P", 110) + \
                     [shot("u10-edge")]

# Phase C — a game
WALK_TO_LAMP = hold("A", 60) + hold("O", 10)          # (15,11) -> (13,20)
SCRIPTS["unit-11"] = [load("unit-11"), run(20), shot("u11-lanterns")] + \
                     WALK_TO_LAMP + [shot("u11-stand")] + hold("O", 2) + \
                     [shot("u11-passed")]
SCRIPTS["unit-12"] = [load("unit-12"), run(20)] + WALK_TO_LAMP + hold("O", 2) + \
                     [shot("u12-lit")]
SCRIPTS["unit-13"] = [load("unit-13"), run(20)] + WALK_TO_LAMP + hold("P", 38) + \
                     [shot("u13-pips")]
SCRIPTS["unit-14"] = [load("unit-14"), run(30),
                      poke(sym("unit-14", "lit_count"), 7)] + WALK_TO_LAMP + \
                     [run(10), shot("u14-gold")]
SCRIPTS["unit-15"] = [load("unit-15"), run(30),
                      poke(sym("unit-15", "lit_count"), 7)] + WALK_TO_LAMP + \
                     [run(20), shot("u15-held")]

# Phase D — jeopardy
SCRIPTS["unit-16"] = [load("unit-16"), run(250), shot("u16-hunt"),
                      run(310), shot("u16-pinned")]
SCRIPTS["unit-17"] = [load("unit-17"), run(500), shot("u17-lifelost"),
                      run(700), shot("u17-nightfalls")]

# Phase E — make it feel finished
SCRIPTS["unit-18"] = [load("unit-18"), run(30),
                      poke(sym("unit-18", "lit_count"), 7),
                      {"action": "start_audio_recording",
                       "path": str(ART / "u18-blip-fanfare.wav")}] + \
                     WALK_TO_LAMP + [run(150),
                                     {"action": "stop_audio_recording"},
                                     shot("u18-held")]
SCRIPTS["unit-19"] = [load("unit-19"), run(30), shot("u19-title"),
                      run(130), key("Space", True), run(4),
                      key("Space", False), run(30), shot("u19-play")]

# unit 20 — the proven m1-won choreography against the byte-identical build
m1won = json.loads((PROTO / "capture" / "m1-won.script.json").read_text())
for step in m1won:
    if step.get("action") == "load_snapshot":
        step["path"] = str(SKEL / "unit-20.sna")
    if step.get("action") == "save_screenshot":
        name = Path(step["path"]).stem.replace("m1-", "u20-")
        step["path"] = str(ART / f"{name}.png")
SCRIPTS["unit-20"] = m1won


def main() -> None:
    for name, steps in SCRIPTS.items():
        out = HERE / f"{name}.script.json"
        out.write_text(json.dumps(steps, indent=1) + "\n")
        print(f"{out.name} ({len(steps)} steps)")


if __name__ == "__main__":
    main()
