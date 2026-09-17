# Locksmith teaching checkpoints

Seven standalone stock 48K PAL Sinclair BASIC programs support nine planned lessons. The final listing is byte-identical to the accepted prototype at `e8272b9`. The earlier published six-unit course remains unchanged while replacement lessons are developed.

| Lessons | Program | Result |
|---|---|---|
| 1 | `board` | Four empty digit cells on an inspectable board |
| 2 | `editor` | Direct digit entry, deletion and complete-guess validation |
| 3 | `exact` | Position matches against visible code 1122; one result row |
| 4 | `clues` | Correct EXACT/OTHER counts, including repeated digits |
| 5–6 | `history` | Ten practice rows and a verified deduction trace |
| 7 | `round` | Hidden random code, immediate win, ten-guess loss and replay |
| 8–9 | `finished` | The accepted title and complete game; saving reuses it |

The practice programs deliberately expose the code. The editor confirms a complete guess without scoring. Exact/clues retain the editable guess and replace one result row. History clears the next guess and records ten submissions, even after a correct one. These are inspection programs; only the hidden-round stage has the final game's win rule.

The board uses STOP so the learner can inspect it. Its capture includes the ordinary ROM STOP report. Other captures are taken during normal video-frame execution. The original PNGs were visually inspected; none were redrawn or edited.

## Editing and verification

`checkpoints.json` identifies each source and lesson. `edits.md`, each `edits.json`, and the later `changes.bas` files describe exact transitions. Changed-line listings include bare line numbers for deletions. The first program is a new complete listing.

From this directory, with a lawful stock 48K ROM configured:

```sh
python3 verification/derive.py
python3 verification/build.py --emulator /path/to/emu198x-spectrum --output verification/evidence --jobs 4
python3 verification/check.py --emulator /path/to/emu198x-spectrum --output verification/evidence --jobs 4
python3 verification/audit.py
```

Every checkpoint is entered through a fresh ROM keyboard session and saved with `SAVE "locksmith" LINE 10`. Trials load these tapes in fresh emulator processes. Checks use keyboard input and read-only observation, not injected game state. Build/check commands accept `--only NAME` for a bounded rerun; the audit still requires evidence for all seven programs.

The retained evidence records **80 passed check groups and 52 scored guesses** on Emu198x Spectrum 0.25.0. It covers editor boundaries, held keys, deletion, incomplete input, exact matches, repeated-digit accounting, one-row replacement, all ten history rows, practice versus hidden-round endings, replay and quit. An independent model consumes unmatched occurrences rather than reproducing the BASIC frequency-count loop.

The audit checks exact source reconstruction, branch targets, unchanged ROM-stored line bytes, both tape checksums, line-10 autostart, source hashes and final identity. The history trial records the deduction sequence in `verification/evidence/history/deduction.json`: 1111 → 2/0, 2222 → 2/0, 2211 → 0/4. Those clues leave 150, six and one possible codes respectively. This is a worked example against a visible practice code, not a hidden solver feature.

Native acceptance belongs to the unchanged final game. Intermediate programs have configuration-specific emulator checks, not independent learner review or original-hardware timing evidence. Full replacement lesson prose is the next step.
