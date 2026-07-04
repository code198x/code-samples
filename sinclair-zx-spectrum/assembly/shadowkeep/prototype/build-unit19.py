#!/usr/bin/env python3
"""Weave — Unit 19: Stand or Sleep (the sealed chapter).

The game is whole — it plays, wins, loses, sounds, and lights. This unit seals it:
a hand-pixelled crown of stone battlements over the title, and the per-game
winnability gate met properly (a scripted run to each ending, THE KEEP STANDS and
THE KEEP SLEEPS, in capture/). "A complete, finishable game" is now true —
losable and winnable.

Single step, built on Unit 18's end.

Run from prototype/:  python3 build-unit19.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "weave" / "unit-18" / "steps" / "step-01.asm"
OUTDIR = HERE / "weave" / "unit-19" / "steps"
OUTDIR.mkdir(parents=True, exist_ok=True)

base = BASE.read_text()

H18 = ("; Shadowkeep — Unit 18: A Theme in One Voice\n"
       "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
       "; step-01 gives the title a voice — a solemn D-minor phrase, looping as it waits.")


def swap(t, old, new):
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:48]!r}"
    return t.replace(old, new)


BATTLEMENTS = """
; draw_battlements — a crown of stone merlons across the title, the keep's
; silhouette above its name. Drawn in wall stone at row 6, columns 8..23.
draw_battlements:
            ld      b, 6
            ld      c, 8
.db_loop:
            push    bc
            ld      hl, battlement_tile
            ld      (tile_ptr), hl
            ld      a, WALL_ATTR
            ld      (tile_attr), a
            call    draw_tile
            pop     bc
            inc     c
            ld      a, c
            cp      24
            jr      nz, .db_loop
            ret

battlement_tile:                    ; crenellations — merlons over solid wall
            defb    %11011011
            defb    %11011011
            defb    %11011011
            defb    %11111111
            defb    %11111111
            defb    %11111111
            defb    %11111111
            defb    %11111111
"""

t = swap(base, H18,
         "; Shadowkeep — Unit 19: Stand or Sleep\n"
         "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
         "; step-01 crowns the title with stone and seals the complete, winnable-and-losable game.")
# crown the title
t = swap(t,
         "show_title:\n"
         "            di\n"
         "            call    clear_screen\n"
         "            ld      hl, str_title\n",
         "show_title:\n"
         "            di\n"
         "            call    clear_screen\n"
         "            call    draw_battlements\n"
         "            ld      hl, str_title\n")
# the battlement routine + tile, after the theme data
t = swap(t,
         "            defb    75, 16           ; D5 (home)\n"
         "            defb    $FF              ; end\n",
         "            defb    75, 16           ; D5 (home)\n"
         "            defb    $FF              ; end\n"
         + BATTLEMENTS)

step00 = swap(base, H18,
              "; Shadowkeep — Unit 19: Stand or Sleep\n"
              "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
              "; step-00 = Unit 18's end: the whole game, its title bare above the keep.")

(OUTDIR / "step-00.asm").write_text(step00)
(OUTDIR / "step-01.asm").write_text(t)
print(f"wrote unit-19 step-00 ({len(step00.splitlines())}), step-01 ({len(t.splitlines())}) lines")
