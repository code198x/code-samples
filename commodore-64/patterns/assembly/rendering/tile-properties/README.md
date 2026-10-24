# Look Up Tile Properties on C64

The picture number in a map does not automatically tell you whether a tile is solid, harmful or climbable. A small property table lets artwork and game behaviour change independently, with a bounds check before looking anything up.

## Bind, initialise and call

Allocate the contiguous private bytes ATTRS, MATCH, VALID, TILE_ID, MASK in that order. Include component.inc once, call tile_properties_init, then set the starting inputs/state. Init clears every named byte, including inputs. Call tile_properties_step for each intended service. Use one owner; independent instances need distinct state and scoped/renamed labels. No helper owns a clock, input reader, display, allocation or interrupt controller.

TILE_ID selects one entry of the caller-owned property_table, whose qualified size is 16. MASK selects properties of interest. Step replaces ATTRS/MATCH/VALID: an in-range ID returns its attribute byte and VALID 1; MATCH is 1 when any selected bit is present. MASK zero matches nothing. An invalid ID returns all three outputs zero without reading outside the table. Inputs survive.

Query the map for a tile ID, then offer that ID and the property mask. Check VALID if a missing ID should be treated as a content error rather than empty space. The sample assigns independent bit values 1, 2, 4 and 8; your game gives those bits their meanings.

Five bytes of state plus a separate immutable sixteen-byte property table. A valid tile with attribute zero differs from an invalid tile because VALID is separate. This is an any-bit test; the quest-flags helper’s all-bits question has a different meaning.

A/X/flags may change; Y and decimal mode survive. Clear decimal mode before binary arithmetic; the caller uses CLD. A direct call needs two return-address stack bytes.

## Customisation and errors

The normal client asks about mask 1; the custom caller asks about mask 8. Tile ID six maps to attribute eight, so the latter matches and the former does not. No tile image or map layout has to change.

The wrong client treats the numeric tile ID as the attribute byte. Tile six then appears to carry bits two and four instead of its authored property bit eight. Look up the property data rather than encoding behaviour accidentally into artwork numbering.

A larger catalogue needs an updated count, storage and index width as appropriate. Sparse IDs may need a different lookup structure. Animated frames can share the same properties, or the animation owner can choose when behaviour changes; neither should happen accidentally because the image index changed.

## Cost and evidence

Measured extent: 41 code bytes, 16 immutable data bytes and 5 private state bytes, excluding alignment, return-address/temporary stack, the case table and presentation machinery. One bounds check, one byte lookup and a mask test. The immutable table costs sixteen bytes; no per-tile properties need to be copied into every map cell. The table transfer to an actual display is unrelated work.

Run make with ASM198X; the Amiga build also accepts BUILD198X. Four variants are maintained: demo, custom, deliberately wrong and exact repair. Observed rows: demo 08 00 01 06 01 00 00 00; custom 08 01 01 06 08 00 00 00; wrong 06 00 01 06 01 00 00 00. These are the first eight state bytes, padded/truncated for display. The packet records all bytes after every call.

Native configuration: PAL C64 with stock BASIC/KERNAL PRG startup and RUN; Asm198x 0.0.72 and Emu198x 0.44.2. Each run covers 64 boundary/varied/error table cases plus a separate sequential client and dirty-state init. Checked source/tool/firmware identities, preserved-register sentinels, actual helper/data extents, immutable loaded bytes, independent integer packet, screenshot pixels and exact repair are retained in verification/. Restricted firmware and snapshots are not distributed. This is configuration-specific qualification, not exhaustive input coverage or original-hardware timing.

Refresh with scripts/verify-playtools.py --topic tile-properties --help; check-playtools.py and test_playtools.py validate every explicit target and reject changed evidence. The shared test models are verification inputs, not runtime dependencies. The client’s checked_step wrapper calls the public tile_properties_step entry; emit_state is only a diagnostic observer. In a game, call the public entry directly and consume its documented outputs.

The standalone PRG owns screen/font/colour RAM, disables interrupt sources and does not restore BASIC. Its private scratch uses $70–$76 and the state binding starts at $80; its diagnostic output starts at $C000.
