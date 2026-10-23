# Optional deadlines in Jupiter Ace FORTH

Enter `build/demo.fth` one line at a time after `make`, then follow its final TURNS call. 1 advances the turn, 2 toggles timing, 0 quits. Timing starts disabled. With it enabled, no input is needed for the next turn: the deadline advances it and starts again. The count is a 16-bit unsigned cell, displayed with U.; it wraps after 65535.

Load order matters: routines.fth, clock.fth, service.fth, input.fth, caller.fth, settings.fth, then TURNS. FORTH binds a word reference when compiling the definition. Load an alternative service **before** compiling caller.fth; redefining it afterwards does not change the caller already compiled. Reset before changing complete variants to reclaim dictionary space. DECIMAL is selected explicitly.

## Reuse the helper

`routines.fth` defines five two-byte variables (ten payload bytes) and three words:

- `DINIT ( now -- )` stores the first clock sample and clears remaining/active state. Set DU separately.
- `DSTART ( -- )` copies DU to DR. DU=0 disables; otherwise it enables DA. It preserves the latest sampled baseline, so poll immediately before starting if that instant matters.
- `DPOLL ( now -- expired )` consumes a current sample and returns 0 or 1. It updates DP even while disabled. Expiry clamps DR to zero and disables DA. Read the returned event now; the next call computes another event.

DU is caller-owned duration, 0..65535 ticks. DP (previous), DE (elapsed), DR (remaining) and DA (active 0/1) belong to the helper. Samples and durations are unsigned cells. Subtraction wraps modulo 65536; **U<** is required for the elapsed-versus-remaining comparison. The helper neither reads hardware nor changes the game, display, keyboard or interrupts. Calls preserve lower stack entries, not arbitrary duplicate contexts. Globals and word names must not collide; this is one mutable context and is not re-entrant.

An elapsed interval must be less than 65536 ticks between polls. A full missed cycle looks like fewer ticks. Zero duration is a disabled policy, not a 65536-tick interval. Whole-clock resets need reinitialisation; they are not ordinary wrap. A late poll produces one event, not a catch-up series. Starting again at the observation time introduces drift. Longer clocks, separate contexts, preserved pause state and fixed-step catch-up are explicit future adaptations.

## Clock adapter

The stock ROM maintains a four-byte FRAMES counter at decimal 15403. `clock.fth` deliberately exposes only its low 16 bits. It reads high, low and high again, retrying if the high byte changed. This avoids accepting a torn low-byte carry; ordinary @ can be interrupted halfway through its byte reads. Interrupts remain enabled. `service.fth` samples DCLOCK and calls DPOLL.

A tick is nominally 1/50 second, so 200 ticks is roughly four seconds and low-word wrap is roughly 21 minutes 51 seconds. The original manual gives the physical interval as 624/625 of a fiftieth, rather than a precision civil-time clock. BEEP and tape activity stop the ROM clock. The adapter does not reset FRAMES and cannot recover ticks the ROM did not count. Keep its normal interrupt service intact. No NTSC or alternate-ROM result is claimed.

## Caller and input

The bounded counter update comes from the existing untimed TURNS word. `input.fth` adds a nonblocking release gate: INKEY=0 re-arms KP; while a key remains held the word returns 0. A new nonzero key is delivered once, then another observed release is required. This is a physical sampled-key policy, not buffered character delivery. A press wholly between polls can be missed. Changing directly from one nonzero key to another does not re-arm it.

TURNS retains one counter cell on the data stack. It polls time, samples FKEY, then handles expiry before input. Expiry discards that iteration's key, including 0 or 2. Otherwise 1 advances once and restarts only an already active timer. An untimed action stays untimed. 2 disables or starts with a full duration; it does not preserve a paused remainder. 0 drops the caller's counter and returns without leaking stack cells. SHOW clears the screen and displays TURN/TIMER; the screen is not restored on return.

The old NEWKEY word is intentionally still a blocking untimed example. Using it unchanged here would prevent deadline service while waiting for a decision. This loop runs continuously; clock sampling is not a frame wait. Replace SHOW with your own feedback, while keeping the helper serviced.

## Customise and diagnose

`customise.fth` changes DU from 200 to 100, without new words or state: roughly four seconds becomes two. The independently executed customisation keeps the same key and expiry policy.

`mistakes/reset-baseline.fth` is deliberately broken. It stores the current clock as DP just before DPOLL. Elapsed is always zero: the clock advances, but DR stays at 200, DA stays enabled and no automatic turn arrives. Choose this file instead of service.fth **before compiling the caller** to reproduce the fault. Reset and load service.fth to repair it. A separate repaired native run expires correctly.

The arithmetic negative control changes U< to signed < in a fresh ROM fixture. Small durations can appear fine. Duration 65535 with elapsed 1 instead expires immediately, because signed comparison interprets 65535 as -1. It completes the second caller and preserves its stack tag; the independent unsigned oracle rejects the result. This test-only mutation is not in a normal generated program.

## Measured costs and limits

On the unexpanded 3 KiB machine, the reusable helper uses **230 dictionary bytes**, including ten state payload bytes and word headers. The stable clock adds 69 bytes; service adds 21; release-gated input adds 80 (including KP); caller/presentation adds 230. Settings allocate no dictionary storage. Total maintained definitions: **630 bytes**. A separate 19-byte NUMBER observation word used in qualification is outside those figures.

The checked dictionary ended at 16090, with RAM top 16384 and the ROM's twelve-byte dictionary/data-stack gap. The minimum *observed* separation between data-stack top and CPU/return-stack pointer was 258 bytes (252 for the deliberately longer faulty service). These snapshots are not an exhaustive peak-stack proof or spare space promised to a larger game. After every caller exit, the data stack returned exactly to HERE+12. Growing a game or adding further words may need an expansion; display and character RAM are not extra free dictionary RAM.

State work is bounded subtraction/comparison and possible remaining update. DCLOCK retries if it overlaps a byte carry. Interpretation, dictionary lookup, ROM interrupts, printing and your own work determine service latency. No cycle count or whole-game frame budget is inferred from the source size.

## Qualification

Emu198x 0.44.1; unexpanded stock FORTH ROM, 8192 bytes, identity pinned with the executable in the records. Four fresh keyboard-entered callers cover working, 100-tick customisation, baseline-reset fault and repaired service. They check idle, a 120-field held action, no-input expiry, restart, disable, normal exit and observed stack separation. Native clock/state and raw 32×24 screen bytes back the counters. Captures settle for two additional fields; every active pixel is compared with native screen and character RAM before an image is accepted. The retained checker independently repeats that pixel comparison.

`boundaries.fth` is a second caller using the same helper without a keyboard policy. Sixteen cases cover zero/maximum duration, no elapsed time, 16-bit wrap, exact/overshot expiry and the signed boundary. It prints a case identifier and a lower-stack tag and returns to an empty stack. The signed-comparison control executes the same cases and is rejected by an independent oracle. Synthetic samples establish arithmetic, not an observed 21-minute rollover or original-hardware accuracy.

From the repository root, run `scripts/verify-ace-deadline.py --emulator /path/to/emu198x-jupiter-ace` and `scripts/verify-ace-deadline-boundaries.py --emulator /path/to/emu198x-jupiter-ace`, with `--firmware` if needed. `verification/sources.json` binds maintained source and observers; retained checks are `scripts/check-ace-deadline.py` and `scripts/test_ace_deadline.py`. Licensed firmware and running snapshots are not included.

Primary reference: *Jupiter Ace User Manual* (1982), chapter 24 “How the memory is laid out”, especially FRAMES and exercises 2–3 (printed pp.141–145); chapter 17 unsigned arithmetic; chapter 25 interrupt handling. The stable high/low/high adapter is this implementation's bounded low-word design, rather than a claim that the manual supplies this exact word.
