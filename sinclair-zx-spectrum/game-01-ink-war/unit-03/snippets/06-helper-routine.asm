;───────────────────────────────────────
; Get address for current cursor position
; Output: HL = attribute address
;───────────────────────────────────────
get_cursor_addr:
        ld a, (cursor_y)
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_cell_addr
        ret
