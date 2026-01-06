start:
        ; Clear screen to black
        call clear_screen

        ; Draw the game board
        call draw_board

        ; Give each player a starting corner
        call init_starting_cells

        ; Position cursor at (1,0) - adjacent to Player 1's corner
        ld a, 1
        ld (cursor_x), a
        xor a
        ld (cursor_y), a

        ; Highlight cursor
        ld b, 0
        ld c, 1
        call get_cell_addr
        call highlight_cursor

        ; Set initial turn indicator
        call update_ui_colours

        ; Set up interrupts for timing
        im 1
        ei

main_loop:
        ; ...
