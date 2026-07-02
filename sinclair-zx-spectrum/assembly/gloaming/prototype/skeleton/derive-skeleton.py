#!/usr/bin/env python3
"""Gloaming route skeleton — derive unit end-states from gloaming-m1.asm.

The module-1 authoring contract (per-unit-plan.md, 2026-07-02): backbone
units are pure subsets of the proven gloaming-m1.asm, derived by
assert-anchored subtraction; detour units (the movement run, 5-8) are
authored forward and must converge on the backbone where they rejoin.

This script IS the subtraction. Every fragment marked M1 is cut from
gloaming-m1.asm by unique anchor (an assert fires if the anchor drifts);
every transform is an exact string replacement that must hit. Authored
(detour/scaffold) text is explicit and listed in AUTHORED below. After
generation, an audit asserts that every emitted line outside the
authored allowlist appears verbatim in gloaming-m1.asm.

unit-20.asm is copied byte-for-byte from gloaming-m1.asm.

Run from this directory:  python3 derive-skeleton.py
"""

from pathlib import Path
import shutil
import sys

HERE = Path(__file__).resolve().parent
M1_PATH = HERE.parent / "gloaming-m1.asm"
M1 = M1_PATH.read_text()


# --------------------------------------------------------------------------
# anchored cutting and transforming
# --------------------------------------------------------------------------

def cut(start: str, end: str) -> str:
    """The m1 text from `start` (inclusive) to `end` (exclusive).
    Both anchors must occur exactly once."""
    assert M1.count(start) == 1, f"start anchor not unique: {start!r}"
    i = M1.index(start)
    assert M1.count(end) == 1, f"end anchor not unique: {end!r}"
    j = M1.index(end)
    assert j > i, f"end before start: {end!r}"
    return M1[i:j].rstrip("\n")


def drop(text: str, gone: str, n: int = 1) -> str:
    """Remove `gone` from `text` exactly `n` times (assert-hit)."""
    assert text.count(gone) == n, f"drop anchor hit {text.count(gone)}x, want {n}: {gone!r}"
    return text.replace(gone, "")


def swap(text: str, old: str, new: str) -> str:
    """Replace `old` with `new` exactly once (assert-hit)."""
    assert text.count(old) == 1, f"swap anchor hit {text.count(old)}x: {old!r}"
    return text.replace(old, new)


DASH = next(l for l in M1.split("\n") if l.startswith("; --"))
EQROW = next(l for l in M1.split("\n") if l.startswith("; =="))


# --------------------------------------------------------------------------
# constants — (first_unit, m1 text) in m1 order; LAMP_GLOW is detour-only
# --------------------------------------------------------------------------

CONSTS = [
    (1, "COBBLE      equ     %00000001"),
    (1, "WALL        equ     %00001111"),
    (3, "LAMP_ATTR   equ     %01000111"),
    (11, "LAMP_UNLIT  equ     %00000101"),
    (12, "LAMP_LIT    equ     %01000110"),
    (2, "WALL_BIT    equ     3"),
    (0, ""),
    (16, "DRAUGHT_ATTR  equ   %01000101"),
    (16, "DRAUGHT_SPEED equ   16              ; frames between the wisp's steps"),
    (16, "DRAUGHT_COL0  equ   28              ; the corner the dark enters from"),
    (16, "DRAUGHT_ROW0  equ   4"),
    (7, "PLAYER_REPEAT equ   6               ; frames between steps while a key is held"),
    (0, ""),
    (13, "PIP_UNLIT   equ     %00101000"),
    (13, "PIP_LIT     equ     %01110000"),
    (13, "PIP_BASE    equ     $5800 + 12"),
    (13, "NUM_LAMPS   equ     8"),
    (0, ""),
    (17, "LIVES       equ     3"),
    (17, "LIFE_PIP    equ     %01010000"),
    (17, "LIFE_BASE   equ     $5800 + 28"),
    (0, ""),
    (15, "MSG_ATTR    equ     %01000111"),
    (15, "MSG_ROW     equ     11"),
    (15, "WIN_COL     equ     7"),
    (17, "LOSE_COL    equ     10"),
    (19, "TITLE_COL   equ     12"),
    (19, "PROMPT_COL  equ     10"),
    (19, "TITLE_ROW   equ     8"),
    (19, "PROMPT_ROW  equ     14"),
    (15, "FONT        equ     $3C00"),
    (0, ""),
    (18, "SPEAKER     equ     %00010000"),
    (0, ""),
    (19, "STATE_TITLE equ     0"),
    (15, "STATE_PLAY  equ     1"),
    (15, "STATE_WIN   equ     2               ; the night is held — the game is won"),
    (17, "STATE_LOSE  equ     3"),
    (0, ""),
    (3, "START_COL   equ     15"),
    (3, "START_ROW   equ     11"),
    (16, "GATHER      equ     120             ; frames the dark gathers before its first step"),
    (0, ""),
    (5, "KEYS_OP     equ     $DFFE"),
    (5, "KEYS_Q      equ     $FBFE"),
    (5, "KEYS_A      equ     $FDFE"),
    (19, "KEYS_SPACE  equ     $7FFE"),
]

# the detour glow colour (unit 5 only) — inserted after LAMP_ATTR
GLOW_CONST = "LAMP_GLOW   equ     %01000110       ; the glow while a key is down (detour)"


def consts_for(u: int) -> str:
    lines, group_open = [], False
    for first, text in CONSTS:
        if first == 0:
            if group_open:
                lines.append("")
                group_open = False
            continue
        if first <= u < 20:
            lines.append(text)
            group_open = True
            if u == 5 and text.startswith("LAMP_ATTR"):
                lines.append(GLOW_CONST)
    while lines and lines[-1] == "":
        lines.pop()
    return "\n".join(lines)


# --------------------------------------------------------------------------
# the inline setup (units 1-18); unit 19 wraps it into m1's init_game
# --------------------------------------------------------------------------

RESETS = [
    (13, "            xor     a\n            ld      (lit_count), a"),
    (17, "            ld      a, LIVES\n            ld      (lives), a"),
    (3, "            ld      a, START_COL\n            ld      (lamp_col), a\n"
        "            ld      a, START_ROW\n            ld      (lamp_row), a"),
    (16, "            ld      a, DRAUGHT_COL0\n            ld      (draught_col), a\n"
         "            ld      a, DRAUGHT_ROW0\n            ld      (draught_row), a\n"
         "            ; the dark gathers before its first step — a beat to read\n"
         "            ; the square before the hunt begins\n"
         "            ld      a, GATHER\n            ld      (draught_timer), a"),
    (7, "            xor     a\n            ld      (player_timer), a"),
]

DRAWS = [
    (1, "            call    clear_bitmap"),
    (2, "            call    fill_ground"),
    (1, "            ld      hl, $5800\n            ld      de, $5801\n"
        "            ld      (hl), COBBLE\n            ld      bc, 767\n"
        "            ldir"),
    (14, "            call    warm_walls"),   # paint_walls before unit 14
    (9, "            call    paint_buildings"),
    (2, "            call    fill_walls"),
    (13, "            call    draw_pips"),
    (17, "            call    draw_lives"),
    (11, "            call    draw_lamps"),
    (8, "            call    save_under"),
    (3, "            call    draw_lamp"),
    (16, "            call    save_draught\n            call    draw_draught"),
]

PAINT_WALLS_CALL = "            call    paint_walls"

SETUP_BANNER = EQROW + "\n; SETUP.\n" + EQROW


def setup_for(u: int) -> str:
    """The start block for units 1-18 (inline init; no title yet)."""
    parts = [SETUP_BANNER, "start:",
             "            ld      a, 0\n            out     ($FE), a"]
    resets = [t for first, t in RESETS if first <= u]
    parts += resets
    if resets:
        parts.append("")
    for first, text in DRAWS:
        if text.endswith("warm_walls") and u < 14:
            if u >= 1:
                parts.append(PAINT_WALLS_CALL)
            continue
        if first <= u:
            parts.append(text)
    if u >= 15:
        parts.append("            ld      a, STATE_PLAY\n"
                     "            ld      (game_state), a")
    if u >= 4:
        parts.append("            im      1\n            ei")
        parts.append("")
        parts.append(main_loop_for(u))
    else:
        parts.append("")
        parts.append("forever:\n            jr      forever")
    out, prev_blank = [], False
    for p in parts:
        if p == "":
            if prev_blank:
                continue
            prev_blank = True
        else:
            prev_blank = False
        out.append(p)
    return "\n".join(out)


def main_loop_for(u: int) -> str:
    if u < 15:
        return ("main_loop:\n            halt\n"
                "            call    play_step\n"
                "            jr      main_loop")
    return ("main_loop:\n            halt\n"
            "            ld      a, (game_state)\n"
            "            cp      STATE_PLAY\n"
            "            jr      z, .do_play\n"
            "            jr      main_loop           ; WIN or LOSE — the screen holds\n"
            ".do_play:\n"
            "            call    play_step\n"
            "            jr      main_loop")


# --------------------------------------------------------------------------
# unit 19: m1's own start / main_loop / title_step / init_game, transformed
# --------------------------------------------------------------------------

START19 = swap(
    cut(EQROW + "\n; SETUP.", "\nmain_loop:"),
    "call    draw_title_screen   ; no startup lock — nothing to debounce yet",
    "call    draw_title_screen")

ML19 = drop(
    cut("main_loop:", "\n" + DASH + "\n; title_step"),
    "            call    end_step            ; WIN or LOSE — wait for a key, then title\n")

TITLE_STEP19 = (
    DASH + "\n; title_step — SPACE starts a fresh game.\n" + DASH + "\n" +
    swap(cut("title_step:", "\n\n" + DASH + "\n; end_step"),
         "title_step:\n"
         "            ld      a, (input_lock)\n"
         "            or      a\n"
         "            jr      z, .tready\n"
         "            dec     a\n"
         "            ld      (input_lock), a\n"
         "            ret\n"
         ".tready:",
         "title_step:"))

INIT19 = cut("init_game:", "\nwarm_walls:")


# --------------------------------------------------------------------------
# play_step (the orchestrator) — era variants by subtraction from m1's
# --------------------------------------------------------------------------

PS_M1 = cut("play_step:", "\ninit_game:")

PS19 = drop(drop(
    PS_M1,
    "            ; the night is held — the lives you kept are the score\n"
    "            ld      a, (lives)\n"
    "            ld      hl, best_lives\n"
    "            cp      (hl)\n"
    "            jr      c, .nobest\n"
    "            ld      (hl), a\n"
    ".nobest:\n"),
    "            ld      a, LOCK\n            ld      (input_lock), a\n")
PS18 = PS19
PS17 = drop(PS18, "            call    fanfare_held\n")
PS16 = drop(PS17,
            "            ld      a, (game_state)\n"
            "            cp      STATE_PLAY\n"
            "            ret     nz\n", n=2)
PS15 = drop(PS16, "            call    draught_step\n")
PS_WRAP = "play_step:\n            call    player_step\n            ret"
PS_STUB = "play_step:\n            ret"


def play_step_for(u: int) -> str:
    if u == 4:
        return PS_STUB
    if u <= 14:
        return PS_WRAP
    return {15: PS15, 16: PS16, 17: PS17, 18: PS18, 19: PS19}[u]


# --------------------------------------------------------------------------
# player_step — sliced from m1's, plus the authored detour forms
# --------------------------------------------------------------------------

PSTEP_M1 = cut(DASH + "\n; player_step.", "\n\n" + DASH + "\n; fill_ground")

_gate_i = PSTEP_M1.index("            ; The held-key gate")
_decode_i = PSTEP_M1.index("            ld      bc, KEYS_OP\n"
                           "            in      a, (c)\n"
                           "            bit     1, a")
_pmove_i = PSTEP_M1.index(".pmove:")
_draught_i = PSTEP_M1.index("            ld      a, (tcol)\n"
                            "            ld      hl, draught_col")
_pcommit_i = PSTEP_M1.index(".pcommit:")

P_TOP = PSTEP_M1[:_gate_i]                       # banner, label, tcol/trow
P_GATE = PSTEP_M1[_gate_i:_decode_i]             # scan + repeat gate
P_DECODE = PSTEP_M1[_decode_i:_pmove_i]          # direction bit-tests
P_WALLCHK = PSTEP_M1[_pmove_i:_draught_i]        # .pmove: + wall_at test
P_DRAUGHT17 = PSTEP_M1[_draught_i:_pcommit_i]    # contact costs a life
P_COMMIT18 = PSTEP_M1[_pcommit_i:]               # .pcommit: through ret

P_DRAUGHT16 = swap(P_DRAUGHT17,
                   "            call    lose_life\n            ret",
                   "            ret                     ; the wisp holds its ground — you cannot pass")

C14 = drop(P_COMMIT18, "            call    blip_lit\n")
C13 = drop(C14, "            call    warm_walls\n")
C12 = drop(C13, "            call    light_pip\n")
C11 = drop(drop(C12,
                "            ld      a, (under_lamp + 8)\n"
                "            cp      LAMP_UNLIT\n"
                "            jr      nz, .pdrawn\n"
                "            ld      a, LAMP_LIT\n"
                "            ld      (under_lamp + 8), a\n"),
           ".pdrawn:\n")
C8 = drop(C11, ".pcommit:\n")
C6 = drop(swap(C8, "            call    restore_under",
               "            call    erase_lamp"),
          "            call    save_under\n")


def _nolabel(c: str) -> str:
    return drop(c, ".pcommit:\n")


CLAMP = (
    "            ; Scaffold (route skeleton): a numeric edge clamp so the detour\n"
    "            ; cannot walk the lamplighter off the map — the walls take this\n"
    "            ; job in unit 9, and the clamp is retired in unit 10.\n"
    "            ld      a, (trow)\n"
    "            cp      2\n"
    "            ret     c\n"
    "            cp      23\n"
    "            ret     nc\n"
    "            ld      a, (tcol)\n"
    "            cp      1\n"
    "            ret     c\n"
    "            cp      31\n"
    "            ret     nc\n")

PSTEP_BANNER = DASH + "\n; player_step.\n" + DASH + "\n"

PSTEP5 = PSTEP_BANNER + """player_step:
            ld      bc, KEYS_OP
            in      a, (c)
            bit     1, a
            jr      z, .held
            bit     0, a
            jr      z, .held
            ld      bc, KEYS_Q
            in      a, (c)
            bit     0, a
            jr      z, .held
            ld      bc, KEYS_A
            in      a, (c)
            bit     0, a
            jr      z, .held
            call    pos_bc
            call    attr_addr_cr
            ld      (hl), LAMP_ATTR
            ret
.held:
            call    pos_bc
            call    attr_addr_cr
            ld      (hl), LAMP_GLOW
            ret"""


def player_step_for(u: int) -> str:
    if u == 5:
        return PSTEP5
    if u == 6:
        return P_TOP + P_DECODE + ".pmove:\n" + CLAMP + C6
    if u == 7:
        return P_TOP + P_GATE + P_DECODE + ".pmove:\n" + CLAMP + C6
    if u == 8:
        return P_TOP + P_GATE + P_DECODE + ".pmove:\n" + CLAMP + C8
    if u == 9:
        return P_TOP + P_GATE + P_DECODE + P_WALLCHK + CLAMP + "\n" + C8
    if u in (10, 11):
        return P_TOP + P_GATE + P_DECODE + P_WALLCHK + C8
    if u == 12:
        return P_TOP + P_GATE + P_DECODE + P_WALLCHK + _nolabel(C12)
    if u == 13:
        return P_TOP + P_GATE + P_DECODE + P_WALLCHK + _nolabel(C13)
    if u in (14, 15):
        return P_TOP + P_GATE + P_DECODE + P_WALLCHK + _nolabel(C14)
    if u == 16:
        return P_TOP + P_GATE + P_DECODE + P_WALLCHK + P_DRAUGHT16 + C14
    if u == 17:
        return P_TOP + P_GATE + P_DECODE + P_WALLCHK + P_DRAUGHT17 + C14
    return PSTEP_M1


ERASE_LAMP = """; erase_lamp — the naive erase: blank the cell the lamplighter leaves.
; (Detour: watch what it does to the cobbles.)
erase_lamp:
            call    pos_bc
            call    scr_addr_cr
            ld      b, 8
            xor     a
.el:
            ld      (hl), a
            inc     h
            djnz    .el
            call    pos_bc
            call    attr_addr_cr
            ld      (hl), COBBLE
            ret"""


# --------------------------------------------------------------------------
# the remaining m1 fragments
# --------------------------------------------------------------------------

WARM_M1 = cut("warm_walls:", "\nbeep:")

PAINT_WALLS = swap(swap(WARM_M1, "warm_walls:", "paint_walls:"),
                   "            ld      a, (lit_count)\n"
                   "            ld      e, a\n"
                   "            ld      d, 0\n"
                   "            ld      hl, wall_ramp\n"
                   "            add     hl, de\n"
                   "            ld      c, (hl)",
                   "            ld      c, WALL")

AUDIO_TO_CHIME = cut("\nbeep:", "\nchime_dusk:").lstrip("\n")
CHIME = cut("\nchime_dusk:", "\nrest:").lstrip("\n")
AUDIO_REST_ON = cut("\nrest:", "\n\n" + DASH + "\n; Screens.").lstrip("\n")

SCREENS_BANNER_M1 = cut(DASH + "\n; Screens. Win and lose now invite another go.", "\ndraw_title_screen:")
SCREENS_BANNER_PRE20 = DASH + "\n; Screens.\n" + DASH

TITLE_SCREEN19 = drop(
    cut("draw_title_screen:", "\ndraw_win_screen:"),
    "            ; your best night — the lives you kept on your finest win,\n"
    "            ; read in lamps (no digits). It survives the loop back to\n"
    "            ; the title: the go-again hook.\n"
    "            ld      hl, $5800 + 11 * 32 + 14\n"
    "            ld      b, LIVES\n"
    "            ld      a, (best_lives)\n"
    "            ld      c, a\n"
    ".tpip:\n"
    "            ld      a, PIP_UNLIT\n"
    "            inc     c\n"
    "            dec     c\n"
    "            jr      z, .tpcold\n"
    "            ld      a, PIP_LIT\n"
    "            dec     c\n"
    ".tpcold:\n"
    "            ld      (hl), a\n"
    "            inc     hl\n"
    "            djnz    .tpip\n")

WIN_SCREEN = drop(
    cut("draw_win_screen:", "\ndraw_lose_screen:"),
    "            ld      hl, prompt_text\n"
    "            ld      b, CONT_ROW\n"
    "            ld      c, PROMPT_COL\n"
    "            call    print_string\n")

LOSE_SCREEN = drop(
    cut("draw_lose_screen:", "\nclear_bitmap:"),
    "            ld      hl, prompt_text\n"
    "            ld      b, CONT_ROW\n"
    "            ld      c, PROMPT_COL\n"
    "            call    print_string\n")

CLEAR_BITMAP = cut("clear_bitmap:", "\n\n" + DASH + "\n; player_step.")

TEX_M1 = cut(DASH + "\n; fill_ground", "\ndraught_step:")
TEX_PRE14 = swap(TEX_M1,
                 " Driven by\n"
                 "; the wall attribute bit, so any future interior buildings get their\n"
                 "; brick for free. Runs at init while the ramp's blue holds the bit.",
                 " Driven by\n"
                 "; the wall attribute bit, so any future interior buildings get their\n"
                 "; brick for free.")

DRAUGHT_STEP17 = cut("draught_step:", "\npaint_buildings:")
DRAUGHT_STEP16 = swap(DRAUGHT_STEP17,
                      "            call    lose_life\n            ret",
                      "            ret                     ; the wisp is at your side — its touch has no price yet")

BUILDINGS = cut("paint_buildings:", "\n\nlose_life:")

LOSE_LIFE19 = drop(
    cut("lose_life:", "\n\n" + DASH + "\n; print_string"),
    "            ld      a, LOCK\n            ld      (input_lock), a\n")
LOSE_LIFE17 = drop(LOSE_LIFE19, "            call    sting_nightfall\n")

PRINT_BLOCK = cut(DASH + "\n; print_string / print_char.", "\n\n" + DASH + "\n; light_pip")

LIGHT_PIP = cut("\nlight_pip:", "\ndraw_pips:").lstrip("\n")
DRAW_PIPS = cut("draw_pips:", "\ndraw_lives:")
DRAW_LIVES = cut("draw_lives:", "\n\n" + DASH + "\n; draw_lamps")

PIPS_BANNER13 = DASH + "\n; light_pip / draw_pips.\n" + DASH
PIPS_BANNER17 = DASH + "\n; light_pip / draw_pips / draw_lives.\n" + DASH

LAMPS_BLOCK = cut(DASH + "\n; draw_lamps / draw_lantern.", "\n\n" + DASH + "\n; scr_addr_cr")

ADDR_BANNER_M1 = DASH + "\n; scr_addr_cr / attr_addr_cr / wall_at.\n" + DASH
ADDR_BANNER_PRE9 = DASH + "\n; scr_addr_cr / attr_addr_cr.\n" + DASH
SCR_ADDR = cut("scr_addr_cr:", "\nattr_addr_cr:")
ATTR_ADDR = cut("attr_addr_cr:", "\nwall_at:")
WALL_AT = cut("wall_at:", "\n\n" + DASH + "\n; The lamplighter's")

PLAYER_SR_M1 = cut(DASH + "\n; The lamplighter's save / restore / draw.",
                   "\n\n" + DASH + "\n; The draught's")
POS_BC = cut("\npos_bc:", "\nsave_under:").lstrip("\n")
DRAW_LAMP = cut("draw_lamp:", "\n\n" + DASH + "\n; The draught's")
PLAYER_DRAW_BANNER = DASH + "\n; The lamplighter's draw.\n" + DASH

DRAUGHT_SR = cut(DASH + "\n; The draught's save / restore / draw.",
                 "\n\n" + DASH + "\n; Data.")

DATA_BANNER = DASH + "\n; Data.\n" + DASH

DATA_VARS = [
    (15, "game_state:\n            defb    STATE_PLAY"),   # STATE_TITLE from 19
    (14, cut("wall_ramp:", "\nlamp_data:")),
    (11, cut("lamp_data:", "\nlamp_col:")),
    (3, cut("\nlamp_col:", "\ntcol:").lstrip("\n")),
    (6, cut("\ntcol:", "\nlit_count:").lstrip("\n")),
    (13, "lit_count:\n            defb    0"),
    (17, "lives:\n            defb    LIVES"),
    (16, cut("draught_col:", "\nplayer_timer:")),
    (7, cut("player_timer:", "\nseek_col:")),
    (16, cut("seek_col:", "\n\nunder_lamp:")),
    (0, ""),
    (8, "under_lamp:\n            defb    0, 0, 0, 0, 0, 0, 0, 0, 0"),
    (16, "under_draught:\n            defb    0, 0, 0, 0, 0, 0, 0, 0, 0"),
    (0, ""),
    (3, cut("\nlamplighter:", "\nlantern:").lstrip("\n")),
    (11, cut("\nlantern:", "\ndraught_glyph:").lstrip("\n")),
    (16, cut("draught_glyph:", "\ntitle_text:")),
    (0, ""),
    (19, cut("title_text:", "\nwin_text:")),
    (15, cut("win_text:", "\nlose_text:")),
    (17, cut("lose_text:", "\n\n            end     start")),
]


def data_for(u: int) -> str:
    parts, pending_gap = [], False
    for first, text in DATA_VARS:
        if first == 0:
            pending_gap = bool(parts)
            continue
        if first <= u:
            body = text
            if u >= 19 and body.startswith("game_state:"):
                body = "game_state:\n            defb    STATE_TITLE"
            if pending_gap:
                parts.append("")
                pending_gap = False
            parts.append(body)
    return "\n".join(parts)


# --------------------------------------------------------------------------
# headers (the route map carries the full narration; these are captions)
# --------------------------------------------------------------------------

HEADERS = {
    1: ("The Empty Square",
        "The screen is the map: one attribute write per cell makes a square at dusk.",
        "subset"),
    2: ("The Cobbles and the Brick",
        "The canvas: bitmap texture under the attributes — cobbles and brickwork.",
        "subset"),
    3: ("The Lamplighter",
        "A glyph drawn from a bitmap definition, standing in the square.",
        "subset"),
    4: ("The Heartbeat",
        "The structured loop, locked to the frame: HALT; update; repeat.",
        "subset"),
    5: ("Reading the Keys",
        "Scan a half-row; a zero bit is a pressed key — the lamplighter glows to prove it.",
        "detour"),
    6: ("One Step",
        "Erase the old cell, draw the new — and the floor pays for the erase.",
        "detour"),
    7: ("Taming the Key",
        "The repeat gate: one press is one step, a held key is a stride, not a blur.",
        "detour"),
    8: ("Save and Restore",
        "The under-buffer: the ground survives your passage.",
        "detour"),
    9: ("Walls",
        "Collision is a bit-test on the attribute; buildings are rectangle data.",
        "subset+scaffold"),
    10: ("Edges",
         "The square itself is the boundary — the scaffold clamp comes out.",
         "subset"),
    11: ("The Lamps",
         "Eight unlit lanterns as cells, surviving your passage like any ground.",
         "subset"),
    12: ("Light It",
         "Stepping onto state changes it: the saved-under byte is the rule.",
         "subset"),
    13: ("The Tally",
         "Progress as coloured pips — no digits.",
         "subset"),
    14: ("The Square Warms",
         "Progress as atmosphere: a data table indexed by lit_count.",
         "subset"),
    15: ("The Night Is Held",
         "All lamps lit is the win — the game gains states and an ending.",
         "subset"),
    16: ("The Draught",
         "One rule reads as intent: step toward the player; the wisp ghosts through stone.",
         "subset"),
    17: ("Lives, and the Fall of Night",
         "Contact costs a life; out of lives, night falls. The taking costs the night its reach.",
         "subset"),
    18: ("A Small Sound",
         "The beeper: a rising blip when a lamp catches; each ending finds its phrase.",
         "subset"),
    19: ("The Title",
         "Sparse and suggestive; press a key to begin — setup becomes the title's job.",
         "subset"),
}

METHODS = {
    "subset": "subset of gloaming-m1.asm, derived by reverse subtraction",
    "subset+scaffold": "subset of gloaming-m1.asm plus the detour's scaffold clamp",
    "detour": "detour, authored forward; converges on the backbone at unit 10",
}


def header_for(u: int) -> str:
    title, idea, method = HEADERS[u]
    return (f"; Gloaming — route skeleton, unit {u:02d}: {title}\n"
            f"; {idea}\n"
            f"; Method: {METHODS[method]}.")


# --------------------------------------------------------------------------
# unit assembly
# --------------------------------------------------------------------------

def unit_text(u: int, pulse: bool = False) -> str:
    parts = [header_for(u), "            org     32768", consts_for(u)]

    parts.append(setup_for(u))

    if u >= 19:
        # m1's own start / dispatch / title_step / init_game
        parts = [header_for(u), "            org     32768", consts_for(u),
                 START19, ML19, TITLE_STEP19]

    if u >= 4:
        if pulse:
            parts.append("play_step:\n"
                         "            ; Try This: make the heartbeat visible — one attribute cell\n"
                         "            ; counts the frames. Take the probe out once you have seen\n"
                         "            ; the loop beat.\n"
                         "            ld      hl, $5800 + 31\n"
                         "            inc     (hl)\n"
                         "            ret")
        else:
            parts.append(play_step_for(u))

    if u >= 19:
        parts.append(INIT19)

    parts.append(WARM_M1 if u >= 14 else PAINT_WALLS)

    if u >= 18:
        parts.append(AUDIO_TO_CHIME)
        if u >= 19:
            parts.append(CHIME)
        parts.append(AUDIO_REST_ON)

    if u >= 15:
        parts.append(SCREENS_BANNER_PRE20)
        if u >= 19:
            parts.append(TITLE_SCREEN19)
        parts.append(WIN_SCREEN)
        if u >= 17:
            parts.append(LOSE_SCREEN)
    parts.append(CLEAR_BITMAP)

    if u >= 5:
        parts.append(player_step_for(u) if u != 4 else "")

    if u >= 2:
        parts.append(TEX_M1 if u >= 14 else TEX_PRE14)

    if u >= 16:
        parts.append(DRAUGHT_STEP17 if u >= 17 else DRAUGHT_STEP16)
    if u >= 9:
        parts.append(BUILDINGS)
    if u >= 17:
        parts.append(LOSE_LIFE19 if u >= 18 else LOSE_LIFE17)
    if u >= 15:
        parts.append(PRINT_BLOCK)
    if u >= 13:
        parts.append(PIPS_BANNER17 if u >= 17 else PIPS_BANNER13)
        parts.append(LIGHT_PIP)
        parts.append(DRAW_PIPS)
        if u >= 17:
            parts.append(DRAW_LIVES)
    if u >= 11:
        parts.append(LAMPS_BLOCK)
    if u >= 2:
        parts.append(ADDR_BANNER_M1 if u >= 9 else ADDR_BANNER_PRE9)
        parts.append(SCR_ADDR)
        parts.append(ATTR_ADDR)
        if u >= 9:
            parts.append(WALL_AT)
    if u >= 8:
        parts.append(PLAYER_SR_M1)
    elif u >= 3:
        parts.append(PLAYER_DRAW_BANNER)
        parts.append(POS_BC)
        if u in (6, 7):
            parts.append(ERASE_LAMP)
        parts.append(DRAW_LAMP)
    if u >= 16:
        parts.append(DRAUGHT_SR)

    if u >= 3:
        parts.append(DATA_BANNER)
        parts.append(data_for(u))

    parts.append("            end     start")

    body = "\n\n".join(p for p in parts if p) + "\n"
    return body


# duplicate-slot fix: player_step is appended once (guard against the
# double-append path in unit_text for units >= 5)
def build_unit(u: int, pulse: bool = False) -> str:
    return unit_text(u, pulse=pulse)


# --------------------------------------------------------------------------
# the audit: every non-authored emitted line must be verbatim m1
# --------------------------------------------------------------------------

AUTHORED = set()
for frag in [GLOW_CONST, PAINT_WALLS_CALL, CLAMP, ERASE_LAMP, PSTEP5,
             SETUP_BANNER, SCREENS_BANNER_PRE20, ADDR_BANNER_PRE9,
             PIPS_BANNER13, PIPS_BANNER17, PLAYER_DRAW_BANNER,
             "forever:\n            jr      forever",
             "play_step:\n            ret",
             "play_step:\n            call    player_step\n            ret",
             "            jr      main_loop           ; WIN or LOSE — the screen holds",
             "game_state:\n            defb    STATE_PLAY",
             "            ret                     ; the wisp holds its ground — you cannot pass",
             "            ret                     ; the wisp is at your side — its touch has no price yet",
             "            call    erase_lamp",
             "            call    paint_walls",
             "paint_walls:",
             "            ld      c, WALL",
             "; title_step — SPACE starts a fresh game.",
             "; fill_ground — the cobble stipple (brief §6). Not decoration: the",
             "; brick for free.",
             "            call    draw_title_screen",
             "            ; Try This: make the heartbeat visible — one attribute cell\n"
             "            ; counts the frames. Take the probe out once you have seen\n"
             "            ; the loop beat.\n"
             "            ld      hl, $5800 + 31\n"
             "            inc     (hl)"]:
    for line in frag.split("\n"):
        AUTHORED.add(line.rstrip())

M1_LINES = {line.rstrip() for line in M1.split("\n")}


def audit(u: int, text: str) -> list[str]:
    bad = []
    for line in text.split("\n"):
        s = line.rstrip()
        if not s:
            continue
        if s.startswith("; Gloaming — route skeleton") or s.startswith("; Method:"):
            continue
        if s in M1_LINES or s in AUTHORED:
            continue
        bad.append(s)
    return bad


for _title, _idea, _method in HEADERS.values():
    AUTHORED.add(f"; {_idea}")
AUTHORED.add("; Gloaming — route skeleton, unit 04 (Try This variant): The Heartbeat, made visible")


# --------------------------------------------------------------------------
# main
# --------------------------------------------------------------------------

def main() -> int:
    failures = 0
    for u in range(1, 20):
        text = build_unit(u)
        bad = audit(u, text)
        if bad:
            failures += 1
            print(f"unit-{u:02d}: {len(bad)} unanchored line(s):")
            for b in bad[:8]:
                print(f"    {b!r}")
        (HERE / f"unit-{u:02d}.asm").write_text(text)
        print(f"unit-{u:02d}.asm written ({len(text.splitlines())} lines)")
    pulse = swap(build_unit(4, pulse=True),
                 "; Gloaming — route skeleton, unit 04: The Heartbeat",
                 "; Gloaming — route skeleton, unit 04 (Try This variant): "
                 "The Heartbeat, made visible")
    (HERE / "unit-04-pulse.asm").write_text(pulse)
    print(f"unit-04-pulse.asm written ({len(pulse.splitlines())} lines)")
    shutil.copyfile(M1_PATH, HERE / "unit-20.asm")
    assert (HERE / "unit-20.asm").read_bytes() == M1_PATH.read_bytes()
    print("unit-20.asm copied byte-for-byte from gloaming-m1.asm")
    if failures:
        print(f"AUDIT FAILED for {failures} unit(s)")
        return 1
    print("audit clean: every non-authored line is verbatim gloaming-m1.asm")
    return 0


if __name__ == "__main__":
    sys.exit(main())
