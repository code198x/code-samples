# Optional turn deadlines in Electron BASIC

Space spends a turn. Timing begins disabled: waiting does nothing to the world. T enables a deadline, another T disables it, and Q ends. Expiry takes one turn without input and starts the next deadline. The display shows turns, automatic expiries and timer-active state, not a live countdown.

## Reuse the maintained BBC BASIC implementation

`make` delegates to `bbc-micro/patterns/basic/framework/turn-deadline`, then copies only generated complete listings to this folder's build directory. No copied helper or second clock implementation is maintained here. Enter `build/demo.bas` into a fresh Electron BASIC program and RUN. `build/customise.bas` halves duration; `build/wrong.bas` is the deliberate baseline-reset fault. NEW/reset before another complete variant so old line numbers cannot survive.

Use the shared `caller.bas`, `turn.bas`, `routines.bas`, `clock.bas` and `monitor.bas`. BASIC line numbers, not file order, determine execution. Reserve their numbers or renumber all GOSUB/GOTO targets consistently. Returning routines need GOSUB, not a bare GOTO.

Set `DU%` (duration) and `DC%` (current sample), both 0..65535 whole ticks, and GOSUB 3000 once. This creates disabled state. GOSUB 3100 starts/restarts from the latest sampled baseline; sample/poll immediately beforehand when that instant matters. On each service iteration, including while disabled, supply DC% and GOSUB 3200. Read DX% immediately: it is one poll's expiry event and the next poll/start clears it. Zero duration disables. Expiry clamps remaining to zero and disables the helper; your caller chooses whether to advance/restart.

Helper-owned globals: DP% previous sample, DR% remaining, DA% active 0/1, DX% expiry 0/1, DE% elapsed. DU%/DC% are caller inputs. The % suffix means signed 32-bit integers in BBC BASIC; all specified values/intermediates fit. These globals are one mutable context, not a re-entrant service. The helper owns no fixed RAM, display, input, vector or hardware timer. GOSUB uses the interpreter's return stack.

## Electron clock and policy

`TIME AND &FFFF` supplies the low 16 bits of MOS centiseconds: 100 ticks per second, wrapping in 655.36 seconds. The Electron's physical real-time interrupt source is 50 Hz; MOS clock units do not promise a separate 100 Hz interrupt or one-centisecond game response. Keep normal MOS IRQ service running. Long interrupt blocking can lose service; a helper cannot recreate uncounted time. Neither this adapter nor its caller resets the shared clock.

Consecutive samples must be less than 65536 ticks apart. A missed whole cycle is ambiguous. An external clock reset is not a rollover: reinitialise/restart. The maximum duration is a representation bound, not permission to stop polling for the whole wrap. For previous=65530 and now=5, elapsed is 11: subtraction modulo 65536.

INKEY$(0) consumes delivered characters without waiting for Return. Typeahead and firmware repeat are possible; this is not a physical press-edge reader. A blocking INPUT/GET collector would stop this caller servicing expiry.

The caller polls time, samples one character, then gives expiry priority, discarding that iteration's character even Q/T. Untimed Space remains untimed; active Space restarts. T disables/discards remaining time, or enables a fresh duration. One late expiry takes one turn, not catch-up turns. Restarting from observation can drift. Carrying lateness, preserving pause time, queuing input or fixed-step accumulation are distinct possible policies, not hidden features.

## Customisation and diagnosis

Change DU%=400 to DU%=200 for roughly four seconds to two; the custom caller is independently executed. Change the bounded turn step S% only within 0..255 and retain the shared rule's byte wrap. Rename all globals consistently when combining routines.

The wrong clock adapter writes DP%=DC% just before polling: elapsed is always zero, remaining stays full and no automatic turn occurs despite a moving native clock. Replace it with clock.bas. The separate repaired cold run expires correctly. Only initialisation should replace a baseline without consuming elapsed time.

## Resources and costs

The caller selects MODE 6 and HIMEM=&3000. Its optional observer reserves &3000–&3013 (20 bytes), below the display at &6000 and above the BASIC program/heap. It owns MB%, LC%, V%, O%, H%, M%, guards and the marker. Remove the GOSUB 9000 call, guard/MB%/LC% setup and monitor.bas if you omit diagnostics. Caller globals N%, S%, EX%, K$ are separate from the helper. Q does not restore old MODE/HIMEM; reset or restore your own layout.

This Electron run stores 218 tokenised helper bytes and 1,096 bytes in the complete diagnostic program, including line headers/terminator. The observed dynamic variable heap occupies 99 bytes after these interactions; this is a snapshot, not peak RAM. BBC BASIC's resident single-letter integer table is additional. The observer reserves 20 more bytes. One recorded idle service sample was 11 centiseconds after its predecessor, including interpreted caller/diagnostic work. No helper-only runtime or whole-game budget is claimed.

The helper does a bounded subtraction, not a loop for every missed tick. Monitor serialization is deliberately readable and expensive. Redraw occurs only on actions/toggles/expiry. Work between calls determines response latency. The native clock can keep accumulating while the interpreter is busy.

## Evidence and sources

`verification/results.json` contains Electron-only cold firmware runs of working/custom/wrong/repaired callers and a second arithmetic caller (normal and faulty equality control). It reuses BBC source, not BBC execution evidence. Complete programs were typed, not injected. Native tokenised line inventory/lengths and guarded output are retained. Twelve synthetic-clock cases check zero/max duration, no movement, wrap and exact/overshot expiry. The one-character >= instead of > fault completes but must fail the same oracle. Synthetic arithmetic is not a wall-clock run over a complete rollover.

Named configuration: stock Electron 32 KiB PAL, MODE 6, Emu198x 0.44.1 with the OS/BASIC hashes in configuration.json. The idle observation advanced 202 centiseconds in 101 native fields, including mailbox settling. No original-hardware, other-ROM, minimum-RAM or whole-game performance claim is made. Retained checks and falsification controls check evidence; they do not rerun the emulator.

Repeat scripts/verify-electron-cpc-basic-deadlines.py with --systems acorn-electron, released tools and lawful firmware. Acorn Electron User Guide chapter 29, OSWORD A=1 and OSBYTE 129; The Advanced User Guide for the Acorn Electron printed p.88, OSWORD 1. The shared source README documents further BBC BASIC integration details. Native captures are Code198x's own program output; no firmware is distributed.
