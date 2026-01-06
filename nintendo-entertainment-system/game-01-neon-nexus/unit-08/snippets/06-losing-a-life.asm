respawn_player:
    ; Reset to spawn position
    lda #SPAWN_X
    sta player_x
    lda #SPAWN_Y
    sta player_y

    ; Grant invulnerability
    lda #INVULN_TIME
    sta invuln_timer

    rts
