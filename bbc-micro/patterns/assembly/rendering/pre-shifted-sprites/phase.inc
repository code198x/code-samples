; SPDX-License-Identifier: MIT
; draw_pixel_sprite: clip_ptr -> 32 bytes, signed PIXEL X +0, Y +14,
; pointer to generated eight-entry phase table +28. Reload before every call:
; X/table become byte X/source pointer. A/X/Y/P change; D=0.
; Owns $70..$78 plus context. Preserve these in interrupt users. No IRQ setup.
draw_pixel_sprite:
    ldy #0
    lda (clip_ptr),y
    and #7
    asl
    sta phase_mask_byte
    ldx #3
phase_divide:
    ldy #1
    lda (clip_ptr),y
    cmp #$80
    ror
    sta (clip_ptr),y
    dey
    lda (clip_ptr),y
    ror
    sta (clip_ptr),y
    dex
    bne phase_divide
    ldy #28
    lda (clip_ptr),y
    sta phase_source_ptr
    iny
    lda (clip_ptr),y
    sta phase_source_ptr+1
    ldy phase_mask_byte
    lda (phase_source_ptr),y
    pha
    iny
    lda (phase_source_ptr),y
    ldy #29
    sta (clip_ptr),y
    pla
    dey
    sta (clip_ptr),y
    jmp phase_draw_clipped
