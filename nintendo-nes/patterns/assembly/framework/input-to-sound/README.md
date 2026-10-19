# Input, new presses and sound: nintendo-nes

An unpublished Pattern Library prototype. Read the comments in every routine and caller before including them. Keep state in writable memory and include each file once.

`input.inc` and `presses.inc` are reusable routines. `use.asm` is an integration fragment for an existing machine program, not a complete boot program. `check.asm` includes the pieces for an assembly check; it does not provide startup, frame synchronisation or a complete game.

```sh
asm198x --dialect ca65 check.asm -o check.nes
```

Run that command in this folder. This only checks assembly/linking; the wrapper is not a playable ROM. Include the three .inc files once in your own ca65 program with BSS/ROM layout, reset code and vectors. Call initialise_input, then update_input once per update. No DMC; no concurrent NMI/music writes to pulse 1. The caller initially disables all audio and owns apu_enable from startup. A=$80 differs from the C64 Fire mask.

## Verification

From the repository root, run `python3 scripts/check-pattern-library-prototype.py` with Asm198x and VICE x64sc installed. Output is bounded and saved in the C64 demo's ignored build directory. It assembles all machine fragments and executes the C64 composition with simulated joystick pins. It also executes 58 original local-turn cases. The script fails if a required observation or output is missing or wrong.

The receipt is `scripts/evidence/pattern-library-prototype.json`. C64 composition checks are VICE 3.10 PAL observations, entered at $0810 after ROM boot. The new Spectrum, Amiga and NES combinations have assembly/link checks only, with no execution claim. The reused sound drivers and C64 joystick reader have their own evidence. Original-hardware validation remains separate.
