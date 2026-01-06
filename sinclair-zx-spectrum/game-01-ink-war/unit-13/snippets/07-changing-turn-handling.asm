claim_cell:
        ; ... validation code ...

        ; Claim it
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_board_addr
        ld a, (current_player)
        ld (hl), a

        ; Update display
        ; ... display code ...

        call beep_claim

        ; Decrement moves and check for game over
        ld a, (moves_remaining)
        dec a
        ld (moves_remaining), a
        or a
        jp z, check_game_over

        ; Handle turn based on game mode
        ld a, (game_mode)
        cp 1
        jr nz, .human_turn

        ; AI's turn
        call ai_think_delay
        call ai_pick_move
        call ai_make_move
        ret

.human_turn:
        ; Switch players for hotseat
        ld a, (current_player)
        xor 3                   ; Toggle: 1 -> 2, 2 -> 1
        ld (current_player), a
        call update_ui_colours
        ret
