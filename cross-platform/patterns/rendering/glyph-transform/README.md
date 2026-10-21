# Turn or reflect an 8×8 glyph

Give a direction arrow four orientations, mirror a small icon, or prepare a sideways character without storing a whole second font. Include the CPU-specific component once and call `glyph_transform`. It transforms one glyph into an eight-byte buffer; it does not draw, move a string or rotate its layout.

The original MIT Code198x font stores eight rows per glyph, top first, bit 7 leftmost. This is also a useful asset format for other one-bit pictures. Conversion into a machine's native character/sprite format remains the caller's job.

## Include, initialise, call

Define F as **32 writable bytes** and include `6502.inc`, `z80.inc` or `6809.inc`. On 6502 also define GP as **two zero-page bytes**; this component does not borrow BP. F need not be zero page. Scratch needs no initialisation, but set every public input:

| F offset | Contract |
| --- | --- |
| 0 | Source address word: eight readable bytes |
| 2 | Destination address word: eight writable bytes |
| 4 | Flags byte, 0..7 |
| 5 | Output: 1 accepted/completed, 0 rejected |
| 6..31 | Private scratch, including an eight-byte source snapshot |

Words are little-endian on 6502/Z80 and big-endian on 6809. Inputs 0..4 survive. Flags bits 0..1 select 0, 1, 2 or 3 clockwise quarter-turns. Bit 2 reflects horizontally **after** rotation. Flags 6 therefore supplies a vertical reflection. Invalid flags or either address above $FFF8 reject before any source or destination access. An eight-byte range ending exactly at $10000 is arithmetically valid; the caller must still provide readable/writable mapped memory.

The source and destination may overlap, including exact in-place operation. All eight source rows are copied before the output is cleared. Keep F, GP, code and stack disjoint from both ranges, with exclusive ownership for the call. ROM destinations, I/O, bank switching, interrupts sharing scratch and unallocated ranges are not made safe by an address check.

6502 changes A/X/Y/flags and requires decimal mode clear. Z80 changes AF/BC/DE/HL/flags. 6809 changes D/X/CC, preserving Y/U/DP. The routine neither masks interrupts nor changes the display. It is non-re-entrant. Reserve a conservative 16-byte stack budget beyond caller/interrupt requirements. A caller may interrupt it only if the handler preserves the live registers and does not touch its scratch or allocations.

Each machine folder supplies a complete original reset caller, its includes and `prepare.inc`. That file shows every transform input, then points the existing enlarged renderer at the result as a one-glyph font. It draws the original F glyph as code 65 at (21,37), magnified 4×4 for inspection. The normal example turns it clockwise; `customise.asm` changes only GLYPH_FLAGS to 4 for reflection. The drawing paths remain distinct:

- Spectrum 48K: 256×192, existing interleaved address helper, separate attributes.
- BBC Micro MODE 4: 320×256, existing row tables and zero-page BP; GP uses a separate two bytes.
- Dragon 32 PMODE 4: 256×192, linear bitmap and big-endian context.
- CPC 464 MODE 1: 320×200 logical pixels, four packed palette pens.

These are original replacement-ROM/MOS fixtures, not stock-firmware launchers. None of the transform code depends on those displays; the complete demonstration still must own the named display and buffers. Existing fixed-width or proportional renderers can consume the same result if their font declaration describes it. Never include both fixed and scaled text components, which export the same text symbols.

## Why (7−y,x)?

Coordinates run 0..7, with Y down. A clockwise turn moves source (x,y) to (7−y,x). The top-left dot becomes top-right. Repeating that mapping twice gives (7−x,7−y), three times gives (y,7−x), and four times returns the source. A horizontal reflection maps the final X to 7−X. Reflection and rotation generally do not commute.

The target scans all 64 source pixels, shifts a row byte, computes each set pixel's destination and ORs its bit into the output. The independent verifier rotates a Boolean matrix instead. Single-pixel tests exercise every coordinate in every orientation, so a symmetric letter cannot conceal a mistaken mapping.

## Make it your own

Change GLYPH_FLAGS from 1 to 4 in the maintained caller. The reflected F keeps the top bar horizontal and moves its stem to the right. Both versions still need eight output bytes and the same transform component. Replacing the source with a different eight-byte glyph preserves the contract. A larger image or proportional metrics requires a new representation and verification.

To keep a whole font, call once per glyph and advance both addresses by eight, after checking the entire source/destination bank allocation in your caller. The component validates only **one glyph**. Overlap safety is likewise per call: an overlapping bank traversal may overwrite a later glyph before its turn. Use separate banks or plan traversal/snapshot storage explicitly. Widths/bearings do not transform automatically; either measure the transformed font or keep an explicit fixed-width layout.

## Common mistake: transpose is not a turn

The maintained `mistakes/*-rotation.inc` fragments deliberately use (y,x). That reflects across the diagonal. On the F example, its long top bar points downwards rather than becoming the right-hand vertical bar of a clockwise turn. The faulty call completes and writes a valid eight-byte glyph; successful return alone cannot distinguish the wrong picture. Restore (7−y,x), rerun and compare both glyph bytes and the displayed result. The repaired program is byte-identical to the positive fixture.

## Costs and alternatives

There is no permanent transformed-font bank: F includes an eight-byte snapshot; each retained result needs another eight bytes. Each valid call reads eight source bytes into scratch, clears eight output bytes and scans 64 source pixels. Each set pixel then reads and writes its destination byte. Those are asset-buffer operations, **not all CPU memory accesses, instruction counts or cycle timings**. Extra quarter-turns perform extra coordinate arithmetic for every set pixel. No frame budget is promised.

Cache a result while it is useful, transform it again when it changes, or prepare variants at build time. All eight orientations of one glyph occupy 64 bytes rather than eight (56 extra); all eight 64-glyph banks occupy 4,096 rather than 512 (3,584 extra). Stored variants omit the transform call but still pay drawing/transfer costs. Cache only the glyphs/orientations actually used. Hardware flips, where a display supports them, may avoid transforming pixels entirely; this routine does not add such hardware to these bitmap modes.

Drawing at scale 4 makes a 32×32 cell; rotation itself still returns 8×8. Neither operation corrects physical pixel aspect ratio. These quarter-turns are exact permutations of bits, with no resampling or antialiasing. Arbitrary angles and fractional sizes require different bounds, sampling and quality decisions.

## Reproduce the evidence

`toolchain.json` pins released Asm198x 0.0.71 and native Emu198x 0.41.0 binaries by checksums. Run from the sample repository root:

```
python3 scripts/verify-glyph-transform.py --native /path/to/qualified/tools --assembler /path/to/qualified/asm198x
python3 scripts/check-glyph-transform.py
python3 -m unittest discover -s scripts -p test_glyph_transform.py -v
```

Fresh execution checks all eight transformations of asymmetric/full/empty data, all 64 single pixels, partial/exact overlap, rejected flags and wrapping addresses, scratch/source/output neighbours and selected full native frames. Normal, customised, faulty and repaired startup paths run separately on each of the four machines. Retained replay checks source/tool identities and actual output/frame bytes; adversarial tests reject missing, incomplete, corrupted and rehashed-but-wrong evidence. Retained evidence is not a claim of fresh execution on the reader's machine. Original hardware, stock OS launch, interrupt coexistence and cycle timing remain separately unverified.
