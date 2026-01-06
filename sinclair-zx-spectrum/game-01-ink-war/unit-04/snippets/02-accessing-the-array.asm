;───────────────────────────────────────
; Get board state address
; Input: B = row (0-7), C = column (0-7)
; Output: HL = address in board_state
;───────────────────────────────────────
get_board_addr:
        ld hl, board_state

        ; Add row offset: y × 8
        ld a, b
        rlca                    ; × 2
        rlca                    ; × 4
        rlca                    ; × 8
        ld e, a
        ld d, 0
        add hl, de

        ; Add column offset
        ld a, c
        ld e, a
        ld d, 0
        add hl, de

        ret
