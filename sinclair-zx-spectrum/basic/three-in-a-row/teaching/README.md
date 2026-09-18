# Three in a Row teaching checkpoints

Eight stock 48K PAL Sinclair BASIC programs develop the native-accepted game.
The ten lessons use `board`, `place`, `turns`, `results`, `reply`, `tactics`,
`policy`, then reuse `policy` for the fork, add `finished`, and reuse that for
saving. `finished/three.bas` is byte-identical to the accepted prototype.

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

The final game was accepted after human play; the intermediate stages have
emulator evidence, not independent learner testing or original-hardware timing.
Native feedback was that it works well and mostly produces draws. That is play
feedback, not a measured outcome frequency or an unbeatable-policy claim.
