# Checked byte-map queries: MSX1 Z80

Read every cell in a 7×5 row-major map, reject out-of-range reads/writes, change a tile, look up its properties, and convert world positions into eight-unit cells. This is reusable CPU/RAM code, not a screen renderer.

The diagnostic replaces the 32 KiB BIOS. Before using its stack, it writes $C0 to PPI port $A8: slot 0 remains selected for pages 0–2, while page 3 ($C000–$FFFF) selects slot 3 RAM in this emulator configuration. Context $C000, results $C040, map $C0F0 and stack top $FFF0 are all in that page. This is a fixture-specific selection, not a portable MSX RAM-discovery routine. Real MSX machines can place RAM in other slots or subslots; a BIOS-facing program should discover and preserve their layout rather than copy this startup byte.

## Include, initialise and call

Include `cross-platform/patterns/rendering/tile-map/z80.inc` after defining TM. Its [shared calling contract](../../../../../cross-platform/patterns/rendering/tile-map/README.md) lists every offset and register/stack obligation. Reserve 20 context bytes, W×H map bytes, highest-ID+1 property bytes and the stack. Pointers and world X/Y are little endian. Dimensions are 1–255; zero dimensions reject every coordinate. Do not cross a bank, unmapped range or the address-space end.

Initialise map/property pointers, width, height and highest ID. Set column/row, call tile_get, check TM+7, then read TM+6. For tile_set, supply the new ID in TM+6; invalid writes leave the map alone. tile_property returns TM+11 and valid. tile_pixel8 takes unsigned 16-bit world X/Y at offsets 16/18 and leaves them unchanged. A zero tile is not a success flag.

Map storage and classification are independent of the display. Convert world coordinates by floor(X/8), floor(Y/8), then query; do not accidentally supply camera-relative screen coordinates. This connects directly with Maths for Games: row×width+column and integer division.

## Build and verify

`make ASM198X=/path/to/asm198x` builds an original replacement firmware fixture. `make VARIANT=closed-exit` builds the maintained customisation. The build helper installs padding/reset vectors as required; the raw assembled payload alone is not necessarily a complete firmware image.

From the repository root:

    python3 scripts/verify-remaining-assembly-maps.py --only msx --native /path/to/binaries --assembler /path/to/asm198x

Asm198x 0.0.71 and Emu198x 0.44.1 executed this exact configuration. All 44 result bytes are compared against explicit host-side rows: 35 reads; rejected read/write flags; unchanged map/guard; valid write, property and conversion; completion marker 239. This does not establish stock loaders, firmware coexistence, graphics, frame deadlines or original hardware.

## Make it your own

Replace properties.inc with customise-properties.inc: tile 3 changes from exit flag 4 to exit+blocking flags 5. Both variants execute independently; result 40 changes 4→5 and all other 43 bytes agree. Whole firmware fixtures differ in exactly one data byte, the property table stays 4 bytes, and code/context sizes stay fixed. The table is ROM data in this fixture; a runtime-editable table needs writable RAM and a suitable pointer. Your game interprets the flags.

## Common errors

The deliberately broken includes live under shared tile-map/mistakes; they are not the normal download. Both run to marker 239. Wrong stride 6 instead of 7 makes the row-one first cell return 2 instead of 3. Ignoring validity before a write changes unchanged-map/guard result 37 from 1 to 0. Restore the maintained normal include and rerun: the complete oracle must pass. Raw observed byte arrays and source/tool/fixture hashes are retained in verification/results.json.

## Costs and extensions

The routine repeatedly adds the row width, so later rows require more work. Storage is W×H + highest-ID+1 bytes, plus code/context/stack. Row-pointer tables trade two bytes per row for fewer additions; packed IDs trade extraction work for RAM. Signed worlds, wider coordinates or different cell sizes need their own explicitly verified variant. No cycle totals or whole-game speed are claimed.

Hardware reference: [MSX Technical Data Book, hardware specifications, slot selection and §1.7.6 PPI port](https://map.grauw.nl/resources/system/msxtech.pdf).
