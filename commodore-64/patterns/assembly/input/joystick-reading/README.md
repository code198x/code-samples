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


## Reuse release events as well

`edges.inc` extends the existing six-byte reader without changing its interfaces. Include joystick.inc once, then edges.inc. Call joy_edges_init once in the same exclusive CIA1 configuration; call joy_poll_edges once per update instead of joy_poll. Read joy1/joy2 for held controls, joy1_new/joy2_new for new presses, and joy1_released/joy2_released for releases. All use the existing five pressed-bit meanings. A/X/flags change; Y survives. The wrapper owns two release bytes and one scratch byte; it uses the existing JSR stack and is not re-entrant on one state set.

The wrapper saves each previous held mask before the maintained reader updates it, then finds `previous AND NOT current`. A zero-history start counts a button already held as a first press. For a scene that should ignore already-held buttons, initialise, sample once, and discard that first result before accepting actions. Polling more than once per game update consumes the edge; use one shared sample for all consumers. Pulses entirely between samples, mechanical bounce, repeat timing and illegal-direction policy remain separate jobs.

Run `make edges ASM198X=/path/to/asm198x`, load build/edges-demo.prg and RUN. The first row contains seven hexadecimal bytes: port1 held/new/released, port2 held/new/released, then the action count. Fire in port2 adds one action; holding it does not add more. Reset to leave. The caller owns the display, CIA ports/timer controls/interrupt masks, CPU banking and an NMI return vector; it deliberately does not coexist with the KERNAL keyboard service. Keyboard keys must remain released.

The example's diagnostic latches and event counters preserve short edge pulses after their display update. They belong to the caller, not the helper: a stable screenshot cannot show every one-update transition. Native transition records check those latches alongside the current masks and counters. The first row's final action count is the visible comparison.

### Make it your own

edges-custom.asm changes ACTION_MASK from `$10` (Fire) to `$04` (Left) in the caller. The reader and release wrapper stay unchanged. Fire no longer spends an action; a new Left press does. Payload and helper sizes stay the same. This is action mapping, not another electrical input mode; choosing a wider mask would count one event when any selected bit is newly pressed, rather than one event per selected button.

### A revealing mistake

edges-wrong.asm deliberately adds edges-wrong.inc: it clears the held history before every poll. Held Fire is then reported as newly pressed every update, action counts rise during the hold and release events disappear. Restore the normal POLL_ROUTINE jump to joy_poll_edges. The repaired caller is independently run and has the same payload as the working caller. The broken build adds eleven bytes. Keep the labelled fault outside the normal build target.

### Costs and current qualification

The wrapper adds 62 instruction bytes and three state bytes to the maintained reader's 100 instruction bytes and six state bytes. Its pure joy_release_bits entry takes A=previous and X=current five-bit masks and returns the released bits in A; X/Y survive, flags and private scratch change. A second guest-owned caller exercises all 1,024 previous/current pairs, including simultaneous and opposite directions. It does not establish physical joystick capability for impossible switch combinations.

The complete diagnostic PRG payload is 490 bytes, including its BASIC header, caller, tables, code and state. Diagnostic latches add eight bytes beyond the normal input state; the caller also has an action counter and ready marker. The two reads per poll still come from the original reader. Extra wrapper/call work is real; byte counts are not a whole-frame or VIC-contention budget.

Six cases on Emu198x 0.44.2, Asm198x 0.0.72 and the recorded stock PAL C64 ROMs cover working/custom/wrong/repaired callers and the independent release matrix. A wrong OR operation completes the matrix guards but fails an independent bit-set oracle. Real port inputs, native screen values, ROM-glyph/PNG agreement and source/tool/firmware identities are retained under verification/edges. Run scripts/verify-c64-input-edges.py, then check-c64-input-edges.py and its corruption tests. The new wrapper is qualified on this PAL configuration; the earlier reader's separate PAL/NTSC evidence remains separate. No original-hardware or complete keyboard-electrical claim follows.
