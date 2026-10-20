# Reusable integer lines, circles and ellipses

Copy a CPU include, keep the machine's bitmap backend, reserve two workspaces,
and call one of five entries. These components draw into an existing bitmap;
they do not own a game loop, scene graph or interrupt handler. The four complete
`rendering/geometry/demo.asm` callers show original video setup and a direct
ellipse call before entering the verification mailbox. Your game needs the
setup and call, not the mailbox.

## Choose the actual machine

| Machine and mode | Geometry | Backend | Bitmap |
| --- | --- | --- | --- |
| Spectrum 48K, 256×192 | `z80.inc` | unchanged drawing-foundations/z80.inc plus existing `pixel_addr` | $4000–$57FF; attributes separate |
| BBC Micro MODE 4, 320×256 | `6502.inc` | unchanged drawing-foundations/6502.inc plus 512-byte scanline tables | &5800–&7FFF |
| Dragon 32 PMODE 4, 256×192 | `6809.inc` | unchanged drawing-foundations/6809.inc | $0600–$1DFF |
| CPC 464 MODE 1, 320×200 | `z80.inc` | `cpc.inc`, four packed pens | $C000–$FFFF allocation, 16,000 visible bytes |

Include a geometry component **once**, and one backend. Define `G` at 160 private
RAM bytes, `BP` at a separate 48 bytes, `GEO_WIDTH`, `GEO_HEIGHT` and
`GEO_PEN_MAX`. Use 255 for the monochrome backends (pen ignored) and 3 for CPC.
The 6502 BP allocation must be zero page; G can be ordinary RAM. BBC also needs
`PIXEL_WIDTH=320`, `PIXEL_HEIGHT=256`, `bitmap_lo` and `bitmap_hi` as in its caller.
Do not overlap code, tables, contexts, stack, display or other live allocations.

`geo_line`, `geo_circle`, `geo_ellipse`, `geo_fill_circle` and `geo_fill_ellipse`
return with RET/RTS. Use native word order: little-endian on Z80/6502,
big-endian on 6809. They require no scratch initialisation. Initialise every
public field used by the call, including the scissor; there is no implicit
full-screen default.

| G offset | Input or output |
| --- | --- |
| 0, 2 | Signed 16-bit x0,y0 for line; cx,cy for curves |
| 4, 6 | Signed 16-bit x1,y1 for line; unsigned rx,ry for ellipse; circle uses rx and ignores ry |
| 8 | Operation: 0 set (CPC replace with pen), 1 clear, 2 XOR |
| 9 | Line flags: 0 include both ends, 1 omit the caller's original final end; curves require 0 |
| 10 | Output: accepted=1, rejected=0 |
| 11 | CPC pen 0–3; monochrome ignores all byte values |
| 12,14 | Scissor left,top, unsigned 16-bit |
| 16,18 | Scissor right,bottom, unsigned 16-bit **exclusive** |
| 20 | Output: native-endian 32-bit destination-byte write count |
| 24 | Output: native-endian 16-bit backend-call count |
| 26–159 | Private scratch; no caller interpretation |

Coordinates must be −512..511; radii 0..255. The scissor must be a nonempty
rectangle inside the physical bitmap. Invalid coordinates, radii, operation,
flags, pen or scissor reject before any destination write; counters return zero.
Circle ignores ry. Public input bytes 0–9 and 11–19 survive. Accepted but wholly
clipped shapes return success with zero writes and calls. Never use a negative
radius to mean a reflected shape.

### A normal Z80 call

After your machine's setup and includes, this outlines an ellipse:

```asm
    ld hl,80
    ld (G+0),hl
    ld hl,70
    ld (G+2),hl
    ld hl,48
    ld (G+4),hl
    ld hl,24
    ld (G+6),hl
    ld hl,0
    ld (G+12),hl
    ld (G+14),hl
    ld hl,GEO_WIDTH
    ld (G+16),hl
    ld hl,GEO_HEIGHT
    ld (G+18),hl
    xor a
    ld (G+8),a
    ld (G+9),a
    inc a
    ld (G+11),a
    call geo_ellipse
    ld a,(G+10)           ; 1 means accepted, including a clipped-away shape
```

For a second call keep the scissor, replace the coordinates/operation/pen, and
call the appropriate entry. The full BBC and Dragon callers show native word
stores; do not paste Z80 instructions into those machines. Own the destination
between set/XOR calls: drawing the same XOR shape twice restores its old pixels
only if nothing changes those pixels between calls.

## Lines: rounding, reversal and clipping

The line chooses adjacent integer pixels with accumulated error rather than
floating-point division per pixel. It orders ends lexicographically (x, then y)
first, so reversing a line gives the same tie pixels. This matters on half-way
slopes: two equally close pixels exist and an API must choose consistently.

Normal lines include both ends. For a closed XOR polyline, set flag 1 on **each**
edge: omit that edge's original final endpoint. Each shared vertex then belongs
to one edge. A zero-length omit-final line draws nothing. The flag still means
the original caller's end when canonicalisation reverses the traversal.

Clipping is a raster-preserving scissor: generate the bounded original line and
discard samples outside [left,right)×[top,bottom). Replacing both endpoints with
rounded boundary intersections can change which interior pixels are selected;
this implementation keeps the original phase. Its cost still includes offscreen
steps, up to a major-axis delta of 1023. Horizontal and vertical lines take the
backend span fast path. An analytic clipper with an explicit phase/tie contract
is a different optimisation, not a silently equivalent replacement.

## Curves: symmetry and wide error

An ellipse with radii a,b obeys `b²*x² + a²*y² = a²*b²`. Starting at (−a,0),
the implementation updates its error and first differences using additions.
It reflects the chosen points into four quadrants, emitting axis points once.
Circles use equal radii through this same implementation. A dedicated eight-way
circle kernel could reduce work; that specialisation is not claimed here.

The reference model recomputes the implicit equation with arbitrary-precision
integers rather than sharing the assembly's error updates. Its line oracle uses
closed-form rounding. Both memory packing and native frame composition are also
calculated separately from the assembly masks.

16-bit curve error is insufficient even though the radii fit a byte. The checked
32-bit implementation covers all accepted pairs. `verify-geometry-arithmetic.py`
checks 65,025 nonzero pairs and 12,780,841 iterations, including the intermediate
error after the X update. The largest absolute stored/intermediate value is
94,739,400 at radii (255,253). The native matrix separately executes that pair.
This numeric proof is not an exhaustive native execution of every pair.

Filled curves emit the widest horizontal interval for each row exactly once,
then its mirrored row when different. A vertical step must not paint the same
row repeatedly under XOR. Zero radii reduce to an inclusive pixel or straight
span; zero is useful, not a division-by-zero accident. Curve clipping intersects
each row/span with the scissor. Counts record actual backend writes/calls, not
idealised area or elapsed cycles.

## CPC MODE 1 is a different backend

`cpc.inc` can be used by itself with BP and the `bp_pixel`, `bp_read`, `bp_hspan`,
`bp_vspan`, `bp_fill`, `bp_box` entries. It has the same BP coordinate/status/
write-count fields as drawing-foundations, but **BP+11 is an input pen 0..3**.
Operation 0 replaces selected pixels with that pen; 1 clears to pen 0; 2 XORs
the pen's two bits. Read requires operation 0 and returns a pen index at BP+10.
Inputs 0–8 and 11 survive; BP+40 counts writes. Rectangle/span ends are exclusive.
All requests are checked, without implicit clipping. Geometry provides clipping.

MODE 1 stores four pixels per byte, with the two bits separated:

`address = $C000 + (y & 7)*2048 + (y >> 3)*80 + (x >> 2)`

For phase `x & 3`, pen bit 0 occupies bit `7-phase`, pen bit 1 bit `3-phase`.
Thus pen 1 at x=0 produces $80, pen 2 produces $08, pen 3 produces $88.
Replacing pen 1 with pen 2 must clear the first bit as well as setting the second;
OR alone is wrong. Two partial-edge masks protect the other pixels. Each 2 KiB
bank uses 2,000 visible bytes: its last 48 remain untouched, 384 bytes in total.
The caller owns the CRTC, Gate Array, pen palette and the full bitmap allocation.
Palette colours are independent of the stored pen indices.

## Resources and costs

| Target | Geometry incl. constants | Backend | Extra row table | G + BP |
| --- | ---: | ---: | ---: | ---: |
| Spectrum | 5,110 bytes | 533 bytes | existing pixel_addr helper additional | 160 + 48 RAM |
| BBC | 5,533 bytes | 526 bytes | 512 bytes | 160 + 48 RAM |
| Dragon | 4,573 bytes | 470 bytes | none | 160 + 48 RAM |
| CPC | 5,110 bytes | 578 bytes | none | 160 + 48 RAM |

Measured with Asm198x 0.0.71; excludes reset code, stack, display and assets.
These are readable checked baselines, not small unrolled inner loops. The wide
curve arithmetic and counters have a real code/time cost. No per-frame or
cross-CPU speed claim follows from byte-write counts. Cache static shapes,
redraw small dirty regions, use tables or specialise when the game warrants it.
For example a filled ellipse (37,15) uses 31 span calls, rather than plotting its
1,833 pixels separately. The observed mono write count is 258; CPC needs 484
with four pixels per byte. Layout and edge alignment affect those counts.

A/X/Y/flags (6502), AF/BC/DE/HL/flags (Z80) and D/X/Y/CC (6809) are clobbered;
6809 U/DP survive. Keep 6502 decimal mode clear. The routines use nested calls;
reserve a conservative 64-byte stack budget **plus** your other calls and IRQ
requirements. No recursion or per-pixel stack allocation is used. G and BP are
non-re-entrant. Calls neither change interrupt state nor arbitrate video access.
Coordinate display updates with your own interrupts, OS and renderer. The
complete reset callers deliberately own the machine; they do not establish OS
coexistence, real-hardware timing or tear-free animation.

The Amiga Pattern Library's existing `blitter-line-draw` is a useful alternative:
Chip RAM, bitplane stride, octant setup, caller clipping, exclusive blitter
register ownership and an asynchronous completion wait. It has its own evidence;
it is not part of this four-machine execution claim.

## Reproduce the evidence

Use released Asm198x 0.0.71 and the four Emu198x 0.39.0 native binaries. Exact
archive and binary hashes, release URLs and producer locks are in toolchain.json.

```sh
make -C sinclair-zx-spectrum/patterns/assembly/rendering/geometry ASM198X=/path/to/asm198x
python3 scripts/verify-geometry.py --native /path/to/native-binaries --assembler /path/to/asm198x
python3 scripts/check-geometry.py
python3 -m unittest discover -s scripts -p test_geometry.py -v
python3 scripts/verify-geometry-arithmetic.py --output /tmp/geometry-bound.json
```

The first command is run from repository root. `fixture.bin` is original code,
not vendor firmware. Emulator arguments are `--rom` for Spectrum/Dragon/CPC,
`--mos` for BBC. Native runs write build/verification; review and copy those
files into verification explicitly. They never overwrite reviewed evidence.

Spectrum, BBC and Dragon each completed 215 calls; CPC completed 382, including
166 backend calls across all pen/phase combinations and invalid requests. After
every call we compare the **complete** bitmap allocation, guards, public inputs,
status, call counts and write counts. Selected entire native frames are compared
pixel by pixel, including palette/border. CPC starts with patterned neighbours
and unused allocation bytes; these must survive. Five deliberately faulty
executables complete accepted draws and fail both the independent memory and
native-image models (wrong squared-axis storage on four CPUs/configurations,
plus a wrong partial-byte CPC mask). CI rechecks retained full observations and
nine corruption/missing-observation controls; it does not pretend a replay is
fresh emulator execution.

## Next fill contract, without inventing an engine

A later polygon fill should accept a caller-owned vertex array with an explicit
count limit and scratch capacity, define winding/even-odd and boundary ownership,
clip spans, and reject invalid capacity before writes. A flood fill needs caller-
owned bounded work storage, seed/colour rules and an explicit capacity-exhaustion
result; recursion into an unknown machine stack is unsuitable. Neither is
implemented or advertised as available by this component.

## Primary references and licence

- Jack Bresenham, *Algorithm for computer control of a digital plotter*, IBM
  Systems Journal 4(1), 1965, pp.25–30:
  https://ibm-1401.info/Pics3/bresenham1965.pdf
- Alois Zingl, *Rasterizing Curves*, §2.1 and the radius-based ellipse algorithm:
  https://zingl.github.io/Bresenham.pdf and https://zingl.github.io/bresenham.html
- Zingl repository pinned at ce9002f5aa1d95bdb7d71a39ebdb0987df139db5:
  https://github.com/zingl/Bresenham/tree/ce9002f5aa1d95bdb7d71a39ebdb0987df139db5
  Recurrences adapted into assembly; MIT notice retained in LICENSE-Zingl.txt.
- Machine address/layout primary references are recorded in the existing
  drawing-foundations/README.md and bitmap-regions/README.md. CPC's standard
  MODE 1 CRTC layout and Gate Array pen packing are the target here; altered
  CRTC layouts and other colour modes need separate backends and qualification.
