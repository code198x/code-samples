# Joystick Reading

Build with `make`, load `build/demo.prg` and type `RUN`. Use either physical
joystick port. White blocks under U/D/L/R/F show held controls. NEW FIRE
counts sampled fire presses in hexadecimal: hold the button and the number
stays still; release and press again to increment it. Reset to leave.

The standalone caller owns the screen, CIA1 port directions and latches,
CIA1 timer controls, and CIA interrupt masks. It maps out BASIC/KERNAL,
disables keyboard scanning and does not return to BASIC. Release keyboard
keys while using the joysticks: the ports share physical keyboard wiring,
and port configuration cannot electrically disconnect held keys.

## Reader contract

Call `joy_init` once with I/O visible, keyboard scanning stopped and the
CIA1 timer PB outputs disabled. It sets both port DDRs to input, writes
released values to their latches and clears six state bytes. `joy_poll`
reads each port once. Both routines change A/X and flags and preserve Y.

- Port 1 is CIA1 port B, `$DC01`; port 2 is CIA1 port A, `$DC00`.
- `joy1`/`joy2` use pressed bits: up=1, down=2, left=4, right=8, fire=16.
  Other bits are cleared. Opposite directions remain separate bits; this
  reader does not choose a movement policy.
- `joy1_new`/`joy2_new` contain `current AND NOT previous`. A held bit is
  new only on the first sample. A release followed by another press is new
  again. A pulse entirely between samples can be missed.
- `joy1_fires`/`joy2_fires` increment on new fire and wrap after `$FF`.
  The first poll compares against released state, so starting with Fire held
  counts as a press. Resetting software state while held has the same policy.

The caller polls once per video frame, so PAL and NTSC have different sample
rates. The new-press rule prevents repetition during a hold; it does not
filter physical switch bounce, define menu repeat or guarantee short pulses.

## Keyboard interaction

The original port-1 routine wrote `$7F` to `$DC00` and claimed that this
disabled keyboard scanning. With DDRA as output, it actually drives column
7 low. The probes reproduce false Up with `1` held, and false Fire with
Space held, in both engines and both video standards. The maintained caller
releases the port drivers instead. It owns that configuration for its whole
run, rather than attempting to coexist with the KERNAL keyboard service.

One probe records an **open Emu198x discrepancy**, outside this caller's
supported configuration. With PB1 driven low, PA configured as input and
Return held, VICE reads PA0 low; Emu198x does not. A forward scan sees Return on PB1 in both engines, proving the key is
active. The source currently scans keys only from PA to PB. The record explicitly marks the PAL/NTSC mismatches;
it does not count those rows as reference parity. Do not use this record to
claim complete keyboard/joystick electrical emulation or keyboard coexistence.

## Verification

```sh
make verify EMU198X_C64=/path/to/emu198x-c64 VICE=/path/to/x64sc
```

Keep the samples checkout's folder structure. The verifier reuses the movement
example's build/Emu helpers and the multiplexer example's PNG reader. No extra
Python packages are needed. Each built fixture must have identical Asm198x
and ACME output.

The input matrix gates the caller before each poll so input delivery and
sample history are independently observable. It exercises all 32 masks on
each port in isolation, 32 simultaneous pairs, holds and release/repress.
Assertions compare state with a separate Python edge calculation, then check
screen cells and hexadecimal counts. A separate run executes the unchanged
once-per-frame caller with actual host input delivery and checks its pictures.
Emu capture paths run normally before screenshots so emitted frames are fresh.

VICE joystick tests use simulated external port pins (`jpdb`), not a guest
RAM substitute. Held-key tests patch only the documented VICE 3.10 KEYBOARD
1.1 snapshot module: 16 row words and 8 reverse-column words. Originals remain
unchanged. Selected-column reads establish that the keys are active. This
tests the keyboard matrix, not the host keyboard mapping or physical switches.

Deliberately removing the previous-state mask must make held Fire count
twice, and the same state observer must reject it. Evidence includes source,
tool, PRG and screenshot identities in `verification/results.json`. Native
emulator checks remain separate from original-hardware verification.

Primary sources: Commodore, *Commodore 64 Programmer's Reference Guide*
(1983), p. 94 (keyboard matrix), pp. 320–322 (I/O assignments) and pp. 343–344
(game ports); MOS Technology, *6526 Complex Interface Adapter*, sheet 5/8
(port directions and pin reads). The sampling policy is this example's choice.

Recorded coverage: 412 state/display checks, 48 native indicator captures,
10 PAL/NTSC keyboard comparisons (including two explicit reverse-scan
mismatches), and four broken-edge runs rejected on held Fire. Tools:
Asm198x 0.0.58, ACME 0.97, VICE 3.10 and Emu198x revision
`df2799e220a10de6a3bc0f14f04c6506363cb7d3`; executable hashes are recorded.
The routines occupy 100 assembled bytes plus six state bytes.
