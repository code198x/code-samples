# Pixels, spans and boxes on Oric and ANTIC

Include `oric.inc` or `antic.inc` once, reserve 48 zero-page bytes at BP,
and provide the `bitmap_lo/hi` row tables from your complete machine caller.
Call `bp_pixel`, `bp_read`, `bp_hspan`, `bp_vspan`, `bp_fill` or `bp_box`.
These are reusable drawing components, without a hidden screen or game loop.

The three `rendering/pixels-and-boxes/demo.asm` programs own video setup and
make a normal direct box call before entering an optional verification mailbox.
The mailbox is not needed in a game. Code, stack, tables, bitmap and BP must not
alias. Scratch needs no initialisation; public inputs do. Preserve the relevant
RAM banks and coordinate display/IRQ access in your application.

## Common 6502 contract

| BP offset | Input / output |
| --- | --- |
| 0,2 | Unsigned little-endian x0,y0 words |
| 4,6 | Exclusive x1,y1 words for spans and rectangles |
| 8 | Operation: 0 set, 1 clear, 2 XOR; read requires 0 |
| 9 | Output: accepted 1, rejected 0 |
| 10 | Output: stored pixel bit for read; otherwise 0 |
| 11 | Ignored and preserved (no selectable pen here) |
| 12–39,42–47 | Private scratch |
| 40 | Output word: destination-byte writes |

Pixel/read ignore both ends; hspan ignores y1; vspan ignores x1. Other fields
must be valid. The whole effective rectangle must be nonempty, ordered and
inside the logical display. Invalid requests reject before any destination
write and return zero read/write outputs. Inputs 0–8 and 11 survive. No implicit
clipping: intersect your rectangle with the display before calling, if needed.

Spans combine edge masks and write full interior bytes. Outlines visit corners
once; XOR therefore leaves them visible. Write counts count stores, not changed
bits, CPU cycles or a frame budget. `bp_read` returns the stored bit; presentation
attributes can change the colour it produces.

Clobbers A/X/Y/P; clears decimal mode. BP must be zero page. The component is
non-re-entrant and does not alter interrupt enables or negotiate OS ownership.
Reserve a conservative 64-byte stack budget in addition to your application's
calls/IRQs. This is not evidence for an OS-loaded program or tear-free drawing.

## Oric Atmos HIRES: six pixels and serial attributes

The fixture establishes HIRES 240×200 at $A000–$BF3F, with 50 Hz mode code $1E
at $BFDF. Every 40-byte row starts with paper-black 16 and ink-white 7.
Those first **two bytes are reserved attributes**, so the routine's logical
surface is **228×200**, with logical x=0 mapping to physical x=12.

`address = $A002 + 40*y + (x div 6)`; mask is `32 >> (x mod 6)`.
Data bits 5..0 are pixels. The routine preserves inverse bit 7 and requires
bit 6 set in **every byte of the effective bounding rectangle before writing**.
This is an intentionally conservative, canonical allocation convention. It is
not a claim that every bit-6-clear byte is a hardware control code: effective
values $20–$3F can also carry pixel patterns. We reject those too, since a later
clear/XOR could turn them into a serial attribute ($00–$1F).

Initialise owned drawable bytes to $40, or $C0 for inverse cells. Preflight
rejects a noncanonical byte anywhere in the rectangle, including its interior
for an outline. Nothing is partially drawn before a later bad byte is found.
Set/clear/XOR change only bits 5..0; clear means zero stored bits, which appear
as ink in an inverse cell. The reserved 400 attribute bytes remain untouched.
The 7,600 drawable bytes are part of the 8,000-byte HIRES allocation.

This policy assumes the fixture's fixed ink/paper/mode and no other serial
attributes inside the drawable surface. A mixed text/graphics renderer needs
its own explicit attribute ownership contract.

## Atari 800XL and Atari 5200: independent ANTIC fixtures

Both use ANTIC mode F, 320×192, eight high-bit-first mono pixels per byte.
For byte-column b, the CPU row table uses:

`address = base + (y div 102)*4096 + (y mod 102)*40 + b`

ANTIC's 4 KiB screen-address counter boundary matters. The first 102 rows use
4,080 bytes. Skip 16 bytes, then put row 102 at the next 4 KiB boundary. The
remaining 90 rows use 3,600 bytes. The 8,192-byte reservation therefore has
512 unused bytes, all preserved by the component.

The original display list uses three 8-line blanks, an explicit LMS instruction
($4F plus address) for each of 192 rows, and JVB ($41 plus start address).
It occupies 582 meaningful bytes in a 768-byte reservation that does not cross
a 1 KiB boundary. This is deliberately easy to inspect. A two-LMS display list
would save space but needs a different construction/verification path.

| Fixture | Bitmap reservation | Display list | GTIA / ANTIC |
| --- | --- | --- | --- |
| 800XL | $4000–$5FFF | $3000–$32FF | $D000 / $D400 |
| 5200 | $2000–$3FFF | $1000–$12FF | $C000 / $D400 |

The XL caller is an original reset OS image with an original zero-filled BASIC
image, not Atari firmware. The 5200 caller is a separate 32 KiB cartridge plus
an original generated 2 KiB reset stub that jumps into it. **It is not the
manufacturer BIOS or evidence of its authentication/boot path.** Each target
ran in its own native emulator. A working XL run is not used as a console claim.
NMI is disabled; the caller owns DMA, display list, palette and RAM. Other OS,
cartridge bank arrangements and live display coexistence need separate work.

## Resources and choosing a faster path

| Target | Backend code | CPU row tables | BP | Additional display metadata |
| --- | ---: | ---: | ---: | ---: |
| Oric | 547 bytes | 400 bytes | 48 bytes | 400 reserved attribute bytes within HIRES |
| 800XL | 528 bytes | 384 bytes | 48 bytes | 582-byte display list, 768 reserved |
| 5200 | 528 bytes | 384 bytes | 48 bytes | 582-byte display list, 768 reserved |

Code counts exclude reset setup, stack and bitmap. Oric preflight reads the
whole bounding rectangle, buying rejection before writes at a runtime cost.
A renderer that owns and guarantees canonical data could offer a separately
checked fast path. ANTIC row tables trade RAM/ROM for avoiding multiplication
and the 4 KiB split on every pixel. Full-byte spans avoid per-pixel calls;
masked sprites or character/tile updates may fit a game better than bitmap work.
No cycle or real-hardware frame-rate claim is made here.

## Verification and reproduction

Asm198x 0.0.71 and native Emu198x 0.39.0 executed **143 Oric, 155 XL and 155
5200 calls**, including the ordinary direct caller. Every call compares the
complete bitmap, guards, status, read bit, public inputs and byte-write count
with an independent selected-pixel model. Atari display lists and padding are
checked too. Phases, all operations, boundaries, rejected declarations, full
fills and the row 101/102 split are covered. Oric includes inverse cells,
control-code rejection after valid rows and rejection of noncanonical $20 data.
Selected whole native frames match independently composed pixels.

Two completed accepted faulty builds per target (wrong bit masks and wrong CPU
row addresses) fail both memory and picture comparisons. Retained evidence is
source/tool-bound and replayed in CI; failure tests reject missing, incomplete
and rehashed bad observations. This qualifies the specified emulator/reset
configurations, not physical hardware timings or stock firmware integration.

```sh
python3 scripts/verify-extended-primitives.py --native /path/to/native-binaries --assembler /path/to/asm198x
python3 scripts/check-extended-primitives.py
python3 -m unittest discover -s scripts -p test_extended_primitives.py -v
```

Fresh runs write each machine's build/verification; reviewed records live in
verification/. Toolchain identities are in toolchain.json. The ROM, OS, cartridge,
font-free drawings and 5200 reset stub are original MIT-licensed project code.
No third-party firmware is distributed.

Hardware references: *Oric Atmos Handbook* (Century Communications), HIRES and
serial attributes; Atari, *De Re Atari* (1982), chapter 2, display-list LMS and
screen addressing (printed pp. 2-5–2-6). Their memory models explain the layouts;
the retained observations establish the named emulator behaviour separately.
