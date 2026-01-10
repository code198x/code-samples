; Switch to the other player
; Simple maths: 3 - 1 = 2, and 3 - 2 = 1

switch_player:
        ld a, (current_player)
        ld b, a
        ld a, 3
        sub b               ; 3 - current = other
        ld (current_player), a

        call draw_turn_indicator
        call draw_cursor    ; Redraw in new colour
        ret

; Called after a successful claim
; Turns alternate: Red → Blue → Red → Blue...
