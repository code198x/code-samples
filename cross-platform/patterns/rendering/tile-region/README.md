# Draw a native tile region

`region.inc` draws a rectangle from the existing byte-map context into a native name table. Keep the level's tile IDs independent of the bytes the display needs. The descriptor table translates between them: the same wall can become pattern 8 on a TMS machine or a two-byte pattern/attribute entry on Sega Mode 4.

The first variant checks the whole request, including every tile ID, before its first VDP write. Invalid requests leave VRAM unchanged. It rejects out-of-bounds rectangles; it does not clip them.

## Include and initialise

Define `TM`, `NR`, `CELL_BYTES` and `NT_STRIDE`, then include `../tile-map/z80.inc` and `region.inc`. `TM` follows the [existing byte-map contract](../tile-map/README.md). Initialise its map pointer, width, height and highest tile ID. The map is row-major and may be ROM or RAM; it must stay unchanged throughout the call and fit the CPU's current address/bank window.

`NR` is 18 caller-owned bytes:

| Offsets | Meaning |
| --- | --- |
| 0 / 1 | Source column / row |
| 2 / 3 | Destination column / row in the logical name table |
| 4 / 5 | Width / height in cells; both nonzero |
| 6 | Returned valid flag: 1 completed, 0 rejected |
| 7–11 | Scratch: row, column, reserved byte and source-row pointer |
| 12 / 13 | VDP data-write / control-write ports |
| 14–15 | Little-endian name-table base in VRAM |
| 16–17 | Little-endian descriptor-table pointer in CPU memory |

`CELL_BYTES=1` selects Graphics I descriptors: one pattern byte per logical ID. `CELL_BYTES=2` selects Sega Mode 4 descriptors: low pattern byte, then the attribute byte containing the ninth pattern bit and flip/palette/priority flags. The table needs `highest ID + 1` complete descriptors. This variant uses `NT_STRIDE=32` and a logical 32×24 destination. Width/height and source coordinates are unsigned bytes; use another variant for signed origins or larger maps.

The name-table base must match the selected VDP registers and reserve a complete 768-byte (Graphics I) or 1,536-byte (Mode 4) range within VRAM. The routine does not allocate patterns, colours, palette entries or sprite memory. Initialise those separately and keep them consistent with the descriptors.

Set offsets 0–5, `call region_draw`, then read offset 6. The six inputs and configuration at 12–17 are preserved. The routine clobbers AF/BC/DE/HL, region scratch, and TM's column/row, valid flag and address scratch. All configured pointers, dimensions and tables are caller preconditions; rectangle and tile-ID checks do not validate arbitrary memory or hardware configuration.

## Ports, mode and ownership

| Tested target | Data write | Control write | Data read for diagnostic | Mode |
| --- | --- | --- | --- | --- |
| ColecoVision | BE | BF | BE | Graphics I |
| Sord M5 | 10 | 11 | 10 | Graphics I |
| MTX | 01 | 02 | 01 | Graphics I |
| Einstein TC01 | 08 | 09 | 08 | Graphics I |
| MSX1 | BIOS[7] | BIOS[7]+1 | BIOS[6] | Graphics I |
| SVI-328 | 80 | 81 | 84 | Graphics I |
| SG-1000 | BE | BF | BE | Graphics I |
| Master System | BE | BF | BE | Mode 4 |
| Game Gear | BE | BF | BE | Mode 4 |

Numbers are hexadecimal. They identify these tested configurations, not every expansion or display interface. The library only writes; diagnostic readback is separate. MSX's standard explicitly permits fast VDP access using the BIOS port bytes. Its original reset fixture selects RAM in slot 3; that fixture setup is not a portable replacement for MSX BIOS initialisation. The SVI's read and write ports differ.

The caller owns the VDP address latch, register configuration, descriptor/pattern/colour storage and target rectangle. Exclude interrupt handlers and other code that use the VDP or mutate the map during the call. The routine neither disables nor restores interrupts. The examples take over the machine, disable interrupts and blank the display during updates, then enable it for observation. They do not establish coexistence with a stock BIOS, an interrupt handler or another renderer.

Game Gear still has a 32×24 logical name table. Its 160×144 picture shows columns 6–25 and rows 3–20 in the selected mode. A valid write outside that window changes VRAM without appearing on the handheld screen. The diagnostic checks such a write through VDP readback as well as the visible corner.

## Cost and alternatives

The routine uses the existing 20-byte map context, 18 bytes of region state, the descriptor table, code and caller stack. At its deepest point it needs 6 stack bytes including the direct caller's CALL and any saved source pointer; reserve extra for the rest of the program and interrupts. The original 1 KB RAM callers explicitly keep readback, contexts, results and stack separate.

Preflight costs a second read of every requested tile. Row addresses are recomputed using the source width and destination stride, so their cost grows with row number. That is easy to follow, but not the fastest possible copy. Cached row pointers, pretranslated cell buffers or a trusted-map variant can trade RAM or validation guarantees for speed.

Every OUT uses a shared helper with four NOPs, RET/CALL overhead and an explicit zero high port byte. Even back-to-back helper calls separate transfers by at least 62 Z80 T-states: 15.5 microseconds at 4 MHz, exceeding the TI manual's worst-case 8-microsecond VRAM-access interval. This is instruction-spacing reasoning for the tested clocks, not a hardware timing measurement or an assertion that a complete rectangle fits VBlank. The included callers update while blanked.

For a scrolling view, clip both source and destination together before calling, or use a dedicated clipping variant. For a running game, a bounded VBlank queue can preserve port ownership and spread large updates over frames. Other TMS modes need their own asset/table contracts; a Text-mode 40-column screen is not this destination layout.

## Build and verify

Each machine folder has a complete original reset-ROM/cartridge caller and Makefile. The shared builder emits only original data; no third-party firmware is distributed. `systems.json` names the precise memory and loader configuration. The map begins at $0FF0 so the checked region crosses a source page boundary.

`python3 scripts/verify-tile-regions.py --native /path/to/tools --assembler /path/to/asm198x` executes all nine machines using Emu198x 0.39.0 and Asm198x 0.0.71. Each result slot includes a nonzero completion bit, so zero-initialised RAM cannot stand in for a completed rejection. There are 22 region calls per machine, including a non-square source selection, a single-cell redraw, both source/destination edges, byte-coordinate extremes, zero extents and an invalid ID after a valid one. The observer compares the whole name table and following guard, read through the VDP ports, and every pixel of the raw framebuffer. It rejects completed wrong-stride and unsafe-destination variants.

`python3 scripts/check-tile-regions.py` checks retained records, sources, readback and pixels without an emulator or firmware. `python3 -m unittest discover -s scripts -p test_tile_regions.py -v` proves these gates reject changed code, damaged VRAM, incomplete/nonfailing controls, wrong images and unexecuted-machine promotion.

The records qualify the selected emulator configuration and these drawing routines. They do not establish original-hardware results, stock-OS loading, VBlank throughput or display/interrupt coexistence. `docs/tilemaps/coverage.json` records drawing separately from query evidence and leaves the other 21 machines unqualified for this component.

## Sources

- Texas Instruments, *TMS9918A/TMS9928A/TMS9929A Video Display Processors Data Manual*, November 1982, §§2.1.3–2.1.5, Graphics I and name/pattern/colour tables: [manufacturer scan](http://www.bitsavers.org/components/ti/TMS9900/TMS9918A_TMS9928A_TMS9929A_Video_Display_Processors_Data_Manual_Nov82.pdf).
- ASCII/Microsoft, *MSX Technical Data Book*, MSX Hardware Specifications §1.7.10, printed p.42: obtain fast-access VDP ports from ROM 6/7.
- Sord, *BASIC-G*, Appendix H, printed p.279: canonical VDP ports 10/11.
- Memotech, *Operator's Manual* (Phoenix), Appendix 10: VDP data/control ports and MODE wiring. [Manufacturer-manual scan](https://archive.org/details/phoenix-mtxoperators-manual).
- Spectravideo, *SVI-318/328 Service & Technical Manual*, I/O map: distinct read/write video ports. [Manufacturer scan](https://hansotten.file-hunter.com/uploads/files/ServiceTechnicalManualSVI3x8.pdf).
- Coleco, *ColecoVision Technical Manual*, CPU/VDP interface. [Manufacturer scan](https://consolemods.org/wiki/images/b/b4/ColecoVision_Technical_Manual.pdf).
- Tatung, *Einstein Hardware Manual*, CPU interface and main-board schematic, p.34: MODE=A0 and gated read/write controls. The table's TC01 addresses were execution-checked in the selected emulator map; this is not an original-hardware decode measurement.
- Sega, *Software Reference Manual for the Sega Mark III*, 1986: video I/O, Mode 4 name entries and palette. [Manufacturer scan](https://segaretro.org/images/d/d6/SoftwareReferenceManualForSegaMarkIIIEU.pdf). The Game Gear crop and CRAM configuration are separately executed in the handheld target; they are not inferred from the Mark III result.
