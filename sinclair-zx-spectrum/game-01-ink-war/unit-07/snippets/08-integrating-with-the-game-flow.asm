claim_cell:
        ; ... validation checks ...

        ; Valid! Claim it
        ; ... claim code ...

        ; If human just moved, trigger AI
        ld a, (current_player)
        cp 1
        jr nz, .done            ; AI already moved

        ; Human moved - now AI's turn
        call ai_think_delay     ; Pause for effect
        call ai_pick_move       ; Find best move
        call ai_make_move       ; Execute it

.done:
        ret
