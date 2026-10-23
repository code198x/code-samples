# Optional turn deadlines in AMOS Professional

A advances a turn. With timing disabled, the world waits. T enables a deadline; keep your hands off the keyboard and the next turn arrives automatically. T disables timing again, and Q leaves. A held A counts once until release. The counter and expiry count wrap within 0..255.

This entry is independently qualified in **AMOS Professional 2.00**, interpreted on a PAL A1200 with 2 MiB chip RAM and no fast RAM, using released Emu198x 0.44.1. It is not qualification of another AMOS version, another compiler, NTSC or a minimum-memory Amiga.

## Build and load

Run `make` here. Import `build/working.asc` into a **blank project** using Merge ASCII; F2 checks syntax and F1 runs. These are ASCII source files, not native tokenised `.AMOS` saves. Use `build/custom.asc` for half the duration, `build/wrong.asc` for the deliberate baseline fault and `build/repaired.asc` for a separate repair. Do not merge complete variants on top of old labels.

`build.py` combines caller.amos, routines.amos, clock.amos, input.amos and monitor.amos, followed by the existing `../command-loop/routines.amos`. The latter supplies PL_ADVANCE unchanged. Its old PL_READ_FRESH remains available but is not called here: that blocking reader belongs to the untimed example. Append all routines **after End**, so execution cannot fall into a Return without a Gosub.

AMOS rejects IF...THEN inside a structured test. The new modules use explicit If/Else/End If blocks. Preserve that structure when adapting the sample.

## Reusable helper

Include routines.amos and reserve its PL_DL_ globals and labels. These are ordinary signed 32-bit integer variables; do not add floating-point suffixes.

| Input/state | Contract |
| --- | --- |
| PL_DL_DURATION | Caller duration, whole ticks 0..65535; zero disables |
| PL_DL_NOW | Caller current sample, whole ticks 0..65535 |
| PL_DL_PREVIOUS | Helper-owned previous sample |
| PL_DL_LEFT | Helper-owned remaining ticks, saturated at zero |
| PL_DL_ACTIVE | Helper-owned 0/1 active flag |
| PL_DL_EXPIRED | Helper-owned 0/1 expiry event for the latest poll |
| PL_DL_ELAPSED | Helper-owned elapsed ticks from that poll |

Set duration and current sample, then Gosub PL_DL_INIT once. It starts disabled. Gosub PL_DL_START to copy duration into remaining and enable a nonzero duration. Starting preserves the latest sampled baseline; poll immediately before starting when that instant matters.

Each service iteration, including while disabled, supply PL_DL_NOW and Gosub PL_DL_POLL. Consume PL_DL_EXPIRED immediately: it is cleared by the next poll or start. On expiry the helper clamps remaining to zero and disables itself. It does not advance a turn or restart automatically. Writing PL_DL_ACTIVE=0 disables timing; the demo also clears remaining. Re-enabling the demo starts a fresh duration, not a preserved pause.

Subtraction is modulo 65536. A move from 65530 to 5 is eleven ticks. The intermediate signed difference fits in a 32-bit AMOS integer; if negative, adding 65536 once corrects it. Elapsed and remaining values are positive within the stated range, so ordinary comparison works here. A single 16-bit FORTH cell needs an unsigned comparison instead.

Poll before a full cycle passes. A whole missed cycle is indistinguishable from less elapsed time. Zero duration does not mean 65536 ticks. An external clock reset requires reinitialisation, not wrap correction. An overdue poll produces one event rather than replaying every missed turn.

The helper owns no bank, screen, keyboard buffer, hardware timer or interrupt vector. It uses globals and normal Gosub/Return frames, allocates no arrays or strings, and performs bounded work rather than looping once per elapsed tick. Rename consistently before including another context. It is not re-entrant.

## Native clock and input

clock.amos reads the low 16 bits of AMOS Timer and polls the helper. The checked PAL runtime advances this clock once per video field, nominally fifty ticks per second. Duration 200 is roughly four seconds; the adapter wraps after 65536 ticks, roughly 21 minutes 51 seconds. It does not expose the full Timer range or promise civil-time accuracy. It never resets the shared Timer value. Coordinate any other code that assigns Timer.

The caller's Wait Vbl controls service pacing. Timer still measures elapsed ticks between samples; it is not merely incremented once per game iteration. Long drawing or other work delays when the program notices expiry. Restarting from observation time introduces drift. A fixed-step accumulator, carrying lateness, multiple contexts or a longer clock are useful adaptations when the game's policy needs them, not hidden guarantees.

PL_POLL_KEY is a nonblocking version of the established release-gated reader. Initialise PL_LASTSCAN=-1 once. It returns PL_KEY$ and retains the accepted scan code. While that key is still held, it returns an empty string immediately. On release it clears queued repeat/typeahead and allows a new delivered character. Inkey$ supplies the character; Key State supplies the release test. Overlapping keys and presses between samples are not promised as queued actions. This module owns that buffer-clearing policy; another reader cannot independently consume the same queue.

The caller polls time and input, then handles expiry first. Expiry wins a simultaneous command, including T or Q, and discards it. Otherwise A calls the existing bounded rule and restarts only an already enabled deadline. An untimed action stays untimed. Unknown commands inherit PL_ADVANCE's rejection rule. Timing is optional, not an inherent requirement of a turn-based game.

## Presentation and optional diagnostics

The caller clears the current screen, changes palette entries 0/1, paper/pen and pointer visibility. Adapt that setup if another part of your game owns the screen. Normal Q exit restores pointer visibility and erases the observer bank, but does not restore the previous picture or palette. Abnormal interruption is outside that normal-exit path.

The complete diagnostic caller reserves **work bank 1, 32 bytes**. PL_MAILBOX obtains its address through Start(1); it is never a fixed machine address. The verifier reads the address from the native screen, then compares guarded bank snapshots with the actual counter glyphs. Do not overlap another bank 1 owner. If you renumber it, change Reserve, Start and Erase together.

monitor.amos writes seven 16-bit big-endian fields: turn, expiry count, active, remaining, sampled clock, duration and elapsed. A guard word is at offset 28 and completion marker 239 at offset 31; marker zero means a partial write. The observer is for qualification, not a second concurrent task's synchronisation API.

Remove the reserve/address/guard/Bank and digit-display lines, Gosub PL_MONITOR, Erase 1 and monitor.amos to omit it. The helper itself needs none of them. The displayed digit row is a capture-font fixture, not part of a game interface. PL_COUNT, PL_STEP, PL_EX, PL_DIRTY, PL_LASTSCAN, PL_KEY$ and the mailbox pointer belong to the caller/input/rule modules.

## Customise and diagnose

customise.amos changes only PL_DL_DURATION=200 to 100. This halves the wait without new assets, helper statements or state fields. The native customisation expires after the shorter clock interval with the same input policy. Choose units deliberately; a count of ticks is not automatically a count of seconds or game turns.

The deliberately broken mistakes/reset-baseline.amos stores now as previous just before polling. Elapsed is consequently always zero. The native clock advances, but remaining stays at 200, active stays 1 and no automatic turn arrives. Generate the wrong variant to reproduce it. Restore clock.amos and import a fresh repaired program to remove that extra assignment. Keep the wrong service separate from normal builds.

A second test-only control replaces the helper's <=0 expiry test with <0. The arithmetic caller completes, but exact expiry incorrectly stays active with zero remaining. An independent oracle rejects three exact-boundary results. Restoring <=0 repairs it. Neither a requester nor a compile failure counts as this intended fault.

## Costs

The seven helper integer values have **28 bytes of numeric payload**, based on AMOS's four-byte integer representation. Names, labels, interpreter tables and return frames add runtime overhead; this is not a total heap or executable-size claim. Maintained ASCII file sizes are reproducible file lengths, not tokenised program or compiled instruction sizes. Those native code/storage overheads have not been isolated here.

The caller requests a separate 32-byte observer bank. The arithmetic fixture independently reports Length(1)=160 for its 160-byte results bank. Bank headers, resident AMOS/editor/runtime, screen and string storage are additional. No minimum Amiga RAM requirement is inferred from the small helper payload.

The observer performs seven two-byte Doke writes plus two one-byte marker writes per poll: sixteen data bytes, separate from its initial guard. At fifty polls per second that is 800 bytes of explicit diagnostic stores; it is an operation/transfer count, not a bus-bandwidth or frame-time benchmark. Removing it saves those stores. Normal PAL idle traces sample one clock tick per field; display changes and other work still need their own budget.

## Native qualification

Four independent imports from the same cold-mounted, verified empty-editor checkpoint cover working, shorter duration, baseline fault and repaired service. Actual keys drive untimed idle, a 100-field held action, timer enable/progression, active restart, no-input expiry, disable/idle and exit. Each observation has its own native image; files are not overwritten by later states. Counter glyphs and guarded bank bytes are independently checked.

boundaries.amos is a second caller of the same helper, using sixteen synthetic sample/duration cases. It reports completion and the bank allocation, then holds its results for inspection. A separately imported exact-boundary fault completes the same cases and is rejected. These are interpreter arithmetic checks, not a twenty-minute wall-clock rollover or original-hardware test.

Supply matching lawful runtime/firmware and the recorded released tools. `scripts/verify-amos-deadline.py --prepare --builder /path/to/build198x-adf --emulator /path/to/emu198x-amiga --kickstart /path/to/rom --amos /path/to/system.adf --private /fresh/private/run` builds source-only fixture media. Then use the same arguments with --boot, followed by --variants working,custom,wrong,repaired,boundaries,wrong-boundary. Build198x ADF 0.2.13 and Emu198x 0.44.1 identities are retained. Private media/snapshots are not distributed. The public checker/tests validate retained evidence; they do not boot AMOS in CI.

## Primary references

*AMOS Professional User Guide* (François Lionet, Stephen Hill and Mel Croucher, 1992), §5.3 TIMER, §5.4 structured control, §5.9 memory banks, §10.1 keyboard input, §14.A memory access and integer representation, and the error reference “No THEN in a structured test”. Consult the named runtime's reference when changing numeric types, input policy or ownership.
