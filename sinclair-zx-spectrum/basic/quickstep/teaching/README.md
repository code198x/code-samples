# Quickstep teaching checkpoints

Eight standalone Sinclair BASIC programs support the ten-lesson progression. Target: stock 48K PAL ZX Spectrum, keyboard and ROM-loaded tape, no machine-code helper. The finished source is identical to the accepted six-lane prototype. All eight checkpoints pass fresh-tape execution, with 96 check groups recorded in `verification/evidence/manifest.json`.

| Lesson | Checkpoint | Result |
|---|---|---|
| 1 | [board](board/quickstep.bas) | Draw a player, two safe strips and an empty lane, then stop. |
| 2 | [walk](walk/quickstep.bas) | Move one cell per press and release; preserve backgrounds and bounds. |
| 3 | [lane](lane/quickstep.bas) | SPACE advances traffic manually; contact is not yet enforced. |
| 4 | [clock](clock/quickstep.bas) | Continuous traffic, a frame target and a lane countdown; polling-only input. |
| 5 | [crossing](crossing/quickstep.bas) | Complete one-lane game with both contact checks, victory and retry. |
| 6–7 | [six-lanes](six-lanes/quickstep.bas) | Full crossing and route-planning experiment; polling-only input. |
| 8 | [buffered](buffered/quickstep.bas) | Retain a recognised short press during drawing. |
| 9–10 | [finished](finished/quickstep.bas) | Accepted title, controls and full game; save and reload the same source. |

Begin a new program at `board`. Use [the exact editing transitions](edits.md) for later checkpoints. Each folder contains the full source and machine-readable additions, replacements and deletions; later folders also contain only the lines to enter in `changes.bas`. Practice-board rows are 0–2; the final board uses rows 0–8. I/J/K/L move, R resets and Q quits in interactive stages. Only `finished` waits for S at its title.

The manual stages wait for release after a movement or SPACE command. The clocked stages repeat held directions. Before `buffered`, a short press during drawing may be missed. Buffering retains one recognised key, not an entire input history. These differences are deliberate teaching steps. `board` stops after drawing and has no movement loop.

All artwork is the original prototype UDG data. The first two checkpoints initialise only the four player characters and strip texture; the vehicle stage adds the eight vehicle characters. Collision uses numeric occupancy, including transparent artwork corners. Silence is deliberate.

## Reproduce the evidence

From this directory, with a lawfully supplied stock 48K ROM configured:

```sh
python3 verification/derive.py
python3 verification/build.py --emulator /path/to/emu198x-spectrum --output verification/evidence --jobs 4
```

For each name in `checkpoints.json`, run both trial scripts:

```sh
python3 verification/check.py --emulator /path/to/emu198x-spectrum --output verification/evidence --only board
python3 verification/frames.py --emulator /path/to/emu198x-spectrum --output verification/evidence --only board
python3 verification/audit.py
```

Run the audit after all eight names have passed. The builder enters every standalone source through fresh ROM keyboard sessions and saves self-starting tapes. Model checks use keyboard events at CPU statement boundaries; frame trials independently use ordinary video-frame execution. Neither injects game state. The audit reconstructs each exact edit transition, compares unchanged stored ROM lines, checks both tape blocks, verifies capture hashes and proves final-source identity.

Retained PNGs are original emulator output, checked against the live bitmap and attributes. The ordinary-frame trials verify the polling-only short-tap limitation, the buffered fix, held movement, fresh loading, frame-byte wraps, complete crossings, retry and quit. Timing observations describe this emulator configuration, not original hardware or input latency. Native acceptance belongs to the unchanged endpoint; intermediate sources still need learner-facing authoring and review.
