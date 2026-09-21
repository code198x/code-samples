# Meteor Storm — runnable teaching progression

Seventeen complete programs develop the accepted 48K PAL game from small
experiments. These are teaching checkpoints, **not a fixed lesson count**.
Split explanations further wherever one change needs its own experiment.
Meet Assembly supplies the immediate background: bytes, bitmap addresses, loops,
calls, flags, bounded keyboard movement and the debugger.

The original [accepted prototype](prototype/README.md) is retained unchanged.
The [finished teaching source](checkpoints/finished/meteor-storm.asm) removes
obsolete recovery machinery and an unused erasure routine. It is not byte-identical
to the prototype. Native evidence compares its gameplay with that reference.

## Progression

| Checkpoint | New observable result |
|---|---|
| [one-row-shift](checkpoints/one-row-shift/README.md) | Carry a pixel into the next byte |
| [eight-shifts](checkpoints/eight-shifts/README.md) | Prepare all eight offsets |
| [pixel-motion](checkpoints/pixel-motion/README.md) | Move the ship between character columns |
| [interrupt-clock](checkpoints/interrupt-clock/README.md) | Count interrupts without a game |
| [half-rate-clock](checkpoints/half-rate-clock/README.md) | Separate display frames from updates |
| [clocked-steering](checkpoints/clocked-steering/README.md) | Give the ship a measured rate |
| [one-meteor](checkpoints/one-meteor/README.md) | Keep two positions independent |
| [first-dodge](checkpoints/first-dodge/README.md) | Decide contact from geometry |
| [object-pool](checkpoints/object-pool/README.md) | Trace independent records |
| [fixed-course](checkpoints/fixed-course/README.md) | Read a complete event schedule |
| [drift](checkpoints/drift/README.md) | Move sideways more slowly |
| [stars](checkpoints/stars/README.md) | Make an object kind change the rules |
| [timed-course](checkpoints/timed-course/README.md) | Measure time independently of progress |
| [boost](checkpoints/boost/README.md) | Check both steps of a faster update |
| [render-budget](checkpoints/render-budget/README.md) | Save drawing work without losing contacts |
| [records](checkpoints/records/README.md) | Separate one run from a session |
| [finished](checkpoints/finished/README.md) | Make the complete game explain itself |

## Build and run

Each checkpoint directory contains `meteor-storm.asm` and, when required, its own
`assets.inc`. Build inside the chosen directory with [Asm198x](https://asm198x.github.io/):

```sh
asm198x --dialect pasmonext --cpu z80 --tapbas meteor-storm.asm -o meteor-storm.tap
emu198x-spectrum --machine spectrum_48k --tape meteor-storm.tap --autoload-tape --scale 3
```

Or assemble with upstream Pasmo:

```sh
pasmo --tapbas meteor-storm.asm meteor-storm.tap
```

The explicit `--cpu z80` selects the original CPU, even with the pasmonext dialect.
Verification also compares Asm198x and upstream Pasmo raw machine code for every
checkpoint. A tape loads through the ROM; a `--sna` snapshot starts directly and
is useful during investigation. Both start at 32768. These programs do not return
to BASIC: use the stated retry control, or reset/reload for a new program.

Generated sprite/event data is checked in, so building needs no Python step.
To regenerate it deliberately, run `python3 assets.py` here. The hand-worked
shift programs come before these generated tables. The accepted prototype's
asset generator is separate and preserved as evidence.

## Investigation and verification

Each checkpoint's README gives the change, a prediction to check, controls and
a repeat route. [contracts.md](contracts.md) describes helper inputs, outputs,
clobbers and limits. The full lesson prose and browser activities remain to be
authored against these executed sources; there is no new public module yet.

```sh
python3 verification/checkpoints.py --emulator /path/to/emu198x-spectrum \
  --pasmo /path/to/upstream/pasmo --output /tmp/meteor-checkpoints
python3 verification/boundaries.py --emulator /path/to/emu198x-spectrum \
  --output /tmp/meteor-boundaries
python3 verification/endpoint.py --emulator /path/to/emu198x-spectrum \
  --output /tmp/meteor-endpoint
```

The first suite builds all programs and checks bit shifts, clocks across wrap,
movement bounds and clean erasure, first-dodge outcomes, independent courses,
star pickups, retries and measured cadence. Its independent host model chooses
keyboard steering; it does not write state to manufacture a successful run.
The endpoint suite additionally checks exact title pixels, boost release,
vertical stars, gentle drift, first-hit loss, timing, score/time records and a
fresh ROM tape load. Evidence identifies source/assets/emulator hashes.
These are emulator results, not physical-hardware tests. Impact audio is captured;
no independent listening claim is made for these captures.
