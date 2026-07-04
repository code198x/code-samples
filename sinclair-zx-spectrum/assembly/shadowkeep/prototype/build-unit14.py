#!/usr/bin/env python3
"""Weave — Unit 14: Furnishings (decoration that makes a room a place).

Re-homes the shipped furnishings (statue, banners, rubble) onto the lit game.
Objects sit clear of the gold and the warden routes; only Hall row 6 shares a
row (rubble cols 14-16 + the col-26 coin), merged here. Statue and banners are
solid (they read as wall); rubble is walkable broken stone.

Single step, built on Unit 13's end.

Run from prototype/:  python3 build-unit14.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "weave" / "unit-13" / "steps" / "step-01.asm"
OUTDIR = HERE / "weave" / "unit-14" / "steps"
OUTDIR.mkdir(parents=True, exist_ok=True)

base = BASE.read_text()

H13 = ("; Shadowkeep — Unit 13: Light and Shadow\n"
       "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
       "; step-01 hangs a torch in each room and shades the floor by distance from the flame.")


def swap(t, old, new):
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:48]!r}"
    return t.replace(old, new)


def inject(t, anchor, addition):
    assert t.count(anchor) == 1, f"anchor not unique ({t.count(anchor)}x): {anchor[:48]!r}"
    return t.replace(anchor, anchor + addition)


FURNISH_DATA = """
statue_tile:
            defb    %00111100
            defb    %01111110
            defb    %00111100
            defb    %00011000
            defb    %00011000
            defb    %00111100
            defb    %01111110
            defb    %01111110

banner_tile:
            defb    %01111110
            defb    %01111110
            defb    %01011010
            defb    %01011010
            defb    %01111110
            defb    %01111110
            defb    %00111100
            defb    %00011000

rubble_tile:
            defb    %00000000
            defb    %01100000
            defb    %01100000
            defb    %00000110
            defb    %00000110
            defb    %00011000
            defb    %00011000
            defb    %00000000
"""

HALL_13 = '''room0_template:
            defb    "###############T################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.........................G....#"'''
HALL_14 = '''room0_template:
            defb    "###############T################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "B..............S...............B"
            defb    "#.............ooo.........G....#"'''

GALLERY_13 = '''            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.......................G......#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############T################"'''
GALLERY_14 = '''            defb    "B..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#........................ooo...#"
            defb    "#..............................#"
            defb    "#.......................G......#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############T################"'''

VAULT_13 = '''            defb    "#.............####.............#"
            defb    "#.............####.............#"
            defb    "#.............####.............#"
            defb    "#.............####.............#"'''
VAULT_14 = '''            defb    "#.............####.............#"
            defb    "B.............####.............#"
            defb    "#.............####.............B"
            defb    "#.............####.............#"'''


t = swap(base, H13,
         "; Shadowkeep — Unit 14: Furnishings\n"
         "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
         "; step-01 dresses the rooms — a statue, banners, rubble — scenery that makes a place.")
# equates
t = inject(t, "TORCH_ATTR  equ     %01001110         ; BRIGHT, blue paper, yellow ink — a lit sconce",
           "\nSTATUE_ATTR equ     %01001111         ; BRIGHT white on blue — pale stone (solid)"
           "\nBANNER_ATTR equ     %01001011         ; BRIGHT magenta on blue — a hanging (solid)"
           "\nRUBBLE_ATTR equ     %00001000         ; dim, like floor — walkable broken stone")
# palette
t = swap(t,
         "            defb    'T'\n"
         "            defw    torch_tile\n"
         "            defb    TORCH_ATTR\n",
         "            defb    'T'\n"
         "            defw    torch_tile\n"
         "            defb    TORCH_ATTR\n"
         "            defb    'S'\n"
         "            defw    statue_tile\n"
         "            defb    STATUE_ATTR\n"
         "            defb    'B'\n"
         "            defw    banner_tile\n"
         "            defb    BANNER_ATTR\n"
         "            defb    'o'\n"
         "            defw    rubble_tile\n"
         "            defb    RUBBLE_ATTR\n")
# tiles (after torch_tile)
t = inject(t,
           "torch_tile:                         ; a flame in its sconce\n"
           "            defb    %00010000\n"
           "            defb    %00111000\n"
           "            defb    %00111000\n"
           "            defb    %01111100\n"
           "            defb    %01111100\n"
           "            defb    %01111100\n"
           "            defb    %00111000\n"
           "            defb    %00010000\n",
           FURNISH_DATA)
# templates
t = swap(t, HALL_13, HALL_14)
t = swap(t, GALLERY_13, GALLERY_14)
t = swap(t, VAULT_13, VAULT_14)

step00 = swap(base, H13,
              "; Shadowkeep — Unit 14: Furnishings\n"
              "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
              "; step-00 = Unit 13's end: lit rooms, but bare — no decoration yet.")

(OUTDIR / "step-00.asm").write_text(step00)
(OUTDIR / "step-01.asm").write_text(t)
print(f"wrote unit-14 step-00 ({len(step00.splitlines())}), step-01 ({len(t.splitlines())}) lines")
