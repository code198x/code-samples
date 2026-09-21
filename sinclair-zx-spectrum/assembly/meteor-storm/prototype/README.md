# Meteor Storm prototype

Native Z80 trial for the replacement Spectrum assembly opening. The user accepted
this native endpoint after play. The [teaching progression](../README.md) now has separately executed runnable
checkpoints. This directory preserves the accepted reference program.

Race through a fixed storm of 100 meteors and 20 collectible stars. O/P steer;
Space launches, then holding Space doubles forward speed with no cooldown.
Release Space to return to normal speed. R retries at a result; Q returns to
the title. One meteor hit ends the run immediately.

Stars award 10 points normally and 20 while boosting. Successful arrival adds
`10 × max(0, 100 − floor(elapsed seconds))` points. The result shows the run's
time and total score, plus separate fastest successful time and highest score.
Records survive retries and title returns within the running program; they are
not saved to tape or disk. Failed runs may set a score record but never a time
record. There is no extra finish bonus for a failed run.

The same course takes about 42 seconds at normal speed or 21 seconds at full
boost. Boost advances two collision-checked simulation steps per update, so
objects cannot skip the intermediate step. The elapsed timer counts PAL frames,
independently of course progress. Shorter reaction time is the cost of boosting.

## Build and run

Run from this directory, with Asm198x on PATH:

```sh
python3 assets.py
asm198x --dialect pasmonext --cpu z80 --tapbas meteor-storm.asm -o meteor-storm.tap
emu198x-spectrum --machine spectrum_48k --tape meteor-storm.tap --autoload-tape --scale 3
```

The target is stock PAL 48K hardware. Code starts at 32768, the stack at $FCF0.
A private IM2 interrupt increments the frame clock, with the vector table at
$FE00–$FF00 and a jump at $FDFD. Simulation runs every second frame (25 Hz).
The ROM font supplies text; game input and timing do not call ROM routines.

The original sprites and scattered event schedule are maintained in `assets.py`; `assets.inc`
is generated. Collision reads position data and inset rectangles. A 20-object
pool has at most nine active meteors under the schedule. Each stores X, Y,
kind/activity, downward speed (2–5 pixels per update) and gentle sideways drift
(-1, 0 or +1 pixel every four updates), reflecting at the edges. Stars fall
straight down regardless of their event-table drift byte. The event table mixes
meteors and visibly distinct stars, with reproducible random positions and drift. Sprites use XOR drawing
and pre-shifted pixel artwork, allowing overlapping trajectories. Unlimited boost doubles course progress, movement and encounter arrival rate.
Stars stay vertical; meteor drift remains one pixel per four course steps.
These are prototype implementation
choices, not an agreed lesson sequence.

## Verification

```sh
python3 verification/model.py
python3 verification/verify.py --emulator /path/to/emu198x-spectrum --output verification/evidence
```

The independent tick model finds a damage-free route and checks all 109 possible
stationary positions: none survives. The native harness uses keyboard input and
ordinary emulator frames, reading state without altering it. It checks movement,
first-hit loss, retry, star scoring and score retention, a complete undamaged passage, object limits, frame
cadence and a separate fresh ROM tape load. It reuses the existing Meet BASIC
verification transport from this samples repository.

`verification/evidence/results.json` identifies the tested source, tape and
emulator. Captures, the keyboard route and impact audio accompany the report.
Sound is captured; listening and human judgement of responsiveness, readability
and difficulty remain part of play review. No lesson or publication acceptance
is implied by automated checks.
