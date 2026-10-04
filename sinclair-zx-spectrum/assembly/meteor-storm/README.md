# Meteor Storm — runnable teaching progression

Thirty-five complete programs develop the accepted 48K PAL game from small
experiments, then extend it with sound, a destroyed phase, colour bands, a
voyage of five storms, a two-byte score, a bonus multiplied by the storm,
harder storms, a voyage record and an attract mode, and package it on a tape
with a loading screen. These are teaching checkpoints, **not a fixed lesson count**.
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
| [pixel-address](checkpoints/pixel-address/README.md) | Find a pixel’s bitmap address |
| [draw-ship](checkpoints/draw-ship/README.md) | Draw one stationary ship |
| [pixel-motion](checkpoints/pixel-motion/README.md) | Move the ship between character columns |
| [interrupt-clock](checkpoints/interrupt-clock/README.md) | Count interrupts without a game |
| [half-rate-clock](checkpoints/half-rate-clock/README.md) | Separate display frames from updates |
| [clocked-steering](checkpoints/clocked-steering/README.md) | Give the ship a measured rate |
| [one-meteor](checkpoints/one-meteor/README.md) | Keep two positions independent |
| [first-dodge](checkpoints/first-dodge/README.md) | Decide contact from geometry |
| [phases](checkpoints/phases/README.md) | Give the game a title, a flight and a result |
| [object-records](checkpoints/object-records/README.md) | Give each meteor its own record |
| [object-pool](checkpoints/object-pool/README.md) | Walk the pool and reuse a slot |
| [fixed-course](checkpoints/fixed-course/README.md) | Read a complete event schedule |
| [drift](checkpoints/drift/README.md) | Move sideways more slowly |
| [star-pickups](checkpoints/star-pickups/README.md) | Make an object kind change the rules |
| [stars](checkpoints/stars/README.md) | Print the score as decimal digits |
| [elapsed-time](checkpoints/elapsed-time/README.md) | Measure time independently of progress |
| [timed-course](checkpoints/timed-course/README.md) | Show the time as seconds and hundredths |
| [boost](checkpoints/boost/README.md) | Check both steps of a faster update |
| [render-budget](checkpoints/render-budget/README.md) | Save drawing work without losing contacts |
| [records](checkpoints/records/README.md) | Separate one run from a session |
| [finished](checkpoints/finished/README.md) | Make the complete game explain itself |
| [tone](checkpoints/tone/README.md) | Turn the impact click into an audible tone |
| [sound-table](checkpoints/sound-table/README.md) | Give star, boost, arrival and impact their own sounds |
| [sound-frames](checkpoints/sound-frames/README.md) | Play star and boost sounds while the storm keeps moving |
| [debris](checkpoints/debris/README.md) | Break the ship apart before the result |
| [colour-bands](checkpoints/colour-bands/README.md) | Colour the storm by place, not by object |
| [voyage](checkpoints/voyage/README.md) | Cross five storms, each from its own event table |
| [two-byte-score](checkpoints/two-byte-score/README.md) | Count the whole voyage's score without wrapping |
| [storm-bonus](checkpoints/storm-bonus/README.md) | Multiply each storm's bonus by its number |
| [harder-storms](checkpoints/harder-storms/README.md) | Give each storm its own speed, density, drift and colours |
| [furthest-storm](checkpoints/furthest-storm/README.md) | Keep the furthest voyage as the session record |
| [attract](checkpoints/attract/README.md) | Play the first storm behind a flashing title |
| [loading-screen](checkpoints/loading-screen/README.md) | Load a picture before the game |

## Build and run

Each checkpoint directory contains `meteor-storm.asm` and, when required, its own
`assets.inc`. Build inside the chosen directory with [Asm198x](https://asm198x.github.io/):

```sh
asm198x --dialect pasmo --cpu z80 --tapbas meteor-storm.asm -o meteor-storm.tap
emu198x-spectrum --machine spectrum_48k --tape meteor-storm.tap --autoload-tape --scale 3
```

Or assemble with upstream Pasmo 0.5.5:

```sh
pasmo --tapbas meteor-storm.asm meteor-storm.tap
```

The lessons use the pasmo dialect; `--dialect pasmonext` assembles every checkpoint
to identical bytes. The explicit `--cpu z80` selects the original CPU.
Verification can also compare Asm198x's raw machine code with an upstream Pasmo
0.5.5 build for every checkpoint, and records the Pasmo banner. A tape loads through
the ROM; a `--sna` snapshot starts directly and is useful during investigation. Both start at 32768. These programs do not return
to BASIC: use the stated retry control, or reset/reload for a new program.

Generated sprite/event data is checked in, so building needs no Python step.
To regenerate it deliberately, run `python3 assets.py` here. The hand-worked
shift programs come before these generated tables. The accepted prototype's
asset generator is separate and preserved as evidence.

## Investigation and verification

Each checkpoint's README gives the change, a prediction to check, controls and
a repeat route. [contracts.md](contracts.md) describes helper inputs, outputs,
clobbers and limits. The published lessons, Meteor Storm in the Code198x ZX
Spectrum assembly curriculum, build from these sources; each `unit-NN` folder
stages the checkpoint its lesson runs. A checkpoint contains only what its unit
and the units before it teach. `python3 verification/teaching_order.py` lists
the labels and constants each checkpoint adds, for checking against the lessons.

```sh
python3 verification/checkpoints.py --emulator /path/to/emu198x-spectrum \
  --pasmo /path/to/upstream/pasmo --output /tmp/meteor-checkpoints
python3 verification/boundaries.py --emulator /path/to/emu198x-spectrum \
  --output /tmp/meteor-boundaries
python3 verification/endpoint.py --emulator /path/to/emu198x-spectrum \
  --output /tmp/meteor-endpoint [--checkpoint tone|sound-table|sound-frames|debris|colour-bands]
```

The first suite builds all programs and checks bit shifts, clocks across wrap,
movement bounds and clean erasure, first-dodge outcomes, phases and key release,
independent courses, star pickups, retries and measured cadence. Its independent host model chooses
keyboard steering; it does not write state to manufacture a successful run.
The endpoint suite additionally checks exact title pixels, boost release,
vertical stars, gentle drift, first-hit loss, timing, score/time records and a
fresh ROM tape load. Evidence identifies source/assets/emulator hashes.
The endpoint suite runs against `finished` by default. `tone`, `sound-table`,
`sound-frames`, `debris` and `colour-bands` keep its rules, so `--checkpoint` runs the same checks, including the comparison
with the accepted prototype's route, times and scores, against them. For `debris` and
`colour-bands` the lost path first waits for the destroyed phase to end.
For `colour-bands` the first suite also checks that every cell of each
character row holds that row's byte from `row_colours` on the title, in flight,
during debris and at the result, and that no attribute changes during a course.
`voyage` changes the rules (clear space leads into the next storm), so the endpoint
suite, which replays the accepted single-storm route, does not apply to it. The
first suite flies it instead: the host model finds a keyboard route through each
of the five courses, and the suite checks that every storm is crossed, that each
later storm starts on an empty playfield with the ship centred and the clock and
course step at zero, that the HUD names each storm, that each storm stays under
100 seconds and that the one-byte score wraps. From `two-byte-score` on it checks
instead that the score counts the whole voyage without wrapping, and reads the
HUD's and the result's score lines back from the bitmap. From `storm-bonus` on it
checks that each clear space adds the bonus times the storm's number and reads
each bonus line back. From `harder-storms` on the host model reads each storm's
rules from the program, the routes follow them, and the suite checks each
storm's colour table in every cell and every object's speed. From
`furthest-storm` on it checks that a whole voyage becomes the record, that a
later idle loss leaves it alone and that the title shows it. From `attract` on it
checks the flashing prompt row, that objects fall behind the title with nothing
to hit, that a whole attract course leaves the title bitmap exactly as drawn,
and that a launch starts on an empty playfield.

`verification/tape.py` builds unit 35's tape (loader, SCREEN$, game) and loads
it through a fresh 48K ROM with `LOAD ""`: the loader blanks the screen, the
SCREEN$ lands byte for byte, nothing prints over it while the game loads, and
the game reaches its title. It needs `build198x` for the BASIC loader
(`--build198x`).
These are emulator results, not physical-hardware tests. Impact audio is captured;
no independent listening claim is made for these captures.
