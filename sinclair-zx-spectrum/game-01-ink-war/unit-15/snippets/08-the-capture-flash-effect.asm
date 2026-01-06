capture_flash:
        ; Set BRIGHT on the cell
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

        ; Wait a few frames
        ld b, 6
.flash_wait:
        halt
        djnz .flash_wait

        ; Go back and clear BRIGHT
        ld de, -33
        add hl, de

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
