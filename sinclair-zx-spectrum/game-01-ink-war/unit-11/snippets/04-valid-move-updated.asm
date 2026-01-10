; Updated valid_move routine
; Now checks for game end before switching players

valid_move:
        call get_board_state_address
        ld a, (current_player)
        ld (hl), a
        call update_cell_display
        call play_success_sound
        ld a, 4
        out (BORDER_PORT), a
        call short_delay
        xor a
        out (BORDER_PORT), a

        ; Update scores after claim
        call draw_scores

        ; Check if game has ended
        call check_game_end

        ; If game over, don't switch players
        ld a, (game_state)
        cp STATE_GAME_OVER
        ret z               ; Game over - return early

        call switch_player
        ret
