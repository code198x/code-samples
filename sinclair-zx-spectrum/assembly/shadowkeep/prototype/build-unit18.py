#!/usr/bin/env python3
"""Weave — Unit 18: A Theme in One Voice (a composed title theme).

Gives the title screen a voice: a short, solemn phrase in D minor, looping while
the keep waits for you. One voice, no harmony — single-channel beeper composition,
the melody carrying the whole mood. A note-table interpreter (play_note /
rest_chunks) walks the theme; SPACE breaks out to start the game.

Single step, built on Unit 17's end.

Run from prototype/:  python3 build-unit18.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "weave" / "unit-17" / "steps" / "step-01.asm"
OUTDIR = HERE / "weave" / "unit-18" / "steps"
OUTDIR.mkdir(parents=True, exist_ok=True)

base = BASE.read_text()

H17 = ("; Shadowkeep — Unit 17: Footsteps and Doors\n"
       "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
       "; step-01 gives the keep its ambient voice — a footfall per step, a creak per door.")


def swap(t, old, new):
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:48]!r}"
    return t.replace(old, new)


TITLE_SILENT = """.tt_wait:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      nz, .tt_wait
.tt_rel:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      z, .tt_rel
            ret"""

TITLE_THEME = """.tt_tune:
            ld      hl, theme
.tt_note:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      z, .tt_pressed   ; SPACE down -> leave
            ld      a, (hl)
            inc     hl
            cp      $FF
            jr      z, .tt_tune      ; end of tune -> loop it
            ld      c, a
            ld      a, (hl)
            inc     hl
            ld      d, a
            ld      a, c
            or      a
            jr      z, .tt_rest
            push    hl
            call    play_note
            pop     hl
            jr      .tt_note
.tt_rest:
            push    hl
            call    rest_chunks
            pop     hl
            jr      .tt_note
.tt_pressed:
            ld      bc, KEYS_SPACE   ; debounce: wait for release
            in      a, (c)
            bit     0, a
            jr      z, .tt_pressed
            ret"""

MUSIC_CODE = """
; ----------------------------------------------------------------------------
; The music player — a note-table interpreter for the title theme.
; play_note — C = pitch (beep delay), D = duration in chunks. A note is the beep
; primitive run for D fixed-size chunks, so a note can be long though one beep's
; cycle count is a single byte.
; ----------------------------------------------------------------------------
play_note:
.pn_loop:
            ld      b, 24            ; one chunk = 24 square-wave cycles
            push    de
            call    beep             ; B cycles at pitch C
            pop     de
            dec     d
            jr      nz, .pn_loop
            ret

; rest_chunks — D chunks of silence, timed to roughly match a note chunk so rests
; sit in the rhythm.
rest_chunks:
.rc_loop:
            ld      b, 24
.rc_inner:
            ld      e, 75
.rc_wait:
            dec     e
            jr      nz, .rc_wait
            djnz    .rc_inner
            dec     d
            jr      nz, .rc_loop
            ret

; The theme — a short, solemn phrase in D minor. Pitch values are beep delay
; constants (larger = lower); durations are chunk counts. One voice, no harmony:
; the melody carries the whole mood by itself.
theme:
            defb    75, 8            ; D5
            defb    63, 8            ; F5
            defb    50, 8            ; A5
            defb    50, 12           ; A5 (held)
            defb    56, 8            ; G5
            defb    63, 8            ; F5
            defb    66, 8            ; E5
            defb    75, 16           ; D5 (resolve)
            defb    0,  6            ; breath
            defb    56, 8            ; G5
            defb    63, 8            ; F5
            defb    50, 8            ; A5
            defb    75, 16           ; D5 (home)
            defb    $FF              ; end
"""

t = swap(base, H17,
         "; Shadowkeep — Unit 18: A Theme in One Voice\n"
         "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
         "; step-01 gives the title a voice — a solemn D-minor phrase, looping as it waits.")
# the title now loops the theme instead of waiting in silence
t = swap(t, TITLE_SILENT, TITLE_THEME)
# the music player + theme, after the door creak
t = swap(t,
         "sfx_door:\n"
         "            ld      c, 36            ; start higher\n"
         ".sd_sweep:\n"
         "            ld      b, 3\n"
         "            push    bc\n"
         "            call    beep\n"
         "            pop     bc\n"
         "            inc     c                ; lower the pitch a little\n"
         "            inc     c\n"
         "            ld      a, c\n"
         "            cp      130              ; until it has groaned down low\n"
         "            jr      c, .sd_sweep\n"
         "            ret\n",
         "sfx_door:\n"
         "            ld      c, 36            ; start higher\n"
         ".sd_sweep:\n"
         "            ld      b, 3\n"
         "            push    bc\n"
         "            call    beep\n"
         "            pop     bc\n"
         "            inc     c                ; lower the pitch a little\n"
         "            inc     c\n"
         "            ld      a, c\n"
         "            cp      130              ; until it has groaned down low\n"
         "            jr      c, .sd_sweep\n"
         "            ret\n"
         + MUSIC_CODE)

step00 = swap(base, H17,
              "; Shadowkeep — Unit 18: A Theme in One Voice\n"
              "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
              "; step-00 = Unit 17's end: the keep sounds, but the title waits in silence.")

(OUTDIR / "step-00.asm").write_text(step00)
(OUTDIR / "step-01.asm").write_text(t)
print(f"wrote unit-18 step-00 ({len(step00.splitlines())}), step-01 ({len(t.splitlines())}) lines")
