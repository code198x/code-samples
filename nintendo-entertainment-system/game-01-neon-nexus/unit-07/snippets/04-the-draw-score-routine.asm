.proc draw_score
    ; Set PPU address to score position ($2022)
    bit PPUSTATUS           ; Reset address latch
    lda #$20
    sta PPUADDR
    lda #$22
    sta PPUADDR

    ; Extract and draw hundreds digit
    lda score
    jsr div100              ; A = hundreds, temp = remainder
    clc
    adc #4                  ; Convert to tile index (0 -> tile 4)
    sta PPUDATA

    ; Extract and draw tens digit
    lda temp                ; Remainder from div100
    jsr div10               ; A = tens, temp = ones
    clc
    adc #4
    sta PPUDATA

    ; Draw ones digit
    lda temp
    clc
    adc #4
    sta PPUDATA

    rts
.endproc
