;───────────────────────────────────────
; Reset and restart the game
;───────────────────────────────────────
restart_game:
        ; Clear the board state
        ld hl, board_state
        ld b, 64
.clear_board:
        ld (hl), 0
        inc hl
        djnz .clear_board

        ; Reset move counter
        ld a, 62
        ld (moves_remaining), a

        ; Reset cursor
        ld a, 1
        ld (cursor_x), a
        xor a
        ld (cursor_y), a

        ; Reset player
        ld a, 1
        ld (current_player), a

        ; Redraw everything
        call clear_screen
        call draw_board
        call init_starting_cells

        ; Highlight cursor
        ld b, 0
        ld c, 1
        call get_cell_addr
        call highlight_cursor

        ; Set border
        call update_ui_colours

        ; Return to main loop
        jp main_loop
