# Yearfall teaching checkpoints

Eleven stock 48K PAL Sinclair BASIC programs develop the accepted game across
thirteen lessons. The final `finished/yearfall.bas` is byte-identical to the
prototype at samples commit `03afc02`. The shortage lesson reuses `trade`; the
saving lesson reuses `finished`.

`checkpoints.json` records exact additions, replacements and deletions. Each
`changes.bas` contains ordinary lines to enter; lessons state deletions separately.
The first listing is a new program. See the documentation's lesson brief for the
purpose and temporary limits of every stage.

## Reproduce

Set `EMU198X_SPECTRUM` to a built executable with its lawful 48K ROM configured.
Run from this directory:

```sh
python3 verification/build.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence --jobs 4
python3 verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence --jobs 4
python3 ../prototype/verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence/finished
python3 verification/audit.py
```

Each build enters the complete source through ROM keyword keys in a fresh
process and records `SAVE "yearfall" LINE 10`. Checks load that tape in a
separate process. Memory observation is read-only; incomplete snapshots during
string updates are retried for at most eight frames.

The first four stages deliberately STOP. Food/seed experiments edit stated
lines through the ROM, then restore them. The shortage fixture uses explicit
ROM LET commands after quitting, then ordinary game keys; it supplies no public
image. Deterministic multi-year runs use `RANDOMIZE 17` and `RUN 200`. Every such
setup is distinct from an unmodified title-to-game playthrough. Results record
fixtures and source/executable identities.

The accepted final game has native play feedback. Intermediate stages have
configuration-specific emulator evidence, not independent learner acceptance or
original-hardware timing. The four-digit editor remains a practical limit for
very long runs. No claim of unlimited settlement size or guaranteed recovery is
made.
