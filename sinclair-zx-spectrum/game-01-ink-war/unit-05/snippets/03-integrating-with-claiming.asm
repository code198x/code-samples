;───────────────────────────────────────
; Claim the current cell for the current player
; Swaps player after successful claim
;───────────────────────────────────────
claim_cell:
        ; Get cursor position
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a

        ; Get board state address
        call get_board_addr

        ; Check if already owned
        ld a, (hl)
        or a
        jr z, .claim_it         ; Empty - can claim

        ; Already owned by someone
        ld a, (current_player)
        cp (hl)
        ret z                   ; Already ours - do nothing
        ; Owned by opponent - can't claim (for now)
        ret

.claim_it:
        ; Mark cell as owned
        ld a, (current_player)
        ld (hl), a

        ; Update the display
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_cell_addr
        call set_cell_colour

        ; Swap to other player
        call swap_player
        ret
