init_game:
        ; Clear board state
        ld hl, board_state
        ld b, 64
.clear_board:
        ld (hl), 0
        inc hl
        djnz .clear_board

        call clear_screen
        call draw_board
        call init_starting_cells

        ; ... rest of initialisation
