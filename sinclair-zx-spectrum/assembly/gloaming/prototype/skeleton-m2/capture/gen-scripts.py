#!/usr/bin/env python3
"""Gloaming module-2 route skeleton — generate the per-unit gate scripts.

One script per unit: boot the unit's .sna, drive the named proof shot,
save it to artefacts/ (not committed). Poke addresses are derived from
each unit's .sym file (the suite's rule: never hardcode addresses —
layout shifts between builds). Screen-attribute pokes (pips, lamp
cells) are fixed VRAM addresses and mirror the proven m2 suite.

Choreography rules carried from prototype/capture/README.md:
  * units 01-07 carry m1's boot chime (blocks ~2s) — openings wait
    160 frames before the Space tap; short taps are safe there.
  * units 08-10 carry the title tune — Space taps on the title hold
    30 frames (the poll sits between tune cells).
  * end-screen Space taps hold 4 frames (outliving the 25-frame lock
    starts an unwanted run).
  * walking is tap-based (2 frames down, 5 up): the repeat gate's
    instant-first-step + re-arm makes each tap exactly one cell.

Unit 10's scripts are the proven dawn/dawnwav choreography with paths
rewritten: the build is byte-identical to gloaming.sna, so poke
addresses transfer as-is.

Run from this directory:  python3 gen-scripts.py
"""

import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent          # skeleton-m2/capture
SKEL = HERE.parent                              # skeleton-m2
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


def tap(k: str, n: int = 1) -> list:
    """n discrete steps: 2 frames down, 5 up — one cell per tap."""
    steps = []
    for _ in range(n):
        steps += [key(k, True), run(2), key(k, False), run(5)]
    return steps


def space(hold: int) -> list:
    return [key("Space", True), run(hold), key("Space", False)]


# the chime-build opening: boot chime, then a short Space tap
OPEN_CHIME = [run(160)] + space(4) + [run(10)]
# the tune-build opening: title tolls, Space held across a cell
OPEN_TUNE = [run(60)] + space(30) + [run(30)]

# (15,11) -> (22,7): up 4, right 7 — lights the NE-quarter lamp
WALK_NE_LAMP = tap("Q", 4) + tap("P", 7)
# retreat to the square's centre: left 7, down 4
RETREAT = tap("O", 7) + tap("A", 4)
# (15,11) -> (13,20): left 2, down 9 — the proven route to the SW lamp
WALK_SW_LAMP = tap("O", 2) + tap("A", 9)

# fixed VRAM pokes from the proven m2 suite: seven pips lit, seven
# lamps (all but 13,20) recoloured LAMP_LIT so the poked lit_count is
# honest on screen and to the snuff rule
PIPS7 = [poke(0x5800 + 12 + i, 0x70) for i in range(7)]
LAMPS7 = [poke(0x5800 + r * 32 + c, 0x46)
          for c, r in [(4, 3), (27, 3), (9, 7), (22, 7),
                       (6, 15), (25, 15), (18, 20)]]


def engineered_eighth(unit: str, extra: list) -> list:
    """Space, then the proven engineered state: 7 lamps lit, the wisp
    parked (timer 255), walk to the 8th lamp at (13,20)."""
    return ([load(unit)] + OPEN_CHIME
            + [poke(sym(unit, "lit_count"), 7),
               poke(sym(unit, "draught_timer"), 255)]
            + extra + PIPS7 + LAMPS7 + WALK_SW_LAMP)


SCRIPTS: dict[str, list] = {}

# unit 1 — the nearest-light hunt turns away from you, and the snuff
# (silent) undoes your work: light (22,7), retreat, watch it die
SCRIPTS["unit-01"] = ([load("unit-01")] + OPEN_CHIME
                      + WALK_NE_LAMP + RETREAT
                      + [run(30), shot("u01-turned"),
                         run(150), shot("u01-snuffed")])

# unit 2 — after the snuff the night withdraws with its prize
SCRIPTS["unit-02"] = ([load("unit-02")] + OPEN_CHIME
                      + WALK_NE_LAMP + RETREAT
                      + [run(140), shot("u02-prize"),
                         run(120), shot("u02-home")])

# unit 3 — the lit lamp pools: a glow ring on the stipple
SCRIPTS["unit-03"] = ([load("unit-03")] + OPEN_CHIME
                      + WALK_NE_LAMP + [run(10), shot("u03-pool")])

# unit 4 — the tendril: a vein of night behind the wisp, capped at 6
SCRIPTS["unit-04"] = ([load("unit-04")] + OPEN_CHIME
                      + [run(380), shot("u04-vein"),
                         run(60), shot("u04-later")])

# unit 5 — the grudge: two lamps lit; the wisp crosses the square for
# the OLDER one, ignoring the nearer player and prize
SCRIPTS["unit-05"] = ([load("unit-05")] + OPEN_CHIME
                      + WALK_SW_LAMP + tap("P", 5)
                      + [run(360), shot("u05-grudge"),
                         run(180), shot("u05-snuffed")])

# unit 6 — the held screen becomes an interstitial: the night deepens,
# and the dark probes watch 2 from a new quarter (SE)
SCRIPTS["unit-06"] = (engineered_eighth("unit-06", [])
                      + [run(250), shot("u06-held")]
                      + space(4)
                      + [run(80), shot("u06-deeper")])

# unit 7 — dawn breaks: the fifth watch's eighth lamp ends the run
SCRIPTS["unit-07"] = (engineered_eighth(
                          "unit-07", [poke(sym("unit-07", "dusk"), 4)])
                      + [run(350), shot("u07-dawn")])

# unit 8 — the dusk bells: ten seconds of the title tune...
SCRIPTS["unit-08"] = ([load("unit-08"), run(30),
                       {"action": "start_audio_recording",
                        "path": str(ART / "u08-bells.wav")},
                       run(500),
                       {"action": "stop_audio_recording"},
                       shot("u08-title")])
# ...and the snuff finds its voice (unit 1's choreography, recorded)
SCRIPTS["unit-08-snuff"] = ([load("unit-08")] + OPEN_TUNE
                            + WALK_NE_LAMP + RETREAT
                            + [run(60),
                               {"action": "start_audio_recording",
                                "path": str(ART / "u08-snuff.wav")},
                               run(220),
                               {"action": "stop_audio_recording"},
                               shot("u08-snuffed")])

# unit 9 — your longest night: two watches survived on a lost run
# outlive the loop back to the title
SCRIPTS["unit-09"] = ([load("unit-09")] + OPEN_TUNE
                      + [poke(sym("unit-09", "dusk"), 2),
                         poke(sym("unit-09", "lives"), 1),
                         run(520), shot("u09-nightfalls")]
                      + space(4)
                      + [run(40), shot("u09-longest")])

# unit 10 — the proven dawn/dawnwav choreography against the
# byte-identical build
for src, dst in [("dawn", "unit-10"), ("dawnwav", "unit-10-wav")]:
    steps = json.loads((PROTO / "capture" / f"{src}.script.json").read_text())
    for step in steps:
        if step.get("action") == "load_snapshot":
            step["path"] = str(SKEL / "unit-10.sna")
        for k in ("path",):
            if step.get("action") in ("save_screenshot",
                                      "start_audio_recording") and k in step:
                name = Path(step[k]).stem
                ext = Path(step[k]).suffix
                step[k] = str(ART / f"u10-{name}{ext}")
    SCRIPTS[dst] = steps


def main() -> None:
    for name, steps in SCRIPTS.items():
        out = HERE / f"{name}.script.json"
        out.write_text(json.dumps(steps, indent=1) + "\n")
        print(f"{out.name} ({len(steps)} steps)")


if __name__ == "__main__":
    main()
