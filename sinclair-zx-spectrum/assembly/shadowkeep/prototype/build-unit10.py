#!/usr/bin/env python3
"""Weave — Unit 10: Something in the Dark (the *threat*, a second mover).

Second unit of the woven game core. Builds on Unit 9's end (gold + the win loop)
and gives the keep a Warden: a spectral hooded sentinel haunting the Hall, drawn
exactly like the thief (a private under-buffer + save/restore/draw) and walking a
deterministic patrol up and down the gold's column.

  step-01  the Warden appears — a second mover with a body: placed at the Hall's
           gold column, drawn on new_game and redrawn on Hall re-entry. Static.
  step-02  the Warden patrols — one cell every WARDEN_SPEED frames after a gather,
           reversing at walls. A route you learn and time (Sabre Wulf, not a
           hunter). It treats the thief's cell as a wall, so it turns aside at
           him for now — contact becomes loss in Unit 11.

Single Warden, Hall only; the per-room table + any-axis patrol is Unit 12. The
Warden is lighting-agnostic (its buffer preserves whatever stone sits under it),
so Unit 13's atmosphere layers on top untouched.

Run from prototype/:  python3 build-unit10.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "weave" / "unit-09" / "steps" / "step-02.asm"
OUTDIR = HERE / "weave" / "unit-10" / "steps"
OUTDIR.mkdir(parents=True, exist_ok=True)

base = BASE.read_text()

H9 = ("; Shadowkeep — Unit 9: The Keep's Gold\n"
      "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
      "; step-02 makes the last coin win: THE KEEP STANDS, in a title -> play -> win loop.")


def swap(t, old, new):
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:48]!r}"
    return t.replace(old, new)


def inject(t, anchor, addition):
    assert t.count(anchor) == 1, f"anchor not unique ({t.count(anchor)}x): {anchor[:48]!r}"
    return t.replace(anchor, anchor + addition)


WARDEN_BODY = """
; ----------------------------------------------------------------------------
; The Warden — something shares the keep. A second mover, drawn exactly like the
; thief: a private under-buffer and its own save / draw, a spectral hooded
; sentinel. First we simply give it a body (it neither moves nor harms yet).
; ----------------------------------------------------------------------------
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

; A spectral hooded sentinel: a cowl with dark eye-slits over a robe that frays
; at the hem. Cold, faceless, unmistakably a figure.
warden_glyph:
            defb    %00111100
            defb    %01111110
            defb    %01100110
            defb    %01111110
            defb    %00111100
            defb    %01111110
            defb    %01111110
            defb    %01011010
"""

WARDEN_MIND = """
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

; warden_step — the patrol. Walks its column one cell every WARDEN_SPEED frames,
; after a WARDEN_GATHER beat, reversing at walls. Deterministic: a route you learn
; and time. It reads the thief's cell as a wall (his attribute has WALL_BIT set),
; so it turns aside at him for now — the catch is Unit 11.
warden_step:
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
            ret
"""


def build_step01():
    t = base
    t = swap(t, H9,
             "; Shadowkeep — Unit 10: Something in the Dark\n"
             "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
             "; step-01 gives the Hall a Warden — a second mover with a body, not yet moving.")
    # equates
    t = inject(t, "TOTAL_GOLD  equ     6",
               "\nWARDEN      equ     %01000101         ; BRIGHT cyan on black — the sentinel"
               "\nWARDEN_COL0 equ     26                ; the Hall's gold column"
               "\nWARDEN_ROW0 equ     11")
    # .enter — redraw the Warden on Hall re-entry (do this first; .enter: makes it unique)
    t = swap(t,
             ".enter:\n"
             "            call    draw_room\n"
             "            call    save_under\n"
             "            call    draw_thief\n"
             "            ret\n",
             ".enter:\n"
             "            call    draw_room\n"
             "            call    save_under\n"
             "            call    draw_thief\n"
             "            ld      a, (current_room)\n"
             "            or      a\n"
             "            ret     nz               ; the Warden is only in the Hall\n"
             "            call    save_warden\n"
             "            call    draw_warden\n"
             "            ret\n")
    # new_game tail — place and draw the Warden (now the remaining such block)
    t = swap(t,
             "            call    draw_room\n"
             "            call    save_under\n"
             "            call    draw_thief\n"
             "            ret\n",
             "            call    draw_room\n"
             "            call    save_under\n"
             "            call    draw_thief\n"
             "            ld      a, WARDEN_COL0\n"
             "            ld      (warden_col), a\n"
             "            ld      a, WARDEN_ROW0\n"
             "            ld      (warden_row), a\n"
             "            call    save_warden\n"
             "            call    draw_warden\n"
             "            ret\n")
    # routines after draw_thief
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
               WARDEN_BODY)
    # variables
    t = swap(t,
             "won:\n"
             "            defb    0\n",
             "won:\n"
             "            defb    0\n"
             "under_warden:\n"
             "            defb    0, 0, 0, 0, 0, 0, 0, 0, 0\n"
             "warden_col:\n"
             "            defb    WARDEN_COL0\n"
             "warden_row:\n"
             "            defb    WARDEN_ROW0\n")
    return t


def build_step02(t):
    t = swap(t,
             "; step-01 gives the Hall a Warden — a second mover with a body, not yet moving.",
             "; step-02 sets the Warden walking — a deterministic patrol up and down its column.")
    # equates: movement constants
    t = swap(t, "WARDEN_ROW0 equ     11",
             "WARDEN_ROW0 equ     11\n"
             "WARDEN_SPEED equ    10                ; frames between patrol steps\n"
             "WARDEN_GATHER equ   50                ; a beat before it begins to move")
    # new_game: init dir + gather
    t = swap(t,
             "            ld      a, WARDEN_ROW0\n"
             "            ld      (warden_row), a\n"
             "            call    save_warden\n",
             "            ld      a, WARDEN_ROW0\n"
             "            ld      (warden_row), a\n"
             "            ld      a, -1\n"
             "            ld      (warden_dir), a\n"
             "            ld      a, WARDEN_GATHER\n"
             "            ld      (warden_timer), a\n"
             "            call    save_warden\n")
    # routines: restore + step, after the glyph
    t = swap(t,
             "warden_glyph:\n"
             "            defb    %00111100\n"
             "            defb    %01111110\n"
             "            defb    %01100110\n"
             "            defb    %01111110\n"
             "            defb    %00111100\n"
             "            defb    %01111110\n"
             "            defb    %01111110\n"
             "            defb    %01011010\n",
             "warden_glyph:\n"
             "            defb    %00111100\n"
             "            defb    %01111110\n"
             "            defb    %01100110\n"
             "            defb    %01111110\n"
             "            defb    %00111100\n"
             "            defb    %01111110\n"
             "            defb    %01111110\n"
             "            defb    %01011010\n"
             + WARDEN_MIND)
    # main loop: step the Warden in the Hall
    t = swap(t,
             "            call    player_step\n"
             "            call    mark_step\n"
             "            jr      .game_loop\n",
             "            call    player_step\n"
             "            ld      a, (current_room)\n"
             "            or      a\n"
             "            call    z, warden_step   ; the Warden haunts the Hall (room 0)\n"
             "            call    mark_step\n"
             "            jr      .game_loop\n")
    # variables: dir + timer
    t = swap(t,
             "warden_row:\n"
             "            defb    WARDEN_ROW0\n",
             "warden_row:\n"
             "            defb    WARDEN_ROW0\n"
             "warden_dir:\n"
             "            defb    -1\n"
             "warden_timer:\n"
             "            defb    WARDEN_GATHER\n")
    return t


# step-00: Unit 9's end, header relabelled to Unit 10.
step00 = swap(base, H9,
              "; Shadowkeep — Unit 10: Something in the Dark\n"
              "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
              "; step-00 = Unit 9's end: gold and a win, but the keep is empty and safe.")

step01 = build_step01()
step02 = build_step02(step01)

(OUTDIR / "step-00.asm").write_text(step00)
(OUTDIR / "step-01.asm").write_text(step01)
(OUTDIR / "step-02.asm").write_text(step02)
print(f"wrote unit-10 step-00 ({len(step00.splitlines())}), "
      f"step-01 ({len(step01.splitlines())}), step-02 ({len(step02.splitlines())}) lines")
