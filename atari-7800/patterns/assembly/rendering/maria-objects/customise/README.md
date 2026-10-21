# Change the shape, width, placement and palette

Run `make`, then load `build/ships.bin` in the NTSC 7800 emulator. This original
reset caller uses the unchanged parent `objects.inc`, valid page-aligned RAM
lists and the same immutable-list DMA enable route as the normal example.

`CUSTOM OBJECTS` changes the width from two to three bytes (8 to 12 pixels),
positions from x32/x152 to x24/x100 and selects palette 1 for the second object.
The original 12x16 ship in `ship.inc` uses all three nonzero colour indices;
zero stays transparent. `CUSTOM PALETTES` initialises palette 1 to $86/$8C/$8E
before DMA is enabled; palette 0 retains $0E/$06/$0A. Changing a header's palette
number alone does not initialise its registers.

Graphics are still sixteen 256-byte-spaced rows, stored bottom first for
OFFSET=15..0. Each row now has three useful bytes and 253 padding bytes. There
are 48 useful source bytes rather than 32, within the same 4096-byte span. Keep
low-address+width<=256, readable graphics for every zone offset, valid bank
state and x+4*width<=160. The chosen x152 would no longer fit width3; use the
new placements or reject the overrun rather than quietly clipping it.

The reusable builder stays 121 bytes with 10 context bytes; four-slot list RAM
stays 18 bytes, the two-object live list 10, DLL 48 and empty list 2. The startup
instruction span grows 120 to 126 bytes. This is assembled size, not elapsed
execution time. A populated raster now reads 8 header bytes + 2 termination bytes
and 6 graphics bytes, rather than 4 graphics bytes. Wider graphics increase DMA
work even when list size is unchanged. These are work counts, not a worst-case
load limit or elapsed-DMA measurement. The cartridge remains 48 KiB.

Building more objects needs list capacity and scanline bandwidth. Smooth
vertical motion, a different video mode, live list updates or a new bank layout
needs a new design/verification pass. This caller still builds once with DMA
off and publishes once during VBlank; it is not an animation publisher.

`verification/ships.json` binds the headers, source and full native capture.
Fresh reproduction from the samples root:
`python3 scripts/verify-tia-maria-customise.py --tools /path/to/tools --output /path/to/output`.
The independent model checks the logical ship, both palettes and placements;
fresh execution also reads back every page-stepped source row and the guard.
RGB expectations use the selected Emu198x 0.41.0 NTSC palette, not a physical
television standard. No commercial BIOS or original-hardware test is claimed.
