# Verify both C64 joystick readers

Agreed scope: a complete input example, both ports, all direction/fire masks,
hold/release behaviour and keyboard interaction in Emu198x and VICE on PAL
and NTSC. Keep runnable source in the samples repo and include it from the
pattern page. No new dependencies or snapshot/API changes are planned.

1. Preserve the original readers and website revision under
   `commodore-64/patterns/assembly/input/joystick-reading/verification/`.
   Reproduce the claimed `$7F` keyboard isolation with held matrix keys and
   no joystick input. Check both DDR configuration and shared keyboard wiring.
2. Add `joystick.inc`, `demo.asm`, `Makefile` and `README.md` in that folder.
   The standalone caller owns CIA1 port configuration, interrupt masks and
   screen. Read five pressed bits from each port once per frame. Keep current
   and previous states so newly pressed bits are current AND NOT previous;
   distinguish this sampling policy from physical switch debouncing.
3. Execute all 32 masks on each port, simultaneous controls, held/released
   fire and representative keyboard interference. Use actual Emu input events
   and VICE's I/O simulation for joystick pins. If needed, use VICE keyboard
   snapshot modules for held-key fixtures, never substitute guest input RAM.
   Confirm those matrix fixtures by reading selected keyboard columns.
   Compare Asm198x/ACME bytes; check guest state and visible indicators; make
   the same observer reject a deliberately broken inversion or edge rule.
4. Record evidence and limits precisely. Any emulator discrepancy gets a
   separate reproduction before changes or accuracy claims. Update
   `joystick-reading.mdx` through CodeFromFile, remove unsupported costs and
   attribution, pin evidence, build and check desktop/mobile rendering and
   all pattern evidence hashes. Commit and merge after required checks pass.

Baselines: samples `ffec9e93b5c1a537b91aeb67b4b26a81fd386421`, website
`c46a2149bba18b143ecacefa506d7bbfa6ed9f0c`. Preserve unrelated work.

## Findings and verification design

The original `$7F` port-1 advice selects keyboard column 7: `1` reads as Up
and Space as Fire in both engines on PAL/NTSC. The maintained reader owns
both CIA ports as inputs, releases their latches, masks five pressed bits and
separates held state from new presses. The assembled routines occupy 100 bytes
and have six state bytes; no unmeasured cycle bound remains.

A separate reverse-scan probe reveals an existing Emu198x discrepancy. Drive
PB1 low with DDRB=$FF, DDRA=$00 and Return held: VICE reads PA0 low, Emu198x
does not. A forward column-0 read sees Return on PB1 in both engines, proving
the key input is present. `machine-commodore-c64/src/machine.rs` currently
resolves keyboard inputs only from PA to PB in `refresh_keyboard_scan`. This
is recorded explicitly rather than counted as reference parity. Correcting
the emulator wiring is a separate next change; the new caller does not use
reverse scanning. The verifier accepts future agreement with the reference,
so the recorded discrepancy does not require retaining the emulator bug.

The keyboard fixture uses no simulated joystick devices. VICE's I/O simulator
returns only five bits (`joyport_io_sim_set_out_lines` masks with $1F), so its
upper-bit values must not be mistaken for keyboard-only pin readings. The
joystick matrix uses that device deliberately and checks the masked result.

Both actual port inputs and displayed cells are checked. A gated caller makes
one sampled transition observable at a time; a separate unchanged caller
checks ordinary frame-based input and fresh screenshots. Physical bounce and
arbitrary simultaneous keyboard/joystick ghosting are not validated here.

## Recorded outcome

All 412 supported state/display checks and 48 native pictures pass. Four
broken-edge runs reject repeated held Fire. Ten keyboard comparisons retain
the two explicit PAL/NTSC reverse-scan mismatches; both include the positive
forward-scan control. All fixture binaries agree between Asm198x and ACME.
Ruff, standalone build and source/hash checks pass. Representative native
pictures were also inspected. No emulator source was changed.
