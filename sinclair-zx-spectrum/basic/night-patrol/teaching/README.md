# Night Patrol — teaching checkpoints

Eight standalone Sinclair BASIC programs support the agreed ten-lesson
progression in `docs/platforms/sinclair-zx-spectrum/games/night-patrol/lesson-brief.md`.
Target: stock 48K PAL Spectrum with a configured ROM. Deliberate silence.

| Checkpoint | Behaviour and temporary limits |
|---|---|
| archive | Draws the 30 × 18 map, file and entrance; stops to BASIC. No player or controls yet. |
| movement | I/J/K/L and uppercase equivalents move through corridors; walls block; held keys repeat. R resets, Q quits. No pickup or danger yet. |
| mission | Take the file and return to win. Results freeze; release before R/Q. No guard yet. |
| patrol | A guard walks independently and catches by contact. No field of view or corner scans yet. |
| scans | Position/facing records add eight stationary corner looks per circuit. Still contact-only danger. |
| sight | A labelled diagnostic stage: guard fixed at (7,5), facing east. Its opening fan uses a logical mask and PRINT/PAPER. Movement into sight causes capture. |
| stealth | Restores the moving patrol and scans with prepared visibility changes and attribute updates. Complete mission and retry; no title or short-key buffering yet. |
| finished | Byte-identical to the approved prototype, including title, legend, input buffering and complete controls. |

The archive checkpoint ends with `9 STOP statement, 20:1`; this is its deliberate
STOP, not a failed map draw. Movement introduces a key-release wait for R, and
mission reuses it for the result menu.

Lesson 7 reuses sight while explaining prepared changes. Lesson 10 reuses
finished for saving and recovery. The finished source approval hash is
`72d436d316de7f278934846d68bc0c7b2125509c105fc3135a89cbd0ddbd5ae8`.

Each folder has a complete `night-patrol.bas` and a `changes.bas` containing
exact additions/replacements since the preceding checkpoint. `checkpoints.json`
lists additions, replacements and deletions separately. For the opening, enter
the full new program. In later stages, remove listed lines by entering their
line numbers alone, then enter `changes.bas`. The transition audit reconstructs
each complete source from these instructions. Removing the moving patrol for
the sight diagnostic and restoring it afterwards are explicit editing stages.

## Prepared data

`data/patrol-positions.bas` is the scans checkpoint's position/facing table.
`data/opening-sight.bas` supplies the hand-explained initial mask.
`data/sight-changes.bas` supplies the final patrol's full change records.
`data/worked-example.json` decodes the first movement into cells added, removed
and retained. These are extracted teaching materials, not extra files the
Spectrum must load: the complete listings already contain their DATA.

The first record changes five cells but leaves ten visible. The logical mask
owns detection; screen colours display it. Recalculate the prepared data when
changing the map, patrol or fan. The optional generator lives at
`../prototype/verification/level.py`; understanding or running Python is not
required to follow the supplied BASIC checkpoints. Do not alter the approved
prototype casually while experimenting with a teaching copy.

## Reproduce

Set `EMU198X_SPECTRUM` to the native executable with a configured 48K ROM, then
run from this directory:

```sh
python3 verification/build.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence --jobs 2
python3 verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence --jobs 2
python3 verification/audit.py
```

For diagnostic images, run `verification/capture.py` with the same emulator
and output arguments; it accepts `--jobs` and `--only` too.

Both build and check accept `--only <checkpoint>`. Every build starts in a fresh
ROM, enters the complete listing with keyword keys and saves an auto-starting
TAP. Checks load those tapes fresh and use ordinary key input with read-only
state observation. Host route search supplies input sequences; it never writes
a winning state into the emulator. The finished tape receives the full approved
prototype suite. Intermediate stages have their own rule models and checks.

After CPU debug stepping, checks advance against the ROM interrupt counter;
ordinary frame runs do not consistently advance from that state in the recorded
binary. Debug-stepped PNGs can be blank, so they are not public lesson media.
For an ordinary-frame capture of finished, run the prototype's `capture.py`
with `--output verification/evidence/finished` and the same emulator argument.

Execution records distinguish native behaviour from learner review. Teaching
pages and publication are separate from these samples.
