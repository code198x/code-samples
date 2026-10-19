# Save, draw and restore Spectrum software objects

`make` builds `build/demo.tap`. LOAD "" on a 48K Spectrum. Two masked 16x16 objects overlap while one moves in eight-pixel steps over a patterned band. Their old backgrounds are restored in reverse draw order. The caller owns the bitmap/attributes, private stack and ROM IM1 wait; reset to leave.

Include background.inc and the existing bitmap-addressing.inc once. Include masked.inc once with SPRITE_W=2 for this caller; that constant belongs to drawing, while the new rectangle helpers take their own runtime width/height.

For save_rect and restore_rect: DE=top-left bitmap byte, HL=packed caller buffer, B=width in bytes (0..32), C=height in scanlines. Zero width/height is a no-op. Otherwise the whole rectangle must fit the 256x192 bitmap; left column+width<=32 and top row+height<=192. Buffer length is width*height, with no address wrap or overlap with the bitmap, active stack, code or another live save buffer. Attributes are not copied.

AF/BC/DE/HL change; IX/IY survive. HL advances by width*height. Four temporary stack bytes are needed beyond the return address and any interrupt use. No static save state is allocated. pixel_down must preserve BC/DE; IRQs must preserve the active working registers, and no concurrent renderer may modify the owned region.

```z80
    ld de,(old_address)
    ld hl,under_a
    ld bc,$0210          ; 2 bytes wide, 16 pixel rows
    call restore_rect
    ; Choose new address, save_rect, then draw_sprite.
```

Keep one buffer AND the previous screen address per live object. Save/draw A then save/draw B; on the next update restore B then A. Save B may contain part of A, so restoring A first would reintroduce A when B is restored. Restore all objects before changing the background or scrolling, then capture/draw the new frame. If scenery changed while objects were present, redraw from the world rather than blindly restoring stale saved bytes.

This implementation deliberately does not clip, pre-shift or manage object lists. The complete caller demonstrates the two-object ordering without imposing an engine interface. Save plus restore adds two transfers of width*height bytes per object on top of drawing; measure the complete workload before choosing a larger scene.

## Run the verification

From the repository root run `python3 scripts/verify-sprite-lifecycle.py --help`. Supply the released assembler, Build198x and the three native emulators. Firmware defaults to the normal per-user emulator locations and remains local. The retained record identifies source, observers, tools and firmware; cases compare complete byte results with independent composition/restoration expectations. Wrong-order and broken-operation controls must fail those same checks. Complete callers and their captures are separate checks. No original-hardware, tear-free or whole-game frame-budget claim is made.
