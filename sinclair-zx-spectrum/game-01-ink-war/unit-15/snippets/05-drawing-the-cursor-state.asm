draw_cursor_state:
        ld a, (cursor_visible)
        or a
        jr z, .hide_cursor

        ; Show cursor - set BRIGHT
        ld a, (hl)
        set 6, a                ; Set BRIGHT bit
        ld (hl), a

        inc hl
        ld a, (hl)
        set 6, a
        ld (hl), a

        ld de, 31
        add hl, de

        ld a, (hl)
        set 6, a
        ld (hl), a

        inc hl
        ld a, (hl)
        set 6, a
        ld (hl), a

        ret

.hide_cursor:
        ; Hide cursor - clear BRIGHT
        ld a, (hl)
        res 6, a                ; Clear BRIGHT bit
        ld (hl), a

        inc hl
        ld a, (hl)
        res 6, a
        ld (hl), a

        ld de, 31
        add hl, de

        ld a, (hl)
        res 6, a
        ld (hl), a

        inc hl
        ld a, (hl)
        res 6, a
        ld (hl), a

        ret
