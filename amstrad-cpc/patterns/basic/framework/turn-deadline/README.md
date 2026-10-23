# Optional turn deadlines in CPC BASIC

Space spends a turn, T enables/disables a deadline, Q ends. Timing starts disabled. Enable it and one overdue deadline takes one turn without a key, then starts over. Counts are byte-bounded; the display is not a live countdown.

## Load and call

Run make, enter build/demo.bas into a fresh CPC464 BASIC program and RUN. build/customise.bas halves duration; build/wrong.bas replaces the clock adapter with the deliberate baseline-reset mistake. Use NEW/reset before changing complete variants. The complete program consists of caller.bas, turn.bas, routines.bas, clock.bas, reduce.bas and optional monitor.bas. Numbered lines determine execution, not file order. Keep line numbers unique and renumber all GOSUB/GOTO targets consistently.

1. Supply DU! duration and DC! current clock, whole ticks 0..65535. GOSUB 3000 initialises disabled state and records a baseline.
2. GOSUB 3100 starts/restarts from the latest sample. Poll immediately beforehand when that instant matters. Duration zero disables.
3. Every service iteration, including while disabled, supply DC! and GOSUB 3200. Read DX! immediately; the next poll/start clears it.
4. Expiry clamps remaining to zero and disables itself. Your caller decides whether to advance/restart. DA!=0 disables, with no preserved-pause operation.

| Global | Agreement |
| --- | --- |
| DU!, DC! | Caller duration/current sample, unsigned whole ticks 0..65535 |
| DP! | Previous sample |
| DR! | Saturating remaining ticks |
| DA!, DX! | Active/latest expiry event, explicit 0 or 1 |
| DE! | Elapsed ticks from the latest poll |

Use explicit real suffixes. Locomotive BASIC % variables are signed 16-bit (-32768..32767), unlike BBC BASIC's 32-bit integers. A surrounding DEFINT cannot narrow these ! variables. The five-byte real format represents the chosen integer range and subtraction intermediates exactly. Rename all globals consistently. This is one mutable context, not re-entrant code. The helper owns no array, fixed RAM, clock, display, keyboard or firmware vector. GOSUB needs the interpreter's return stack; do not GOTO into returning routines.

## TIME and the low-word adapter

TIME is the running firmware clock in 1/300ths of a second. Four seconds is DU!=1200; two is 600. clock.bas reads TIME, calls the reusable reduce.bas normaliser at 5100, then polls the helper. That normaliser subtracts 65536*INT(DC!/65536), retaining 0..65535. It accepts an unsigned whole clock 0..4294967295, not arbitrary fractions or negative inputs. The helper only accepts the reduced sample.

Do not use TIME AND &FFFF as a supposedly universal port: CPC bitwise operations use signed integer conversion, while the clock can exceed that range. The normaliser uses real arithmetic and is separately exercised by the native boundary caller, including 2147483647, 2147483648 and 4294967295. It never sets TIME or installs an IRQ. Keep normal firmware interrupt service enabled; it cannot recover ticks which that service missed.

The low word wraps every 65536/300 = about 218.45 seconds. Consecutive samples must be less than 65536 ticks apart. A whole missed cycle is ambiguous. A reset/change of the shared clock is not a rollover; reinitialise/restart your context. The full 32-bit clock wrapping is also handled by low-word reduction, provided no full low-word cycle was missed.

## Input and game policy

UPPER$(INKEY$) consumes one delivered character without waiting for Return and accepts normal upper/lowercase T/Q. Firmware buffering/repeat still apply; this is not physical press detection. A blocking INPUT collector would stop this caller processing expiry.

Time is polled before input and expiry wins, discarding that iteration's character even Q/T. Space advances and restarts only an already active timer. Untimed actions stay untimed. T disables/discards remaining time or enables a fresh duration. One late event takes one turn, not a catch-up burst. Restarting from observation time can drift; carrying lateness, preserved pause state, multiple contexts and fixed-step accumulation are possible extensions with different contracts.

The bounded counter expression comes from the existing CPC command loop, with explicit real globals. Keep spaces in `(N!+S!) AND 255`; the compact BBC spelling `AND255` is rejected by Locomotive BASIC. A syntax error stops the interpreter and leaves the last completed diagnostic snapshot unchanged. A completion marker proves a coherent stored snapshot, not that the program is still running—check advancing clock/state too.

## Customise and repair

customise.bas changes only DU!=1200 to 600 and is independently executed. S! remains 0..255 for the byte-wrapping turn rule. Change the caller's expiry/input order only when that policy fits your game; leave helper arithmetic separate.

mistakes/reset-baseline.bas writes DP!=DC! immediately before polling. The native clock moves, but elapsed stays zero, remaining stays full and no automatic turn occurs. Restore clock.bas; a fresh repaired run expires. Only initialisation should discard the old baseline without accounting for elapsed time. Do not include the correct and wrong adapters together: they deliberately use the same line number.

## Ownership and measured costs

The caller selects MODE 1 and MEMORY 40959, reserving observer memory at &A000–&A013 (20 bytes), below the screen at &C000. Keep other allocations out of that range. Caller globals N!, S!, EX!, K$ and diagnostic globals MB!, LC!, V!, O!, H!, M! are separate from the seven helper globals. Q does not restore the old mode or MEMORY value; reset or restore your own configuration before another program. Remove the GOSUB 9000 call, guard/MB!/LC! setup and monitor.bas to omit diagnostics.

The native BASIC line chain contains 277 tokenised helper bytes (3000–3250) and 1,311 bytes for the complete diagnostic program, including headers/terminator. Seven helper real values have 35 bytes of numeric payload, derived from the format; names, interpreter bookkeeping and temporary/return stack storage are additional and not isolated here. No peak heap claim is made. A recorded idle service sample was 40 firmware ticks after its predecessor (about 0.133 seconds), including diagnostic work, not a helper-only benchmark. The observer's 20-byte reservation is additional.

This is bounded work per poll, not one interpreter loop per missed tick. Output changes only on actions/toggles/expiry. The optional observer copies four three-byte values and flags each service, slowing response. Measure actual game work before making frame-budget claims; a running clock does not make BASIC concurrent.

## Native qualification

Stock CPC464 64 KiB PAL, MODE 1, Locomotive BASIC 1.0, Emu198x 0.44.1, with tool/firmware identities in verification/configuration.json. Programs were cold-booted and typed. Native program line inventory/lengths and guarded output are retained. Six variants cover working/custom/wrong/repaired callers and a second arithmetic caller with a deliberately faulty equality branch. Twelve synthetic-clock cases include high 32-bit normalisation, zero/max duration, no movement, wrap and exact/overshot expiry. The faulty >= instead of > branch completes but must fail the independent oracle.

The working idle observation advanced 607 ticks in 102 native fields, including mailbox settling and sample age. That supports the 300 Hz serviced clock in this configuration; it does not establish one-tick response latency or a full wall-clock rollover run. No original-hardware, other-ROM, minimum-RAM or whole-game performance claim is made. Retained checks and 36 corruption controls do not themselves rerun emulation.

Repeat scripts/verify-electron-cpc-basic-deadlines.py with --systems amstrad-cpc, released tools and lawful firmware. Primary sources: Amstrad CPC464 User Instructions chapter 8, data types, TIME, INKEY$, UPPER$, MEMORY; CPC464 Firmware Manual, KL TIME PLEASE (&BD0D). Native captures show Code198x's own program; no firmware is distributed.
