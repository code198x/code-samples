# Brick Bash prototype

A stock 48K PAL Spectrum BASIC game: clear eighteen bricks with one ball and a horizontal paddle. Native play feedback: “That works, it's surprisingly tough”. The agreed ten-lesson progression now has [nine executed teaching checkpoints](../teaching/README.md); the final listing is identical to this prototype.

S starts, O/P move, SPACE serves, R restarts the round and Q quits. Catching the ball with the left, centre or right of the paddle sends it left, vertically or right. A miss ends the attempt; retry restores the whole wall.

Load [the recorded tape](verification/bricks.tap) with `LOAD ""` through the Spectrum ROM. [The source](brick-bash.bas) uses pixel coordinates and a 3×6 brick array for collision. Six original UDGs provide the brick and paddle artwork. The game is silent.

## Build and verification

With an Emu198x Spectrum executable and its stock 48K ROM configured, run from this directory:

```sh
python3 verification/build.py --emulator /path/to/emu198x-spectrum --output /tmp/brick-bash-review
python3 verification/check.py --emulator /path/to/emu198x-spectrum --output /tmp/brick-bash-review
python3 verification/controls.py --emulator /path/to/emu198x-spectrum --output /tmp/brick-bash-review
```

The builder enters ROM keyboard tokens and records `SAVE "bricks" LINE 10`. It reuses the maintained Meet BASIC entry harness; verification reuses Tail Chase's read-only BASIC state decoder. Fresh tape sessions use keyboard input without game-state injection.

[Main results](verification/results.json) and [control results](verification/controls.json) contain fourteen passed checks: loading, held movement and clamps, miss, retry, complete clearance, frozen completion, all three return zones, one-pixel paddle-edge contacts, restart during flight and quitting from every phase. Each observed move is compared with an independent rectangle-scanning model. Full playfield bitmap comparisons check remaining artwork and stray pixels in ready, miss and completion states. [The manifest](verification/manifest.json) identifies the source, checksum-verified tape and four visually inspected captures.

Movement observations had a median of 20 PAL frames, ranging from 18 to 25. These are commit/drawing boundaries, not a fixed update period or host input latency. Native feedback establishes that the game worked in this trial; original-hardware performance and learner outcomes remain untested.
