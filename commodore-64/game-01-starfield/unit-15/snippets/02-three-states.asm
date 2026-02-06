        ; --- State dispatch ---
        lda game_state
        beq title_state         ; 0 = title
        cmp #$02
        beq game_over_state     ; 2 = game over
        jmp game_active         ; 1 = playing

title_state:
        ; Redraw title text (repairs any star damage)
        jsr show_title

        ; Poll fire button
        lda $dc00
        and #%00010000
        bne state_done          ; Not pressed

        ; Fire pressed — start the game
        jsr clear_screen
        jsr init_game
        jmp game_loop

game_over_state:
        ; Redraw game over text (repairs any star damage)
        jsr show_game_over

        ; Poll fire button
        lda $dc00
        and #%00010000
        bne state_done          ; Not pressed

        ; Fire pressed — return to title
        jsr clear_screen
        jsr init_title
        jmp game_loop

state_done:
        jmp game_loop
