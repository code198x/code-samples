        ; --- Check game state ---
        lda game_state
        beq game_active

        ; --- Game over: poll fire button ---
        lda $dc00
        and #%00010000
        bne game_loop           ; Not pressed, keep waiting

        ; Fire pressed — restart the game
        jsr clear_screen
        jsr init_game
        jmp game_loop

game_active:
        ; ... input, movement, collision code continues here
