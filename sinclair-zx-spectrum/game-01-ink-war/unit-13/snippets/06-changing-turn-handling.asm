; Check game mode
        ld a, (game_mode)
        cp 1
        jr nz, .two_player

        ; AI's turn (mode 1 only)
        call ai_think_delay
        call ai_pick_move
        call ai_make_move
        ret

.two_player:
        ; Switch to other player (mode 2)
        ld a, (current_player)
        cp 1
        jr nz, .switch_to_p1

        ; Switch to P2
        ld a, 2
        ld (current_player), a
        call update_ui_colours
        ret

.switch_to_p1:
        ; Switch to P1
        ld a, 1
        ld (current_player), a
        call update_ui_colours
        ret
