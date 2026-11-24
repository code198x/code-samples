# Switchyard · Game Boy DMG

Route a parcel to the marked upper depot. The same yard grows from a drawing into a one-decision game: choose a track, dispatch the parcel, and see the consequence.

## Build and play

With GNU Make and [Asm198x 0.0.75](https://github.com/asm198x/asm198x/releases/tag/asm198x-v0.0.75) on your PATH, run this from this folder:

```sh
make
emu198x-game-boy --model dmg --rom build/03-delivery.gb
```

Open each built cartridge from a fresh reset. The original program and art use a 32 KiB ROM-only cartridge (no mapper or cartridge RAM). No external artwork, assembler libraries or Game Boy firmware files are needed. In an emulator configured to supply its own boot ROM, use the stock DMG reset path instead for the qualified setup below.

| Cartridge | Try it |
| --- | --- |
| `01-junction.gb` | Edit `ROUTE_UP_TILE` in `01-junction.asm` from 2 to 4. Rebuild and reset: the upper gate's arrow becomes a diamond, with the rest of the yard unchanged. |
| `02-switch.gb` | Press **A**: the arrow moves from the lower branch to the upper one. Holding A does not repeat; release and press again to move it back. |
| `03-delivery.gb` | From reset, **Start** dispatches to the lower depot and shows an X. **B** restarts after the result. Try **A**, release, then **Start** to deliver to the marked upper depot and show a check. |

[The three learner activities](LESSONS.md) include predictions, what to inspect and what to try when an edit does not behave as expected.

## Technical boundaries

Start by reading the assembly file for the checkpoint you are playing. [`01-junction.asm`](01-junction.asm) writes a fixed tile and reads no buttons. [`02-switch.asm`](02-switch.asm) adds a route and one previous A sample in work RAM, then redraws the two gate cells. [`03-delivery.asm`](03-delivery.asm) adds a result byte: A selects before Start dispatches; after a result, only B restarts the attempt. The parcel moves to the depot immediately. There is no animation in transit, timer, sound or saving.

[`yard.inc`](yard.inc) contains the cartridge header, background setup and tile art. Setup fills the map with the LCD off; interactive updates wait for VBlank. Only the interactive checkpoints include [`joypad.inc`](joypad.inc). The Game Boy reports action-button presses as zero bits; the helper lets the selected row settle and flips the bits so one means down. The checkpoint decides whether that is a new press. See [Pan Docs on JOYP](https://github.com/gbdev/pandocs/blob/master/src/Joypad_Input.md) for the register layout.

The installed-emulator command accepts the original cartridge directly. The native proof below does not cover original hardware, browser upload, keyboard bindings, touch controls or browser editing.

## Reproduce the native proof

```sh
python3 verify.py --assembler "$(command -v asm198x)" \
  --emulator "$(command -v emu198x-game-boy)" \
  --out /tmp/switchyard-proof
```

The verifier rebuilds each cart, checks its header, starts the machine at `$0100` with an empty firmware directory, sends button press/release events, and reads the results without writing guest memory. It checks state, tile-map contents, and the rendered 8×8 pixel masks at nine named cells. It also rebuilds the junction edit and rejects a separate mutation that repeats while A is held. Captures and full machine observations go to the output directory, not into the cartridge source.

The retained [Linux x86-64 observation](verification.json) used official Asm198x 0.0.75 and [Emu198x 0.48.5](https://github.com/emu198x/emu198x/releases/tag/v0.48.5). It covers this cartridge/configuration only.
