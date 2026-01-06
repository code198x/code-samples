;───────────────────────────────────────
; Set up starting cells for both players
;───────────────────────────────────────
init_starting_cells:
        ; Player 1 gets (0,0) - top-left
        ld hl, board_state
        ld (hl), 1              ; Mark as owned by Player 1

        ; Colour it red
        ld b, 0
        ld c, 0
        call get_cell_addr
        ld a, RED_ON_RED
        ld b, a
        call set_cell_direct    ; New helper (doesn't check current_player)

        ; Player 2 gets (7,7) - bottom-right
        ld hl, board_state + 63 ; Index 63 = row 7, col 7
        ld (hl), 2              ; Mark as owned by Player 2

        ; Colour it cyan
        ld b, 7
        ld c, 7
        call get_cell_addr
        ld a, CYAN_ON_CYAN
        ld b, a
        call set_cell_direct

        ret
