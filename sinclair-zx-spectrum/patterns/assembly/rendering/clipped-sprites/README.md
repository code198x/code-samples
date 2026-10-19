# Clip masked Spectrum sprites

Build with `make ASM198X=/path/to/asm198x`; load `build/demo.tap` on a 48K PAL Spectrum. The caller owns the bitmap, attributes and a private stack at $ff00; it uses ROM IM1/HALT and requires reset to exit.

Include `clip.inc`, `draw.inc` and the existing `../bitmap-addressing/bitmap-addressing.inc` once. `draw_clipped` takes IX pointing at 32 exclusive caller bytes: signed X at +0 (eight-pixel byte columns), signed Y at +14 (pixel rows), and a source pointer at +28. The source has 64 interleaved keep-mask/image bytes for a 16×16 image, four bytes per original row. Keep-mask 1 retains scenery; image bits must be zero wherever the keep-mask is 1. Both record inputs are overwritten with the fixed extent/viewport configuration; their positions remain intact.

AF/BC/DE/HL change, IX/IY survive. The two 14-byte axis blocks occupy +0..27; outputs within each block are destination +6, source skip +8, visible count +10; +12..13 is scratch. +30 is the draw row counter. Source/context/code/stack must be disjoint from the bitmap and one another. Attributes remain untouched. No IRQ/display synchronisation is set up by the includes. Row copying pushes four bytes, plus call returns and interrupt needs; clip_axis also uses temporary two-byte pushes.

`clip_axis` intersects one signed-position interval with a viewport. Position is a signed 16-bit word; extent is 0..256, limit is 1..256. It returns destination, source samples to skip, and visible count. All three results are zero when invisible. Negative positions stay signed until the intersection is known; do not convert a negative coordinate into a screen pointer. Inputs outside these extent/limit contracts are not validated.

For a rectangle, clip both axes before drawing. The source still has its ORIGINAL row stride when the visible width shrinks. On a left/top crop, advance to the surviving source column/row; changing only the destination paints the wrong part of the object.

These routines do not erase old objects, save backgrounds, move a camera or schedule drawing. For save-under movement, retain the previous clipped destination AND dimensions and its separate saved buffer, restore overlapping objects in reverse order, update scenery, then clip/save/draw again. A fully invisible object has no rectangle to save or restore. A right-edge object may need a different buffer footprint after moving. See the sibling sprite-lifecycle implementation; never pass an unclipped negative position to its copy helpers.

The demo is an original static scene with nine calls: four cropped corners, three visible objects and two fully invisible objects. It continues servicing frame waits. This is an aligned first implementation, not arbitrary-pixel clipping or a complete game renderer. Actual CPU/native-scene execution and rejected broken clipping/source-crop controls are recorded in `docs/sprite-clipping/verification/`; the guard checks retained bindings, not fresh runtime execution.
