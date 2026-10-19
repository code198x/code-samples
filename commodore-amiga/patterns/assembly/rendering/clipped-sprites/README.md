# Clip word-aligned Amiga blitter objects

Build with `make ASM198X=/path/to/asm198x BUILD198X=/path/to/build198x-adf`; boot `build/demo.adf` on A500 OCS PAL/KS1.3. The caller takes over custom chips, owns a 320×256 one-plane display and requires reset to leave. All data/code is in chip RAM.

Include `clip.inc` and `draw.inc` once. `draw_clipped`: D0.w is signed X in sixteen-pixel words, D1.w signed Y in rows, A0 opaque mask, A1 image, A2 screen base. The fixed source is 32×16, four bytes per row (64 bytes each for mask and image). Mask 1 selects image; this polarity differs from Spectrum/BBC keep-masks. Even pointers, owned chip-RAM spans, all source/destination/context/code/stack ranges disjoint. Caller must enable DMA and own the blitter for the entire synchronous operation.

D0-D7/A0-A5 survive; CCR changes. Stack requirement: 68 saved-data bytes plus BSR/caller-return and interrupt needs. Both clipping axes are resolved before writing blitter registers; an invisible object starts no blit. A/B source modulos keep the original four-byte row stride, while C/D modulos keep the screen's forty-byte stride. The routine waits before programming and before return. It does not set up a copper list, interrupts, OS ownership, clipping within words or shifts.

`clip_axis` alone takes D0.w position, D1.w extent, D2.w limit; returns destination, source skip and count in those same registers. D3/D4 and CCR change, address registers survive; upper data-register words are unspecified.

Hardware basis: *Amiga Hardware Reference Manual*, chapter 6, Memory Layout and DMA Channels (https://www.theflatnet.de/pub/cbm/amiga/AmigaDevDocs/hard_6.html). The implementation is original Code198x code.

`clip_axis` intersects one signed-position interval with a viewport. Position is a signed 16-bit word; extent is 0..256, limit is 1..256. It returns destination, source samples to skip, and visible count. All three results are zero when invisible. Negative positions stay signed until the intersection is known; do not convert a negative coordinate into a screen pointer. Inputs outside these extent/limit contracts are not validated.

For a rectangle, clip both axes before drawing. The source still has its ORIGINAL row stride when the visible width shrinks. On a left/top crop, advance to the surviving source column/row; changing only the destination paints the wrong part of the object.

These routines do not erase old objects, save backgrounds, move a camera or schedule drawing. For save-under movement, retain the previous clipped destination AND dimensions and its separate saved buffer, restore overlapping objects in reverse order, update scenery, then clip/save/draw again. A fully invisible object has no rectangle to save or restore. A right-edge object may need a different buffer footprint after moving. See the sibling sprite-lifecycle implementation; never pass an unclipped negative position to its copy helpers.

The demo is an original static scene with nine calls: four cropped corners, three visible objects and two fully invisible objects. It continues servicing frame waits. This is an aligned first implementation, not arbitrary-pixel clipping or a complete game renderer. Actual CPU/native-scene execution and rejected broken clipping/source-crop controls are recorded in `docs/sprite-clipping/verification/`; the guard checks retained bindings, not fresh runtime execution.
