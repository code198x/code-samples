# Bitmap primitives: Atom, Electron, C64 and Amiga

Use the maintained include with a complete normal caller to draw a pixel, read
one stored bit, draw horizontal/vertical spans, fill a rectangle or outline it.
The component owns no display allocation, OS service or game loop. The caller
sets up the named mode, reserves BP, supplies the tables/constants and calls a
routine directly. Its following mailbox is only diagnostic transport.

## Interface and resources

| BP offset | Input / output |
| --- | --- |
| 0,2 | Unsigned native-endian x0,y0 words |
| 4,6 | Exclusive x1,y1 words |
| 8 | Operation 0 set, 1 clear, 2 XOR; read requires 0 |
| 9 | Accepted 1 or rejected 0 |
| 10 | Stored read bit 0/1; otherwise 0 |
| 11 | Ignored, preserved |
| 12–39,42–47 | Private scratch |
| 40 | Output word: destination-byte stores |

Call bp_pixel, bp_read, bp_hspan, bp_vspan, bp_fill or bp_box. Pixel/read ignore
both ends, hspan ignores y1, vspan ignores x1. Inputs 0–8 and 11 survive. Whole
requests must be ordered, nonempty and within the compiled display bounds.
Invalid requests reject before destination writes, with zero read/write outputs.
There is no silent clipping. Outlines visit a shared corner only once, so XOR
works even for a 1×1 box. Clear zeros stored bits, not a universal colour.

BP reserves 48 private bytes: zero page on 6502, even-aligned RAM on 68000.
6502 words are little-endian; 68000 words are big-endian. Scratch needs no
initialisation, public fields do. Keep code, stack, tables, bitmap and BP disjoint
and stable. These are non-re-entrant CPU routines. The 6502 requires decimal
mode off on entry (the caller uses CLD), clobbering A/X/Y/P. The 68000 clobbers
D0–D7/A1/CCR and leaves SR interrupt-mask bits unchanged. Reserve a conservative
64-byte stack budget beyond your other calls/IRQs.

6502 defines PIXEL_WIDTH/HEIGHT and PIXEL_BYTE_STEP (1 for Atom, 8 for Electron
and C64). Include 6502.inc once and the complete caller's bitmap_lo/hi row tables.
Use a two-digit zero-page constant for BP, such as $70: ACME retains literal
width, so $0070 cannot serve as its indirect zero-page operand even though the
value is equal. ACME and the qualified Asm198x build now produce identical
executables for all three maintained 6502 callers.

Those trusted tables must cover every compiled row. The 68000 defines
BITMAP_BASE and PIXEL_WIDTH/HEIGHT and includes m68000.inc once; this backend
specifically uses forty consecutive bytes per row. Changing one address does not
qualify a different mode, stride or machine.

## Actual display layouts

| Target | Logical display | Address of byte containing (x,y) |
| --- | --- | --- |
| Atom, full RAM model | 256×192 mono | $8000 + y*32 + (x div 8) |
| Electron MODE 4 | 320×256 mono | $5800 + (y div 8)*320 + (x div 8)*8 + (y mod 8) |
| C64 PAL standard HIRES bitmap | 320×200, stored bits | $2000 + (y div 8)*320 + (x div 8)*8 + (y mod 8) |
| A500 PAL single-plane low resolution | 320×256, stored bits | $10000 + y*40 + (x div 8) |

Bit 7 is leftmost: mask = 128 >> (x mod 8). The screen origin is top left, Y
downwards. A span masks its two edges and writes whole interior bytes; neighbours
survive. Electron and C64 share a useful byte-address formula but have different
video setup, colour, memory and timing responsibilities. They ran separately.

### Atom

The complete fixture selects the full RAM model, configures its 8255/VDG for
256×192 and owns $8000–$97FF (6,144 bytes). This is not evidence for the base
2.5 KiB machine's complete RAM configuration or for BBC/Electron timing.
The original combined reset image contains no Acorn firmware. A project that
keeps BASIC, uses a different video mode or allocates less graphics RAM needs
its own ownership/loading arrangement. Addresses at (13,20): $8281, mask $04.

### Electron

The caller selects MODE 4 with a fixed start at $5800 and owns the ULA/palette
and $5800–$7FFF bitmap. Adjacent horizontal bytes are eight addresses apart;
its 512-byte tables describe scanlines, not character rows. At (13,20), address
$5A8C, mask $04. Hardware scrolling or an OS-managed display can move the start;
these tables deliberately describe the fixed reset configuration only. Original
OS and zero-filled BASIC images replace manufacturer firmware for this fixture.
A source shared with BBC-style addressing does not establish BBC/Electron
contention, palette or frame-budget equivalence.

### C64

The reset caller owns CPU-port mapping ($00/$01), VIC bank selection through
CIA2, D011/D016/D018, sprites/interrupt policy and screen colours. It selects
bank 0, the $2000 bitmap and $0400 screen matrix. Each of the 1,000 screen bytes
is $10: its high nibble makes a stored one white, its low nibble a zero black.
In standard bitmap mode these colours come from screen RAM, not colour RAM.
The routine never edits those bytes. Set/clear/read therefore mean stored bits;
other cell colour pairs can make equal bits look different in adjacent cells.

The useful bitmap is 8,000 bytes, within an 8,192-byte reservation. All 192 tail
bytes and all 1,024 screen-matrix bytes are guarded in the native workload.
At (13,20), byte address $228C, mask $04. The diagnostic mailbox is $0800,
outside screen colours; BP is $70. Code is an original reset KERNAL, with
original zero-filled BASIC/character images. This is not a stock-KERNAL loader.
Multicolour bitmap and character/sprite paths are different representations,
not pen values added to this monochrome API.

### Amiga

A500 PAL uses one 320×256 plane at $10000–$127FF (10,240 bytes) in Chip RAM.
The 72-byte Copper list at $4000 establishes the fixed fetch/display windows,
plane pointer, zero modulos and black/white palette. It is checked unchanged.
At (13,20), byte address $10321, mask $04. The original reset ROM disables the
old DMA/interrupt users, then enables the selected display; it is not Kickstart
or an AmigaOS application. BP is even-aligned at $2000.

This CPU baseline writes byte masks, so arbitrary pixel edges work without
requiring word-aligned X. For more planes, call an appropriately owned plane
path or build a pen-aware adapter; no multi-plane pen replacement is supplied.
A CPU may access Fast RAM but display DMA cannot use it as an A500 bitplane.
A live OS game must acquire/release display and blitter ownership correctly.
Do not let the blitter or an IRQ writer race these read/modify/write operations.

## Work and alternatives

| Target | Backend code | Row tables | BP | Other display metadata |
| --- | ---: | ---: | ---: | --- |
| Atom | 528 bytes | 384 bytes | 48 bytes | none |
| Electron | 537 | 512 | 48 | caller-owned ULA/palette |
| C64 | 537 | 400 | 48 | 1,024-byte screen reservation |
| Amiga | 480 | 0 | 48 | 72-byte Copper list |

Counts exclude reset setup, stack and bitmap. The checked 32×8 fill makes
32 destination-byte stores at X24 and 40 at X25 on each backend. Full fills
write 6,144 / 10,240 / 8,000 / 10,240 bytes respectively; C64 tail storage is
preserved. These are stores, not elapsed cycles or a cross-machine ranking.
Row tables spend space to avoid address derivation. The 68000 baseline derives
one row address then walks byte masks; word/longword interiors could reduce CPU
stores when alignment permits. Blitter fills or copies add DMA setup, masks,
modulos, arbitration and a completion/ownership contract; existing Amiga native
region CPU/blitter examples show a bounded aligned case. They are not evidence
for arbitrary-position general blitter spans. Character-backed updates and
sprites may cost less for a game's actual presentation.

## Native qualification

Asm198x 0.0.71 and Emu198x 0.39.0 execute 169 Atom, 173 Electron, 173 C64 and
173 Amiga calls: 688 total, including the ordinary direct callers. Every call
compares complete bitmap allocation, guards, public inputs, acceptance/read and
store counts with an independent selected-pixel model. Tests include every
horizontal bit phase, all operations, tiny/full rectangles, last pixels,
interleaved row boundaries, rejected declarations and aligned/unaligned fills.
Selected whole native frames match independently composed images. C64 padding
and screen colours, and the Amiga Copper list, must remain unchanged.

Two completed accepted faulty executables per target (wrong masks and wrong
row addressing) fail both memory and picture comparisons. Source/tool identities,
complete observations and image hashes are retained, with corruption tests that
reject missing or rehashed bad evidence. CI replays those native records; it does
not claim fresh native execution of these four machines on Linux. Physical
hardware timing, stock-OS loading and tear-free display coexistence need separate
checks. Original code/drawings are MIT licensed; no vendor firmware is shipped.

```sh
python3 scripts/verify-remaining-primitives.py --native /path/to/native-binaries --assembler /path/to/asm198x
python3 scripts/check-remaining-primitives.py
python3 -m unittest discover -s scripts -p test_remaining_primitives.py -v
```

Hardware sources: Acornsoft, *Atomic Theory and Practice*, graphics/8255/VDG
sections; *Electron Advanced User Guide*, MODE 4 screen layout (printed p.240);
Commodore, *Commodore 64 Programmer's Reference Guide*, chapter 3, standard bitmap
mode and screen-colour nibbles (printed pp.122–125); *Amiga Hardware Reference
Manual*, chapter 3, forming a basic playfield and its summary. They establish the
hardware model; the observations qualify the explicitly named emulator fixtures.
