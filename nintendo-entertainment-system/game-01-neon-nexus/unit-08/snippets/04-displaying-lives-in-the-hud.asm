draw_hud:
    ; --- Draw Score (existing code) ---
    lda #$20            ; nametable 0, row 0
    sta PPUADDR
    lda #$02            ; column 2
    sta PPUADDR

    ; Draw hundreds digit
    lda score+1
    jsr div10
    clc
    adc #4              ; tile 4 = digit '0'
    sta PPUDATA

    ; Draw tens digit
    lda temp
    jsr div10
    clc
    adc #4
    sta PPUDATA

    ; Draw ones digit
    lda temp
    clc
    adc #4
    sta PPUDATA

    ; --- Draw Lives ---
    lda #$20            ; nametable 0, row 0
    sta PPUADDR
    lda #$1A            ; column 26 (right side)
    sta PPUADDR

    lda lives
    clc
    adc #4              ; convert to digit tile
    sta PPUDATA

    ; Reset scroll after PPU writes
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

    rts
