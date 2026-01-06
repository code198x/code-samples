;───────────────────────────────────────
; Execute the AI's move
;───────────────────────────────────────
ai_make_move:
        ; Check if AI found a valid move
        ld a, (best_score)
        or a
        ret z                   ; No valid moves - AI is stuck

        ; Set current player to AI
        ld a, 2
        ld (current_player), a

        ; Claim the chosen cell
        ld a, (best_y)
        ld b, a
        ld a, (best_x)
        ld c, a
        call get_board_addr
        ld a, 2                 ; AI is player 2
        ld (hl), a

        ; Update display
        ld a, (best_y)
        ld b, a
        ld a, (best_x)
        ld c, a
        call get_cell_addr
        call set_cell_colour

        ; Switch back to human
        ld a, 1
        ld (current_player), a
        call update_ui_colours

        ret
