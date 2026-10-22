# ColecoVision assembly: one turn per new left-fire press

`make` builds an original 32 KiB cartridge. Start it through the stock BIOS on
a base NTSC ColecoVision. Left fire on controller one advances TURN 00 to 01;
holding it does not take another turn; release and press again for 02. The
counter is hexadecimal. The $55,$AA header skips the BIOS title through its
normal start vector; this is not host CPU or RAM injection.

## Reusable contract

Define T as seven private consecutive writable bytes. Include turn.inc once.
CALL init_turn with A=initial count at startup; it clears all other state and
sets step=1. Store another step at T+5 afterwards if wanted. Pass an active-high
button sample in A to CALL sample_turn, with the same bit convention every call.
Test T+6 afterwards for 1 accepted / 0 held or released. Call service_tick once
per serviced display interval for its optional diagnostic field counter.

| Offset | Meaning |
| --- | --- |
| +0 | Counter, addition modulo 256 |
| +1 | Previous sample |
| +2/+3 | Serviced fields, little-endian modulo 65536 |
| +4 | Current sample |
| +5 | Step, preserved |
| +6 | Accepted flag, replaced every call |

init_turn clobbers AF; sample_turn clobbers AF/B and preserves DE/HL/IX/IY;
service_tick clobbers HL and preserves flags. Other registers are preserved by
these routines. A direct CALL needs two return-address stack bytes. The code is
69 bytes, with seven state bytes and no hardware/heap/interrupt ownership. Do
not concurrently share its state with another foreground or NMI owner.

## Complete caller and hardware ownership

The caller owns RAM $6000–$6006, guards $6007–$6008, stack below $63F0 and the
VDP/controller mode. ColecoVision has 1 KiB mirrored RAM; mirrors are not extra
allocation. The original glyph include is reused from the bitmap-text family:
512 font bytes, plus the caller's VDP setup and display code. The 32 KiB image
includes padding; it is not all useful routine code.

The caller initialises Graphics I and owns all 16 KiB VRAM, the VDP address latch,
registers and status flag. It uses ports $BE/$BF, disables the VDP interrupt
source (R1 IE0 clear) and polls status bit 7. DI by itself does not disable the
VDP's NMI route. Reading status clears its latched field and other status flags,
and resets the command latch. No other reader or renderer may steal the flag
or interleave a two-byte control-port command.

wait_frame discards the old status then waits for a fresh latched field. It
clobbers AF and preserves other registers. It is a polling synchronisation
routine, not a universal VDP scheduler. Keeping IE0 disabled is part of this
caller, not an instruction to use DI as an NMI control. A BIOS/NMI-driven game
needs a different ownership arrangement and should not mix these approaches.

The controller is put into joystick mode by a write to $C0. Read $FC, invert
and mask bit 6 for active-high left fire. This caller does not promise keypad,
right-fire, spinner or other peripheral support. A short tap between samples can
be missed; an event queue or interrupt-owned sampler is a separate technique.

## Customise and diagnose

Replace settings.inc with customise.inc: STEP=2 produces 00, 02, 04 without
changing routine size or state. wrap.inc starts at FE for FE, FF, 00. nonzero.inc
starts at 25 (37 decimal). Changing counter width, display mode, clock policy
or interrupt ownership requires new contracts and checks.

mistakes/held-as-press.inc deliberately ignores previous state. Replace edge.inc
with it to see the counter race while fire is held. Restore edge.inc to fix it.
mistakes/no-wait.inc removes field synchronisation while leaving press detection
intact; service_tick then counts CPU iterations. Restore frame.inc. The native
verifier runs both faults and independent repaired callers, and records service
counts rather than claiming a still image proves timing. The demo draws only
when a turn is accepted; normal idle processing still services fields.

```sh
python3 scripts/verify-xl-coleco-loops.py --only coleco --tools TOOL_RELEASE_DIRECTORY --firmware ROM_ROOT
python3 scripts/check-xl-coleco-loop-records.py
python3 -m unittest discover -s scripts -p test_xl_coleco_loop_records.py -v
```

Eight cold BIOS-started cases retain context observations, real input, custom
step, nonzero, wrap, fault/repair runs and 32 native captures. Tool producer and
firmware hashes are recorded; no BIOS is redistributed. This tests released
Emu198x 0.44.1 and Asm198x 0.0.71 in the named NTSC configuration, not original
hardware, PAL or an entire emulator. The BASIC runtime/compiler/load path on
ColecoVision remains a separate unqualified gap; this assembly entry does not
rule one out.

Primary sources: Coleco *ColecoVision Technical Manual*, system/VDP/controller
wiring; Texas Instruments *TMS9918A/TMS9928A/TMS9929A Video Display Processors
Data Manual* (November 1982), status F, interrupt enable, access protocol and
Graphics I. Cartridge header and hand-controller software details are also
cross-checked against the retained community programmer reference, rather than
claimed to be fully documented by the service manual.
