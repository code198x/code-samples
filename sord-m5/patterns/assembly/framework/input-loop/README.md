# Turns alongside display service: sord-m5

Build this original caller, start it through the route below, and press Space. The background changes once. Hold the control and it stays there; release and press again to restore the first colour. Display servicing continues while the game waits for input.

## Build and start

```sh
make
```

Output: `build/demo.bin`. Tested configuration: **NTSC Sord M5, recorded monitor, cartridge**. [demo.asm](demo.asm) is the complete caller; [Makefile](Makefile) shows the assembler dialect and packaging. Use Asm198x, plus Python 3 for the MTX/Einstein packaging helper. Supply your own legally obtained firmware where the machine requires it.

The cartridge header supplies start and initialisation routine addresses. Space is active-high Y0 port $30 bit 6. The caller owns VDP status/control port $11 and backdrop R7; do not mix its status reads with BIOS VDP/IRQ handling. This does not qualify a BASIC cartridge or other peripherals.

## Fit the pieces into your program

Initialise the caller once, then keep the outer main loop and display wait running. Its four state bytes are: turn count, previous button sample, and a little-endian 16-bit display-service counter. The turn count changes only on a newly pressed control; the service count advances even while the player does nothing.

Replace the accepted-press increment with your game update, and replace the parity colour with your drawing. Keep the previous-sample update outside the accepted-action block. Otherwise a held key can become a fresh press every pass. Copy wait_frame with its caller contract: it clobbers accumulator/flags and owns the status read; the input block also uses the temporary registers shown in the source. It is not safe to paste these direct-device blocks alongside a firmware ISR that also owns the same registers or control-port latch.

Memory owned: **$7000-$7003**, plus the stack and display structures defined in the source. Interrupts are disabled for the takeover. There is no timeout or catch-up policy here: the service count is separate from game progression, and any future deadline must define what it counts, how it wraps and what an expired turn does.

## Verify

From the repository root:

```sh
python3 scripts/verify-hardware-input-loops.py --native /path/to/native/binaries --only sord-m5
```

[The retained record](verification/results.json) pins the startup route, exact firmware/executable/source hashes and configuration. It checks approximately one service tick per native frame, idle stability, two presses, a held control and visible colour changes. Removing the wait and removing edge detection must fail the corresponding positive guards. This qualifies this caller/configuration; it is not a whole-emulator or physical-hardware certification.
