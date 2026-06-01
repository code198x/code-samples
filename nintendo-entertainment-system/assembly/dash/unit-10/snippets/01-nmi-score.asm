; =============================================================================
; NMI Handler — with score display update
; =============================================================================
; After OAM DMA, the handler writes the current score digit to the nametable.
; PPUADDR sets the write position; PPUDATA writes the tile. Afterward,
; PPUSCROLL must be reset — any PPUADDR write corrupts the scroll position.
; =============================================================================

nmi:
    pha
    txa
    pha
    tya
    pha

    ; --- OAM DMA (sprites) ---
    lda #0
    sta OAMADDR
    lda #>oam_buffer
    sta OAMDMA

    ; --- Update score display on nametable ---
    bit PPUSTATUS           ; Reset address latch
    lda #$20
    sta PPUADDR
    lda #$22
    sta PPUADDR             ; PPU address $2022 (row 1, col 2)
    lda score
    clc
    adc #DIGIT_ZERO         ; Convert score to tile index
    sta PPUDATA

    ; --- Reset scroll (required after PPUADDR writes) ---
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

    lda #1
    sta nmi_flag

    pla
    tay
    pla
    tax
    pla
    rti
