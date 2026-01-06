update_ui_colours:
        ld a, (current_player)
        cp 1
        jr nz, .player_2
        ld a, 2
        jr .set_border
.player_2:
        ld a, 5
.set_border:
        ld (border_colour), a   ; Save for beeper
        out (254), a
        ret
