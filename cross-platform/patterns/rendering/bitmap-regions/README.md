# Draw checked map regions into a bitmap

A door opens, so redraw one tile. A room changes, so redraw its rectangle. These routines copy original 8×8 tile pictures into a CPU-addressed bitmap, preserving the row-major byte-map format used by the map/query family. They extend the existing native VDP region family with 6502, 6809 and Z80 implementations.

There is no name table to update here: each cell copies eight bitmap bytes on the monochrome machines, or sixteen on CPC MODE 1. A map change and its visible redraw remain separate operations.

## Calling contract

Define `NR` as 32 private, caller-owned bytes; on 6502 they must be in zero page, with the whole context inside that page. Define `MAP`, `MAP_W`, `MAP_H`, `TILES`, `TILE_COUNT`, `CELL_BYTES`, `SCREEN_COLS`, `SCREEN_ROWS`, `X_STEP`, `bitmap_lo` and `bitmap_hi` before including the CPU routine. These are assembly-time symbols, not a runtime allocation API. Link the routine once; the demo's ROM addresses are not a memory allocator.

- `MAP`: writable row-major byte IDs, with `MAP_W` columns and `MAP_H` rows. Width is 1–128 and height 1–255; the allocation must fit the CPU address space without wrapping. The example map is 12×8 and crosses a page boundary at $04F0 (CPC $44F0).
- `TILES`: consecutive tiles, eight scanlines each, one or two bytes per scanline. `TILE_COUNT` is 1–16 for these variants. The table must contain every declared tile; zero is an opaque empty picture, not transparency.
- `bitmap_lo` and `bitmap_hi`: low/high address bytes for each pixel scanline. Both tables contain `SCREEN_ROWS*8` entries, up to 256 each. Together they describe the current bitmap base and layout. Rebuild/reselect them when changing the display start or hard scrolling.
- `CELL_BYTES`: 1 on Atom, BBC and Dragon; 2 for this CPC MODE 1 routine. The 6809 variant here is for one-byte monochrome rows; the Z80 variant is for two-byte CPC rows. These are qualified variants, not freely interchangeable settings.
- `X_STEP`: horizontal byte displacement per 8-pixel cell: 8 on BBC, 1 on Atom/Dragon, 2 on CPC. BBC scanline bytes are adjacent vertically within a character, so cell width in bytes is not the horizontal address step.

Set `NR+0..5` to source column, source row, destination column, destination row, width and height. Use JSR/CALL `region_draw`. `NR+6` is one on completion, zero on rejection. The six request bytes survive. `NR+7..31` are scratch/reserved and need no initialisation.

Zero sizes, starts outside the map/display, rectangles which overrun either boundary and tile IDs outside `TILE_COUNT` are rejected before the first bitmap store. It rejects rather than clips. It makes a complete ID preflight before painting; keep the map, tile data, address tables and request stable throughout both passes.

The 6502 version clobbers A/X/Y/flags and requires decimal mode clear. The 6809 version clobbers A/B/X/CC; Y/U/DP are preserved. The Z80 version clobbers AF/BC/DE/HL/flags. All versions alter the context scratch. The deepest stack use in these routines is four bytes including the direct caller's JSR/CALL and the paint helper call; allow additional space for the rest of your program and interrupts. Neither the routine nor its context is re-entrant.

The caller owns bitmap memory, tile assets, map, tables, context, display registers, palette and interrupt policy. No drawing routine sets up the hardware or masks/restores interrupts. The original reset diagnostics configure video separately and exclude interrupts. Ordinary MOS/BASIC/firmware integration requires a loader and an explicit ownership agreement; the diagnostic ROM is not a stock-OS application.

## Layouts and costs

| Machine | Picture | Bitmap allocation | Scanline address (y starts at zero) | Horizontal step |
| --- | --- | --- | --- | --- |
| BBC Micro Model B | MODE 4, 320×256, 2 colours | $5800–$7FFF, 10 KB | $5800 + (y/8)*320 + (y mod 8) | 8 |
| Acorn Atom | mode 4, 256×192, monochrome | $8000–$97FF, full 6 KB graphics expansion | $8000 + y*32 | 1 |
| Dragon 32 | PMODE 4, 256×192, monochrome | $0600–$1DFF, 6 KB | $0600 + y*32 | 1 |
| Amstrad CPC 464 | MODE 1, 320×200, 4 pens | $C000–$FFFF, 16 KB including unused gaps | $C000 + (y mod 8)*2048 + (y/8)*80 | 2 |

A 5×3 region copies 120 bitmap bytes on the monochrome targets, 240 on CPC. The demonstration additionally erases one cell and draws the bottom-right corner, giving 136 or 272 bytes written by its three accepted calls. These are byte counts, not cycle or frame-budget measurements.

The two address tables cost 512 bytes on BBC, 384 on Atom/Dragon and 400 on CPC. Four tile pictures cost 32 or 64 bytes. Each call uses the 32-byte context plus caller stack. Tables trade RAM/ROM space for clear and predictable address lookup. The readable source locator still walks preceding map rows for each selected cell; cached map row pointers and row-span copies are useful faster variants. Do not infer VBlank fit from a small example.

CPC pixel bits are interleaved: in each byte, pixels 0–3 use low pen bits 7,6,5,4 and high pen bits 3,2,1,0. A tile therefore needs two packed bytes per scanline. BBC/Atom/Dragon use most-significant-bit-left monochrome rows. The 6809 code uses unsigned D indexing for scanline tables: B-only offsets are signed and would address before the table for scanlines 128–255.

## Verification and boundaries

Each machine completes 18 calls: three accepted draws and fifteen rejected requests covering zero extents, source/destination overruns, byte-coordinate extremes and an invalid tile after a valid one. Every case has a nonzero completion marker. Each rejected request is also executed separately after the same three accepted draws; all sixty isolated rejected calls preserve the complete bitmap and guard.

The observer compares the entire allocated bitmap, including CPC's unused gaps, with an independently constructed expected image in memory. Sixteen mapped guard bytes are checked too: immediately below the bitmap on BBC/Dragon/CPC; after the map on Atom because the address just below its video RAM is unmapped. The complete native capture, borders included, is compared pixel for pixel with an independent composition. Screenshot colours are the released emulator's configured output, not a claim about a particular CRT.

Both completed wrong-layout and unsafe-destination variants fail on all four machines. Retained evidence, source hashes and released executable identities accompany each caller. The guard checks can run without firmware or emulator executables:

```sh
python3 scripts/check-bitmap-regions.py
python3 -m unittest discover -s scripts -p test_bitmap_regions.py -v
```

To execute again, use checksum-verified Asm198x 0.0.71 and Emu198x 0.39.0 binaries, then:

```sh
python3 scripts/verify-bitmap-regions.py --native /path/to/emulators --assembler /path/to/asm198x
```

No restricted firmware is included. This establishes these reset fixtures and selected emulator configurations; it does not establish original-hardware timing, stock-OS loading, interrupt coexistence, tearing-free animation or a complete-game frame budget. Clipping, transparent/masked tiles, queued updates and other display modes need their own variants and checks.

## Primary references

- *The Advanced User Guide for the BBC Microcomputer*, Appendix F, MODE 4 register/layout tables, printed pp. 470–471. The layout illustration explicitly assumes a cleared, unscrolled display.
- Acornsoft, *Atomic Theory and Practice*, §11.1 and §11.8.2, printed pp. 79 and 88–89: graphics allocation, mode selection and bitmap plotting.
- Duncan Smeed and Ian Sommerville, *Inside the Dragon*, chapter 7: VDG/PIA control, SAM mode bits and display-base selection in 512-byte units.
- *The Anatomy of the CPCs*, vol. 1, §1.6, printed pp. 45–48: video RAM, eight-line spacing and packed pixel colours.

The exact initialisation bytes remain visible in each original caller. These sources describe the hardware; emulator observations establish the separate configuration-specific execution claims above.
