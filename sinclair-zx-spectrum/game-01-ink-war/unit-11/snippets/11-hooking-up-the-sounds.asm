move_up:
        ld a, (cursor_y)
        or a
        ret z

        call get_cursor_addr
        call clear_cursor

        ld a, (cursor_y)
        dec a
        ld (cursor_y), a

        call get_cursor_addr
        call highlight_cursor

        ld a, MOVE_DELAY
        ld (move_delay), a
        call beep_move          ; <-- Add this
        ret
