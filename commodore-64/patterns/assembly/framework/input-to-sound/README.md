# Input, new presses and sound: commodore-64

An unpublished Pattern Library prototype. Read the comments in every routine and caller before including them. Keep state in writable memory and include each file once.

This folder contains a complete PAL C64 program. From the repository root:

```sh
make -C commodore-64/patterns/assembly/framework/input-to-sound
```

Load `build/demo.prg`, type `RUN`, and use case-labelled joystick port 2 with keyboard keys released. A new Fire press changes the border and starts a note. Holding Fire does not retrigger. The gate clears after six updates; the SID releases while updates continue. Reset to leave.

The caller stops keyboard scanning, owns CIA1 and its timer outputs, maps out ROMs, owns the RAM NMI vector, SID voice 1, master volume/filter routing and border. It does not return to BASIC. The existing `joystick.inc` and `sid-note.inc` are included by their relative paths; clone the repository rather than downloading only demo.asm.

## Verification

From the repository root, run `python3 scripts/check-pattern-library-prototype.py` with Asm198x and VICE x64sc installed. Output is bounded and saved in the C64 demo's ignored build directory. It assembles all machine fragments and executes the C64 composition with simulated joystick pins. It also executes 58 original local-turn cases. The script fails if a required observation or output is missing or wrong.

The receipt is `scripts/evidence/pattern-library-prototype.json`. C64 composition checks are VICE 3.10 PAL observations, entered at $0810 after ROM boot. The Spectrum, Amiga and NES combinations have separate execution recipes and receipts: see scripts/verify-pattern-machine-callers.py and scripts/evidence/pattern-library-spectrum.json, pattern-library-amiga.json and pattern-library-nes.json. The reused sound drivers and C64 joystick reader have their own evidence. Original-hardware validation remains separate.
