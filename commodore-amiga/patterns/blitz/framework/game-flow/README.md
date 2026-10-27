# Blitz game flow: preserve a paused session

The working caller resumes with score 4 and finishes that session with score 6. The deliberate wrong owner resumes at 0 and finishes at 2 because it resets whenever Play is entered. A later fresh restart leaves both at score 2, so the final score alone hides the fault.

## Build, include and call

Run `make`. In original Blitz BASIC 2.10 / Ted 1.1, insert `build/working.asc` into a blank project and compile/run with Amiga-X. Press Q to close the result window. Use a fresh blank project for each complete variant so labels do not collide. The generated ASCII files are source imports, not compiled executables or native editor saves.

The builder joins `settings.bb2`, `caller.bb2` and `routines.bb2`. Keep helper labels after the owner's `End`. Call `Gosub PL_GF_INIT` once, then supply logical events and call `Gosub PL_GF_STEP` once per update. Reserve all six `PL_GF_` long fields for this one mutable context. This helper is not reentrant and owns no arrays, input reader, clock, bank, window or interrupt.

| Long field | Contract |
| --- | --- |
| `PL_GF_STATE` | Title 0, Play 1, Over 2, Paused 3 |
| `PL_GF_EVENTS` | Caller input: integer mask 0..15, preserved by Step |
| `PL_GF_CHANGED` | One-update state-entry pulse |
| `PL_GF_FRESH` | One-update request to reset session data |
| `PL_GF_ERROR` | Zero valid, one invalid state, two invalid events |
| `PL_GF_NEXT` | Private transition scratch |

Init zeros all six fields. Step first clears pulses and error, validates state before events, selects one next state, then commits once. Invalid input preserves state, events and scratch with cleared pulses and error 1 or 2. Negative events and values such as 256 are rejected before membership arithmetic. A low-byte-only check would miss them.

Events are Start 1, Pause 2, Loss 4 and Restart 8. Title/Start enters fresh Play. Play/Loss enters Over; otherwise Play/Pause enters Paused. Over/Restart enters fresh Play; otherwise Over/Start enters Title. Paused/Pause resumes Play without requesting a reset. Loss wins Pause; Restart wins Start. Other valid event bits have no effect. Consume pulses before the next Step clears them.

The source uses bounded `MOD` arithmetic for bit membership after domain validation. It does not rely on another BASIC dialect's numeric `AND`. Globals, arrays where present in callers, and typed `Data.l`/`Read` retain the original compiler's long representation.

## Simulation and session ownership

The small caller processes fifteen fixed held-event samples. It derives fresh logical events with a bounded four-bit pass and preserves the previous held mask across pause. It updates score for the old Play state, calls Step, then resets score and health only on `FRESH`. Entering Play does not simulate Play in that same update. Holding Pause cannot toggle repeatedly without release. This is logical-event qualification, not a physical keyboard-reader test.

`small`, `working` and `repaired` have identical generated source. The custom owner changes fresh-session health from 3 to 5. The wrong variant changes only the reset condition to include every entry to Play. Native working/repaired outputs are resumed 4, resets 2, state 1, score 2, health 3, finished 6. Wrong gives resumed 0, resets 3 and finished 2. Restore the FRESH-only condition to repair it; all variants must compile and complete for that comparison to mean anything.

The complete owner opens a 420×180 window on the Workbench screen and prints the result. Normal Q exit closes its window and returns to Ted. That normal path does not qualify arbitrary interruption or restore another owner's window state. Put presentation and input under your game's existing owner when integrating the helper.

## Resources and bounded diagnostics

Six four-byte long fields hold 24 bytes of numeric payload. Compiled instructions, runtime bookkeeping, call-stack use, editor, screen and window storage are additional; their separate sizes have not been isolated. Source lengths are not executable sizes, and this does not establish minimum RAM or peak stack usage.

Diagnostics are separate programs, not required by the small owner. Six independent imports contain 64,64,64,64,64,46 full records. Each record holds eleven signed longs and a four-byte row marker, giving 48 bytes. Five native banks are 3,080 bytes each and the last is 2,216 bytes, confirmed by actual `BankSize` screen digits. Each bank includes two final long guards; headers are additional. Total allocation across these independent runs is 17,616 bytes. Joining only their record bodies with one final guard pair produces the 17,576-byte canonical observation packet. No single diagnostic run needs the combined allocation.

The bounded imports fit the original compiler's default object buffer on the checked configuration. Increasing diagnostic DATA without rechecking that resource may fail compilation. Completion proves the observed workload finished, not a frame-time or throughput budget. The diagnostic owner allocates bank 0, exposes its actual address and size, and frees it on normal exit; coordinate that bank number with other owners.

## Original runtime and retained verification

All eleven imports ran through original Blitz BASIC 2.10 / Ted 1.1 on released Emu198x 0.44.1, configured as a PAL A1200 with 2 MiB chip RAM and no fast RAM. This qualifies those compiled runs, not original hardware, another compiler/runtime, NTSC or a smaller machine.

An independent literal four-by-sixteen table covers all 64 valid state/event pairs. Additional rows cover all 252 remaining byte states, four signed/wide states, forty invalid event pairs, five signed-minimum inputs and one nonzero-seeded Init. The guest constructs the signed minimum by subtracting one from -2147483647. Init starts with nonzero pulses/error and scratch so missing resets are observable. Preserved owner payload 65537 exposes upper-bit corruption. All full contexts, payload and row/global guards are checked, not only the final state.

`scripts/verify-blitz-game-flow.py` imports source-bound fixture media, compiles through the original editor, obtains guest bank addresses from actual screen pixels and compares every byte. It also checks native count, pulse, allocation and font digits, five usable owner outputs, and changed result/exit captures. No fixed bank address or injected instruction pointer runs the helper. Firmware-bearing snapshots and licensed runtime disks remain private.

`scripts/check-blitz-game-flow.py` checks retained proof without booting the runtime. It requires all six unique chunks in order, all 366 rows, all five owners, exact source/program/fixture/runtime/capture identities, full independent packets and actual native pixels. `scripts/test_blitz_game_flow.py` challenges coverage, upper bits, pulses, Init, payload, completion guards, source identities and pixels; recomputing a false packet's hash cannot make it pass. Re-run native verification with matching lawful local media and a fresh private fixture whenever qualified runtime inputs change.

For Maths for Games, the state table maps a finite old-state/event pair to one next state. Priorities make simultaneous events deterministic. For Craft, keep this transition decision separate from simulation, input history and session resets. State entry and a fresh session serve different purposes.
