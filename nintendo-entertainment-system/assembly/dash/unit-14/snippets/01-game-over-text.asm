    ; --- Draw "GAME OVER" text (one-shot) ---
    lda game_over
    beq @no_go_text
    lda game_over_drawn
    bne @no_go_text

    ; Write "GAME OVER" at row 14, column 12 ($21CC)
    lda #$21
    sta PPUADDR
    lda #$CC
    sta PPUADDR
    lda #LETTER_G
    sta PPUDATA
    lda #LETTER_A
    sta PPUDATA
    lda #LETTER_M
    sta PPUDATA
    lda #LETTER_E
    sta PPUDATA
    lda #0                  ; Space
    sta PPUDATA
    lda #DIGIT_ZERO         ; O reuses the digit 0 tile
    sta PPUDATA
    lda #LETTER_V
    sta PPUDATA
    lda #LETTER_E
    sta PPUDATA
    lda #LETTER_R
    sta PPUDATA

    lda #1
    sta game_over_drawn

@no_go_text:
