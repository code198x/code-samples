; Check if the game has ended (all cells filled)
; Called after each successful claim
; Sets game_state to STATE_GAME_OVER if board is full

check_game_end:
        ; Count empty cells
        ld hl, board_state
        ld bc, TOTAL_CELLS
        ld d, 0             ; Empty cell counter

check_end_loop:
        ld a, (hl)
        or a                ; Is cell empty (0)?
        jr nz, cell_not_empty
        inc d               ; Found an empty cell

cell_not_empty:
        inc hl
        dec bc
        ld a, b
        or c
        jr nz, check_end_loop

        ; D now contains count of empty cells
        ld a, d
        or a                ; Any empty cells left?
        ret nz              ; Yes - game continues

        ; No empty cells - game is over!
        ld a, STATE_GAME_OVER
        ld (game_state), a

        ; Clear the turn indicator (no more turns)
        call clear_turn_indicator

        ret
