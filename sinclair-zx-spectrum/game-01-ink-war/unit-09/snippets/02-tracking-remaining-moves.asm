; In claim_cell, after successfully claiming:
        ld a, (moves_remaining)
        dec a
        ld (moves_remaining), a

        ; Check if game is over
        or a
        call z, check_game_over
