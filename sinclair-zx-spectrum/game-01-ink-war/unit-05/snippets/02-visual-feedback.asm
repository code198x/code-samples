;───────────────────────────────────────
; Update border colour to show current player
;───────────────────────────────────────
update_ui_colours:
        ld a, (current_player)
        cp 1
        jr nz, .player_2
        ld a, 2                 ; Red for Player 1
        jr .set_border
.player_2:
        ld a, 5                 ; Cyan for Player 2
.set_border:
        out (254), a
        ret
