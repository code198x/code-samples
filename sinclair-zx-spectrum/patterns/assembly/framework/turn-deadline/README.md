# Optional turn deadlines on a 48K Spectrum: Z80

Press 1 and the turn counter advances. Hold it and nothing else happens: the caller needs a release before another action. Waiting does nothing until 2 enables a deadline. After 200 ROM clock ticks, roughly four seconds on the named PAL configuration, an automatic turn arrives. Press 2 again to disable timing. Q returns to BASIC. The display shows turn, expiry count and enabled flag in hexadecimal, not a live countdown.

## Build and load

Run `make ASM198X=/path/to/asm198x` here. Load build/demo.tap through the normal 48K ROM with LOAD "". The generated BASIC loader uses CLEAR 32767, loads CODE at $8000 and calls it through USR. **END start matters:** it supplies the entry address for the loader's RANDOMIZE USR line. A code header's load address alone does not start the program. No firmware is supplied.

The complete image is 393 bytes at $8000–$8188. Its writable tail owns TURN, EXPIRIES, KEY and HELD (four bytes), DEADLINE (ten) and READY (two). READY is an observation marker, not part of the countdown. Reserve the whole image against BASIC, display buffers and other code. Relocate the origin and loader reservation together. The existing BASIC return stack is retained; no private stack or ISR is installed.

## Take the countdown

Include cross-platform/patterns/framework/elapsed-deadline/z80.inc once and provide the label DEADLINE for ten writable bytes. Words are little-endian: duration +0, remaining +2, active +4, one-poll event +5, elapsed +6 and previous clock +8.

1. Set duration to an integer 0..65535. Pass the current clock in HL to deadline_init once. It records the baseline and starts disabled; duration is preserved.
2. Call deadline_start to copy duration into remaining and enable only for nonzero duration. It clears the event but retains the latest sampled baseline. Poll immediately before starting if that instant matters.
3. Pass each new clock in HL to deadline_poll, including while disabled. Read +5 before the next poll/start clears it. Expiry clamps remaining to zero, disables the context and emits one event. Your caller decides what follows.

AF/DE/HL are clobbered; BC/IX/IY survive. Each call uses the existing return stack, owns no display/input/interrupt resource and is not re-entrant on one context. Rename labels or provide another explicit implementation when several independent contexts are needed.

Subtraction wraps modulo 65536. A sample change from 65526 to 10 means twenty elapsed ticks. Consecutive polls must be less than one complete cycle apart: roughly 21 minutes 51 seconds at 50 Hz. A missed whole cycle is indistinguishable from no elapsed time. Reinitialise after an external FRAMES reset. Zero duration means off, never a 65536-tick wait. A late poll gives one event, with no catch-up; restarting from observation introduces drift.

## Clock and input belong to the machine

clock.inc reads the low word of FRAMES at $5C78 using one LD HL instruction. Maskable interrupts are accepted between instructions, so the two-byte value is coherent with the stock IM1 service. HL changes; flags and other registers survive. Leave the normal ROM, IY workspace and enabled IM1 interrupt service intact. Long interrupt masking or ROM routines that suppress clock service can lose time. This is not a civil-time clock or replacement interrupt handler.

input.inc adapts the existing Ace row/bit reader to the Spectrum contract: 1 at $F7FE bit 0, 2 at bit 1, Q at $FBFE bit 0, active low. AF/BC change; DE/HL/IX/IY survive. A=0 means none, 1 action, 2 toggle, 3 quit. Q wins over 2 over 1. HELD suppresses all commands until every command key is observed released. A press wholly between polls can be missed; switching directly between held keys does not re-arm. This is physical sampled input, not a character buffer. The countdown and dispatcher keep the same interfaces as the maintained Ace/MSX callers; their firmware and I/O contracts remain different.

The wrapper saves AF/BC/DE/HL/IX/IY on entry. It calls the stock CLS routine at $0DAF, then draws the first eight cells using the current CHARS font pointer. Drawing changes AF/BC/DE/HL and uses nested return-stack bytes; the ROM IRQ also needs its own stack space. It neither replaces the font nor restores the old screen. Q waits for command release and one normal interrupt before restoring registers and RET, so the key does not leak into BASIC's next edit line. IRQs must be enabled on entry.

## Let the game choose the policy

dispatch.inc has no I/O. It owns the bounded byte turn/expiry counters and KEY. An expiry wins over that iteration's command, including quit/toggle. Otherwise 1 advances once and restarts only active timing; an untimed action stays untimed. Disabling discards the remainder; enabling starts a full duration. Replace the turn increment with your own world update. Preserved pause, queued commands and carried lateness are different useful policies, not hidden hardware requirements.

This caller draws continuously for readable feedback. Clock sampling does not wait for a frame. A game can redraw on changes or add an independent display wait, while continuing to service deadlines often enough.

## Customise, break and repair

customise.asm changes DURATION=200 to 100, about four seconds to two, without changing image/context size. Keep units and clock range explicit. Maths for Games develops the same units, unsigned ranges and modular subtraction.

wrong-baseline.asm selects a deliberately broken clock adapter: it overwrites previous before polling. The real clock moves but elapsed is always zero, remaining stays at 200 and the screen remains 01 00 01. Restore clock.inc and rebuild; an independent repaired run reaches 03 01 01. The broken adapter adds three bytes. Never include both adapters in a working image.

no-entry.asm omits END start. The tape still loads the exact 393-byte image, then BASIC reports 0 OK, 30:1; READY stays zero because USR never ran. Add END start and rebuild the loader. A successful load is not evidence that a routine executed.

## Costs and verification

The countdown is 97 emitted bytes plus ten context bytes. The clock reader adds four bytes, input fifty, dispatcher sixty-one, and caller/presentation 165. Sixteen writable image bytes bring the complete payload to 393. These are emitted sizes, not cycle counts or peak stack measurements. IRQs, keyboard and drawing affect service latency; no whole-game frame budget follows.

Emu198x 0.44.2, recorded stock 48K ROM, PAL; Asm198x 0.0.72. Seven independent ROM-tape-loaded cases cover working/custom/wrong/repaired callers, a second arithmetic/policy caller, wrong equality and the missing-entry control. The debugger stops naturally at the USR entry to compare every loaded byte before the first instruction; it does not set the PC or write game state. Twelve supplied clock pairs cover zero/one/maximum duration, wrap and exact/overshot expiry. Three controlled policy cases cover expiry+action, expiry+toggle and untimed action. Removing exact equality completes its guards but fails the oracle. Supplied clocks do not establish an observed 22-minute rollover.

Captures are checked against native bitmap bytes and the native font glyphs; real keyboard actions include a long held action. Return to BASIC is followed by PRINT arithmetic. The retained checker validates source/tool/ROM identities, startup, state and images. `python3 scripts/check-spectrum-deadlines.py` checks both language routes; `python3 -m unittest discover -s scripts -p test_spectrum_deadlines.py` deliberately changes evidence and must fail. Reproduce execution with scripts/verify-spectrum-assembly-deadlines.py and released tools plus your own ROM. No original-hardware or whole-emulator qualification is claimed.

Primary sources: Sinclair Research, ZX Spectrum BASIC Programming (1982), chapter 18, clocks and interrupted reads: https://worldofspectrum.org/ZXBasicManual/zxmanchap18.html ; Appendix A, FRAMES/CHARS and ROM workspace. The wrapper, coherent word adapter, countdown and policy are this implementation, not historical listings from that manual.
