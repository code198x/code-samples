;───────────────────────────────────────
; Highlight a cell by setting FLASH
; Input: HL = address of top-left attribute
;───────────────────────────────────────
highlight_cursor:
        ; Top-left
        ld a, (hl)
        set 7, a
        ld (hl), a

        ; Top-right
        inc hl
        ld a, (hl)
        set 7, a
        ld (hl), a

        ; Move to next row (we're at top-right, need bottom-left)
        ; That's 31 bytes forward: 32 - 1 = 31
        ld de, 31
        add hl, de

        ; Bottom-left
        ld a, (hl)
        set 7, a
        ld (hl), a

        ; Bottom-right
        inc hl
        ld a, (hl)
        set 7, a
        ld (hl), a

        ret
