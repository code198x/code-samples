# Measure, align and wrap fixed-width bitmap text

Put a prompt in a panel without counting spaces by hand. Include one layout
component, the existing 8×8 bitmap-text component and its qualified span backend.
The complete callers show the result on Spectrum 48K, BBC MODE 4, Dragon PMODE 4
and CPC MODE 1. This is the first bounded layout tranche of docs issue #126;
proportional fonts, word wrapping and scaling remain separate work.

## Copy, initialise and call

Keep the relative directory structure when copying a complete caller, or adjust
its include paths to your project. `demo.asm` and `customise.asm` each include
`caller.inc`, which supplies video setup, a font, the renderer and the layout
component exactly once. `prepare.inc` is the ordinary call to adapt; the mailbox
is only verification transport. Run `make ASM198X=/path/to/asm198x` in a target's
`patterns/assembly/rendering/text-layout` directory. Load `build/positive/fixture.bin`
or `build/customise/fixture.bin` as the original reset image using the emulator's
`--rom` option, or `--mos` on BBC. This is not an OS-loadable application.

A game can omit the reset and mailbox, keep its own mode setup, reserve the
contexts, initialise the font/pen fields in T, and use `prepare.inc` as a direct
call. Define `TEXT_WIDTH`, `TEXT_HEIGHT`, `TEXT_PEN_MAX` and `TEXT_PACKED` as in the
existing bitmap-text caller. Preserve the machine's backend helper/table too.

Reserve **64 bytes at TL**, **96 at T** and **48 at BP**, separately from the
bitmap, source, font, code and stack. Only BP must be zero page on 6502. Layout
uses BP+46/47 briefly for indirect reads; it holds no live pointer there across a
renderer call. The unchanged text include defines the `t_*` aliases before the
layout include. The two components share T+95's comparison scratch deliberately.
Scratch needs no initialisation; public inputs do.

| TL offset | Meaning |
| --- | --- |
| 0, 2 | Unsigned words: rectangle left, top |
| 4, 6 | Unsigned words: rectangle width, height |
| 8 | Alignment: 0 left, 1 centre, 2 right |
| 9 | Line pitch in scanlines, 8..255 |
| 10 | Word: counted source address |
| 12 | Byte: source length, 0..255 |
| 13 | Output: 1 accepted, 0 rejected |
| 14 | Output: source bytes consumed, including line feeds |
| 15 | Output: logical line count, including interior empty lines |
| 16 | Output: glyph count on the last line |
| 18 | Output word: maximum logical line width, in pixels |
| 20 | Output word: first line origin X |
| 22, 24 | Output words: last line end X and origin Y |
| 26 | Output word: total backend span calls |
| 28 | Output 32-bit value: total destination-byte writes |
| 32..63 | Private scratch; offsets 17 and 58..63 are reserved |

Words/counters use native order: little-endian on 6502/Z80, big-endian on 6809.
Inputs 0..12 survive. T and BP are owned, clobbered workspaces: do not expect the
renderer inputs or last-call outputs to survive layout. Reinitialise T's font,
range, fallback, mode and pens before changing those choices. Layout supplies T's
source, count, position and scissor from TL; it does not preserve a former scissor.

Call `layout_measure` to return `8*length` at TL+18 and accepted=1. It reads no
string/font, ignores the rectangle and clears the other outputs. Even 255 codes
measure correctly as 2,040 pixels. It measures a single counted line: a line-feed
byte is a glyph slot for this entry point, just as it is for `layout_line`.

Call `layout_line` for one aligned line. All bytes are glyph codes; missing codes
use T's configured fallback. A line wider than the rectangle rejects before
bitmap writes. `layout_block` instead treats byte 10 as LF and wraps at character
boundaries to `width div 8` glyphs. It keeps spaces and can split a word. It does
not implement word wrapping, tabs, automatic case conversion or a text editor.
Byte zero remains a glyph code, not a terminator.

## Line breaks and rejection

Block planning consumes an LF after a full chunk with that chunk. An LF at the
start of a chunk makes an empty line; consecutive LFs retain interior empty
lines. A final LF ends its line without adding another trailing row. Empty input
has zero lines and zero coordinates/work counters. In line mode, empty input
likewise draws nothing. Empty input still validates the declaration.

The rectangle must fit the named physical bitmap and be at least 8×8. Both pens,
the text mode, font/range/fallback and arithmetic allocation bounds follow the
existing text contract. Source end may equal $10000 but cannot exceed it. Supply
real readable allocations and stable mappings: this arithmetic check cannot
validate arbitrary ROM/RAM, bank or OS ownership. A zero-length source is not read.

Every planned row must fit: `rowY + 8 <= top + height`. Pitch is the distance
between origins, not a blank-line count. For five rows at pitch 16, the footprint
is `(5-1)*16+8=72` scanlines. There is no sixth empty row after the final LF.

Layout checks the full declaration and plans every line before the first draw.
An oversized label, impossible rectangle, invalid font or too-tall block leaves
the destination untouched and returns accepted=0 with all documented outputs zero.
T/BP scratch may still change. Source/font/configuration must remain stable for
both passes; interrupt-driven mutation or aliasing with writable allocations
invalidates that guarantee. Non-re-entrant contexts cannot be shared by callers
or interrupt handlers without a separate ownership scheme.

Opaque mode paints each actual glyph cell's background. It does not clear unused
line space or blank lines. Clear an owned panel before replacing a longer message;
otherwise old letters can remain. Transparent text preserves zero-bit pixels.
The underlying font cell and advance remain 8×8: this does not measure visible
ink or provide proportional text.

## Maths and useful edits

Five codes need 40 pixels. In a 177-pixel rectangle, 137 remain. Centring uses
`left + floor(137/2)`, leaving the odd spare pixel on the right. At left 21 the
origin is 89; right alignment instead starts at 158. Check width before unsigned
subtraction: an overlong string must not wrap into a huge offset.

`customise.asm` narrows the panel from 176 to 104 pixels, selects right alignment,
changes pitch from 12 to 16 and supplies another counted message. Its five lines
fit in 80 scanlines. The word PANEL deliberately splits across the 13-column
boundary: this small component wraps characters, not words. Change the constants
and original message data together; keep `MESSAGE_LENGTH` equal to its byte count.
No extra font, bitmap or context allocation is required. A wider/longer message
can still increase renderer work or exceed the rectangle.

## Machine differences and costs

The shared calculation does not make the display paths interchangeable. Spectrum
retains its scanline address helper and separate attributes. BBC MODE 4 needs
512 bytes of row tables for its interleaved screen. Dragon PMODE 4 uses a linear
one-bit plane and big-endian public words. CPC MODE 1 packs four pen indices per
byte, has interleaved rows and preserves unused screen-allocation bytes. All mode,
CPU mapping, palette and interrupt setup remains caller-owned.

The layout component adds 1,628 code bytes on Z80, 1,867 on 6502, or 1,463 on
6809, measured with Asm198x 0.0.71. Its 64-byte context is additional to the
existing 96+48 bytes. The reused font is 512 bytes here. The old renderer/backends,
BBC tables, video allocation, caller, messages and stack are separate costs.
Reserve a conservative **80-byte stack budget**, plus caller/interrupt depth.
6502 requires decimal mode clear and clobbers A/X/Y/flags. Z80 clobbers
AF/BC/DE/HL/flags. 6809 clobbers D/X/Y/CC; U/DP survive. No entry changes interrupt
state, waits for a frame, configures video or acquires an OS resource.

Measurement is constant work on the counted length. Block layout makes two planning passes, with bounded lookahead at line ends.
The second pass interleaves planning and rendering after the complete first pass
has qualified the request. Drawing adds source/font reads and the unchanged
renderer's glyph/row/span work. A line call need not scan for LF.
Work counters report span calls and destination-byte writes, not CPU cycles or
elapsed time. Packed colour and byte phase change those counts. Use fixed labels
or cached positions when a cheaper static solution is enough; dynamic layout is
not a requirement for every frame. No original-hardware, live-tearing or frame-
budget claim follows from these reset configurations.

## Common mistakes and verification

`mistakes/` contains labelled wrong/fixed fragments. Omitting the final width
shift measures four pixels per code while the renderer still advances eight:
centred text moves right. Omitting the rectangle origin places the result relative
to screen zero; clipping can also remove letters. Each deliberately broken
executable completes its bounded call. Independent expected memory and full native
pixels match the predicted symptom and differ from the good result. Each repaired
fragment is assembled and executed too; its cartridge bytes equal the good caller.

`verify-text-layout.py` runs the four machines, checks whole bitmap allocations,
inputs/outputs, guards and unchanged source/font, and retains customisation,
fault and repair captures. `check-text-layout.py` recomputes all outcomes and
checks source/tool/artifact bindings; it is a retained replay, not fresh execution.
`test_text_layout.py` proves missing observations and rehashed corrupt outcomes
are rejected. Toolchain metadata records the exact released binary identities.
No manufacturer firmware or extracted artwork is distributed. The reused font and
messages are original Code198x diagnostic data under the repository MIT licence.

```sh
python3 scripts/verify-text-layout.py --native /path/to/native-binaries --assembler /path/to/asm198x
python3 scripts/check-text-layout.py
python3 -m unittest discover -s scripts -p test_text_layout.py -v
```

Use the existing bitmap-text, drawing-foundations and geometry READMEs for the
underlying hardware citations and qualified mode details. These layout routines
add calculations over those interfaces, not another hardware or font API.

## Observed example workloads

The default 33-byte message occupies two logical lines; the custom 44-byte message
occupies five. Both message and layout change, so this is not an isolated
alignment benchmark. The default/custom span counts are 511/709 on every target.
Destination-byte writes are 767/1,117 on the three mono targets, and 1,075/1,453
on CPC MODE 1. Context and font allocations do not grow. All are native work
counters checked independently, not cycle or elapsed-time measurements.
