#!/usr/bin/env python3
"""Weave — Unit 17: Footsteps and Doors (the keep's ambient voice).

The game's *events* already sound — the gold chimes (Unit 9), victory flourishes
(9), capture tolls (11). This unit gives the keep its ambient voice: a footfall
under every step, a creak as a door swings. Both reuse the beep primitive the
gold chime already established.

  sfx_step  a short low footfall, under every successful move.
  sfx_door  a creak that groans downward, as a room changes.

Single step, built on Unit 16's end.

Run from prototype/:  python3 build-unit17.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "weave" / "unit-16" / "steps" / "step-01.asm"
OUTDIR = HERE / "weave" / "unit-17" / "steps"
OUTDIR.mkdir(parents=True, exist_ok=True)

base = BASE.read_text()

H16 = ("; Shadowkeep — Unit 16: A Keep with Character\n"
       "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
       "; step-01 lets a room hold many torches — each floor cell lit by its nearest flame.")


def swap(t, old, new):
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:48]!r}"
    return t.replace(old, new)


SFX_CODE = """
; sfx_step — a footfall: short and low, gone almost before you notice it. Played
; under every successful move.
sfx_step:
            ld      b, 5
            ld      c, 90
            call    beep
            ret

; sfx_door — a creak: a tone that falls in pitch as it plays, so the note groans
; downward — a heavy door swinging on its hinges.
sfx_door:
            ld      c, 36            ; start higher
.sd_sweep:
            ld      b, 3
            push    bc
            call    beep
            pop     bc
            inc     c                ; lower the pitch a little
            inc     c
            ld      a, c
            cp      130              ; until it has groaned down low
            jr      c, .sd_sweep
            ret
"""

t = swap(base, H16,
         "; Shadowkeep — Unit 17: Footsteps and Doors\n"
         "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
         "; step-01 gives the keep its ambient voice — a footfall per step, a creak per door.")
# sfx routines, after the gold chime
t = swap(t,
         "sfx_pickup:\n"
         "            ld      b, 8\n"
         "            ld      c, 20\n"
         "            call    beep\n"
         "            ld      b, 8\n"
         "            ld      c, 14\n"
         "            call    beep\n"
         "            ret\n",
         "sfx_pickup:\n"
         "            ld      b, 8\n"
         "            ld      c, 20\n"
         "            call    beep\n"
         "            ld      b, 8\n"
         "            ld      c, 14\n"
         "            call    beep\n"
         "            ret\n"
         + SFX_CODE)
# a footfall under every move
t = swap(t,
         "            call    save_under\n"
         "            call    draw_thief\n"
         "            call    check_exit\n"
         "            ret\n",
         "            call    save_under\n"
         "            call    draw_thief\n"
         "            call    sfx_step\n"
         "            call    check_exit\n"
         "            ret\n")
# a creak as a room changes
t = swap(t,
         ".enter:\n"
         "            call    draw_room\n",
         ".enter:\n"
         "            call    sfx_door\n"
         "            call    draw_room\n")

step00 = swap(base, H16,
              "; Shadowkeep — Unit 17: Footsteps and Doors\n"
              "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
              "; step-00 = Unit 16's end: the game sounds its events, but the keep is otherwise silent.")

(OUTDIR / "step-00.asm").write_text(step00)
(OUTDIR / "step-01.asm").write_text(t)
print(f"wrote unit-17 step-00 ({len(step00.splitlines())}), step-01 ({len(t.splitlines())}) lines")
