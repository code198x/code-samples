.proc load_palette
    ; Set PPU address to palette ($3F00)
    bit PPUSTATUS           ; Reset address latch
    lda #$3f
    sta PPUADDR
    lda #$00
    sta PPUADDR
