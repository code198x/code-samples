# Three in a Row teaching checkpoints

Nine stock 48K PAL Sinclair BASIC programs develop the game.
The eleven lessons use `board`, `place`, `turns`, `results`, `reply`, `tactics`,
`policy`, then reuse `policy` for the fork, add `finished`, reuse that for
saving, and end with `colours`. `finished/three.bas` is byte-identical to the
accepted prototype. `colours/three.bas` is the final program: it replaces the
dim blue grid with green and keeps every drawing colour temporary, so only
lines 10 and 8000 change the permanent colours.

`checkpoints.json` records exact additions, replacements and deletions between
programs. `changes.bas` contains ordinary lines to enter, with deletions stated
separately in the lessons. The first listing is a new program.

## Reproduce

Set `EMU198X_SPECTRUM` to a built Spectrum executable with its lawful 48K ROM
configured. Run from this directory:

```sh
python3 verification/build.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence --jobs 4
python3 verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence --jobs 4
cp ../prototype/verification/evidence/model.json verification/evidence/finished/model.json
python3 ../prototype/verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence/finished
python3 verification/audit.py
```

Each build starts with a fresh ROM, enters the complete program with keyword
keys and records `SAVE "three" LINE 10`. Each execution check starts another
process and loads that tape. Memory observations are read-only. Separate
winning-line and priority fixtures use ordinary DIM/LET commands after STOP;
they are not playthroughs and do not provide public captures.

The intermediate games deliberately expose incomplete rules. `place` allows
nine X marks; `turns` alternates players and stops only at a full board;
`results` detects wins and draws; `reply` uses the first empty square; `tactics`
adds immediate wins and blocks; `policy` adds positional preferences. These
programs have no session tally and always restart with X. The finished game
introduces a title, tally and alternating starters.

The `colours` check first plays the fork (1, 8, 7, 4) on the `finished` tape and
asserts the leak it teaches: the grid and the permanent colours (`ATTR P`,
23693) are blue after the board is drawn, and yellow after the winning line,
so line 5060's footer prints in yellow. It then plays the same round on the
`colours` tape and asserts that the permanent colours stay BRIGHT white on
black, the footer is white, the grid is green, and the cross and winning line
keep their own colours. `audit.py` also checks the listings: only lines 10 and
8000 of `colours` contain a colour statement, against six lines in `finished`.

The `finished` game was accepted after human play; `colours` changes only how colour is applied and has emulator evidence; the intermediate stages have
emulator evidence, not independent learner testing or original-hardware timing.
Native feedback was that it works well and mostly produces draws. That is play
feedback, not a measured outcome frequency or an unbeatable-policy claim.

## Source lineage

The recorded evidence names the SHA-256 of each listing as it was when that evidence ran. [`source-lineage/lineage.json`](../../source-lineage/README.md) links each of those hashes to the listing now here, with the proof of what changed (stored spaces removed, or a variable renamed), and the audits accept the recorded hashes through it.
