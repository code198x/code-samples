# Tile-map queries: commodore-amiga

Reusable CPU implementation: [`m68000.inc`](../../../../../cross-platform/patterns/rendering/tile-map/m68000.inc). Read the [calling contract](../../../../../cross-platform/patterns/rendering/tile-map/README.md) before including it. It reads/writes map bytes, looks up properties and converts unsigned 16-bit world coordinates to eight-unit cells. It does not own the display or game loop.

## Memory in this diagnostic

- Context: `$2000` through `$2017` (24 bytes).
- Results: `$2040` through `$206B` (44 bytes).
- Writable 7×5 map: `$20F0` through `$2112` (35 bytes).
- Initial stack address: `$7F000`. The CPU's native stack rules and machine mapping still apply.
- A guard byte immediately after the map checks that rejected writes do not spill past it. Properties and original map data reside beside the test program in its synthetic ROM/cartridge.

These addresses belong to a diagnostic which takes over the machine. They are not free-space recommendations for a game under its stock OS. Reserve suitable locations in your own memory layout, including display/firmware workspaces and bank switching. The 68000 context must be even-aligned and A0 must point at it.

## Use the routine

Allocate and initialise the context/map/property table as shown at the start of `demo.asm`. Set width and height to match the actual contiguous map, and highest-ID to match the property table. Set column/row, call `tile_get`, and check valid before reading the tile ID. For a write, set column/row/tile and call `tile_set`. A failed write must leave the map unchanged.

A tile ID is not a hardware character/pattern index and a property value is not interpreted by this library. For a world-position query, supply X/Y, call `tile_pixel8`, check valid and then call `tile_property`. Keep the logical level in world coordinates; subtract a camera only when preparing display positions.

## Run the diagnostic

`make ASM198X=/path/to/asm198x` builds the original diagnostic fixture. It uses synthetic reset ROMs/cartridges rather than the stock interpreter. The maintained verifier selects this machine's exact command, runs the CPU, observes all 44 result bytes and rejects a completed wrong-stride and write-without-valid variants. No screenshot or stock-loader claim follows from this test. See the record in `verification/results.json` once retained.

The unrolled queries in `demo.asm` make each observation explicit; they are a test caller, not an engine or a recommended level-rendering loop. Copy the reusable include and initialise your own context when integrating it into a project. A real display adapter, interrupt policy and native media loader remain separate work.

## Reset overlay

The original ROM fixture removes the low-memory reset ROM overlay through CIA-A before using its RAM context and stack. That is fixture startup work. The query include neither changes overlay nor takes ownership of custom chips, CIA or OS services.
