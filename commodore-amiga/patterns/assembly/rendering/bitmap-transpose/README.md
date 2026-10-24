# Transpose an Eight-by-eight Bitmap on Amiga

Turning rows into columns is the building block behind rotating small glyphs and adapting bitmap layouts.

## Use it in a project

C0..C7 are eight monochrome source rows, bit seven leftmost. Return R0..R7 with row and column exchanged: source pixel (x,y) becomes destination (y,x). Preserve source rows. This is a diagonal reflection; combine with mirroring for a quarter turn.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **R0, R1, R2, R3, R4, R5, R6, R7, C0, C1, C2, C3, C4, C5, C6, C7**. They occupy 16 contiguous bytes. Also reserve the private workspace: **T0, T1, T2, T3, T4, EXPR_SAVE** (6 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `bitmap_transpose_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `bitmap_transpose_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | none |
| Supply before service | C0..C7 |
| Read after service | R0..R7 |

Each output row corresponds to one input column. Test that bit in every source row and place it at the matching output position.

## Machine contract

D0–D3/A0–A1/CCR may change; D4–D7/A2–A6 are preserved. A direct BSR/JSR needs four return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The A500 OCS diagnostic cold-boots an OFS disk, owns the Copper and bitplane and disables interrupt/DMA sources. The helper does not take over hardware or allocate Chip RAM.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x` and `BUILD198X=/path/to/build198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Transpose an identity diagonal, which should remain identical. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller clears the first row before transforming it. The destination’s first column loses those pixels. Keep all eight source rows until the transform has completed.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 418 code bytes; public state is 16 bytes and private scratch is 6 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Sixty-four pixel tests plus shifts. A butterfly bit-swap algorithm is faster but less direct; precomputed transformed art costs storage instead of runtime.

Source and destination bindings must be separate. This is a data transformation, not a machine-specific draw routine; screen attributes and colour planes need separate handling.

## Execution evidence

Four variants run on A500 OCS PAL, Kickstart1.3 OFS cold boot, using Asm198x 0.0.72, Emu198x 0.44.2 and Build198x 0.2.9. Each executes 62 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.

## Existing alternatives

The existing [full-glyph transform](https://code198x.com/patterns/sinclair-zx-spectrum/assembly/rendering/bitmap-text/) covers rotation and reflection with an overlap-safe pointer interface on its documented machines. This separate-buffer helper exposes transposition directly for row/column conversion. A transpose reflects across a diagonal; it must not silently substitute for a clockwise turn. Choose the existing transform for its quarter-turn flags or in-place operation.
