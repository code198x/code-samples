; SPDX-License-Identifier: MIT
; phase_draw_clipped: clip_ptr -> 32-byte context; +0 signed X in byte columns,
; +14 signed Y in pixel rows, +28 source pointer (96 interleaved KEEP/image
; bytes for a 24x16 sprite). Remaining context is work and clip outputs.
; MODE4 standard unscrolled $5800..$7fff. No attributes or OS/display setup.
; A/X/Y/P change. D=0. Own ZP $70..$78 and context, exclude interrupt users.
; This implementation pushes TWO source bytes per
; row, in addition to JSR returns and IRQ use. No static background storage.
phase_source_ptr=$72
phase_screen_ptr=$74
phase_row_ptr=$76
phase_mask_byte=$78
phase_draw_clipped:
    ldy #2
    lda #3
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
    bne phase_draw_clip_y
    rts
phase_draw_clip_y:
    clc
    lda clip_ptr
    adc #14
    sta clip_ptr
    bcc phase_draw_y_pointer
    inc clip_ptr+1
phase_draw_y_pointer:
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
    bcs phase_draw_context_restored
    dec clip_ptr+1
phase_draw_context_restored:
    ldy #24
    lda (clip_ptr),y
    bne phase_draw_visible
    rts
phase_draw_visible:
    ldy #30
    sta (clip_ptr),y
    ; source = original + skipped_rows*6 + skipped_columns*2.
    ldy #22
    lda (clip_ptr),y
    asl
    sta phase_mask_byte
    asl
    clc
    adc phase_mask_byte
    tax
    ldy #8
    lda (clip_ptr),y
    asl
    sta phase_mask_byte
    txa
    clc
    adc phase_mask_byte
    ldy #28
    adc (clip_ptr),y
    sta phase_source_ptr
    iny
    lda (clip_ptr),y
    adc #0
    sta phase_source_ptr+1
    ; MODE4: base + (y/8)*320 + x*8 + (y mod 8).
    lda #0
    sta phase_row_ptr+1
    ldy #20
    lda (clip_ptr),y
    and #7
    sta phase_mask_byte
    ldy #6
    lda (clip_ptr),y
    asl
    rol phase_row_ptr+1
    asl
    rol phase_row_ptr+1
    asl
    rol phase_row_ptr+1
    ora phase_mask_byte
    sta phase_row_ptr
    lda phase_row_ptr+1
    clc
    adc #$58
    sta phase_row_ptr+1
    ldy #20
    lda (clip_ptr),y
    lsr
    lsr
    lsr
    tax
    beq phase_draw_clipped_row
phase_draw_cell_row:
    clc
    lda phase_row_ptr
    adc #64
    sta phase_row_ptr
    lda phase_row_ptr+1
    adc #1
    sta phase_row_ptr+1
    dex
    bne phase_draw_cell_row
phase_draw_clipped_row:
    lda phase_row_ptr
    sta phase_screen_ptr
    lda phase_row_ptr+1
    sta phase_screen_ptr+1
    lda phase_source_ptr+1
    pha
    lda phase_source_ptr
    pha
    ldy #10
    lda (clip_ptr),y
    tax
phase_draw_clipped_byte:
    ldy #0
    lda (phase_source_ptr),y
    sta phase_mask_byte
    lda (phase_screen_ptr),y
    and phase_mask_byte
    iny
    ora (phase_source_ptr),y
    dey
    sta (phase_screen_ptr),y
    clc
    lda phase_source_ptr
    adc #2
    sta phase_source_ptr
    bcc phase_draw_source_ready
    inc phase_source_ptr+1
phase_draw_source_ready:
    clc
    lda phase_screen_ptr
    adc #8
    sta phase_screen_ptr
    bcc phase_draw_screen_ready
    inc phase_screen_ptr+1
phase_draw_screen_ready:
    dex
    bne phase_draw_clipped_byte
    pla
    sta phase_source_ptr
    pla
    sta phase_source_ptr+1
    ldy #30
    lda (clip_ptr),y
    sec
    sbc #1
    sta (clip_ptr),y
    bne phase_draw_next_row
    rts
phase_draw_next_row:
    clc
    lda phase_source_ptr
    adc #6
    sta phase_source_ptr
    bcc phase_draw_source_row
    inc phase_source_ptr+1
phase_draw_source_row:
    inc phase_row_ptr
    bne phase_draw_row_carry_ready
    inc phase_row_ptr+1
phase_draw_row_carry_ready:
    lda phase_row_ptr
    and #7
    bne phase_draw_clipped_row
    clc
    lda phase_row_ptr
    adc #$38
    sta phase_row_ptr
    lda phase_row_ptr+1
    adc #1
    sta phase_row_ptr+1
    jmp phase_draw_clipped_row
