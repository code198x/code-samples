# Input, new presses and sound: sinclair-zx-spectrum

`input.inc` and `presses.inc` are reusable routines; `use.inc` shows their integration with the sound driver. Include each once, initialise state in writable memory and follow the register/resource contracts in the files. `demo.asm` is now a complete launchable caller; `check.asm` remains an assembly-only wrapper for the fragment.

## Build and run

Build with `make` in this folder. Load `build/demo.tap` with the 48K ROM's `LOAD ""`, or use `build/demo.sna` for a quick start. QAOP moves the held-control bits; a new Space press plays one short click and changes the border. Holding Space does not retrigger. The demo enables the ROM interrupt only around `HALT`, then disables it before input and the blocking beep. Reset to leave.

The relative driver includes are deliberate. Keep the repository folder layout, or adjust those paths when moving the code into your own project.

## What was executed

Emu198x 0.32.5: 48K PAL, snapshot startup; ROM tape boot checked separately. 39 input stages check held values, new-press behaviour and event counts. Five captured audio windows check release, press, hold, stop and repress while the update counter continues. A deliberately cleared history while the action remains held produces an extra event, and the same count guard rejects it.

The Spectrum matrix covers all 32 QAOP/Space masks. A separate fresh ROM tape load also responds to Space, keeps its count stable while held and responds again after release. The beeper blocks only for the click; `use.inc` itself keeps interrupts disabled. The full demo explicitly enables the ROM interrupt before each HALT.

Run the bounded recipe from the repository root, providing your installed emulator binaries and existing Kickstart file:

```sh
python3 scripts/verify-pattern-machine-callers.py \
  --spectrum /path/to/emu198x-spectrum \
  --nes /path/to/emu198x-nes \
  --amiga /path/to/emu198x-amiga \
  --kickstart /path/to/kick13.rom
```

Use `--only spectrum` to run this machine alone. Build198x defaults to PATH; `--build198x` accepts an explicit path. No firmware is distributed. Captures and logs stay in the ignored build directory. The committed receipt is `scripts/evidence/pattern-library-spectrum.json`. These are emulator observations on the named configurations, not original-hardware or subjective listening checks.
