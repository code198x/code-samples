;───────────────────────────────────────
; Swap to the other player
;───────────────────────────────────────
swap_player:
        ld a, (current_player)
        xor 3                   ; 1 XOR 3 = 2, 2 XOR 3 = 1
        ld (current_player), a
        call update_ui_colours  ; Show the change
        ret
