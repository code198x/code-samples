;───────────────────────────────────────
; Claim the current cell for the current player
; Checks validity before claiming
;───────────────────────────────────────
claim_cell:
        ; Get cursor position
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a

        ; Check if empty
        call get_board_addr
        ld a, (hl)
        or a
        ret nz                  ; Not empty - can't claim

        ; Check if adjacent to our territory
        call check_adjacency
        ret nz                  ; Not adjacent - invalid move

        ; Valid! Claim it
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_board_addr
        ld a, (current_player)
        ld (hl), a              ; Update board state

        ; Update display
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_cell_addr
        call set_cell_colour

        ; Swap to other player
        call swap_player
        ret
