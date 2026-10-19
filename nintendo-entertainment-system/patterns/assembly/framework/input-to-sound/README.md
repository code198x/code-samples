# Input, new presses and sound: nintendo-nes

`input.inc` and `presses.inc` are reusable routines; `use.inc` shows their integration with the sound driver. Include each once, initialise state in writable memory and follow the register/resource contracts in the files. `demo.asm` is now a complete launchable caller; `check.asm` remains an assembly-only wrapper for the fragment.

## Build and run

Build with `make` in this folder, then load `build/demo.nes` on an NTSC NES configuration. Controller 1 A starts pulse 1; releasing A silences it. A new press changes the background colour. The complete reset code clears RAM, disables NMI/DMC, waits for the PPU and initialises the caller. Reset to leave.

The relative driver includes are deliberate. Keep the repository folder layout, or adjust those paths when moving the code into your own project.

## What was executed

Emu198x 0.34.2: NTSC NROM, cartridge reset, controller 1, DMC disabled. 263 input stages check held values, new-press behaviour and event counts. Five captured audio windows check release, press, hold, stop and repress while the update counter continues. A deliberately cleared history while the action remains held produces an extra event, and the same count guard rejects it.

The NES matrix covers all 256 controller masks. The simple reader assumes no DMC sample DMA. The caller owns pulse 1 and the APU enable shadow; it must not compete with an NMI/music driver. The fixed pitch targets NTSC.

Run the bounded recipe from the repository root, providing your installed emulator binaries and existing Kickstart file:

```sh
python3 scripts/verify-pattern-machine-callers.py \
  --spectrum /path/to/emu198x-spectrum \
  --nes /path/to/emu198x-nes \
  --amiga /path/to/emu198x-amiga \
  --kickstart /path/to/kick13.rom
```

Use `--only nes` to run this machine alone. Build198x defaults to PATH; `--build198x` accepts an explicit path. No firmware is distributed. Captures and logs stay in the ignored build directory. The committed receipt is `scripts/evidence/pattern-library-nes.json`. These are emulator observations on the named configurations, not original-hardware or subjective listening checks.
