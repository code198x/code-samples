; SPDX-License-Identifier: MIT
; BBC MODE4, byte-aligned 8x8 object. A character cell is eight adjacent bytes.
; Caller sets screen_ptr=$70/$71 to one cell wholly in $5800..$7fff.
; pairs_ptr=$72/$73 addresses 16 interleaved mask/image bytes.
; saved_background[8] and saved_screen[2] belong to ONE live object.
; save -> draw -> restore before moving. Do not overlap independently saved
; objects: restore all in reverse order, then capture/draw the next frame.
; Mask 1 keeps background; image must be 0 there. No clipping/attributes/shift.
; A/Y/flags change, X preserved. Decimal mode clear. MOS IRQ must preserve ZP.
save_background:
    lda screen_ptr
    sta saved_screen
    lda screen_ptr+1
    sta saved_screen+1
    ldy #7
save_background_row:
    lda (screen_ptr),y
    sta saved_background,y
    dey
    bpl save_background_row
    rts
restore_background:
    lda saved_screen
    sta screen_ptr
    lda saved_screen+1
    sta screen_ptr+1
    ldy #7
restore_background_row:
    lda saved_background,y
    sta (screen_ptr),y
    dey
    bpl restore_background_row
    rts
draw_masked_cell:
    ldy #0
masked_cell_row:
    tya
    pha
    asl
    tay
    lda (pairs_ptr),y
    sta mask_byte
    iny
    lda (pairs_ptr),y
    sta image_byte
    pla
    tay
    lda (screen_ptr),y
    and mask_byte
    ora image_byte
    sta (screen_ptr),y
    iny
    cpy #8
    bne masked_cell_row
    rts
screen_ptr=$70
pairs_ptr=$72
saved_screen: !word 0
saved_background: !fill 8,0
mask_byte: !byte 0
image_byte: !byte 0
