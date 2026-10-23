# Optional timed turns on PET in BASIC

Space takes a turn. Waiting initially does nothing. T enables a 240-tick deadline; expiry takes one turn without input and starts the next deadline. Space restarts an active deadline after its own turn. T disables and discards remaining time; re-enabling starts fresh. Q ends this caller.

## Load and reuse

Run `make -C commodore-pet/patterns/basic/framework/turn-deadline`, enter `build/demo.bas` as one numbered program and RUN. `build/customise.bas` is the maintained 120-tick caller; `build/wrong.bas` is explicitly broken. Use NEW/reset between complete variants. This is qualified on **32 KiB 40-column upgrade-ROM PET, default PAL timing**, with the recorded stock firmware hashes. BASIC is typed from boot, not installed through debugger writes.

These wrappers reuse the maintained C64 BASIC `routines.bas`, `clock.bas`, command-rule `../command-loop/routines.bas` and the observer portion of `monitor.bas`; the PET owns a compact presentation shared with VIC-20. The Makefile lists those include paths. It concatenates the caller, command rule, deadline helper, clock adapter, presentation and observer; numeric BASIC lines may be entered in that order because the interpreter orders them by number. Each line number is unique. Keep the whole checkout when building.

Copy the helper's lines 3000–3250 into free numbers, renumbering every caller consistently. It does not require a display, keyboard reader, frame wait or fixed RAM mailbox. The complete caller makes those separate choices visible.

## Callable contract

All variables are global floating-point BASIC values; only the first two name characters distinguish them. Rename the complete interface consistently if a project already uses these names. DUAL and DU would collide. Initialise once, not on every poll.

| Entry | Inputs | Result |
| --- | --- | --- |
| GOSUB 3000 | DC=current clock | DP baseline; DR=0, DA=0, DX=0, DE=0 |
| GOSUB 3100 | DU=duration | DR=DU; DA=1 for nonzero duration, DX=0 |
| GOSUB 3200 | DC=current clock | DE elapsed, DP updated, DR/DA updated, DX expiry event |
| GOSUB 5000 | Firmware TI | Read DC and poll the helper |

Use integer-valued clock/duration data, duration 0 through 5,183,999; zero disables. The helper performs no range validation. Its seven numeric globals are DU, DC, DP, DR, DA, DX and DE. The native variable table confirms seven-byte variable entries: **49 bytes** for those entries, including their names and five-byte values. The demonstration uses additional caller/observer state. No hidden fixed-address storage belongs to the helper.

Poll while enabled or disabled, and consume DX before the next poll clears it. Expiry clamps remaining time to zero and disables the countdown; the caller decides what expiry means. Start uses the latest sampled baseline: read/poll immediately before starting when that instant matters. The helper uses the BASIC GOSUB return stack and must return before the next call.

TI wraps at **5,184,000 ticks**. Poll less than one complete clock cycle apart; a negative DC-DP gets one modulus added. An arbitrary TI$ reset cannot be distinguished from rollover, so reinitialise/restart after an intentional external clock change. This implementation retains the full firmware modulus, unlike the separate 16-bit assembly adapter. The released default PET counts 30 ticks in 30 roughly 50 Hz fields, so 240 observed ticks are about 4.8 seconds in this configuration. The manual’s nominal sixtieth-second wording is not the measured conversion here.

## Input, policy and ownership

GET K$ is nonblocking delivered-character input. Buffered characters and firmware key repeat remain possible; it is not a physical press-edge promise. The caller polls time, reads one character, then gives expiry priority over that character, including Q or T. It spends one automatic turn and starts one new deadline, without a catch-up burst. Otherwise Q ends, T toggles, and Space takes a turn. Untimed actions stay untimed. Disabling discards the remainder; this is not a preserved-pause implementation.

The helper does not reset TI$ or install interrupts. Keep normal firmware clock/input service running. A blocking INPUT, lengthy computation or slow rendering can delay noticing expiry even when TI keeps advancing. Do not call the polling routine only when a character arrives.

The optional observer borrows **$033A (826), the inactive second-cassette buffer**: twenty bytes in normal callers, ninety-nine in the arithmetic caller. Do not perform tape I/O, load/save through that buffer or put another routine there while observing. It sits outside this program's BASIC heap, so it does not hide a top-of-memory reservation. To omit it in a game, remove its guard initialisation, GOSUB 9000 and lines 9000–9120, retaining the loop's GOTO. Re-measure the resulting program rather than treating this capture build as a speed benchmark.

## Make it your own

`customise.bas` changes DU=240 to DU=120 and otherwise preserves the caller. Its own native run expires after half as many ticks; clock rate and helper storage stay the same. Change input/presentation in their own pieces. A physical input sampler, preserved pauses, multiple deadlines or catch-up rules require separate ownership and qualification.

## A mistake with a visible symptom

The maintained deliberately broken `commodore-64/patterns/basic/framework/turn-deadline/mistakes/reset-baseline.bas` sets DP=DC immediately before polling. The clock advances, but DE remains zero and DR never decreases. In the observed wrong caller the display stays at TURN 1, E 0, T 1 after the normal deadline would have passed. Use the normal `clock.bas` as the repair; the repaired complete source is identical to working and reaches TURN 3, E 1, T 1 after two Space turns and an automatic turn.

Boundary and wrong-boundary callers supply guest DATA values to the same helper. They cover disabled/one/max duration, exact and overdue expiry, low-word crossing without false rollover, and the real clock modulus. The changed > to >= completes but fails the independent oracle at equality. These synthetic samples establish arithmetic, not a wall-clock wait across a whole clock cycle.

## Measured costs and evidence

The working tokenised program occupies **1,016 bytes**, including **191 helper bytes** and **274 observer bytes**. Its final observed variable table is **133 bytes** (nineteen entries), with **four string bytes** in that snapshot. The BASIC free gap is **30,590 bytes** after those allocations on the named configuration. These are inspected native pointers and line extents, not peak heap/stack measurements or a claim about the minimum possible implementation. The 120-tick edit does not change tokenised size. The deliberately wrong adapter adds six tokenised bytes.

The instrumented idle caller commonly samples intervals around 17–18 service ticks. That includes BASIC input, serialization and observer work; it is not the cost of the helper alone. Removing instrumentation or using the separately qualified assembly routine may be useful, but requires a new workload measurement. Rendering is only requested on changes, while the optional observer runs every service iteration.

Six independent released **Emu198x 0.44.2** boots per machine retain typed-source hashes, actual emulator/server and firmware identities, coherent guarded mailboxes, complete tokenised line inventories, native variable tables and captures. The retained checker independently decodes the visible digits and rejects 28 falsified records across the two routes. Run `python3 scripts/check-pet-vic-basic-deadlines.py` and `python3 -m unittest discover -s scripts -p test_pet_vic_basic_deadlines.py -v`.

Primary contracts: Commodore's [PET memory map](https://www.manualslib.com/manual/1024284/Commodore-Pet.html?page=348), [cassette-buffer reservation guidance](https://www.manualslib.com/manual/1024284/Commodore-Pet.html?page=343), and the VIC-20 Programmer's Reference Guide memory map and TI/GET descriptions. No original-hardware, other-ROM/region, peak-RAM or whole-game performance claim is made. Source and runtime evidence are specific to this route; another machine's BASIC syntax is not its qualification.
