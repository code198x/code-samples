# Shrink an 8×8 glyph without changing its storage format

Fit a small icon into a 5×7 box or squash it to 8×4. `glyph_resize` resamples one MSB-left, top-row-first eight-byte glyph into caller-owned storage. The result is still an eight-byte 8×8 cell: useful pixels occupy the top-left width×height rectangle and the rest is zero. It does not pack variable-width rows or change your renderer's advance.

## Include, initialise, call

Define **RZ as 32 writable bytes**, include the CPU-specific `6502.inc`, `z80.inc` or `6809.inc`, and call `glyph_resize`. On 6502 also reserve **RP as two separate zero-page bytes**; RZ need not be zero page. Set every public input; scratch needs no initialisation.

| RZ offset | Contract |
| --- | --- |
| 0 | Source address word: eight readable bytes |
| 2 | Destination address word: eight writable bytes |
| 4 | Target width byte, 1..8 |
| 5 | Target height byte, 1..8 |
| 6 | Output: 1 completed, 0 rejected |
| 7..31 | Private scratch, including eight source snapshot bytes |

6502/Z80 words are little-endian; 6809 words are big-endian. Inputs 0..5 survive. Either dimension outside 1..8, or either address above $FFF8, rejects before source/destination access. Ending exactly at $10000 is arithmetically valid. You must still own readable/writable mapped memory: this check does not make ROM, I/O, bank switching or an unallocated range safe.

The source and destination may overlap, including exact in-place operation. All eight source bytes are snapshotted before all eight destination bytes are cleared. Keep RZ, RP, code and stack disjoint from both ranges. Exclusive access is required for the call; it is non-re-entrant and changes no interrupt or display policy. An interrupt handler must preserve live registers and leave the component's allocations alone.

6502 changes A/X/Y/flags and requires decimal mode clear. Z80 changes AF/BC/DE/HL/flags. 6809 changes D/X/CC and preserves Y/U/DP. Reserve a conservative 16-byte stack allowance beyond caller/interrupt requirements. The later drawing call has its own larger stack and hardware obligations.

The four machine folders contain complete normal/customised callers and `prepare.inc`, showing every input, the call and how the result becomes a one-glyph font for the existing enlarged renderer. Normal dimensions are 5×7; customised dimensions are 8×4. Both display the result at scale 4 inside a 32×32 cell at (21,37). The original F is assigned code 65 in this one-glyph output font. It is original MIT Code198x data, not a ROM extraction.

- Spectrum 48K uses its existing 256×192 interleaved bitmap helper and separately owned attributes.
- BBC MODE 4 uses 320×256, row tables and zero-page BP; RP is separate.
- Dragon PMODE 4 uses 256×192 linear rows and big-endian fields.
- CPC MODE 1 uses 320×200 logical pixels, four pens and packed display bytes.

These are original replacement-ROM/MOS reset fixtures, not stock-firmware launchers. The resize component itself has no display dependency. The renderer, font declaration and native transfer format remain explicit choices; writing these eight bytes does not upload a hardware character or sprite automatically.

## Sampling: select from the whole source

For destination (x,y), read source `(x*8 div width, y*8 div height)`. This is a top-left nearest-neighbour convention, equivalent to selecting the cell containing the mapped point, with no interpolation. At width 5, columns sample **0,1,3,4,6**; width 4 samples **0,2,4,6**. Height uses the same rule independently. Width/height 8 returns the original exactly; 1×1 keeps only the top-left source pixel.

The target uses bounded integer error accumulators, rather than division for every pixel. Starting at zero, add eight after each destination pixel; subtract width and advance the source column while the error is at least width. Reset X state at each row. This generates exactly `floor(x*8/width)`. The independent oracle uses direct division, plus known-coordinate and identity controls.

At width 4, a one-pixel vertical line in source column 1 disappears: that column is never sampled. Nearest-neighbour shrinking loses detail. A designer-redrawn small icon may be clearer. Averaging/coverage filters, pixel-centre sampling and antialiasing are different policies; none is hidden here. Native bitmap pixels may have non-square physical proportions; equal numeric factors do not correct them.

## Make it your own

Change GLYPH_WIDTH/GLYPH_HEIGHT from 5/7 to 8/4 in the maintained customised caller. Horizontal detail returns while alternate source rows are omitted. The zero padding, eight-byte output, renderer cell and advance stay unchanged. A different eight-byte source icon preserves the contract. Larger input images, variable-size storage or proportional metrics need a new representation and verification.

You can use this output with the existing fixed-width, enlarged or proportional bitmap renderer if its font declaration describes the actual result. Cropped proportional assets/widths/bearings must be regenerated together. To shrink a bank, call once per glyph and advance each address by eight after validating the whole bank in your caller. Per-call overlap safety does not make overlapping bank traversal safe: one output can overwrite a later source. Prefer separate banks or explicitly planned traversal/snapshots.

## Common mistake: cropping instead of shrinking

The maintained `mistakes/*-sampling.inc` fragments deliberately advance the source X by one per destination pixel. They take columns 0,1,2,3,4 for width 5, discarding the right side rather than selecting across the whole source. Y still resamples correctly in this bounded fault. On the F example, the top bar and middle bar have the wrong proportions. The call completes and respects buffer bounds, so success alone does not prove the intended picture.

Restore the eight-step accumulator. Compare both the eight output bytes and the displayed result. The executed repaired build is byte-identical to the positive program. Faults are separate from the normal download, clearly labelled before their listings.

## Costs and choices

Each valid call reads eight source bytes into scratch, clears eight output bytes and samples width×height pixels, from 1 through 64. Each sampled set bit performs a destination read/modify/write. These are glyph-buffer operations, **not all CPU memory accesses, instruction counts or measured cycle timings**. Small dimensions reduce sampling work but do not remove the eight-byte snapshot/clear. The recurrence also performs repeated subtraction to advance source coordinates; fewer output pixels need not mean a proportional speedup.

The result always occupies eight bytes, even if only 1×1 is useful. Runtime shrinking here buys reuse of one source asset and small scratch, not packed-asset storage savings. Cache a result or prepare a deliberately designed small glyph at build time. Keeping all 64 width/height variants, including the 8×8 identity, takes 512 bytes per glyph, compared with eight for one source. Store only sizes you need. Drawing at scale 4 repeats the selected pixels; it cannot recover discarded details. No frame-budget promise follows from a correct native picture.

## Reproduce qualification

Released Asm198x 0.0.71 and Emu198x 0.41.0 tools are checksum-pinned in `toolchain.json`.

```
python3 scripts/verify-glyph-resize.py --native /path/to/qualified/tools --assembler /path/to/qualified/asm198x
python3 scripts/check-glyph-resize.py
python3 -m unittest discover -s scripts -p test_glyph_resize.py -v
```

Each named machine checks all 64 size pairs against asymmetric/full/empty/diagonal glyphs, every source pixel at four representative shapes, partial/exact overlap, rejected dimensions and wrapping addresses, source/output/scratch guards, and selected complete bitmap/native frames. Normal, customised, faulty and repaired callers execute independently. Retained checks bind source and tools and reject missing, incomplete, corrupted and rehashed-but-wrong evidence. Original hardware, stock-OS loading, interrupt coexistence and cycle timing remain separate work. This component does not provide larger-than-8 targets, arbitrary angles or scale-aware text layout.
