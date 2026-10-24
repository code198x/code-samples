# Fractional Position Updates on Amiga

A quarter-pixel step should eventually move the sprite a whole pixel. Keep the fraction between updates and four small steps add up; throw it away each time and the sprite never gets there.

## Bind, initialise and call

Allocate the contiguous private bytes POS_LO, POS_HI, VEL_LO, VEL_HI in that order. Include component.inc once, call fractional_position_init, then set the starting inputs/state. Init clears every named byte, including inputs. Call fractional_position_step for each intended service. Use one owner; independent instances need distinct state and scoped/renamed labels. No helper owns a clock, input reader, display, allocation or interrupt controller.

POS_LO/POS_HI hold an unsigned 8.8 position: the low byte counts 1/256 units and the high byte is the integer part. VEL_LO/VEL_HI hold a signed two’s-complement 8.8 displacement. Step adds the whole two-byte displacement to the whole position, preserving both velocity bytes. Position wraps modulo 65,536 raw units by design; this helper does not clamp a world boundary.

Initialise once, then set both position bytes and both velocity bytes. Call once per simulation update. Use POS_HI as the integer coordinate only where that coordinate range suits the renderer; retain POS_LO in the game state. The normal client adds 0.25 four times to position 100 and reaches exactly 101.

Four persistent/input bytes. A displacement of −0.5 is FF80 in hexadecimal, stored low byte 80 then high byte FF. One raw unit is 1/256 of your chosen world unit; these are units per service call, not per second.

D0–D3/A0–A1/CCR may change; D4–D7/A2–A6 survive. A direct BSR/JSR needs four return-address stack bytes.

## Customisation and errors

The custom client uses 0.5 per update instead of 0.25. Four calls reach 102. The representation and helper code are unchanged.

The wrong client clears POS_LO before every call. The quarter-step is always restarted from a whole unit, so four calls leave position 100.25 instead of 101. Retain the fractional byte between calls; discarding it only for drawing is harmless, discarding it from state is not.

An 8.8 unsigned position covers 0–255.996 units. C64 and Amiga displays can extend beyond 255 horizontal pixels, so do not mistake this for a complete screen-coordinate format. Wider worlds need a wider integer part. [The Amiga Flock lessons](https://code198x.com/systems/commodore-amiga/assembly/flock/unit-14/) already use 16.16 positions; that is a useful wider alternative rather than a reason to squeeze those games into this byte-oriented interface. Clamp or wrap at the game’s actual bounds as a separate policy.

## Cost and evidence

Measured extent: 68 code bytes, 0 immutable data bytes and 4 private state bytes, excluding alignment, return-address/temporary stack, the case table and presentation machinery. One two-byte addition, with no rendering or wait. The 6502 carries from the low byte; Z80 adds a word; 68000 packs the byte binding into a word. Integer movement is smaller when fractional motion is unnecessary, but cannot accumulate these sub-unit steps.

Run make with ASM198X; the Amiga build also accepts BUILD198X. Four variants are maintained: demo, custom, deliberately wrong and exact repair. Observed rows: demo 00 65 40 00 00 00 00 00; custom 00 66 80 00 00 00 00 00; wrong 40 64 40 00 00 00 00 00. These are the first eight state bytes, padded/truncated for display. The packet records all bytes after every call.

Native configuration: A500 OCS PAL with Kickstart 1.3 and an OFS cold-boot disk; Asm198x 0.0.72 and Emu198x 0.44.2, with Build198x 0.2.9 for disk mastering. Each run covers 64 boundary/varied/error table cases plus a separate sequential client and dirty-state init. Checked source/tool/firmware identities, preserved-register sentinels, actual helper/data extents, immutable loaded bytes, independent integer packet, screenshot pixels and exact repair are retained in verification/. Restricted firmware and snapshots are not distributed. This is configuration-specific qualification, not exhaustive input coverage or original-hardware timing.

Refresh with scripts/verify-playtools.py --topic fractional-position --help; check-playtools.py and test_playtools.py validate every explicit target and reject changed evidence. The shared test models are verification inputs, not runtime dependencies. The client’s checked_step wrapper calls the public fractional_position_step entry; emit_state is only a diagnostic observer. In a game, call the public entry directly and consume its documented outputs.

The bootable caller takes over Copper/bitplane/interrupt/DMA resources and explicitly disarms all eight sprites. It does not restore Workbench. These are caller presentation choices, not dependencies of the reusable helper.
