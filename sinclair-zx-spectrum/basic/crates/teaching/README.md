# Crates teaching checkpoints

Complete Sinclair BASIC states for the agreed three-room game on a stock 48K ZX Spectrum, PAL. The accepted prototype remains unchanged beside this tree. These are teaching sources, not published lessons.

## Sequence

`roster.json` owns every source path, predecessor, added/replaced/deleted BASIC line and source hash. Each unit's `snippets/` contains only the new lines to enter; deletions are recorded separately. A new program does not need a redundant list of line numbers to add. Lesson 11 saves the unit 10 program unchanged.

| Unit | Runnable stages |
|---|---|
| 1 | A four-character wooden crate |
| 2 | Tile bank, stored warehouse, player overlay |
| 3 | Walking, bounds, blocked cells, count and exit |
| 4 | Floor pushes and restart |
| 5 | Targets survive crates and player overlays |
| 6 | Goal counter, then a complete single-room visit |
| 7 | The first room loaded from eight row strings |
| 8 | Map validation before entering play |
| 9 | Two rooms with explicit progression and current-room replay |
| 10 | Three rooms, two interacting crates and a fresh game |
| 11 | Fresh tape load and complete play using unit 10 unchanged |

The tile-bank stage separates string arrays and slicing from the numeric world array. [Tile source](tiles.md) shows the original sketches, quadrants and row bytes. A map cell, a character code, a pixel-row byte and an ink colour have different jobs.

The early walking stage deliberately has no restart command. Floor-only pushing cannot place a crate on a target until the following stage adds the preservation rule. Before the complete-round stage, filling a target does not freeze movement. These intermediate behaviours are part of the progression, not the finished game's rules.

## Map contract

Each map is eight DATA strings of eight characters. Spaces are not silently trimmed or accepted as floor.

| Symbol | Meaning | Stored grid value |
|---|---|---|
| `-` | Floor | 0 |
| `#` | Wall | 1 |
| `.` | Target | 2 |
| `C` | Crate on floor | 3 |
| `*` | Crate on target | 4 |
| `P` | Player on floor | 0; coordinates stored separately |
| `+` | Player on target | 2; coordinates stored separately |

Unit 7 assumes the supplied valid map. Unit 8 checks row length before indexing, known symbols, exactly one player, positive crate count and equal crate/target totals. Combined symbols count towards each applicable total. Failure displays a diagnostic and stops before play. A missing DATA item can still raise the ROM's Out of DATA report; this is not a general BASIC exception handler. Structural validity does not establish solvability. A valid map whose crates are already on every target begins completed; an empty map is rejected.

Room DATA begins at explicit lines 8000, 8100 and 8200. Graphics use RESTORE 7200. Every restart rereads the selected room and resets its counters. Selection does not depend on computing a BASIC line number from the room index.

## Differences from the accepted prototype

The endpoint decodes and validates maps instead of constructing them by repeated assignments. The three grids, starting coordinates, sprites and rules are compared with the accepted prototype's independent model. Final program bytes therefore differ intentionally.

The teaching HUD adds `GOALS filled/total`, first as a runnable counter in unit 6. This supplies a textual alternative to the green delivered-crate colour. The overview and eleven lessons, including captures of this readout, were approved in the website review. That approval is separate from the earlier native prototype playtest. Silence, single-step I/J/K/L, S start, R restart/replay, N continuation/new game and Q exit are retained.

## Reproduce and inspect

```sh
python3 verification/derive.py
python3 verification/assets.py
python3 verification/audit.py
python3 verification/verify.py --emulator /path/to/emu198x-spectrum --output /tmp/crates-teaching
python3 verification/boundaries.py --emulator /path/to/emu198x-spectrum --output /tmp/crates-teaching
python3 verification/graphics.py --emulator /path/to/emu198x-spectrum --output /tmp/crates-teaching
python3 verification/fresh_tape.py --emulator /path/to/emu198x-spectrum --output /tmp/crates-teaching
```

Derivation reconstructs each complete listing from its predecessor and edit roster. Verification enters changes through the ROM editor and caches ROM-saved, hash-checked tapes for repeat runs. It compares all world cells, positions, counts and rendered pixels with independent expectations; declared fixture edits are restored before proceeding. The final tape is saved with LINE 10. `tape.py` selects the final program from the ROM recording without changing its header or payload; a fresh default LOAD reconstructs the graphics before play. Each cached checkpoint uses a distinct tape name.

All thirteen checkpoints passed on the recorded configuration. Execution status, configuration hashes and checkpoint identities are in `verification/results.json`; separate boundary, graphics and packaged-tape records retain their additional checks. Inspected captures and their base-source and fixture associations are in `captures/manifest.json`. Neither generation nor the prototype's earlier checks prove a teaching checkpoint passed. Native host input, original hardware and learner comprehension are separate observations.

Original program, maps, graphics and tooling use this repository's MIT licence. Language sources: Vickers/Bradbeer, *ZX Spectrum BASIC Programming*, second edition (1983), chapters 4–6, 8, 12, 14–16, 18 and 20.

The recorded final teaching tape takes 30 PAL frames (0.60 seconds) for the sampled first walk and 42 frames (0.84 seconds) for the following push, including drawing and return to input. `verification/timing.json` identifies the source and tape. These are two deterministic samples, not native host-latency measurements. Run `verification/timing.py` with `--emulator`, `--tape` and `--output` to reproduce.
