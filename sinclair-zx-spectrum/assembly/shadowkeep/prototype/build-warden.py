#!/usr/bin/env python3
"""Shadowkeep — the Warden jeopardy prototype.

Builds shadowkeep-warden.asm from the shipped Place (unit-16 step-01.asm)
by adding a second mover: the Warden, a deterministic patrol-freezer that
haunts the Hall (room 0). Touch the Warden and you join the sleepers —
THE KEEP SLEEPS. The Place had no fail state; this gives it one.

Design (per a-game-needs-jeopardy.md + the Waking vision):
  * The Warden patrols row 11 of the Hall (across the east door), one cell
    every WARDEN_SPEED frames, reversing at walls. Deterministic and
    memorisable — Sabre Wulf's roaming beasts, not Gloaming's hunting
    draught: it walks a route, it does not seek you.
  * No combat: contact = stasis = loss. You route around it.
  * Room 0 only (a known prototype limit — the design-stress pass will
    surface "leave the Hall to escape" and inform the real per-room design).

The engine already has the two-mover shape (save/restore/draw + a private
buffer); the Warden reuses it exactly, the way the learner built the
draught in Gloaming. Injections are anchored; an assert fires on drift.

Run from this directory:  python3 build-warden.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
SRC = HERE.parent / "unit-16" / "steps" / "step-01.asm"
OUT = HERE / "shadowkeep-warden.asm"

t = SRC.read_text()


def inject(anchor: str, addition: str, *, after: bool = True) -> None:
    global t
    assert t.count(anchor) == 1, f"anchor not unique ({t.count(anchor)}x): {anchor[:50]!r}"
    t = t.replace(anchor, anchor + addition if after else addition + anchor)


def swap(old: str, new: str) -> None:
    global t
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:50]!r}"
    t = t.replace(old, new)


# header
swap("; Shadowkeep — Unit 16: The Keep Stands\n"
     "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
     "; step-01 wraps it in a state machine: title -> play -> win -> title, a finishable, replayable game.",
     "; Shadowkeep — the Warden jeopardy prototype (a-game-needs-jeopardy.md, 2026-07-04)\n"
     "; The Place, made losable: a deterministic patrol-freezer haunts the Hall.\n"
     "; Touch it and you join the sleepers - THE KEEP SLEEPS. Built from unit-16 step-01.")

# --- equates ---
inject("THIEF       equ     %01001010",
       "\nWARDEN        equ   %01000101       ; BRIGHT cyan on black - the freezer, spectral"
       "\nWARDEN_SPEED  equ   10              ; frames between the Warden's patrol steps"
       "\nWARDEN_GATHER equ   80              ; a beat before it begins - read the Hall first"
       "\nWARDEN_COL0   equ   29              ; enters at the east end of its patrol row"
       "\nWARDEN_ROW0   equ   11              ; row 11 - across the Hall's east door")

# --- main loop: the Warden patrols, and catching the thief loses the game ---
swap("            call    player_step\n"
     "            call    mark_step\n"
     "            jr      .game_loop\n"
     ".won:\n"
     "            call    show_win         ; \"THE KEEP STANDS\", flourish, wait for SPACE\n"
     "            jr      main_title       ; round again",
     "            call    player_step\n"
     "            ld      a, (current_room)\n"
     "            or      a\n"
     "            jr      nz, .skip_warden ; the Warden haunts the Hall (room 0) alone\n"
     "            call    check_caught     ; the thief may have stepped into the Warden\n"
     "            ld      a, (caught)\n"
     "            or      a\n"
     "            jr      nz, .lost\n"
     "            call    warden_step      ; the Warden steps; it may land on the thief\n"
     "            ld      a, (caught)\n"
     "            or      a\n"
     "            jr      nz, .lost\n"
     ".skip_warden:\n"
     "            call    mark_step\n"
     "            jr      .game_loop\n"
     ".lost:\n"
     "            call    show_lose        ; \"THE KEEP SLEEPS\", the sting, wait for SPACE\n"
     "            jr      main_title\n"
     ".won:\n"
     "            call    show_win         ; \"THE KEEP STANDS\", flourish, wait for SPACE\n"
     "            jr      main_title       ; round again")

# --- new_game: place and draw the Warden, clear the caught flag ---
swap("            ld      a, START_ROW\n"
     "            ld      (thief_row), a\n",
     "            ld      a, START_ROW\n"
     "            ld      (thief_row), a\n"
     "            ld      a, WARDEN_COL0\n"
     "            ld      (warden_col), a\n"
     "            ld      a, WARDEN_ROW0\n"
     "            ld      (warden_row), a\n"
     "            ld      a, -1\n"
     "            ld      (warden_dir), a  ; patrolling west to begin\n"
     "            ld      a, WARDEN_GATHER\n"
     "            ld      (warden_timer), a\n"
     "            xor     a\n"
     "            ld      (caught), a\n")

# --- room change: redraw the Warden only when we re-enter the Hall ---
# (done before new_game's tail so its draw_room/.../ret anchor is unique)
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
     "            ld      a, (current_room)\n"
     "            or      a\n"
     "            ret     nz               ; the Warden is only in the Hall\n"
     "            call    save_warden      ; re-entered the Hall: grab fresh ground...\n"
     "            call    draw_warden      ; ...and repaint the Warden the room wiped\n"
     "            ret\n")

swap("            call    draw_room\n"
     "            call    save_under\n"
     "            call    draw_thief\n"
     "            ret\n",
     "            call    draw_room\n"
     "            call    save_under\n"
     "            call    draw_thief\n"
     "            call    save_warden\n"
     "            call    draw_warden\n"
     "            ret\n")

# --- the Warden's mind and body, added after the thief's draw ---
WARDEN_CODE = """
; ----------------------------------------------------------------------------
; The Warden - a deterministic patrol-freezer. It walks row 11 of the Hall,
; one cell every WARDEN_SPEED frames, reversing when it meets a wall. It does
; not seek the thief (that was Gloaming's draught); it walks a fixed route you
; learn and time. Landing on the thief - or the thief walking into it - is the
; loss: THE KEEP SLEEPS. Same two-mover shape as the thief: a private buffer,
; save / restore / draw.
; ----------------------------------------------------------------------------
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

            ; propose the next cell along the patrol row, in the current dir
            ld      a, (warden_col)
            ld      c, a
            ld      a, (warden_dir)
            add     a, c
            ld      c, a             ; C = next col
            ld      a, (warden_row)
            ld      b, a             ; B = row

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
            ld      a, (warden_dir)  ; wall ahead - reverse, and wait a beat
            neg
            ld      (warden_dir), a
            ret
.ws_commit:
            push    bc               ; keep the proposed (row B, col C) - restore_warden's
            call    restore_warden   ; wpos_bc reloads B,C from the OLD position and heals it
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
; show_lose - the mirror of show_win. Black screen, the words, a falling sting,
; then wait for SPACE (and release) to return to the title.
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

; sfx_caught - a descending sting: the opposite of the win flourish, a note
; sinking into the dark.
sfx_caught:
            ld      c, 20            ; start high
.sca_loop:
            ld      b, 10
            push    bc
            call    beep
            pop     bc
            ld      a, c
            add     a, 12            ; larger delay -> lower pitch (falling)
            ld      c, a
            cp      120
            jr      c, .sca_loop
            ret

str_lost:
            defb    "THE KEEP SLEEPS", 0

warden_glyph:
            defb    %00111100
            defb    %01111110
            defb    %11111111
            defb    %11111111
            defb    %11011011
            defb    %11111111
            defb    %01111110
            defb    %00111100
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
     "            defb    WARDEN_COL0\n"
     "warden_row:\n"
     "            defb    WARDEN_ROW0\n"
     "warden_dir:\n"
     "            defb    -1\n"
     "warden_timer:\n"
     "            defb    WARDEN_GATHER\n"
     "caught:\n"
     "            defb    0\n")

OUT.write_text(t)
print(f"wrote {OUT} ({len(t.splitlines())} lines)")
