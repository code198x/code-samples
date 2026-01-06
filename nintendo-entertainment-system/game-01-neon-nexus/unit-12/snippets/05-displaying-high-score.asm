draw_game_over:
    ; Hide sprites
    ldx #0
    lda #$FF
@hide:
    sta oam, x
    inx
    bne @hide

    ; "GAME OVER" at row 10
    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$4B                ; row 10, col 11
    sta PPUADDR

    ldx #0
@go_loop:
    lda gameover_text, x
    beq @draw_hi
    sta PPUDATA
    inx
    bne @go_loop

@draw_hi:
    ; "HI" at row 13, col 11
    lda #$21
    sta PPUADDR
    lda #$AB                ; row 13, col 11
    sta PPUADDR

    lda #TILE_H
    sta PPUDATA
    lda #TILE_I
    sta PPUDATA
    lda #0                  ; space
    sta PPUDATA

    ; High score digits
    lda high_score+1
    jsr div10
    clc
    adc #4
    sta PPUDATA

    lda temp
    jsr div10
    clc
    adc #4
    sta PPUDATA

    lda temp
    clc
    adc #4
    sta PPUDATA

    ; Check if new high score
    lda new_high
    beq @done

    ; "NEW" at row 15
    lda #$21
    sta PPUADDR
    lda #$EB                ; row 15, col 11
    sta PPUADDR

    lda #TILE_N
    sta PPUDATA
    lda #TILE_E
    sta PPUDATA
    lda #TILE_W
    sta PPUDATA

@done:
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    rts
