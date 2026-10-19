# Input, new presses and sound: commodore-amiga

An unpublished Pattern Library prototype. Read the comments in every routine and caller before including them. Keep state in writable memory and include each file once.

`input.inc` and `presses.inc` are reusable routines. `use.asm` is an integration fragment for an existing machine program, not a complete boot program. `check.asm` includes the pieces for an assembly check; it does not provide startup, frame synchronisation or a complete game.

```sh
asm198x --dialect vasm --exe check.asm -o check
```

Run that command in this folder. The wrapper checks a Hunk executable with chip-memory sample data; it is not a boot disk or OS-safe program. Start inside a hardware-owning program; A5=$DFF000. Initialise input with audio channel 0 off, wait a frame, then call update_input once per PAL frame. The sample loops until release. The fixed period 424 and frame interval satisfy the driver's off-time requirement. Preserve disk/control bits when changing CIA-A direction bit 7.

The input routine preserves the original horizontal JOY1DAT bits and decodes only vertical bits. Physical port 2 Fire is CIA-A bit 7. The earlier article's Fire table must not be used for this caller. See Commodore-Amiga, Hardware Reference Manual, third edition, chapter 8, controller ports and Fire Button.

## Verification

From the repository root, run `python3 scripts/check-pattern-library-prototype.py` with Asm198x and VICE x64sc installed. Output is bounded and saved in the C64 demo's ignored build directory. It assembles all machine fragments and executes the C64 composition with simulated joystick pins. It also executes 58 original local-turn cases. The script fails if a required observation or output is missing or wrong.

The receipt is `scripts/evidence/pattern-library-prototype.json`. C64 composition checks are VICE 3.10 PAL observations, entered at $0810 after ROM boot. The new Spectrum, Amiga and NES combinations have assembly/link checks only, with no execution claim. The reused sound drivers and C64 joystick reader have their own evidence. Original-hardware validation remains separate.
