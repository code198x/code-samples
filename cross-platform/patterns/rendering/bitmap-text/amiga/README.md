# Amiga bitmap text with 32-bit source pointers

Include ../m68000.inc alongside the single-plane remaining-primitives/m68000.inc
backend, reserve T (96 even-aligned bytes) and BP (48 separate bytes), and supply
a readable font/string. The complete Amiga bitmap-text/demo.asm caller establishes
A500 PAL 320×256, points its Copper at one Chip RAM plane, then directly calls
text_string to draw PIXEL TEXT at (21,37). Its mailbox is diagnostic transport,
not a game loop. Scratch needs no initialisation; public fields do.

This port uses the same eight-row, high-bit-first glyph format and logical
character/advance rules as the other text components. **Its context layout is
different**, because fonts and strings have 32-bit pointers. Do not copy offsets
from the 16-bit-address components. All words/longwords are big-endian.

| T offset | Input / output |
| --- | --- |
| 0,2 | Signed origin X,Y, each −512..511 |
| 4 | Font pointer longword |
| 8 | Counted string pointer longword; ignored by text_char |
| 12 | String length byte 0..255; ignored by text_char |
| 13 | Single code byte for text_char |
| 14,15 | First code, fallback code bytes |
| 16 | Glyph-count word, 1..256; first+count ≤256 |
| 18 | Mode byte: 0 transparent, 1 opaque |
| 19,20 | Foreground/background stored-bit pens, each 0..1 |
| 21 | Output accepted 1 or rejected 0 |
| 22,24,26,28 | Scissor L,T,R,B words; right/bottom exclusive |
| 30 | Output signed word: next X |
| 32,33 | Output bytes: consumed codes, fallback substitutions |
| 34 | Output word: backend span calls |
| 36 | Output longword: destination-byte stores |
| 40–95 | Private scratch |

Call text_char or text_string. Text_char ignores string pointer/length;
text_string uses its supplied length, without scanning for NUL or interpreting
newlines. A zero byte is a code. Unsupported codes use the declared fallback,
which must exist in the contiguous font. There is no implicit case conversion.
Every code, including spaces, substitutes and fully clipped glyphs, advances X
by eight: nextX = startX + 8*consumed. Empty strings are accepted without source
reads/drawing after validating their declaration. Inputs 0–20 and 22–29 survive.

The origin is the cell's top-left corner, not a typographic baseline. The scissor
must be nonempty and inside the 320×256 physical plane. Glyph-local pixels are
translated before clipping. A valid fully offscreen label still succeeds and
advances. Bad coordinates, font declaration/fallback, mode, either pen, scissor
or pointer arithmetic reject before destination writes, with nextX=startX and
all output counters zero.

Pointers are stored as 32-bit values, but this 68000 contract accepts only
$000000–$FFFFFF and allocation ends no greater than $1000000. A last byte at
$FFFFFF is arithmetically allowed. This is **not** a RAM/ROM mapping or ownership
check: the whole allocation must actually be readable, stable and disjoint from
code, T/BP, stack and destination. Byte font/string reads may use odd addresses;
contexts and their word/long fields must be even-aligned. The verified default
font is in the original reset ROM; separate synthetic font/string buffers use
odd Chip RAM addresses. The original reset image also supplies a valid blank
glyph ending exactly at the physical address limit for a boundary test.

## Integration and costs

Define TEXT_WIDTH=320 and TEXT_HEIGHT=256 and the backend's PIXEL_WIDTH/HEIGHT
and BITMAP_BASE. This caller uses BP=$2000, T=$2200, plane=$10000, Copper=$4000.
No call allocates a font, changes interrupt enables, waits for a frame, owns an
OS service or synchronises the display. T/BP are non-re-entrant. Clobbers
D0–D7/A1/CCR; SR interrupt-mask bits survive. Reserve a conservative 64-byte stack
budget in addition to your other calls/IRQs. Do not race blitter or IRQ writes.
An AmigaOS loader/display needs its own ownership and integration work.

Transparent text sends maximal foreground runs through bp_hspan. Opaque text
first paints each clipped eight-pixel background row, then its foreground runs.
Zero foreground/background pens clear stored bits; one sets them. Palette and
plane ownership remain with the caller. Multiple bitplanes or pen replacement
need a deliberate adapter; they are not hidden in this one-plane API.

The component is 888 assembled bytes; the CPU span backend is 480. Contexts take
96+48 RAM bytes. The optional original 64-glyph font is 512 bytes (10 digits need
80; 256 contiguous glyphs need 2,048). Reset setup, stack, string, bitmap and the
72-byte Copper list are additional. The font is original Code198x MIT-licensed
sample data, not an extracted ROM font.

The ten-code PIXEL TEXT takes 77/77 stores transparent at X24/X31, or 157/237
opaque. Foreground uses 77 spans; opaque adds 80 background spans. These are
observed stores, not cycles or a frame-rate promise. A word/longword masked blit
could combine background and ink in fewer passes; pre-shifted phases spend font
space. Blitter text also needs edge masks, alignment, DMA ownership and completion
handling. Existing aligned Amiga region/sprite paths are linked comparisons,
not a general arbitrary-position text blitter supplied by this component.

## Qualification

81 calls completed using Asm198x 0.0.71 and native Emu198x 0.39.0, covering all
horizontal phases, pens, opaque/transparent operation, every clipping edge,
negative/fully offscreen origins, empty/255-code strings, fallback, 256-code
fonts, odd buffers, wide pointers and arithmetic ends at the 24-bit limit.
Every call checks full plane memory, guards, public inputs, source/font
preservation, acceptance, advance, consumption/substitution and work counts
against an independent logical pixel model. Selected complete native frames
match independently composed images. The Copper list must remain unchanged.

Wrong glyph-bit and advance executables each complete accepted calls and fail
both memory and image checks. Complete observations and exact source/tool
identities are retained; CI replays them with evidence-corruption failure tests.
This is the named original reset fixture, not stock Kickstart, physical hardware
timing or tear-free live coexistence qualification. No vendor firmware is shipped.

```sh
make -C commodore-amiga/patterns/assembly/rendering/bitmap-text ASM198X=/path/to/asm198x
python3 scripts/verify-amiga-bitmap-text.py --native /path/to/native-binaries --assembler /path/to/asm198x
python3 scripts/check-amiga-bitmap-text.py
python3 -m unittest discover -s scripts -p test_amiga_bitmap_text.py -v
```
