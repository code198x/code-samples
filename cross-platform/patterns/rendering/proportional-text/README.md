# Proportional labels and word-aware panels

An I needs less room than a W. This selectable layout component sums per-glyph
widths plus letter spacing, uses that sum for alignment and word boundaries,
and places each glyph through the existing `text_char` and native span backend.
Choose one of text-layout, word-wrap or proportional-text: they export the same
`layout_measure`, `layout_line`, `layout_block` labels and cannot be included together.
The original fixed-width variants remain unchanged.

## Include and call

Use the complete `rendering/proportional-text/demo.asm` caller for Spectrum 48K,
BBC Micro MODE 4, Dragon 32 PMODE 4 or CPC 464 MODE 1. Include bitmap-text once,
then this CPU component and the existing qualified backend/helper/tables.
Reserve **TL=80**, **T=96**, **BP=48** separate bytes. BP is zero-page on 6502.
The existing fixed variants need only TL=64; reserve the larger allocation when
switching to this component. Keep code, contexts, stack, source, glyph rows,
metric table and bitmap distinct. Scratch needs no initialisation.

Initialise T's font pointer/range/count/fallback, mode and pens as in caller.inc.
Supply TL's existing panel inputs, then the additional metrics and spacing:

| TL offset | Input |
| --- | --- |
| 0,2 | Unsigned words: panel left/top |
| 4,6 | Words: width/height, at least 8×8 and wholly inside the physical bitmap |
| 8 | Alignment byte: 0 left, 1 centre, 2 right |
| 9 | Pitch byte: 8..255 scanlines between row origins |
| 10 | Word counted source pointer |
| 12 | Byte length 0..255; zero bytes are data, not terminators |
| 64 | Word metric-table pointer, one width byte for every declared font glyph |
| 66 | Byte extra letter spacing, 0..2 |

Words/counters are little-endian on Z80/6502, big-endian on 6809. TL+0..12 and
64..66 survive. TL+17,60..63,67,78..79 are reserved; other private bytes may change.
Outputs retain the fixed-layout offsets: accepted13, consumed14, logical rows15,
last-row glyph count16, word maximum advance18, first originX20, last endX22,
last originY24, word span count26, 32-bit destination-byte writes28.

Every width must be 1..8, and width+spacing must be <=8. The complete metric
table is validated before drawing, even for empty input. Source/font/table ends
may equal $10000 but must not exceed it. This checks arithmetic, not arbitrary
CPU memory mapping or allocation ownership. Caller supplies readable stable
allocations, font/range/pen configuration and mappings for the entire call.
Unsupported codes resolve to T's fallback before looking up their width. The
font still has eight contiguous row bytes per glyph, bit7 leftmost. Keep its
ink inside the declared width; smaller widths deliberately crop it. Blank space
has a width too. There are no bearings, descenders, kerning pairs or shaping.
Top is an eight-row cell origin, not a typographic baseline.

`layout_measure` now reads the counted source, fallback and table: the count
alone cannot measure proportional text. Initialise all inputs as for a draw.
It validates the declaration and returns only accepted=1 and the total advance
at TL+18, zeroing other outputs. Like line mode, LF is a glyph/fallback there.
A measured line can exceed panel width; `layout_line` rejects an oversized line.
Never use the old count-only measurement contract with this variant.

Block mode fits the next glyph's complete advance, then uses the same explicit
word policy as word-wrap. LF breaks; an immediately following space can become
a break; otherwise backtrack to the last space after the row's first byte.
Omit only the selected separator, preserve other spaces, and split overlong
words when no eligible boundary exists. Every row consumes input; a glyph that
cannot fit rejects rather than looping. Consecutive LFs keep interior empty
rows; a final LF adds no trailing row. Empty text has no rows.

The full planning pass rejects too-tall/invalid requests with zero public
outputs and no bitmap writes. The second pass replans and draws. This guarantee
requires stable source, font, metrics and configuration, with no aliases into
scratch or destination. T/BP, including their scissor, belong to the component
until it returns. It clips each glyph to its allocated advance. Opaque mode
clears that advance's eight rows, including letter spacing; transparent zero
bits leave the destination alone. Neither clears unused panel space or blank
lines. Clear your panel before replacing longer text.

## Make it your own

The maintained customise.asm changes width176→104, centre→right alignment,
pitch12→16, message33→44 bytes and letter spacing1→2. The extra spacing changes
advance sums and can change wrapping without changing glyph shape. Edit the
counted message and MESSAGE_LENGTH together. Replace a glyph's eight rows and
its width together, respecting width+spacing<=8. Width describes logical ink
allocation, not a request to scale the bitmap.

The original MIT font is cropped from bitmap-text/font.json so its leftmost ink
starts at bit7. font.json retains the readable rows and 64 widths. A space has
width3. I has width3, W width5; with spacing1 six I glyphs advance24 pixels,
six W glyphs36. I! WIDE advances32; spacing2 makes it39. All include a final
spacing slot: alignment uses logical advances, not optical ink bounds.

Each target includes a deliberately wrong advance build and executed repair.
The faulty renderer still moves8 pixels after each letter while measurement
and wrapping use the table. I! WIDE therefore starts at the planned position
but spreads beyond its measured end. Restore the per-glyph advance; do not
compensate by changing the panel or centring formula. Broken fragments are
separate from the reusable include and normal download.

## Ownership, work and limits

Font rows still cost512 bytes; the matching 64-byte width table is additional.
TL grows16 bytes. T/BP and the display backend retain their existing sizes;
BBC retains its512-byte row tables and zero-page requirement. Native results
record assembled layout/text/backend sizes and actual span/write counts for
normal, custom and diagnostic workloads. A smaller advance may reduce painted
background pixels but changes byte phase and line breaks. The component also
validates a table, scans source for measurement, possibly rescans words, and
calls the baseline text renderer once per glyph. Destination writes are not
elapsed time. No speed or frame-budget claim follows from fitting more text.
Static labels can be measured/rendered once; pre-rendering trades assets for CPU.

Clobbers A/X/Y/flags on6502 (D must be clear), AF/BC/DE/HL/flags onZ80,
D/X/Y/CC on6809 (U/DP preserved). Reserve a conservative80-byte stack budget
plus caller/interrupt depth. Non-re-entrant; supplies no OS negotiation,
interrupt protection, banking, frame wait or display synchronisation. The
original reset fixtures own their machines. Evidence establishes the named
mode and reset path, not stock-OS loading, live tearing, hardware timing,
other machines or a commercial frame budget. Native captures preserve emulator
borders/sampling; they are not calibrated CRT aspect ratios.

## Reproduce

```
python3 scripts/verify-proportional-text.py --native /path/to/pinned/binaries --assembler /path/to/asm198x
python3 scripts/check-proportional-text.py
python3 -m unittest discover -s scripts -p test_proportional_text.py -v
```

Toolchain.json pins released Asm198x0.0.71 and Emu198x0.41.0 binaries, archive
hashes and producer identities. Native observations go to build/verification;
review before copying into verification. Retained replay is not fresh execution.
Checks compare independent advance/row expectations, full bitmap allocations,
CPC padding, guards, inputs/outputs, source/font/metric immutability and selected
whole native frames. Maintained wrong/fixed calls must complete and differ from
good pixels; repairs reproduce the positive fixture. Corruption controls must
fail even when altered artefacts are rehashed.

Hardware contracts and primary references remain in the unchanged bitmap-text,
drawing-foundations and geometry README files. This layer adds arithmetic and
layout, not another hardware addressing implementation. Maths for Games unit06
(integer division/remainders) and13 (local-to-screen translation) supply useful
connections. Scaling/rotation and typographic baseline/kerning support remain
separate work under docs#126.
