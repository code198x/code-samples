    ; Load palette data into PPU
    bit PPUSTATUS           ; Reset address latch
    lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR             ; PPU address = $3F00 (palette)

    ldx #0
@load_palette:
    lda palette_data, x
    sta PPUDATA
    inx
    cpx #32
    bne @load_palette
