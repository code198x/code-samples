; Update display
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_cell_addr
        call set_cell_colour

        call beep_claim         ; <-- Add this

        ; Decrement moves...
