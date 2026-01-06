;───────────────────────────────────────
; Get attribute address for a game cell
; Input: B = row (0-7), C = column (0-7)
; Output: HL = address of top-left attribute
;───────────────────────────────────────
get_cell_addr:
        ld hl, 22664            ; Base address of game board

        ; Add row offset: y × 64
        ld a, b
        rlca                    ; × 2
        rlca                    ; × 4
        rlca                    ; × 8
        rlca                    ; × 16
        rlca                    ; × 32
        rlca                    ; × 64
        ld e, a
        ld d, 0
        add hl, de

        ; Add column offset: x × 2
        ld a, c
        add a, a                ; × 2
        ld e, a
        ld d, 0
        add hl, de

        ret
