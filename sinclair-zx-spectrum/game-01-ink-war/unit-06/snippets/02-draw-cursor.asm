; Draw the cursor at its current position
; Uses a distinct colour (bright yellow) to highlight the selected cell

CURSOR_ATTR equ %01110000   ; Bright yellow paper, black ink

draw_cursor:
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address   ; HL = attribute address

        ld a, CURSOR_ATTR
        ld (hl), a
        ret
