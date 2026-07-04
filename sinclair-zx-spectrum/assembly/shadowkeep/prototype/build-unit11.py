#!/usr/bin/env python3
"""Weave — Unit 11: Join the Sleepers (the *fail* — the Place becomes a game).

Third unit of the woven game core, and the pivot of the whole arc: until now the
keep is finishable but not losable. Here the Warden's touch becomes stasis — the
direct echo of Gloaming's "a game needs a way to lose."

  step-01  contact = caught. The Warden's step onto the thief's cell sets a flag;
           the loop gains its lose arm (title -> explore -> win OR lose -> title)
           and throws you back to the title. (You can't walk INTO the Warden — it
           reads as a wall — so the catch is the Warden walking into you.)
  step-02  THE KEEP SLEEPS — the loss screen + a plunge-then-lock caught-sting,
           the mirror of the win flourish.

Run from prototype/:  python3 build-unit11.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "weave" / "unit-10" / "steps" / "step-02.asm"
OUTDIR = HERE / "weave" / "unit-11" / "steps"
OUTDIR.mkdir(parents=True, exist_ok=True)

base = BASE.read_text()

H10 = ("; Shadowkeep — Unit 10: Something in the Dark\n"
       "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
       "; step-02 sets the Warden walking — a deterministic patrol up and down its column.")


def swap(t, old, new):
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:48]!r}"
    return t.replace(old, new)


def inject(t, anchor, addition):
    assert t.count(anchor) == 1, f"anchor not unique ({t.count(anchor)}x): {anchor[:48]!r}"
    return t.replace(anchor, anchor + addition)


LOSE_CODE = """
; ----------------------------------------------------------------------------
; show_lose — the mirror of show_win. Black screen, the words, the freezing
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

; sfx_caught — the plunge into stasis: a quick fall, then a deep, long toll as
; the stone closes over you. The opposite of the win flourish.
sfx_caught:
            ld      c, 16
.sca_fall:
            ld      b, 5
            push    bc
            call    beep
            pop     bc
            ld      a, c
            add     a, 7
            ld      c, a
            cp      100
            jr      c, .sca_fall
            ld      b, 60
            ld      c, 130
            call    beep
            ret

str_lost:
            defb    "THE KEEP SLEEPS", 0
"""


def build_step01():
    t = base
    t = swap(t, H10,
             "; Shadowkeep — Unit 11: Join the Sleepers\n"
             "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
             "; step-01 makes the Warden's touch a loss — the Place becomes a game.")
    # warden_step: catch the thief before the wall test
    t = swap(t,
             "            ld      a, (warden_dir)\n"
             "            ld      hl, warden_row\n"
             "            add     a, (hl)\n"
             "            ld      b, a             ; B = next row\n"
             "            push    bc\n"
             "            call    wall_at\n"
             "            pop     bc\n"
             "            jr      z, .ws_commit    ; floor ahead — step onto it\n",
             "            ld      a, (warden_dir)\n"
             "            ld      hl, warden_row\n"
             "            add     a, (hl)\n"
             "            ld      b, a             ; B = next row\n"
             "            ld      a, b             ; the thief there? caught — check BEFORE\n"
             "            ld      hl, thief_row    ; wall_at, because his own cell reads as wall\n"
             "            cp      (hl)\n"
             "            jr      nz, .ws_wall\n"
             "            ld      a, c\n"
             "            ld      hl, thief_col\n"
             "            cp      (hl)\n"
             "            jr      nz, .ws_wall\n"
             "            ld      a, 1\n"
             "            ld      (caught), a\n"
             "            ret\n"
             ".ws_wall:\n"
             "            push    bc\n"
             "            call    wall_at\n"
             "            pop     bc\n"
             "            jr      z, .ws_commit    ; floor ahead — step onto it\n")
    # main loop: branch to .lost when caught
    t = swap(t,
             "            call    player_step\n"
             "            ld      a, (current_room)\n"
             "            or      a\n"
             "            call    z, warden_step   ; the Warden haunts the Hall (room 0)\n"
             "            call    mark_step\n"
             "            jr      .game_loop\n"
             ".won:\n",
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
             "            jr      .game_loop\n"
             ".lost:\n"
             "            jr      main_title       ; caught — step-02 gives it a screen\n"
             ".won:\n")
    # new_game: clear caught
    t = swap(t,
             "            xor     a\n"
             "            ld      (current_room), a\n"
             "            ld      (won), a\n",
             "            xor     a\n"
             "            ld      (current_room), a\n"
             "            ld      (won), a\n"
             "            ld      (caught), a\n")
    # variable: caught
    t = swap(t,
             "warden_timer:\n"
             "            defb    WARDEN_GATHER\n",
             "warden_timer:\n"
             "            defb    WARDEN_GATHER\n"
             "caught:\n"
             "            defb    0\n")
    return t


def build_step02(t):
    t = swap(t,
             "; step-01 makes the Warden's touch a loss — the Place becomes a game.",
             "; step-02 gives the loss a face: THE KEEP SLEEPS, and a plunge-then-lock sting.")
    # .lost: show the screen
    t = swap(t,
             ".lost:\n"
             "            jr      main_title       ; caught — step-02 gives it a screen\n",
             ".lost:\n"
             "            call    show_lose        ; \"THE KEEP SLEEPS\", the sting, wait for SPACE\n"
             "            jr      main_title\n")
    # routines: after str_again
    t = inject(t,
               "str_again:\n"
               "            defb    \"PRESS SPACE TO RETURN\", 0\n",
               LOSE_CODE)
    return t


# step-00: Unit 10's end, header relabelled.
step00 = swap(base, H10,
              "; Shadowkeep — Unit 11: Join the Sleepers\n"
              "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
              "; step-00 = Unit 10's end: a Warden patrols the Hall, but cannot yet harm you.")

step01 = build_step01()
step02 = build_step02(step01)

(OUTDIR / "step-00.asm").write_text(step00)
(OUTDIR / "step-01.asm").write_text(step01)
(OUTDIR / "step-02.asm").write_text(step02)
print(f"wrote unit-11 step-00 ({len(step00.splitlines())}), "
      f"step-01 ({len(step01.splitlines())}), step-02 ({len(step02.splitlines())}) lines")
