# Draw regions into a character screen or Electron bitmap

Draw a room, replace a changed tile or reveal a strip of scenery. The map holds logical byte IDs. The renderer translates them into the display's native representation without making the game's rules depend on screen bytes.

| Machine | Selected configuration | One cell writes |
| --- | --- | --- |
| Electron | MODE 4, 320×256 logical pixels, 40×32 cells | Eight bitmap bytes |
| PET | 40 columns × 25 rows, fixed character ROM | One screen code |
| VIC-20 | PAL, unexpanded, 22×23, RAM characters, high resolution | One screen code and one colour nibble |
| Aquarius | Unexpanded, 40×25, fixed character ROM | One screen code and one foreground/background byte |

## Include, initialise, call

Define `NR`, `MAP`, `MAP_W`, `MAP_H`, `TILE_COUNT`, `SCREEN`, `SCREEN_COLS` and `SCREEN_ROWS` before including the character routine once. Define `glyph_codes` as one native screen code per logical ID. For colour targets supply `COLOUR` and `tile_colours` with the same ID indexing. The 6502 variant uses `HAS_COLOUR=0` for PET or `1` for VIC-20; the Z80 variant writes both Aquarius planes. These are compile-time layout choices. They do not detect a display mode at runtime.

Reserve all 32 bytes of `NR` as private writable context. It must be in zero page on 6502; Aquarius uses ordinary RAM. No scratch initialisation call is needed. Set unsigned bytes +0..5 to source column, source row, destination column, destination row, width and height; call `region_draw`. Byte +6 returns one on completion or zero on rejection. All six request bytes survive; scratch +6..31 may change. Contexts are not re-entrant.

Zero sizes, invalid starts, source/destination overruns and IDs outside the descriptor table are rejected before any destination writes. Every selected ID is checked in a preflight before painting; bounds compare extents against remaining space rather than allowing addition to wrap. This variant rejects rather than clips. Keep map, request, descriptors, assets and display configuration stable throughout the call. Source/context/descriptors must not alias the overwritten destinations.

The 6502 code clobbers A/X/Y/flags and needs decimal mode clear. Its source width is 1–128; source height is 1–255. Character dimensions and tile count must fit nonzero unsigned bytes, with screen width at most 128 for this variant. Four stack bytes cover the direct JSR and paint helper. The Aquarius Z80 implementation clobbers AF/BC/DE/HL/flags; map and screen dimensions and tile count are nonzero bytes. Six stack bytes cover the direct CALL, paint helper and saved pointer. Neither changes interrupt state. Allow additional stack and preserved state for your own caller and interrupts.

Your caller owns memory allocations, register preservation in interrupts, video setup, colour interpretation and OS coexistence. The routine does not load assets, change modes, disable interrupts, arbitrate with an OS or fit a frame budget automatically. Four glyph-code bytes plus four colour bytes describe four tiles in the colour examples. Descriptor encoding and accessible allocation sizes are caller obligations, not properties a pointer can validate.

The complete machine `demo.asm` callers keep reset setup and test cases separate from the reusable include. Their fixed addresses are working allocations to adapt, not a universal game memory layout. `Makefile` uses the released Asm198x tool; it builds original reset fixtures, not stock-OS executables.

## Electron: reuse the bitmap renderer

Electron includes the existing `bitmap-regions/6502.inc` unchanged. Supply `TILES`, `CELL_BYTES=1`, `X_STEP=8`, screen dimensions and `bitmap_lo`/`bitmap_hi` instead of character descriptors. Its four original eight-byte pictures are copied to $0800 by the caller. ID zero is an opaque blank picture, not a skip instruction.

MODE 4 occupies $5800–$7FFF. Eight scanlines of each 8×8 cell are consecutive; the next cell is eight bytes away, and the next character row is 320 bytes away. For pixel scanline y the address tables contain `$5800 + (y/8)*320 + (y mod 8)`. Two 256-byte tables cost 512 bytes. A 5×3 patch copies 120 picture bytes, plus ID preflight and address work. Native output duplicates pixels horizontally into a 640×256 framebuffer; game coordinates remain 320×256.

The original OS replacement sets ULA mode, base and palette directly. It establishes this layout, not MOS loading or hardware scroll-wrap support. The memory observer checks all 10,240 bitmap bytes plus two separate reserved RAM guard blocks at $57E0 and $57F0; there is no writable guard beyond $7FFF because ROM starts there. All of these guard locations are explicit, not an assertion of adjacent writable RAM on every side.

## PET: screen codes are not printable character codes

The routine writes $8000–$83E7, one byte per displayed cell. Its allocated 1,024-byte screen span includes the unchanged 24-byte tail. A logical ID selects a `glyph_codes` entry, whose image comes from the installed character ROM. Set that descriptor table to the glyphs your actual ROM provides. Printing through the editor and directly writing a screen code are different interfaces.

PET has no per-cell colour RAM in this configuration. `HAS_COLOUR=0` omits colour writes. The capture's green foreground is the emulator's monochrome display treatment. Choose graphics from the installed character set or build larger shapes from several cells; this routine does not make the stock character ROM writable. The original driver disables the cursor; it does not demonstrate coexistence with the editor.

## VIC-20: spend RAM on your own pictures

The unexpanded PAL caller uses 22×23 cells at $1E00 and their colour nibbles at $9600. It checks each full 512-byte allocation, including the six unused tail cells. Four high-resolution characters take 32 bytes at $1000; selecting that RAM character base is separate from region drawing. The screen and character RAM consume part of the same small main-RAM allocation.

`glyph_codes` is deliberately non-identity: IDs 0,1,2,3 select codes 0,3,1,2. `tile_colours` supplies high-resolution colours 1,1,2,5. Keep colour bit 3 clear for this path; enabling multicolour changes pixel interpretation. Physical colour RAM stores four bits, so readbacks and guards compare those bits explicitly. Draws are opaque and share a background colour; multicolour characters, character animation and raster effects require their own policies.

## Aquarius: two screen planes and a shared border cell

The character span is $3000–$33FF and the matching colour span $3400–$37FF. The active 40×25 display uses 1,000 entries from each; the remaining 24 bytes stay unchanged. The colour byte's high nibble selects foreground and low nibble background. Four descriptors here use $F0,$F0,$10,$80. A 5×3 patch writes fifteen character bytes and fifteen colour bytes.

The surround repeats cell zero and its attribute. Redrawing cell (0,0) can therefore change the border too. This caller leaves that cell as a blank black-background descriptor. BASIC normally uses rows 1–24; direct hardware drawing can use all 25. A game sharing BASIC/editor ownership needs an explicit agreement about that first row and scrolling.

Glyphs come from a fixed character ROM; this component cannot redefine them in software. Set `glyph_codes` for the installed font. The unexpanded caller keeps context, map, results, guards and stack in the mapped $3800–$3FFF RAM, not a presumed expansion.

## Verification and limits

All four original reset diagnostics execute 18 normal calls each: three accepted draws and fifteen map/bounds/ID rejections. Every rejection is also executed separately after the same three accepted draws: 60 isolated rejection runs. Complete destination allocations, unused tails, colour bits and both mapped guard blocks are compared against independent models. Every native capture pixel is compared with a separate composition, including borders and Electron scaling.

Both wrong-layout and unsafe-destination controls complete on each machine and fail the same memory checks; wrong-layout captures also fail the pixel oracle. Nonzero per-call markers and a final completion byte distinguish a rejected request from code that never ran.

PET and Aquarius are supplied with **original diagnostic font ROMs** by the fixture builder. Those fonts isolate glyph selection for repeatable pixel checks. They are not stock manufacturer fonts and do not establish software-redefinable glyphs on those machines. VIC-20 uploads its original glyphs through RAM as a real game can. No manufacturer firmware is distributed.

Released Emu198x 0.39.0 and Asm198x 0.0.71 qualify the named configurations. These results do not establish stock-OS loading, original-hardware timing, tear-free updates, interrupt coexistence or throughput. Copy counts are storage/work counts, not measured cycle costs. Cached row pointers and wider spans can reduce address work. Clipping, masks, timed queues and trusted-map variants change the contract and should be measured separately.

```sh
make -C commodore-vic-20/patterns/assembly/rendering/tile-region
python3 scripts/verify-character-regions.py --native /path/to/emulators --assembler /path/to/asm198x
python3 scripts/check-character-regions.py
python3 -m unittest discover -s scripts -p test_character_regions.py -v
```

## Sources

- *The Advanced User Guide for the Acorn Electron*, chapter 14: ULA screen address, mode and palette registers; screen organisation chapters for MODE 4.
- *PET/CBM Personal Computer Guide* (McGraw-Hill, 1980): display memory, screen codes and character generator. The executed configuration is the emulator's 40-column PET; no 80-column result is transferred.
- Commodore, *VIC-20 Programmer's Reference Guide*, video register descriptions and user-defined characters: screen/character bases, dimensions and colour RAM. The selected driver uses high-resolution characters and PAL placement.
- [vdSteenoven's Aquarius technical pages](https://www.vdsteenoven.com/aquarius/), memory allocation and screen/colour discussion. This is a community transcription of Mattel/Radofin material, not a manufacturer manual. Captured output and full memory checks independently establish the selected emulator configuration; original service documentation remains a separate source need.
