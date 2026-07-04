#!/usr/bin/env python3
"""Shadowkeep — the Warden jeopardy, closed design (design-stress 2026-07-04).

The minimal one-room prototype (build-warden.py) *proved jeopardy is possible*
but was not yet a game: the threat was quarantined away from the objective (B1),
thin (B2), the door was a free escape (B3), and you could die on entry (B4). This
build closes those holes so the design can be decompose-verified before any unit
is cut:

  * A Warden in EVERY room, instantiated from a per-room table (start cell, dir,
    axis) — the same data-driven shape the torches and gold already use. One
    mechanic replicated from data, not new technique. (Closes B1 density + B2.)
  * Gold on CONTESTED ground — every coin sits on its room's Warden route, so
    reaching a coin means reading and timing the patrol. The Warden stands
    between the thief and the objective, not off to one side. (Closes B1.)
  * The Warden guards the GOLD, not the door — fleeing a room costs you its
    coins. (Closes B3.)
  * Per-room entry: the Warden resets to a route-start clear of the entry cell
    and gathers WARDEN_GATHER frames before it moves. You never materialise onto
    it; the first beat of every room is readable. (Closes B4.)
  * One hit -> title (B5, decided (c)): the freeze is binary, and you are alone.

Plus the two A/V-bar fixes the pre-decompose assessment surfaced:
  * a spectral hooded-sentinel glyph (was a placeholder blob), and
  * a caught-sting that plunges then locks (was a plain descending sweep) — the
    emotional beat of the whole mechanic.

Wardens are deterministic patrollers (Sabre Wulf's roaming beasts, NOT Gloaming's
hunting draught): each walks a fixed route, reversing at walls, and you learn and
time it. No combat — contact is stasis. Same two-mover engine shape as the thief
(save / restore / draw + a private buffer). Injections are anchored; an assert
fires on drift from the shipped base.

Run from this directory:  python3 build-warden-closed.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
SRC = HERE.parent / "unit-16" / "steps" / "step-01.asm"
OUT = HERE / "shadowkeep-warden-closed.asm"

t = SRC.read_text()


def inject(anchor: str, addition: str, *, after: bool = True) -> None:
    global t
    assert t.count(anchor) == 1, f"anchor not unique ({t.count(anchor)}x): {anchor[:50]!r}"
    t = t.replace(anchor, anchor + addition if after else addition + anchor)


def swap(old: str, new: str) -> None:
    global t
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:50]!r}"
    t = t.replace(old, new)


# --- header ---
swap("; Shadowkeep — Unit 16: The Keep Stands\n"
     "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
     "; step-01 wraps it in a state machine: title -> play -> win -> title, a finishable, replayable game.",
     "; Shadowkeep — the Warden jeopardy, CLOSED design (a-game-needs-jeopardy.md, 2026-07-04)\n"
     "; The Place, made a game: a Warden haunts every room, standing on the gold's ground.\n"
     "; Read the patrol, take the gap. Touched, you join the sleepers - THE KEEP SLEEPS.\n"
     "; Built from unit-16 step-01; closes design-stress B1-B4 before the unit decompose.")

# --- equates ---
inject("THIEF       equ     %01001010",
       "\nWARDEN        equ   %01000101       ; BRIGHT cyan on black - the freezer, spectral"
       "\nWARDEN_SPEED  equ   10              ; frames between the Warden's patrol steps"
       "\nWARDEN_GATHER equ   50              ; a beat on room entry - read it before it moves"
       "\nAXIS_HORIZ    equ   0               ; the Warden varies its column (walks a row)"
       "\nAXIS_VERT     equ   1               ; the Warden varies its row (walks a column)")

# --- main loop: the Warden patrols every room; catching the thief loses ---
swap(".game_loop:\n"
     "            halt\n"
     "            ld      a, (won)\n"
     "            or      a\n"
     "            jr      nz, .won\n"
     "            call    player_step\n"
     "            call    mark_step\n"
     "            jr      .game_loop\n"
     ".won:\n"
     "            call    show_win         ; \"THE KEEP STANDS\", flourish, wait for SPACE\n"
     "            jr      main_title       ; round again",
     ".game_loop:\n"
     "            halt\n"
     "            ld      a, (won)\n"
     "            or      a\n"
     "            jr      nz, .won\n"
     "            call    player_step\n"
     "            ld      a, (won)         ; the winning coin ends it before the Warden acts\n"
     "            or      a\n"
     "            jr      nz, .won\n"
     "            call    check_caught     ; the thief may have stepped into the Warden\n"
     "            ld      a, (caught)\n"
     "            or      a\n"
     "            jr      nz, .lost\n"
     "            call    warden_step      ; the Warden steps; it may land on the thief\n"
     "            ld      a, (caught)\n"
     "            or      a\n"
     "            jr      nz, .lost\n"
     "            call    mark_step\n"
     "            jr      .game_loop\n"
     ".lost:\n"
     "            call    show_lose        ; \"THE KEEP SLEEPS\", the sting, wait for SPACE\n"
     "            jr      main_title\n"
     ".won:\n"
     "            call    show_win         ; \"THE KEEP STANDS\", flourish, wait for SPACE\n"
     "            jr      main_title       ; round again")

# --- new_game: clear the caught flag alongside the other resets ---
swap("            xor     a\n"
     "            ld      (current_room), a\n"
     "            ld      (won), a\n",
     "            xor     a\n"
     "            ld      (current_room), a\n"
     "            ld      (won), a\n"
     "            ld      (caught), a\n")

# --- room change (.enter): instantiate THIS room's Warden, clear of the entry ---
# Done before the new_game-tail swap so the sfx_door-prefixed anchor is unique.
swap(".enter:\n"
     "            call    sfx_door\n"
     "            call    draw_room\n"
     "            call    save_under\n"
     "            call    draw_thief\n"
     "            ret\n",
     ".enter:\n"
     "            call    sfx_door\n"
     "            call    draw_room\n"
     "            call    save_under\n"
     "            call    draw_thief\n"
     "            call    warden_enter     ; this room's Warden, from the table\n"
     "            call    save_warden\n"
     "            call    draw_warden\n"
     "            ret\n")

# --- new_game tail: same, for the opening room ---
swap("            call    draw_room\n"
     "            call    save_under\n"
     "            call    draw_thief\n"
     "            ret\n",
     "            call    draw_room\n"
     "            call    save_under\n"
     "            call    draw_thief\n"
     "            call    warden_enter\n"
     "            call    save_warden\n"
     "            call    draw_warden\n"
     "            ret\n")

# --- the Warden's mind and body, after the thief's draw ---
WARDEN_CODE = """
; ----------------------------------------------------------------------------
; The Warden - a deterministic patrol-freezer, one per room. It walks a fixed
; route (a row or a column, per its table entry), one cell every WARDEN_SPEED
; frames, reversing at walls. It does NOT seek the thief (that was Gloaming's
; draught); it walks a route you learn and time - Sabre Wulf, not a hunter.
; Its route crosses the room's gold, so reaching a coin means timing the patrol.
; Landing on the thief - or the thief walking into it - is the loss: THE KEEP
; SLEEPS. Same two-mover shape as the thief: a private buffer, save/restore/draw.
; ----------------------------------------------------------------------------

; warden_enter - instantiate the current room's Warden from warden_table:
; place it at the route-start (chosen clear of the entry cell) and start its
; gather. Called on new_game and on every room change.
warden_enter:
            ld      a, (current_room)
            add     a, a
            add     a, a             ; * 4 bytes per table row
            ld      e, a
            ld      d, 0
            ld      hl, warden_table
            add     hl, de
            ld      a, (hl)
            ld      (warden_col), a
            inc     hl
            ld      a, (hl)
            ld      (warden_row), a
            inc     hl
            ld      a, (hl)
            ld      (warden_dir), a
            inc     hl
            ld      a, (hl)
            ld      (warden_axis), a
            ld      a, WARDEN_GATHER
            ld      (warden_timer), a
            ret

check_caught:
            ld      a, (warden_col)
            ld      hl, thief_col
            cp      (hl)
            ret     nz
            ld      a, (warden_row)
            ld      hl, thief_row
            cp      (hl)
            ret     nz
            ld      a, 1
            ld      (caught), a
            ret

warden_step:
            ld      a, (warden_timer)
            dec     a
            ld      (warden_timer), a
            ret     nz
            ld      a, WARDEN_SPEED
            ld      (warden_timer), a

            ; propose the next cell along the patrol axis, in the current dir
            ld      a, (warden_axis)
            or      a
            jr      nz, .ws_vert
.ws_horiz:
            ld      a, (warden_row)
            ld      b, a             ; B = row (fixed)
            ld      a, (warden_dir)
            ld      hl, warden_col
            add     a, (hl)
            ld      c, a             ; C = next col
            jr      .ws_have
.ws_vert:
            ld      a, (warden_col)
            ld      c, a             ; C = col (fixed)
            ld      a, (warden_dir)
            ld      hl, warden_row
            add     a, (hl)
            ld      b, a             ; B = next row
.ws_have:
            ; the thief there? caught - and check BEFORE wall_at, because the
            ; thief's own cell reads as wall (its attribute has WALL_BIT set)
            ld      a, c
            ld      hl, thief_col
            cp      (hl)
            jr      nz, .ws_wall
            ld      a, b
            ld      hl, thief_row
            cp      (hl)
            jr      nz, .ws_wall
            ld      a, 1
            ld      (caught), a
            ret
.ws_wall:
            push    bc
            call    wall_at
            pop     bc
            jr      z, .ws_commit    ; floor ahead (bit clear) - step onto it
            ld      a, (warden_dir)  ; wall ahead - reverse, wait for the next tick
            neg
            ld      (warden_dir), a
            ret
.ws_commit:
            push    bc               ; keep the proposed (row B, col C) - restore's
            call    restore_warden   ; wpos_bc reloads B,C from the OLD cell and heals it
            pop     bc               ; ...then take the proposal back
            ld      a, c
            ld      (warden_col), a
            ld      a, b
            ld      (warden_row), a
            call    save_warden      ; photograph the new cell's ground
            call    draw_warden
            ret

wpos_bc:
            ld      a, (warden_row)
            ld      b, a
            ld      a, (warden_col)
            ld      c, a
            ret

save_warden:
            call    wpos_bc
            call    scr_addr_cr
            ld      de, under_warden
            ld      b, 8
.svw_row:
            ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h
            djnz    .svw_row
            call    wpos_bc
            call    attr_addr_cr
            ld      a, (hl)
            ld      (under_warden + 8), a
            ret

restore_warden:
            call    wpos_bc
            call    scr_addr_cr
            ld      de, under_warden
            ld      b, 8
.rsw_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .rsw_row
            call    wpos_bc
            call    attr_addr_cr
            ld      a, (under_warden + 8)
            ld      (hl), a
            ret

draw_warden:
            call    wpos_bc
            call    attr_addr_cr
            ld      (hl), WARDEN
            call    wpos_bc
            call    scr_addr_cr
            ld      de, warden_glyph
            ld      b, 8
.drw_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .drw_row
            ret

; ----------------------------------------------------------------------------
; show_lose - the mirror of show_win. Black screen, the words, the freezing
; sting, then wait for SPACE (and release) to return to the title.
; ----------------------------------------------------------------------------
show_lose:
            di
            call    clear_screen
            ld      hl, str_lost
            ld      b, 9
            ld      c, 8
            call    print_string
            ld      hl, str_again
            ld      b, 15
            ld      c, 5
            call    print_string
            call    sfx_caught
.slo_wait:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      nz, .slo_wait
.slo_rel:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      z, .slo_rel
            ret

; sfx_caught - the plunge into stasis: a quick fall, then a deep, long toll as
; the stone closes over you. The opposite of the win flourish.
sfx_caught:
            ld      c, 16            ; start high
.sca_fall:
            ld      b, 5
            push    bc
            call    beep
            pop     bc
            ld      a, c
            add     a, 7             ; larger delay -> lower pitch (falling fast)
            ld      c, a
            cp      100
            jr      c, .sca_fall
            ld      b, 60            ; ...then the lock: one deep, held toll
            ld      c, 130
            call    beep
            ret

str_lost:
            defb    "THE KEEP SLEEPS", 0

; The Warden's glyph - a spectral hooded sentinel: a cowl with dark eye-slits
; over a robe that frays at the hem. Cold, faceless, unmistakably a figure.
warden_glyph:
            defb    %00111100
            defb    %01111110
            defb    %01100110
            defb    %01111110
            defb    %00111100
            defb    %01111110
            defb    %01111110
            defb    %01011010

; warden_table - one row per room: start col, start row, dir (+1/-1), axis.
; Each route crosses that room's gold and starts clear of the entry cell.
;   Hall  : column 26, rows 2..21 (both Hall coins sit on col 26)
;   Gallery: column 24, bottom chamber rows 9..22 (both coins on col 24)
;   Vault : row 20, cols 1..30 (both coins on row 20), starting between them
warden_table:
            defb    26, 11, -1, AXIS_VERT
            defb    24, 15, -1, AXIS_VERT
            defb    15, 20, -1, AXIS_HORIZ
"""

inject("            ld      de, thief\n"
       "            ld      b, 8\n"
       ".thief_row:\n"
       "            ld      a, (de)\n"
       "            ld      (hl), a\n"
       "            inc     de\n"
       "            inc     h\n"
       "            djnz    .thief_row\n"
       "            ret\n",
       WARDEN_CODE)

# --- variables ---
swap("under_thief:\n"
     "            defb    0, 0, 0, 0, 0, 0, 0, 0, 0\n",
     "under_thief:\n"
     "            defb    0, 0, 0, 0, 0, 0, 0, 0, 0\n"
     "under_warden:\n"
     "            defb    0, 0, 0, 0, 0, 0, 0, 0, 0\n"
     "warden_col:\n"
     "            defb    0\n"
     "warden_row:\n"
     "            defb    0\n"
     "warden_dir:\n"
     "            defb    -1\n"
     "warden_axis:\n"
     "            defb    AXIS_VERT\n"
     "warden_timer:\n"
     "            defb    WARDEN_GATHER\n"
     "caught:\n"
     "            defb    0\n")

# --- contested gold: move each room's coins onto its Warden's route ---
# Hall (room 0): coins to (col 26, row 6) and (col 26, row 17); clear the old
# top/bottom-band coins. The Warden walks col 26 past both.
swap('            defb    "#.......G......................#"\n',
     '            defb    "#..............................#"\n')          # was Hall top coin (col 8, row 2)
swap('            defb    "#.............ooo..............#"\n',
     '            defb    "#.............ooo.........G....#"\n')          # Hall: coin (col 26, row 6), by the rubble row
swap('            defb    "#.....................G........#"\n',
     '            defb    "#.........................G....#"\n')          # Hall: coin (col 26, row 17); was (col 22, row 20)

# Gallery (room 1): coins on the Warden's column (col 24) - the existing bottom
# coin at (col 24, row 20) already sits on it, so add a second at (col 24, row 11)
# and clear the old off-route top coin.
swap('            defb    "#.....G........................#"\n',
     '            defb    "#..............................#"\n')          # was Gallery top coin (col 6, row 2)
swap('            defb    "...............................#"\n',
     '            defb    "........................G......#"\n')          # Gallery: coin (col 24, row 11), west-exit kept open at col 0

# Vault (room 2): coins to (col 10, row 20) and (col 20, row 20), both on the
# Warden's row; clear the old top coin.
swap('            defb    "#.........G....................#"\n',
     '            defb    "#..............................#"\n')          # was Vault top coin (col 10, row 2)
swap('            defb    "#...................G..........#"\n',
     '            defb    "#.........G.........G..........#"\n')          # Vault: coins (col 10 & col 20, row 20)

OUT.write_text(t)
print(f"wrote {OUT} ({len(t.splitlines())} lines)")
