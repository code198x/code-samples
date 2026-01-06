;───────────────────────────────────────
; Set cell colour directly
; Input: HL = address of top-left attribute
;        B = colour value to set
;───────────────────────────────────────
set_cell_direct:
        ; Top-left
        ld a, (hl)
        and %10000000           ; Keep FLASH bit
        or b
        ld (hl), a

        ; Top-right
        inc hl
        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        ; Move to bottom-left
        ld de, 31
        add hl, de

        ; Bottom-left
        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        ; Bottom-right
        inc hl
        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        ret
