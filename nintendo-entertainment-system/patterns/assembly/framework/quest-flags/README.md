# Quest and Inventory Flags on NES

A key collected, a door unlocked, a conversation finished: eight yes/no facts fit in one byte. A mask lets you change one fact without erasing its neighbours, or ask whether a group of requirements has been met.

## Reuse

Bind these contiguous private bytes in order: FLAGS, MASK, MODE, ALL_SET. Include component.inc once; call quest_flags_init, set the inputs and call quest_flags_step. The init entry clears every byte, including caller-input fields. Set starting values after init. Both entry points use one fixed binding; use distinct names/scopes and state blocks for independent instances. Do not include conflicting global field labels unchanged.

FLAGS stores eight independent bits. MASK selects any subset of them. MODE **1 sets** those bits, MODE **2 clears** them; other modes only query. After the optional change, ALL_SET is 1 exactly when every bit in MASK is present in FLAGS. An empty mask is satisfied. MASK and MODE survive.

FLAGS persists across calls. MASK and MODE are inputs. ALL_SET is replaced on each call and describes the state after any set or clear operation.

A/X/flags may change; Y and decimal mode survive. **Clear decimal mode before binary arithmetic**; the standalone caller uses CLD. A direct call pushes a two-byte return address.

Initialise once for a fresh world. Assign a power-of-two mask to each independent fact: 1, 2, 4, 8 and so on. Use MODE 0 to query without changing the world. A combined mask such as 12 asks for bits 4 and 8 together; the result means all, not any.

## Limits and alternatives

More than eight facts need a larger byte array plus an index/mask lookup. Counters belong in counters: a flag cannot hold three arrows. Shared interrupt/main-loop updates need an ownership or critical-section policy because these read/modify/write sequences are not atomic transactions.

At most one byte of world state changes. Mask operations take bounded paths and no scan. A byte per fact costs more RAM but may make an early project easier to inspect. Measured helper extent: 53 bytes; named state: 4 bytes, excluding return addresses, code alignment and the diagnostic harness. No whole-game cycle budget is inferred.

## Build and evidence

Run make with ASM198X set to the assembler binary; Amiga also takes BUILD198X. Four maintained variants: demo, custom, deliberately wrong client, exact repair. The custom caller moves its example fact from mask 8 to mask 16. It leaves the unrelated mask-1 fact intact. Changing the bit assignment needs matching definitions in every user of that save/world data. The wrong client passes 3, the intended bit number, where the API expects mask 8. The binary value 3 selects the two lowest bits. Setting and later clearing it destroys the unrelated mask-1 fact. Pass a mask, not an ordinal bit number.

Observed rows: demo 01 08 02 00 00 00 00 00; custom 01 10 02 00 00 00 00 00; wrong 00 03 02 00 00 00 00 00. Read these as hexadecimal state bytes in the field order above, truncated/padded to eight for display; the packet retains every state byte after every call.

Native configuration: NTSC NES with a mapper-0 cartridge, CHR-ROM diagnostic font, NMI and DMC disabled; Asm198x 0.0.72 and Emu198x 0.44.2. Ninety-six table calls per variant exercise valid boundaries and varied inputs, followed by an independent sequential client. A dirty-state init and preserved-register sentinels are checked. Tables are not exhaustive over all input combinations. configuration.json and results.json retain tool/firmware/source identities, immutable loaded bytes, native packet, helper extent and captures; restricted firmware and snapshots are not committed. Use scripts/verify-gameplay-patterns.py --topic quest-flags --help to refresh; check-gameplay-patterns.py and test_gameplay_patterns.py validate retained observations and reject mutations. See the independent model in cross-platform/patterns/framework/gameplay-patterns/cases.py.

The standalone cartridge owns its background, CHR font and RAM layout. Its diagnostic packet is bounded below the end of the NES’s 2 KiB internal RAM; the component owns no PPU or audio registers.
