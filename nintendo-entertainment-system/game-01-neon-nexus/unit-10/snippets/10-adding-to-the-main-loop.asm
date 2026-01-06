playing_state:
    lda invuln_timer
    beq @no_invuln
    dec invuln_timer
@no_invuln:

    jsr read_controller
    jsr update_player
    jsr move_enemies
    jsr check_item_collision
    jsr check_enemy_collision
    jsr update_sound            ; <-- Add this
    jsr update_player_sprite
    jsr update_enemy_sprites
    jsr update_item_sprite

    jmp game_loop
