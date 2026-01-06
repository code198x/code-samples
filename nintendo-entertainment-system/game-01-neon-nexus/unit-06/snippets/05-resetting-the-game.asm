.proc reset_game
    ; Reset game state
    lda #STATE_PLAYING
    sta game_state

    ; Reset score
    lda #0
    sta score

    ; Reset player position
    lda #128
    sta player_x
    lda #200
    sta player_y

    ; Reset enemies
    jsr init_enemies

    ; Reset item
    jsr init_item

    rts
.endproc
