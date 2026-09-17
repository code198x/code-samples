# Three in a Row — BASIC prototype

Stock 48K PAL Sinclair BASIC. A deliberately fallible priority opponent:
win, block, centre, first free corner in 1/3/7/9 order, then last free edge.
The computer prints the rule that chose its move. The board is numeric state;
its picture is never read to determine ownership, legal moves or wins.

S starts. Press a digit 1–9 to place X; O replies. R restarts an unfinished
round with the same starter, or begins the next completed round with the other
starter. Q quits. Completed rounds update the session tally once. The final
board remains visible and a yellow line marks a win. The game is silent.

## Build and verification

Run from this folder, supplying the emulator executable and a lawful configured
48K ROM. No ROM is distributed here.

```sh
python3 verification/model.py
python3 verification/build.py --emulator /path/to/emu198x-spectrum --output verification/evidence
python3 verification/check.py --emulator /path/to/emu198x-spectrum --output verification/evidence
python3 verification/capture.py --emulator /path/to/emu198x-spectrum --output verification/evidence
python3 verification/audit.py
```

The build enters every source line using actual ROM keyword keys, records stored
line bytes and saves `three.tap` with automatic execution at line 10. The check
loads that tape into a fresh emulator process, sends ordinary keys and compares
observed moves and reason text with an independent line-count model.

The model enumerates all legal human replies under both starters. Its path
counts are not human win probabilities. Native play covers representative legal
paths, all available choice reasons, endings, held/invalid/occupied keys,
restart/replay and quit. Sixteen separate winning-line diagnostics and a
full-board winning diagnostic use ROM-entered DIM/LET commands after STOP;
these are explicit fixtures, not ordinary play or public playthrough captures.
No direct memory writes are used. Original captures come from legal rounds.

The entry helper reuses the maintained Meet BASIC ROM harness. The read-only
state observer comes from Tail Chase. These are host verification dependencies,
not part of the Spectrum program.

Human acceptance is pending. The existing six published lessons are unchanged;
teaching checkpoints and replacement lessons follow acceptance of the game.

## Emulator used for the playtest

The native playtest uses the local Emu198x checkout at commit
`e1f49c7e8e20ff8cf1cab8453955f2b212dab4e3`; its executable reports 0.24.0.
The released 0.25.0 executable was also checked. Both pass the gameplay suite.
`release-results.json` preserves the release run; `results.json` records the
local build. No emulator source was changed.

The original fork-win captures from both builds are byte-identical. The separate
`render_check.py` uses Pillow to compare the original PNG's foreground with all
49,152 screen bitmap pixels, after checking black paper, non-black ink and FLASH
off. It does not modify images. See `renderer-comparison.json` and the two
`*-render.json` records. This checks original capture data independently of any
image-preview display.
