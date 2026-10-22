# Jupiter Ace: wait for a player action in assembly

Press 1: TURN $00 becomes TURN $01. Hold it: the count stays put. Release and press again for $02. Other keys leave the count alone; Q returns to FORTH. The $ marks hexadecimal: $0A is ten, $FF is 255, and the next action wraps to $00. The byte stands in for an untimed world update, not elapsed time.

## Build and load

From the repository root, using Asm198x 0.0.71:

```sh
python3 scripts/build-dragon-ace-loops.py --assembler /path/to/asm198x --system jupiter-ace
```

Enter `build/working/load.fth` one line at a time after a fresh normal-firmware boot. This loader is generated from the actual assembled bytes; do not maintain a second handwritten DATA/C, listing. No firmware is supplied by this repository. On the stock 3 KiB Ace, the loader defines `TURNS` as `15616 CALL`, checks that HERE has not passed 15616, reserves dictionary padding to $3D00, and compiles the assembled bytes with C,. The 212-byte payload occupies $3D00–$3DD3, including one state byte. FORTH owns the dictionary and both stacks; C, advances HERE to protect the payload from later definitions. The padding costs additional dictionary space. Use a fresh boot: do not repeat the loader into an existing dictionary. The guard aborts before allocating backwards. Do not LOAD/REDEFINE or move the dictionary containing this absolute-address code. A relocatable primitive would be a different implementation.

## Reuse the routines

Keep `demo.asm`, `caller.inc` and `routines.inc` together. `demo.asm` supplies the origin and compile-time settings. Include `routines.inc` once in a project, initialise persistent state once with A = initial count and a call to `turn_init`, then call `turn_advance` for each accepted action. Change STEP to a byte 0–255 at build time. The state operation does no input, drawing or sound and uses no fixed scratch area: its labelled byte moves when the whole source is assembled at a different origin. Relocation also requires a matching loader/reservation.

- `turn_init`: A in; stores it in `turn_count`; A preserved, flags changed.
- `turn_advance`: no argument; adds STEP modulo 256; A/flags changed.
- `show_turn`: formats that byte as two hexadecimal digits; does not change it.
- `draw_box`: writes an original three-cell-wide text box; does not change state.
- `trigger_sound`: blocking one-bit pulse train, separate from the update. It is a diagnostic effect, not a background music service or a calibrated pitch.

`show_turn` uses A/BC/DE/HL/flags and writes ASCII cells $2400–$2407. `draw_box` uses A/flags and writes $2440–$2442, $2460–$2462 and $2480–$2482. Keep the ROM's normal character definitions: replacing the shared X glyph changes this box too. The loader clears once before TURNS; the routines do not clear unrelated UI.

`new_action` waits for both command keys to be released, then samples 1 at $F7FE bit 0 and Q at $FBFE bit 0. Zero means pressed. It returns A=1 for an action, A=0 for quit; Q wins a simultaneous sample; its release is awaited before returning, so the held quit key cannot leak into FORTH input. It uses BC/A/flags, ignores other keys, and reads no general character buffer. Polling occupies the CPU, but does not advance the world. IN on an Ace also pulls the loudspeaker in, so input and sound share hardware effects.

CALL is not an ordinary Z80 CALL/RET boundary: the top-level return is `JP (IY)`, exactly as the Ace manual specifies. Internal subroutines use RET. The caller leaves IX/IY and the FORTH data stack untouched and balances the existing return stack; it does not reset SP or disable interrupts. Other main registers may change. The maximum internal nesting is two ordinary return addresses (four bytes), plus the interpreter/interrupt stack requirements. Sound uses A/BC/DE/flags: alternating OUT and IN pushes the speaker out and in. Do not share speaker control concurrently with another sound routine. These routines require no extra character RAM or fixed scratch space outside the protected payload.

## Customise and diagnose

Build `--variant step-three` to use `customise.asm`: two actions give $03 then $06, without more code or state bytes. Keep the same loop and replace the arithmetic with your room/board update; decide separately which commands spend a turn.

`mistakes/reset-each-command.asm` is deliberately broken (`--variant wrong-reset`). RESET_EACH=1 puts initialisation in the iteration. The update happens, then the next redraw erases it: $00 persists after both actions. Move that initialisation back to startup by using the original caller (`--variant repaired`). The retained wrong and repaired cases execute separately. This is a state-lifetime fault, not a failure of addition.

A timed adventure needs a clock, a waiting policy that can inspect it, and a rule for a deadline arriving alongside a command. The display interrupt continuing does not turn every poll into a game turn.

## Verify

```sh
python3 scripts/verify-dragon-ace-loops.py --native /path/to/released/binaries-and-locks --assembler /path/to/asm198x --only jupiter-ace
python3 scripts/check-dragon-ace-loops.py
```

The record retains exact producer locks, firmware hashes, loaded payload bytes, video RAM, native images and PCM observations. Eight cold-start callers cover normal use, step three, wrong/reset and repair, wrap, nonzero start, omitted drawing and omitted sound. Keyboard loaders must match assembled bytes before launch. Idle/held/ignored input must preserve the count; Q must return to firmware that computes 2+3. Negative callers must fail the same drawing/audio/state conditions. This is configuration-specific native execution, not original-hardware, cassette, pitch accuracy, timing accuracy or whole-emulator qualification.

## Primary references

*Jupiter Ace User's Manual*, issue 2 (Jupiter Cantab, 1982), chapter 25, pp. 144–146 (CALL, JP(IY), register/stack contract, dictionary movement); chapter 26, p. 152 (keyboard half-row reads and speaker IN/OUT effects); chapter 24 (memory ownership). Keyboard bit positions are corroborated by the Ace schematic's A11/A10 half-rows.
