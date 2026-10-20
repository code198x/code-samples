# Fixed-width bitmap text at any pixel position

Include one CPU text component and the machine's existing span backend, reserve
T and BP, supply a readable font and string, then call `text_char` or
`text_string`. The component draws directly into your bitmap. It owns no screen,
font allocation, game loop, OS service or interrupt handler.

The four complete `rendering/bitmap-text/demo.asm` callers initialise the exact
video configuration, draw `PIXEL TEXT` at (21,37) with an ordinary direct call,
then enter a diagnostic mailbox. A game needs the setup and call, not the mailbox.

## Targets and inclusion

| Machine | Text include | Backend |
| --- | --- | --- |
| Spectrum 48K, 256×192 | z80.inc | unchanged drawing-foundations/z80.inc and existing pixel_addr helper |
| BBC Micro MODE 4, 320×256 | 6502.inc | unchanged drawing-foundations/6502.inc and 512-byte bitmap_lo/hi scanline tables |
| Dragon 32 PMODE 4, 256×192 at $0600 | 6809.inc | unchanged drawing-foundations/6809.inc |
| CPC 464 MODE 1, 320×200 at $C000 | z80.inc | unchanged geometry/cpc.inc, packed four-pen spans |

Define `T` at 96 private RAM bytes and `BP` at a separate 48 bytes. BP must be
zero page on 6502; T need not be. The text temporarily uses BP+46/47 for indirect
source reads on 6502, with no live pointer carried across a backend call.
Define `TEXT_WIDTH`, `TEXT_HEIGHT`, `TEXT_PEN_MAX` and `TEXT_PACKED`: mono targets
use PEN_MAX=1 and PACKED=0, CPC uses 3 and 1. Include both components exactly
once; the complete caller shows syntax, addressing helper/table and video setup.

Scratch needs no initialisation. Public inputs do. Keep code, font, string,
contexts, stack and bitmap allocations distinct. The CPU source is shared only
where the ABI actually agrees; these targets still require their own backend,
mode and execution evidence. An unqualified backend does not acquire working
text support by sharing a CPU.

## Calling contract

The origin is the glyph cell's **top left**, not a typographic baseline. X points
right, Y down. Every glyph is eight rows of eight bits, bit 7 leftmost, and advances
X by eight pixels. The supplied diagnostic design draws five columns across seven
rows inside that cell; the cell and advance are still 8×8.

| T offset | Input/output |
| --- | --- |
| 0,2 | Signed 16-bit X,Y, each −512..511 |
| 4 | Word: first byte of contiguous font rows |
| 6 | Word: counted string address; ignored by text_char |
| 8 | Byte: string length 0..255; ignored by text_char |
| 9 | Byte: character code for text_char; ignored by text_string |
| 10 | Byte: first character code in font |
| 11 | Word: font glyph count, 1..256; first+count ≤256 |
| 13 | Byte: fallback character code, which must exist in the font |
| 14 | Byte: 0 transparent, 1 opaque |
| 15,16 | Bytes: foreground and background pens; both must be in the target's range |
| 17 | Output: 1 accepted, 0 rejected |
| 18,20,22,24 | Word scissor left,top,right,bottom; right/bottom exclusive |
| 26 | Output word: next X after logical advance |
| 28,29 | Output bytes: codes consumed, fallback substitutions |
| 30 | Output word: backend span calls |
| 32 | Output 32-bit destination-byte writes |
| 36–95 | Private scratch |

Words and the 32-bit counter use native order: little-endian on 6502/Z80,
big-endian on 6809. `text_char` consumes exactly one code; `text_string` consumes
the supplied length, without scanning for a terminator. A zero byte in the string
is a code, not an end marker. Newlines, wrapping and paragraph layout are not
implemented. An empty string is accepted with no source reads or drawing, after
validating its declaration.

Font storage is `count*8` bytes. Lookup is `(code-first)*8 + row`. Unsupported
codes use the declared fallback and increase the substitution count, including
when clipped away. There is no implicit case conversion. The optional original
font covers ASCII 32..95 (uppercase, digits and symbols); use another contiguous
font/range if your project needs lowercase or another encoding.

The scissor must be nonempty and inside the named physical bitmap. A valid string
may be partly or completely clipped, still consuming all codes and returning
`nextX = inputX + 8*length`. Rejection preserves the original X as nextX and
returns zero consumed/substitutions/calls/writes. Public inputs 0–16 and 18–25
survive every call. For the allowed origin/length range, final X fits signed
16-bit (largest 2551); it is not truncated back to a byte.

Invalid origin, mode, pen, font range, fallback, scissor or a 16-bit source/font
end that would pass $10000 rejects before destination writes. An allocation
ending exactly at $10000 is representable by its declaration. This arithmetic
check is **not a CPU mapping or ownership sandbox**: the caller must supply the
whole readable allocation, keep banks stable, and exclude aliasing with the
bitmap, contexts, stack and code being executed. The routines cannot validate
arbitrary ROM/RAM/OS mappings. Both pen inputs must be valid even in transparent
mode; background is then not drawn.

## What opaque and transparent mean

For each font bit 1, write the foreground pen. With transparent text, bit 0
leaves the destination alone. With opaque text, bit 0 writes background. A space
therefore advances without changing pixels in transparent mode and paints its
8×8 background cell in opaque mode. Mono pens are stored bits 0/1; CPC pens are
indices 0..3 whose displayed colours come from the caller's palette. Spectrum
attributes are separate and untouched. Text does not add XOR behaviour to these
two modes.

The implementation emits maximal foreground runs through `bp_hspan`. An opaque
row first paints an eight-pixel background span, then its foreground runs. The
backend already owns clipping-free address calculation, edge masks, partial-byte
preservation and CPC packing; none of that renderer code is cloned into text.
The text intersects every run with its scissor before passing it to the backend.

This is a clear composable baseline, not a fast masked-glyph blitter. Opaque
foreground pixels are written after their background, so some destination bytes
are touched twice. The existing masked sprite paths show KEEP/image composition
that can combine those operations. Shift at draw time reduces asset storage but
adds work; pre-shifted eight-phase glyphs trade a larger font for simpler draws.
An eight-pixel glyph can straddle two eight-bit mono bytes, or three four-pixel
CPC bytes. Word-aligned Amiga masks have different costs and ownership again.

## Translation, phase and advance

Glyph-local (3,5) at cell origin (21,37) becomes destination (24,42). Translate
first, then clip against the display/scissor. On a monochrome target, `24 div 8`
chooses a byte column and `24 mod 8` its bit. CPC MODE 1 divides by four instead.
A second glyph begins at X=29, even if the first glyph is a blank or missing code.
A cell's left edge, its visible ink and its advance are different quantities.

For our ten-code `PIXEL TEXT` workload, native counters report:

| Target | Transparent at X=24 / X=31 | Opaque at X=24 / X=31 |
| --- | ---: | ---: |
| Spectrum/BBC/Dragon | 77 / 77 byte writes | 157 / 237 byte writes |
| CPC | 90 / 84 byte writes | 250 / 324 byte writes |

Foreground run count is 77; opaque adds 80 background spans. The font's blank
columns and gaps matter: an off-grid cell does not always increase foreground
writes. These are observed byte writes, not cycles, timings or a frame-budget
claim. Layout, glyph shape and pen semantics belong in a meaningful comparison.

## Resource costs and integration

| Target | Text component | Backend | Font sample | Contexts | Extra table/helper |
| --- | ---: | ---: | ---: | ---: | --- |
| Spectrum | 2288 bytes | 533 | 512 | 96+48 RAM | existing pixel_addr additional |
| BBC | 2456 bytes | 526 | 512 | 96+48 RAM | 512-byte scanline tables |
| Dragon | 2058 bytes | 470 | 512 | 96+48 RAM | none |
| CPC | 2268 bytes | 578 | 512 | 96+48 RAM | none |

Measured with Asm198x 0.0.71. Excludes reset caller, string, display and stack.
Font size is a choice, not a compulsory 512-byte allocation: a digits-only ten-
glyph font costs 80 bytes, while 256 glyphs cost 2048. A sparse encoding needs a
lookup layer or remapping rather than pretending its holes are free.

Clobbers: 6502 A/X/Y/flags (decimal mode clear); Z80 AF/BC/DE/HL/flags; 6809
D/X/Y/CC (U/DP survive). Reserve a conservative 64-byte stack budget plus other
calls/interrupts. T and BP are non-re-entrant. No call changes interrupt state,
waits for a frame, negotiates an OS, allocates memory or synchronises video.
Keep source and destination stable for the whole call. Reset fixtures own the
machine; stock-OS loading, coexistence, live tearing and hardware timing need
separate integration/qualification.

## Reproduce and inspect

```sh
make -C sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-text ASM198X=/path/to/asm198x
python3 scripts/verify-bitmap-text.py --native /path/to/native-binaries --assembler /path/to/asm198x
python3 scripts/check-bitmap-text.py
python3 -m unittest discover -s scripts -p test_bitmap_text.py -v
```

Exact released binaries/archive hashes and producer records are in toolchain.json
(Asm198x 0.0.71, Emu198x 0.39.0). No manufacturer firmware is distributed. Builds
write original `fixture.bin`; emulator startup uses --rom on Spectrum/Dragon/CPC,
--mos on BBC. Fresh observations go to build/verification; reviewed files under
verification are never automatically replaced.

The four native runs complete **316 calls**: 76 each on Spectrum/BBC/Dragon, 88
on CPC. Every call compares the complete bitmap allocation, neighbours/guards,
unchanged font/string allocations, public fields, acceptance, final X, consumed/
fallback counts and span/write counts. Selected entire native frames match an
independent composition. Font bits are interpreted per pixel in the oracle;
packing/composition reuse the separately maintained independent bitmap model.
Native cases cover every horizontal phase, negative/clipped/last-pixel origins,
all foreground/background pairs, empty/255-code strings, first/last/missing
codes, a complete 256-glyph declaration, rejected declarations and byte-wrap
bounds. Eight deliberately faulty executing builds (wrong glyph bit and wrong
advance on each target) complete accepted draws and fail both memory and native
picture checks. CI rechecks retained observations and eight corruption/missing-
evidence controls; retained replay is not fresh native execution.

## Sources and rights

The font JSON and assembled font rows are original Code198x diagnostic data,
MIT licensed, authored for this component rather than extracted from firmware.
`font.json` is the readable glyph-row source; the three font includes encode it
for the respective assembler dialects. The complete native run compares those
assembled bytes with the declared rows. A project may replace the sample font;
check the replacement's own licence and credit.

The hardware sources and exact layout contracts are retained in
../drawing-foundations/README.md and ../geometry/README.md. Existing fixed-grid
Spectrum printing and positioned/masked sprite entries remain alternatives;
they are not silently reclassified as this text API. Proportional measurement,
wrapping, scaling and Amiga-native text variants remain separate work.
