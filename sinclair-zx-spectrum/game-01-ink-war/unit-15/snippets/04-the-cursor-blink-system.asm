update_cursor_blink:
        ld a, (cursor_timer)
        dec a
        ld (cursor_timer), a
        ret nz

        ; Timer expired - toggle cursor
        ld a, CURSOR_BLINK
        ld (cursor_timer), a

        ld a, (cursor_visible)
        xor 1                   ; Toggle 0<->1
        ld (cursor_visible), a

        ; Update the display
        call get_cursor_addr
        call draw_cursor_state
        ret
