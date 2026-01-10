; Claiming now switches players

check_claim:
        bit 4, d            ; Space pressed?
        ret z

        ; ... (check if cell is empty) ...

        ; Claim it
        ld a, (current_player)
        ld (hl), a          ; Store in board_state
        call update_cell_display

        ; Success feedback
        ld a, 4             ; Green flash
        out (BORDER_PORT), a
        call short_delay
        xor a
        out (BORDER_PORT), a

        ; Switch to other player
        call switch_player  ; <-- NEW!

        ret

; Now: claim → display → switch → other player's turn
