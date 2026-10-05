# The Caverns teaching checkpoints

Nine stock 48K PAL Sinclair BASIC programs develop the game. Eleven lessons
use `room`, `map`, `walk`, `treasure`, `pit`, `patrol`, reuse `patrol` to
trace arrival and escape, add `expedition`, then `finished`, reuse `finished`
for saving, and end with `steady`. The finished source is byte-identical to
the accepted prototype at samples commit `7c3fcfe`. `steady` is that game with
the per-turn screen flash removed, and is the final program.

`checkpoints.json` records exact additions, replacements and deletions.
`changes.bas` contains ordinary lines to enter; the lessons state deletions
separately. The first listing is a new program.

## Reproduce

Set `EMU198X_SPECTRUM` to a built Spectrum executable with its lawful 48K ROM
configured. Run from this directory:

```sh
python3 verification/build.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence --jobs 4
python3 verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence --jobs 4
for name in finished steady; do
  cp ../prototype/verification/evidence/model.json verification/evidence/$name/model.json
  python3 ../prototype/verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence/$name --source $name/caverns.bas
done
python3 verification/flicker.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
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
Steady draws the fixed frame once and overprints only what a turn changes,
padding text so a shorter line covers a longer one, instead of clearing the
screen every turn.

`flicker.py` plays the same keys on `finished` and `steady`, reading the screen
after every frame of each turn. A frame in which a line that holds text before
and after the turn is blank counts as a flash. `finished` must flash on every
turn that redraws, which shows the check can fail; `steady` must never flash;
and both must show the same colour at every pixel after every action, so
overprinting leaves nothing stale and every ending and warning looks the same.
It reads display memory once per frame, so a change undone within one frame
would go unseen. It also saves the mid-turn pictures the lesson shows.

The reader can encounter the ROM relocating its string-variable table during
INKEY$. It advances one emulated frame and retries, with a strict eight-retry
limit, when a snapshot is incomplete. `verification/evidence/input-sampling.json`
records the observed case and the complete state one frame later. Retry counts
are retained in stage results. This changes observation timing, not game state.

All execution check groups pass; `verification/evidence/manifest.json` records
them. Native feedback accepted the finished game; `steady` has emulator
evidence that it plays the same game, not native acceptance of its own.
Intermediate programs have emulator evidence, not independent learner testing
or original-hardware timing measurements.

## Source lineage

The recorded evidence names the SHA-256 of each listing as it was when that evidence ran. [`source-lineage/lineage.json`](../../source-lineage/README.md) links each of those hashes to the listing now here, with the proof of what changed (stored spaces removed, or a variable renamed), and the audits accept the recorded hashes through it.
