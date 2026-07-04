#!/usr/bin/env python3
"""Weave — Unit 16: A Keep with Character (many flames, each cell its nearest).

Last unit of the atmosphere sub-arc. Upgrades lighting from one torch per room to
many: find_torches gathers every 'T' into a list, and shade_for_cell lights each
floor cell by its NEAREST flame (then the room's falloff). The Hall gains two
side-wall sconces (three in all), the Gallery an east-wall torch; the Vault keeps
its single altar flame — its character is the dark.

Single step, built on Unit 15's end. New torches sit clear of the gold and the
warden routes.

Run from prototype/:  python3 build-unit16.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "weave" / "unit-15" / "steps" / "step-01.asm"
OUTDIR = HERE / "weave" / "unit-16" / "steps"
OUTDIR.mkdir(parents=True, exist_ok=True)

base = BASE.read_text()

H15 = ("; Shadowkeep — Unit 15: Mood through Constraint\n"
       "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
       "; step-01 gives each room its own falloff — the Hall broad, the Vault a tight crypt.")


def swap(t, old, new):
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:48]!r}"
    return t.replace(old, new)


FIND_TORCH_OLD = """find_torch:
            ld      a, NO_TORCH
            ld      (torch_col), a
            ld      (torch_row), a
            call    room_entry_addr
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            ld      b, 0
.ft_row:
            ld      c, 0
.ft_col:
            ld      a, (hl)
            cp      'T'
            jr      nz, .ft_skip
            ld      a, c
            ld      (torch_col), a
            ld      a, b
            ld      (torch_row), a
.ft_skip:
            inc     hl
            inc     c
            ld      a, c
            cp      32
            jr      nz, .ft_col
            inc     b
            ld      a, b
            cp      24
            jr      nz, .ft_row
            ret"""

FIND_TORCHES_NEW = """; find_torches — collect every 'T' in the current room (up to MAX_TORCHES) into
; torch_list as (col, row) pairs; torch_count says how many.
find_torches:
            xor     a
            ld      (torch_count), a
            call    room_entry_addr
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            ld      b, 0
.fr_row:
            ld      c, 0
.fr_col:
            ld      a, (hl)
            cp      'T'
            jr      nz, .fr_skip
            ld      a, (torch_count)
            cp      MAX_TORCHES
            jr      nc, .fr_skip
            push    hl
            add     a, a            ; count * 2
            ld      e, a
            ld      d, 0
            ld      hl, torch_list
            add     hl, de
            ld      (hl), c         ; column
            inc     hl
            ld      (hl), b         ; row
            pop     hl
            ld      a, (torch_count)
            inc     a
            ld      (torch_count), a
.fr_skip:
            inc     hl
            inc     c
            ld      a, c
            cp      32
            jr      nz, .fr_col
            inc     b
            ld      a, b
            cp      24
            jr      nz, .fr_row
            ret"""

SHADE_MOOD = """shade_for_cell:
            push    bc
            ld      a, (torch_col)
            cp      NO_TORCH
            jr      z, .sf_dark
            ld      a, b
            ld      hl, torch_row
            sub     (hl)
            jr      nc, .sf_rpos
            neg
.sf_rpos:
            ld      d, a            ; |row - torch_row|
            ld      a, c
            ld      hl, torch_col
            sub     (hl)
            jr      nc, .sf_cpos
            neg
.sf_cpos:
            cp      d               ; A = |dc|; max(|dc|, |dr|)
            jr      nc, .sf_max
            ld      a, d
.sf_max:
            ld      e, a                ; E = Chebyshev distance
            ld      a, (current_room)   ; shift it by THIS room's falloff
            ld      c, a
            ld      b, 0
            ld      hl, room_falloff
            add     hl, bc
            ld      b, (hl)             ; B = this room's falloff
            ld      a, e
            inc     b
.sf_shift:
            dec     b
            jr      z, .sf_clamp
            srl     a
            jr      .sf_shift
.sf_clamp:
            cp      MAX_SHADE + 1
            jr      c, .sf_done
            ld      a, MAX_SHADE
.sf_done:
            pop     bc
            ret
.sf_dark:
            ld      a, MAX_SHADE
            pop     bc
            ret"""

SHADE_MULTI = """shade_for_cell:
            push    bc
            ld      a, b
            ld      (cell_row), a
            ld      a, c
            ld      (cell_col), a
            ld      a, (torch_count)
            or      a
            jr      z, .sf_dark
            ld      a, 255
            ld      (min_dist), a
            ld      hl, torch_list
            ld      a, (torch_count)
            ld      b, a            ; loop count
.sf_loop:
            ld      a, (cell_col)
            sub     (hl)            ; - torch col
            jr      nc, .sf_dc
            neg
.sf_dc:
            ld      d, a            ; |dc|
            inc     hl              ; -> torch row
            ld      a, (cell_row)
            sub     (hl)
            jr      nc, .sf_dr
            neg
.sf_dr:
            inc     hl              ; -> next torch pair
            cp      d               ; A = |dr|; take the larger
            jr      nc, .sf_mx
            ld      a, d
.sf_mx:
            ld      e, a            ; this torch's distance
            ld      a, (min_dist)
            cp      e
            jr      c, .sf_keep     ; min already smaller
            ld      a, e
            ld      (min_dist), a
.sf_keep:
            djnz    .sf_loop

            ld      a, (current_room)
            ld      c, a
            ld      b, 0
            ld      hl, room_falloff
            add     hl, bc
            ld      b, (hl)
            ld      a, (min_dist)
            inc     b
.sf_shift:
            dec     b
            jr      z, .sf_clamp
            srl     a
            jr      .sf_shift
.sf_clamp:
            cp      MAX_SHADE + 1
            jr      c, .sf_done
            ld      a, MAX_SHADE
.sf_done:
            pop     bc
            ret
.sf_dark:
            ld      a, MAX_SHADE
            pop     bc
            ret"""

t = swap(base, H15,
         "; Shadowkeep — Unit 16: A Keep with Character\n"
         "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
         "; step-01 lets a room hold many torches — each floor cell lit by its nearest flame.")
# equates: drop NO_TORCH, add MAX_TORCHES
t = swap(t, "NO_TORCH    equ     $FF\nMAX_SHADE   equ     4",
         "MAX_SHADE   equ     4\nMAX_TORCHES equ     4")
# find_torch -> find_torches
t = swap(t, FIND_TORCH_OLD, FIND_TORCHES_NEW)
# shade_for_cell -> nearest-of-many
t = swap(t, SHADE_MOOD, SHADE_MULTI)
# draw_room now gathers all torches
t = swap(t, "            call    find_torch\n", "            call    find_torches\n")
# variables: swap the single-torch pair for the multi-torch scratch + list
t = swap(t,
         "torch_col:\n"
         "            defb    NO_TORCH\n"
         "torch_row:\n"
         "            defb    NO_TORCH\n",
         "torch_count:\n"
         "            defb    0\n"
         "cell_row:\n"
         "            defb    0\n"
         "cell_col:\n"
         "            defb    0\n"
         "min_dist:\n"
         "            defb    0\n"
         "torch_list:\n"
         "            defs    MAX_TORCHES * 2\n")
# Hall: two side-wall sconces on the first pillar row (row 8)
t = swap(t,
         '            defb    "#.............ooo.........G....#"\n'
         '            defb    "#..............................#"\n'
         '            defb    "#........##..........##........#"\n',
         '            defb    "#.............ooo.........G....#"\n'
         '            defb    "#..............................#"\n'
         '            defb    "T........##..........##........T"\n')
# Gallery: an east-wall torch in the top chamber (row 4)
t = swap(t,
         'room1_template:\n'
         '            defb    "###############.################"\n'
         '            defb    "#..............................#"\n'
         '            defb    "#..............................#"\n'
         '            defb    "#..............................#"\n'
         '            defb    "#..............................#"\n',
         'room1_template:\n'
         '            defb    "###############.################"\n'
         '            defb    "#..............................#"\n'
         '            defb    "#..............................#"\n'
         '            defb    "#..............................#"\n'
         '            defb    "#..............................T"\n')

step00 = swap(base, H15,
              "; Shadowkeep — Unit 16: A Keep with Character\n"
              "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
              "; step-00 = Unit 15's end: each room one torch; now a room may hold many.")

(OUTDIR / "step-00.asm").write_text(step00)
(OUTDIR / "step-01.asm").write_text(t)
print(f"wrote unit-16 step-00 ({len(step00.splitlines())}), step-01 ({len(t.splitlines())}) lines")
