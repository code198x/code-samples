; Main loop with game state checking

main_loop:
        halt

        ; Check game state - only process input if playing
        ld a, (game_state)
        cp STATE_GAME_OVER
        jr z, game_over_loop

        ; Still playing - process input
        call read_keys
        call move_cursor
        call check_claim
        jr main_loop

game_over_loop:
        ; Game is over - just loop
        ; (next unit adds winner display)
        jr main_loop
