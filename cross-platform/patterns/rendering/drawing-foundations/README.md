# Draw bits; change shared pictures

These are callable components, not an engine. Include one backend in your own
program, reserve its context and display memory, initialise the documented video
mode, then call the routine you need. `demo.asm` is a complete original reset
caller. Its mailbox only lets an external observer submit isolated test calls;
your game calls the routine directly and does not need that transport.

## Bitmap contract

Backends: Spectrum 48K (`z80.inc`), BBC Micro MODE 4 (`6502.inc`), Dragon 32
PMODE 4 at $0600 (`6809.inc`). Define `BP` at a private 48-byte RAM allocation;
the 6502 allocation must be in zero page. BBC additionally supplies
`PIXEL_WIDTH=320`, `PIXEL_HEIGHT=256` and the maintained caller's 256-entry
`bitmap_lo`/`bitmap_hi` tables. Spectrum includes its existing
`bitmap-addressing/bitmap-addressing.inc` after this include. No initialisation
of scratch is required. Establish the video mode and clear the bitmap separately.

| Offset | Field |
| --- | --- |
| 0, 2 | x0, y0, unsigned 16-bit words |
| 4, 6 | x1, y1, unsigned 16-bit **exclusive** ends |
| 8 | Operation: 0 set, 1 clear, 2 XOR |
| 9 | Output: 1 accepted, 0 rejected |
| 10 | Output: pixel read as 0 or 1; zero on other calls/rejection |
| 12–47 | Private scratch, including word destination-write count at 40 |

6502/Z80 words are little-endian; 6809 words are big-endian. Inputs 0–8 survive.
Call `bp_fill` or `bp_box` with all four coordinates. `bp_hspan` uses x0/x1/y0;
`bp_vspan` uses x0/y0/y1. `bp_pixel` and `bp_read` use x0/y0. Unused end fields
are ignored; set operation to zero for reads. All return through RTS/RET.

Coordinates start at the **top left**, with Y increasing downwards. Spectrum and
Dragon are 256×192; BBC is 320×256. Empty, reversed, invalid-operation and
out-of-bounds requests reject before writing, without clipping. A 1×1 outline
writes once; XOR outlines never toggle corners twice. A full-width right end of
256 or 320 is representable; it is not squeezed into an 8-bit coordinate.

The 6502 version destroys A/X/Y/flags and requires decimal mode clear. Z80 destroys
AF/BC/DE/HL/flags. 6809 destroys D/X/Y/CC, preserves U/DP. Reserve at least eight
stack bytes for these routines including their direct call, **plus** your other
calls and interrupts. The shared context is not re-entrant. None changes interrupt
state, installs an interrupt handler or coordinates another renderer.

BBC tables describe the actual scanline addresses, including the eight-scanline
character interleave. The table entries are trusted configuration, not an address
sandbox. Spectrum reuses `pixel_addr`, retaining its three-part interleave.
Dragon calculates `y*32 + x/8 + $0600`, spending instructions rather than a row
table. These kernels are qualified for these exact modes; packed colour pixels
need a different mask/colour contract.

### Why a span is worth having

For x=13, integer division gives byte column `13 div 8 = 1`; remainder gives
bit position `13 mod 8 = 5`. The bit is `128 >> 5 = 4`. Set uses OR, clear uses
AND with the inverted mask, XOR toggles, and read tests the masked byte. Do not
write the mask straight over a partial byte: its other pixels belong to someone
else.

A horizontal interval [5,13) covers eight pixels but touches **two bytes**. The
first mask is $07, the last is $F8. A filled box with y=[20,24) repeats those
masks on four rows: width 8, height 4, area 32 pixels, eight byte writes. These
kernels process bytes between the two edges, never eight separate plot calls per
interior byte. They still perform read/modify/write on full-byte interiors; a
specialised set/clear store path could avoid those reads. No universal speed win
is claimed for the checked version or its write-count instrumentation.

The native counters were compared against independently enumerated destination
bytes after every call. The 32×8 aligned fill writes 32 bytes; shifting it one
pixel writes 40. The whole-display clear writes 6,144 bytes on Spectrum/Dragon,
10,240 on BBC. A thin outline touches edge bytes rather than its whole area,
though this readable implementation still visits interior byte columns to skip
them. An edge-only iterator, unchecked inner entry, cached row pointers and
specialised store paths are useful faster variants with different size/contracts.

## Glyph contract

Include the machine's `custom-glyphs/glyphs.inc`, define `G` at a private 24-byte
context (zero page on VIC), and initialise the video configuration shown in its
caller. Public fields use little-endian words on all three machines.

| Offset | Field |
| --- | --- |
| 0 | Word: readable source address |
| 2, 3 | First slot, count (nonzero) |
| 4 | Character/tile code for selection |
| 5 | Word: linear screen cell index |
| 7 | Output: 1 accepted, 0 rejected |
| 8 | Word: destination bytes written by the call |

`glyph_init` blanks the owned font **and** name table; call once after setup,
not each frame. `glyph_install` uploads a contiguous range. `glyph_replace`
uploads one slot and ignores count. `glyph_select` changes one name entry, leaving
the font alone. Inputs 0–6 survive; status/cost reset even on rejected calls.
The source must be readable, long enough for the whole upload, and not overlap
context/destination. This low-level API does not validate arbitrary CPU mappings.
The returned counts are writes, not elapsed cycles or frame-budget measurements.

| Machine | Owned glyphs | Owned names | Per-glyph data | Special ownership |
| --- | --- | --- | --- | --- |
| Unexpanded PAL VIC-20 | $1000–$13FF, slots 0–127 | $1E00–$1FF9, 22×23 | 8 row bytes | $9005=$FC, $9002=$96, colour $9600; colour bit 3 clear |
| MSX1 Graphics I | VRAM $0000–$07FF, slots 0–255 | $1800–$1AFF, 32×24 | 8 row bytes | Data/control ports, address latch, grouped colours at $2000 |
| DMG unsigned BG tiles | VRAM $8000–$8FFF, slots 0–255 | $9800–$9BFF, 32×32 | 16 bytes, low/high planes per row | LCD off; LCDC selects unsigned tile addressing and map $9800 |

The VIC's 128 slots are **this allocation**, not a claim that the hardware only
has 128 character codes. Its 1 KB font budget leaves room for other data in an
unexpanded machine; a 256-code variant needs a larger reserved window and adapted
bounds/init. Keep code, source assets and screen out of the owned window.
Character RAM cannot be shared with BASIC or another display without agreement.
A VIC cell's colour bit 3 selects multicolour; these bytes are hi-res glyphs and
the original caller keeps that bit clear. Colour RAM is caller-owned, not written
by the component. Screen codes are not PETSCII.

MSX allows counts 1–255; use two calls to install all 256 slots. Read write ports
from BIOS addresses 7/6 as shown by the original MSX convention (7 is write base;
6 is read base); G+10 holds the **write data port**, G+11 its control port.
The ported routine never accesses VRAM through an invented CPU address.
Keep the latch exclusively owned for the entire call, by disabling or coordinating
VDP-using interrupts. The conservative OUT helper spaces accesses for standard
MSX1 clocks; no accelerated-CPU qualification is claimed. Graphics I shares one
foreground/background colour byte among eight slots: replacing bits is separate
from choosing colours. Init leaves colours, sprites and VDP registers to the
caller. It clobbers AF/BC/DE/HL/flags; reserve ten stack bytes plus other program
requirements. The other TMS machines need their own wired-port/video checks.

DMG calls reject if LCDC bit 7 is set. The caller waits until LY≥145 before turning
a running LCD off, then turns it back on after updating. This is a bulk screen-
construction baseline, not a live animation queue: repeatedly stopping the LCD
is not a recommended frame loop. Tiles use low-plane then high-plane bytes per
row; bit 7 is leftmost in both. A pixel value is `low_bit + 2*high_bit`, then BGP
maps it to a shade. The 32×32 map's last cell is off screen with zero scroll; the
visible screen is 20×18. Calls clobber AF/BC/DE/HL/flags and use at most eight
stack bytes including the caller. No CGB banking, signed $8800 tile indexing,
window/sprite renderer or live VRAM arbitration is implemented here.

VIC calls clobber A/X/Y/flags with decimal clear, reserve four stack bytes including
the direct JSR. None of the glyph routines changes banks, masks interrupts or
preserves a competing OS's state. All are non-re-entrant.

### Picture, code and placement are different things

Two cells containing code 1 share glyph 1. Uploading a new picture to slot 1
changes **both**. Selecting code 2 in one of those cells changes only that cell.
Changing eight row bytes costs eight font writes on VIC/MSX; changing a name costs
one. On MSX either operation also needs two control-port writes to select its
VRAM address. On DMG a glyph costs sixteen writes for its two planes. Count the
upload and the display-access policy, not just the asset size.

Row `10000001` is 128+1=129: light the first and last dots. VIC/MSX store one byte
per row; row r of slot n is at `base + n*8 + r`. DMG instead uses
`base + n*16 + r*2` for the low plane and the next byte for the high plane.
For local pixel (lx,ly) in screen cell (cx,cy), the visible pixel is
`(8*cx+lx, 8*cy+ly)`. That equation explains grid placement; it does not add
arbitrary-position or scaled text support to these APIs.

## Space budget

Measured from the assembled label ranges, excluding reset callers and ROM padding:

| Component | Code and inline masks | Extra row table | Context |
| --- | ---: | ---: | ---: |
| Spectrum pixels | 489 bytes, plus 44-byte existing address helpers | 0 | 48 RAM bytes |
| BBC pixels | 526 bytes | 512 bytes | 48 zero-page bytes |
| Dragon pixels | 470 bytes | 0 | 48 RAM bytes |
| VIC glyphs | 203 bytes | 0 | 24 zero-page bytes |
| MSX glyphs, including port helpers | 205 bytes | 0 | 24 RAM bytes |
| DMG glyphs | 186 bytes | 0 | 24 RAM bytes |

The three pixel figures include 24 bytes of masks. Glyph assets and display memory
are additional, as listed above. The DMG LCD-stop helper, machine setup, mailbox,
MSX diagnostic readback and original assets belong to the caller and are excluded.
`costs.json` records these assembled sizes; `build/selected.sym` allows inspection
using the pinned assembler. Different CPU instruction sizes make byte counts a
storage comparison, not a CPU-speed ranking.

## Build and verify

Use released Asm198x 0.0.71 and Emu198x 0.39.0 binaries, whose archive checksums,
executable identities and producer source locks are in `toolchain.json`.

```sh
make -C bbc-micro/patterns/assembly/rendering/pixels-and-boxes
python3 scripts/verify-drawing-foundations.py --native /path/to/emulators --assembler /path/to/asm198x
python3 scripts/check-drawing-foundations.py
python3 -m unittest discover -s scripts -p test_drawing_foundations.py -v
```

The execution script writes into each caller's `build/verification/`. The checked-
in `verification/` directories preserve the reviewed run for offline checks;
copy a new run only after reviewing it. Every selected mode is executed separately.
Memory is checked after each request, including isolated rejected requests; later
accepted draws cannot conceal damage. Bitmap checks cover all eight bit phases,
set/clear/XOR/read, spans, outlined/filled and one-pixel boxes, full extents,
empty/reversed/extreme coordinates and invalid operations. Glyph checks cover
first/last slots, zero/overflow counts, largest legal transfers, invalid cells,
shared replacements, single-cell changes, reset and LCD-on rejection.

Independent models compare complete bitmap or glyph/name allocations, nonzero
guards and selected **whole native framebuffers**, including borders/crops.
Completed wrong-mask builds on all three bitmap targets and wrong-slot builds on
all three glyph targets fail both memory and visible-output comparisons. The
retained check reruns the independent models, checks source/tool identities, and
fails on missing calls or altered observations. Unit controls also rehash corrupt
memory to prove a matching checksum cannot replace the independent model.

These are original reset-fixture results, not stock-OS coexistence, loading,
physical-machine timing, tear-free live updates or throughput measurements.
Palette RGB values and frame windows describe the pinned emulator release, not
universal analogue output. Pictures and glyph data are original Code198x work,
licensed MIT with the code. No manufacturer firmware or extracted game art is
included. Existing BASIC PLOT/DRAW/CIRCLE and UDG lessons remain useful alternatives;
this family supplies the smaller callable assembly pieces.

## Primary references

- Sinclair, *ZX Spectrum BASIC Programming* (1982), chapter 24, display file and
  attributes; the existing `pixel_addr` helper exposes the bitmap permutation.
- Bray, Dickens and Holmes, *The Advanced User Guide for the BBC Micro* (1983),
  screen memory/graphics and video hardware sections: MODE 4 starts at &5800,
  bit masks and character-row storage. This caller takes over the display; it
  does not call MOS graphics or change MOS workspaces to match.
- Duncan Smeed and Ian Sommerville, *Inside the Dragon* (1983), chapter 7,
  especially resolution graphics modes and implementing graphics: PMODE 4,
  SAM/VDG configuration and linear scanlines.
- Commodore, *VIC-20 Programmer's Reference Guide*, Working with Graphics /
  Character Memory / Programmable Characters, and Appendix E VIC registers
  ($9002/$9005 and the colour/multicolour control).
- ASCII/Microsoft, *MSX Technical Data Book*, BIOS bytes 6/7 fast-access VDP ports;
  Texas Instruments, *TMS9918A/TMS9928A/TMS9929A Video Display Processors Data
  Manual* (November 1982), Graphics I mode, pattern generator/name/colour tables
  and CPU–VDP access timing.
- Nintendo, *Game Boy Programming Manual*, version 1.1 (2000), VRAM/background
  pattern encoding and Programming Cautions §2.1.1 (LCD stop on early DMG).
