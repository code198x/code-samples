#!/usr/bin/env python3
"""Gloaming module 2 (The Long Night) route skeleton — derive unit end-states.

Backbone (units 5-10): subsets of the proven gloaming.asm, derived
newest-first by assert-anchored subtraction. Unit 10 is copied
byte-for-byte. Unit 9 is the flagged metric swap: its subtraction
removes the best_dusk machinery and swaps m1's best-lives machinery
back in, cut verbatim from gloaming-m1.asm — the only backbone
boundary whose upward diff removes m1 code. Units 5-7 likewise carry
m1's one-shot dusk chime (the title tune replaces it at unit 8) —
m1-sourced text is cut from gloaming-m1.asm by anchor, never retyped.

Detour spine (units 1-4): the nearest-light Manhattan hunt the final
game replaced at round 12 (the eraser problem). The hunt is the text
of the prototype's own history — introduced by 7463ded, retired by
87bf8ce; the HISTORY fragments below are verbatim from the b601157
tree (the last commit that carried them) and are verified against
`git show b601157:<path>` when git is available. Everything else in
the spine is final-form text. The spine converges: unit-04 must equal
unit-05 with exactly the queue/oldest <-> nearest-scan swap inverted.

Both chain anchors bind:
  * unit-10.asm == gloaming.asm, byte-for-byte.
  * the chain bottoms out at the module seam: unit-00-seam.asm
    (unit-01 with unit 1's declared insertions removed) must be
    byte-identical to gloaming-m1.asm — module 1's proven end state.

After generation, an audit asserts every emitted line appears verbatim
in gloaming.asm, gloaming-m1.asm, or the explicit allowlist below.

Run from this directory:  python3 derive-skeleton-m2.py
"""

from pathlib import Path
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent          # skeleton-m2
PROTO = HERE.parent                             # prototype
M2_PATH = PROTO / "gloaming.asm"
M1_PATH = PROTO / "gloaming-m1.asm"
M2 = M2_PATH.read_text()
M1 = M1_PATH.read_text()

ORG = "            org     32768"
M2_BODY = M2[M2.index(ORG):]
M1_BODY = M1[M1.index(ORG):]


# --------------------------------------------------------------------------
# anchored transforms
# --------------------------------------------------------------------------

def drop(text: str, gone: str, n: int = 1) -> str:
    """Remove `gone` from `text` exactly `n` times (assert-hit)."""
    assert text.count(gone) == n, \
        f"drop anchor hit {text.count(gone)}x, want {n}: {gone[:60]!r}"
    return text.replace(gone, "")


def swap(text: str, old: str, new: str, n: int = 1) -> str:
    """Replace `old` with `new` exactly `n` times (assert-hit)."""
    assert text.count(old) == n, \
        f"swap anchor hit {text.count(old)}x, want {n}: {old[:60]!r}"
    return text.replace(old, new)


def cut(src: str, start: str, end: str) -> str:
    """`src` text from `start` (inclusive) to `end` (exclusive); both
    anchors must occur exactly once."""
    assert src.count(start) == 1, f"start anchor not unique: {start[:60]!r}"
    assert src.count(end) == 1, f"end anchor not unique: {end[:60]!r}"
    i, j = src.index(start), src.index(end)
    assert j > i, f"end before start: {end[:60]!r}"
    return src[i:j]


def in_m1(frag: str) -> str:
    """Assert `frag` is verbatim m1 text, then return it."""
    assert frag in M1, f"not verbatim gloaming-m1.asm: {frag[:60]!r}"
    return frag


# --------------------------------------------------------------------------
# HISTORY — the nearest-light hunt, verbatim from the b601157 tree
# (introduced 7463ded "the dark seeks the light", retired 87bf8ce
# "oldest-lit targeting"). Verified against git below when available.
# --------------------------------------------------------------------------

DASH = "; ----------------------------------------------------------------------------"

H_MANHATTAN = (
    DASH + "\n"
    "; manhattan — distance from the draught to cell (C = col, B = row) -> A.\n"
    + DASH + "\n"
    "manhattan:\n"
    "            ld      a, (draught_col)\n"
    "            sub     c\n"
    "            jp      p, .dc\n"
    "            neg\n"
    ".dc:\n"
    "            ld      d, a\n"
    "            ld      a, (draught_row)\n"
    "            sub     b\n"
    "            jp      p, .dr\n"
    "            neg\n"
    ".dr:\n"
    "            add     a, d\n"
    "            ret\n")

H_SCAN = (
    "            ; the lamplighter's flame is the first candidate...\n"
    "            ld      a, (lamp_col)\n"
    "            ld      c, a\n"
    "            ld      (seek_col), a\n"
    "            ld      a, (lamp_row)\n"
    "            ld      b, a\n"
    "            ld      (seek_row), a\n"
    "            call    manhattan\n"
    "            ld      (seek_best), a\n"
    "\n"
    "            ; ...then every lit lamp, keeping the nearest\n"
    "            ld      hl, lamp_data\n"
    ".scan:\n"
    "            ld      a, (hl)\n"
    "            cp      $FF\n"
    "            jr      z, .chase\n"
    "            ld      c, a\n"
    "            inc     hl\n"
    "            ld      b, (hl)\n"
    "            inc     hl\n"
    "            push    hl\n"
    "            push    bc\n"
    "            call    attr_addr_cr\n"
    "            ld      a, (hl)\n"
    "            pop     bc\n"
    "            cp      LAMP_LIT\n"
    "            jr      nz, .dnext      ; unlit lamps cast no light\n"
    "            call    manhattan\n"
    "            ld      hl, seek_best\n"
    "            cp      (hl)\n"
    "            jr      nc, .dnext      ; not nearer — keep the current prey\n"
    "            ld      (hl), a\n"
    "            ld      a, c\n"
    "            ld      (seek_col), a\n"
    "            ld      a, b\n"
    "            ld      (seek_row), a\n"
    ".dnext:\n"
    "            pop     hl\n"
    "            jr      .scan\n")

H_SEEK_BEST_DECL = (
    "seek_best:\n"
    "            defb    0\n")

HISTORY = [H_MANHATTAN, H_SCAN, H_SEEK_BEST_DECL]


def verify_history() -> None:
    """Soft provenance check: the HISTORY fragments must be verbatim in
    the b601157 blob (skipped with a warning if git is unavailable)."""
    rel = "sinclair-zx-spectrum/assembly/gloaming/prototype/gloaming.asm"
    try:
        blob = subprocess.run(
            ["git", "show", f"b601157:{rel}"],
            capture_output=True, text=True, check=True,
            cwd=HERE).stdout
    except (OSError, subprocess.CalledProcessError):
        print("WARNING: git unavailable — HISTORY provenance not re-verified")
        return
    for frag in HISTORY:
        assert frag in blob, \
            f"HISTORY fragment not verbatim in b601157: {frag[:60]!r}"
    print("history fragments verified verbatim against b601157")


# --------------------------------------------------------------------------
# m1-sourced fragments (cut by anchor from gloaming-m1.asm, never retyped)
# --------------------------------------------------------------------------

M1_DRAUGHT_CONSTS = cut(
    M1, "DRAUGHT_SPEED equ   16", "\nPLAYER_REPEAT")

M1_STATE_WIN = in_m1(
    "STATE_WIN   equ     2               ; the night is held — the game is won")

M1_EI_CHIME = in_m1(
    "            ei\n"
    "            call    chime_dusk          ; after EI — the rests need the interrupt")

M1_TITLE_BANNER = in_m1(
    "; title_step — after the lock, SPACE starts a fresh game.")

M1_END_BANNER = in_m1(
    "; end_step — WIN or LOSE: after the lock, SPACE returns to the title.")

M1_BEST_BLOCK = cut(
    M1, "            ; the night is held — the lives you kept are the score",
    "            call    draw_win_screen")

M1_AUDIO = cut(M1, "\nchime_dusk:", "\nfanfare_held:")

CHIME_DAWN_BLOCK = cut(M2, "\nchime_dawn:", "\nfanfare_held:")

M1_TITLE_PIPS = cut(
    M1, "            ; your best night — the lives you kept on your finest win,",
    "\n            ld      c, a\n.tpip:")

M1_BEST_DECL = in_m1(
    "best_lives:\n"
    "            defb    0               ; lives kept on the finest win — never reset")

M1_GATHER_COMMENT = in_m1(
    "            ; the dark gathers before its first step — a beat to read")

M1_HUNT_FLAME = cut(
    M1, "            ; the dark hunts the lamplighter's own flame",
    "\n\n.chase:")

M1_PIPS_BANNER = in_m1("; light_pip / draw_pips / draw_lives.")


# --------------------------------------------------------------------------
# the transform chain, newest first: T[u] is unit u's body text
# --------------------------------------------------------------------------

T = {10: M2_BODY}

# ---- unit 9: minus chime_dawn (unit 10's diff is the dawn phrase) --------

t = T[10]
t = swap(t,
         "            call    chime_dawn          ; the motif rises; G5 hangs...\n"
         "            call    dawn_sweep          ; ...the sweep holds the breath...\n"
         "            call    fanfare_held        ; ...and the fanfare's C answers it",
         "            call    dawn_sweep\n"
         "            call    fanfare_held")
t = drop(t, CHIME_DAWN_BLOCK)
T[9] = t

# ---- unit 8: minus best_dusk, m1's best-lives machinery swapped back -----

t = T[9]
# the dawn set comes out ...
t = drop(t,
         "            ld      a, NUM_DUSKS        ; the whole night held — the row fills\n"
         "            ld      (best_dusk), a\n")
# ... and m1's update returns to m1's own site, the held-dusk win path
t = swap(t,
         "            jr      z, .thedawn\n"
         "            call    draw_win_screen",
         "            jr      z, .thedawn\n"
         + M1_BEST_BLOCK
         + "            call    draw_win_screen")
# the title row reads lives again, at m1's column
t = swap(t,
         "            ; your longest night — one pip per watch survived, best run,\n"
         "            ; read in lamps as ever (no digits). It survives the loop\n"
         "            ; back to the title: the go-again hook.\n"
         "            ld      hl, $5800 + 11 * 32 + 13\n"
         "            ld      b, NUM_DUSKS\n"
         "            ld      a, (best_dusk)",
         M1_TITLE_PIPS)
# the lose-path watch-earned max comes out (m1 recorded nothing on a loss)
t = drop(t,
         "            ; a watch survived is a watch earned, even on a lost night\n"
         "            ld      a, (dusk)\n"
         "            ld      hl, best_dusk\n"
         "            cp      (hl)\n"
         "            jr      c, .gkeep\n"
         "            ld      (hl), a\n"
         ".gkeep:\n")
# the data byte swaps back, at m1's slot (after lives — the seam needs
# m1's declaration order)
t = drop(t,
         "best_dusk:\n"
         "            defb    0               ; watches survived, best run — never reset in play\n")
t = swap(t,
         "lives:\n"
         "            defb    LIVES\n",
         "lives:\n"
         "            defb    LIVES\n"
         + M1_BEST_DECL + "\n")
T[8] = t

# ---- unit 7: minus the title tune and the snuff's voice ------------------

t = T[8]
t = swap(t,
         "            ei                          ; the tune's rests need the interrupt;\n"
         "                                        ; the first toll plays from title_step",
         M1_EI_CHIME)
t = swap(t,
         "; title_step — after the lock, SPACE starts a fresh game. While SPACE is\n"
         "; up, one cell of the title tune plays per pass — the poll sits between\n"
         "; cells, so a keypress waits at most one cell of the dusk bells.",
         M1_TITLE_BANNER)
t = swap(t,
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
         "            call    init_run",
         ".tready:\n"
         "            ld      bc, KEYS_SPACE\n"
         "            in      a, (c)\n"
         "            bit     0, a\n"
         "            ret     nz\n"
         "            call    init_run")
t = swap(t,
         "            xor     a                   ; the dusk bells start from the toll\n"
         "            ld      (title_music_step), a\n"
         "            ld      (title_key_seen), a ; and any stale press is forgotten",
         "            call    chime_dusk")
# the audio shelf reverts to m1's: blip_snuff, the phrase banner, the
# tune, and its listening rest all leave; the one-shot dusk chime returns
# (the fragment is the T9 state: gloaming.asm's shelf minus chime_dawn)
t = swap(t,
         drop(cut(M2, "\nblip_snuff:", "\nfanfare_held:"), CHIME_DAWN_BLOCK),
         M1_AUDIO)
t = drop(t, "            call    blip_snuff\n")
t = drop(t,
         "title_music_step:\n"
         "            defb    0               ; which step of the title tune plays next\n"
         "title_key_seen:\n"
         "            defb    0               ; SPACE latched by title_rest mid-tune\n")
T[7] = t

# ---- unit 6: minus dawn (watch 5 wraps forever — the honest endless) -----

t = T[7]
t = drop(t,
         "STATE_DAWN  equ     4               ; the fifth dusk held — morning, the true win\n"
         "DAWN_COL    equ     10\n")
t = drop(t,
         "            ; the eighth lamp: is this the last watch of the night?\n"
         "            ld      a, (dusk)\n"
         "            cp      NUM_DUSKS - 1\n"
         "            jr      z, .thedawn\n")
t = drop(t,
         ".thedawn:\n"
         "            call    draw_dawn_screen\n"
         "            call    dawn_sweep\n"
         "            call    fanfare_held\n"
         "            ld      a, LOCK\n"
         "            ld      (input_lock), a\n"
         "            ld      a, STATE_DAWN\n"
         "            ld      (game_state), a\n"
         "            ret\n")
t = drop(t, cut(M2, "draw_dawn_screen:", "draw_lose_screen:"))
t = drop(t, cut(M2, DASH + "\n; dawn_sweep", DASH + "\n; lamp_index_at"))
t = drop(t,
         "dawn_text:\n"
         "            defb    \"DAWN BREAKS\"\n"
         "            defb    $FF\n")
T[6] = t

# ---- unit 5: minus watches — a single dusk; the grudge queue lives -------

t = T[6]
t = swap(t,
         "NUM_DUSKS     equ   5               ; the night is five watches long; hold them all\n"
         "                                    ; and the dawn breaks",
         M1_DRAUGHT_CONSTS)
t = swap(t,
         "STATE_WIN   equ     2               ; a dusk held — the night deepens",
         M1_STATE_WIN)
t = swap(t,
         "; end_step — after the lock, SPACE moves on. A held dusk continues the\n"
         "; run — the night deepens; only NIGHT FALLS returns to the title.",
         M1_END_BANNER)
t = drop(t,
         "            ld      a, (game_state)\n"
         "            cp      STATE_WIN\n"
         "            jr      z, .deeper\n")
t = drop(t,
         ".deeper:\n"
         "            ld      hl, dusk\n"
         "            inc     (hl)\n"
         "            call    init_game\n"
         "            ld      a, STATE_PLAY\n"
         "            ld      (game_state), a\n"
         "            ret\n")
t = swap(t, "            call    init_run", "            call    init_game")
t = swap(t,
         "; A run is a night: dusk 0, full lives. Each held dusk re-enters\n"
         "; init_game with dusk bumped — the square relights, the lives carry.\n"
         "init_run:\n"
         "            xor     a\n"
         "            ld      (dusk), a\n"
         "            ld      a, LIVES\n"
         "            ld      (lives), a\n"
         "            ; fall through into the per-dusk setup\n"
         "\n"
         "init_game:\n"
         "            xor     a\n"
         "            ld      (lit_count), a",
         "init_game:\n"
         "            xor     a\n"
         "            ld      (lit_count), a\n"
         "            ld      a, LIVES\n"
         "            ld      (lives), a")
t = swap(t,
         "            ; the dark probes from a new quarter each watch\n"
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
         "            ld      (draught_home_row), a",
         "            ld      a, DRAUGHT_COL0\n"
         "            ld      (draught_col), a\n"
         "            ld      (draught_home_col), a\n"
         "            ld      a, DRAUGHT_ROW0\n"
         "            ld      (draught_row), a\n"
         "            ld      (draught_home_row), a")
t = swap(t,
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
         "            ; ...but it gathers before the first step — a beat to read",
         M1_GATHER_COMMENT)
t = drop(t,
         "            ; the tendril reaches further as the night deepens\n"
         "            ld      hl, dusk_lentab\n"
         "            add     hl, de\n"
         "            ld      a, (hl)\n"
         "            ld      (tendril_max), a\n")
t = swap(t, "            ld      a, (dusk_speed)",
         "            ld      a, DRAUGHT_SPEED", n=2)
t = drop(t, cut(M2, "corner_tab:", "\n" + DASH + "\n; tendril_claimed") + "\n")
t = drop(t, "\n" + cut(M2, "dusk_table:", "\nwall_ramp:") + "\n")
t = drop(t,
         "dusk:\n"
         "            defb    0\n"
         "dusk_speed:\n"
         "            defb    16\n")
T[5] = t

# ---- unit 4: the convergence swap — oldest grudge back to nearest light --
# (87bf8ce inverted: the queue leaves, the history's Manhattan scan returns)

t = T[5]
t = swap(t,
         cut(M2, DASH + "\n; lamp_index_at", "\n" + DASH + "\n; draught_step"),
         H_MANHATTAN)
t = drop(t, "            ld      (lit_qcount), a\n")
t = drop(t,
         "            ; record the lighting order — the night bears its grudges\n"
         "            ; oldest-first (lamp_col/lamp_row are the lamplighter's\n"
         "            ; position, and he is standing on the lamp)\n"
         "            ld      a, (lamp_col)\n"
         "            ld      c, a\n"
         "            ld      a, (lamp_row)\n"
         "            ld      b, a\n"
         "            call    lamp_index_at\n"
         "            call    lit_push\n")
t = swap(t,
         "            ; the oldest flame is the night's grievance — it reclaims\n"
         "            ; the ground it lost first. With nothing lit, it hunts the\n"
         "            ; lamplighter's own flame: light your first lamp and the\n"
         "            ; hunt turns away from you.\n"
         "            ld      a, (lit_qcount)\n"
         "            or      a\n"
         "            jr      nz, .oldest\n"
         "            ld      a, (lamp_col)\n"
         "            ld      (seek_col), a\n"
         "            ld      a, (lamp_row)\n"
         "            ld      (seek_row), a\n"
         "            jr      .chase\n"
         ".oldest:\n"
         "            ld      a, (lit_queue)\n"
         "            add     a, a\n"
         "            ld      e, a\n"
         "            ld      d, 0\n"
         "            ld      hl, lamp_data\n"
         "            add     hl, de\n"
         "            ld      a, (hl)\n"
         "            ld      (seek_col), a\n"
         "            inc     hl\n"
         "            ld      a, (hl)\n"
         "            ld      (seek_row), a\n",
         H_SCAN)
t = drop(t,
         "            ; the grievance is settled — off the lit-order queue\n"
         "            ld      a, (draught_col)\n"
         "            ld      c, a\n"
         "            ld      a, (draught_row)\n"
         "            ld      b, a\n"
         "            call    lamp_index_at\n"
         "            call    lit_remove\n")
t = swap(t,
         "lit_queue:\n"
         "            defb    0, 0, 0, 0, 0, 0, 0, 0\n"
         "lit_qcount:\n"
         "            defb    0\n",
         H_SEEK_BEST_DECL)
T[4] = t

# ---- unit 3: minus the tendril ------------------------------------------

t = T[4]
t = drop(t,
         "DARK        equ     %01000001       ; the night made solid — bright-blue mist, impassable\n")
t = drop(t,
         "            ; the solid night blocks too — you cannot walk into the dark\n"
         "            ld      a, (hl)\n"
         "            cp      DARK\n"
         "            ret     z\n")
t = drop(t, "\n" + cut(M2, "mist_tex:", "\nbrick_tex:"))
t = drop(t,
         "            ; the tendril: night pools where the wisp has walked. Ground\n"
         "            ; and spilt light are both taken (the pool heals on release);\n"
         "            ; posts and stone are not. Re-walking its own trail refreshes\n"
         "            ; the night's claim, so the tendril never gaps mid-vein.\n"
         "            ld      a, (draught_col)\n"
         "            ld      c, a\n"
         "            ld      a, (draught_row)\n"
         "            ld      b, a\n"
         "            push    bc\n"
         "            call    attr_addr_cr\n"
         "            pop     bc\n"
         "            ld      a, (hl)\n"
         "            cp      DARK\n"
         "            jr      z, .retake\n"
         "            cp      COBBLE\n"
         "            jr      z, .take\n"
         "            cp      GLOW\n"
         "            jr      nz, .notake\n"
         ".take:\n"
         "            ld      (hl), DARK\n"
         "            ld      de, mist_tex\n"
         "            call    blit_tex\n"
         ".retake:\n"
         "            call    tendril_push\n"
         ".notake:\n")
t = drop(t, cut(M2, DASH + "\n; tendril_push", DASH + "\n; paint_buildings"))
t = drop(t, cut(M2, DASH + "\n; tendril_claimed", DASH + "\n; pooled_at"))
t = drop(t, "\n" + cut(M2, DASH + "\n; pooled_at", "\nlose_life:"))
t = drop(t, "            ld      (tendril_len), a\n")
t = drop(t, "            ld      (tendril_head), a\n")
t = drop(t,
         "tendril_head:\n"
         "            defb    0\n"
         "tendril_len:\n"
         "            defb    0\n"
         "tendril_max:\n"
         "            defb    6\n"
         "tendril_buf:\n"
         "            defb    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0\n"
         "            defb    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0\n")
T[3] = t

# ---- unit 2: minus the pools ---------------------------------------------

t = T[3]
t = drop(t,
         "GLOW        equ     %00000110       ; pool-warmed cobble — ground the light holds\n")
t = drop(t, "            call    recompute_pools\n", n=2)
t = drop(t, cut(M2, DASH + "\n; recompute_pools", DASH + "\n; fill_ground"))
t = drop(t, "\n" + cut(M2, "recompute_pools:", "\n" + DASH + "\n; dawn_sweep"))
T[2] = t

# ---- unit 1: minus the withdraw/rest rhythm ------------------------------

t = T[2]
t = drop(t,
         "WREST       equ     48              ; frames it rests at home after a withdrawal —\n"
         "                                    ; the snuff window holds even when home is close\n")
t = drop(t,
         "            ; withdrawing? after a snuff the night carries its prize\n"
         "            ; home before hunting again — every snuff buys the\n"
         "            ; lamplighter a window, and the hunt re-enters from a\n"
         "            ; quarter he can plan against\n"
         "            ld      a, (draught_mode)\n"
         "            or      a\n"
         "            jr      z, .hunt\n"
         "            ld      a, (draught_home_col)\n"
         "            ld      hl, draught_col\n"
         "            cp      (hl)\n"
         "            jr      nz, .whome\n"
         "            ld      a, (draught_home_row)\n"
         "            ld      hl, draught_row\n"
         "            cp      (hl)\n"
         "            jr      nz, .whome\n"
         "            xor     a                   ; home — rest, then the hunt resumes\n"
         "            ld      (draught_mode), a\n"
         "            ld      a, WREST\n"
         "            ld      (draught_timer), a\n"
         "            ret\n"
         ".whome:\n"
         "            ld      a, (draught_home_col)\n"
         "            ld      (seek_col), a\n"
         "            ld      a, (draught_home_row)\n"
         "            ld      (seek_row), a\n"
         "            jp      .chase\n"
         ".hunt:\n")
t = drop(t,
         "            ld      a, 1                ; the prize is taken — withdraw\n"
         "            ld      (draught_mode), a\n")
t = swap(t,
         "            ld      a, (draught_home_col)\n"
         "            ld      (draught_col), a\n"
         "            ld      a, (draught_home_row)\n"
         "            ld      (draught_row), a\n"
         "            ld      a, DRAUGHT_SPEED\n"
         "            ld      (draught_timer), a\n"
         "            xor     a                   ; already home — hunt on arrival\n"
         "            ld      (draught_mode), a",
         "            ld      a, DRAUGHT_COL0\n"
         "            ld      (draught_col), a\n"
         "            ld      a, DRAUGHT_ROW0\n"
         "            ld      (draught_row), a\n"
         "            ld      a, DRAUGHT_SPEED\n"
         "            ld      (draught_timer), a")
t = drop(t, "            ld      (draught_mode), a\n")
t = drop(t, "            ld      (draught_home_col), a\n")
t = drop(t, "            ld      (draught_home_row), a\n")
t = drop(t,
         "draught_home_col:\n"
         "            defb    28\n"
         "draught_home_row:\n"
         "            defb    4\n"
         "draught_mode:\n"
         "            defb    0               ; 0 = hunting, 1 = withdrawing home\n")
T[1] = t

# ---- unit 0: the module seam — must equal gloaming-m1.asm ----------------

t = T[1]
t = swap(t, H_SCAN.rstrip("\n"), M1_HUNT_FLAME)
t = drop(t, "\n" + H_MANHATTAN)
# the draught_step and paint_buildings banners are m2-era prose the m1
# cut does not carry (the draught banner describes the nearest-light
# rule; the buildings banner names what the night ignores) — both
# arrive with unit 1, and m1's tight layout (no blank after brick_tex)
# is the seam's shape
t = drop(t, cut(M2, "\n\n" + DASH + "\n; draught_step", "\ndraught_step:"))
t = drop(t, cut(M2, "\n\n" + DASH + "\n; paint_buildings", "\npaint_buildings:"))
t = drop(t,
         "            ld      a, (under_draught + 8)\n"
         "            cp      LAMP_LIT\n"
         "            jr      nz, .nosnuff\n"
         "            ld      a, LAMP_UNLIT\n"
         "            ld      (under_draught + 8), a\n"
         "            call    unlight_pip\n"
         "            call    warm_walls\n"
         ".nosnuff:\n")
t = swap(t, "; light_pip / unlight_pip / draw_pips / draw_lives.",
         M1_PIPS_BANNER)
t = drop(t, "\n" + cut(M2, "unlight_pip:", "\ndraw_pips:"))
t = drop(t, H_SEEK_BEST_DECL)
T[0] = t


# --------------------------------------------------------------------------
# headers (the route map carries the full narration; these are captions)
# --------------------------------------------------------------------------

HEADERS = {
    1: ("The Dark Seeks the Light",
        "Targeting generalises: nearest light — and your flame counts; the snuff, silent for now, undoes your work.",
        "detour"),
    2: ("It Carries Its Prize Home",
        "Behaviour needs rhythm, not just rules: hunt, snuff, withdraw, rest.",
        "detour"),
    3: ("The Pools of Light",
        "Claimed ground: a lit lamp warms its eight neighbours, and both movers restore before the recolour.",
        "detour"),
    4: ("The Tendril",
        "The night takes territory: a ring buffer of darkness that releases its oldest claim.",
        "detour"),
    5: ("The Night Bears Grudges",
        "The eraser problem: greedy-nearest camps your work — the lit-order queue hunts the oldest flame instead.",
        "subset"),
    6: ("The Night Deepens",
        "Escalation as data on two axes — and the held screen becomes an interstitial.",
        "subset+m1"),
    7: ("Dawn Breaks",
        "A run needs an ending you can reach: hold the fifth watch and morning comes.",
        "subset+m1"),
    8: ("The Dusk Bells",
        "A title tune that yields the keyboard — and the snuff finds its voice.",
        "subset+m1"),
    9: ("Your Longest Night",
        "What deserves to survive changed: the best row counts watches now, not lives.",
        "subset"),
}

METHODS = {
    "subset": "subset of gloaming.asm, derived by reverse subtraction",
    "subset+m1": "subset of gloaming.asm, plus m1 text carried verbatim from gloaming-m1.asm (best-lives; dusk chime below unit 8)",
    "detour": "detour spine — the history's nearest-light hunt (7463ded..b601157) under final-form text; converges on the backbone at unit 5",
}


def header_for(u: int) -> str:
    title, idea, method = HEADERS[u]
    return (f"; Gloaming — route skeleton (module 2), unit {u:02d}: {title}\n"
            f"; {idea}\n"
            f"; Method: {METHODS[method]}.\n\n")


# --------------------------------------------------------------------------
# the audit: every emitted line must be verbatim m2, m1, or allowlisted
# --------------------------------------------------------------------------

AUTHORED = {"            call    dawn_sweep"}
for frag in HISTORY:
    for line in frag.split("\n"):
        AUTHORED.add(line.rstrip())

M2_LINES = {line.rstrip() for line in M2.split("\n")}
M1_LINES = {line.rstrip() for line in M1.split("\n")}


def audit(u: int, text: str) -> list[str]:
    bad = []
    for line in text.split("\n"):
        s = line.rstrip()
        if not s or s.startswith("; Gloaming — route skeleton") \
                or s.startswith("; Method:"):
            continue
        if s in M2_LINES or s in M1_LINES or s in AUTHORED:
            continue
        bad.append(s)
    return bad


for _t, _idea, _m in HEADERS.values():
    AUTHORED.add(f"; {_idea}")


# --------------------------------------------------------------------------
# main
# --------------------------------------------------------------------------

def main() -> int:
    verify_history()
    failures = 0

    # unit 10 — byte-for-byte
    shutil.copyfile(M2_PATH, HERE / "unit-10.asm")
    assert (HERE / "unit-10.asm").read_bytes() == M2_PATH.read_bytes()
    print("unit-10.asm copied byte-for-byte from gloaming.asm")

    # units 9..1 — headers + derived bodies
    for u in range(9, 0, -1):
        text = header_for(u) + T[u]
        bad = audit(u, text)
        if bad:
            failures += 1
            print(f"unit-{u:02d}: {len(bad)} unanchored line(s):")
            for b in bad[:8]:
                print(f"    {b!r}")
        (HERE / f"unit-{u:02d}.asm").write_text(text)
        print(f"unit-{u:02d}.asm written ({len(text.splitlines())} lines)")

    # the module seam: unit-01 minus its declared insertions, under m1's
    # own header, must be byte-identical to gloaming-m1.asm
    seam = M1[:M1.index(ORG)] + T[0]
    (HERE / "unit-00-seam.asm").write_text(seam)
    if seam != M1:
        failures += 1
        print("SEAM BROKEN: unit-00-seam.asm != gloaming-m1.asm")
        import difflib
        for line in list(difflib.unified_diff(
                M1.splitlines(), seam.splitlines(),
                "gloaming-m1.asm", "unit-00-seam.asm", lineterm=""))[:40]:
            print(f"    {line}")
    else:
        print("seam holds: unit-00-seam.asm is byte-identical to gloaming-m1.asm")

    if failures:
        print(f"AUDIT FAILED for {failures} unit(s)")
        return 1
    print("audit clean: every line is verbatim gloaming.asm, gloaming-m1.asm,")
    print("or the explicit HISTORY/authored allowlist")
    return 0


if __name__ == "__main__":
    sys.exit(main())
