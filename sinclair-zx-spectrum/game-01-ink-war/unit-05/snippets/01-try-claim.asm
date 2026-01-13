; ----------------------------------------------------------------------------
; Try Claim Cell
; ----------------------------------------------------------------------------
; Attempts to claim the current cell. If already claimed, shows error feedback.

try_claim:
            call    get_cell_state
            or      a
            jr      z, .tc_valid

            ; Cell already claimed - error feedback
            call    sound_error
            call    flash_border_error
            call    update_border       ; Restore correct border colour
            ret

.tc_valid:
            ; Valid move - claim the cell
            call    claim_cell
            call    sound_claim

            ld      a, (current_player)
            xor     3
            ld      (current_player), a

            call    draw_ui             ; Update scores and turn indicator
            call    update_border
            call    draw_cursor

            ret
