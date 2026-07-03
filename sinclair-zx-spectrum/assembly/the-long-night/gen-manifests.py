#!/usr/bin/env python3
"""The Long Night — generate each unit's capture manifest.

Choreography rules carried from the gloaming suites:
  * units 1-7 boot with the module-1 dusk chime (blocks ~2s): openings
    wait 160 frames before a short Space tap.
  * units 8-10 carry the title tune: Space taps on the title hold 30
    frames (the poll sits between tune cells).
  * end-screen Space taps hold 4 frames.
  * walking is tap-based (2 frames down, 5 up): the repeat gate makes
    each tap exactly one cell.
  * poke addresses are derived per PROGRAM from a fresh symbol table
    (pasmo) — never hardcoded by hand; layout shifts between steps.

Run from this directory:  python3 gen-manifests.py
(then: python3 ../../../_capture/capture.py unit-NN/capture/manifest.json)
"""

import json
import re
import subprocess
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent

_sym_cache: dict[str, dict[str, int]] = {}


def syms(program: str) -> dict[str, int]:
    if program not in _sym_cache:
        asm = HERE / program
        with tempfile.TemporaryDirectory() as td:
            sna = Path(td) / "x.sna"
            symf = Path(td) / "x.sym"
            subprocess.run(["pasmo", "--sna", str(asm), str(sna), str(symf)],
                           check=True, capture_output=True)
            _sym_cache[program] = {
                m.group(1): int(m.group(2), 16)
                for m in re.finditer(r"^(\S+)\s+EQU\s+0([0-9A-F]+)H$",
                                     symf.read_text(), re.M)}
    return _sym_cache[program]


def tap(k, n=1):
    out = []
    for _ in range(n):
        out += [{"hold": k}, {"wait": 2}, {"release": k}, {"wait": 5}]
    return out


def space(hold):
    return [{"hold": "Space"}, {"wait": hold}, {"release": "Space"}]


OPEN_CHIME = [{"wait": 160}] + space(4) + [{"wait": 10}]
OPEN_TUNE = [{"wait": 60}] + space(30) + [{"wait": 30}]

WALK_NE = tap("Q", 4) + tap("P", 7)          # (15,11) -> (22,7)
RETREAT = tap("O", 7) + tap("A", 4)          # back to (15,11)
WALK_SW = tap("O", 2) + tap("A", 9)          # (15,11) -> (13,20)

# the proven engineered-state pokes: seven pips lit, seven lamps (all
# but 13,20) recoloured LAMP_LIT — fixed VRAM, same on every build
PIPS7 = [{"poke": 0x5800 + 12 + i, "value": 0x70} for i in range(7)]
LAMPS7 = [{"poke": 0x5800 + r * 32 + c, "value": 0x46}
          for c, r in [(4, 3), (27, 3), (9, 7), (22, 7),
                       (6, 15), (25, 15), (18, 20)]]


def eng(program: str, extra: list) -> list:
    """Seven lamps lit, the wisp parked, then walk to the 8th at (13,20)."""
    s = syms(program)
    return (OPEN_CHIME if "unit-06" in program or "unit-07" in program
            else OPEN_TUNE) + [
        {"poke": s["lit_count"], "value": 7},
        {"poke": s["draught_timer"], "value": 255},
    ] + extra + PIPS7 + LAMPS7 + WALK_SW


M: dict[str, dict] = {}

# ---- unit 1: the hunt turns away from you; then the snuff ---------------
M["unit-01"] = {"captures": [
    {"id": "step-01-guards",
     "program": "steps/step-01.asm",
     "timeline": OPEN_CHIME + WALK_NE + RETREAT
     + [{"record_video": "step-01-turned.mp4"}, {"wait": 60},
        {"screenshot": "step-01-turned.png"}, {"wait": 170},
        {"screenshot": "step-01-guards.png"}, {"stop_video": True}]},
    {"id": "step-02-undone",
     "program": "steps/step-02.asm",
     "timeline": OPEN_CHIME + WALK_NE + RETREAT
     + [{"record_video": "step-02-undone.mp4"}, {"wait": 170},
        {"screenshot": "step-02-snuffed.png"}, {"wait": 110},
        {"screenshot": "step-02-hunts.png"}, {"stop_video": True}]},
]}

# ---- unit 2: withdraw with the prize; then the rest ----------------------
M["unit-02"] = {"captures": [
    {"id": "step-01-withdraws",
     "program": "steps/step-01.asm",
     "timeline": OPEN_CHIME + WALK_NE + RETREAT
     + [{"wait": 70}, {"record_video": "step-01-withdraws.mp4"},
        {"wait": 190}, {"screenshot": "step-01-home.png"},
        {"wait": 30}, {"screenshot": "step-01-restless.png"},
        {"stop_video": True}]},
    {"id": "step-02-rests",
     "program": "steps/step-02.asm",
     "timeline": OPEN_CHIME + WALK_NE + RETREAT
     + [{"wait": 70}, {"record_video": "step-02-rests.mp4"},
        {"wait": 190}, {"screenshot": "step-02-home.png"},
        {"wait": 30}, {"screenshot": "step-02-rests.png"},
        {"stop_video": True}]},
]}

# ---- unit 3: the pools — and the ghost the discipline prevents -----------
U3_STAGE = OPEN_CHIME + WALK_NE + tap("O", 1)   # light (22,7), stand in its ring
M["unit-03"] = {"captures": [
    {"id": "step-01-ghost",
     "program": "steps/step-01.asm",
     "timeline": U3_STAGE
     + [{"screenshot": "step-01-pool.png"},
        {"record_video": "step-01-ghost.mp4"},
        {"wait": 190}] + tap("O", 3)
     + [{"wait": 20}, {"screenshot": "step-01-ghost.png"},
        {"stop_video": True}]},
    {"id": "step-02-clean",
     "program": "steps/step-02.asm",
     "timeline": U3_STAGE
     + [{"record_video": "step-02-clean.mp4"},
        {"wait": 190}] + tap("O", 3)
     + [{"wait": 20}, {"screenshot": "step-02-clean.png"},
        {"stop_video": True}]},
]}

# ---- unit 4: the tendril — vein, ring release, and the claim scan --------
M["unit-04"] = {"captures": [
    {"id": "step-01-vein",
     "program": "steps/step-01.asm",
     "timeline": OPEN_CHIME
     + [{"wait": 150}, {"record_video": "step-01-vein.mp4"},
        {"wait": 105}, {"screenshot": "step-01-vein.png"},
        {"wait": 60}, {"screenshot": "step-01-released.png"},
        {"wait": 320}, {"stop_video": True},
        {"screenshot": "step-01-crossed.png"}]},
    {"id": "step-02-mended",
     "program": "steps/step-02.asm",
     "timeline": OPEN_CHIME
     + [{"wait": 640}, {"screenshot": "step-02-mended.png"}]},
    {"id": "step-03-takes-glow",
     "program": "steps/step-03.asm",
     "timeline": OPEN_CHIME + WALK_NE + RETREAT
     + [{"wait": 115}, {"screenshot": "step-03-takes-glow.png"},
        {"wait": 100}, {"screenshot": "step-03-after.png"}]},
]}

# ---- unit 5: the grudge ---------------------------------------------------
M["unit-05"] = {"captures": [
    {"id": "step-01-grudge",
     "program": "steps/step-01.asm",
     "timeline": OPEN_CHIME + WALK_SW + tap("P", 5)
     + [{"record_video": "step-01-grudge.mp4"},
        {"wait": 360}, {"screenshot": "step-01-grudge.png"},
        {"wait": 180}, {"screenshot": "step-01-snuffed.png"},
        {"stop_video": True}]},
]}

# ---- unit 6: the interstitial, the tables, the carried lives -------------
LIFE2 = lambda prog: [{"poke": syms(prog)["lives"], "value": 2},
                      {"poke": 0x5800 + 28 + 2, "value": 0x01}]
M["unit-06"] = {"captures": [
    {"id": "step-01-deeper",
     "program": "steps/step-01.asm",
     "timeline": eng("unit-06/steps/step-01.asm", LIFE2("unit-06/steps/step-01.asm"))
     + [{"wait": 250}, {"screenshot": "step-01-held.png"}]
     + space(4)
     + [{"wait": 80}, {"screenshot": "step-01-lie.png"}]},
    {"id": "step-02-corner",
     "program": "steps/step-02.asm",
     "timeline": eng("unit-06/steps/step-02.asm", [])
     + [{"wait": 250}] + space(4)
     + [{"wait": 80}, {"screenshot": "step-02-corner.png"}]},
    {"id": "step-03-carried",
     "program": "steps/step-03.asm",
     "timeline": eng("unit-06/steps/step-03.asm", LIFE2("unit-06/steps/step-03.asm"))
     + [{"wait": 250}, {"screenshot": "step-03-held.png"}]
     + space(4)
     + [{"wait": 80}, {"screenshot": "step-03-carried.png"}]},
]}

# ---- unit 7: dawn breaks — then the ceremony ------------------------------
DUSK4 = lambda prog: [{"poke": syms(prog)["dusk"], "value": 4}]
M["unit-07"] = {"captures": [
    {"id": "step-01-dawn",
     "program": "steps/step-01.asm",
     "timeline": eng("unit-07/steps/step-01.asm", DUSK4("unit-07/steps/step-01.asm"))
     + [{"wait": 220}, {"screenshot": "step-01-dawn.png"}]},
    {"id": "step-02-golden",
     "program": "steps/step-02.asm",
     "timeline": eng("unit-07/steps/step-02.asm", DUSK4("unit-07/steps/step-02.asm"))
     + [{"record_video": "step-02-sweep.mp4"},
        {"wait": 350}, {"screenshot": "step-02-golden.png"},
        {"stop_video": True}]},
]}

# ---- unit 8: the bells, the listening rest, the snuff's voice -------------
M["unit-08"] = {"captures": [
    {"id": "step-01-bells",
     "program": "steps/step-01.asm",
     "timeline": [{"wait": 30},
                  {"record_audio": "step-01-bells.wav"},
                  {"wait": 500},
                  {"stop_audio": True},
                  {"screenshot": "step-01-title.png"}]},
    {"id": "step-03-snuff",
     "program": "steps/step-03.asm",
     "timeline": OPEN_TUNE + WALK_NE + RETREAT
     + [{"wait": 60},
        {"record_audio": "step-03-snuff.wav"},
        {"wait": 220},
        {"stop_audio": True},
        {"screenshot": "step-03-snuffed.png"}]},
]}

# ---- unit 9: your longest night -------------------------------------------
M["unit-09"] = {"captures": [
    {"id": "step-01-longest",
     "program": "steps/step-01.asm",
     "timeline": OPEN_TUNE
     + [{"poke": syms("unit-09/steps/step-01.asm")["dusk"], "value": 2},
        {"poke": syms("unit-09/steps/step-01.asm")["lives"], "value": 1},
        {"wait": 520}, {"screenshot": "step-01-nightfalls.png"}]
     + space(4)
     + [{"wait": 40}, {"screenshot": "step-01-longest.png"}]},
]}

# ---- unit 10: the dawn phrase ----------------------------------------------
def u10_open(prog):
    s = syms(prog)
    return (OPEN_TUNE
            + [{"poke": s["lit_count"], "value": 7},
               {"poke": s["draught_timer"], "value": 255},
               {"poke": s["dusk"], "value": 4}]
            + PIPS7 + LAMPS7 + WALK_SW)

M["unit-10"] = {"captures": [
    {"id": "step-01-dawnphrase",
     "program": "steps/step-01.asm",
     "timeline": u10_open("unit-10/steps/step-01.asm")[:-len(WALK_SW)]
     + [{"record_audio": "step-01-dawnphrase.wav"}]
     + WALK_SW
     + [{"wait": 420}, {"stop_audio": True},
        {"screenshot": "step-01-dawn.png"}]
     + space(4)
     + [{"wait": 40}, {"screenshot": "step-01-morning.png"}]},
]}


def main() -> None:
    for unit, m in sorted(M.items()):
        cap = HERE / unit / "capture"
        cap.mkdir(parents=True, exist_ok=True)
        manifest = {
            "machine": "sinclair-zx-spectrum",
            "image_dir": f"sinclair-zx-spectrum/assembly/the-long-night/{unit}",
            "captures": m["captures"],
        }
        (cap / "manifest.json").write_text(json.dumps(manifest, indent=1) + "\n")
        print(f"{unit}/capture/manifest.json ({len(m['captures'])} captures)")


if __name__ == "__main__":
    main()
