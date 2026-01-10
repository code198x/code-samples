; Convert player number to attribute colour
; Input: A = player (0, 1, or 2)
; Output: A = attribute byte

get_player_colour:
        cp EMPTY
        jr nz, not_empty
        ld a, EMPTY_ATTR        ; White
        ret

not_empty:
        cp PLAYER1
        jr nz, not_p1
        ld a, P1_ATTR           ; Bright red
        ret

not_p1:
        ld a, P2_ATTR           ; Bright blue
        ret
