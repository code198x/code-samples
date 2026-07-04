#!/usr/bin/env python3
"""Weave — Unit 9: The Keep's Gold (the *want*, and the win half of the loop).

First unit of the woven game core (Sub-arc 1.3). Builds on Unit 8's end (three
explorable rooms, no goal) and adds:

  step-01  gold scattered through the rooms + collect (lift on step-on, a chime,
           a counter). No win yet — you can clear the keep, but nothing happens.
  step-02  the win: the last coin -> THE KEEP STANDS, wrapping the explore loop in
           the tiny game's title -> play -> win -> title state machine (reuse).

Gold sits at its FINAL contested positions (the prototype's coordinates), so the
wardens of Units 10-12 arrive on the gold's ground — the gold never moves, never
taught safe-then-relocated. The collect repaint uses the plain floor tile (no
lighting yet; lighting is Unit 13, and it upgrades this repaint then).

Reuses verbatim from the shipped finale (unit-16): print helpers, show_title
(minus the theme — that's Unit 18), show_win, beep, sfx_pickup, sfx_win, gold_tile,
collect_gold's shape. Anchored injection; asserts fire on drift from the Unit 8 base.

Run from prototype/:  python3 build-unit09.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE.parent / "unit-08" / "steps" / "step-01.asm"
# Staging workspace — the woven code chain lives here until the coordinated swap
# into the live unit-NN/ paths (with MDX + catalogue) keeps the site coherent.
OUTDIR = HERE / "weave" / "unit-09" / "steps"
OUTDIR.mkdir(parents=True, exist_ok=True)

base = BASE.read_text()

H8 = ("; Shadowkeep — Unit 8: Three Rooms\n"
      "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
      "; step-01 adds a third room — Hall, Gallery, Vault — joined into one keep.")


def working():
    return base  # fresh copy of the Unit 8 base each step


def swap(t, old, new):
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:48]!r}"
    return t.replace(old, new)


def inject(t, anchor, addition):
    assert t.count(anchor) == 1, f"anchor not unique ({t.count(anchor)}x): {anchor[:48]!r}"
    return t.replace(anchor, anchor + addition)


# ---------------------------------------------------------------------------
# Room templates with the six coins at their final contested positions.
# ---------------------------------------------------------------------------
HALL_8 = '''room0_template:
            defb    "################################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#........##..........##........#"
            defb    "#........##..........##........#"
            defb    "#..............................#"
            defb    "#..............................."
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#........##..........##........#"
            defb    "#........##..........##........#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "################################"'''

HALL_9 = '''room0_template:
            defb    "################################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.........................G....#"
            defb    "#..............................#"
            defb    "#........##..........##........#"
            defb    "#........##..........##........#"
            defb    "#..............................#"
            defb    "#..............................."
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#........##..........##........#"
            defb    "#........##..........##........#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.........................G....#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "################################"'''

GALLERY_8 = '''room1_template:
            defb    "###############.################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############.################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "...............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "################################"'''

GALLERY_9 = '''room1_template:
            defb    "###############.################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############.################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "........................G......#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.......................G......#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "################################"'''

VAULT_8 = '''room2_template:
            defb    "################################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.............####.............#"
            defb    "#.............####.............#"
            defb    "#.............####.............#"
            defb    "#.............####.............#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############.################"'''

VAULT_9 = '''room2_template:
            defb    "################################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.............####.............#"
            defb    "#.............####.............#"
            defb    "#.............####.............#"
            defb    "#.............####.............#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.........G.........G..........#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############.################"'''


# ---------------------------------------------------------------------------
# Shared code blocks (reused from the shipped finale, adapted for pre-lighting).
# ---------------------------------------------------------------------------
GOLD_CODE = """
; ----------------------------------------------------------------------------
; The gold — the keep's goal. Step onto a coin and it lifts: the map cell turns
; to floor (gone for good), the cell repaints as plain floor (no lighting yet),
; a chime sounds, and the counter ticks down.
; ----------------------------------------------------------------------------
collect_gold:
            call    cell_state_addr  ; HL -> map cell at the thief's position
            ld      a, (hl)
            cp      'G'
            ret     nz
            ld      (hl), '.'        ; the gold is taken — floor from now on
            call    pos_bc           ; B = row, C = col
            call    draw_floor_cell  ; repaint the cell as plain floor
            call    sfx_pickup
            ld      hl, gold_remaining
            dec     (hl)
            ret

; draw_floor_cell — paint the floor tile at (row B, col C). Lighting (Unit 13)
; will replace this with a shade chosen by distance from the nearest torch.
draw_floor_cell:
            ld      hl, floor_tile
            ld      (tile_ptr), hl
            ld      a, FLOOR_ATTR
            ld      (tile_attr), a
            call    draw_tile
            ret

; ----------------------------------------------------------------------------
; beep — the one tone primitive (the tiny game's blip, reused). B = cycles,
; C = the delay between speaker toggles (the pitch; larger C = lower).
; ----------------------------------------------------------------------------
beep:
.bp_cycle:
            ld      a, %00010000
            out     ($FE), a
            ld      e, c
.bp_hi:
            dec     e
            jr      nz, .bp_hi
            xor     a
            out     ($FE), a
            ld      e, c
.bp_lo:
            dec     e
            jr      nz, .bp_lo
            djnz    .bp_cycle
            ret

; sfx_pickup — a bright two-blip chime: the sound of gold.
sfx_pickup:
            ld      b, 8
            ld      c, 20
            call    beep
            ld      b, 8
            ld      c, 14
            call    beep
            ret

gold_tile:
            defb    %00000000
            defb    %00111100
            defb    %01111110
            defb    %01111110
            defb    %01111110
            defb    %01111110
            defb    %00111100
            defb    %00000000
"""

WIN_CODE = """
; ----------------------------------------------------------------------------
; show_title — black screen, the keep's name and a prompt; wait for SPACE (and
; release). Silent for now — the composed theme arrives in Unit 18. Words use the
; ROM's own 8x8 font at $3D00.
; ----------------------------------------------------------------------------
show_title:
            di
            call    clear_screen
            ld      hl, str_title
            ld      b, 8
            ld      c, 11
            call    print_string
            ld      hl, str_prompt
            ld      b, 16
            ld      c, 6
            call    print_string
.tt_wait:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      nz, .tt_wait
.tt_rel:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      z, .tt_rel
            ret

; show_win — the keep is cleared. Black screen, the words, the flourish, then
; wait for SPACE (and release) to return to the title.
show_win:
            di
            call    clear_screen
            ld      hl, str_won
            ld      b, 9
            ld      c, 8
            call    print_string
            ld      hl, str_again
            ld      b, 15
            ld      c, 5
            call    print_string
            call    sfx_win
.sw_wait:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      nz, .sw_wait
.sw_rel:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      z, .sw_rel
            ret

; win — the last coin is gone. Flourish, and raise the flag the loop watches.
win:
            ld      a, 1
            ld      (won), a
            call    sfx_win
            ret

; sfx_win — an ascending flourish: a low note climbing in steps to a high one.
sfx_win:
            ld      c, 60
.swf_loop:
            ld      b, 12
            push    bc
            call    beep
            pop     bc
            ld      a, c
            sub     8
            ld      c, a
            cp      16
            jr      nc, .swf_loop
            ret

; clear_screen — fill bitmap and attributes with zero: a black screen.
clear_screen:
            ld      hl, $4000
            ld      (hl), 0
            ld      de, $4001
            ld      bc, 6911
            ldir
            ret

; print_string — HL -> zero-terminated text, B = row, C = col.
print_string:
.ps_loop:
            ld      a, (hl)
            or      a
            ret     z
            push    hl
            call    print_char
            pop     hl
            inc     hl
            inc     c
            jr      .ps_loop

; print_char — A = character (32..127), B = row, C = col. Copies the ROM font
; glyph at $3D00 + (char-32)*8 to the screen, bright white.
print_char:
            push    bc
            sub     32
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      de, $3D00
            add     hl, de
            push    hl
            call    scr_addr_cr
            pop     de
            ld      b, 8
.pc_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .pc_row
            pop     bc
            call    attr_addr_cr
            ld      (hl), %01000111
            ret

str_title:
            defb    "SHADOWKEEP", 0
str_prompt:
            defb    "PRESS SPACE TO ENTER", 0
str_won:
            defb    "THE KEEP STANDS", 0
str_again:
            defb    "PRESS SPACE TO RETURN", 0
"""

# The state-machine skeleton that replaces Unit 8's bare explore loop (step-02).
START_8 = """start:
            ld      a, 0
            out     ($FE), a

            ld      hl, room0_template
            ld      de, room0_state
            ld      bc, 768
            ldir
            ld      hl, room1_template
            ld      de, room1_state
            ld      bc, 768
            ldir
            ld      hl, room2_template
            ld      de, room2_state
            ld      bc, 768
            ldir

            xor     a
            ld      (current_room), a
            ld      a, START_COL
            ld      (thief_col), a
            ld      a, START_ROW
            ld      (thief_row), a
            ld      a, TOTAL_GOLD
            ld      (gold_remaining), a

            call    draw_room
            call    save_under
            call    draw_thief

            im      1
            ei
.loop:
            halt
            call    player_step
            call    mark_step
            jr      .loop"""

START_9 = """start:
            ld      a, 0
            out     ($FE), a
            im      1

; --- TITLE -> PLAY -> WIN -> TITLE ------------------------------------------
main_title:
            call    show_title       ; returns (interrupts off) when SPACE pressed
            call    new_game         ; reset the keep, place the gold, draw
            ei
.game_loop:
            halt
            ld      a, (won)
            or      a
            jr      nz, .won
            call    player_step
            call    mark_step
            jr      .game_loop
.won:
            call    show_win         ; "THE KEEP STANDS", flourish, wait for SPACE
            jr      main_title       ; round again

; new_game — copy the room templates back into working state (so collected gold
; returns), reset the thief, the gold counter and the win flag, draw the keep.
new_game:
            ld      hl, room0_template
            ld      de, room0_state
            ld      bc, 768
            ldir
            ld      hl, room1_template
            ld      de, room1_state
            ld      bc, 768
            ldir
            ld      hl, room2_template
            ld      de, room2_state
            ld      bc, 768
            ldir

            xor     a
            ld      (current_room), a
            ld      (won), a
            ld      a, TOTAL_GOLD
            ld      (gold_remaining), a
            ld      a, START_COL
            ld      (thief_col), a
            ld      a, START_ROW
            ld      (thief_row), a

            call    draw_room
            call    save_under
            call    draw_thief
            ret"""


def build_step01():
    t = working()
    # header
    t = swap(t, H8,
             "; Shadowkeep — Unit 9: The Keep's Gold\n"
             "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
             "; step-01 scatters gold through the rooms and lets the thief collect it.")
    # equates
    t = inject(t, "THIEF       equ     %01001010",
               "\nGOLD_ATTR   equ     %00000110         ; yellow ink, no BRIGHT -> walkable gold"
               "\nTOTAL_GOLD  equ     6")
    # gold counter init in start
    t = swap(t,
             "            ld      a, START_ROW\n"
             "            ld      (thief_row), a\n"
             "\n"
             "            call    draw_room",
             "            ld      a, START_ROW\n"
             "            ld      (thief_row), a\n"
             "            ld      a, TOTAL_GOLD\n"
             "            ld      (gold_remaining), a\n"
             "\n"
             "            call    draw_room")
    # collect hook in player_step (before save_under)
    t = swap(t,
             "            ld      a, (trow)\n"
             "            ld      (thief_row), a\n"
             "            call    save_under",
             "            ld      a, (trow)\n"
             "            ld      (thief_row), a\n"
             "            call    collect_gold     ; the new cell might be gold — lift it first\n"
             "            call    save_under")
    # palette: add gold
    t = swap(t,
             "            defb    '+'\n"
             "            defw    mark_tile\n"
             "            defb    MARK_ATTR\n",
             "            defb    '+'\n"
             "            defw    mark_tile\n"
             "            defb    MARK_ATTR\n"
             "            defb    'G'\n"
             "            defw    gold_tile\n"
             "            defb    GOLD_ATTR\n")
    # templates
    t = swap(t, HALL_8, HALL_9)
    t = swap(t, GALLERY_8, GALLERY_9)
    t = swap(t, VAULT_8, VAULT_9)
    # routines (after draw_thief's ret, before scr_addr_cr)
    t = inject(t,
               "draw_thief:\n"
               "            call    pos_bc\n"
               "            call    attr_addr_cr\n"
               "            ld      (hl), THIEF\n"
               "            call    pos_bc\n"
               "            call    scr_addr_cr\n"
               "            ld      de, thief\n"
               "            ld      b, 8\n"
               ".thief_row:\n"
               "            ld      a, (de)\n"
               "            ld      (hl), a\n"
               "            inc     de\n"
               "            inc     h\n"
               "            djnz    .thief_row\n"
               "            ret\n",
               GOLD_CODE)
    # variable: gold_remaining
    t = swap(t,
             "under_thief:\n"
             "            defb    0, 0, 0, 0, 0, 0, 0, 0, 0\n",
             "under_thief:\n"
             "            defb    0, 0, 0, 0, 0, 0, 0, 0, 0\n"
             "gold_remaining:\n"
             "            defb    TOTAL_GOLD\n")
    return t


def build_step02(step01):
    t = step01
    # header
    t = swap(t,
             "; Shadowkeep — Unit 9: The Keep's Gold\n"
             "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
             "; step-01 scatters gold through the rooms and lets the thief collect it.",
             "; Shadowkeep — Unit 9: The Keep's Gold\n"
             "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
             "; step-02 makes the last coin win: THE KEEP STANDS, in a title -> play -> win loop.")
    # collect_gold: call win at zero
    t = swap(t,
             "            ld      hl, gold_remaining\n"
             "            dec     (hl)\n"
             "            ret\n",
             "            ld      hl, gold_remaining\n"
             "            dec     (hl)\n"
             "            ld      a, (hl)\n"
             "            or      a\n"
             "            call    z, win           ; the last coin — the keep stands\n"
             "            ret\n")
    # replace the bare explore loop with the state machine
    t = swap(t, START_8, START_9)
    # win / title / screens code (after gold's gold_tile block — anchor on gold_tile's last row)
    t = swap(t,
             "gold_tile:\n"
             "            defb    %00000000\n"
             "            defb    %00111100\n"
             "            defb    %01111110\n"
             "            defb    %01111110\n"
             "            defb    %01111110\n"
             "            defb    %01111110\n"
             "            defb    %00111100\n"
             "            defb    %00000000\n",
             "gold_tile:\n"
             "            defb    %00000000\n"
             "            defb    %00111100\n"
             "            defb    %01111110\n"
             "            defb    %01111110\n"
             "            defb    %01111110\n"
             "            defb    %01111110\n"
             "            defb    %00111100\n"
             "            defb    %00000000\n"
             + WIN_CODE)
    # variable: won
    t = swap(t,
             "gold_remaining:\n"
             "            defb    TOTAL_GOLD\n",
             "gold_remaining:\n"
             "            defb    TOTAL_GOLD\n"
             "won:\n"
             "            defb    0\n")
    return t


# step-00: Unit 8's end, header relabelled to Unit 9.
step00 = swap(working(), H8,
              "; Shadowkeep — Unit 9: The Keep's Gold\n"
              "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
              "; step-00 = Unit 8's end: three rooms you can explore, but nothing to seek.")

step01 = build_step01()
step02 = build_step02(step01)

(OUTDIR / "step-00.asm").write_text(step00)
(OUTDIR / "step-01.asm").write_text(step01)
(OUTDIR / "step-02.asm").write_text(step02)
print(f"wrote unit-09 step-00 ({len(step00.splitlines())}), "
      f"step-01 ({len(step01.splitlines())}), step-02 ({len(step02.splitlines())}) lines")
