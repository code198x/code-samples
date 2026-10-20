; Caller defines NR (32 zero-page bytes), MAP/MAP_W/MAP_H, TILES,
; TILE_COUNT (1..16), CELL_BYTES (1/2), SCREEN_COLS/ROWS, X_STEP (1/2/8),
; and bitmap_lo/bitmap_hi (one address per pixel scanline).
; Decimal mode must be clear. A/X/Y/flags and NR+6..31 clobbered.
region_draw:
    lda #0
    sta NR+6
    lda NR+4
    bne bounds_nonzero_0
    rts
bounds_nonzero_0:
    lda NR+0
    cmp #MAP_W
    bcc bounds_start_0
    rts
bounds_start_0:
    lda #MAP_W
    sec
    sbc NR+0
    cmp NR+4
    bcs bounds_fit_0
    rts
bounds_fit_0:
    lda NR+5
    bne bounds_nonzero_1
    rts
bounds_nonzero_1:
    lda NR+1
    cmp #MAP_H
    bcc bounds_start_1
    rts
bounds_start_1:
    lda #MAP_H
    sec
    sbc NR+1
    cmp NR+5
    bcs bounds_fit_1
    rts
bounds_fit_1:
    lda NR+4
    bne bounds_nonzero_2
    rts
bounds_nonzero_2:
    lda NR+2
    cmp #SCREEN_COLS
    bcc bounds_start_2
    rts
bounds_start_2:
    lda #SCREEN_COLS
    sec
    sbc NR+2
    cmp NR+4
    bcs bounds_fit_2
    rts
bounds_fit_2:
    lda NR+5
    bne bounds_nonzero_3
    rts
bounds_nonzero_3:
    lda NR+3
    cmp #SCREEN_ROWS
    bcc bounds_start_3
    rts
bounds_start_3:
    lda #SCREEN_ROWS
    sec
    sbc NR+3
    cmp NR+5
    bcs bounds_fit_3
    rts
bounds_fit_3:
    lda #0
    sta NR+29
region_pass:
    lda #0
    sta NR+16
region_row:
    lda #0
    sta NR+17
region_cell:
    lda #<MAP
    sta NR+20
    lda #>MAP
    sta NR+21
    lda NR+1
    clc
    adc NR+16
    tax
    beq source_column
source_row:
    clc
    lda NR+20
    adc #MAP_W
    sta NR+20
    bcc source_no_carry
    inc NR+21
source_no_carry:
    dex
    bne source_row
source_column:
    lda NR
    clc
    adc NR+17
    tay
    lda (NR+20),y
    sta NR+19
    cmp #TILE_COUNT
    bcc region_id_ok
    rts
region_id_ok:
    lda NR+29
    beq region_next
    jsr region_paint
region_next:
    inc NR+17
    lda NR+17
    cmp NR+4
    beq region_row_done
    jmp region_cell
region_row_done:
    inc NR+16
    lda NR+16
    cmp NR+5
    beq region_pass_done
    jmp region_row
region_pass_done:
    lda NR+29
    bne region_success
    inc NR+29
    jmp region_pass
region_success:
    lda #1
    sta NR+6
    rts
region_paint:
    lda NR+19
    asl
    asl
    asl
!if CELL_BYTES = 2 {
    asl
}
    clc
    adc #<TILES
    sta NR+24
    lda #>TILES
    adc #0
    sta NR+25
    lda #0
    sta NR+18
region_scanline:
    lda NR+3
    clc
    adc NR+16
    asl
    asl
    asl
    clc
    adc NR+18
    tay
    lda bitmap_lo,y
    sta NR+22
    lda bitmap_hi,y
    sta NR+23
    lda #0
    sta NR+28
    lda NR+2
    clc
    adc NR+17
!if X_STEP >= 2 {
    asl
    rol NR+28
}
!if X_STEP = 8 {
    asl
    rol NR+28
    asl
    rol NR+28
}
    clc
    adc NR+22
    sta NR+22
    lda NR+23
    adc NR+28
    sta NR+23
    ldy #0
    lda (NR+24),y
    sta (NR+22),y
!if CELL_BYTES = 2 {
    iny
    lda (NR+24),y
    sta (NR+22),y
}
    clc
    lda NR+24
    adc #CELL_BYTES
    sta NR+24
    bcc paint_no_carry
    inc NR+25
paint_no_carry:
    inc NR+18
    lda NR+18
    cmp #8
    bne region_scanline
    rts
