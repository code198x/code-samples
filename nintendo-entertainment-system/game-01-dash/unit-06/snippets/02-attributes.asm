    ; --- Set ground palette (attribute table) ---
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$F0
    sta PPUADDR             ; PPU address $23F0 (attribute row 6)

    lda #$50                ; Palette 1 for bottom quadrants (rows 26-27)
    ldx #8
@write_attr6:
    sta PPUDATA
    dex
    bne @write_attr6

    lda #$05                ; Palette 1 for top quadrants (rows 28-29)
    ldx #8
@write_attr7:
    sta PPUDATA
    dex
    bne @write_attr7
