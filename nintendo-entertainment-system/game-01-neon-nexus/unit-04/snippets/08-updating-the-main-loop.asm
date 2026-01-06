forever:
    lda frame_counter
@wait:
    cmp frame_counter
    beq @wait

    jsr read_controller
    jsr update_player
    jsr move_enemies
    jsr update_enemy_sprites

    jmp forever
