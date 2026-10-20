; NR is 32 caller-owned bytes. Same scalar/compile-time contract; 6809
; pointers in scratch NR+20..27 are big-endian. A/B/X/CC clobbered.
region_draw
    clr NR+6
    lda NR+4
    bne bounds_nonzero_0
    rts
bounds_nonzero_0
    lda NR+0
    cmpa #MAP_W
    blo bounds_start_0
    rts
bounds_start_0
    lda #MAP_W
    suba NR+0
    cmpa NR+4
    bhs bounds_fit_0
    rts
bounds_fit_0
    lda NR+5
    bne bounds_nonzero_1
    rts
bounds_nonzero_1
    lda NR+1
    cmpa #MAP_H
    blo bounds_start_1
    rts
bounds_start_1
    lda #MAP_H
    suba NR+1
    cmpa NR+5
    bhs bounds_fit_1
    rts
bounds_fit_1
    lda NR+4
    bne bounds_nonzero_2
    rts
bounds_nonzero_2
    lda NR+2
    cmpa #SCREEN_COLS
    blo bounds_start_2
    rts
bounds_start_2
    lda #SCREEN_COLS
    suba NR+2
    cmpa NR+4
    bhs bounds_fit_2
    rts
bounds_fit_2
    lda NR+5
    bne bounds_nonzero_3
    rts
bounds_nonzero_3
    lda NR+3
    cmpa #SCREEN_ROWS
    blo bounds_start_3
    rts
bounds_start_3
    lda #SCREEN_ROWS
    suba NR+3
    cmpa NR+5
    bhs bounds_fit_3
    rts
bounds_fit_3
    clr NR+29
region_pass
    clr NR+16
region_row
    clr NR+17
region_cell
    ldx #MAP
    lda NR+1
    adda NR+16
    beq source_column
source_row
    leax MAP_W,x
    deca
    bne source_row
source_column
    ldb NR
    addb NR+17
    lda b,x
    sta NR+19
    cmpa #TILE_COUNT
    blo region_id_ok
    rts
region_id_ok
    tst NR+29
    beq region_next
    jsr region_paint
region_next
    inc NR+17
    lda NR+17
    cmpa NR+4
    beq region_row_done
    jmp region_cell
region_row_done
    inc NR+16
    lda NR+16
    cmpa NR+5
    beq region_pass_done
    jmp region_row
region_pass_done
    tst NR+29
    bne region_success
    inc NR+29
    jmp region_pass
region_success
    lda #1
    sta NR+6
    rts
region_paint
    clra
    ldb NR+19
    lslb
    rola
    lslb
    rola
    lslb
    rola
    addd #TILES
    std NR+24
    clr NR+18
region_scanline
    ldb NR+3
    addb NR+16
    lslb
    lslb
    lslb
    addb NR+18
    ; B-indexed addressing is signed on 6809: use unsigned D for rows >=128.
    clra
    ldx #bitmap_lo
    lda d,x
    sta NR+23
    clra
    ldx #bitmap_hi
    lda d,x
    sta NR+22
    clra
    ldb NR+2
    addb NR+17
    addd NR+22
    std NR+22
    ldx NR+24
    lda ,x+
    stx NR+24
    ldx NR+22
    sta ,x
    inc NR+18
    lda NR+18
    cmpa #8
    bne region_scanline
    rts
