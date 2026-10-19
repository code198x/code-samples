# Input, new presses and sound: commodore-amiga

`input.inc` and `presses.inc` are reusable routines; `use.inc` shows their integration with the sound driver. Include each once, initialise state in writable memory and follow the register/resource contracts in the files. `demo.asm` is now a complete launchable caller; `check.asm` remains an assembly-only wrapper for the fragment.

## Build and run

Build with `make` in this folder, with Asm198x and Build198x on PATH. Boot `build/demo.adf` on an A500 OCS PAL configuration with Kickstart 1.3. Physical port 2 Fire starts the looping sample; release stops DMA. A new press changes the background. The demonstration takes over custom interrupts, DMA, channel 0 and the input port; reset to leave. Its counters expose each direction/Fire edge while the normal frame loop keeps running.

The relative driver includes are deliberate. Keep the repository folder layout, or adjust those paths when moving the code into your own project.

## What was executed

Emu198x 0.34.2: A500 OCS PAL, Kickstart 1.3, cold ADF boot, physical port 2. 25 input stages check held values, new-press behaviour and event counts. Five captured audio windows check release, press, hold, stop and repress while the update counter continues. A deliberately cleared history while the action remains held produces an extra event, and the same count guard rejects it.

The Amiga matrix covers all nine normal stick positions with Fire released/held, plus a hold/release sequence. Opposing directions are excluded because the emulator input adapter resolves them before the port read. Per-bit counters preserve the first-frame edges while the full native clock runs; no instruction-breakpoint timing is needed. Audio checks allow a 24-frame recording window so the emulator's decaying filter tail can settle after DMA stops; the final silence threshold remains strict. This does not claim instantaneous muting or a one-shot sample driver.

Run the bounded recipe from the repository root, providing your installed emulator binaries and existing Kickstart file:

```sh
python3 scripts/verify-pattern-machine-callers.py \
  --spectrum /path/to/emu198x-spectrum \
  --nes /path/to/emu198x-nes \
  --amiga /path/to/emu198x-amiga \
  --kickstart /path/to/kick13.rom
```

Use `--only amiga` to run this machine alone. Build198x defaults to PATH; `--build198x` accepts an explicit path. No firmware is distributed. Captures and logs stay in the ignored build directory. The committed receipt is `scripts/evidence/pattern-library-amiga.json`. These are emulator observations on the named configurations, not original-hardware or subjective listening checks.
