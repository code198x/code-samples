; Erase the cursor (restore to empty cell colour)
; Called before moving so the old position returns to normal

erase_cursor:
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address

        ld a, EMPTY_ATTR        ; Restore to white
        ld (hl), a
        ret

; Pattern: erase at old position, move, draw at new position
; This prevents leaving "ghost" cursors behind
