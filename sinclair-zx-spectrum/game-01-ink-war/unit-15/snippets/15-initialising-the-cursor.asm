init_game:
        ; ... existing code ...

        ; Initialise cursor blink
        ld a, CURSOR_BLINK
        ld (cursor_timer), a
        ld a, 1
        ld (cursor_visible), a

        ; Highlight cursor
        ld b, 0
        ld c, 1
        call get_cell_addr
        call highlight_cursor

        ; ... rest of init ...
