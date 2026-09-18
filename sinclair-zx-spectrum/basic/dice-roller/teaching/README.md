# Dice Roller teaching checkpoints

Five complete Sinclair BASIC programs develop the accepted probability
prototype. Use stock 48K PAL ZX Spectrum configuration with a supplied ROM.

| Checkpoint | Result | Temporary limit |
|---|---|---|
| roll | Twelve numbered die rolls | Stops to BASIC; no tallies |
| tally | Six counts totalling twelve | Final table after numbered rolls |
| shares | Counts and rounded percentages | Final table; no bars |
| live | Counts, shares and fixed-scale bars as rolls arrive | Twelve rolls; Q stops early; RUN starts again |
| finished | Batch choice, fresh/add, previous comparison and limits | Accepted prototype, unchanged |

The opening listing is a new program. For later stages, `checkpoints.json`
names the exact additions, replacements and deletions; each `changes.bas`
contains only the lines to enter. Complete programs are `dice-roller.bas`.
The source audit reconstructs every transition. Do not enlarge the early
numbered-roll programs past the screen: larger batches are introduced through
the finished menu.

Set `EMU198X_SPECTRUM` to the native emulator executable and run here:

```sh
python3 verification/build.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence --jobs 2
python3 verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
python3 verification/audit.py
"$EMU198X_SPECTRUM" --machine spectrum_48k --tape verification/evidence/live/dice-roller.tap --autoload-tape --scale 3
```

Every checkpoint is entered in a fresh ROM through keyword keys and saved as
an auto-starting TAP. Checks load those tapes in new emulator processes and
observe memory without writing it. Intermediate checks cover counted results,
percentage rounding, two live updates, early stop and fresh RUN. The finished
checkpoint receives the prototype's complete checks, including its labelled
ROM-command boundary fixtures. Audit binds source, saved tokens, tape checksums,
execution records and emulator identity; the final source is byte-identical to
the approved prototype.

Execution evidence is specific to this emulator configuration, not independent
learner review or original-hardware timing. The prototype's known headless
capture issue remains: retained PNGs are diagnostic, not public lesson media.
The teaching specification is in the docs repository at
`platforms/sinclair-zx-spectrum/games/dice-roller/lesson-brief.md`.
