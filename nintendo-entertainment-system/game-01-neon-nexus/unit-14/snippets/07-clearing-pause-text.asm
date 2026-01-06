clear_pause_text:
    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$CD
    sta PPUADDR

    lda #0              ; empty tile
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    rts
