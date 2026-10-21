# Place ROM characters without pretending they are pixels

Use a counted run of native screen codes to draw a label, a row of scenery or one part of a larger character picture. The game supplies the codes; the installed ROM supplies the shapes. These routines complement the existing PET/Aquarius map-region renderer rather than replacing it.

| Machine | Selected surface | Display ownership |
| --- | --- | --- |
| PET | 40×25 fixed character cells, monochrome | Caller owns screen RAM; no per-cell colour plane |
| Aquarius | 40×25 cells and foreground/background bytes | Caller owns both planes; cell zero and surround preserved |
| ZX80 | Up to 32×24 ROM characters, variable-length display rows | ROM refresh; only existing cells can be replaced |
| ZX81 | Up to 32×24 ROM characters, variable/full display rows | ROM refresh; this caller reserves the lower two rows |

The Sinclair include takes `COLS=32`, `ROWS=22` and `DF_END=$4010`. On ZX80 that word is DF-END; on ZX81 it is VARS, following the display file. D_FILE is the word at $400C on both. The two words have different meanings even where their addresses happen to match. The example exposes 22 upper rows as a policy to leave input space; the hardware has 24. A caller owning the whole file may select up to 24 rows. Do not change these compile-time dimensions without establishing the actual allocation.

## Include and call

Include the machine's `characters.inc` once. Define `FC` as 24 private writable bytes: zero page on PET, ordinary RAM on Z80. Sinclair also needs the constants above. Keep context, code, source, destination, stack and OS allocations separate. The complete `demo.asm` files assemble with Asm198x; PET/Aquarius are original reset drivers. The Sinclair `caller.bas` files invoke the assembled entry through the stock ROM's USR function. Qualification places that assembled image at $6100 using debugger writes; this is not a cassette loader.

| Offset | Input or output |
| --- | --- |
| +0..1 | Pointer to `count` readable native screen codes, low byte first |
| +2 | Zero-based cell column |
| +3 | Zero-based cell row |
| +4 | Nonzero count, one row only |
| +5 | Output: 1 accepted, 0 rejected |
| +6 | Output: accepted character writes, otherwise 0 |
| +7 | Aquarius foreground/background byte; ignored elsewhere |
| +8..23 | Reserved/scratch; do not share it with the game |

Set +0..4 (and Aquarius +7), call `character_span`, then inspect +5. No scratch initialisation is needed. Inputs +0..4 and +7 survive. Rejections return before any display or colour write. Status and scratch can still change on rejection. Source allocation, non-wrapping readable pointers, stability and non-aliasing are caller obligations; an assembly routine cannot prove ownership from a pointer.

PET clobbers A/X/Y/flags and requires decimal mode clear. Z80 clobbers AF/BC/DE/HL and preserves IX/IY. None changes banks or interrupt state. The component is not re-entrant: an interrupt cannot use the same context while a call is in progress. Direct stack space is two bytes on PET/Aquarius and four on Sinclair, including the helper call; add the caller's saved registers, return frames and interrupts. The USR bridge saves AF/BC/DE/HL (eight more bytes), restores them and returns BC=0 for BASIC's numeric result. It does not take over display refresh.

## Machine differences

**PET:** address = $8000 + row×40 + column. Only displayed cells $8000–$83E7 are written; the unused 24-byte tail remains unchanged. Screen codes are not the PETSCII codes passed to PRINT. Choose codes for the installed ROM and selected character set; a ROM glyph is not a software-redefinable picture. There is no invented colour byte. This 40-column result does not qualify an 80-column PET or a graphics expansion.

**Aquarius:** matching addresses are $3000 + cell and $3400 + cell. Attribute high nibble selects foreground, low nibble background. One accepted character writes both bytes. Requests starting at (0,0) reject: that cell repeats into the surround, so an ordinary label must not change it. The caller can still deliberately manage cell zero outside this routine. BASIC normally owns the first display row and scrolls its own area; a game using this reset driver owns all 25 rows, not a coexisting BASIC/editor allocation. Both 24-byte tails remain unchanged. The unexpanded driver's context/stack fit $3800–$3FFF.

**ZX80/ZX81:** the routine reads the current D_FILE pointer on every call, skips newline-terminated rows, then finds the requested column. It checks the exclusive end before walking or writing, and checks the entire target span plus source codes before committing. It never extends a short row, inserts a newline or moves BASIC's variables. Codes with bit 6 set reject: those can be control instructions rather than ordinary glyphs in the executed display file. Codes 0–63 and their inverses 128–191 are allowed. Native screen codes are not ASCII; A is 38 here, not 65.

A valid, stable ROM display file is a precondition. Do not hand the routine malformed pointers or concurrently relocate the file. PRINT, INPUT and program editing can move or rebuild it. The ZX80 driver prints three ten-cell rows; requests reaching unallocated columns/rows reject. The ZX81 16 KiB configuration has full rows; its first 22 rows are compared. ZX80 checks compare the three owned rows, including every terminator; INPUT owns the following area. The last two screen rows and moving editor/input state are not asserted invariant on either machine.

The ZX80 loses its picture during ordinary computation and refreshes while the ROM waits for input. The ZX81 can share processing and display refresh in SLOW mode; FAST suppresses that display work. Neither caller replaces the ROM timing loop, changes I, disables interrupts or installs a custom raster. Preserve the ROM's NMI/interrupt/register conventions. A standalone assembly game needs its own explicit refresh policy; this is not a free-running video controller.

## From cells to pictures

A code selects an installed shape; it does not set one arbitrary dot. ROM block graphics can give a coarser logical grid. If a chosen glyph supplies 2×2 independently selectable blocks, subcell (sx,sy) lies in cell (floor(sx/2),floor(sy/2)); its quadrant is selected by (sx mod 2,sy mod 2). That needs a real lookup from quadrant mask to that ROM's glyph codes. There is no universal PET/Aquarius/Sinclair table, and this component does not claim one. For shapes the ROM lacks, compose several cells, choose an approximation or select a separately documented hardware/display extension.

The existing map/query routines should retain logical IDs and collision rules. Translate IDs into screen codes at drawing time. Our PET/Aquarius region routines already do that for rectangles. This span handles a counted label or changed row. Bigger pictures, clipping, transparency, proportionally spaced text and arbitrary-size glyphs require different contracts.

## Costs and alternatives

The assembled components contain 86 code bytes (PET), 103 (Aquarius), and 164 each (ZX80/ZX81), excluding caller/assets. Each reserves 24 context bytes. A label costs one source byte per cell and N destination writes; Aquarius costs 2N writes across the two planes. Sinclair performs a row walk and a full preflight before copying. These are code/storage/write counts, not measured cycles or a frame budget.

Cache row pointers only while the display file stays put. PRINT is easier when the ROM owns placement, formatting and scrolling. Direct screen codes give a game precise ownership, but transfer charset, memory and refresh responsibilities to it. A trusted fast path could omit some checks after validation; measure that saving against the risk of destroying a newline. A graphics board, custom ROM or high-resolution display trick is a separate configuration, not a stock pixel backend hidden behind the same API.

## Verification

Released Asm198x 0.0.71 and Emu198x 0.41.0 execute three builds on each target. Every call has a nonzero acceptance/rejection marker and a final completion byte. Independent models check the selected allocations and request outcomes; every captured PET/Aquarius frame pixel, including the border, is compared against the local stock font. Sinclair comparisons cover every pixel in the owned 32×3 or 32×22 cell rectangle after one global frame-padding alignment. Firmware, tool, source, image and observed-memory hashes are recorded. No firmware bytes are distributed.

Completed wrong-stride controls fail both destination and pixel checks. Completed unsafe-count controls on PET/Aquarius bypass the horizontal bound; the Sinclair control bypasses the source-token guard instead (the newline preflight independently prevents a count-only overflow). Both are intentionally faulty builds, not unfinished executions mistaken for rejected calls. Retained CI verifies source bindings, independent destinations, markers and hashes; it does not rerun proprietary firmware or regenerate the font-pixel oracle.

```sh
make -C commodore-pet/patterns/assembly/rendering/fixed-characters
python3 scripts/verify-fixed-characters.py --native /path/to/native-tools --assembler /path/to/asm198x
python3 scripts/check-fixed-characters.py
python3 -m unittest discover -s scripts -p test_fixed_characters.py -v
```

This establishes those emulator/configuration observations, not original-hardware timing, stock-OS loading for PET/Aquarius, live raster safety or a promise that every ROM revision has identical glyph pictures. The originals in this repository are MIT licensed. Native screenshots were captured by Code198x from these callers; character designs remain the respective manufacturers' work. Their role is to explain the selected machine's actual output.

## Sources

- Sinclair, *ZX81 BASIC Programming*, display/character-set appendices and machine-code section: ROM characters, display file, USR and SLOW/FAST. [Manufacturer manual](https://zxnext.zx-pk.ru/manuals/ZX81_Manual.pdf).
- Bob Maunder, *The ZX80 Companion*, 2nd edition, chapter 4 (display-file construction and machine-code calls). Third-party book; its character-code tables reproduce Sinclair material by permission. [Archive record](https://archive.org/details/the-zx80-companion).
- *PET-CBM Personal Computer Guide* (McGraw-Hill, 1980), display memory and screen codes. Third-party reference, not a Commodore manual. The local stock character ROM is the primary witness for the captured shapes.
- Mattel Aquarius character ROM and native two-plane execution. Martin van der Steenoven's [Aquarius technical pages](https://www.vdsteenoven.com/aquarius/) are a community transcription/secondary reference for the memory map; not relabelled as a Mattel publication.
- Don Thomasson, *The Ins and Outs of the TS1000 & ZX81* (1983), pp. 36–40, software display generation and newline hazards. ZX81/TS1000 only; not cited for ZX80 hardware.
