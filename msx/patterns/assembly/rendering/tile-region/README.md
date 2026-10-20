# Draw a native tile region on MSX1

Take a rectangle of logical tile IDs and write the matching native name-table entries. Start with `initialise_context` and `example_call` in `demo.asm`, then use the shared [calling contract and routines](../../../../../cross-platform/patterns/rendering/tile-region/README.md) in your own program. The example's reset-ROM setup takes over the display; it is separate from the reusable routine.

## This caller

- Selected mode: Graphics I; 1 native byte(s) per cell, 32×24 logical name table at $1800.
- VDP data/control writes: $98/$99; diagnostic data reads: $98. The MSX caller reads the BIOS port bytes at 6/7 rather than embedding them in the routine.
- Diagnostic readback: $C000 through $C31F; map context: $C320 (20 bytes); region context: $C334 (18 bytes); result flags: $C354 (23 bytes); initial stack: $FEF0, growing down. These do not overlap.
- Map and descriptor/pattern data are original ROM data. The map starts at $0FF0 and crosses a page boundary.
- The caller disables interrupts, configures the VDP and blanks the display during changes. Choose and reserve memory/VRAM for your project; these addresses do not claim firmware or interrupt compatibility.

## Use it

Define `TM`, `NR`, `CELL_BYTES` and `NT_STRIDE`, include the byte-map lookup and region routines, and initialise the map dimensions, maximum ID, ports, name-table base and descriptor pointer. Set source column/row, destination column/row, width/height in `NR+0..5`, call `region_draw`, and check `NR+6`.

AF/BC/DE/HL, region scratch and map-query address scratch are clobbered. Six bytes of stack are needed at the deepest point including the direct call and saved pointer. The caller owns stable map/descriptor data and exclusive VDP access. Pattern and colour/palette upload remains separate. Invalid extents and IDs are rejected before any VDP write; clipping and VBlank queues are separate variants.

## Build and inspect

Run `make ASM198X=/path/to/asm198x` for the original diagnostic image. The shared build script documents its loader flags and packaging. `verification/positive.png` is the actual raw capture; the JSON files retain complete name-table/guard readback and accepted/rejected calls. The deliberately wrong-stride and unsafe-destination diagnostics also complete, and the independent observer rejects their output.

The retained run used Emu198x 0.39.0 and Asm198x 0.0.71. See the shared contract for source manuals, tool identities, timing limits, alternative implementations and repeat commands. Evidence applies to this selected emulator/mode; no original-hardware, stock-OS-loader, concurrent-interrupt or frame-budget claim is made.
