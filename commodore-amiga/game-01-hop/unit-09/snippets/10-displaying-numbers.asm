; Draw lives count
draw_lives:
            move.w  lives,d0
            move.w  #LIVES_X,d1
            move.w  #LIVES_Y,d2
            bsr     draw_digit
            rts
