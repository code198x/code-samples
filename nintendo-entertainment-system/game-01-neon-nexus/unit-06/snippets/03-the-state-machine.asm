forever:
    lda frame_counter
@wait:
    cmp frame_counter
    beq @wait

    lda game_state
    cmp #STATE_GAMEOVER
    beq @handle_gameover

    ; STATE_PLAYING: normal gameplay
    jsr read_controller
    jsr update_player
    jsr move_enemies
    jsr update_enemy_sprites
    jsr update_item_sprite
    jsr check_item_collision
    jsr check_enemy_collision
    jmp forever

@handle_gameover:
    ; Check for restart
    jsr read_controller
    lda buttons
    and #BTN_START
    beq @no_restart
    jsr reset_game
@no_restart:
    jmp forever
