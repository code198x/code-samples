; In ai_make_move, after claiming:
        ld a, (moves_remaining)
        dec a
        ld (moves_remaining), a

        or a
        call z, check_game_over
