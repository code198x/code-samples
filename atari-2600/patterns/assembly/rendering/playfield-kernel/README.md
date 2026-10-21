# Prepare a playfield, then race the beam

Use this for a chunky maze, score glyph or symmetric backdrop. The reusable
buffer helpers prepare a picture; the fixed kernel delivers it every field.
The TIA has no persistent framebuffer to accept a general-purpose plot call.

## Include and call

Copy `playfield.inc` and `kernel.inc`. The maintained `demo.asm` shows the complete
reset, allocation and NTSC field caller. Assemble with `make` (Asm198x ACME).
Reserve `PF_BUFFER=$80` for 72 bytes and `PF=$C8` for 16 zero-page bytes. This
qualified allocation leaves $D8–$E7 for caller results, $E8–$EB for guards and
$EC–$FF for 20 stack bytes. Do not overlap any of these allocations.

```asm
    jsr pf_clear
    lda #3
    sta PF+2                 ; column 0..19 in the LEFT half
    lda #5
    sta PF+3                 ; band 0..23
    lda #1
    sta PF+4                 ; 1=set, 0=erase
    jsr pf_cell              ; PF+5 = 1 accepted / 0 rejected
```

`pf_clear` zeroes all 72 picture bytes. `pf_cell` preserves x/y/value and modifies
one native buffer byte. Invalid x, y or value rejects before any buffer write.
A/X/Y/flags and PF+5..7 are clobbered; clear does not set a status.

For an **opaque 5×7 glyph**, put a pointer at PF+0/1, origin at PF+2/3 and call
`pf_stamp`. Seven readable bytes encode rows, bit 4 leftmost; bits 7..5 must be
zero. It validates all seven rows before writing. Origins must fit the whole
stamp (x<=15, y<=17). Source must be stable, readable, non-wrapping and disjoint
from buffer/context/stack. Source pointer and origin survive. PF+4..12 and flags
are scratch/status. PF+5 returns 1/0. Zero glyph bits erase existing cells.
The supplied A is original data; replace it with your own seven-byte shapes.

Both helpers require decimal mode clear, no concurrent access to their shared
context, and two stack bytes per direct JSR; stamp needs four including its
nested cell call. Add your caller/interrupt depth. Neither helper touches video
registers, interrupt state, sound, banks or the frame clock.

## Emission belongs to the frame owner

`pf_kernel` clobbers A/Y/flags and PF+13/14. It emits 24 bands of eight lines,
using PF0/1/2, WSYNC and the entire visible CPU schedule. The caller owns VSYNC,
VBLANK, CTRLPF, COLUPF/COLUBK and all blank/overscan work. Follow `demo.asm`:
clear stale PF registers before unblanking, call the kernel at its scheduled
boundary, then WSYNC after return to finish the final line before blanking.
Never put a picture helper, music service or input read inside this kernel.

The selected buffer starts at $80 and fits one page. The absolute,Y reads each
cost four CPU cycles. After each WSYNC release the PF writes end at cycles
7, 14 and 21; visible output starts at colour clock 68 (CPU cycle 22 2/3).
The longest band rollover, including a page-crossing branch if relocated, still
reaches the next WSYNC within 76 CPU cycles. This schedule does not qualify an
arbitrarily relocated buffer that makes an indexed read cross a page.

The native caller measures 59,736 colour clocks between steady field markers:
262 lines ×228 colour clocks, at three colour clocks per CPU cycle. The picture
has 192 emitted lines. The capture includes the emulator's 240-row viewport;
the first emitted line lands at y14 in this caller. A deliberately added
overscan line is rejected by the same period test. PAL needs a separate caller
and measurement; changing a title does not qualify PAL timing.

## Granularity and cost

There are 20 independent columns. Each cell is four colour clocks wide and
eight scanlines tall. The TIA repeats that half across the right side, or
reflects it when CTRLPF bit 0 is set. It is not 40 independent columns. A glyph
is 20×56 colour clocks/scanlines, repeated or reflected with the rest.

PF0's useful bits scan **4,5,6,7**; PF1 scans 7..0; PF2 scans 0..7. The helper
hides that packing without hiding the display's coarse grid. Logical point
(13,19) belongs to cell (3,2) at this 4×8 scale, with remainders (1,3).
A game's collision grid need not have the same resolution as its drawing grid.

Assembled components: **197 code bytes plus 64 table bytes**; 72 picture bytes,
16 context bytes and seven bytes per glyph. Clear makes 72 buffer writes;
a cell makes one; a stamp makes 35 calls/writes after seven validation reads.
These are work counts, not measured helper execution times or a promise that
a large number of stamps fits blanking. The visible kernel is recurring work
even when the picture does not change.

A smaller height or ROM-only picture can save scarce RIOT RAM. An asymmetric
playfield needs a different, mid-line rewrite schedule. Players, missiles,
ball, variable colours, sprite multiplexing and fine text are separate kernels
with competing register/cycle ownership. General lines, ellipses, arbitrary
pixel fonts and arbitrary glyph scaling are not supplied by this component.

## Evidence and sources

`verification/results.json` retains native repetition/reflection frames, source
hashes, field period and completed wrong-bit/late-register/wrong-period controls.
The shared verifier compares every native pixel against a logical cell grid;
separate native boundary calls snapshot the whole buffer around rejected calls.
No firmware, commercial art or original-hardware execution is claimed.

Hardware source: Steve Wright, Atari, *Stella Programmer's Guide* (1979),
[full retypeset guide](http://www.atarihq.com/danb/files/stella.pdf), printed
pp. 2–3 (field timing), 10–11 (playfield), 39 (serial output bit-order diagram).
See the [family comparison](../../../../../cross-platform/patterns/rendering/tia-maria/README.md)
for reproduction and the contrasting MARIA contract.

The separate `mistakes/` fragments show deliberately broken cases and tested
fixes. They are excluded from the normal caller. The shared guide explains
how to reproduce them; the website shows verified native captures and diagnosis.
