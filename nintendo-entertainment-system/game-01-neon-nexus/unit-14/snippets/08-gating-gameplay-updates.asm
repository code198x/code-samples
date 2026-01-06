playing_state:
    jsr read_controller
    jsr check_pause

    ; If paused, skip all gameplay updates
    lda pause_flag
    bne @skip_gameplay

    ; Normal gameplay
    inc frame_counter

    lda invuln_timer
    beq @no_invuln
    dec invuln_timer
@no_invuln:

    jsr update_player
    jsr move_enemies
    jsr check_item_collision
    jsr check_enemy_collision
    jsr update_sound

@skip_gameplay:
    ; Always update sprites (so player stays visible)
    jsr update_player_sprite
    jsr update_enemy_sprites
    jsr update_item_sprite

    jmp game_loop
