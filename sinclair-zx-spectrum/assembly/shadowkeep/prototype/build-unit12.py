#!/usr/bin/env python3
"""Weave — Unit 12: A Warden for Every Room (density from data).

Fourth and final unit of the woven game core. Generalises the single Hall Warden
to one per room, instantiated from a table — the same data-driven shape the gold
already uses. The gold placed back in Unit 9 already sits on each room's route, so
nothing moves: the Wardens simply arrive on the gold's ground.

  step-01  any-axis patrol — the Warden can walk a row OR a column (warden_axis),
           so a room can be guarded across or up-and-down. The Hall stays vertical.
  step-02  a Warden in every room — a warden_table (start cell, dir, axis per room)
           and warden_enter, instantiated on entry clear of the entry cell; the
           loop steps the current room's Warden in all three rooms. Gallery (a
           column) and Vault (a row) get theirs. 'A second mover is a table entry.'

Run from prototype/:  python3 build-unit12.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "weave" / "unit-11" / "steps" / "step-02.asm"
OUTDIR = HERE / "weave" / "unit-12" / "steps"
OUTDIR.mkdir(parents=True, exist_ok=True)

base = BASE.read_text()

H11 = ("; Shadowkeep — Unit 11: Join the Sleepers\n"
       "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
       "; step-02 gives the loss a face: THE KEEP SLEEPS, and a plunge-then-lock sting.")


def swap(t, old, new):
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:48]!r}"
    return t.replace(old, new)


def inject(t, anchor, addition):
    assert t.count(anchor) == 1, f"anchor not unique ({t.count(anchor)}x): {anchor[:48]!r}"
    return t.replace(anchor, anchor + addition)


WS_VERTICAL = """warden_step:
            ld      a, (warden_timer)
            dec     a
            ld      (warden_timer), a
            ret     nz
            ld      a, WARDEN_SPEED
            ld      (warden_timer), a
            ld      a, (warden_col)
            ld      c, a             ; C = column (fixed)
            ld      a, (warden_dir)
            ld      hl, warden_row
            add     a, (hl)
            ld      b, a             ; B = next row
            ld      a, b             ; the thief there? caught — check BEFORE
            ld      hl, thief_row    ; wall_at, because his own cell reads as wall
            cp      (hl)
            jr      nz, .ws_wall
            ld      a, c
            ld      hl, thief_col
            cp      (hl)
            jr      nz, .ws_wall
            ld      a, 1
            ld      (caught), a
            ret
.ws_wall:
            push    bc
            call    wall_at
            pop     bc
            jr      z, .ws_commit    ; floor ahead — step onto it
            ld      a, (warden_dir)  ; wall ahead — reverse, wait a beat
            neg
            ld      (warden_dir), a
            ret
.ws_commit:
            push    bc               ; keep the proposed row — restore heals the OLD cell
            call    restore_warden
            pop     bc
            ld      a, b
            ld      (warden_row), a
            call    save_warden      ; photograph the new cell's ground
            call    draw_warden
            ret"""

WS_ANYAXIS = """warden_step:
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
            ld      a, b             ; the thief there? caught — check BEFORE
            ld      hl, thief_row    ; wall_at, because his own cell reads as wall
            cp      (hl)
            jr      nz, .ws_wall
            ld      a, c
            ld      hl, thief_col
            cp      (hl)
            jr      nz, .ws_wall
            ld      a, 1
            ld      (caught), a
            ret
.ws_wall:
            push    bc
            call    wall_at
            pop     bc
            jr      z, .ws_commit    ; floor ahead — step onto it
            ld      a, (warden_dir)  ; wall ahead — reverse, wait a beat
            neg
            ld      (warden_dir), a
            ret
.ws_commit:
            push    bc               ; keep the proposed (row B, col C)
            call    restore_warden
            pop     bc
            ld      a, c
            ld      (warden_col), a
            ld      a, b
            ld      (warden_row), a
            call    save_warden      ; photograph the new cell's ground
            call    draw_warden
            ret"""

WARDEN_ENTER = """
; ----------------------------------------------------------------------------
; warden_enter — instantiate the current room's Warden from warden_table: place
; it at the route-start (chosen clear of the entry cell), set its axis, and start
; its gather. Called on new_game and on every room change. A second mover is a
; table entry — like the torches and the gold.
; ----------------------------------------------------------------------------
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

; warden_table — one row per room: start col, start row, dir (+1/-1), axis.
; Each route crosses that room's gold and starts clear of the entry cell.
warden_table:
            defb    WARDEN_COL0, WARDEN_ROW0, -1, AXIS_VERT   ; Hall — the gold's column
            defb    24, 15, -1, AXIS_VERT                     ; Gallery — column 24, lower chamber
            defb    15, 20, -1, AXIS_HORIZ                    ; Vault — row 20, between the coins
"""


def build_step01():
    t = base
    t = swap(t, H11,
             "; Shadowkeep — Unit 12: A Warden for Every Room\n"
             "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
             "; step-01 lets a Warden walk a row or a column — patrol on either axis.")
    # axis equates
    t = swap(t, "WARDEN_GATHER equ   50                ; a beat before it begins to move",
             "WARDEN_GATHER equ   50                ; a beat before it begins to move\n"
             "AXIS_HORIZ  equ     0                 ; the Warden varies its column (walks a row)\n"
             "AXIS_VERT   equ     1                 ; the Warden varies its row (walks a column)")
    # axis-aware warden_step
    t = swap(t, WS_VERTICAL, WS_ANYAXIS)
    # warden_axis variable
    t = swap(t,
             "warden_dir:\n"
             "            defb    -1\n",
             "warden_dir:\n"
             "            defb    -1\n"
             "warden_axis:\n"
             "            defb    AXIS_VERT\n")
    return t


def build_step02(t):
    t = swap(t,
             "; step-01 lets a Warden walk a row or a column — patrol on either axis.",
             "; step-02 gives every room its own Warden, instantiated from a table on entry.")
    # new_game: instantiate from the table instead of hardcoding the Hall
    t = swap(t,
             "            call    draw_thief\n"
             "            ld      a, WARDEN_COL0\n"
             "            ld      (warden_col), a\n"
             "            ld      a, WARDEN_ROW0\n"
             "            ld      (warden_row), a\n"
             "            ld      a, -1\n"
             "            ld      (warden_dir), a\n"
             "            ld      a, WARDEN_GATHER\n"
             "            ld      (warden_timer), a\n"
             "            call    save_warden\n"
             "            call    draw_warden\n"
             "            ret\n",
             "            call    draw_thief\n"
             "            call    warden_enter     ; this room's Warden, from the table\n"
             "            call    save_warden\n"
             "            call    draw_warden\n"
             "            ret\n")
    # .enter: a Warden in every room
    t = swap(t,
             "            call    draw_thief\n"
             "            ld      a, (current_room)\n"
             "            or      a\n"
             "            ret     nz               ; the Warden is only in the Hall\n"
             "            call    save_warden\n"
             "            call    draw_warden\n"
             "            ret\n",
             "            call    draw_thief\n"
             "            call    warden_enter     ; this room's Warden, clear of the entry cell\n"
             "            call    save_warden\n"
             "            call    draw_warden\n"
             "            ret\n")
    # main loop: step the Warden in every room
    t = swap(t,
             "            call    player_step\n"
             "            ld      a, (current_room)\n"
             "            or      a\n"
             "            jr      nz, .skip_warden ; the Warden haunts the Hall (room 0)\n"
             "            call    warden_step      ; it may step onto the thief\n"
             "            ld      a, (caught)\n"
             "            or      a\n"
             "            jr      nz, .lost\n"
             ".skip_warden:\n"
             "            call    mark_step\n"
             "            jr      .game_loop\n",
             "            call    player_step\n"
             "            call    warden_step      ; every room has its Warden now\n"
             "            ld      a, (caught)\n"
             "            or      a\n"
             "            jr      nz, .lost\n"
             "            call    mark_step\n"
             "            jr      .game_loop\n")
    # routines: warden_enter + table, after warden_step's draw
    t = inject(t, WS_ANYAXIS + "\n", WARDEN_ENTER)
    return t


# step-00: Unit 11's end, header relabelled.
step00 = swap(base, H11,
              "; Shadowkeep — Unit 12: A Warden for Every Room\n"
              "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
              "; step-00 = Unit 11's end: one Warden, in the Hall alone; the other rooms are safe.")

step01 = build_step01()
step02 = build_step02(step01)

(OUTDIR / "step-00.asm").write_text(step00)
(OUTDIR / "step-01.asm").write_text(step01)
(OUTDIR / "step-02.asm").write_text(step02)
print(f"wrote unit-12 step-00 ({len(step00.splitlines())}), "
      f"step-01 ({len(step01.splitlines())}), step-02 ({len(step02.splitlines())}) lines")
