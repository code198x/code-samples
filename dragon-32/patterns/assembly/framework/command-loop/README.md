# Dragon 32: wait for a player action in assembly

Press 1: TURN $00 becomes TURN $01. Hold it: the count stays put. Release and press again for $02. Other keys leave the count alone; Q returns to BASIC. The $ marks hexadecimal: $0A is ten, $FF is 255, and the next action wraps to $00. The byte stands in for an untimed world update, not elapsed time.

## Build and load

From the repository root, using Asm198x 0.0.71:

```sh
python3 scripts/build-dragon-ace-loops.py --assembler /path/to/asm198x --system dragon-32
```

Enter `build/working/load.bas` one line at a time after a fresh normal-firmware boot. This loader is generated from the actual assembled bytes; do not maintain a second handwritten DATA/C, listing. No firmware is supplied by this repository. Dragon reserves memory above `CLEAR 200,&H6FFF`, enters a numbered READ/POKE loader, runs it, then starts with `CLS:EXEC &H7000`. The payload occupies $7000–$70E9 (234 bytes), including its one state byte. BASIC must not allocate into it. The loader variables I/A and line numbers are temporary; reserve/renumber them if combining programs. This route proves keyboard entry, POKE and EXEC, not cassette transfer.

## Reuse the routines

Keep `demo.asm`, `caller.inc` and `routines.inc` together. `demo.asm` supplies the origin and compile-time settings. Include `routines.inc` once in a project, initialise persistent state once with A = initial count and a call to `turn_init`, then call `turn_advance` for each accepted action. Change STEP to a byte 0–255 at build time. The state operation does no input, drawing or sound and uses no fixed scratch area: its labelled byte moves when the whole source is assembled at a different origin. Relocation also requires a matching loader/reservation.

- `turn_init`: A in; stores it in `turn_count`; A preserved, flags changed.
- `turn_advance`: no argument; adds STEP modulo 256; A/flags changed.
- `show_turn`: formats that byte as two hexadecimal digits; does not change it.
- `draw_box`: writes an original three-cell-wide text box; does not change state.
- `trigger_sound`: blocking one-bit pulse train, separate from the update. It is a diagnostic effect, not a background music service or a calibrated pitch.

`show_turn` uses A/X/flags and writes $0400–$0407. `draw_box` uses A/flags and writes $0440–$0442, $0460–$0462 and $0480–$0482, leaving other cells intact. These are MC6847 screen codes, not ASCII: X is 24. The caller starts in the normal 32-column text mode and clears once before EXEC. Do not use these addresses unchanged in PMODE graphics.

`JSR $8006` asks the Dragon ROM for a character (A=0 means none); TSTA makes the empty case explicit. It is a delivered-character contract, not a general simultaneous-key scanner. The named Dragon 32 run checks that a held 1 does not repeat. Dragon 64/alternative firmware repeat policies are not qualified.

The complete entry preserves CC, DP, D, X, Y and U on the existing S stack and returns with RTS through EXEC's original frame. It never resets S or disables ROM interrupts. The sound routine uses A/B/X/flags plus five stack bytes for its return address and three saved PIA values (in addition to callers' stack frames). It saves/restores PIA1 control, DDR and data while temporarily enabling PB1 as the one-bit sound output and disabling the sound multiplexer. It retains other data bits. It is not safe to run concurrently with another owner of those PIA registers, cassette operations or another audio driver. Interrupts can stretch the pulse timings. The firmware still owns its RAM workspace, IRQ and keyboard state.

## Customise and diagnose

Build `--variant step-three` to use `customise.asm`: two actions give $03 then $06, without more code or state bytes. Keep the same loop and replace the arithmetic with your room/board update; decide separately which commands spend a turn.

`mistakes/reset-each-command.asm` is deliberately broken (`--variant wrong-reset`). RESET_EACH=1 puts initialisation in the iteration. The update happens, then the next redraw erases it: $00 persists after both actions. Move that initialisation back to startup by using the original caller (`--variant repaired`). The retained wrong and repaired cases execute separately. This is a state-lifetime fault, not a failure of addition.

A timed adventure needs a clock, a waiting policy that can inspect it, and a rule for a deadline arriving alongside a command. The display interrupt continuing does not turn every poll into a game turn.

## Verify

```sh
python3 scripts/verify-dragon-ace-loops.py --native /path/to/released/binaries-and-locks --assembler /path/to/asm198x --only dragon-32
python3 scripts/check-dragon-ace-loops.py
```

The record retains exact producer locks, firmware hashes, loaded payload bytes, video RAM, native images and PCM observations. Eight cold-start callers cover normal use, step three, wrong/reset and repair, wrap, nonzero start, omitted drawing and omitted sound. Keyboard loaders must match assembled bytes before launch. Idle/held/ignored input must preserve the count; Q must return to firmware that computes 2+3. Negative callers must fail the same drawing/audio/state conditions. This is configuration-specific native execution, not original-hardware, cassette, pitch accuracy, timing accuracy or whole-emulator qualification.

## Primary references

*Inside the Dragon* (Addison-Wesley, 1983), pp. 103–104 (INCH $8006, A/zero and registers; OUTCH $800C), pp. 212–213 (PIA single-bit sound and required direction/multiplexer control), Appendix 3, pp. 348–349 (direct/indirect I/O jump tables). The keyboard service address is $8006; $800C is screen output, not cassette input.
