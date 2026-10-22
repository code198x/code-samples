# Checked byte maps on Acorn Atom

Reuse `cross-platform/patterns/rendering/tile-map/6502.inc` unchanged. Copy that include into your project, define TM as a reserved 20-byte zero-page context, clear decimal mode and initialise the pointers, dimensions and highest ID shown in `demo.asm`. The include provides `tile_get`, `tile_set`, `tile_property` and `tile_pixel8`.

The diagnostic selects the full Atom model. Its combined 24 KiB synthetic ROM puts the caller at $C000; results at $0400 and the map at $04F0 stay in low RAM. No BASIC or screen workspace is preserved.

## Call and own the state

Offsets 0–1: map pointer; 2/3: width/height; 4/5: column/row; 6: tile; 7: valid; 8–10: scratch; 11: property; 12–13: property pointer; 14: highest ID; 15: scratch; 16–17: world X; 18–19: world Y. Pointers and world positions are little endian.

Reserve W×H contiguous map bytes and highest-ID+1 property bytes. Width and height are 1–255; all pointed ranges must be addressable without wrapping or crossing an unmapped/banked boundary. Context TM..TM+19 must fit zero page. This is a byte-coordinate representation, not a maximum level size imposed by the machine.

Set column/row, call `tile_get`, and check valid before using tile. Tile zero is legitimate; invalid reads return zero too. `tile_set` also takes tile and rejects coordinates or IDs outside the contract without changing the map. `tile_property` returns a property byte plus valid; the caller decides what bits mean. `tile_pixel8` divides unsigned 16-bit world X/Y by eight, rejects unrepresentable cell coordinates and performs the checked get. World inputs remain intact.

A/X/Y/flags are clobbered. Code, map, property table, context and stack belong to the caller. Interrupts are neither installed nor masked by the library; use separate contexts and preserve interrupted state if calling it from an interrupt. The diagnostic disables interrupts, clears decimal mode and initialises its stack. Do not copy those takeover steps blindly into firmware-owned code.

## Maths and alternatives

The byte offset is row×width+column. Carry into the pointer high byte matters even on a small map. The fixture starts its 35-byte map at $04F0, so it crosses a page boundary. A 7×5 map catches width/height swaps that a square room can hide.

Eight-unit world-to-cell conversion uses three right shifts. A row-pointer table trades two bytes per row for avoiding repeated row-width additions. Power-of-two widths permit shift-based addressing, while packed IDs save map RAM but add bit extraction and read/modify/write work. These are variants to consider; this entry does not claim measured timing for them.

## Common errors, observed

- Wrong stride: changing address arithmetic to add six for this seven-wide map returns tile 2 instead of 3 at column 0, row 1. Use the actual width, not the height, visible width or screen-byte stride.
- Ignoring validity on writes: removing `beq tile_set_done` allows a rejected coordinate to write through the computed pointer. The completed diagnostic changes its unchanged-map/guard result from 1 to 0. Keep the early return and inspect valid in the caller.
- Treating tile 0 as failure: valid empty floor becomes indistinguishable from an invalid query. Use TM+7.

The first two variants were executed on this machine; the third explains the API contract. Retained records contain all 44 observed result bytes for the correct caller and both completed faulty callers. These are memory observations, not fabricated screenshots.

## Build and verify

`make ASM198X=/path/to/asm198x` builds the original synthetic reset fixture. From the repository root run `python3 scripts/verify-assembly-map-gaps.py --only acorn-atom --assembler /path/to/asm198x --native /path/to/native-tools`. It builds all three variants without editing maintained source and fails unless the correct results match the independent oracle and both faulty callers complete with different results.

Executed with released Asm198x 0.0.71 and Emu198x 0.44.1. `verification/results.json` binds the caller, shared implementation, observer, fixture and tool hashes. No third-party firmware is distributed. This proves CPU/RAM routine behaviour in the stated configuration, not a stock interpreter loader, picture, interrupt coexistence, frame deadline or original hardware. The unrolled diagnostic is an explicit test caller; use the shared include in a real game.
