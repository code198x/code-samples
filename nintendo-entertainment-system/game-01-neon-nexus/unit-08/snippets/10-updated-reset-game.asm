reset_game:
    ; Reset lives
    lda #3
    sta lives

    ; Reset score
    lda #0
    sta score
    sta score+1

    ; Reset positions
    lda #SPAWN_X
    sta player_x
    lda #SPAWN_Y
    sta player_y

    ; Clear invulnerability
    lda #0
    sta invuln_timer

    ; Reinitialise enemies and item
    jsr init_enemies
    jsr respawn_item

    ; Back to playing
    lda #STATE_PLAYING
    sta game_state

    rts
