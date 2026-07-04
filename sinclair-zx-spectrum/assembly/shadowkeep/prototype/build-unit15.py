#!/usr/bin/env python3
"""Weave — Unit 15: Mood through Constraint (each room its own darkness).

Gives every room its own light falloff — the Hall broad and soft, the Vault a
tight crypt — and turns the Vault into that crypt: no wall torch, the only flame
on the altar itself, so with falloff 0 the light pools tight and the rest sinks to
black. The Warden and gold still render over it (bright sprites on dark stone).

  shade_for_cell now shifts the distance by the room's falloff before clamping;
  room_falloff carries one byte of mood per room; the Vault template loses its
  wall torch and altar banners and gains a flame in the altar.

Single step, built on Unit 14's end.

Run from prototype/:  python3 build-unit15.py
"""
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE / "weave" / "unit-14" / "steps" / "step-01.asm"
OUTDIR = HERE / "weave" / "unit-15" / "steps"
OUTDIR.mkdir(parents=True, exist_ok=True)

base = BASE.read_text()

H14 = ("; Shadowkeep — Unit 14: Furnishings\n"
       "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
       "; step-01 dresses the rooms — a statue, banners, rubble — scenery that makes a place.")


def swap(t, old, new):
    assert t.count(old) == 1, f"swap anchor not unique ({t.count(old)}x): {old[:48]!r}"
    return t.replace(old, new)


SHADE_OLD = """shade_for_cell:
            ld      a, (torch_col)
            cp      NO_TORCH
            jr      z, .sf_dark
            ld      a, b
            ld      hl, torch_row
            sub     (hl)
            jr      nc, .sf_rpos
            neg
.sf_rpos:
            ld      d, a            ; |row - torch_row|
            ld      a, c
            ld      hl, torch_col
            sub     (hl)
            jr      nc, .sf_cpos
            neg
.sf_cpos:
            cp      d               ; A = |dc|; max(|dc|, |dr|)
            jr      nc, .sf_max
            ld      a, d
.sf_max:
            srl     a               ; distance / 2
            cp      MAX_SHADE + 1
            jr      c, .sf_done
            ld      a, MAX_SHADE
.sf_done:
            ret
.sf_dark:
            ld      a, MAX_SHADE
            ret"""

SHADE_NEW = """shade_for_cell:
            push    bc
            ld      a, (torch_col)
            cp      NO_TORCH
            jr      z, .sf_dark
            ld      a, b
            ld      hl, torch_row
            sub     (hl)
            jr      nc, .sf_rpos
            neg
.sf_rpos:
            ld      d, a            ; |row - torch_row|
            ld      a, c
            ld      hl, torch_col
            sub     (hl)
            jr      nc, .sf_cpos
            neg
.sf_cpos:
            cp      d               ; A = |dc|; max(|dc|, |dr|)
            jr      nc, .sf_max
            ld      a, d
.sf_max:
            ld      e, a                ; E = Chebyshev distance
            ld      a, (current_room)   ; shift it by THIS room's falloff
            ld      c, a
            ld      b, 0
            ld      hl, room_falloff
            add     hl, bc
            ld      b, (hl)             ; B = this room's falloff
            ld      a, e
            inc     b
.sf_shift:
            dec     b
            jr      z, .sf_clamp
            srl     a
            jr      .sf_shift
.sf_clamp:
            cp      MAX_SHADE + 1
            jr      c, .sf_done
            ld      a, MAX_SHADE
.sf_done:
            pop     bc
            ret
.sf_dark:
            ld      a, MAX_SHADE
            pop     bc
            ret"""

VAULT_14 = '''room2_template:
            defb    "###############T################"
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
            defb    "B.............####.............#"
            defb    "#.............####.............B"
            defb    "#.............####.............#"'''

VAULT_15 = '''room2_template:
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
            defb    "#.............#T##.............#"
            defb    "#.............####.............#"
            defb    "#.............####.............#"
            defb    "#.............####.............#"'''

t = swap(base, H14,
         "; Shadowkeep — Unit 15: Mood through Constraint\n"
         "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
         "; step-01 gives each room its own falloff — the Hall broad, the Vault a tight crypt.")
# shade_for_cell now applies per-room falloff
t = swap(t, SHADE_OLD, SHADE_NEW)
# room_falloff table (before the shade ramp)
t = swap(t,
         "\n; The shade ramp: lightest (lit) to darkest (deep shadow), all blue/black dither.\nshade_tiles:",
         "\n; One byte of mood per room: how slowly its light fades.\n"
         "room_falloff:\n"
         "            defb    2                   ; Hall — broad, soft pool\n"
         "            defb    1                   ; Gallery — medium\n"
         "            defb    0                   ; Vault — tight pool, deep dark\n"
         "\n; The shade ramp: lightest (lit) to darkest (deep shadow), all blue/black dither.\nshade_tiles:")
# the Vault becomes a crypt
t = swap(t, VAULT_14, VAULT_15)

step00 = swap(base, H14,
              "; Shadowkeep — Unit 15: Mood through Constraint\n"
              "; Cumulative build; every step runs on its own. Narrative: the unit page.\n"
              "; step-00 = Unit 14's end: lit and furnished, but every room lit the same.")

(OUTDIR / "step-00.asm").write_text(step00)
(OUTDIR / "step-01.asm").write_text(t)
print(f"wrote unit-15 step-00 ({len(step00.splitlines())}), step-01 ({len(t.splitlines())}) lines")
