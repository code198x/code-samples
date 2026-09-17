# Drift prototype

A stock 48K PAL Sinclair BASIC steering and docking trial. Turn, burn, coast and turn back to brake. Move the whole ship inside the docking box almost stopped; hitting an arena wall ends the attempt.

S starts. O/P rotate anticlockwise/clockwise; SPACE applies thrust. Turning and thrust are separate actions. R restarts and Q quits. Heading does not determine existing motion: releasing thrust preserves velocity. The prototype has one arena, one dock, eight headings and a speed cap, with no automatic drag.

The source computes direction vectors and original triangle artwork once at startup. Flight uses table lookups, pixel drawing and geometric checks. No machine-code helper, colour collision or external assets are required. The game is silent.

Build a ROM-saved tape with a configured Emu198x Spectrum executable:

```sh
python3 verification/build.py --emulator /path/to/emu198x-spectrum --output /tmp/drift-review
```

The builder reuses the maintained Meet BASIC keyboard harness. Load the resulting `drift.tap` with `LOAD ""`. The user docked successfully in native play but found speed hard to read. The revised readout is pending play review; teaching stages are not yet agreed.

The retained [tape](verification/drift.tap) is self-starting. Very short key taps can fall between BASIC polls; hold a turn or burn briefly. There is no dedicated brake key: turn against your motion and thrust.

The top row shows speed in pixels per update and **DOCK OK** or **TOO FAST**. DOCK OK means the speed condition is met; you still need to enter the box. The lower DRIFT row shows east/west and north/south velocity components. Numbers are rounded to tenths, while the docking cue uses the exact game rule. Values update after a burn or reset, because coasting and turning preserve velocity.

## Verification

```sh
python3 verification/check.py --emulator /path/to/emu198x-spectrum --output /tmp/drift-review
python3 verification/controls.py --emulator /path/to/emu198x-spectrum --output /tmp/drift-review
python3 verification/timing.py --emulator /path/to/emu198x-spectrum --output /tmp/drift-review
```

The main checker reuses Tail Chase's read-only BASIC decoder and compares 360 updates against a host vector model. It covers rotation, coasting, counterthrust, the speed cap, four walls, restart and a complete two-axis docking flight. Additional trials cover held turning, fast dock passage and title exit. Ordinary-frame execution separately checks thrust, coasting, restart and exit after a crash.

At rest, 40 complete movement-commit intervals had a median of 19 PAL frames and range 19–20: about 2.6 updates per second. Held thrust had a median of 44 frames across eight observed intervals, including the transition into burning. Updating the readout costs time during thrust. These observations are not a fixed flight rate or host-input latency measurement. The state-model checks use instruction stepping; their session clock is not a timing benchmark. The user reported successful native docking before the readout revision; this revision awaits play feedback. Original-hardware performance remains unverified.
