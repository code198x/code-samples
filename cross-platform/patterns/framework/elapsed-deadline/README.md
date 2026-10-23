# A clock is not a turn

These independent 6502 and Z80 routines consume the low 16 bits of a caller-supplied clock. They neither read input nor wait, render, allocate memory, install an interrupt or choose when a game turn starts. The native Atom and CPC callers show different clock and input adapters.

## Include, initialise, poll, start

Reserve DEADLINE as a consecutive block that no other module owns: **12 bytes on 6502, 10 on Z80**. Set its duration word at +0/+1 (little endian). Pass the current clock in A/X (low/high) on 6502 or HL on Z80 to `deadline_init`. This sets the baseline and disables the timer. Include the matching `.inc` after your caller; avoid colliding labels and contexts.

Pass a fresh clock value to `deadline_poll` every service iteration, including while disabled. Read +5 immediately: 1 means the active deadline expired **in that poll**, 0 otherwise. `deadline_start` copies the duration into remaining time and enables the timer; a zero duration disables it. The caller can disable it by writing zero to +4. Polling still maintains the clock baseline. Set duration before calling start; do not change it mid-deadline and expect remaining time to change.

| Offset | Bytes | Meaning |
| --- | --- | --- |
| +0 | 2 | Caller-owned duration, 0 disables; otherwise 1..65535 ticks |
| +2 | 2 | Remaining ticks, 0 on expiry |
| +4 | 1 | Enabled flag, 0 or 1 |
| +5 | 1 | Expired on this poll, 0 or 1 |
| +6 | 2 | Elapsed ticks consumed by this poll |
| +8 | 2 | Previous clock sample |
| +10 | 2 | 6502-only temporary current-clock word |

All words are unsigned. Modular subtraction handles one clock rollover, provided fewer than 65536 ticks pass between polls. It cannot detect a whole missed rollover. A clock that resets independently must be reinitialised; it is not an ordinary wrap. Remaining time saturates at zero on expiry. The routine disables itself and reports one event; it never underflows into a long future wait. Further polls clear the event. It does not replay every overdue turn or carry excess elapsed time into a new turn.

Clear decimal mode before using the 6502 implementation. Init/poll clobber A, X and status; start uses A/status. Y is preserved. A JSR uses two stack bytes. The Z80 routines clobber AF, DE and HL across the interface; BC/IX/IY are preserved. CALL uses two stack bytes. Neither changes interrupt state. One mutable context is not reentrant; independent timers require independent state and a separate label/context arrangement.

## Caller policy

The example callers poll time first. If a deadline expired, that iteration commits exactly one automatic turn, starts a new deadline and ignores the sampled input. Otherwise an action commits a turn and restarts an already enabled timer. It leaves untimed mode untimed. T toggles timing. This expiry-first policy is a choice, not a property of the helper. If your design queues simultaneous input, make that explicit.

The Atom counts **observed** falling edges of PPI PC7; unseen sync edges are lost. The CPC reads KL TIME PLEASE and uses its low 16 bits. Both are bounded polling examples, not fixed-step catch-up engines. The Atom's signal sampling is a different limitation from the helper's modular rollover limit.

## Costs and alternatives

Assembled with Asm198x 0.0.71, the helpers occupy 140 bytes (6502) and 97 bytes (Z80). Both use bounded constant work per poll rather than a loop per elapsed tick. Contexts use 12 and 10 bytes; the callers reserve another ten state bytes and two diagnostic guard bytes. These are executable/data sizes, not complete RAM requirements: firmware, stack, display and the typed loader also occupy memory.

The qualified complete callers occupy 479 bytes on Atom and 326 on CPC. They print only when a turn changes, rather than redrawing continuously. A firmware character output or clock read can cost more than the helper; no stand-alone cycle count or whole-game frame budget has been measured. Choose a wider clock for longer service gaps, an interrupt-maintained clock where appropriate, or a scheduler/catch-up policy when missed work must be accounted for. Those are extensions requiring their own contracts and verification.

## Qualification

Use the individual callers' Makefiles and verification directories. They are entered from cold stock firmware through their complete generated BASIC loaders. The observer compares every installed machine-code byte in reads of at most 256 bytes, checks idle/action/expiry/restart/disable behaviour and guards, changes the duration, and runs the input-gated expiry mistake and a fresh repaired caller. Atom also starts its observed clock near rollover.

Separate original reset-ROM fixtures execute twelve arithmetic cases per CPU, including zero/maximum durations, no elapsed time, exact/overshot deadlines and rollover. A deliberately incorrect zero-boundary branch completes the fixture but fails the independent host arithmetic oracle. Those fixtures qualify CPU/RAM arithmetic, not firmware loading, display timing or original hardware.

```sh
python3 scripts/verify-firmware-deadlines.py --tools RELEASE_DIRECTORY --firmware ROM_ROOT --system acorn-atom
python3 scripts/verify-firmware-deadlines.py --tools RELEASE_DIRECTORY --firmware ROM_ROOT --system amstrad-cpc
python3 scripts/check-firmware-deadlines.py
python3 -m unittest discover -s scripts -p test_firmware_deadlines.py -v
```

The release directory contains the extracted `asm198x-aarch64-apple-darwin`, `emu198x-acorn-atom-aarch64-apple-darwin` and `emu198x-amstrad-cpc-aarch64-apple-darwin` archives. ROM_ROOT contains the normal per-machine firmware folders. Supply your own firmware. Retained checkers validate observations/source bindings; they do not run an emulator.
