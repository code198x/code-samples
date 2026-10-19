# SG-1000: turns with an optional deadline

Press button 1: the full-screen colour changes once. Hold it: no repeat. Press button 2 to enable a 120-tick deadline; turns can now end while you wait. Press button 2 again to return to untimed play. Reset to leave. There is no game rule beyond counting turns.

## Build and start

From the code-samples root:

```sh
make -C sega-sg-1000/patterns/assembly/framework/turn-deadline
emu198x-sega-sg-1000 --cart sega-sg-1000/patterns/assembly/framework/turn-deadline/build/demo.sg
```

Uses installed Asm198x and Python 3; no third-party runtime libraries or firmware. Tested configuration: NTSC SG-1000. Other variants and original hardware remain unqualified.

## Include, initialise and call

`demo.asm` is the complete cartridge, reset vector, stack, input/colour setup and caller. `frame.inc` owns the VDP status latch. The shared `cross-platform/assembly/framework/turn-deadline/turn.inc` owns turn/countdown operations. Keep their relative include paths or adjust them explicitly when copying. The Makefile pads the cartridge and finishes its Sega header/checksum.

Reserve $C000–$C007 and zero all eight bytes before use. Set the stack to unused RAM (the caller uses $C3F0). `commit_turn` increments the 16-bit turn count and sets `remaining=120`. `tick_deadline` increments the 16-bit accepted-tick count, decrements `remaining`, and calls `commit_turn` on expiry; call it only while timed, with a nonzero countdown. Both clobber AF and HL; neither draws, reads input or waits. Counts wrap; the expiry byte wraps after 256 expiries. Relocate the equates if your project already owns this RAM.

Read the active-low action bits at $DC, invert them and derive newly pressed bits from the previous sample. Button 1 calls `commit_turn`. Button 2 toggles timed mode and restarts the countdown. Untimed iterations do not call `wait_frame` or `tick_deadline`. Timed iterations accept a fresh VDP announcement before advancing time. Enabling timed mode does not manufacture an initial tick.

If action and expiry coincide in a sampled iteration, action goes first and restarts the deadline. The tick then consumes the first unit of that new deadline. This is an explicit policy, not a claim to timestamp physical button arrival. Input between samples may be missed.

## Machine ownership and limits

The SG-1000 uses its fixed TMS9918-family palette rather than Mode 4 CRAM. This caller selects colours 2 and 3. Its eight state bytes and stack fit inside the 1 KiB RAM window; the later consoles’ larger RAM is not assumed.

The cartridge keeps maskable interrupts disabled and owns all VDP status/control access. `wait_frame` clobbers AF, clears a pending status and polls bit 7 for a new announcement. Status reads also reset the command latch; never let another status reader or interrupt split a register write. Missed announcements collapse into one flag. A 120-tick deadline is not a universal two seconds: region, work duration and missed announcements matter. A true elapsed-time clock needs another policy.

Rendering is deliberately disabled; output uses the backdrop colour. This does not qualify tile/sprite uploads or their timing. The caller can busy-poll untimed input because no music, background task or power policy needs servicing. Adapt that choice when adding those features. The $0066 handler returns from Pause NMI without implementing a pause menu; Game Gear Start is not handled.

## Verify

```sh
python3 scripts/verify-sega-turns.py --native /path/to/native/binaries
```

The recipe checks idle state, distinct/held presses, countdown independence, no early expiry, expiry without input, deadline restart and return to untimed play. PNG raster streams must change after a turn and return after even turns. Negative ROMs remove either the wait or press-edge detection; the corresponding rate/held-action check must reject them. Positive cases use no host memory writes. Retained results identify source and emulator hashes. These are configuration-specific observations, not whole-emulator certification.

## Hardware sources

Texas Instruments’ [TMS9918A/TMS9928A/TMS9929A data manual](https://bitsavers.org/components/ti/TMS9900/TMS9918A_TMS9928A_TMS9929A_Video_Display_Processors_Data_Manual_Nov82.pdf), VDP Registers and CPU Interface; the [SG-1000 memory map](https://www.smspower.org/Development/MemoryMap) identifies the smaller RAM window.
