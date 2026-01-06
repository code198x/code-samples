;───────────────────────────────────────
; Initialise a new game
;───────────────────────────────────────
init_game:
        call clear_screen
        call draw_board
        call init_starting_cells

        ; Position cursor
        ld a, 1
        ld (cursor_x), a
        xor a
        ld (cursor_y), a

        ; Reset move counter
        ld a, 62
        ld (moves_remaining), a

        ; Reset player
        ld a, 1
        ld (current_player), a

        ; Highlight cursor
        ld b, 0
        ld c, 1
        call get_cell_addr
        call highlight_cursor

        call update_ui_colours

        ret
