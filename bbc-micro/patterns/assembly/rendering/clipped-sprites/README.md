# Clip masked BBC MODE4 sprites

Build with `make ASM198X=/path/to/asm198x`; type `build/loader.bas` into Model B MOS1.20/BASICII. It selects MODE4 and reserves memory with HIMEM=&3000. The machine-code caller owns $3000 onwards and the unscrolled $5800..$7fff bitmap; it uses MOS OSBYTE19 with IRQs active. Reset to exit.

Include `clip.inc` and `draw.inc` once. Set `clip_ptr` ($70/$71) to 32 exclusive caller bytes: signed X at +0 (eight-pixel byte columns), signed Y at +14 (pixel rows), source pointer +28. Source: 64 interleaved keep-mask/image bytes for a 16×16 image; original stride four bytes. A keep-mask 1 retains scenery, and corresponding image bits must be zero. Each 14-byte axis block returns destination +6, source skip +8, count +10; +12..13 is scratch. The wrapper sets its own fixed extents/limits; +30 counts rows.

A/X/Y/P change; decimal mode must be clear. The wrapper owns zero-page $70..$78 and the context; interrupt users must preserve them. Source, context, code and stack must not overlap one another or the bitmap. This is specifically the normal unscrolled MODE4 mapping, not a CRTC-addressed wraparound screen. Two source-pointer bytes are pushed per row, plus JSR returns/IRQ needs. No static buffers or OS/display setup live inside the includes.

`clip_axis` intersects one signed-position interval with a viewport. Position is a signed 16-bit word; extent is 0..256, limit is 1..256. It returns destination, source samples to skip, and visible count. All three results are zero when invisible. Negative positions stay signed until the intersection is known; do not convert a negative coordinate into a screen pointer. Inputs outside these extent/limit contracts are not validated.

For a rectangle, clip both axes before drawing. The source still has its ORIGINAL row stride when the visible width shrinks. On a left/top crop, advance to the surviving source column/row; changing only the destination paints the wrong part of the object.

These routines do not erase old objects, save backgrounds, move a camera or schedule drawing. For save-under movement, retain the previous clipped destination AND dimensions and its separate saved buffer, restore overlapping objects in reverse order, update scenery, then clip/save/draw again. A fully invisible object has no rectangle to save or restore. A right-edge object may need a different buffer footprint after moving. See the sibling sprite-lifecycle implementation; never pass an unclipped negative position to its copy helpers.

The demo is an original static scene with nine calls: four cropped corners, three visible objects and two fully invisible objects. It continues servicing frame waits. This is an aligned first implementation, not arbitrary-pixel clipping or a complete game renderer. Actual CPU/native-scene execution and rejected broken clipping/source-crop controls are recorded in `docs/sprite-clipping/verification/`; the guard checks retained bindings, not fresh runtime execution.
