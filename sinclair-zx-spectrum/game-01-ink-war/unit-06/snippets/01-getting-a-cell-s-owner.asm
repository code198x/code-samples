;───────────────────────────────────────
; Get the owner of a cell
; Input: B = row (0-7), C = column (0-7)
; Output: A = owner (0=empty, 1=Player 1, 2=Player 2)
;───────────────────────────────────────
get_owner:
        call get_board_addr     ; HL = address in board_state
        ld a, (hl)              ; A = owner
        ret
