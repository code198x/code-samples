# Meet Assembly

Seven runnable checkpoints and two deliberate fault cases support the eight
[Meet Assembly lessons](https://code198x.com/systems/sinclair-zx-spectrum/assembly/meet-assembly/).
Target: stock 48K PAL ZX Spectrum, original Z80 instructions.

| Lesson | Source | Experiment |
|---|---|---|
| 1 | `first-program.asm` | Change the border with one output value. |
| 2 | `one-byte.asm` | Follow eight bits into bitmap memory. |
| 3 | `eight-rows.asm` | Design an 8×8 character with explicit screen writes. |
| 4 | `row-loop.asm` | Preserve that picture with a counted drawing loop. |
| 5 | `draw-routine.asm` | Call one drawing routine twice; inspect its contract. |
| 6 | `move-character.asm` | Move on each O/P press, erase and redraw within bounds. |
| 7 | `clocked-character.asm` | Pace held-key movement with frame interrupts. |
| 8 | `debug-branch.asm`, `debug-trail.asm` | Investigate faulty variants of lesson 7. |

## Build and run locally

Use [Asm198x](https://asm198x.github.io/) with its Pasmo dialect and stock Z80 target:

```sh
asm198x --dialect pasmo --cpu z80 --tapbas first-program.asm -o first-program.tap
```

Or use [upstream Pasmo](https://pasmo.speccy.org/):

```sh
pasmo --tapbas first-program.asm first-program.tap
```

Substitute the source name for another experiment. Both routes produce the same
machine code; tape headers can differ. Mount the tape in a fresh 48K Spectrum,
enter `LOAD ""` and start playback. Emu198x can perform that sequence:

```sh
emu198x-spectrum --machine spectrum_48k --tape first-program.tap --autoload-tape --scale 3
```

The ROM loader establishes BASIC's memory environment and a valid return stack.
The first drawing programs stay in a hold loop. The movement experiment disables
interrupts and polls input. The clocked program explicitly establishes IY and IM 1,
then enables the ROM's interrupt service and waits with HALT. These programs do
not return to BASIC; reset or start a fresh machine for another run.

The early programs write only their selected pixels and attributes. The movement
programs clear and own the first character row. None claims to handle arbitrary
screen positions or preserve a detailed background.

## Browser route

The lessons use the real `@asm198x/z80` assembler and `@emu198x/zx-spectrum`
(version 0.4.0 or later). They install machine code in a fresh Spectrum and call
it through the ROM's CLEAR/RANDOMIZE USR path. No tape wait is needed. Source edits
only affect the machine after assembling again. Inspectors read actual RAM;
recorded writes and routine calls are labelled as recordings. Lesson 8 steps the
actual machine with normal playback paused.

Download the edited source from each lesson to keep a local copy. The browser
and tape routes use the same program bytes and different loading procedures.

## Repeat the checks

```sh
python3 verification/verify.py --pasmo /path/to/upstream/pasmo --emulator /path/to/emu198x-spectrum --output /tmp/meet-assembly-checks
```

The verifier compares Asm198x and upstream Pasmo output, loads all eighteen tapes
into fresh emulated machines, checks code and display memory, exercises movement
and timing, and confirms the two intended faults. Use `--source filename.asm`
to select one checkpoint. The JSON report records tool versions and hashes.
This is emulated 48K PAL evidence, not a physical-hardware claim.

Browser regression scripts live in the website's `scripts/verification/` folder,
including `byte-pixels.mjs`, `eight-rows.mjs`, `row-loop.mjs`,
`drawing-routine.mjs`, `movement.mjs`, `clocked-movement.mjs` and
`guided-debugger.mjs`. Run each with the site base URL and an output directory.
They check edits, actual machine state, keyboard operation and narrow layouts.
