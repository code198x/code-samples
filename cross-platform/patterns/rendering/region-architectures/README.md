# Native regions across different display architectures

Redraw one changed tile, a room or a strip of newly revealed scenery. These adapters preserve the row-major byte-map concept while making each display's requirements visible. They add Oric Atmos, Atari 800XL, Game Boy and Amiga A500 to the region family. A logical map ID is not necessarily a screen byte, and a cell need not be eight pixels wide.

## Choose the implementation

| Machine | Cell | Selected display | Copy path |
| --- | --- | --- | --- |
| Oric Atmos | 6×8 pixels | HIRES, 38 drawable columns × 25 rows | CPU bitmap bytes, two attribute columns reserved |
| Atari 800XL | 8×8 pixels | ANTIC F, 40×24 cells | CPU bitmap bytes, explicit per-line LMS addresses |
| Game Boy DMG | 8×8 pixels | 32×32 logical background map, 20×18 visible at scroll zero | SM83 name bytes; LCD-off calls only |
| Amiga A500 PAL | 16×8 pixels | 320×256, two bitplanes, 20×32 cells | 68000 word copies or synchronous blitter copies |

Do not apply the map family's eight-unit coordinate conversion blindly to Oric X or Amiga X. Choose simulation units deliberately, and convert screen pixels using the actual cell width. The map remains twelve bytes per row in these examples.

## Common request, explicit machine contracts

All callers supply six unsigned request bytes in this order: source column, source row, destination column, destination row, width, height. Call `region_draw`; valid at +6 is one for completion, zero for rejection. The six request bytes survive. Zero sizes, starts outside the map/display, source/destination overruns and IDs outside the configured tile set are rejected before the first destination write. This variant rejects rather than clips.

All selected IDs are checked in a preflight before painting. Keep the request, map, tile assets, descriptor/address tables and display configuration stable throughout the call. Neither interrupt masking nor video setup is hidden inside the drawing routine. Contexts are private and non-re-entrant. These requests share a meaning, not a binary ABI across CPUs.

### Oric and Atari: the existing 6502 bitmap routine

Both include the maintained `bitmap-regions/6502.inc` unchanged. Define assembly-time `NR`, `MAP`, `MAP_W`, `MAP_H`, `TILES`, `TILE_COUNT`, `SCREEN_COLS`, `SCREEN_ROWS`, `CELL_BYTES=1`, `X_STEP=1`, `bitmap_lo` and `bitmap_hi`. The complete 32-byte context must fit in zero page; clear decimal mode before calling. A/X/Y/flags and scratch +6..31 may change. The maximum call stack is four bytes including the direct JSR and paint-helper JSR, excluding caller/interrupt work.

The source byte-map allocation must fit without wrapping: width 1–128, height 1–255. These readable tile variants use 1–16 consecutive eight-byte tile pictures. Address tables contain one low and one high byte for every pixel scanline; the supplied tables cost 400 bytes on Oric and 384 on Atari. A new display base or layout needs matching tables. Ordinary OS integration needs its own loader and ownership agreement; the reset driver is separate.

### Game Boy: LCD-off background-map transfer

Define `NR` as 32 writable bytes, plus `MAP`, `MAP_W`, `MAP_H`, `TILE_COUNT`, `BG_MAP`, `SCREEN_COLS=32` and `SCREEN_ROWS=32`. Include `sm83.inc`. AF/BC/DE/HL/flags and scratch +6..31 may change; four stack bytes cover the direct CALL and paint helper. The example uses WRAM, not high RAM, for context/map/result storage. Map dimensions are bytes, and all allocations must fit their accessible bank.

The routine checks LCDC bit 7 first. If the LCD is enabled, it rejects the request without touching VRAM. The caller disables a running LCD safely in vertical blank; the reset driver waits until LY is at least 145, following Nintendo's early-DMG caution. It uploads four original 2bpp tiles, draws while the LCD is off, and enables the LCD afterwards. Interrupts or other code must not re-enable it midway through a call.

The logical IDs 0–3 select identically numbered hardware patterns in this baseline. Tile bytes are uploaded separately: two bytes per scanline, low colour bitplane then high. A different logical-to-physical mapping needs a descriptor translation variant. The full 32×32 map is checked even where the 160×144 viewport cannot show it. This is not a live-display upload queue, CGB banked attribute implementation or a scrolling engine.

### Amiga: two planes, two drawing backends

Pass A0 pointing to a 32-byte even-aligned context:

| Offset | Meaning |
| --- | --- |
| 0–5 | Six request bytes |
| 6 | Completion/rejection flag |
| 7 | Backend: 0 CPU, 1 blitter; other values rejected |
| 8–11 | Byte-map pointer |
| 12–15 | Tile-picture pointer |
| 16–19 | Plane 0 pointer |
| 20–23 | Plane 1 pointer |
| 24/25/26 | Map width / height / tile count |
| 27–31 | Scratch |

Pointers are big-endian longwords. The tiles and plane pointers must be even; misalignment is rejected. The caller guarantees their allocations, ranges and Chip RAM visibility for display/blitter DMA. The map pointer may be byte-aligned. The example uses 12×8 byte IDs, four tile pictures and two 40-byte-pitch planes. Each 16×8 tile occupies 32 bytes: eight words for plane 0, then eight for plane 1. A0 and the six request bytes survive. D0–D7/A1–A5/CCR are caller-clobbered; no interrupt state changes. Stack depth including the direct BSR is eight bytes on the CPU path, at most sixteen on the blitter path.

`m68000.inc` calls the separate reusable `blit-plane.inc`. That helper takes A1=source, A2=destination and A5=custom-chip base. It copies one aligned 16×8 monochrome tile plane from a two-byte source pitch to a forty-byte destination pitch. It preserves address/data registers and clobbers CCR plus BLTCON0/1, BLTAFWM/BLTALWM, BLTAPT/BLTDPT, BLTAMOD/BLTDMOD and BLTSIZE. Caller owns the blitter exclusively and enables master/blitter DMA. All accessed buffers are aligned Chip RAM.

The helper waits before using the blitter and before returning. Its initial hardware read precedes busy-bit polling, as the hardware reference recommends for older Agnus. `BLTDMOD=38` skips the rest of a forty-byte destination row after its copied word; source modulo is zero. `BLTSIZE=$0201` starts eight lines of one word each. The region routine runs it once per plane. This call is synchronous: it does not demonstrate useful CPU/blitter overlap or OS arbitration. Use an explicit ownership protocol for an OS application; the original reset driver owns the machine.

CPU and blitter versions copy the same 32 bytes per cell. The blitter version also pays for register setup and waits, so hardware acceleration is not an automatic win for such small jobs. Measure the workload before selecting it. Batching spans, asynchronous submission, clipping, masks and more display modes are separate variants.

## Display-specific allocations

**Oric:** the 8,000-byte bitmap is $A000–$BF3F, forty bytes per scanline. Columns 0 and 1 are reserved for PAPER/INK, leaving 38 six-pixel cells. Tables point at $A002+y*40. Tile bytes keep bit 6 set so pixel data cannot become serial attributes; the caller must supply correctly encoded assets. Blank pictures are $40 bytes, not zero bytes. The bottom three text rows are separate. This variant does not cross or overwrite attribute slots.

**Atari:** the bitmap allocation is $4000–$5FFF, including gaps. ANTIC's screen address counter does not carry across a 4 KB boundary. The first block holds 102 complete forty-byte scanlines; the next starts at $5000. Tables point at `$4000 + (y/102)*4096 + (y mod 102)*40`. The original driver uses an LMS for each scanline, keeping the display list explicit rather than minimal. Its active list is 582 bytes; 768 bytes are reserved/copied at $3000, within one 1 KB display-list page. Used bitmap bytes total 7,680; the remaining 512 allocation bytes stay unchanged. Other modes, widths or display lists need their own tables and checks.

**Game Boy:** the background map occupies $9800–$9BFF, with separately reserved sixteen-byte guards at $97F0 and $9C00. The first guard is in unused tile-data space, not an adjacent RAM bank. Four tile patterns occupy $8000–$803F. The driver selects unsigned pattern addressing, background map $9800 and zero scroll, with the window and sprites off. LCD-on calls are deliberately rejected.

**Amiga:** two separate 10,240-byte Chip RAM planes occupy $10000–$127FF and $12800–$14FFF in the driver. Copper list, tile data, context, map, guards and stack are separate allocations. The Copper reloads the plane pointers for each display. CPU and blitter drawings happen before display DMA is enabled; neither constitutes a frame-budget measurement.

## Verification

Five execution paths cover four machines: Oric, Atari, Game Boy, and both Amiga backends. Normal passes execute 99 calls total: 18 on each 6502 target, 19 on Game Boy (including LCD-on rejection), and 22 per Amiga backend (including backend/alignment rejections). Every normal case records a nonzero completion marker.

Each of fifteen rejected map/bounds/ID requests is also executed separately after the same three accepted draws on every path: 75 isolated rejected requests preserve the complete destination and both mapped guards. The observer compares every destination byte, including reserved Oric attributes and unused Atari gaps, with an independent model. Every native framebuffer pixel, including borders or the handheld viewport, matches a separate composition.

Both completed wrong-layout and unsafe-destination controls fail on all five paths. An additional shortened-blit control fails through the selected blitter path, establishing that hardware copy is actually exercised. CPU/blitter complete memory outputs match. Native captures are emulator output, not CRT photographs. These results establish the selected released Emu198x 0.39.0 configurations and original reset fixtures, not original hardware timing, stock-OS loading, interrupt coexistence, tear-free animation or throughput.

No manufacturer firmware is included. Build and run:

```sh
make -C oric-atmos/patterns/assembly/rendering/tile-region
python3 scripts/verify-region-architectures.py --native /path/to/emulators --assembler /path/to/asm198x
python3 scripts/check-region-architectures.py
python3 -m unittest discover -s scripts -p test_region_architectures.py -v
```

Execution uses checksum-verified Asm198x 0.0.71 and Emu198x 0.39.0. Per-caller records retain exact source/executable identities, complete destination readbacks, native captures and completed controls. Retained checks run without emulator executables or firmware.

## Primary references

- *The Oric Atmos Handbook* (Century Communications): HIRES graphics, serial attributes and memory map; the graphics discussion explains that attributes occupy screen positions. The actual bitmap bound follows 200 scanlines × 40 bytes from $A000.
- Atari, *De Re Atari* (1982), chapter 2, printed pp. 2-5–2-6: 1 KB display-list counter boundary, LMS and the 4 KB screen-memory counter boundary.
- Nintendo, *Game Boy Programming Manual*, version 1.1 (2000): LCD controller operation-stop flag; Programming Cautions §2.1.1 on safely disabling early-DMG LCDs, and the VRAM/tile-map format sections.
- Commodore, *Amiga Hardware Reference Manual*, third edition: chapters 3 and 6, bitplanes, blitter area-copy setup, modulos, busy polling and blitter ownership; printed p. 186 explains the initial hardware read before polling.

Original reset setup stays visible in every caller. The reusable code owns only the explicitly documented memory and device operations.
