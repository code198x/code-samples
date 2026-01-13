; Screen border colours for each player
P1_BORDER   equ     2               ; Red border for Player 1's turn
P2_BORDER   equ     1               ; Blue border for Player 2's turn

; ----------------------------------------------------------------------------
; Update Screen Border
; ----------------------------------------------------------------------------
; Sets border colour based on current player

update_border:
            ld      a, (current_player)
            cp      1
            jr      z, .ub_p1
            ld      a, P2_BORDER
            jr      .ub_set
.ub_p1:
            ld      a, P1_BORDER
.ub_set:
            out     (KEY_PORT), a
            ret
