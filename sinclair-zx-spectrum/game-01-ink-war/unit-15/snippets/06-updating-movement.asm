clear_cursor:
        ; Clear BRIGHT (not FLASH anymore)
        ld a, (hl)
        res 6, a
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
