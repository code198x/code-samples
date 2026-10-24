# Optional turn deadlines in 48K Spectrum BASIC

Space takes a turn. Holding it takes only one: release before the next action. Waiting does nothing until T enables timing; then a turn arrives after 200 clock ticks, roughly four seconds on this PAL Spectrum. T disables timing or starts a fresh duration. Q stops after you release it. The display shows turns, automatic expiries and timer state, not a live countdown.

## Build and load the complete example

Run `make BUILD198X=/path/to/build198x` here. Load build/demo.tap through the normal 48K ROM with LOAD "". Build198x 0.2.9 tokenises the maintained numbered source; the ROM loads and executes it. build/demo.bas is the complete listing if you prefer entering it. build/customise.tap halves duration; build/wrong.tap demonstrates the baseline fault. NEW/reset before loading another complete variant.

The Makefile combines caller.bas, input.bas, routines.bas, clock.bas, dispatch.bas, presentation.bas and optional monitor.bas, in numeric order. Keep line numbers unique and update every GO SUB/GO TO target when renumbering. Spectrum BASIC needs LET and its GO SUB/GO TO syntax: the ten-line countdown has the same arithmetic contract as the maintained Dragon/MSX helper, with an explicit dialect implementation here.

## Take the helper into your own project

Set DU to integer duration 0..65535 and DC to the sampled clock, then GO SUB 3000 once. It records the baseline and starts disabled. GO SUB 3100 copies duration to remaining and enables only when nonzero. It clears the one-poll event but retains the most recent baseline: sample/poll immediately before starting when that instant matters.

Every service iteration, including while disabled, sets DC and calls 3200. Read DX before another poll/start clears it. DR is remaining, DA enabled, DP previous and DE elapsed. DU/DC are caller inputs; DP/DR/DA/DX/DE belong to the helper. They are one mutable context and must not collide with a larger program's variables. The helper performs no I/O or fixed-address RAM access; GO SUB uses BASIC's existing return stack.

The routine stores whole ticks in Sinclair numbers. Values and intermediates within this contract are represented exactly; do not substitute a narrower integer representation. At native allocation, each two-letter numeric helper entry occupies seven bytes including its name: 49 bytes for seven entries. Other BASICs have different representations and costs.

Subtraction wraps modulo 65536: 65526 to 10 is twenty ticks. Poll less than one complete cycle apart, roughly 21 minutes 51 seconds at 50 Hz. Extra complete cycles cannot be recovered from two samples. Reinitialise after an external FRAMES reset. Zero duration means off. Expiry clamps remaining to zero and disables the helper; the caller chooses whether to restart. A late observation produces one event, without catch-up. Restarting from observation can drift.

## Read a coherent clock

clock.bas reads the high byte at 23673, the low byte at 23672, then the high byte again. If it changed, the adapter retries. This avoids combining a pre-carry high byte with a post-carry low byte. DH/DL are its scratch globals; DC is the resulting low-word clock. It does not POKE FRAMES or change interrupts. A full high-byte cycle between the two checks would be ambiguous too: this short adapter is for normally serviced foreground BASIC, not suspended snapshots or replaced firmware.

The stock IM1 ROM increments FRAMES. Keep that service available; interrupt masking, tape/sound routines and other work can affect clock service and response. It is a nominal 50-tick clock on this named PAL configuration, not a precision stopwatch. Sampling it does not pace the display.

## Input, policy and drawing are separate

input.bas returns K$ from a nonblocking INKEY$ sample and owns KH. It accepts one command then waits to observe no key before re-arming. A short press between samples can be missed; changing directly between held keys does not re-arm. INPUT would block deadline service while a player thinks. Q's exit path waits for release before STOP so the key does not become the next BASIC edit command.

dispatch.bas owns N (byte-bounded turns), EX (expiries) and CH (redraw request). It performs no input or drawing. Expiry wins over the sampled command, including T/Q. An action restarts only active timing; untimed actions stay untimed. Disabling discards the remainder; enabling gives a full duration. The caller handles quit only when there is no expiry. Change the bounded increment to your own world update. Preserved pause, queued commands or carried lateness need explicit additional policy/state.

presentation.bas owns the first two text rows and redraws on changes. The complete caller clears once, selects black paper/white ink and leaves the screen in that state on STOP. BASIC owns keyboard, display, variable/stack storage and its normal IRQ service. There is no replacement ISR or assembly dependency.

## Reserve only what you use

The complete caller uses CLEAR 49999 before creating variables. Its optional observer owns 50000–50018: game/deadline values, guards and a completion marker. The separate second caller reserves 50000–50104 for twelve arithmetic records and three controlled policy results. Keep that high RAM clear of other code/data. Without diagnostics remove the MB initialiser, line 40, GO SUB 9000 and monitor.bas, then choose a reservation appropriate to your project. The countdown itself needs no POKE buffer.

The native complete working program contains 1,784 tokenised bytes including line headers. The helper occupies 290 of those bytes. Its observed variable area, including the terminator, is 101 bytes; seven helper entries account for 49. These are snapshots, not peak stack/heap measurements. Instrumented service samples commonly span roughly fifteen clock ticks; that includes interpreted input, policy and serialisation, not the helper alone. BASIC can notice expiry well after the clock passed it.

## Change, break and repair

customise.bas sets DU=100 instead of 200: about two seconds instead of four, without changing program/helper size. Choose clock units first. Maths for Games connects units, ranges and modular arithmetic to the same decisions.

mistakes/reset-baseline.bas stores DC into DP immediately before polling. The clock keeps moving, but remaining stays full and the automatic turn never arrives: TURN 1 E 0 T 1. Restore clock.bas and rebuild; an independent repaired run reaches TURN 3 E 1 T 1. The faulty listing adds seven tokenised bytes. Never combine both clock adapters in a working program.

## Verification and sources

Six independent ROM-tape-loaded cases cover working/custom/wrong/repaired callers and a second arithmetic/policy caller with a wrong-equality control. Every native tokenised line is compared with the TAP and the complete maintained line inventory. Native pointer/variable dumps establish the measured costs. Twelve supplied clock pairs cover wrap, zero/one/maximum duration and exact/overshot expiry. Changing > to >= completes the fixture but fails the oracle; three controlled policy cases check expiry+action, expiry+toggle and untimed action. Synthetic clocks are arithmetic evidence, not an observed 22-minute rollover. Ordinary live input runs do not force exact simultaneity.

Actual keyboard input, native bitmap/font pixels, return-to-editor arithmetic and source/tool/ROM/image identities are retained. Check with scripts/check-spectrum-deadlines.py and the associated unittest falsification controls; reproduce with scripts/verify-spectrum-basic-deadlines.py, Build198x and your own stock 48K ROM. The named emulator is Emu198x 0.44.2. No physical-hardware, other model/region or whole-emulator qualification is claimed.

Primary source: Sinclair Research, ZX Spectrum BASIC Programming (1982), chapter 18 explicitly discusses the interrupted-read hazard: https://worldofspectrum.org/ZXBasicManual/zxmanchap18.html ; Appendix A documents FRAMES and BASIC's workspace. The retry adapter, countdown, release gate and game policy are this implementation's choices.
