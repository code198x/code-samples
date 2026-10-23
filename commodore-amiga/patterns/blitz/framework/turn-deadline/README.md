# Give a Blitz BASIC turn an optional deadline

A advances a turn; T enables or disables a deadline; Q leaves. Timing starts disabled. Waiting takes no turn until you enable it. This uses original Blitz BASIC 2.10 / Ted 1.1 in Amiga mode, with its own Intuition window and a short owned vertical-blank clock. The console-based untimed command loop remains a useful separate choice.

## Put the pieces in a project

Run `make` and use Ted's **Edit → Insert from disk** to bring `build/working.asc` into a blank source. The files are maintained ASCII, not tokenised Blitz editor saves. Native `INCLUDE` requires tokenised source: append these ASCII modules in Ted, or save tokenised modules first. Do not tell the compiler to INCLUDE the raw downloads. Compile/run from Ted with Right Amiga + X. Bring each complete variant into a blank listing, rather than appending a second set of labels.

The builder combines caller.bb2, routines.bb2, clock.bb2, input.bb2, monitor.bb2 and the existing command-loop/routines.bb2. PL_advance is reused unchanged. Routines belong after End, preventing fall-through into Return. Blitz variable and label names are case-sensitive: preserve PL_dl_init, PL_dl_now and every related spelling exactly. Commands' displayed capitalisation does not make identifiers case-insensitive.

## Reusable state

Seven explicitly signed-long globals hold the deadline. PL_dl_duration.l and PL_dl_now.l are caller inputs in 0..65535 whole ticks. Zero duration disables. PL_dl_previous.l, PL_dl_left.l, PL_dl_active.l, PL_dl_expired.l and PL_dl_elapsed.l are helper state/results. Active and expired are explicit 0/1 values; do not assume Blitz's comparison true (-1) is the same representation.

Set duration and current sample and Gosub PL_dl_init once. It begins disabled. Gosub PL_dl_start copies duration to remaining and enables nonzero duration, retaining the latest sampled baseline. Sample/poll immediately before starting when the start instant matters. Supply now and Gosub PL_dl_poll every service iteration, including while disabled. Consume PL_dl_expired before another poll/start clears it. Expiry clamps remaining to zero and disables; the caller decides what to do and whether to restart.

The helper owns no screen, window, bank, clock interrupt, input queue or dynamic array/string. It uses normal Gosub/Return calls. Its globals and labels form one mutable context and must not collide with another module. It is not re-entrant. Multiple independent deadlines need separate state.

## Wrap and pacing

The signed-long intermediate can represent now minus previous throughout the stated bounds. If negative, adding 65536 once gives the modular difference: 65530 to 5 is eleven ticks. Poll before a complete 65536-tick cycle passes; two low-word samples cannot reveal a whole missed cycle. An external clock reset requires reinitialisation. Zero is disabled, not a full-cycle duration. An overdue poll produces one event, not every missed turn.

PL_clock_init owns PL_ticks.l and installs a numeric-only SetInt 5 handler. It increments once per delivered vertical blank and wraps at 65536. The checked PAL workload must establish the rate independently; VWait only paces the main loop. It is not used as the elapsed-time counter. Main code reads the counter; only the handler changes it after initialisation. The Amiga's instruction-boundary interrupt handling permits the ordinary long load used by this caller; this is not a generic lock-free API for multiple writers or other CPUs.

**Require exclusive ownership of Blitz's type-5 handler set.** ClrInt 5 removes all Blitz handlers of that type, not just this routine. A larger game must coordinate ownership and teardown. The handler uses no strings, Intuition, file I/O or blitter calls. Ordinary operating-system services stay active; this is not a BLITZ-mode takeover. Clock units depend on the display configuration. Long main-loop work delays observation; restarting from observation time introduces drift. Carrying lateness, longer clocks and fixed-step accumulation are distinct later adaptations.

## Input and turn policy

The caller obtains a Workbench screen handle 0 and opens owned window 0, which selects WindowInput/WindowOutput. PL_poll_key reads and uppercases one delivered Inkey$ character without waiting for Return. Unlike the existing AMOS release-gated reader, this accepts the window's delivered characters, which may include operating-system repeats. It makes no one-action-per-physical-press promise. Another reader cannot independently consume the same queue. Focus and window activation matter.

The caller services time and input, then gives expiry priority. An expiry consumes the current command, including T or Q. Otherwise A calls the existing byte-range rule and restarts only an already enabled deadline. Untimed actions stay untimed. T disables/clears remaining or starts a fresh full duration; it does not preserve a paused remainder. Unknown commands do not take a turn. Count and expiry count wrap within 0..255.

The caller owns its window and its input/output redirection. Normal Q exit removes the owned handler set, restores DefaultInput/DefaultOutput, frees window 0 and frees observer bank 0. It does not close the shared Workbench screen or take ownership of its palette. Do not overlap another screen/window object-number owner. Abnormal interruption or another task's destruction of owned resources needs a separate cleanup policy.

## Optional observation

The caller requests bank 0 with 40 bytes, gets its address from Bank(0), and shows the address and BankSize(0). It never assumes a fixed machine address. The monitor writes seven long fields at offsets 0..24: turn, expiry count, active, remaining, clock, duration and elapsed. A guard $1A2B3C4D is at offset 32 and completion value 239 at offset 36. Zero completion means a partial observation. It is a qualification aid, not an interrupt-safe communication contract.

To omit it, remove InitBank/address/guard and Bank/Size/digit-display lines, Gosub PL_monitor, FreeBank 0 and monitor.bb2. Rename bank ownership consistently if another component uses bank 0. The deadline needs none of these resources.

## Customisation and errors

customise.bb2 changes only duration 200 to 100 ticks. It changes the pressure without changing the helper, its state or assets. Other useful caller policies include untimed safe areas, encounter-specific durations, or a single expiry without automatic restart. Check bounds, clock units and input arbitration when adapting them.

mistakes/reset-baseline.bb2 deliberately stores current time as previous immediately before polling. Elapsed therefore stays zero and remaining never decreases while the actual clock moves. Restore clock.bb2 and load a fresh repaired variant. A second arithmetic-only control changes <=0 to <0; exact expiry then leaves zero remaining active until a later poll. Keep wrong variants out of working builds.

## Costs and verification status

The seven helper long values have 28 bytes of numeric payload; the adapter adds a four-byte clock. Compiler/runtime structures, code, call frames, strings and window resources are additional. ASCII file size does not measure executable size. The observer requests a separate 40-byte bank and writes seven four-byte fields plus two four-byte completion values per poll: 36 explicit data bytes. At fifty polls per second that would be 1800 bytes of explicit diagnostic stores, not a measured bus-bandwidth or frame-time benchmark. The handler performs one increment, one comparison and a conditional reset per vertical blank; this is an operation count, not a cycle measurement.

Original Blitz BASIC 2.10 / Ted 1.1 compiled all four callers independently in released Emu198x 0.44.1, PAL A1200, 2 MiB chip, no fast RAM, the recorded Kickstart 3.1 identity and three floppy drives. The third drive held the source-only Cases fixture from boot. Actual keys exercised untimed idle, accepted input, enable/progression, active restart, expiry without input, disable/idle and normal exit. Native count/active pixels agree with guarded bank snapshots. The clock advances one tick per completed native field in the recorded idle and progression windows.

Two more independent imports execute sixteen synthetic-clock arithmetic cases and the exact-expiry control. All normal cases agree with the independent modular oracle; the completed strict-comparison control fails three exact-expiry cases. These synthetic samples are not a twenty-minute wall-clock rollover test. The retained checker and 26 corruption controls pass. No minimum-memory, original-hardware, NTSC, AmiBlitz/PED or another-compiler claim follows.

Run `python3 scripts/check-blitz-deadline.py` and `python3 -m unittest discover -s scripts -p test_blitz_deadline.py` from the repository root to recheck retained evidence. CI does that, rather than booting licensed software. For fresh native execution, supply the recorded lawful runtime/firmware and tools to `scripts/verify-blitz-deadline.py`: first --prepare --builder /path/to/build198x-adf, then --boot, then --variants working,custom,wrong,repaired,boundaries,wrong-boundary. Each invocation also requires --emulator, --kickstart, --blitz, --blitz-libs and --private paths. Use a fresh private directory for preparation. The fixture manifest refuses source changes between native cases. Boot phases retain the observed editor route, including sufficient source-loading time; normal output, rather than shortcut completion, establishes a compiled caller.

Raw native frames remain in verification/. The two published PNGs remove only proven duplicate framebuffer columns. The checker independently reconstructs those exports and refuses removal of a unique pixel. Private media and running snapshots are not distributed.

Primary reference: Acid Software, *Blitz BASIC 2.1 User Manual*, “Label and Variable Names”, “Locating Variables and Labels in Memory”, SetInt/ClrInt, Inkey$/DefaultInput, window/input/output ownership and memory-bank commands: https://daemonbite.com/files/linked/BB21Manual.pdf.
