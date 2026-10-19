; SPDX-License-Identifier: MIT
; draw_clipped: clip_ptr -> 32-byte context; +0 signed X in byte columns,
; +14 signed Y in pixel rows, +28 source pointer (64 interleaved KEEP/image
; bytes for a 16x16 sprite). Remaining context is work and clip outputs.
; MODE4 standard unscrolled $5800..$7fff. No attributes or OS/display setup.
; A/X/Y/P change. D=0. Own ZP $70..$78 and context, exclude interrupt users.
; This implementation pushes TWO source bytes per
; row, in addition to JSR returns and IRQ use. No static background storage.
source_ptr=$72
screen_ptr=$74
row_ptr=$76
mask_byte=$78
draw_clipped:
    ldy #2
    lda #2
    sta (clip_ptr),y
    iny
    lda #0
    sta (clip_ptr),y
    iny
    lda #40
    sta (clip_ptr),y
    iny
    lda #0
    sta (clip_ptr),y
    jsr clip_axis
    ldy #10
    lda (clip_ptr),y
    bne draw_clip_y
    rts
draw_clip_y:
    clc
    lda clip_ptr
    adc #14
    sta clip_ptr
    bcc draw_y_pointer
    inc clip_ptr+1
draw_y_pointer:
    ldy #2
    lda #16
    sta (clip_ptr),y
    iny
    lda #0
    sta (clip_ptr),y
    iny
    sta (clip_ptr),y
    iny
    lda #1
    sta (clip_ptr),y
    jsr clip_axis
    sec
    lda clip_ptr
    sbc #14
    sta clip_ptr
    bcs draw_context_restored
    dec clip_ptr+1
draw_context_restored:
    ldy #24
    lda (clip_ptr),y
    bne draw_visible
    rts
draw_visible:
    ldy #30
    sta (clip_ptr),y
    ; source = original + skipped_rows*4 + skipped_columns*2.
    ldy #22
    lda (clip_ptr),y
    asl
    asl
    tax
    ldy #8
    lda (clip_ptr),y
    asl
    sta mask_byte
    txa
    clc
    adc mask_byte
    ldy #28
    adc (clip_ptr),y
    sta source_ptr
    iny
    lda (clip_ptr),y
    adc #0
    sta source_ptr+1
    ; MODE4: base + (y/8)*320 + x*8 + (y mod 8).
    lda #0
    sta row_ptr+1
    ldy #20
    lda (clip_ptr),y
    and #7
    sta mask_byte
    ldy #6
    lda (clip_ptr),y
    asl
    rol row_ptr+1
    asl
    rol row_ptr+1
    asl
    rol row_ptr+1
    ora mask_byte
    sta row_ptr
    lda row_ptr+1
    clc
    adc #$58
    sta row_ptr+1
    ldy #20
    lda (clip_ptr),y
    lsr
    lsr
    lsr
    tax
    beq draw_clipped_row
draw_cell_row:
    clc
    lda row_ptr
    adc #64
    sta row_ptr
    lda row_ptr+1
    adc #1
    sta row_ptr+1
    dex
    bne draw_cell_row
draw_clipped_row:
    lda row_ptr
    sta screen_ptr
    lda row_ptr+1
    sta screen_ptr+1
    lda source_ptr+1
    pha
    lda source_ptr
    pha
    ldy #10
    lda (clip_ptr),y
    tax
draw_clipped_byte:
    ldy #0
    lda (source_ptr),y
    sta mask_byte
    lda (screen_ptr),y
    and mask_byte
    iny
    ora (source_ptr),y
    dey
    sta (screen_ptr),y
    clc
    lda source_ptr
    adc #2
    sta source_ptr
    bcc draw_source_ready
    inc source_ptr+1
draw_source_ready:
    clc
    lda screen_ptr
    adc #8
    sta screen_ptr
    bcc draw_screen_ready
    inc screen_ptr+1
draw_screen_ready:
    dex
    bne draw_clipped_byte
    pla
    sta source_ptr
    pla
    sta source_ptr+1
    ldy #30
    lda (clip_ptr),y
    sec
    sbc #1
    sta (clip_ptr),y
    bne draw_next_row
    rts
draw_next_row:
    clc
    lda source_ptr
    adc #4
    sta source_ptr
    bcc draw_source_row
    inc source_ptr+1
draw_source_row:
    inc row_ptr
    bne draw_row_carry_ready
    inc row_ptr+1
draw_row_carry_ready:
    lda row_ptr
    and #7
    bne draw_clipped_row
    clc
    lda row_ptr
    adc #$38
    sta row_ptr
    lda row_ptr+1
    adc #1
    sta row_ptr+1
    jmp draw_clipped_row
