clear_playfield:
    lda PPUSTATUS

    ; Clear rows 8-18 ($2100-$2240)
    lda #$21
    sta PPUADDR
    lda #$00
    sta PPUADDR

    lda #0
    ldx #0
@loop:
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    inx
    cpx #80                 ; 320 tiles = 10 rows
    bne @loop

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    rts
