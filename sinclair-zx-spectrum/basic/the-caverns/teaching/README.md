# The Caverns teaching checkpoints

Eight stock 48K PAL Sinclair BASIC programs develop the native-accepted game.
Ten lessons use `room`, `map`, `walk`, `treasure`, `pit`, `patrol`, reuse
`patrol` to trace arrival and escape, add `expedition`, then `finished`, and
reuse `finished` for saving. The finished source is byte-identical to the
accepted prototype at samples commit `7c3fcfe`.

`checkpoints.json` records exact additions, replacements and deletions.
`changes.bas` contains ordinary lines to enter; the lessons state deletions
separately. The first listing is a new program.

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

Each build enters a complete listing in a fresh ROM using keyword keys and
records `SAVE "caverns" LINE 10`. Execution checks load that tape in a separate
process. Memory observations are read-only; no game state is injected.
The audit checks editing transitions, literal targets, unchanged token bytes,
tape checksums, auto-start, evidence hashes and final-source identity.

The first two programs deliberately STOP after drawing. Walking initially
makes every room safe; treasure adds one-time collection without an objective;
pit adds a loss; patrol adds the moving creature and an escape turn. Expedition
adds returning all three treasures to the entrance. Finished adds the title.

The reader can encounter the ROM relocating its string-variable table during
INKEY$. It advances one emulated frame and retries, with a strict eight-retry
limit, when a snapshot is incomplete. `verification/evidence/input-sampling.json`
records the observed case and the complete state one frame later. Retry counts
are retained in stage results. This changes observation timing, not game state.

All 97 execution check groups pass. Native feedback accepted the finished
game. Intermediate programs have emulator evidence, not independent learner
testing or original-hardware timing measurements.
