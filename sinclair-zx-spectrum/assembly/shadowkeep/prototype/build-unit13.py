#!/usr/bin/env python3
"""Weave — Unit 13: Light and Shadow (atmosphere begins, over a working game).

First unit of Sub-arc 1.4. Re-homes the shipped lighting system (from the old
"Light and Shadow" unit) onto the game-core base: a torch in each room, and floor
shaded by distance from the flame. The Warden is lighting-agnostic — its buffer
preserves whatever shade sits under it — so it walks lit stone untouched, and the
gold-collect repaint upgrades from plain floor to the lit shade here.

Torches sit at column 15 (Hall top wall, Gallery south wall, Vault top wall),
clear of the gold (cols 24/26/10/20) and the warden routes.

Single step: the lighting system, exactly as it shipped, threaded over gold +
wardens. Built on Unit 12's end.

Run from prototype/:  python3 build-unit13.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "weave" / "unit-12" / "steps" / "step-02.asm"
OUTDIR = HERE / "weave" / "unit-13" / "steps"
OUTDIR.mkdir(parents=True, exist_ok=True)

base = BASE.read_text()

H12 = ("; Shadowkeep — Unit 12: A Warden for Every Room\n"
       "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
       "; step-02 gives every room its own Warden, instantiated from a table on entry.")


def swap(t, old, new):
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:48]!r}"
    return t.replace(old, new)


def inject(t, anchor, addition):
    assert t.count(anchor) == 1, f"anchor not unique ({t.count(anchor)}x): {anchor[:48]!r}"
    return t.replace(anchor, anchor + addition)


LIGHT_ROUTINES = """
; ----------------------------------------------------------------------------
; find_torch — scan the current room's map for 'T', remember where it is (or
; NO_TORCH if the room is unlit).
; ----------------------------------------------------------------------------
find_torch:
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
            ret

; ----------------------------------------------------------------------------
; shade_for_cell — row in B, column in C. Returns a shade 0..4 in A: the
; Chebyshev distance to the torch, halved and clamped. Near the flame = 0
; (lightest); far away = 4 (darkest). No torch = darkest everywhere.
; ----------------------------------------------------------------------------
shade_for_cell:
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
            srl     a               ; distance / 2
            cp      MAX_SHADE + 1
            jr      c, .sf_done
            ld      a, MAX_SHADE
.sf_done:
            ret
.sf_dark:
            ld      a, MAX_SHADE
            ret
"""

SHADE_DATA = """
; The shade ramp: lightest (lit) to darkest (deep shadow), all blue/black dither.
shade_tiles:
            defw    shade0_tile
            defw    shade1_tile
            defw    shade2_tile
            defw    shade3_tile
            defw    shade4_tile

shade0_tile:                        ; lit — nearly all blue
            defb    %00000000
            defb    %00100010
            defb    %00000000
            defb    %00000000
            defb    %00000000
            defb    %10001000
            defb    %00000000
            defb    %00000000
shade1_tile:
            defb    %00100010
            defb    %00000000
            defb    %10001000
            defb    %00000000
            defb    %00100010
            defb    %00000000
            defb    %10001000
            defb    %00000000
shade2_tile:                        ; the half-and-half slate from Unit 2
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
shade3_tile:
            defb    %10101010
            defb    %11111111
            defb    %01010101
            defb    %11111111
            defb    %10101010
            defb    %11111111
            defb    %01010101
            defb    %11111111
shade4_tile:                        ; deep shadow — nearly all black
            defb    %11111111
            defb    %11101110
            defb    %11111111
            defb    %10111011
            defb    %11111111
            defb    %11101110
            defb    %11111111
            defb    %10111011

torch_tile:                         ; a flame in its sconce
            defb    %00010000
            defb    %00111000
            defb    %00111000
            defb    %01111100
            defb    %01111100
            defb    %01111100
            defb    %00111000
            defb    %00010000
"""

# Woven templates (gold, from Unit 9) + a torch at column 15.
HALL_9 = '''room0_template:
            defb    "################################"'''
HALL_13 = '''room0_template:
            defb    "###############T################"'''

GALLERY_LAST = '''            defb    "################################"

; The Vault — a great altar of stone in the middle, south door (column 15)
; down to the Gallery.'''
GALLERY_LAST_13 = '''            defb    "###############T################"

; The Vault — a great altar of stone in the middle, south door (column 15)
; down to the Gallery.'''

VAULT_9 = '''room2_template:
            defb    "################################"'''
VAULT_13 = '''room2_template:
            defb    "###############T################"'''


def build_step01():
    t = base
    t = swap(t, H12,
             "; Shadowkeep — Unit 13: Light and Shadow\n"
             "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
             "; step-01 hangs a torch in each room and shades the floor by distance from the flame.")
    # equates
    t = inject(t, "MARK_ATTR   equ     %00001111",
               "\nTORCH_ATTR  equ     %01001110         ; BRIGHT, blue paper, yellow ink — a lit sconce"
               "\nNO_TORCH    equ     $FF"
               "\nMAX_SHADE   equ     4")
    # lighting routines before draw_room
    t = swap(t, "draw_room:\n", LIGHT_ROUTINES + "\ndraw_room:\n            call    find_torch\n")
    # draw_room: shade the floor cells
    t = swap(t,
             "            ld      hl, (map_ptr)\n"
             "            ld      a, (hl)\n"
             "            call    lookup_tile\n"
             "            call    draw_tile\n"
             "            ld      hl, (map_ptr)\n"
             "            inc     hl\n",
             "            ld      hl, (map_ptr)\n"
             "            ld      a, (hl)\n"
             "            cp      '.'\n"
             "            jr      nz, .not_floor\n"
             "            call    shade_for_cell\n"
             "            add     a, a\n"
             "            ld      e, a\n"
             "            ld      d, 0\n"
             "            ld      hl, shade_tiles\n"
             "            add     hl, de\n"
             "            ld      e, (hl)\n"
             "            inc     hl\n"
             "            ld      d, (hl)\n"
             "            ld      (tile_ptr), de\n"
             "            ld      a, FLOOR_ATTR\n"
             "            ld      (tile_attr), a\n"
             "            call    draw_tile\n"
             "            jr      .cell_done\n"
             ".not_floor:\n"
             "            call    lookup_tile\n"
             "            call    draw_tile\n"
             ".cell_done:\n"
             "            ld      hl, (map_ptr)\n"
             "            inc     hl\n")
    # upgrade draw_floor_cell (plain -> lit) so collected gold repaints shaded
    t = swap(t,
             "draw_floor_cell:\n"
             "            ld      hl, floor_tile\n"
             "            ld      (tile_ptr), hl\n"
             "            ld      a, FLOOR_ATTR\n"
             "            ld      (tile_attr), a\n"
             "            call    draw_tile\n"
             "            ret\n",
             "draw_floor_cell:\n"
             "            call    shade_for_cell\n"
             "            add     a, a\n"
             "            ld      e, a\n"
             "            ld      d, 0\n"
             "            ld      hl, shade_tiles\n"
             "            add     hl, de\n"
             "            ld      e, (hl)\n"
             "            inc     hl\n"
             "            ld      d, (hl)\n"
             "            ld      (tile_ptr), de\n"
             "            ld      a, FLOOR_ATTR\n"
             "            ld      (tile_attr), a\n"
             "            call    draw_tile\n"
             "            ret\n")
    # palette: torch entry
    t = swap(t,
             "            defb    'G'\n"
             "            defw    gold_tile\n"
             "            defb    GOLD_ATTR\n",
             "            defb    'G'\n"
             "            defw    gold_tile\n"
             "            defb    GOLD_ATTR\n"
             "            defb    'T'\n"
             "            defw    torch_tile\n"
             "            defb    TORCH_ATTR\n")
    # shade tiles + torch tile data (after gold_tile)
    t = inject(t,
               "gold_tile:\n"
               "            defb    %00000000\n"
               "            defb    %00111100\n"
               "            defb    %01111110\n"
               "            defb    %01111110\n"
               "            defb    %01111110\n"
               "            defb    %01111110\n"
               "            defb    %00111100\n"
               "            defb    %00000000\n",
               SHADE_DATA)
    # torches into the templates
    t = swap(t, HALL_9, HALL_13)
    t = swap(t, GALLERY_LAST, GALLERY_LAST_13)
    t = swap(t, VAULT_9, VAULT_13)
    # variables: torch position
    t = swap(t,
             "caught:\n"
             "            defb    0\n",
             "caught:\n"
             "            defb    0\n"
             "torch_col:\n"
             "            defb    NO_TORCH\n"
             "torch_row:\n"
             "            defb    NO_TORCH\n")
    return t


step00 = swap(base, H12,
              "; Shadowkeep — Unit 13: Light and Shadow\n"
              "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
              "; step-00 = Unit 12's end: the game entire, but flatly lit — no atmosphere yet.")

step01 = build_step01()

(OUTDIR / "step-00.asm").write_text(step00)
(OUTDIR / "step-01.asm").write_text(step01)
print(f"wrote unit-13 step-00 ({len(step00.splitlines())}), step-01 ({len(step01.splitlines())}) lines")
