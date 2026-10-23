# A MOS clock with an optional turn deadline

Space takes one turn, T enables/disables timing, reset leaves. An untimed world waits for the player. Enable timing and one overdue deadline takes one turn without a key, then starts over. The display shows hexadecimal turn count, expiry count and active flag. It is not a live countdown.

BBC Micro and Electron share this maintained implementation, the five-byte MOS OSWORD 1 clock reader, and the existing cross-platform 6502 deadline helper. Their firmware and execution records are separate. Both tested targets have 32 KiB, PAL output, MODE 6 and stock OS/BASIC. Do not infer identical display contention or performance from the common ABI.

## Build and include

`make ASM198X=/path/to/asm198x` uses the website's pinned 0.0.65 assembler. Enter the generated `build/loader.bas` into a fresh BASIC program and RUN. It lowers HIMEM to &2F00 and installs the complete executable at &3000, below MODE 6's &6000 display. Reset/NEW before switching complete variants. The loader does not save your old mode or memory layout; reset or restore your own layout before another program.

For a project, include `settings.inc`, your caller, `clock.inc`, `input.inc`, `dispatch.inc` and `cross-platform/patterns/framework/elapsed-deadline/6502.inc`, each once. CodeFromFile pages show the maintained pieces. Place returning routines outside the main execution path, or jump over them. The small dispatcher and display are example policy, not part of the deadline algorithm. You can omit the input/display/dispatch and drive the helper yourself.

1. Define DEADLINE as twelve writable bytes, clear decimal mode, and keep firmware interrupts running. Set duration at +0/+1, little endian, 0..65535. Zero disables.
2. Obtain a clock sample in A (low) and X (high), then JSR deadline_init. It begins disabled and records the baseline.
3. JSR deadline_start enables/restarts from the latest sample. Sample/poll immediately before starting when that instant matters.
4. On every service, even while disabled, call sample_clock then deadline_poll. Read +5 immediately: it is one poll's expiry event. Next poll/start clears it.
5. The caller decides whether to advance and restart. This caller gives expiry priority over Space and T, discarding that poll's edges. An active Space restarts, untimed Space stays untimed. T disables and discards remaining time; re-enable starts over. One overdue event produces one turn, never a catch-up burst.

## State and ownership

| Offset | Agreement |
| --- | --- |
| 0..1 | Caller duration, unsigned ticks |
| 2..3 | Helper remaining time, saturated at zero |
| 4 | Active, 0/1 |
| 5 | Latest poll's expiry, 0/1 |
| 6..7 | Elapsed ticks from that poll |
| 8..9 | Previous clock sample |
| 10..11 | Helper scratch current sample |

The helper clobbers A/X/status and preserves Y; decimal mode must remain clear. It is not re-entrant and must not share one block between foreground and IRQ callers. JSR/RTS uses the existing 6502 stack; do not JMP into a routine expecting RTS without arranging a return address. The helper makes no nested JSRs. MOS calls can use more stack and clobber A/X/Y/flags; do not carry register values across them. Firmware IRQ stack use is additional and not isolated here.

The example owns &2F00–&2F0B (12 deadline bytes), &2F0C–&2F0D (two diagnostic guard bytes), &2F20–&2F29 (10 caller/input bytes) and &2F30–&2F34 (all five OSWORD result bytes). STATE+0..2 are spare/cleared, +3 previous held mask, +4/+5 turns, +6 automatic expiries, +7 redraw request, +8 pressed mask and +9 current held mask. Relocate these constants consistently and reserve against other modules. No fixed zero page, IRQ vector, hardware timer or system-clock ownership is taken. MODE 6, normal MOS VDU/keyboard services and the loader's memory reservation belong to this demonstration.

OSWORD 1 needs five writable result bytes even though this adapter uses two. Reading only one clock byte loses most of the range; reserving only two result bytes lets MOS overwrite neighbours. Do not replace the call with an unprotected pair of direct clock reads: the low byte can wrap between them.

## Clock and input differences

MOS exposes centiseconds: 100 ticks per second, although the Electron's physical real-time interrupt source is 50 Hz. The named PAL runs observe 60 centiseconds during 30 display fields. This is a serviced firmware clock, not a promise of an independent 100 Hz Electron interrupt or one-centisecond response granularity. Keep IRQs enabled and preserve the normal MOS path. Long interrupt blocking can lose clock service; the helper cannot reconstruct missing time.

Low 16 bits wrap every 655.36 seconds. Consecutive samples must be less than 65536 ticks apart; a whole missed cycle cannot be distinguished. A clock reset is not wrap: reinitialise and restart after an external clock change. The helper never resets the shared clock. A display wait is unnecessary for this untimed/polled service; add pacing only when your workload needs it.

`sample_keys` uses OSBYTE 129 physical key tests: X=&9D for Space (INKEY(-99)), X=&DC for T (INKEY(-36)), Y=&FF. Bit 0 means Space, bit 1 T. `pressed = held AND NOT previous` counts one action per observed press, ignoring firmware autorepeat. Release must be observed before another edge. Very short taps between samples can be missed. Neither a character buffer nor a blocking line reader provides this same contract. Normal keyboard buffering still occurs; these tests do not drain or own it.

## Customise, diagnose and extend

Change `DURATION = 400` to `200` for roughly four seconds to two, in both machines. `verify-mos-deadlines.py` builds and executes that exact substitution as a second public caller. Change the dispatcher for a different turn policy without rewriting the helper. Extra deadline contexts need distinct state, plus distinct labels or a pointer-based helper; this absolute-address implementation is a single context.

The maintained `mistakes/input-gated-expiry.inc` adds a bad early return when no key edge arrives. It lets the helper expire, but skips the turn and restart. Symptom: clock advances, remaining is zero and active state is off, yet no automatic turn occurs. The visible timer flag remains stale at 01 because redraw was skipped too. The one-poll event has already vanished by the next key press. Replace that dispatch with `dispatch.inc`; a fresh repaired run advances without input. Never hide timer processing inside an input-only branch.

Arithmetic is subtraction modulo 65536: for previous=65530 and now=5, elapsed=11. Subtract elapsed from remaining, then expire on underflow **or exact zero**. The native second caller checks twelve synthetic-clock cases, including zero/max duration, no movement, wrap and exact/overshot expiry. Its single changed equality branch must fail the same oracle after completing. That second caller checks arithmetic on each machine's CPU under stock boot, not native clock accuracy over a whole rollover.

This caller restarts at observation time, which can drift after late servicing. Carrying lateness, fixed-step accumulation, a wider clock, preserved pause state and queued commands are different useful policies, not hidden features. Maths for Games explains the wrap/subtraction; curriculum projects can choose how those rules affect play.

## Evidence and costs

`verification/results.json` and `configuration.json` live separately under both systems. Public runs cold-boot, type the complete loader, RUN, and compare every installed executable byte. Only reads/input/captures follow; no debugger state injection creates a result. They cover untimed idle/action, clock/countdown agreement, expiry without input, active restart, held-key suppression, disabled timing, shorter duration, wrong and repaired dispatch. Independent image decoding compares visible counts with guarded state. In the wrong expiry capture, the display retains its old active flag because the bad dispatcher also skips the redraw request; the guarded active state is already zero. Retained checks bind exact source/observer/tool/firmware identities and reject falsified evidence; they do not rerun emulation.

The checked assembly contains 140 helper bytes and a 16-byte clock adapter within the 445-byte public executable. Its helper state is 12 bytes, clock buffer 5, caller/input 10, optional guards 2: 29 scratch/diagnostic bytes beyond code. The loader reserves a larger memory range; these are used bytes, not the size of that whole reservation. The wrong dispatcher adds five code bytes. Counts come from assembled symbol distances and actual binary length, not source-line estimates. MOS/VDU firmware, existing stack and interpreter costs are additional. No helper-only cycle measurement or whole-game frame budget is claimed. Firmware polling, redraw and BBC/Electron memory contention differ; measure your actual workload.

The helper performs a bounded subtraction per poll, never one iteration per elapsed tick. Each clock service asks MOS to copy five bytes although only two are consumed. Display updates happen only when state changes. A faster direct hardware reader trades portability and firmware coexistence for tighter control; it is not silently substituted here.

## Sources

Acorn *Electron User Guide*, chapter 29 OSWORD A=1 and OSBYTE 129; *The Advanced User Guide for the Acorn Electron*, printed p.88, OSWORD 1, plus keyboard call table. BBC Micro *Advanced User Guide*, §9.3 printed p.248 OSWORD 1 and §8 OSBYTE 129. OSWORD clock units are centiseconds; physical interrupt sources differ.

Repeat `scripts/verify-mos-deadlines.py --tools ... --firmware ... --assembler ...`; supply the verified released binaries and lawful OS/BASIC ROMs described by the configuration records. Native Emu198x 0.44.1 and Asm198x 0.0.65 were used. No firmware or runtime media is distributed.
