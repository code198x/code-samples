# Integer-enlarged bitmap glyphs

Turn each font pixel into a rectangle. SCALE_X=2 and SCALE_Y=2 make an 8×8
cell occupy 16×16 logical pixels; 3×2 gives 24×16. The original eight row bytes
are unchanged. This is runtime nearest-neighbour integer enlargement, not a
larger predesigned font or a request for a different display mode.

## Include, initialise, call

Use the complete `rendering/scaled-text/demo.asm` caller for Spectrum 48 K,
BBC Micro MODE 4, Dragon 32 PMODE 4 or CPC 464 MODE 1. Include this CPU component
**instead of** bitmap-text's CPU component. Both export text_char/text_string
and the same private aliases, so do not include both. Keep the existing native
span backend and its required helpers/tables. These callers still own the reset
and video configuration; a game supplies its own compatible setup.

The T allocation is still 96 bytes and BP is a separate 48 bytes (zero-page on
6502). The original input/output offsets remain:

| T offset | Input/output |
| --- | --- |
| 0,2 | Signed words: cell-origin X,Y, each−512..511 |
| 4 | Word: contiguous font-row address |
| 6 | Word: counted string address; ignored by text_char |
| 8 | Byte: string length 0..255; ignored by text_char |
| 9 | Byte: character code; ignored by text_string |
| 10 | Byte: first character in the font |
| 11 | Word: glyph count 1..256, first+count≤256 |
| 13 | Byte: fallback code, which must exist in the font |
| 14 | Byte: 0 transparent, 1 opaque |
| 15,16 | Foreground/background pen bytes; both must be valid |
| 17 | Output: 1 accepted, 0 rejected |
| 18,20,22,24 | Word scissor left/top/right/bottom; right/bottom exclusive |
| 26 | Output word: next X after logical advances |
| 28,29 | Outputs: consumed codes and fallback substitutions |
| 30 | Output word: native span calls |
| 32 | Output 32-bit destination-byte writes |
| 68,69 | **Additional inputs:** integer scale X,Y, each 1..4 |

Words and counters are little-endian on 6502/Z80, big-endian on 6809. Inputs 0..16,
18..25 and 68..69 survive. Other bytes are output/private scratch; scratch needs
no initialisation. Always set both scale bytes, even for 1×1. A caller written
for fixed text does not initialise these previously private bytes automatically.
See prepare.inc for the maintained font/pen/scissor/scale setup and direct call.

Font storage is still count×8 bytes, MSB leftmost, with eight consecutive rows
per glyph. Source is counted bytes, not a zero-terminated string. LF has no
special meaning; unsupported bytes, including zero when outside the declared
font, use the fallback. Our original MIT diagnostic font covers ASCII 32..95.
It is included from bitmap-text unchanged rather than copied from firmware.

text_char consumes one code. text_string consumes its declared length and
returns `nextX = X + length×8×scaleX`, including clipped, blank and fallback
codes. A 255-code string at X 511 and scaleX 4 ends at 8671, which fits the word
output. An empty string accepts after validating its declaration, with no
source reads or drawing. Rejection preserves the original X as nextX and zeroes
consumed/substitutions/calls/writes. Invalid scales, origin, pens, mode, font
range/fallback, scissor or source/font end arithmetic reject before any draw.
Allocations may end exactly at$10000; they must not pass it.

These checks do not validate arbitrary CPU mappings, permissions or aliases.
The caller owns readable, stable source/font allocations and keeps code,
contexts, stack and bitmap distinct throughout the call. No allocation or bank
switch is supplied. The four original reset fixtures are separate execution
qualifications, not evidence for every machine sharing their CPU.

## Which pixels are repeated?

For a destination-local pixel(dx,dy), read source pixel
`(dx div scaleX, dy div scaleY)`. A source pixel(sx,sy) occupies the half-open
rectangle `[sx×scaleX,(sx+1)×scaleX) × [sy×scaleY,(sy+1)×scaleY)` before adding
the cell's screen origin. The native code scales foreground run endpoints and
repeats each source row; the independent oracle samples destination pixels
using integer division. Both must produce the same complete image.

Clip after that translation. A partially visible glyph keeps its original
sampling phase; it does not restart its font at the clipping edge. Each native
span is intersected with the physical-screen scissor before calling the
existing backend. Spectrum attributes remain separately owned. CPC pens are
indices 0..3 packed into four logical pixels per byte; mono targets use 0/1.
BBC retains interleaved scanline tables and zero-page BP. Dragon retains its
linear bitmap and big-endian fields.

Transparent mode leaves zero bits alone. Opaque mode first fills each expanded
cell row with background, then overlays its foreground runs. It paints blank
cell columns and rows too. Neither mode clears unused text-panel space. Clear
the region you own before replacing a longer label.

Fully clipped cells skip the font-row/raster loop after resolving the code and
fallback. Their logical advance and consumed/substitution counts still apply.
This prevents long offscreen strings from needlessly expanding thousands of
invisible rows. The initial naive 255-code,4×4 Spectrum call was still advancing
at 1024 emulated frames and completed by 1152 with correct memory. The cell skip
completed the same independent result within a 128-frame observation. These are
coarse bounded fixture observations, not cycle counts, a speed ratio or a frame
budget. Retained records include the full large workload under the unchanged
1024-frame ceiling.

## Make it your own

Build customise.asm: change 2×2 to 3×2 and replace PIXEL TEXT with the original
four-byte BIG! label. The cell grows from 16×16 to 24×16; its source remains
8×8. Change MESSAGE_LENGTH with the message. Try 1×4 or 4×1 for deliberate tall
or wide cells; all sixteen scale pairs execute in the retained checks.

Use measured scaled advances before centring or right alignment. Existing
text-layout, word-wrap and proportional-text components assume eight-pixel
cells/row heights and are **not adapters for this renderer**. A scaled layout
would need to agree on both cell dimensions and advance; do not silently drop
this include beneath those wrappers. This tranche supplies direct glyph/string
calls. Wrapping, baselines, kerning, fractional resampling, shrinking, flipping
and rotation remain separate variants.

## A common wrong step

The deliberately wrong advance fragment retains an eight-pixel movement while
rendering 2×2 cells. WAVE therefore overlaps its neighbours; in opaque mode a
later background cell can erase part of the preceding letter. The faulty call
completes and matches its independent wrong-image expectation. Restore the
cached `8×scaleX` step, then verify the repaired full bitmap and nextX. Both
paths execute; the repaired fixture is byte-identical to the normal build.
Broken fragments live outside the reusable include and normal build.

## Cost and alternatives

No expanded font allocation is required: the sample remains 512 bytes. T 96 and
BP 48 are unchanged allocations; BBC's 512-byte row tables, helper code, bitmap,
source and stack are separate. Retained results record assembled component and
backend sizes. Reserve a conservative 64-byte stack budget plus caller/interrupt
depth. 6502 clobbers A/X/Y/flags and requires decimal mode clear; Z80 clobbers
AF/BC/DE/HL/flags;6809 clobbers D/X/Y/CC and preserves U/DP.

An opaque cell paints `(8×scaleX)×(8×scaleY)` background pixels, then its ink.
Doubling both factors quadruples that logical area. Horizontal enlargement
changes run width and byte crossings; vertical enlargement repeats spans and
background rows. Packed CPC and mono byte layouts can therefore have different
write counts for the same logical glyph. Counts include repeated writes to a
byte, not just unique touched addresses. They are drawing work, not elapsed time.
The one-glyph clipping fast path and validation also cost code and comparisons.

Keeping another pre-rendered size uses more asset storage but can avoid runtime
expansion. Pre-shifted or masked glyph blitters make different CPU/memory
trade-offs; a hardware character grid may need precomposed multi-cell glyphs or
another display path. None is supplied merely by this bitmap routine. Choose
for the actual workload and display interval; measure the whole game before
claiming that a large animated label fits a frame.

The component is non-re-entrant and owns T/BP until return. It does not set up
an OS, interrupts, banks, display synchronisation, a frame wait or a game loop.
Captures retain native borders and horizontal sampling. Logical 2×2 expansion
preserves each emulator raster's pixel proportions; it does not calibrate a CRT
or make non-square physical pixels square. Original hardware, stock-OS loading,
live tearing and other modes need separate checks.

## Reproduce and inspect

```
python3 scripts/verify-scaled-text.py --native /path/to/pinned/binaries --assembler /path/to/asm198x
python3 scripts/check-scaled-text.py
python3 -m unittest discover -s scripts -p test_scaled_text.py -v
```

The toolchain pins released Asm198x 0.0.71 and Emu198x 0.41.0 archives, binary hashes
and producer identities. Fresh observations go to build/verification; review
before retaining them under verification. The independent checks compare complete
bitmap allocations including CPC padding, neighbours, public fields, consumed/
fallback counts, logical nextX, span/byte-write counters, unchanged string/font
allocations and selected whole native frames. Cases include all sixteen scale
pairs, every mono bit phase, pens/modes, signed/partial/full clipping,255 codes,
256-glyph declarations, empty input, malformed declarations, customisation and
an executing fault/repair. Corruption controls reject rehashed bad evidence.
Retained replay is not fresh execution. The scaled evidence job is separate
from the existing near-ten-minute record job; existing family checks remain.

Hardware contracts and original references remain in bitmap-text,
drawing-foundations and geometry README files. Maths for Games unit 06 explains
integer division/remainders; unit 13 connects glyph-local and screen coordinates.
General transforms remain planned material, not an already authored lesson.
