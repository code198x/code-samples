# Mirror an Eight-bit Bitmap Row on C64

A stored row of pixels can face the other way without keeping a second copy of the artwork.

## Use it in a project

Reverse all eight bits of ROW into MIRRORED, preserving ROW. Bit seven is the leftmost source pixel. Apply the helper separately to each row of an eight-pixel-wide monochrome image.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **MIRRORED, ROW**. They occupy 2 contiguous bytes. Also reserve the private workspace: **T0, T1, T2** (3 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `bitmap_mirror_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `bitmap_mirror_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | none |
| Supply before service | ROW |
| Read after service | MIRRORED |

Consume source bits from the low end while shifting the result left. After eight steps the bit order has reversed exactly.

## Machine contract

A/X/status may change; Y and decimal mode are preserved. Use CLD for binary arithmetic. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The diagnostic PRG owns screen, font and colour RAM and disables interrupts; it does not return to BASIC. The reusable helper does none of those things.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Mirror a symmetric row to show that some images legitimately remain unchanged. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller removes the upper nibble before reversal. Pixels at the left vanish rather than moving to the right. Preserve the complete row.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 70 code bytes; public state is 2 bytes and private scratch is 3 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Eight stages per row. A 256-byte reversal table saves runtime; NES sprite horizontal flip avoids transforming pattern bytes altogether. The C64 has no VIC-II sprite flip bit.

This transforms monochrome row data only. It does not change screen attributes, planar colour ordering or sprite registers. NES sprite flip attributes can avoid this work. The C64 needs transformed bitmap data because its sprites have no horizontal-flip bit.

## Execution evidence

Four variants run on PAL stock-ROM PRG, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.

## Existing alternatives

The existing [full-glyph transform](https://code198x.com/patterns/sinclair-zx-spectrum/assembly/rendering/bitmap-text/) supports quarter-turns, reflections and overlapping source/destination buffers on its documented machines. Its pointer interface and snapshot workspace are useful for whole-font tools. This row helper needs no source/destination pointer or eight-byte snapshot; call it for one row at a time, or choose the full transform for its richer contract.
