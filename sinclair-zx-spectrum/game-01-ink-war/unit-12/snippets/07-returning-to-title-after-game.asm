restart_game:
        ; Clear board state
        ld hl, board_state
        ld b, 64
.clear_board:
        ld (hl), 0
        inc hl
        djnz .clear_board

        ; Return to title instead of restarting immediately
        jp start
