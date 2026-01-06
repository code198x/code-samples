;───────────────────────────────────────
; Move cursor up
;───────────────────────────────────────
move_up:
        ld a, (cursor_y)
        or a                    ; At row 0?
        ret z                   ; Yes - can't go up

        ; Clear old cursor
        call get_cursor_addr
        call clear_cursor

        ; Update position
        ld a, (cursor_y)
        dec a
        ld (cursor_y), a

        ; Highlight new cursor
        call get_cursor_addr
        call highlight_cursor
        ret

;───────────────────────────────────────
; Move cursor down
;───────────────────────────────────────
move_down:
        ld a, (cursor_y)
        cp 7                    ; At row 7?
        ret z                   ; Yes - can't go down

        call get_cursor_addr
        call clear_cursor

        ld a, (cursor_y)
        inc a
        ld (cursor_y), a

        call get_cursor_addr
        call highlight_cursor
        ret

;───────────────────────────────────────
; Move cursor left
;───────────────────────────────────────
move_left:
        ld a, (cursor_x)
        or a                    ; At column 0?
        ret z

        call get_cursor_addr
        call clear_cursor

        ld a, (cursor_x)
        dec a
        ld (cursor_x), a

        call get_cursor_addr
        call highlight_cursor
        ret

;───────────────────────────────────────
; Move cursor right
;───────────────────────────────────────
move_right:
        ld a, (cursor_x)
        cp 7                    ; At column 7?
        ret z

        call get_cursor_addr
        call clear_cursor

        ld a, (cursor_x)
        inc a
        ld (cursor_x), a

        call get_cursor_addr
        call highlight_cursor
        ret
