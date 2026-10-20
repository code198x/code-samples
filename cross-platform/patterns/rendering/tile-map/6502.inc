; Byte map, caller-owned zero-page context TM..TM+19. See README.md.
; A/X/Y/flags clobbered. Decimal flag must be clear. No IRQ/stack ownership.
tile_locate:
    lda #0
    sta TM+7
    lda TM+4
    cmp TM+2
    bcs tile_locate_done
    lda TM+5
    cmp TM+3
    bcs tile_locate_done
    lda TM
    sta TM+8
    lda TM+1
    sta TM+9
    lda TM+5
    sta TM+10
    beq tile_column
tile_rows:
    clc
    lda TM+8
    adc TM+2
    sta TM+8
    bcc tile_no_carry
    inc TM+9
tile_no_carry:
    dec TM+10
    bne tile_rows
tile_column:
    clc
    lda TM+8
    adc TM+4
    sta TM+8
    bcc tile_address_ready
    inc TM+9
tile_address_ready:
    lda #1
    sta TM+7
tile_locate_done:
    rts

tile_get:
    jsr tile_locate
    lda TM+7
    beq tile_get_invalid
    ldy #0
    lda (TM+8),y
    sta TM+6
    rts
tile_get_invalid:
    lda #0
    sta TM+6
    rts

tile_set:
    lda #0
    sta TM+7
    lda TM+6
    cmp TM+14
    bcc tile_set_id_ok
    beq tile_set_id_ok
    rts
tile_set_id_ok:
    jsr tile_locate
    lda TM+7
    beq tile_set_done
    ldy #0
    lda TM+6
    sta (TM+8),y
tile_set_done:
    rts

tile_property:
    lda #0
    sta TM+7
    sta TM+11
    lda TM+6
    cmp TM+14
    bcc tile_property_ok
    beq tile_property_ok
    rts
tile_property_ok:
    tay
    lda (TM+12),y
    sta TM+11
    lda #1
    sta TM+7
    rts

; Unsigned 16-bit world X/Y -> eight-unit cells. Does not mutate X/Y.
tile_pixel8:
    lda #0
    sta TM+7
    sta TM+6
    lda TM+16
    sta TM+4
    lda TM+17
    sta TM+15
    ldx #3
tile_shift_x:
    lsr TM+15
    ror TM+4
    dex
    bne tile_shift_x
    lda TM+15
    bne tile_pixel_done
    lda TM+18
    sta TM+5
    lda TM+19
    sta TM+15
    ldx #3
tile_shift_y:
    lsr TM+15
    ror TM+5
    dex
    bne tile_shift_y
    lda TM+15
    bne tile_pixel_done
    jsr tile_get
tile_pixel_done:
    rts
