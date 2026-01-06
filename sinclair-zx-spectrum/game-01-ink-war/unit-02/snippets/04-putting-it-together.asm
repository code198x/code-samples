start:
        ; Set up the display
        ld a, 0
        out (254), a            ; Black border
        call clear_screen
        call draw_board

        ; Highlight cursor at starting position
        ld a, (cursor_y)
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_cell_addr
        call highlight_cursor

        ; Main loop (just wait for now)
.hang:
        halt
        jr .hang
