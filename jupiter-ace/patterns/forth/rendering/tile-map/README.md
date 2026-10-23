# Checked byte-map queries in Jupiter Ace FORTH

Enter routines.fth, then room.fth, then demo.fth, in that order. Compile each definition before entering the next. The first query, `0 1 MGET`, reads column zero of row one and leaves **3 1**: tile 3, success flag 1. The caller prints the flag first because it is on top of the stack.

This is a byte map in FORTH-managed dictionary RAM, not a renderer. It ran through the stock ROM and real emulated keyboard on the unexpanded 3 KiB Ace, with Emu198x 0.44.1 and the ROM identified in docs/ace-map-tools.json. No assembler, RAM injection or replacement firmware is used.

## Take the routines

The definitions in routines.fth are the reusable part. Names begin with M; reserve those names or rename them consistently. Its first DECIMAL sets the input number base for compilation. Calling the compiled words does not change BASE.

The stack effects below run from bottom to top: the rightmost item is the top. A dash separates consumed inputs from returned outputs.

| Word | Stack effect | Job |
| --- | --- | --- |
| MINIT | base width height properties max-ID -- | Select caller-owned map and property storage |
| MCELL | column row -- address valid | Check coordinates and compute the byte address |
| MGET | column row -- tile valid | Read a checked cell; failure returns 0 0 |
| MSET | tile column row -- valid | Change a checked cell, rejecting IDs outside 0..max-ID |
| MFLAGS | tile -- flags valid | Fetch a property byte; failure returns 0 0 |
| MXY | X Y -- tile valid | Divide non-negative signed-cell world positions by eight, then query |

Use the valid flag, not the tile, to distinguish success: tile zero is real floor data. FORTH IF consumes the top flag. Consume or discard the value underneath it on both paths. MSET returns only one item; the other query words return two. They preserve items below their arguments.

MINIT takes five values, with max-ID on top. It does not allocate or validate storage. Width and height must be positive, the map must hold width×height consecutive bytes, and that product and the final address must not wrap the 16-bit address space. All bytes must stay readable, and writable for MSET, for the entire call. Max-ID is 0..255; the property table needs max-ID+1 bytes. Dimensions are native cells, not artificially restricted to byte dimensions, but the allocated RAM remains the practical bound.

MCELL treats coordinates as unsigned cells. On the supplied 7×5 map, -1 is the bit pattern 65535 and fails the bounds check. MXY deliberately uses signed division: its X/Y inputs are 0..32767, with negative values rejected before division. An unsigned 16-bit world needs a different conversion, not an assumption that `/` is unsigned.

## Memory and lifetime

MB/MW/MH/MP/MM hold the selected map, width, height, property table and maximum ID. MC/MR are scratch coordinates. These seven variables use 14 payload bytes plus their dictionary headers. A call changes MC/MR; do not keep another value there.

This is one active descriptor. Call MINIT again when switching maps. The global variables make the words non-reentrant: do not interrupt a query with another query using the same state. They use the ROM's data and return stacks, and neither mask interrupts nor take over a clock. MSET balances its temporary >R on every branch; its address cannot be left on the return stack when it returns.

CREATE and C, allocate the example data in the dictionary. C@/C! access one byte; @/! access a two-byte FORTH cell and are not substitutes here. Do not FORGET or overwrite words/data while the descriptor points at them. The 35 map bytes, following guard byte and four property bytes belong to the caller. A read-only map would need a different change policy.

The measured dictionary increase is **448 bytes for routines.fth**, then **63 for room.fth**, totalling **511 bytes**. The latter includes 40 data bytes and the two CREATE headers. These counts exclude the demonstration/observer words, interpreter workspace and both stacks. Free space above HERE is not all available for more map data: stacks and input still need room. They are configuration-specific ROM measurements, not machine-code instruction sizes or speed timings.

## Make it your own

Run customise.fth after loading the normal definitions/data. It changes FLAGS[3] from 4 (exit) to 5 (exit and blocking). Exactly one property byte changes; no new word is compiled. MFLAGS now returns 5 1 for tile 3, while the tile map is unchanged. Your game must interpret the bits; these routines only return them.

For another room, change the CREATE data and the MINIT dimensions together. For another tile type, allocate the corresponding property byte and raise max-ID together. Passing dimensions larger than the storage is a contract error, not something a coordinate check can discover.

The address is base + row×width + column. World-to-cell conversion divides by eight and rounds down for non-negative values. It uses world coordinates; subtracting a camera first asks about another cell. These are direct applications of Maths for Games, independent of the screen's character layout.

## Verified mistakes

The full deliberately broken variants are in mistakes/ and never belong in the normal load order. Each is loaded from a fresh ROM boot, followed by the same room and caller cases.

- Wrong stride replaces the map width with 6 in MCELL. At column 0, row 1, MGET returns 2 1 rather than 3 1. The first row still passes, which is why a non-square map and later-row checks matter.
- Bypassed validity in MSET converts a rejected coordinate into an accepted write to MB. A write of 1 at column 7, row 0 wrongly returns success and changes the first map byte from 0 to 1. Restore the normal MSET and repeat: the write returns 0 and all map/guard bytes remain unchanged.

The fault calls really complete. The observer prints a distinct case number, the two results and a preserved 77 stack marker; stale output or a stack leak fails the check. Actual display bytes, map snapshots, allocation observations and tool/ROM/source identities are retained in verification/results.json. This is more useful evidence than an image that hides whether the word returned.

## Reproduce

From the repository root:

    python3 scripts/verify-ace-map.py --native /path/to/native-binaries
    python3 scripts/check-ace-map.py
    python3 -m unittest discover -s scripts -p test_ace_map.py -v

The stock ROM remains local; --firmware can select its exact pinned copy. Each variant executes 59 indexed operations: every cell, rejected coordinates/IDs, properties, valid writes/readback and world conversion. Full byte-map/guard snapshots check that rejected writes leave storage alone. The CI checker decodes retained display bytes and falsification tests prove altered/incomplete records fail; that is separate from fresh local emulator execution.

## Costs and onward work

Each query uses a multiplication in the ROM plus bounds checks. Row-address tables would trade two bytes per row for avoiding that multiplication. Packed IDs could save RAM but need extraction/update code; larger rooms may warrant decoded room data or a changes overlay. These are possible extensions, not implemented optimisations or measured frame rates.

The assembly map implementation is a separate Z80 routine and synthetic reset fixture; its execution record does not qualify these FORTH words. Neither version here establishes native tile drawing, a frame deadline or original-hardware behaviour.

Primary reference: Jupiter Cantab, *Jupiter Ace User Manual* (1982), chapters on variables, byte storage, repeating/return stacks, CREATE and memory layout; appendices for U<, / and HERE. Public scan: https://pestilenz.org/~bauerm/jupiter.pdf
