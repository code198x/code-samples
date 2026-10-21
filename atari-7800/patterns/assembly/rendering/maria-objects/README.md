# Build a small MARIA object list

Give MARIA a picture address, width, palette and position. It fetches the picture
while your CPU does other work. That sounds like freedom after a TIA kernel,
but every object's header and graphics consume part of a scanline's DMA budget.

## Include, initialise, append

Copy `objects.inc`, reserve 10 private zero-page bytes at `ML` ($80 here), and
set `ML_CAPACITY` to 1..31 at assembly time. Allocate a **page-aligned RAM list**
of `4*capacity+2` bytes. The selected caller reserves 18 bytes at $1900 for four
objects. The pointer is a trusted allocation contract, not an address validator.

```asm
    lda #<LIST
    sta ML
    lda #>LIST
    sta ML+1
    jsr maria_begin          ; empty list, count zero, two-byte terminator
    lda #<graphics
    sta ML+2
    lda #>graphics
    sta ML+3
    lda #2                   ; two bytes = eight 160A pixels
    sta ML+4
    lda #0                   ; palette 0..7
    sta ML+5
    lda #32                  ; left edge, 160A pixels
    sta ML+6
    jsr maria_append         ; ML+8 = 1 accepted / 0 rejected
```

`maria_append` preserves ML+0..6, uses +7 as count, +8 as status and +9 as scratch.
Count is routine-owned state initialised by `maria_begin`; do not corrupt it.
Width must be 1..31 bytes, palette 0..7, x 0..159, and x+4*width<=160. The source
row must not cross a page: low-address+width<=256. A row ending exactly at the
boundary fits. No clipping or hardware wrap is exposed by this API.

All checks happen before any list write. A rejected call returns 0, preserving
the list and count. An append writes four header bytes and a new two-byte
terminator; begin writes two zero bytes and resets count. Begin does not wipe
old tail bytes: DMA follows the terminator. Changing the destination requires
another begin. Neither routine checks that a pointer names writable RAM.

A/X/Y/flags are clobbered. Use decimal mode clear and two stack bytes for each
direct JSR, plus caller/interrupt depth. The context must be in valid zero-page
RAM, not the 6532 RAM that this mode cannot use. The CPU stack is the machine's
page-one RAM. No interrupt/video/bank state is changed by these helpers.

## Zones and graphics remain caller-owned

Each direct header contains low graphics address, palette/negative width, high
graphics address and horizontal position. Width two encodes as 30 in the low
five bits. Pixel zero is transparent; each palette supplies three nonzero
colours. The caller uses palette 0 colour 1 and original A glyph data.

The DLL has sixteen 16-raster zones. Only zone 3 uses the nonempty list. Each
DLL entry supplies OFFSET=15, then the list address high byte followed by low.
MARIA adds the descending OFFSET to the graphics address's high byte: the first
row is at base+15*256 and the last at base. The 16 rows therefore occupy 16
pages in this simple fixture, despite only 32 useful bytes for one eight-pixel
shape. Several shapes can share unused columns in those pages.

The complete caller copies its 48-byte DLL into $1800 RAM, builds lists at
$1900 (objects) and $1920 (empty), sets palettes/DPPH/DPPL with DMA off, waits
for VBlank, then enables normal 160A DMA. Its code is an original 48 KiB reset
cartridge with no commercial BIOS/authentication route; that route is not
qualified by this example. The lists are immutable after enabling DMA.

For animation, build an inactive list/DLL and publish its pointer during VBlank,
coordinating both nonadjacent DPP registers and any interrupts. This fixture
does not implement or verify that publisher. Editing the list while MARIA
fetches it can tear or expose an unfinished header. No component promises
atomic publication, arbitrary vertical placement, bank switching or DLI safety.
The DLL, palette registers, DMA mode and graphics lifetime belong to one owner.

## Work and trade-offs

The builder is **121 code bytes**, with 10 context bytes. A four-slot list needs
18 RAM bytes; this caller also uses a 48-byte DLL and two-byte empty list.
The two displayed headers and terminator occupy ten bytes. A populated raster
fetches two four-byte headers, the two-byte terminator and four graphics bytes;
the same list is reused for sixteen rasters. Empty zones still have DMA setup,
termination and shutdown work. These counts are not CPU cycle measurements.

The *7800 Software Guide*, Appendix 3, expresses timings in **7.16 MHz cycles**:
8 per four-byte header and 3 per direct graphics byte, plus startup (5–9) and
shutdown (4–7, or 10–13 at zone end). Its accounting is not interchangeable
with CPU instruction cycles or other MARIA documents' clock/boundary conventions.
The fixture records workload, not an exact elapsed-DMA or physical-hardware
measurement. More objects, wider rows, indirect data and zone transitions all
change the budget. A capacity of four is a software allocation choice, not a
claim that MARIA can display only four objects—or any number regardless of width.

A byte holds four 2-bit pixels in 160A. Local pixel x maps to byte floor(x/4),
shift 6−2*(x mod 4); that packing is separate from the object's screen position.
At screen x32, a local x3 appears at x35. MARIA's native capture doubles logical
horizontal pixels and includes overscan: this emulator's active origin is x27,
so the first object's left edge is capture x91. Those capture coordinates are
not a game-coordinate API. Zone 3 appears at capture y50 in this configuration.

More colours, 320-pixel modes, indirect character maps, holey DMA, priority
composition and split objects across zones deserve their own contracts and
measurements. General pixel/line drawing and a software framebuffer are not
implied by the list builder. Compare the [TIA component](../../../../../atari-2600/patterns/assembly/rendering/playfield-kernel/README.md)
when CPU-emitted video is the constraint instead.

## Evidence and sources

`verification/results.json` retains the native frame, exact headers, source
hashes and completed wrong-width/position controls. Independent native boundary
calls cover zero/oversized widths, palette, placement, row-page overflow and
capacity without changing any byte in the surrounding 256-byte list page.
This demonstrates this emulator/model and direct 160A caller, not stock BIOS
loading, every MARIA mode or a saturation benchmark.

Primary: Atari, [*7800 Software Guide*](https://atarihq.com/danb/files/7800%20Software%20Guide.pdf),
“Display List”, “Display List List”, “DMA Modes”, “Starting up the 7800” and
Appendix 3 “MARIA Timing”. Reproduce with the [shared verification guide](../../../../../cross-platform/patterns/rendering/tia-maria/README.md).
