;───────────────────────────────────────
; Clear cursor highlight (reset FLASH)
; Input: HL = address of top-left attribute
;───────────────────────────────────────
clear_cursor:
        ; Top-left
        ld a, (hl)
        res 7, a
        ld (hl), a

        ; Top-right
        inc hl
        ld a, (hl)
        res 7, a
        ld (hl), a

        ; Move to bottom-left
        ld de, 31
        add hl, de

        ; Bottom-left
        ld a, (hl)
        res 7, a
        ld (hl), a

        ; Bottom-right
        inc hl
        ld a, (hl)
        res 7, a
        ld (hl), a

        ret
