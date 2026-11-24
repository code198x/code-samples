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

The setup fills the BG tile map, copies ten original tiles with the LCD off, and reserves `$C000–$C002` for route, previous button sample and result. The main loop changes six tile-map cells at VBlank. It samples JOYP using the action row and stores the previous sample even on release. A is accepted only before dispatch; Start commits the selected route and draws the result immediately. There is no in-flight animation, timer, sound, save support or assertion about original hardware. B only resets a completed delivery attempt.

The three entry files select checkpoints from the same commented `yard.inc`; this isn't a dependency on another game's sources. The installed-emulator command above accepts the original cartridge directly. Browser upload, keyboard bindings, touch support, and browser editing are separate from the native result.

## Reproduce the native proof

```sh
python3 verify.py --assembler "$(command -v asm198x)" \
  --emulator "$(command -v emu198x-game-boy)" \
  --out /tmp/switchyard-proof
```

The verifier rebuilds each cart, checks its header, starts the machine at `$0100` with an empty firmware directory, sends button press/release events, and reads the results without writing guest memory. It checks state, tile-map contents, and the rendered 8×8 pixel masks at nine named cells. It also rebuilds the junction edit and rejects a separate mutation that repeats while A is held. Captures and full machine observations go to the output directory, not into the cartridge source.

The retained [Linux x86-64 observation](verification.json) used official Asm198x 0.0.75 and [Emu198x 0.48.5](https://github.com/emu198x/emu198x/releases/tag/v0.48.5). It covers this cartridge/configuration only.
