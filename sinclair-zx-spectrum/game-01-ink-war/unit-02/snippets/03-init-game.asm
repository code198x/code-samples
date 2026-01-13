; ----------------------------------------------------------------------------
; Initialise Game State
; ----------------------------------------------------------------------------

init_game:
            ; Clear board state (all empty)
            ld      hl, board_state
            ld      b, 64
            xor     a
.clear_loop:
            ld      (hl), a
            inc     hl
            djnz    .clear_loop

            ; Player 1 starts
            ld      a, 1
            ld      (current_player), a

            ; Cursor at top-left
            xor     a
            ld      (cursor_row), a
            ld      (cursor_col), a

            ret
