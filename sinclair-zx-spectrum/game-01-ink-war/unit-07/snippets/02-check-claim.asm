; Check if Space was pressed and try to claim

check_claim:
        bit 4, d                ; Space pressed? (bit 4)
        ret z                   ; No - return

        ; Calculate board index
        ld a, (cursor_row)
        add a, a                ; ×2
        add a, a                ; ×4
        add a, a                ; ×8
        ld hl, board_state
        ld e, a
        ld d, 0
        add hl, de              ; + (row × 8)

        ld a, (cursor_col)
        ld e, a
        add hl, de              ; + column

        ; HL now points to this cell's state
        ld a, (hl)
        or a                    ; Is it empty (0)?
        jr nz, cant_claim       ; Not empty - reject

        ; Claim it!
        ld a, (current_player)
        ld (hl), a              ; Store in board_state
        call update_display     ; Show the colour
        ret

cant_claim:
        ; Flash border red - invalid move
        ret
