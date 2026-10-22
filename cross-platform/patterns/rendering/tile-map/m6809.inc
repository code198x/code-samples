; Byte map: caller-owned TM..TM+19, big-endian 16-bit fields.
; A/B/D, X and CC clobbered. Y/U/DP preserved; S must be a valid stack.
; No IRQ masking or stack allocation. Context/map/property ranges must not wrap.
tile_locate:
    clr TM+7
    lda TM+4
    cmpa TM+2
    bhs tile_locate_done
    lda TM+5
    cmpa TM+3
    bhs tile_locate_done
    ldx TM
    lda TM+5
    sta TM+10
    beq tile_column
tile_rows:
    clra
    ldb TM+2
    leax d,x
    dec TM+10
    bne tile_rows
tile_column:
    clra
    ldb TM+4
    leax d,x
    stx TM+8
    lda #1
    sta TM+7
tile_locate_done:
    rts

tile_get:
    jsr tile_locate
    tst TM+7
    beq tile_get_invalid
    ldx TM+8
    lda ,x
    sta TM+6
    rts
tile_get_invalid:
    clr TM+6
    rts

tile_set:
    clr TM+7
    lda TM+6
    cmpa TM+14
    bls tile_set_id_ok
    rts
tile_set_id_ok:
    jsr tile_locate
    tst TM+7
    beq tile_set_done
    ldx TM+8
    lda TM+6
    sta ,x
tile_set_done:
    rts

tile_property:
    clr TM+7
    clr TM+11
    lda TM+6
    cmpa TM+14
    bls tile_property_ok
    rts
tile_property_ok:
    ldx TM+12
    clra
    ldb TM+6
    lda d,x
    sta TM+11
    lda #1
    sta TM+7
    rts

; Unsigned 16-bit world X/Y -> eight-unit cells; inputs unchanged.
tile_pixel8:
    clr TM+7
    clr TM+6
    ldd TM+16
    lsra
    rorb
    lsra
    rorb
    lsra
    rorb
    tsta
    bne tile_pixel_done
    stb TM+4
    ldd TM+18
    lsra
    rorb
    lsra
    rorb
    lsra
    rorb
    tsta
    bne tile_pixel_done
    stb TM+5
    jsr tile_get
tile_pixel_done:
    rts
