; Set attribute table address ($23C0)
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$c0
    sta PPUADDR

    ; Fill attributes with zone pattern
    ldx #0
@attr_loop:
    lda attribute_data, x
    sta PPUDATA
    inx
    cpx #64
    bne @attr_loop

    rts
.endproc
