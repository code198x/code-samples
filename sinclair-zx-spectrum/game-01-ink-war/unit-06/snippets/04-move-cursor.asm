; Move cursor based on key input
; D contains newly pressed keys (from read_keys)

move_cursor:
        ld a, d
        and %00001111       ; Mask to direction keys
        ret z               ; No movement? Return early

        call erase_cursor   ; Remove from old position

        ; Check Q (up) - bit 0
        bit 0, d
        jr z, not_up
        ld a, (cursor_row)
        or a                ; At top? (row 0)
        jr z, not_up
        dec a               ; Move up
        ld (cursor_row), a
not_up:

        ; Check A (down) - bit 1
        bit 1, d
        jr z, not_down
        ld a, (cursor_row)
        cp 7                ; At bottom? (row 7)
        jr z, not_down
        inc a               ; Move down
        ld (cursor_row), a
not_down:

        ; (O and P handled similarly)

        call draw_cursor    ; Draw at new position
        ret
