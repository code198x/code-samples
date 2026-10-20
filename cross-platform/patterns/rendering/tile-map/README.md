# Byte-map queries for native code

The maintained includes supply checked reads/writes, a property table lookup and an eight-unit world-position conversion. They do not draw, wait for a frame, install an interrupt or load a game. Include the appropriate CPU file, reserve its context and initialise the pointers/dimensions before calling it. Each machine folder supplies a complete original diagnostic, Makefile, exact memory reservation and evidence.

## Byte contexts: 6502, Z80 and SM83

Define TM as the first byte of a caller-owned 20-byte context. For 6502 it must fit entirely in zero page (TM <= 236) and the decimal flag must be clear. Pointer fields are little endian.

| Offset | Field |
| --- | --- |
| 0–1 | Pointer to contiguous row-major map bytes |
| 2, 3 | Width and height, each 1–255 cells |
| 4, 5 | Input column and row, unsigned bytes |
| 6 | Tile ID: output from get; input to set/property |
| 7 | Valid flag: 1 success, 0 failure |
| 8–10 | Address/row scratch; do not retain values across calls |
| 11 | Property lookup output |
| 12–13 | Pointer to property bytes |
| 14 | Highest valid tile ID, 0–255 |
| 15 | Conversion scratch |
| 16–17, 18–19 | Unsigned 16-bit world X and Y |

## 68000 context

A0 points at an even-aligned 24-byte context. Multi-byte values use native big-endian storage. Offsets 0–3 hold the map pointer; 4/5 width/height; 6/7 column/row; 8 tile ID; 9 valid flag; 10 property output; 11 highest tile ID; 12–15 property pointer; 16–19 scratch address; 20–21 X and 22–23 Y. A0 is preserved, D0–D2/A1/CCR are clobbered.

## Calls and ownership

- `tile_get`: set column/row, call, check valid immediately, then read tile. Failure sets valid=0 and tile=0; a zero tile alone is not proof of success.
- `tile_set`: set column/row/tile; only a tile at or below the configured maximum and coordinates inside the map can be written. Failure sets valid=0 and leaves the entire map unchanged. The map must be writable RAM for this operation; a ROM map needs a separate changes overlay or another representation.
- `tile_property`: set tile; check valid, then read property. The property table needs highest-ID+1 readable bytes. Failure sets valid=0 and property=0. It does not query the map or interpret the flag bits.
- `tile_pixel8`: set unsigned 16-bit world X/Y. The routine divides by eight, rejects results too large for a byte cell coordinate, then runs the checked query. Check valid before using cell/tile outputs. X/Y inputs remain unchanged. It deliberately implements eight-unit square cells; other sizes need a corresponding conversion. Negative/signed worlds need an explicit origin policy.

The map must contain W*H addressable bytes without crossing the CPU address-space end, bank window or an unmapped boundary. Properties and code must also remain readable under the selected banking state. Own/reserve the context, arrays, property table and stack. Interrupt code may call these only with a separate context and adequate stack, and must preserve any registers the interrupted caller needs. No routine masks or installs interrupts.

6502 clobbers A/X/Y/flags, Z80 and SM83 clobber AF/BC/DE/HL; they do not promise other state through caller code. The deepest return-address storage for one direct call is 4 bytes for get/set on 6502/Z80/SM83 and 8 on 68000. Pixel conversion uses 6 bytes on 6502, 4 on Z80/SM83 (a tail jump reuses the return) and 12 on 68000. Property lookup uses one return address: 2 bytes on the 8-bit CPUs, 4 on 68000. Add the surrounding caller stack and interrupts separately.

Row addressing is a straightforward repeated addition on the 8-bit CPUs and a multiply on 68000. More distant rows cost more repeated additions. Wider cell coordinates and dimensions, especially on 68000, are another variant rather than a hardware limit. Row-pointer tables or fixed-width shifts are useful alternatives; this code makes no cycle-count or frame-budget claim. Map storage is W*H bytes, property storage highest-ID+1 bytes, plus context/code/stack. A fully writable map may be the wrong choice for a very small RAM machine.

## Build and verification

Run `make ASM198X=/path/to/asm198x` in a machine's `patterns/assembly/rendering/tile-map` folder. Asm198x 0.0.71 was used. `build.py` produces an original synthetic diagnostic ROM/cartridge. These replace firmware for a bounded CPU/RAM test; they are not an OS distribution, stock BASIC/FORTH loader or game boot recipe. All bytes are original test material.

The diagnostic copies a non-square 7×5 map into its declared RAM, reads every cell, rejects four outside reads, five invalid writes and an invalid property ID, checks the entire map and its following guard stayed unchanged, performs a valid write, reads the property table, converts a position and rejects an oversized converted coordinate. Result byte 43 is written only at completion. On every system the same observer must reject a deliberately wrong row stride and a write which ignores the validity flag, after each altered caller also reaches completion. Nineteen maps cross a 256-byte boundary; the Atari 2600 map stays within its 128-byte RAM window and uses its own stack budget.

Run `scripts/verify-native-tilemaps.py --native /path/to/native-binaries --assembler /path/to/asm198x`. This establishes the routines on each named CPU/memory configuration. It does not establish stock firmware compatibility, a tape/disk loader, display output, IRQ coexistence, a frame deadline or original hardware. Retained checks in CI bind source and output identities; local execution remains a separate step.
