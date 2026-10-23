# Optional turn deadlines on the Dragon 32: 6809

The screen shows three hexadecimal bytes: turn, expiry count and enabled flag. Press 1 for a turn. Nothing advances while you wait until T enables timing. After 240 firmware ticks (about 4.8 seconds on the named PAL configuration), an automatic turn arrives. T disables or enables with a fresh duration. Q returns to BASIC.

## Build, reserve and load

`make -C dragon-32/patterns/assembly/framework/turn-deadline ASM=/path/to/asm198x` builds the binary. To create the keyboard loader and reproduce the runs, use `python3 scripts/verify-dragon-assembly-deadlines.py --tools /path/to/released/tools --firmware /path/to/roms --assembler /path/to/asm198x`. This needs your own stock Dragon 32 firmware; no ROM is supplied.

For manual entry, make generates `build/load.bas` from the actual emitted bytes; enter it one line at a time after a fresh firmware boot. The verifier also keeps a loader for each variant under build/working and its sibling folders. Its CLEAR reserves RAM above $6FFF; READ/POKE loads the actual assembled bytes at $7000, then CLS:EXEC &H7000 launches them. This proves the keyboard/POKE/EXEC route, not cassette loading. Loader variables I/A and numbered lines are temporary and must not collide with an existing program.

The normal payload occupies $7000–$70F5 (246 bytes). Caller state occupies $7200–$7202: turn, expiries and delivered key. The deadline context owns $7210–$721B (12 bytes). The separate native fixture also borrows $7203 for its loop count and $7300–$7350 for results. Reserve these locations against BASIC, other machine code and graphics buffers. The helper itself accepts X=context, so other projects may allocate that context elsewhere. The caller's fixed labels and loader/reservation must be changed together when relocating it.

## Include and call the helper

Include deadline.inc once. X points to twelve writable bytes. All words are big-endian: duration +0, remaining +2, active +4, one-poll event +5, elapsed +6, previous +8, scratch +10.

- Set duration to 0..65535, pass a clock in D and call deadline_init once. It clears state and records the baseline, starting disabled. Duration is left intact.
- Call deadline_start to copy duration into remaining and enable when nonzero. It clears the event but does not resample time. Poll immediately before starting when the exact baseline matters.
- Pass the next clock in D and call deadline_poll, including while disabled. Test +5 immediately afterwards; the next call clears the old event. Expiry clamps remaining to zero and disables active. Your caller decides what happens next.

X/Y/U/DP are preserved. D and condition flags are clobbered. Each call uses the existing S stack for its two-byte return address; the helper makes no nested calls, changes no interrupt masks and performs no I/O. Each context belongs to one caller and is not re-entrant. Zero duration means off, never a full 65536-tick wait.

Unsigned subtraction wraps modulo 65536. A 65526 → 10 clock change is twenty ticks. Consecutive polls must be less than one complete cycle apart (roughly 21 minutes 51 seconds at 50 Hz). No arithmetic can recover a missed full cycle from these samples. Reinitialise after an external TIMER reset. A late observation produces one event, without catch-up. Restarting at observation time introduces drift.

## Read the actual clock

clock.inc snapshots the stock ROM TIMER word at $0112–$0113 into D. It saves CC, masks IRQ around the two-byte load, then restores CC. It does not reset TIMER, replace vectors or change the PIAs. Its saved CC and return address occupy three stack bytes. Other registers are unchanged. It belongs in the firmware-hosted mainline; this is not a replacement clock for a cartridge that owns its interrupts.

The stock video IRQ supplies the clock. The released default PAL configuration advances about one tick per field; duration 240 is about 4.8 seconds. Keep normal ROM services running. This qualifies the named Dragon 32 firmware under Emu198x 0.44.2, not Dragon 64/other ROMs, every region or original-hardware timing.

The caller asks INCH at $8006 for a delivered character; A=0 means none. It does not wait for a command. It is not a general simultaneous-key scanner or a universal physical press-edge promise. Firmware retains keyboard/IRQ/workspace ownership. The entire entry saves CC, DP, D, X, Y and U on the existing S stack and returns through EXEC's frame; it never resets S. The native return check then asks BASIC to calculate 2+3.

## Keep game policy separate

The helper knows no turns or keys. dispatch.inc makes expiry win over a simultaneously delivered command, including Q/T. Otherwise 1 advances once and restarts only an active timer; an untimed action stays untimed. T discards remaining time when disabling and starts a full duration when enabling. These are choices, not hardware rules. Replace the bounded turn increment with your own world update.

The status drawing writes only $0400–$0401, $0403–$0404 and $0406–$0407 in normal text mode. It uses A/Y/U/flags; X is preserved. Digits are deliberately inverse text cells. The caller clears text once before entry; it neither restores the screen nor supports PMODE graphics. There is no sound driver or frame wait here.

## Customise and diagnose

customise.asm changes only DURATION=240 to 120: about 4.8 seconds becomes 2.4. The payload/state sizes are unchanged. Use unsigned elapsed ticks rather than comparing an absolute future time with a wrapped clock. Maths for Games develops the same ideas: units, ranges and modular subtraction.

mistakes/reset-baseline.asm deliberately selects a broken helper that stores now as previous immediately before subtraction. Elapsed stays zero: the clock advances, the timer stays active, but remaining never decreases and the automatic turn never arrives. The wrong helper adds two bytes. Restore deadline.inc and rebuild; the independent repaired native run produces the normal result. Do not include both versions in a working project.

## Cost and checks

The helper is 66 assembled bytes plus twelve context bytes. The clock adapter is nine bytes. The whole normal caller is 246 bytes plus fifteen owned state bytes, the firmware stack and its existing workspace. These are emitted-byte counts, not cycle or peak-stack measurements. Input, IRQs and rendering affect service latency; clock sampling does not pace the loop. The caller draws continuously for simple feedback. Games can redraw on changes instead.

Six independent keyboard-loaded native runs cover working, half duration, wrong baseline, repair, boundaries and a wrong-equality control. Loaded executable bytes must exactly match assembly before EXEC. The second caller executes twelve synthetic clock pairs plus three policy cases (expiry+action, expiry+toggle, untimed action). Equality/overshoot, zero/one/maximum duration and wrap are checked against an independent host oracle. The wrong equality control completes its guards but fails the oracle. These supplied samples are not an observed long real-time rollover.

Run `python3 scripts/check-dragon-assembly-deadlines.py` and `python3 -m unittest discover -s scripts -p test_dragon_assembly_deadlines.py`. Ten deliberate changes to source identity, cases, native state, loaded bytes, boundaries, captures and firmware must be rejected. Captures show 03 01 01 for the normal automatic turn and 01 00 01 for the baseline fault.

## Primary sources

*Inside the Dragon* (Addison-Wesley, 1983), pp.103–104 (INCH $8006 and no-character case), pp.196–197 (video IRQ/system clock), Appendix 2 ($0112–$0113 TIMER), Appendix 3 (ROM entry tables). *Dragon 32 Programmer’s Reference Guide* (Sunshine, 1983), p.34 (TIMER range): https://archive.worldofdragon.org/browse/downloads/Books/Dragon-32-Programmers-Reference-Guide.pdf . The adapter/helper are this implementation, not code claimed to have been printed in those books.
