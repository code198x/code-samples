lose_life:
    dec lives

    ; Play death sound
    jsr play_death_sound

    lda lives
    beq @game_over

    jsr respawn_player
    rts

@game_over:
    lda #STATE_GAMEOVER
    sta game_state
    lda #0
    sta screen_drawn
    rts
