# Optional turn deadlines in BBC Micro BASIC II

Press Space to spend one turn. Leave timing disabled and the world waits. T enables a deadline; another T disables it. Q ends the demo. Expiry advances one turn even with no input, then starts a fresh deadline. The display shows the turn, automatic expiry count and active flag; it is not a live countdown.

## Load and reuse

Run `make` here, enter `build/demo.bas` as one numbered program, then RUN. `build/customise.bas` has half the duration. `build/wrong.bas` deliberately replaces the clock adapter with the baseline-reset mistake. Reset/NEW before entering a different complete variant so old line numbers do not survive.

Include `caller.bas`, `turn.bas`, `routines.bas`, `clock.bas` and `monitor.bas` together. Numbered BASIC lines determine execution order, rather than file order. Reserve all shown line numbers. Renumber consistently, including GOSUB/GOTO targets. The turn rule reuses the bounded expression from the sampled turn loop; the new caller consumes delivered characters rather than physical press edges. The older untimed example remains usable without any deadline code.

To use only the helper, include lines 3000–3250 from `routines.bas`:

1. Set `DU%` to the duration and `DC%` to the current clock; `GOSUB 3000` initialises disabled state and the previous sample.
2. `GOSUB 3100` starts/restarts: remaining becomes duration, zero duration disables. This uses the latest sampled baseline, so sample/poll immediately before starting when that instant matters.
3. Every service iteration, including while disabled, set `DC%` and `GOSUB 3200`. Read `DX%` immediately. This is an event for that poll; the next poll clears it.
4. On expiry the helper clamps remaining to zero and disables itself. Decide in your caller whether to change the game or restart it. Writing `DA%=0` disables timing. The helper has no pause/resume operation.

| Global | Agreement |
| --- | --- |
| DU% | Caller duration, whole number 0..65535; 0 disables |
| DC% | Caller-supplied clock, whole number 0..65535 |
| DP% | Helper-owned previous clock sample |
| DR% | Helper-owned remaining ticks, saturated at zero |
| DA% | Helper-owned active flag, 0 or 1 |
| DX% | Helper-owned expiry event, 0 or 1 |
| DE% | Helper-owned elapsed ticks from this poll |

These are shared BASIC globals. Rename consistently to avoid other modules; the % suffix selects signed 32-bit integers. The integer ranges above are exact in this representation. The helper owns no fixed RAM, keyboard, display, firmware vector or hardware timer. It creates no arrays or strings and performs a fixed number of statements per poll, rather than looping once per missed tick. GOSUB requires the interpreter’s return frame; do not jump into a returning routine with GOTO. It is one mutable context, not a re-entrant service.

## Machine clock and input

The adapter reads `TIME AND &FFFF` and calls the helper. This deliberately uses only the low 16 bits of the centisecond clock: 100 ticks per second, wrapping every 655.36 seconds. It is not the full five-byte MOS clock or a full-width TIME adapter. Keep ordinary MOS IRQ/timer service running.

At most one rollover may be crossed between consecutive samples: the elapsed interval must be strictly less than 65536 ticks. A missed whole cycle is indistinguishable from less elapsed time. Resetting the shared clock is not a rollover; reinitialise/restart your context after an external clock change. The adapter never resets the global clock itself. The largest duration is a representation bound, not permission to stop polling for an entire wrap.

`INKEY$(0)` reads without waiting for Return. It consumes firmware-delivered characters, including typeahead and repeat; a held key is not promised to count once. Buffered characters can survive until a later poll. Use a physical edge reader when that is the intended control contract. A blocking INPUT/GET line collector would stop this BASIC loop servicing expiry; timers do not make the interpreter concurrent.

The caller polls time, samples one character, then handles expiry first. Simultaneous expiry wins and discards that iteration’s character, even Q or T. Otherwise Space advances once and restarts only an already enabled timer. An untimed Space stays untimed. T enables with a fresh duration or disables; re-enabling starts over rather than preserving old remaining time. A long overdue deadline produces one turn, not catch-up turns. Restarting at observation time introduces drift; carry lateness or use an accumulator if your game needs another policy.

## Customise and diagnose

`customise.bas` changes only `DU%=400` to `DU%=200`: roughly four seconds becomes two. Use clock units, not assumed frame counts. Integer subtraction and wrap arithmetic connect directly to Maths for Games; deadlines are a game policy separate from display pacing.

The deliberately wrong `mistakes/reset-baseline.bas` writes `DP%=DC%` immediately before polling. Elapsed time is consequently always zero. The native clock advances, the timer stays active, remaining stays at the full duration and no automatic turn occurs. Restore `clock.bas`; a separate fresh repaired run expires correctly. Only initialisation should replace the baseline without consuming elapsed time. Do not include this wrong adapter alongside the correct adapter: their line numbers intentionally replace one another.

## Presentation and optional diagnostics

The caller selects MODE 6 and lowers HIMEM to &3000, reserving &3000–&3013 for its optional 20-byte observer. Keep the BASIC program and heap below HIMEM and the display above the reservation. Q does not restore the old mode or HIMEM; reset or restore your own previous layout before another program.

The helper itself does not need this reservation. Remove GOSUB 9000, the guards, MB%/LC% initialisation and `monitor.bas` to omit the observer. The monitor owns MB%, LC%, V%, O%, H%, M%; the caller owns N%, S%, EX% and K$. The observer writes three-byte little-endian remaining/clock/duration/elapsed fields, byte turn/expiry/active flags, guards 165/90 and completion marker 239. A marker of zero means a partial snapshot; this is diagnostic data, not a synchronisation API for a second game task.

The observer is intentionally readable and expensive, especially in C64 BASIC. It slows service opportunities; a native clock continues to accumulate time between them. Neither the caller nor helper promises a frame budget or zero-latency expiry. Redraw happens only on actions, toggles and expiry. Polling resolution depends on all your work between calls, including display and sound.

## Qualification

`verification/native.json` retains independent cold-firmware runs of working, shorter, wrong and repaired public callers, typed through the keyboard. No debugger writes initialise guest state. `verification/boundaries.json` comes from a second BASIC caller (`boundaries.bas` plus the same helper and byte writer): twelve synthetic-clock cases execute in the interpreter and are checked against an independent arithmetic oracle. Synthetic clock tests establish arithmetic, not native clock accuracy or a 24-hour wall-clock run.

Repeat using `scripts/verify-basic-deadlines.py` and `scripts/verify-basic-deadline-boundaries.py`, supplying `--tools` and `--firmware`. Native tools are the verified Emu198x 0.44.1 Apple Silicon binaries; firmware/tool hashes are in the records. BBC Model B, 32 KiB, MOS/BASIC II, MODE 6 is the named configuration. No original-hardware, other-ROM or other-region execution claim is made.

## References and extensions

BBC Micro Advanced User Guide, §9.3 OSWORD 1 (printed p.248), five-byte centisecond system clock; §8 OSBYTE 129 timed key read. The BASIC ROM User Guide (1984), BASIC II memory map and TIME/INKEY$ language behaviour.

Longer clocks, preserved pause state, queued commands, multiple deadline contexts, fixed-step catch-up and tighter assembly service are possible extensions, not hidden features. Prefer each only when its resource cost and policy fit the game. No routine can recover time its chosen clock did not count.

## Measured costs

The native interpreter stored **218 bytes of tokenised helper lines**, including line headers. The complete diagnostic caller occupies **1096 tokenised program bytes**. Its observed dynamic variable heap occupies **99 bytes** after the checked interactions; this is a snapshot, not a peak-memory promise. BBC BASIC’s resident single-letter integer table is outside that dynamic heap. The optional observer reserves another **20 bytes**. In the recorded disabled-idle snapshot, successive service samples were **8 centiseconds** apart with the observer present; that includes interpreted caller/diagnostic work and is not the cost of the helper alone.
