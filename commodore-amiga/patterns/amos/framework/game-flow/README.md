# AMOS game flow: keep a session when play resumes

The working caller resumes with score 4 and finishes that session with score 6. The deliberate fault resets on every entry to Play: it resumes at 0 and finishes at 2. The repair restores the original caller. This separates entering a state from starting a new session.

## Build and run

Run `make` in this directory. In AMOS Professional 2.00, import `build/working.asc` into a blank project with Merge ASCII, check with F 2, then run with F 1. Let the original checker finish before starting execution. Press `q` to leave the result screen. Import each complete variant into a fresh blank project; merging variants can duplicate labels.

The generated `.asc` files are ASCII input for AMOS, not saved tokenised `.AMOS` programs. The builder joins settings, the small caller and the helper after `End`. `small` and `working` are identical. `custom` changes starting health from 3 to 5. `wrong` inserts the reset-on-resume fault; `repaired` restores the exact working source. `cases` is a separate diagnostic program, not the small caller.

## Include and own the context

Include `routines.amos` after the owner's `End`, reserve its `PL_GF_` names and call `Gosub PL_GF_INIT` once. No arrays, hardware, input reader, clock or work bank belong to the helper. Use normal signed integer variables, without a floating-point suffix. This is one context with one caller; it is not reentrant.

| Field | Ownership and result |
| --- | --- |
| `PL_GF_STATE` | Current state: Title 0, Play 1, Over 2, Paused 3 |
| `PL_GF_EVENTS` | Caller supplies a whole event mask 0..15; preserved by Step |
| `PL_GF_CHANGED` | Entry pulse;1 only when Step changes state |
| `PL_GF_FRESH` | Reset request;1 only on Title/Start or Over/Restart |
| `PL_GF_ERROR` | 0 valid;1 invalid state;2 invalid event mask |
| `PL_GF_NEXT` | Private transition scratch; do not share with another routine |

`INIT` zeros all six fields. Before each `Gosub PL_GF_STEP`, supply logical events: Start 1, Pause 2, Loss 4, Restart 8. Step clears the two pulses and error first. It validates state before events. Invalid input preserves the supplied state/events and does not change transition scratch. In particular,256 is invalid; checking only byte bits 4..7 would miss it.

| Old state | Decision |
| --- | --- |
| Title | Start enters Play and requests a fresh session |
| Play | Loss enters Over; otherwise Pause enters Paused |
| Over | Restart enters Play with a fresh session; otherwise Start enters Title |
| Paused | Pause resumes Play without a fresh session |

The helper selects one next state, then commits it. Simultaneous Loss and Pause choose Over. Simultaneous Restart and Start in Over choose a fresh Play session. Unused events in a valid mask have no effect. `CHANGED` and `FRESH` must be consumed before the next Step clears them.

## Put simulation and reset in the owner

The small caller processes a fixed 15-sample held-event trace. It derives fresh byte events from the previous held mask, updates score only for the old Play state, calls Step, then resets score/health only when `FRESH` is set. Entering Play does not run its simulation in that same update. Pause/resume preserves score, health and input history. Repeated held input does not repeatedly toggle pause.

The trace is a logical-input test, not qualification of a physical keyboard reader. In a game, keep input sampling and rendering outside this helper. Keep the previous held mask when resuming so the same held press does not become a second fresh event.

`wrong.amos` resets whenever Play is entered, including resume. The actual native wrong caller reports resumed 0, reset count 3 and finished 2. Working and repaired report resumed 4, reset count 2 and finished 6. Both end in Play with score 2 after a later fresh restart. Read the resumed/finished observations as well as the final score; the final score alone hides this fault.

## Costs and limits

Six ordinary integer fields hold 24 bytes of numeric payload using AMOS's four-byte integer representation. Names, labels, interpreter tables and GOSUB return frames add overhead. This is not a total heap, executable-size, minimum-memory or peak-stack claim. The small caller owns its score, health, edge history and trace counters; the helper leaves them alone. Maintained ASCII file lengths are reproducible source sizes, not tokenised or compiled code sizes.

The independent 360-row diagnostic requests a separate 17,284-byte work bank, confirmed by native `Length(1)` pixels. Each 48-byte row records incoming state/events, the complete six-field result, three preserved owner values and a completion marker. It uses 44 bytes of integer fields and a four-byte marker per row, plus the final four-byte completion marker. Bank headers, the resident runtime/editor and screen storage are additional. The small caller needs none of this bank. No timing or throughput claim is inferred from diagnostic completion.

Qualification so far uses original AMOS Professional 2.00 interpreted on a PAL A1200,2 MiB chip RAM and no fast RAM, through released Emu 198 x 0.44.1. It does not qualify other interpreters, compiled output, NTSC, original hardware or smaller machines. Five additional native records reject the signed minimum as a state and as events in each valid state. The guest constructs it by assigning -2147483647 and decrementing once, avoiding an out-of-range positive literal. Adjacent negative values and the positive maximum are also observed.

## Retained verification

`oracle.py` supplies a literal four-by-sixteen transition table independent of the helper's conditional statements. The native observer covers all 64 valid pairs, all 252 other byte-valued states, four signed/wide state inputs and 40 invalid event pairs, including 256,512,65535 and the positive signed maximum. It records full 32-bit values, not truncated bytes. Nonzero initial pulses prove that invalid calls clear old pulses; payload 65537 exposes upper-bit corruption.

The native verifier imports source-bound fixture media, reads the guest-selected bank address from actual screen pixels and compares every byte against that table. The retained checker also reads native count, exit and allocation pixels. Source/runtime/import/capture hashes bind the evidence. Deliberately changed records, completion markers, state/payload upper bits, pulses and identities must be rejected. Separate original-runtime imports observe all five small caller variants. Firmware-bearing snapshots and licensed runtime media stay private.

Use `scripts/verify-amos-game-flow.py` and `scripts/verify-amos-game-flow-callers.py` with the matching lawful local firmware/runtime, recorded tools and a fresh private fixture. `scripts/check-amos-game-flow.py` validates retained proof; `scripts/test_amos_game_flow.py` challenges it. These retained checks do not boot the interpreter in CI.

## Connections

For Maths for Games, treat state as a finite set and events as a bit set: the transition table is a function from one old-state/event pair to one next state. Priorities make simultaneous inputs deterministic. For Craft, keep the state decision separate from simulation, rendering and session ownership. A state-entry pulse and a session-reset request serve different jobs.

Primary reference: *AMOS Professional User Guide*, the sections on integer variables, structured control, GOSUB/RETURN and memory banks. Preserve this runtime's syntax when adapting the example; source accepted by another BASIC dialect is insufficient evidence.
