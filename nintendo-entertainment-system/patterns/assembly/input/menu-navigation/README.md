# Wrap and Skip Menu Options on NES

A menu should wrap cleanly at either end and skip options the player cannot choose. Keep the selection rule separate from drawing and key-repeat timing, and the same menu can work with a keyboard, joystick or controller.

## Bind, initialise and call

Allocate the contiguous private bytes SELECTED, OPTION_COUNT, ENABLED, DELTA, MOVED, VALID in that order. Include component.inc once, call menu_navigation_init, then set the starting inputs/state. Init clears every named byte, including inputs. Call menu_navigation_step for each intended service. Use one owner; independent instances need distinct state and scoped/renamed labels. No helper owns a clock, input reader, display, allocation or interrupt controller.

OPTION_COUNT is 1–8 and SELECTED must be a valid index below it. ENABLED is a bit mask: bit zero enables option zero, and bits above the count are ignored. DELTA is 1 forward, 255 backward or zero for no movement. Invalid count/index/delta preserves selection and clears VALID/MOVED. A valid call sets VALID and searches at most OPTION_COUNT candidates, wrapping and choosing the first enabled option. With none enabled it leaves the selection unchanged; MOVED reports an actual selection change.

Initialise once, set the option count, mask and starting selection, then offer one navigation action at a time. Use the existing input-repeat routine to decide when held input should produce another action. Resolve opposed directions before supplying DELTA. A disabled starting selection can move to an enabled candidate; the routine does not draw or activate the option.

Six bytes, including the caller’s direction input and the replaced MOVED/VALID flags. A no-movement DELTA does not repair a disabled selected option. A valid count/layout is separate from the question of whether an option is currently enabled.

A/X/flags may change; Y and decimal mode survive. Clear decimal mode before binary arithmetic; the caller uses CLD. A direct call needs two return-address stack bytes. This helper can also use one temporary stack byte, so allow three bytes for its call, excluding its caller and interrupts.

## Customisation and errors

The normal example starts at option two in a three-option menu with only options zero and two enabled, then wraps forward to zero. The custom caller enables all three and requests a backward move, selecting option one.

The wrong client simply adds DELTA to SELECTED. Moving forward from the last index two produces invalid index three, because byte wrap is not menu wrap. Bound the index by the option count and search the enabled candidates.

More than eight options need a larger availability structure and wider or bounded indices. Two-dimensional layouts need an explicit neighbour/navigation policy. Selection and activation should remain distinct, especially when a key that opened a menu is still held.

## Cost and evidence

Measured extent: 109 code bytes, 8 immutable data bytes and 6 private state bytes, excluding alignment, return-address/temporary stack, the case table and presentation machinery. At most eight candidate tests. The 6502/Z80 examples use an eight-byte mask table; 68000 tests a register bit directly and needs no table. Keeping a count bounds the search even when every option is disabled.

Run make with ASM198X; the Amiga build also accepts BUILD198X. Four variants are maintained: demo, custom, deliberately wrong and exact repair. Observed rows: demo 00 03 05 01 01 01 00 00; custom 01 03 07 FF 01 01 00 00; wrong 03 03 05 01 01 01 00 00. These are the first eight state bytes, padded/truncated for display. The packet records all bytes after every call.

Native configuration: NTSC mapper-0 NES cartridge, CHR-ROM diagnostic font, NMI/DMC disabled; Asm198x 0.0.72 and Emu198x 0.44.2. Each run covers 64 boundary/varied/error table cases plus a separate sequential client and dirty-state init. Checked source/tool/firmware identities, preserved-register sentinels, actual helper/data extents, immutable loaded bytes, independent integer packet, screenshot pixels and exact repair are retained in verification/. Restricted firmware and snapshots are not distributed. This is configuration-specific qualification, not exhaustive input coverage or original-hardware timing.

Refresh with scripts/verify-playtools.py --topic menu-navigation --help; check-playtools.py and test_playtools.py validate every explicit target and reject changed evidence. The shared test models are verification inputs, not runtime dependencies. The client’s checked_step wrapper calls the public menu_navigation_step entry; emit_state is only a diagnostic observer. In a game, call the public entry directly and consume its documented outputs.

The standalone cartridge owns its background/font and test RAM layout. Its bounded packet, preview and completion marker fit below the end of the NES’s 2 KiB internal RAM. The helper itself owns no PPU, DMA or audio registers.
