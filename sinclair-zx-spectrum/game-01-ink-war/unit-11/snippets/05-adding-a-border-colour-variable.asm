set_winner_border:
        ld a, (winner)
        cp 1
        jr nz, .not_p1
        ld a, 2                 ; Red
        jr .set
.not_p1:
        cp 2
        jr nz, .is_draw
        ld a, 5                 ; Cyan
        jr .set
.is_draw:
        ld a, 6                 ; Yellow
.set:
        ld (border_colour), a   ; Save for beeper
        out (254), a
        ret
