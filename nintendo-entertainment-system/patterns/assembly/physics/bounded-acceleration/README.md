# Bounded Signed Acceleration on NES

Gravity should keep adding speed until the chosen terminal velocity, not turn a fast fall into an upward launch when an integer overflows. This helper adds signed acceleration and clamps the result to an explicit symmetric speed limit.

## Bind, initialise and call

Allocate the contiguous private bytes VEL_LO, VEL_HI, ACC_LO, ACC_HI, LIMIT_LO, LIMIT_HI, CLIPPED, VALID in that order. Include component.inc once, call bounded_acceleration_init, then set the starting inputs/state. Init clears every named byte, including inputs. Call bounded_acceleration_step for each intended service. Use one owner; independent instances need distinct state and scoped/renamed labels. No helper owns a clock, input reader, display, allocation or interrupt controller.

VEL_LO/VEL_HI and ACC_LO/ACC_HI are signed two’s-complement 8.8 words, stored low byte first. LIMIT_LO/LIMIT_HI are a nonnegative raw magnitude from 0 to 32,767. Step clears CLIPPED and VALID, rejects a limit with its high bit set, and otherwise adds velocity and acceleration in a logically wider signed range before clamping to −LIMIT…+LIMIT. VALID becomes 1; CLIPPED becomes 1 only when the wide sum was outside that interval. An invalid limit preserves velocity and leaves both flags zero. Acceleration and limit bytes survive.

Initialise once, set the starting velocity, acceleration and limit, then service before the position update if that is your chosen integrator order. Treat that order as part of the game’s behaviour. The normal four-call client accelerates by −0.5 per call to a limit of 2.0 and finishes at −2.0.

Eight bytes: two for velocity, two for acceleration, two for a magnitude limit, and two replaced status flags. The symmetric limit cannot be 32,768 because the positive signed endpoint cannot represent it. Initial velocity may be anywhere in the signed 16-bit range; a valid call clamps the resulting sum.

A/X/flags may change; Y and decimal mode survive. Clear decimal mode before binary arithmetic; the caller uses CLD. A direct call needs two return-address stack bytes. This helper can also use one temporary stack byte, so allow three bytes for its call, excluding its caller and interrupts.

## Customisation and errors

The custom client lowers the limit from 2.0 to 1.0. Continued acceleration now saturates at −1.0 and sets CLIPPED on the later calls. A zero limit is also a valid request to hold velocity at zero.

The wrong client clears ACC_HI. The intended FF80 displacement (−0.5) becomes 0080 (+0.5), so the object accelerates the wrong way. Supply the signed high byte rather than zero-extending a negative value.

This models acceleration over fixed simulation updates. A variable time step needs explicit scaling, wider intermediates and a rounding policy. Drag, collision response and different upward/downward limits are separate rules. If parameters are prevalidated, an unchecked internal variant may save work, but it is a different contract and is not the qualified implementation here.

## Cost and evidence

Measured extent: 135 code bytes, 0 immutable data bytes and 8 private state bytes, excluding alignment, return-address/temporary stack, the case table and presentation machinery. The 6502 examines signed overflow after the high-byte ADC; the Z80 uses ADC HL,DE because ADD HL,DE does not provide the same signed-overflow result; the 68000 sign-extends words into a long intermediate. Comparisons and clamping take bounded paths. No floating-point unit is used.

Run make with ASM198X; the Amiga build also accepts BUILD198X. Four variants are maintained: demo, custom, deliberately wrong and exact repair. Observed rows: demo 00 FE 80 FF 00 02 00 01; custom 00 FF 80 FF 00 01 01 01; wrong 00 02 80 00 00 02 00 01. These are the first eight state bytes, padded/truncated for display. The packet records all bytes after every call.

Native configuration: NTSC mapper-0 NES cartridge, CHR-ROM diagnostic font, NMI/DMC disabled; Asm198x 0.0.72 and Emu198x 0.44.2. Each run covers 64 boundary/varied/error table cases plus a separate sequential client and dirty-state init. Checked source/tool/firmware identities, preserved-register sentinels, actual helper/data extents, immutable loaded bytes, independent integer packet, screenshot pixels and exact repair are retained in verification/. Restricted firmware and snapshots are not distributed. This is configuration-specific qualification, not exhaustive input coverage or original-hardware timing.

Refresh with scripts/verify-playtools.py --topic bounded-acceleration --help; check-playtools.py and test_playtools.py validate every explicit target and reject changed evidence. The shared test models are verification inputs, not runtime dependencies. The client’s checked_step wrapper calls the public bounded_acceleration_step entry; emit_state is only a diagnostic observer. In a game, call the public entry directly and consume its documented outputs.

The standalone cartridge owns its background/font and test RAM layout. Its bounded packet, preview and completion marker fit below the end of the NES’s 2 KiB internal RAM. The helper itself owns no PPU, DMA or audio registers.
