# Manhattan Distance on NES

On a four-way grid, distance is the horizontal gap plus the vertical gap. That makes a useful cheap measure for a guard choosing a nearby target, or a turn-based game showing a movement budget. Two byte coordinates can produce a result larger than a byte.

## Reuse

Bind these contiguous private bytes in order: AX, AY, BX, BY, DIST_LO, DIST_HI. Include component.inc once; call manhattan_distance_init, set the inputs and call manhattan_distance_step. The init entry clears every byte, including caller-input fields. Set starting values after init. Both entry points use one fixed binding; use distinct names/scopes and state blocks for independent instances. Do not include conflicting global field labels unchanged.

AX/AY and BX/BY are unsigned coordinates from 0–255. Step preserves all four inputs and writes DIST_LO/DIST_HI as a little-endian result **|AX − BX| + |AY − BY|**, from 0–510. A wider result is needed even though each coordinate fits in one byte.

Four input bytes and a two-byte output. There is no map, actor state or movement inside this helper. Byte order is explicit on every target, including 68000.

A/X/flags may change; Y and decimal mode survive. **Clear decimal mode before binary arithmetic**; the standalone caller uses CLD. A direct call pushes a two-byte return address.

Fill both coordinate pairs and call step when the decision needs the distance. Compare both result bytes when selecting a threshold or nearest target. Ties need a separate stable rule. Reusing one scratch block for successive independent queries is safe under a single owner.

## Limits and alternatives

This is the shortest distance on an unobstructed four-way grid. Walls can make the actual route longer or unreachable. Eight-way movement may call for Chebyshev or octile distance; Euclidean movement needs a different metric. Wider or signed coordinates need wider differences before taking absolute values.

Two absolute differences and one wide sum, with no multiply or square root. That makes the result cheap for grid decisions, but it does not make it an interchangeable estimate for every movement model. Measured helper extent: 65 bytes; named state: 6 bytes, excluding return addresses, code alignment and the diagnostic harness. No whole-game cycle budget is inferred.

## Build and evidence

Run make with ASM198X set to the assembler binary; Amiga also takes BUILD198X. Four maintained variants: demo, custom, deliberately wrong client, exact repair. The custom query moves BX from 255 to 200 while BY stays 255 and A remains at the origin. The result is 455, encoded C7 01, rather than 510, encoded FE 01. The wrong client discards DIST_HI after computing the distance. The opposite corners now look 254 units apart rather than 510. Keep the carry byte through both the storage and comparison paths.

Observed rows: demo 00 00 FF FF FE 01 00 00; custom 00 00 C8 FF C7 01 00 00; wrong 00 00 FF FF FE 00 00 00. Read these as hexadecimal state bytes in the field order above, truncated/padded to eight for display; the packet retains every state byte after every call.

Native configuration: NTSC NES with a mapper-0 cartridge, CHR-ROM diagnostic font, NMI and DMC disabled; Asm198x 0.0.72 and Emu198x 0.44.2. Ninety-six table calls per variant exercise valid boundaries and varied inputs, followed by an independent sequential client. A dirty-state init and preserved-register sentinels are checked. Tables are not exhaustive over all input combinations. configuration.json and results.json retain tool/firmware/source identities, immutable loaded bytes, native packet, helper extent and captures; restricted firmware and snapshots are not committed. Use scripts/verify-gameplay-patterns.py --topic manhattan-distance --help to refresh; check-gameplay-patterns.py and test_gameplay_patterns.py validate retained observations and reject mutations. See the independent model in cross-platform/patterns/framework/gameplay-patterns/cases.py.

The standalone cartridge owns its background, CHR font and RAM layout. Its diagnostic packet is bounded below the end of the NES’s 2 KiB internal RAM; the component owns no PPU or audio registers.
