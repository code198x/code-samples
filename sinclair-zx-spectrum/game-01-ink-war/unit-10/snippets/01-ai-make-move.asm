; ----------------------------------------------------------------------------
; AI Make Move
; ----------------------------------------------------------------------------
; AI picks best adjacent cell (or random if none)

ai_make_move:
            ; Find best cell adjacent to AI territory
            call    find_best_adjacent_cell
            ; A = cell index (0-63), or $FF if board full

            cp      $ff
            ret     z               ; No empty cells (shouldn't happen)

            ; Convert index to row/col and set cursor
            ld      b, a
            and     %00000111       ; Column = index AND 7
            ld      (cursor_col), a
            ld      a, b
            rrca
            rrca
            rrca
            and     %00000111       ; Row = index >> 3
            ld      (cursor_row), a

            ; Claim the cell (reuse existing code)
            call    claim_cell
            call    sound_claim

            ; ... switch player, update UI, check game over
