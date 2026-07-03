#!/usr/bin/env python3
"""The Long Night — derive every unit's step files from the course baseline.

The baseline is Gloaming unit 20's final step (byte-identical to
gloaming-m1.sna — the module seam). Each unit's end state is that text
plus the unit's diff: code verbatim from the route skeleton
(prototype/skeleton-m2/), comments in the course voice. Intermediate
steps are partial applications of the same transforms — every fragment
lands by assert-anchored swap, exactly as the skeleton itself was
derived.

The gate (run by this script):
  * every step assembles under Asm198x;
  * each unit's FINAL step is byte-identical to its skeleton snapshot
    (skeleton-m2/unit-0N.sna) — so unit 10's final step is the shipped
    gloaming.sna, byte for byte;
  * each unit's step-00 is the previous unit's final text under the new
    unit's header.

Run from this directory:  python3 derive-steps.py
"""

from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent            # the-long-night
GLOAMING = HERE.parent / "gloaming"
BASELINE = GLOAMING / "unit-20" / "steps" / "step-02.asm"
SKEL = GLOAMING / "prototype" / "skeleton-m2"
ASM198X = Path.home() / "Projects/198x/Asm198x/asm198x/target/release/asm198x"

C0 = BASELINE.read_text()
DASH = "; ----------------------------------------------------------------------------"


def drop(text: str, gone: str, n: int = 1) -> str:
    assert text.count(gone) == n, \
        f"drop anchor hit {text.count(gone)}x, want {n}: {gone[:64]!r}"
    return text.replace(gone, "")


def swap(text: str, old: str, new: str, n: int = 1) -> str:
    assert text.count(old) == n, \
        f"swap anchor hit {text.count(old)}x, want {n}: {old[:64]!r}"
    return text.replace(old, new)


def header(unit: int, title: str, idea: str, text: str) -> str:
    """Swap the three-line course header for this unit's."""
    old = text[:text.index("\n\n")]
    new = (f"; The Long Night — Unit {unit}: {title}\n"
           f"; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
           f"; {idea}")
    return new + text[text.index("\n\n"):]


# ==========================================================================
# UNIT 1 — The Dark Seeks the Light
# ==========================================================================

MANHATTAN = """\
; ----------------------------------------------------------------------------
; manhattan — distance from the draught to cell (C = col, B = row) -> A.
; Grid distance, not straight-line: |dc| + |dr|, the number of steps a
; 4-connected walker needs — the only distance the night knows.
; ----------------------------------------------------------------------------
manhattan:
            ld      a, (draught_col)
            sub     c
            jp      p, .dc
            neg
.dc:
            ld      d, a
            ld      a, (draught_row)
            sub     b
            jp      p, .dr
            neg
.dr:
            add     a, d
            ret

"""

SCAN = """\
            ; the lamplighter's flame is the first candidate...
            ld      a, (lamp_col)
            ld      c, a
            ld      (seek_col), a
            ld      a, (lamp_row)
            ld      b, a
            ld      (seek_row), a
            call    manhattan
            ld      (seek_best), a

            ; ...then every lit lamp, keeping the nearest. The lamp table
            ; names the candidates; the SCREEN says which are lit — the
            ; same attribute truth the collision system reads.
            ld      hl, lamp_data
.scan:
            ld      a, (hl)
            cp      $FF
            jr      z, .chase
            ld      c, a
            inc     hl
            ld      b, (hl)
            inc     hl
            push    hl
            push    bc
            call    attr_addr_cr
            ld      a, (hl)
            pop     bc
            cp      LAMP_LIT
            jr      nz, .dnext      ; unlit lamps cast no light
            call    manhattan
            ld      hl, seek_best
            cp      (hl)
            jr      nc, .dnext      ; not nearer — keep the current prey
            ld      (hl), a
            ld      a, c
            ld      (seek_col), a
            ld      a, b
            ld      (seek_row), a
.dnext:
            pop     hl
            jr      .scan
"""

SNUFF = """\
            ; the snuff: while the wisp covers a lit lamp, the lamp's
            ; truth is ITS buffer — the same saved-under rule that lights
            ; lamps beneath the lamplighter, run by the villain. Rewrite
            ; the saved attribute to cold, and the wisp's own restore
            ; will leave the lamp out as it moves on.
            ld      a, (under_draught + 8)
            cp      LAMP_LIT
            jr      nz, .nosnuff
            ld      a, LAMP_UNLIT
            ld      (under_draught + 8), a
            call    unlight_pip
            call    warm_walls
.nosnuff:
"""

UNLIGHT_PIP = """\

; unlight_pip — light_pip's mirror: step the count back and cool the
; pip at the new count. The tally can go DOWN now.
unlight_pip:
            ld      a, (lit_count)
            dec     a
            ld      (lit_count), a
            ld      e, a
            ld      d, 0
            ld      hl, PIP_BASE
            add     hl, de
            ld      (hl), PIP_UNLIT
            ret
"""


def unit_01() -> dict[str, str]:
    t = header(1, "The Dark Seeks the Light",
               "Targeting generalises: nearest light — and your flame counts.", C0)
    s00 = t

    # step 1 — the nearest-light hunt
    t = swap(t,
             "; draught_step — the hunt. One rule: step one cell along the axis with\n"
             "; the greater distance to the lamplighter (ties go sideways). No walls,\n"
             "; no vetoes — the wisp is not of the town, and stone means nothing to it.",
             "; draught_step — the hunt, generalised. The wisp steps toward the\n"
             "; NEAREST LIGHT: a lit lamp, or the lamplighter's own flame. Same\n"
             "; chase, new prey — and still no walls, no vetoes on the way.")
    t = swap(t,
             DASH + "\n; draught_step",
             MANHATTAN + DASH + "\n; draught_step")
    t = swap(t,
             "            ; the dark hunts the lamplighter's own flame\n"
             "            ld      a, (lamp_col)\n"
             "            ld      (seek_col), a\n"
             "            ld      a, (lamp_row)\n"
             "            ld      (seek_row), a\n",
             SCAN)
    t = swap(t,
             "seek_row:\n"
             "            defb    0\n",
             "seek_row:\n"
             "            defb    0\n"
             "seek_best:\n"
             "            defb    0               ; the nearest distance found so far\n")
    s01 = t

    # step 2 — the snuff, silent
    t = swap(t,
             "            ld      a, (dtrow)\n"
             "            ld      (draught_row), a\n"
             "            call    save_draught\n"
             "            call    draw_draught\n"
             "            ret\n",
             "            ld      a, (dtrow)\n"
             "            ld      (draught_row), a\n"
             "            call    save_draught\n"
             + SNUFF +
             "            call    draw_draught\n"
             "            ret\n")
    t = swap(t,
             "; light_pip / draw_pips / draw_lives.",
             "; light_pip / unlight_pip / draw_pips / draw_lives.")
    t = swap(t,
             "            ld      (hl), PIP_LIT\n"
             "            ret\n",
             "            ld      (hl), PIP_LIT\n"
             "            ret\n" + UNLIGHT_PIP)
    s02 = t

    return {"step-00": s00, "step-01": s01, "step-02": s02}


# ==========================================================================
# UNIT 2 — It Carries Its Prize Home
# ==========================================================================

WITHDRAW_S1 = """\
            ; withdrawing? after a snuff the night carries its prize
            ; home before hunting again — behaviour is a MODE now, and
            ; the mode decides what this beat means
            ld      a, (draught_mode)
            or      a
            jr      z, .hunt
            ld      a, (draught_home_col)
            ld      hl, draught_col
            cp      (hl)
            jr      nz, .whome
            ld      a, (draught_home_row)
            ld      hl, draught_row
            cp      (hl)
            jr      nz, .whome
            xor     a                   ; home — the hunt resumes at once
            ld      (draught_mode), a
            ld      a, DRAUGHT_SPEED
            ld      (draught_timer), a
            ret
.whome:
            ld      a, (draught_home_col)\n\
            ld      (seek_col), a
            ld      a, (draught_home_row)
            ld      (seek_row), a
            jp      .chase
.hunt:
"""


def unit_02(prev: str) -> dict[str, str]:
    t = header(2, "It Carries Its Prize Home",
               "Behaviour needs rhythm, not just rules: hunt, snuff, withdraw, rest.", prev)
    s00 = t

    # step 1 — the mode flag: withdraw home with the prize
    t = swap(t,
             "            ; --- and, in the far corner, something else ---\n"
             "            ld      a, DRAUGHT_COL0\n"
             "            ld      (draught_col), a\n"
             "            ld      a, DRAUGHT_ROW0\n"
             "            ld      (draught_row), a\n",
             "            ; --- and, in the far corner, something else ---\n"
             "            ld      a, DRAUGHT_COL0\n"
             "            ld      (draught_col), a\n"
             "            ld      (draught_home_col), a   ; and remember where home is —\n"
             "            ld      a, DRAUGHT_ROW0\n"
             "            ld      (draught_row), a\n"
             "            ld      (draught_home_row), a   ; the withdraw will need it\n")
    t = swap(t,
             "            ld      a, GATHER\n"
             "            ld      (draught_timer), a\n"
             "            xor     a\n"
             "            ld      (player_timer), a\n",
             "            ld      a, GATHER\n"
             "            ld      (draught_timer), a\n"
             "            xor     a\n"
             "            ld      (player_timer), a\n"
             "            ld      (draught_mode), a\n")
    t = swap(t,
             "            ld      a, DRAUGHT_SPEED\n"
             "            ld      (draught_timer), a\n"
             "\n"
             "            ; the lamplighter's flame is the first candidate...",
             "            ld      a, DRAUGHT_SPEED\n"
             "            ld      (draught_timer), a\n"
             "\n"
             + WITHDRAW_S1 +
             "            ; the lamplighter's flame is the first candidate...")
    t = swap(t,
             "            call    warm_walls\n"
             ".nosnuff:",
             "            call    warm_walls\n"
             "            ld      a, 1                ; the prize is taken — withdraw\n"
             "            ld      (draught_mode), a\n"
             ".nosnuff:")
    t = swap(t,
             "            call    restore_draught\n"
             "            ld      a, DRAUGHT_COL0\n"
             "            ld      (draught_col), a\n"
             "            ld      a, DRAUGHT_ROW0\n"
             "            ld      (draught_row), a\n"
             "            ld      a, DRAUGHT_SPEED\n"
             "            ld      (draught_timer), a\n",
             "            call    restore_draught\n"
             "            ld      a, (draught_home_col)\n"
             "            ld      (draught_col), a\n"
             "            ld      a, (draught_home_row)\n"
             "            ld      (draught_row), a\n"
             "            ld      a, DRAUGHT_SPEED\n"
             "            ld      (draught_timer), a\n"
             "            xor     a                   ; already home — hunt on arrival\n"
             "            ld      (draught_mode), a\n")
    t = swap(t,
             "draught_row:\n"
             "            defb    4\n",
             "draught_row:\n"
             "            defb    4\n"
             "draught_home_col:\n"
             "            defb    28\n"
             "draught_home_row:\n"
             "            defb    4\n"
             "draught_mode:\n"
             "            defb    0               ; 0 = hunting, 1 = withdrawing home\n")
    s01 = t

    # step 2 — the rest: the snuff window holds even when home is close
    t = swap(t,
             "GATHER      equ     120             ; frames the dark gathers before its first step\n",
             "GATHER      equ     120             ; frames the dark gathers before its first step\n"
             "WREST       equ     48              ; frames it rests at home after a withdrawal —\n"
             "                                    ; the snuff window holds even when home is close\n")
    t = swap(t,
             "            xor     a                   ; home — the hunt resumes at once\n"
             "            ld      (draught_mode), a\n"
             "            ld      a, DRAUGHT_SPEED\n"
             "            ld      (draught_timer), a\n"
             "            ret\n",
             "            xor     a                   ; home — rest, then the hunt resumes\n"
             "            ld      (draught_mode), a\n"
             "            ld      a, WREST\n"
             "            ld      (draught_timer), a\n"
             "            ret\n")
    s02 = t

    return {"step-00": s00, "step-01": s01, "step-02": s02}


# ==========================================================================
# UNIT 3 — The Pools of Light
# ==========================================================================

POOLS_CORE = """\
; ----------------------------------------------------------------------------
; recompute_pools — the lamps cast their light. Every glow cell dies
; back to bare cobble, then every LIT lamp warms its eight neighbours.
; Derived, not tracked: called after any light or snuff, it rebuilds
; the whole layer from lamp truth, so the pools can never drift.
; ----------------------------------------------------------------------------
recompute_pools:
            ld      hl, $5820           ; rows 1-23 (row 0 is the HUD)
            ld      bc, 736
.rp1:
            ld      a, (hl)
            cp      GLOW
            jr      nz, .rp1n
            ld      (hl), COBBLE
.rp1n:
            inc     hl
            dec     bc
            ld      a, b
            or      c
            jr      nz, .rp1
            ld      hl, lamp_data
.rp2:
            ld      a, (hl)
            cp      $FF
            jr      z, .rpdone
            ld      c, a
            inc     hl
            ld      b, (hl)
            inc     hl
            push    hl
            push    bc
            call    attr_addr_cr
            ld      a, (hl)
            pop     bc
            cp      LAMP_LIT
            jr      nz, .rp2n
            call    glow_ring
.rp2n:
            pop     hl
            jr      .rp2
.rpdone:
            ret

; glow_ring — warm the eight cells around lamp (C = col, B = row) where
; they are bare cobble. Pools never take walls, posts, or the dark.
glow_ring:
            ld      hl, ring_offsets
            ld      e, 8
.gr:
            push    hl
            push    de
            push    bc
            ld      a, (hl)
            add     a, c
            ld      c, a
            inc     hl
            ld      a, (hl)
            add     a, b
            ld      b, a
            call    attr_addr_cr
            ld      a, (hl)
            cp      COBBLE
            jr      nz, .grn
            ld      (hl), GLOW
.grn:
            pop     bc
            pop     de
            pop     hl
            inc     hl
            inc     hl
            dec     e
            jr      nz, .gr
            ret

ring_offsets:
            defb    -1, -1,  0, -1,  1, -1
            defb    -1,  0,          1,  0
            defb    -1,  1,  0,  1,  1,  1

"""


def unit_03(prev: str) -> dict[str, str]:
    t = header(3, "The Pools of Light",
               "Claimed ground: a lit lamp warms its eight neighbours.", prev)
    s00 = t

    # step 1 — pools, recomputed from lamp truth (no mover discipline yet)
    t = swap(t,
             "COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground\n",
             "COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground\n"
             "GLOW        equ     %00000110       ; pool-warmed cobble: yellow INK on black —\n"
             "                                    ; ground the light holds\n")
    t = swap(t,
             DASH + "\n; manhattan",
             POOLS_CORE + DASH + "\n; manhattan")
    t = swap(t,
             "            call    light_pip\n"
             "            call    blip_lit\n"
             "            call    warm_walls\n",
             "            call    light_pip\n"
             "            call    blip_lit\n"
             "            call    warm_walls\n"
             "            call    recompute_pools\n")
    t = swap(t,
             "            call    unlight_pip\n"
             "            call    warm_walls\n",
             "            call    unlight_pip\n"
             "            call    warm_walls\n"
             "            call    recompute_pools\n")
    s01 = t

    # step 2 — the restore-both-movers discipline
    t = swap(t,
             "recompute_pools:\n"
             "            ld      hl, $5820           ; rows 1-23 (row 0 is the HUD)\n",
             "recompute_pools:\n"
             "            ; the discipline: both movers OFF the screen first, so the\n"
             "            ; recolour reads and writes true ground — never a sprite,\n"
             "            ; and never into a buffer that would restore stale colour\n"
             "            call    restore_under\n"
             "            call    restore_draught\n"
             "            ld      hl, $5820           ; rows 1-23 (row 0 is the HUD)\n")
    t = swap(t,
             ".rpdone:\n"
             "            ret\n",
             ".rpdone:\n"
             "            ; ...and back on, their buffers re-photographing ground\n"
             "            ; that now includes the glow\n"
             "            call    save_under\n"
             "            call    save_draught\n"
             "            call    draw_lamp\n"
             "            call    draw_draught\n"
             "            ret\n")
    s02 = t

    return {"step-00": s00, "step-01": s01, "step-02": s02}


# ==========================================================================
# UNIT 4 — The Tendril
# ==========================================================================

TAKE_BLOCK = """\
            ; the tendril: night pools where the wisp has walked. Ground
            ; and spilt light are both taken; posts and stone are not.
            ld      a, (draught_col)
            ld      c, a
            ld      a, (draught_row)
            ld      b, a
            push    bc
            call    attr_addr_cr
            pop     bc
            ld      a, (hl)
            cp      DARK
            jr      z, .retake
            cp      COBBLE
            jr      z, .take
            cp      GLOW
            jr      nz, .notake
.take:
            ld      (hl), DARK
            ld      de, mist_tex
            call    blit_tex
.retake:
            call    tendril_push
.notake:
"""

PUSH_HEAD = """\
; ----------------------------------------------------------------------------
; tendril_push — record darkened cell (C = col, B = row) in the tendril
; ring. When the ring is full the oldest cell releases back to bare
; cobble first — the night cannot hold ground beyond its reach, so the
; tendril can never permanently wall the square off.
; ----------------------------------------------------------------------------
tendril_push:
            ld      a, (tendril_len)
            ld      hl, tendril_max
            cp      (hl)
            jr      c, .tgrow
            ; full: release the oldest cell (the slot head points at)
            push    bc
            ld      a, (tendril_head)
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, tendril_buf
            add     hl, de
            ld      c, (hl)
            inc     hl
            ld      b, (hl)
"""

PUSH_TAIL = """\
.tgrow:
            inc     a
            ld      (tendril_len), a
.tstore:
            ld      a, (tendril_head)
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, tendril_buf
            add     hl, de
            ld      (hl), c
            inc     hl
            ld      (hl), b
            ld      a, (tendril_head)
            inc     a
            ld      hl, tendril_max
            cp      (hl)
            jr      c, .tadv
            xor     a
.tadv:
            ld      (tendril_head), a
            ret

"""

RELEASE_NAIVE = """\
            push    bc
            call    attr_addr_cr
            pop     bc
            ld      (hl), COBBLE
            ld      de, cobble_tex
            call    blit_tex
            pop     bc
            jr      .tstore
"""

RELEASE_CLAIMED = """\
            ; a newer ring entry may still claim this cell (the wisp
            ; re-walks its own trail) — then the night keeps it
            call    tendril_claimed
            jr      z, .treld
            ; if the wisp itself is crossing that cell, mend its saved
            ; ground instead of the screen — its buffer holds that cell
            ; while it stands there, and the buffer is the truth
            ld      a, (draught_col)
            cp      c
            jr      nz, .trel
            ld      a, (draught_row)
            cp      b
            jr      nz, .trel
            push    bc
            ld      hl, cobble_tex
            ld      de, under_draught
            ld      bc, 8
            ldir
            pop     bc
            ld      a, COBBLE
            ld      (under_draught + 8), a
            jr      .treld
.trel:
            push    bc
            call    attr_addr_cr
            pop     bc
            ld      a, (hl)
            cp      DARK
            jr      nz, .treld
            ld      (hl), COBBLE
            ld      de, cobble_tex
            call    blit_tex
.treld:
            pop     bc
            jr      .tstore
"""

RELEASE_FINAL = """\
            ; a newer ring entry may still claim this cell (the wisp
            ; re-walks its own trail) — then the night keeps it
            call    tendril_claimed
            jr      z, .treld
            ; if the wisp itself is crossing that cell, mend its saved
            ; ground instead of the screen
            ld      a, (draught_col)
            cp      c
            jr      nz, .trel
            ld      a, (draught_row)
            cp      b
            jr      nz, .trel
            ; mend the wisp's saved ground: stipple, and glow if a lit
            ; lamp still pools this cell — the light heals behind the dark
            push    bc
            ld      hl, cobble_tex
            ld      de, under_draught
            ld      bc, 8
            ldir
            pop     bc
            call    pooled_at
            ld      a, COBBLE
            jr      nz, .tsetu
            ld      a, GLOW
.tsetu:
            ld      (under_draught + 8), a
            jr      .treld
.trel:
            push    bc
            call    attr_addr_cr
            pop     bc
            ld      a, (hl)
            cp      DARK
            jr      nz, .treld
            push    hl
            call    pooled_at
            pop     hl
            ld      a, COBBLE
            jr      nz, .tset
            ld      a, GLOW
.tset:
            ld      (hl), a
            ld      de, cobble_tex
            call    blit_tex
.treld:
            pop     bc
            jr      .tstore
"""

CLAIMED = """\
; ----------------------------------------------------------------------------
; tendril_claimed — does any ring slot other than head hold (C, B)?
; Z set if claimed. Only called with the ring full, so every slot holds
; a real cell.
; ----------------------------------------------------------------------------
tendril_claimed:
            ld      hl, tendril_buf
            ld      e, 0
.tc:
            ld      a, (tendril_head)
            cp      e
            jr      z, .tcn             ; the slot being released — skip
            ld      a, (hl)
            cp      c
            jr      nz, .tcn
            inc     hl
            ld      a, (hl)
            dec     hl
            cp      b
            jr      nz, .tcn
            xor     a                   ; Z — a newer claim holds it
            ret
.tcn:
            inc     hl
            inc     hl
            inc     e
            ld      a, (tendril_max)
            cp      e
            jr      nz, .tc
            or      a                   ; NZ (max is never 0) — free
            ret

"""

POOLED_AT = """\
; ----------------------------------------------------------------------------
; pooled_at — is cell (C, B) within one cell of a LIT lamp? Z if so.
; The light heals: released tendril ground inside a live pool returns
; to glow, not bare cobble.
; ----------------------------------------------------------------------------
pooled_at:
            ld      hl, lamp_data
.pa:
            ld      a, (hl)
            cp      $FF
            jr      z, .pano
            ld      e, a                ; lamp col
            inc     hl
            ld      d, (hl)             ; lamp row
            inc     hl
            ld      a, e
            sub     c
            jp      p, .pac
            neg
.pac:
            cp      2
            jr      nc, .pa
            ld      a, d
            sub     b
            jp      p, .par
            neg
.par:
            cp      2
            jr      nc, .pa
            push    hl
            push    bc
            ld      c, e
            ld      b, d
            call    attr_addr_cr
            ld      a, (hl)
            pop     bc
            pop     hl
            cp      LAMP_LIT
            jr      nz, .pa
            xor     a                   ; Z — pooled by a lit lamp
            ret
.pano:
            or      1                   ; NZ — bare ground
            ret

"""


def unit_04(prev: str) -> dict[str, str]:
    t = header(4, "The Tendril",
               "The night takes territory: a ring buffer of darkness.", prev)
    s00 = t

    # step 1 — the take, the solid dark, and a naive fixed-length release
    t = swap(t,
             "GLOW        equ     %00000110       ; pool-warmed cobble: yellow INK on black —\n"
             "                                    ; ground the light holds\n",
             "GLOW        equ     %00000110       ; pool-warmed cobble: yellow INK on black —\n"
             "                                    ; ground the light holds\n"
             "DARK        equ     %01000001       ; the night made solid: blue INK on black,\n"
             "                                    ; BRIGHT — impassable, unmistakably there\n")
    t = swap(t,
             "            defb    %00010000\n"
             "            defb    %00000000\n"
             "\n"
             "brick_tex:",
             "            defb    %00010000\n"
             "            defb    %00000000\n"
             "\n"
             "mist_tex:\n"
             "            ; the solid night — dense, swirling, unmistakably *there*\n"
             "            defb    %01101100\n"
             "            defb    %11011011\n"
             "            defb    %00110110\n"
             "            defb    %01101101\n"
             "            defb    %11011010\n"
             "            defb    %10110110\n"
             "            defb    %01101011\n"
             "            defb    %11010110\n"
             "\n"
             "brick_tex:")
    t = swap(t,
             "            call    wall_at\n"
             "            ret     nz\n"
             "\n"
             "            ; and the mirror rule:",
             "            call    wall_at\n"
             "            ret     nz\n"
             "            ; the solid night blocks too — you cannot walk into the dark\n"
             "            ld      a, (hl)\n"
             "            cp      DARK\n"
             "            ret     z\n"
             "\n"
             "            ; and the mirror rule:")
    t = swap(t,
             ".dmove:\n"
             "            call    restore_draught\n",
             ".dmove:\n"
             "            call    restore_draught\n"
             + TAKE_BLOCK)
    t = swap(t,
             "\n; paint_buildings — walk the rectangle table",
             "\n" + PUSH_HEAD + RELEASE_NAIVE + PUSH_TAIL
             + "; paint_buildings — walk the rectangle table")
    t = swap(t,
             "lit_qcount:\n"
             "            defb    0\n",
             "lit_qcount:\n"
             "            defb    0\n") if False else t
    t = swap(t,
             "seek_best:\n"
             "            defb    0               ; the nearest distance found so far\n",
             "seek_best:\n"
             "            defb    0               ; the nearest distance found so far\n"
             "tendril_head:\n"
             "            defb    0\n"
             "tendril_len:\n"
             "            defb    0\n"
             "tendril_max:\n"
             "            defb    6               ; the night's reach — six cells of held ground\n"
             "tendril_buf:\n"
             "            defb    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0\n"
             "            defb    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0\n")
    t = swap(t,
             "            ld      (player_timer), a\n"
             "            ld      (draught_mode), a\n",
             "            ld      (player_timer), a\n"
             "            ld      (tendril_len), a\n"
             "            ld      (tendril_head), a\n"
             "            ld      (draught_mode), a\n")
    s01 = t

    # step 2 — no gaps in the night: the claim scan, and the crossing mend
    t = swap(t, RELEASE_NAIVE, RELEASE_CLAIMED)
    t = swap(t,
             DASH + "\n; lose_life",
             CLAIMED + DASH + "\n; lose_life")
    s02 = t

    # step 3 — the light heals: released ground inside a live pool glows
    t = swap(t, RELEASE_CLAIMED, RELEASE_FINAL)
    t = swap(t,
             DASH + "\n; lose_life",
             POOLED_AT + DASH + "\n; lose_life")
    s03 = t

    return {"step-00": s00, "step-01": s01, "step-02": s02, "step-03": s03}


# ==========================================================================
# UNIT 5 — The Night Bears Grudges
# ==========================================================================

QUEUE_ROUTINES = """\
; ----------------------------------------------------------------------------
; lamp_index_at — which lamp_data entry sits at (C = col, B = row)?
; Returns the index in A ($FF if none — callers only ask about cells
; they know hold a lamp).
; ----------------------------------------------------------------------------
lamp_index_at:
            ld      hl, lamp_data
            ld      e, 0
.lia:
            ld      a, (hl)
            cp      $FF
            ret     z
            cp      c
            jr      nz, .lian
            inc     hl
            ld      a, (hl)
            dec     hl
            cp      b
            jr      nz, .lian
            ld      a, e
            ret
.lian:
            inc     hl
            inc     hl
            inc     e
            jr      .lia

; lit_push — append lamp index (A) to the lit-order queue.
lit_push:
            ld      e, a
            ld      a, (lit_qcount)
            ld      d, a
            inc     a
            ld      (lit_qcount), a
            ld      a, d
            ld      hl, lit_queue
            add     a, l
            ld      l, a
            jr      nc, .lp
            inc     h
.lp:
            ld      (hl), e
            ret

; lit_remove — take lamp index (A) out of the lit-order queue,
; closing the gap.
lit_remove:
            ld      e, a
            ld      hl, lit_queue
            ld      a, (lit_qcount)
            ld      d, a
            or      a
            ret     z
.lr:
            ld      a, (hl)
            cp      e
            jr      z, .lrfound
            inc     hl
            dec     d
            jr      nz, .lr
            ret
.lrfound:
            dec     d
            jr      z, .lrlast
.lrshift:
            inc     hl
            ld      a, (hl)
            dec     hl
            ld      (hl), a
            inc     hl
            dec     d
            jr      nz, .lrshift
.lrlast:
            ld      a, (lit_qcount)
            dec     a
            ld      (lit_qcount), a
            ret

"""

OLDEST = """\
            ; the oldest flame is the night's grievance — it reclaims
            ; the ground it lost first. With nothing lit, it hunts the
            ; lamplighter's own flame: light your first lamp and the
            ; hunt turns away from you.
            ld      a, (lit_qcount)
            or      a
            jr      nz, .oldest
            ld      a, (lamp_col)
            ld      (seek_col), a
            ld      a, (lamp_row)
            ld      (seek_row), a
            jr      .chase
.oldest:
            ld      a, (lit_queue)
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, lamp_data
            add     hl, de
            ld      a, (hl)
            ld      (seek_col), a
            inc     hl
            ld      a, (hl)
            ld      (seek_row), a
"""


def unit_05(prev: str) -> dict[str, str]:
    t = header(5, "The Night Bears Grudges",
               "The eraser problem: the queue hunts the oldest flame, not the nearest.", prev)
    s00 = t

    # step 1 — the whole swap: greedy-nearest retires, the ledger arrives
    t = swap(t,
             "            ld      (tendril_head), a\n"
             "            ld      (draught_mode), a\n",
             "            ld      (tendril_head), a\n"
             "            ld      (draught_mode), a\n"
             "            ld      (lit_qcount), a\n")
    t = swap(t,
             "            ld      (under_lamp + 8), a\n"
             "            call    light_pip\n",
             "            ld      (under_lamp + 8), a\n"
             "            ; record the lighting order — the night bears its grudges\n"
             "            ; oldest-first (lamp_col/lamp_row are the lamplighter's\n"
             "            ; position, and he is standing on the lamp)\n"
             "            ld      a, (lamp_col)\n"
             "            ld      c, a\n"
             "            ld      a, (lamp_row)\n"
             "            ld      b, a\n"
             "            call    lamp_index_at\n"
             "            call    lit_push\n"
             "            call    light_pip\n")
    t = swap(t, MANHATTAN, QUEUE_ROUTINES)
    t = swap(t, SCAN, OLDEST)
    # the banner keeps up with the rule (the real prototype's never did —
    # its comment promised "nearest" long after round 12; the unit's page
    # tells that story)
    t = swap(t,
             "; draught_step — the hunt, generalised. The wisp steps toward the\n"
             "; NEAREST LIGHT: a lit lamp, or the lamplighter's own flame. Same\n"
             "; chase, new prey — and still no walls, no vetoes on the way.",
             "; draught_step — the hunt bears grudges. The wisp steps toward the\n"
             "; OLDEST grievance: the head of the lit-order queue, or, with\n"
             "; nothing lit, the lamplighter's own flame. Still no walls.")
    t = swap(t,
             "            ld      (under_draught + 8), a\n"
             "            call    unlight_pip\n",
             "            ld      (under_draught + 8), a\n"
             "            ; the grievance is settled — off the lit-order queue\n"
             "            ld      a, (draught_col)\n"
             "            ld      c, a\n"
             "            ld      a, (draught_row)\n"
             "            ld      b, a\n"
             "            call    lamp_index_at\n"
             "            call    lit_remove\n"
             "            call    unlight_pip\n")
    t = swap(t,
             "seek_best:\n"
             "            defb    0               ; the nearest distance found so far\n",
             "lit_queue:\n"
             "            defb    0, 0, 0, 0, 0, 0, 0, 0\n"
             "lit_qcount:\n"
             "            defb    0\n")
    s01 = t

    return {"step-00": s00, "step-01": s01}


# ==========================================================================
# UNIT 6 — The Night Deepens
# ==========================================================================

def unit_06(prev: str) -> dict[str, str]:
    t = header(6, "The Night Deepens",
               "Escalation as data — and the held screen becomes an interstitial.", prev)
    s00 = t

    # step 1 — a run of watches: the split, the interstitial, lives that carry
    t = swap(t,
             "STATE_WIN   equ     2               ; the night is held — the game is won",
             "STATE_WIN   equ     2               ; a dusk held — the night deepens")
    t = swap(t, "            call    init_game\n"
                "            ld      a, STATE_PLAY\n",
                "            call    init_run\n"
                "            ld      a, STATE_PLAY\n")
    t = swap(t,
             "; end_step — WIN or LOSE: SPACE returns to the title.",
             "; end_step — after the lock, SPACE moves on. A held dusk continues\n"
             "; the run — the night deepens; only NIGHT FALLS returns to the title.")
    t = swap(t,
             "            ret     nz\n"
             "            call    draw_title_screen\n",
             "            ret     nz\n"
             "            ld      a, (game_state)\n"
             "            cp      STATE_WIN\n"
             "            jr      z, .deeper\n"
             "            call    draw_title_screen\n")
    t = swap(t,
             "            ld      a, STATE_TITLE\n"
             "            ld      (game_state), a\n"
             "            ret\n",
             "            ld      a, STATE_TITLE\n"
             "            ld      (game_state), a\n"
             "            ret\n"
             ".deeper:\n"
             "            ; the dusk was held — the night is NOT over. Deepen and\n"
             "            ; go again: the square relights, and the lives carry.\n"
             "            ld      hl, dusk\n"
             "            inc     (hl)\n"
             "            call    init_game\n"
             "            ld      a, STATE_PLAY\n"
             "            ld      (game_state), a\n"
             "            ret\n")
    t = swap(t,
             DASH + "\n"
             "; init_game — everything a fresh night needs, gathered from what was\n"
             "; the boot sequence. Beginning is a callable thing now.\n"
             + DASH + "\n"
             "init_game:\n"
             "            xor     a\n"
             "            ld      (lit_count), a\n"
             "            ld      a, LIVES\n"
             "            ld      (lives), a\n",
             DASH + "\n"
             "; init_run / init_game — a run is a NIGHT now: dusk 0, full lives.\n"
             "; Each held dusk re-enters init_game with dusk bumped — the square\n"
             "; relights, the lives carry. What resets per RUN and what resets per\n"
             "; WATCH is the whole design decision, drawn as two entry points.\n"
             + DASH + "\n"
             "init_run:\n"
             "            xor     a\n"
             "            ld      (dusk), a\n"
             "            ld      a, LIVES\n"
             "            ld      (lives), a\n"
             "            ; fall through into the per-dusk setup\n"
             "\n"
             "init_game:\n"
             "            xor     a\n"
             "            ld      (lit_count), a\n")
    t = swap(t,
             "player_timer:\n"
             "            defb    0\n",
             "player_timer:\n"
             "            defb    0\n"
             "dusk:\n"
             "            defb    0               ; which watch of the night this is\n")
    s01 = t

    # step 2 — escalation as data: pace and reach tables, a corner per watch
    t = swap(t,
             "DRAUGHT_SPEED equ   16              ; frames between the wisp's steps\n"
             "DRAUGHT_COL0  equ   28              ; the corner the dark enters from\n"
             "DRAUGHT_ROW0  equ   4\n",
             "NUM_DUSKS     equ   5               ; five watches of night — the tables\n"
             "                                    ; below give each watch its teeth\n")
    t = swap(t,
             "            ; --- and, in the far corner, something else ---\n"
             "            ld      a, DRAUGHT_COL0\n"
             "            ld      (draught_col), a\n"
             "            ld      (draught_home_col), a   ; and remember where home is —\n"
             "            ld      a, DRAUGHT_ROW0\n"
             "            ld      (draught_row), a\n"
             "            ld      (draught_home_row), a   ; the withdraw will need it\n",
             "            ; the dark probes from a new quarter each watch —\n"
             "            ; a lesson the square teaches by ITSELF: watch 2 already\n"
             "            ; feels different before anything else has changed\n"
             "            ld      a, (dusk)\n"
             "            and     3\n"
             "            add     a, a\n"
             "            ld      e, a\n"
             "            ld      d, 0\n"
             "            ld      hl, corner_tab\n"
             "            add     hl, de\n"
             "            ld      a, (hl)\n"
             "            ld      (draught_col), a\n"
             "            ld      (draught_home_col), a\n"
             "            inc     hl\n"
             "            ld      a, (hl)\n"
             "            ld      (draught_row), a\n"
             "            ld      (draught_home_row), a\n")
    t = swap(t,
             "            ; the dark gathers before its first step — a beat to read\n"
             "            ; the square before the hunt begins\n"
             "            ld      a, GATHER\n"
             "            ld      (draught_timer), a\n",
             "            ; the night deepens: the wisp's pace comes from the dusk\n"
             "            ; table, deeper dusks holding the last entry\n"
             "            ld      a, (dusk)\n"
             "            cp      NUM_DUSKS\n"
             "            jr      c, .dpace\n"
             "            ld      a, NUM_DUSKS - 1\n"
             ".dpace:\n"
             "            ld      e, a\n"
             "            ld      d, 0\n"
             "            ld      hl, dusk_table\n"
             "            add     hl, de\n"
             "            ld      a, (hl)\n"
             "            ld      (dusk_speed), a\n"
             "            ; ...but it gathers before the first step — a beat to read\n"
             "            ; the square before the hunt begins\n"
             "            ld      a, GATHER\n"
             "            ld      (draught_timer), a\n"
             "            ; the tendril reaches further as the night deepens\n"
             "            ld      hl, dusk_lentab\n"
             "            add     hl, de\n"
             "            ld      a, (hl)\n"
             "            ld      (tendril_max), a\n")
    t = swap(t, "            ld      a, DRAUGHT_SPEED\n",
                "            ld      a, (dusk_speed)\n", n=2)
    t = swap(t,
             "            defb    $FF\n"
             "\n"
             + DASH + "\n; tendril_claimed",
             "            defb    $FF\n"
             "\n"
             "corner_tab:\n"
             "            ; where the dark enters, per watch (NE, SE, SW, NW)\n"
             "            defb    28, 4\n"
             "            defb    28, 19\n"
             "            defb    3, 19\n"
             "            defb    3, 4\n"
             "\n"
             + DASH + "\n; tendril_claimed")
    t = swap(t,
             "input_lock:\n"
             "            defb    0\n",
             "input_lock:\n"
             "            defb    0\n"
             "\n"
             "dusk_table:\n"
             "            ; the wisp's pace per dusk (frames between steps) — the\n"
             "            ; night deepens as data, not code. Dusk 1 is gentle on\n"
             "            ; purpose: the hunt must be readable before it's a threat.\n"
             "            ; The final watch is pace 9, not 8 — playtested: 8 is the\n"
             "            ; human wall, 9 is beatable. The last watch should be the\n"
             "            ; climax, not the ceiling.\n"
             "            defb    16, 13, 11, 9, 9\n"
             "\n"
             "dusk_lentab:\n"
             "            ; the tendril's reach per watch (cells of night held) —\n"
             "            ; the second axis of the deepening. Front-loading reach\n"
             "            ; made watch 1 brutal (playtested: a practised player lost\n"
             "            ; at watch 2) — the opening teaches the mechanic, the deep\n"
             "            ; watches punish with it.\n"
             "            defb    3, 6, 9, 13, 18\n")
    t = swap(t,
             "dusk:\n"
             "            defb    0               ; which watch of the night this is\n",
             "dusk:\n"
             "            defb    0               ; which watch of the night this is\n"
             "dusk_speed:\n"
             "            defb    16\n")
    s02 = t

    # step 3 — the carried lives: the ledger must read memory
    t = swap(t,
             "; draw_lives — three embers on the ledge's right shoulder.\n"
             "draw_lives:\n"
             "            ld      hl, LIFE_BASE\n"
             "            ld      b, LIVES\n"
             "            ld      a, LIFE_PIP\n",
             "; draw_lives — the embers on the ledge's right shoulder. Read the\n"
             "; CARRIED lives, not the constant: a run's lives survive the watches\n"
             "; now, and the ledge must say so. (The constant version repainted\n"
             "; three every watch — a lie we only caught while taking this game\n"
             "; apart for this module. Playtests read the square; nobody read the\n"
             "; ledger across a watch boundary.)\n"
             "draw_lives:\n"
             "            ld      hl, LIFE_BASE\n"
             "            ld      a, (lives)\n"
             "            ld      b, a\n"
             "            ld      a, LIFE_PIP\n")
    s03 = t

    return {"step-00": s00, "step-01": s01, "step-02": s02, "step-03": s03}


# ==========================================================================
# UNIT 7 — Dawn Breaks
# ==========================================================================

DAWN_SWEEP = """\
; ----------------------------------------------------------------------------
; dawn_sweep — morning enters from the sky: row by row the ground
; warms to gold and the night's mist burns off (dark cells get their
; stipple back). Walls, lamps, text, and the two figures are left to
; the palettes they already wear. Blocking, like the fanfare — the
; ending is allowed a second of ceremony.
; ----------------------------------------------------------------------------
dawn_sweep:
            ld      b, 1
.dsr:
            halt
            halt
            ld      c, 0
.dsc:
            push    bc
            call    attr_addr_cr
            ld      a, (hl)
            cp      DARK
            jr      nz, .dsn1
            pop     bc
            push    bc
            push    hl
            ld      de, cobble_tex
            call    blit_tex
            pop     hl
            jr      .dsset
.dsn1:
            cp      COBBLE
            jr      z, .dsset
            cp      GLOW
            jr      nz, .dsnext
.dsset:
            ld      (hl), GLOW
.dsnext:
            pop     bc
            inc     c
            ld      a, c
            cp      32
            jr      c, .dsc
            inc     b
            ld      a, b
            cp      24
            jr      c, .dsr
            ret

"""


def unit_07(prev: str) -> dict[str, str]:
    t = header(7, "Dawn Breaks",
               "A run needs an ending you can reach: hold the fifth watch and morning comes.", prev)
    s00 = t

    # step 1 — the true ending exists
    t = swap(t,
             "STATE_LOSE  equ     3               ; night falls — the game is lost\n",
             "STATE_LOSE  equ     3               ; night falls — the game is lost\n"
             "STATE_DAWN  equ     4               ; the fifth dusk held — morning,\n"
             "                                    ; the TRUE win\n"
             "DAWN_COL    equ     10              ; centres the eleven characters\n")
    t = swap(t,
             "            cp      NUM_LAMPS\n"
             "            ret     nz\n",
             "            cp      NUM_LAMPS\n"
             "            ret     nz\n"
             "            ; the eighth lamp: is this the last watch of the night?\n"
             "            ld      a, (dusk)\n"
             "            cp      NUM_DUSKS - 1\n"
             "            jr      z, .thedawn\n")
    t = swap(t,
             "            ld      a, STATE_WIN\n"
             "            ld      (game_state), a\n"
             "            ret\n",
             "            ld      a, STATE_WIN\n"
             "            ld      (game_state), a\n"
             "            ret\n"
             ".thedawn:\n"
             "            call    draw_dawn_screen\n"
             "            call    fanfare_held\n"
             "            ld      a, LOCK\n"
             "            ld      (input_lock), a\n"
             "            ld      a, STATE_DAWN\n"
             "            ld      (game_state), a\n"
             "            ret\n")
    t = swap(t,
             "\ndraw_lose_screen:",
             "\n; draw_dawn_screen — the same lift-and-say as the win screen, with\n"
             "; the morning's own words. The square stands as the run left it.\n"
             "draw_dawn_screen:\n"
             "            call    restore_under\n"
             "            ld      hl, dawn_text\n"
             "            ld      b, MSG_ROW\n"
             "            ld      c, DAWN_COL\n"
             "            call    print_string\n"
             "            ld      hl, prompt_text\n"
             "            ld      b, CONT_ROW\n"
             "            ld      c, PROMPT_COL\n"
             "            call    print_string\n"
             "            ret\n"
             "\ndraw_lose_screen:")
    t = swap(t,
             "lose_text:\n"
             "            defb    \"NIGHT FALLS\"\n"
             "            defb    $FF\n",
             "lose_text:\n"
             "            defb    \"NIGHT FALLS\"\n"
             "            defb    $FF\n"
             "\n"
             "dawn_text:\n"
             "            defb    \"DAWN BREAKS\"\n"
             "            defb    $FF\n")
    s01 = t

    # step 2 — the ceremony: morning sweeps in from the sky
    t = swap(t,
             DASH + "\n; lamp_index_at",
             DAWN_SWEEP + DASH + "\n; lamp_index_at")
    t = swap(t,
             "            call    draw_dawn_screen\n"
             "            call    fanfare_held\n",
             "            call    draw_dawn_screen\n"
             "            call    dawn_sweep\n"
             "            call    fanfare_held\n")
    s02 = t

    return {"step-00": s00, "step-01": s01, "step-02": s02}


# ==========================================================================
# UNIT 8 — The Dusk Bells
# ==========================================================================

TUNE = """\
; ----------------------------------------------------------------------------
; The title tune — the dusk bells, one note per STEP. title_step plays
; one step per pass with the SPACE poll between cells: a tune changes
; the input contract of every screen that returns to the title, and
; this shape is the contract being honoured.
; The last step leaves D5 hanging; the wrap back to the toll resolves it.
; ----------------------------------------------------------------------------
title_tune:
            ld      a, (title_music_step)
            ld      b, a                ; the step to play now
            inc     a
            and     7                   ; eight steps, then the toll again
            ld      (title_music_step), a
            ld      a, b
            add     a, a
            ld      hl, .steps
            ld      e, a
            ld      d, 0
            add     hl, de
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            jp      (hl)
.steps:
            defw    .toll_a, .toll_b, .motif_e, .motif_c
            defw    .toll_c, .warm_c, .warm_e, .hang_d
.toll_a:                            ; the toll — cold ground
            ld      b, $84          ; A4
            ld      c, $F7
            call    beep
            ld      b, 10
            jp      title_rest
.toll_b:
            ld      b, $84          ; A4
            ld      c, $F7
            call    beep
            ld      b, 13
            jp      title_rest
.motif_e:                           ; the dusk motif, a lamp far off
            ld      b, $92          ; E5
            ld      c, $A4
            call    beep
            ld      b, 4
            jp      title_rest
.motif_c:
            ld      b, $9D          ; C5
            ld      c, $CF
            call    beep
            ld      b, 13
            jp      title_rest
.toll_c:                            ; the toll returns
            ld      b, $84          ; A4
            ld      c, $F7
            call    beep
            ld      b, 10
            jp      title_rest
.warm_c:                            ; a small warmth kindles
            ld      b, $5E          ; C5
            ld      c, $CF
            call    beep
            ld      b, 3
            jp      title_rest
.warm_e:
            ld      b, $77          ; E5
            ld      c, $A4
            call    beep
            ld      b, 4
            jp      title_rest
.hang_d:                            ; left hanging — leans back into the dark
            ld      b, $EC          ; D5
            ld      c, $B8
            call    beep
            ld      b, 16
            jp      title_rest

"""

REST_DEAF = """\
; title_rest — the tune's silence. For now it is just rest with its own
; name: deaf, counting frames. Play this build and feel what that costs
; the title — a tap that lands inside a long rest is simply gone.
title_rest:
            halt
            djnz    title_rest
            ret

"""

REST_LISTENING = """\
; title_rest — the tune's silence, listening. Same shape as rest, but
; each frame polls SPACE; a press latches title_key_seen and cuts the
; rest short so title_step can act on it next pass. A tap can land
; inside a note now, never inside a rest.
title_rest:
            halt
            push    bc
            ld      bc, KEYS_SPACE
            in      a, (c)
            pop     bc
            bit     0, a
            jr      z, .heard
            djnz    title_rest
            ret
.heard:
            ld      a, 1
            ld      (title_key_seen), a
            ret

"""


def unit_08(prev: str) -> dict[str, str]:
    t = header(8, "The Dusk Bells",
               "A title tune that yields the keyboard — and the snuff finds its voice.", prev)
    s00 = t

    # step 1 — the bells toll (and the one-shot chime retires)
    t = swap(t,
             "            im      1\n"
             "            ei\n"
             "            call    chime_dusk          ; after EI — the rests need the interrupt\n",
             "            im      1\n"
             "            ei                          ; the tune's rests need the interrupt;\n"
             "                                        ; the first toll plays from title_step\n")
    t = swap(t,
             "; title_step — SPACE starts a fresh game.",
             "; title_step — SPACE starts a fresh game. While SPACE is up, one\n"
             "; cell of the title tune plays per pass — the poll sits between\n"
             "; cells, so a keypress waits at most one cell of the dusk bells.")
    t = swap(t,
             ".tready:\n"
             "            ld      bc, KEYS_SPACE\n"
             "            in      a, (c)\n"
             "            bit     0, a\n"
             "            ret     nz\n"
             "            call    init_run\n",
             ".tready:\n"
             "            ld      bc, KEYS_SPACE\n"
             "            in      a, (c)\n"
             "            bit     0, a\n"
             "            jp      nz, title_tune      ; no key — the bells toll on\n"
             "            call    init_run\n")
    t = swap(t,
             "            call    draw_title_screen\n"
             "            call    chime_dusk\n",
             "            call    draw_title_screen\n"
             "            xor     a                   ; the dusk bells start from the toll\n"
             "            ld      (title_music_step), a\n")
    t = swap(t,
             "\nchime_dusk:                         ; two cold tolls, then the motif far off\n"
             "            ld      b, $84          ; A4\n"
             "            ld      c, $F7\n"
             "            call    beep\n"
             "            ld      b, 10\n"
             "            call    rest\n"
             "            ld      b, $84          ; A4\n"
             "            ld      c, $F7\n"
             "            call    beep\n"
             "            ld      b, 13\n"
             "            call    rest\n"
             "            ld      b, $92          ; E5\n"
             "            ld      c, $A4\n"
             "            call    beep\n"
             "            ld      b, 4\n"
             "            call    rest\n"
             "            ld      b, $9D          ; C5\n"
             "            ld      c, $CF\n"
             "            jp      beep\n",
             "")
    t = swap(t,
             "rest:\n"
             "            halt\n"
             "            djnz    rest\n"
             "            ret\n"
             "\n"
             "fanfare_held:",
             "rest:\n"
             "            halt\n"
             "            djnz    rest\n"
             "            ret\n"
             "\n"
             + TUNE + REST_DEAF +
             "fanfare_held:")
    t = swap(t,
             "input_lock:\n"
             "            defb    0\n",
             "input_lock:\n"
             "            defb    0\n"
             "title_music_step:\n"
             "            defb    0               ; which step of the title tune plays next\n")
    s01 = t

    # step 2 — the rests learn to listen
    t = swap(t, REST_DEAF, REST_LISTENING)
    t = swap(t,
             ".tready:\n"
             "            ld      bc, KEYS_SPACE\n"
             "            in      a, (c)\n"
             "            bit     0, a\n"
             "            jp      nz, title_tune      ; no key — the bells toll on\n"
             "            call    init_run\n",
             ".tready:\n"
             "            ld      a, (title_key_seen) ; a press the tune's rests latched\n"
             "            or      a\n"
             "            jr      nz, .tstart\n"
             "            ld      bc, KEYS_SPACE\n"
             "            in      a, (c)\n"
             "            bit     0, a\n"
             "            jp      nz, title_tune      ; no key — the bells toll on\n"
             ".tstart:\n"
             "            xor     a\n"
             "            ld      (title_key_seen), a\n"
             "            call    init_run\n")
    t = swap(t,
             "            xor     a                   ; the dusk bells start from the toll\n"
             "            ld      (title_music_step), a\n",
             "            xor     a                   ; the dusk bells start from the toll\n"
             "            ld      (title_music_step), a\n"
             "            ld      (title_key_seen), a ; and any stale press is forgotten\n")
    t = swap(t,
             "title_music_step:\n"
             "            defb    0               ; which step of the title tune plays next\n",
             "title_music_step:\n"
             "            defb    0               ; which step of the title tune plays next\n"
             "title_key_seen:\n"
             "            defb    0               ; SPACE latched by title_rest mid-tune\n")
    s02 = t

    # step 3 — the snuff finds its voice
    t = swap(t,
             "            ld      c, $51\n"
             "            jp      beep\n",
             "            ld      c, $51\n"
             "            jp      beep\n"
             "\n"
             "blip_snuff:                         ; the third falls, an octave down — cold again\n"
             "            ld      b, $0F          ; E5\n"
             "            ld      c, $A4\n"
             "            call    beep\n"
             "            ld      b, $10          ; C5\n"
             "            ld      c, $CF\n"
             "            jp      beep\n")
    t = swap(t,
             "            call    lit_remove\n"
             "            call    unlight_pip\n"
             "            call    warm_walls\n",
             "            call    lit_remove\n"
             "            call    unlight_pip\n"
             "            call    blip_snuff\n"
             "            call    warm_walls\n")
    s03 = t

    return {"step-00": s00, "step-01": s01, "step-02": s02, "step-03": s03}


# ==========================================================================
# UNIT 9 — Your Longest Night
# ==========================================================================

def unit_09(prev: str) -> dict[str, str]:
    t = header(9, "Your Longest Night",
               "What deserves to survive changed: the row counts watches now, not lives.", prev)
    s00 = t

    # step 1 — the metric swap, whole: a replacement, not an addition
    t = drop(t,
             "            ; the night is held — the lives you kept are the score\n"
             "            ld      a, (lives)\n"
             "            ld      hl, best_lives\n"
             "            cp      (hl)\n"
             "            jr      c, .nobest\n"
             "            ld      (hl), a\n"
             ".nobest:\n")
    t = swap(t,
             ".thedawn:\n"
             "            call    draw_dawn_screen\n",
             ".thedawn:\n"
             "            ld      a, NUM_DUSKS        ; the whole night held — the row fills\n"
             "            ld      (best_dusk), a\n"
             "            call    draw_dawn_screen\n")
    t = swap(t,
             ".gone:\n"
             "            call    draw_lose_screen\n",
             ".gone:\n"
             "            ; a watch survived is a watch earned, even on a lost night\n"
             "            ld      a, (dusk)\n"
             "            ld      hl, best_dusk\n"
             "            cp      (hl)\n"
             "            jr      c, .gkeep\n"
             "            ld      (hl), a\n"
             ".gkeep:\n"
             "            call    draw_lose_screen\n")
    t = swap(t,
             "            ; your best night — the lives you kept on your finest win,\n"
             "            ; read in lamps (no digits). It survives the loop back to\n"
             "            ; the title: the go-again hook.\n"
             "            ld      hl, $5800 + 11 * 32 + 14\n"
             "            ld      b, LIVES\n"
             "            ld      a, (best_lives)\n",
             "            ; your longest night — one pip per watch survived, best\n"
             "            ; run, read in lamps as ever (no digits). It survives the\n"
             "            ; loop back to the title: the go-again hook.\n"
             "            ld      hl, $5800 + 11 * 32 + 13\n"
             "            ld      b, NUM_DUSKS\n"
             "            ld      a, (best_dusk)\n")
    t = drop(t,
             "best_lives:\n"
             "            defb    0               ; lives kept on the finest win — never reset\n")
    t = swap(t,
             "lit_qcount:\n"
             "            defb    0\n",
             "lit_qcount:\n"
             "            defb    0\n"
             "best_dusk:\n"
             "            defb    0               ; watches survived, best run — never\n"
             "                                    ; reset in play\n")
    s01 = t

    return {"step-00": s00, "step-01": s01}


# ==========================================================================
# UNIT 10 — The Dawn Phrase
# ==========================================================================

CHIME_DAWN = """\
chime_dawn:                         ; dusk's bell answered — light returns
            ld      b, $D2          ; C5, where dusk ended, the ground note
            ld      c, $CF
            call    beep
            ld      b, 8
            call    rest
            ld      b, $C6          ; E5, the answer rises the motif
            ld      c, $A4
            call    beep
            ld      b, 4
            call    rest
            ld      b, $FF          ; G5, opens toward morning — the fanfare completes it
            ld      c, $8A
            call    beep
            ld      b, $B1          ; held — B counts to 255, so sound it again
            ld      c, $8A
            jp      beep

"""


def unit_10(prev: str) -> dict[str, str]:
    t = header(10, "The Dawn Phrase",
               "Motif discipline: dusk's bell, reversed — and the build is the shipped game.", prev)
    s00 = t

    # step 1 — the dawn finds its phrase
    t = swap(t,
             "            call    draw_dawn_screen\n"
             "            call    dawn_sweep\n"
             "            call    fanfare_held\n",
             "            call    draw_dawn_screen\n"
             "            call    chime_dawn          ; the motif rises; G5 hangs...\n"
             "            call    dawn_sweep          ; ...the sweep holds the breath...\n"
             "            call    fanfare_held        ; ...and the fanfare's C answers it\n")
    t = swap(t,
             "            ld      (title_key_seen), a\n"
             "            ret\n"
             "\n"
             "fanfare_held:",
             "            ld      (title_key_seen), a\n"
             "            ret\n"
             "\n"
             + CHIME_DAWN +
             "fanfare_held:")
    s01 = t

    return {"step-00": s00, "step-01": s01}


# ==========================================================================
# build + gate
# ==========================================================================

UNITS: dict[int, dict[str, str]] = {}
UNITS[1] = unit_01()
UNITS[2] = unit_02(UNITS[1]["step-02"])
UNITS[3] = unit_03(UNITS[2]["step-02"])
UNITS[4] = unit_04(UNITS[3]["step-02"])
UNITS[5] = unit_05(UNITS[4]["step-03"])
UNITS[6] = unit_06(UNITS[5]["step-01"])
UNITS[7] = unit_07(UNITS[6]["step-03"])
UNITS[8] = unit_08(UNITS[7]["step-02"])
UNITS[9] = unit_09(UNITS[8]["step-03"])
UNITS[10] = unit_10(UNITS[9]["step-01"])


def assemble(asm: Path, sna: Path) -> None:
    subprocess.run([str(ASM198X), "--dialect", "pasmonext", "--sna",
                    str(asm), "-o", str(sna)],
                   check=True, capture_output=True)


def skeleton_sna(u: int) -> bytes:
    """The unit's skeleton snapshot, assembled fresh from the tracked
    source (the .sna files are derived and deliberately untracked)."""
    import tempfile
    with tempfile.NamedTemporaryFile(suffix=".sna") as tmp:
        assemble(SKEL / f"unit-{u:02d}.asm", Path(tmp.name))
        return Path(tmp.name).read_bytes()


def main() -> int:
    failures = 0
    for u, steps in sorted(UNITS.items()):
        udir = HERE / f"unit-{u:02d}" / "steps"
        udir.mkdir(parents=True, exist_ok=True)
        final_name = sorted(steps)[-1]
        for name, text in sorted(steps.items()):
            path = udir / f"{name}.asm"
            path.write_text(text)
            sna = udir / f"{name}.sna"
            try:
                assemble(path, sna)
            except subprocess.CalledProcessError as e:
                print(f"unit-{u:02d}/{name}: ASSEMBLY FAILED\n{e.stderr.decode()[:400]}")
                failures += 1
                continue
            print(f"unit-{u:02d}/{name}.asm ok ({len(text.splitlines())} lines)")
        # the unit gate: final step == skeleton snapshot
        want = skeleton_sna(u)
        got_path = udir / f"{final_name}.sna"
        if got_path.exists() and got_path.read_bytes() == want:
            print(f"unit-{u:02d}: final step byte-identical to skeleton unit-{u:02d}.sna")
        else:
            print(f"unit-{u:02d}: FINAL STEP DOES NOT MATCH SKELETON")
            failures += 1
        # tidy the build products (steps ship as source; .sna are derived)
        for sna in udir.glob("*.sna"):
            sna.unlink()
    if failures:
        print(f"GATE FAILED ({failures})")
        return 1
    print("gate clean")
    return 0


if __name__ == "__main__":
    sys.exit(main())
