# Drift teaching checkpoints

Six standalone stock 48K PAL Sinclair BASIC programs support eight lessons. The user accepted the version with speed and direction feedback after successful native docking. The final listing is byte-identical to that prototype. Website lesson prose is not yet authored.

| Lesson | Listing | Result |
|---|---|---|
| 1. Give the ship a nose | [draw-ship](draw-ship/drift.bas) | Static triangle, arena and draw-twice erasure experiment |
| 2. Point somewhere else | [heading](heading/drift.bas) | Eight headings; position does not change |
| 3. Burn, then let go | [flight](flight/drift.bas) | Thrust, retained two-component velocity and walls |
| 4. Turn back to brake | [flight](flight/drift.bas) | Counterthrust experiment; no new source |
| 5. Read the motion | [readout](readout/drift.bas) | Speed, E/W–N/S components and the future docking speed band |
| 6. Arrive gently | [docking](docking/drift.bas) | Exact low-speed and position checks; success and retry |
| 7. Finish the flight | [finished](finished/drift.bas) | Accepted endpoint with title and start controls |
| 8. Keep the game | [finished](finished/drift.bas) | ROM saving and fresh loading; no new source |

Each directory contains its full `drift.bas`, exact `edits.json` relative to the previous checkpoint and `changes.bas` containing added/replaced lines. The first program is a new listing, not an add-line exercise. `checkpoints.json` maps checkpoint identities to lesson numbers. Counterthrust is already possible in flight: the later experiment explains that rule rather than adding a hidden brake.

The display in `readout` says SLOW below the future docking threshold; the box and DOCK OK cue arrive together in `docking`. Position, heading and velocity remain separate quantities throughout. Intermediate programs are not claimed to run at the final program's pace.

## Reproduce

With a configured Emu198x Spectrum executable and stock 48K ROM:

```sh
python3 verification/derive.py
python3 verification/build.py --emulator /path/to/emu198x-spectrum --output /tmp/drift-teaching --jobs 3
python3 verification/check.py --emulator /path/to/emu198x-spectrum --output /tmp/drift-teaching
python3 verification/render.py --emulator /path/to/emu198x-spectrum --output /tmp/drift-teaching
python3 ../prototype/verification/controls.py --emulator /path/to/emu198x-spectrum --output /tmp/drift-teaching/finished
python3 ../prototype/verification/timing.py --emulator /path/to/emu198x-spectrum --output /tmp/drift-teaching/finished
python3 verification/audit.py --evidence /tmp/drift-teaching
```

The build and check tools accept `--only <checkpoint-name>` for one stage. The derivation script is an authoring tool, not a runtime dependency. Each tape is entered through the ROM keyboard and saved independently, then loaded into a fresh process. Tests drive keys and compare read-only state with a host vector model. Captures are original PNGs checked against the current bitmap; no images are reconstructed or edited. The prototype tools supply the maintained ROM keyboard harness, read-only state decoder and endpoint control/timing checks.

Executed results and configuration-specific limitations are recorded in `verification/evidence/summary.json`. Native acceptance applies to the final game; the intermediate checkpoints and learner outcomes are separate claims.
