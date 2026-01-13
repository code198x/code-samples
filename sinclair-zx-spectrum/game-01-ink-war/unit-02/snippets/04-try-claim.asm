; ----------------------------------------------------------------------------
; Try Claim Cell
; ----------------------------------------------------------------------------

try_claim:
            ; Check if cell is empty
            call    get_cell_state
            or      a
            ret     nz              ; Not empty - can't claim

            ; Claim the cell
            call    claim_cell

            ; Play success sound
            call    sound_claim

            ; Switch player
            ld      a, (current_player)
            xor     3               ; Toggle between 1 and 2
            ld      (current_player), a

            ; Redraw cursor with new state
            call    draw_cursor

            ret
