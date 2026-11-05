# Make 17 pattern sources build with their machine's own assembler

Fixes #216 and #183. Measured at `5cd14335` with ACME 0.97, PasmoNext 0.1.3
and Asm198x 0.0.73. Asm198x 0.0.73 already rejects the five Z80 sources, so
those patterns don't build with the current release at all.

The NES `tile-map` source in #216 is not a defect: it is ACME source, its
`build.py` builds it as ACME, and ACME and Asm198x agree on all 16,384 bytes.
asm198x/asm198x#972's machine table assumes every NES pattern is ca65. That
needs a per-source exception there, not a change here.

## Changes

1. ACME reads a four-digit hex literal as 16-bit, so `(NR+20),y` is out of
   range. Write the zero-page bases as two digits: `NR=$70`, `BP=$40`,
   `FC=$70`, `G=$40` in the Electron, BBC (three), PET (two) and VIC-20 (two)
   demos. Shared includes are untouched.
2. ACME opens `!source` relative to the folder it runs in. `turn.inc`'s
   `!source "edge-filter.inc"` names the file from the demo folder instead;
   all four Atari callers sit at the same depth.
3. Aquarius `tile-region`: rename the `halt` label, which is a Z80 mnemonic.
4. Game Gear and Master System `custom-glyphs`: PasmoNext rejects `P` anywhere
   because it is a condition code. Rename it to `PAT` in `mode4.inc`, both
   demos, both `glyphs.inc`, `native-glyphs/build.py`'s fault patches and the
   three READMEs. `mode4.inc` has no other users. The two website lessons
   quote `P` in prose (line 19); change them in a website PR.
5. ColecoVision (#183): `defs $10000-$,0` becomes `defs 65536-$,0`, which
   PasmoNext 0.1.3 and Asm198x both assemble to the intended padding.

## Verification

- Bytes: every changed source assembles with its reference tool and with
  Asm198x to identical output. For the ACME group that output must also
  equal Asm198x's output for the unchanged source. For the Z80 group, which
  the current release can't build, it must equal the binary each pattern's
  `results.json` recorded.
- Evidence: re-record each affected family with its own `verify-*.py` on the
  latest releases, Asm198x 0.0.74 and Emu198x 0.48.3, moving its pins to
  match, then run its `check-*.py` and tests. Any observation that differs is
  investigated, not re-pinned. A machine that needs its own design decision
  on the new emulator keeps its existing pin and gets a follow-up issue.
- Every Makefile touched still builds with the website's assembler pin.
