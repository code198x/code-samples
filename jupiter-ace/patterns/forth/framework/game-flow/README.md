# Ace game flow: resume without resetting progress

The working owner resumes with score 4 and finishes that session with 6. The wrong reset policy resumes at 0 and finishes at 2. A later fresh restart leaves both at score 2, so the final score alone hides the fault.

## Enter and run

Run `make`, then enter `build/working.fth` one line at a time in the stock Jupiter Ace FORTH ROM. The file defines the helper, reset policy and owner, selects starting health, then issues fifteen ordinary interpreted `GTICK` commands. Its three `GSHOW` calls display state/score 1/4 after resume, 2/6 after loss, and 1/2 after a fresh restart. The trace is not a large compiled word taking dictionary space.

Reset before loading another complete variant. The Ace binds references while compiling: load `reset.fth` before `caller.fth`. Redefining `GRESET` after `GTICK` was compiled does not change the reference already in that owner. `build/wrong.fth` uses `mistakes/reset-on-resume.fth` before compiling the caller; `build/repaired.fth` restores the exact normal source in a fresh boot. `build/custom.fth` sets starting health to five instead of three.

These are ASCII keyboard-entry sources, not a tape or saved native dictionary. `DECIMAL` is selected explicitly. Reserve the `G` names below for one mutable context and one owner; the component is not reentrant.

## Helper words and cells

| Word | Stack effect | Meaning |
| --- | --- | --- |
| `GINIT` | `( -- )` | Zero all six helper cells |
| `GSTEP` | `( -- )` | Validate state/events, choose one next state and update pulses |
| `GRESET` | `( -- flag )` | Owner reset policy, normally the `GF` fresh-session pulse |
| `GNEW` | `( -- )` | Initialise helper and owner, retaining the selected starting health |
| `GTICK` | `( held -- )` | Consume one held mask 0..15 and update the owner |
| `GSHOW` | `( -- )` | Clear the screen and print current state and score |

Calls preserve values below their arguments. These words use ordinary colon-word return frames and do not manually transfer data with `>R`/`R>`. Helper `EXIT` paths occur outside any `DO`/`LOOP`; the Ace manual forbids that early-exit idiom inside such a loop. There is no helper allocation, input reader, clock, drawing loop or interrupt takeover.

| Two-byte cell | Ownership and meaning |
| --- | --- |
| `GS` | Current state: Title 0, Play 1, Over 2, Paused 3 |
| `GE` | Caller event mask 0..15; Step preserves it |
| `GC` | One-update state-entry pulse |
| `GF` | One-update fresh-session request |
| `GX` | Zero valid, one invalid state, two invalid events |
| `GN` | Private next-state scratch |

Supply Start 1, Pause 2, Loss 4 and Restart 8 as event bits before `GSTEP`. Title/Start enters fresh Play. Play/Loss enters Over; otherwise Play/Pause enters Paused. Over/Restart enters fresh Play; otherwise Over/Start enters Title. Paused/Pause resumes Play without a fresh reset. Loss wins Pause, and Restart wins Start. Other bits in a valid mask have no effect.

Step clears pulses and error before validating state, then events with unsigned `U<`. Negative numbers and cells such as 256,32768,65535 fail those small domains. Invalid input preserves state, events and private scratch with error one or two. The Ace stores sixteen-bit cells: negative input text and its unsigned alias can represent the same bits. These are not 32-bit integer claims.

The helper selects `GN` while `GS` remains the old state, then commits once. Consume `GC`/`GF` before another Step clears them. Entering a state and starting a fresh session are separate events.

## The owner keeps simulation, health and history

`GP` is previous held input; `GV` is score; `GH` is selected starting health; `GL` is current health; `GR` counts fresh resets. `GNEW` sets history/score/reset count to zero and current health from `GH`. `GINIT` alone leaves those owner cells untouched.

`GTICK` requires a logical held mask 0..15. It computes fresh bits as `held AND (held XOR previous)`, stores the current held mask, advances the old Play state's score modulo 256, calls `GSTEP`, then resets score/health only when `GRESET` requests it. Entering Play does not run Play simulation during that same update. Pause preserves session data and history, so a held press does not become a second fresh event on resume.

The example qualifies logical input. It does not provide a physical keyboard reader or guarantee delivery of overlapping keys. Keep your game's input, drawing and update scheduling outside the helper. `GSHOW` replaces the screen contents and does not restore the previous display; the state words themselves do not clear it.

Change `3 GH !` to `5 GH !` before `GNEW` to customise starting health. `GL @ U.` shows the resulting current health. The helper and transitions are unchanged. Put other fresh-session data in the owner's reset block, preserving it on resume unless discarding progress is an intentional game rule.

## Fault and repair

Normal `GRESET` returns `GF @`. The wrong policy also returns true for `GC @` when the new state is Play. That resets on resume: the native trace reports resumed 0, three resets and finished 2. Working and repaired report resumed 4, two resets and finished 6. All four variants complete; a compile error or missing state observation would not demonstrate this fault.

Repair by resetting the machine and loading the normal policy before compiling the owner. Working and repaired have identical entered-source and compiled dictionary images. Customisation changes data only; its compiled code outside variable cells is identical to normal.

## Measured dictionary and stack costs

On the unexpanded 3 KiB machine, `routines.fth` uses **492 dictionary bytes**, including twelve payload bytes for its six cells and their headers. Normal `reset.fth` adds 19 bytes; `caller.fth` adds 252, including ten payload bytes for five owner cells. Settings allocate no dictionary storage. Total maintained definitions are **763 bytes**. The deliberate wrong reset policy adds eighteen more bytes. Source-file lengths are not dictionary costs.

Qualification separately defines a 19-byte `NUMBER` observation word. With it present, working/custom/repaired dictionaries ended at 16223 and the wrong owner at 16241. RAM top remained 16384. The empty data stack is `HERE+12`; the lower tag occupies one further cell. Headers, interpreter call/CPU stack and temporary input storage consume the remaining space. This does not promise spare memory to a larger game or establish a peak-stack budget.

The separate state diagnostic adds 261 dictionary bytes to the helper, including ten payload bytes for `OA`..`OE`; with `NUMBER` its dictionary ended at 16213. Nine observations while the release-gated diagnostic caller was still waiting measured data-stack/CPU-stack separations of 147..149 bytes. They are actual samples, not an exhaustive minimum. Larger observers or additional game words need new measurements; screen/character RAM is not extra free dictionary storage.

The diagnostic waits for release before accepting a fresh key. Qualification uses Return to finish that wait, so returning to the ROM editor cannot leave a digit in its next command. `UNTIL` consumes its condition; the wait does not drop a caller's lower stack value.

## Native qualification and retained checks

All definitions were entered through the actual keyboard path and executed by the stock 8,192-byte FORTH ROM in Emu198x 0.44.1, without RAM expansion, code injection, entry-pointer changes or `FAST` disabling checks. This qualifies the named ROM/configuration and workload, not original hardware, another FORTH or every possible stack depth.

The independent literal four-by-sixteen table covers all 64 valid state/event pairs, all 252 remaining byte states, seven signed/wide state input spellings, forty invalid event pairs, two both-invalid priority cases and one nonzero-seeded Init: 366 input-syntax cases. Full helper cells and preserved owner payload 65535/32768/3 are observed, along with a native completion counter, lower tag 77 and return to the empty stack. Alias spellings are retained as syntax observations rather than different cell patterns. Four independent owner boots execute the fifteen-sample trace, comparing every helper and owner field, held history and custom health.

The native runner records every newly compiled dictionary byte before and after execution. Only the two-byte payload at each observed variable address may change; code, headers and strings must remain identical. Raw images, hashes, entered-file order and source/tool/ROM identities bind this compiled-load proof. Initial and final payload bytes also agree with the native state observations and independent model.

Use `scripts/verify-ace-game-flow.py` with matching lawful local firmware and the recorded emulator to reproduce the native runs. `scripts/check-ace-game-flow.py` checks retained proof, and `scripts/test_ace_game_flow.py` challenges it without booting the ROM. Tests reject changed cells, upper bits, input order, completion, source/compiled identities, variable addresses, stack bounds, owners and pixels. Every active captured RGBA pixel is compared with native screen and glyph RAM using the locked emulator's observed palette. Licensed firmware and running snapshots remain private.

For Maths for Games, states form a finite set and event bits select a deterministic next state. For Craft, keep that decision separate from simulation, input history and fresh-session ownership. Primary reference: *Jupiter Ace User Manual* (1982), unsigned arithmetic, repetition/control and chapter 24's dictionary/data-stack memory layout.
