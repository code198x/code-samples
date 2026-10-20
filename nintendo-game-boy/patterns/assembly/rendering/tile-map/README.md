# Tile-map queries: nintendo-game-boy

Reusable CPU implementation: [`sm83.inc`](../../../../../cross-platform/patterns/rendering/tile-map/sm83.inc). Read the [calling contract](../../../../../cross-platform/patterns/rendering/tile-map/README.md) before including it. It reads/writes map bytes, looks up properties and converts unsigned 16-bit world coordinates to eight-unit cells. It does not own the display or game loop.

## Memory in this diagnostic

- Context: `$C000` through `$C013` (20 bytes).
- Results: `$C040` through `$C06B` (44 bytes).
- Writable 7×5 map: `$C0F0` through `$C112` (35 bytes).
- Initial stack address: `$FFFE`. The CPU's native stack rules and machine mapping still apply.
- A guard byte immediately after the map checks that rejected writes do not spill past it. Properties and original map data reside beside the test program in its synthetic ROM/cartridge.

These addresses belong to a diagnostic which takes over the machine. They are not free-space recommendations for a game under its stock OS. Reserve suitable locations in your own memory layout, including display/firmware workspaces and bank switching. Define TM to point at a reserved 20-byte context; the library uses absolute context references.

## Use the routine

Allocate and initialise the context/map/property table as shown at the start of `demo.asm`. Set width and height to match the actual contiguous map, and highest-ID to match the property table. Set column/row, call `tile_get`, and check valid before reading the tile ID. For a write, set column/row/tile and call `tile_set`. A failed write must leave the map unchanged.

A tile ID is not a hardware character/pattern index and a property value is not interpreted by this library. For a world-position query, supply X/Y, call `tile_pixel8`, check valid and then call `tile_property`. Keep the logical level in world coordinates; subtract a camera only when preparing display positions.

## Run the diagnostic

`make ASM198X=/path/to/asm198x` builds the original diagnostic fixture. It uses synthetic reset ROMs/cartridges rather than the stock interpreter. The maintained verifier selects this machine's exact command, runs the CPU, observes all 44 result bytes and rejects a completed wrong-stride and write-without-valid variants. No screenshot or stock-loader claim follows from this test. See the record in `verification/results.json` once retained.

The unrolled queries in `demo.asm` make each observation explicit; they are a test caller, not an engine or a recommended level-rendering loop. Copy the reusable include and initialise your own context when integrating it into a project. A real display adapter, interrupt policy and native media loader remain separate work.
