highlight_cursor:
        ; Reset blink timer and make visible
        ld a, CURSOR_BLINK
        ld (cursor_timer), a
        ld a, 1
        ld (cursor_visible), a

        ; Set BRIGHT
        ld a, (hl)
        set 6, a
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
