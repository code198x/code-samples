; Reset game for a new play
; Called when transitioning from title to playing state

reset_game:
        ; Clear entire board state
        ld hl, board_state
        ld b, 64
        xor a
reset_board:
        ld (hl), a
        inc hl
        djnz reset_board

        ; Reset all game variables
        ld a, PLAYER1
        ld (current_player), a

        xor a
        ld (p1_score), a
        ld (p2_score), a
        ld (winner), a
        ld (prev_keys), a

        ; Reset cursor to centre
        ld a, 3
        ld (cursor_row), a
        ld (cursor_col), a

        ret
