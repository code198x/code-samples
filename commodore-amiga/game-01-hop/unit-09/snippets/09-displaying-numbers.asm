; Draw score at position
; Score is in 'score' variable
draw_score:
            move.l  score,d0
            move.w  #SCORE_X,d4         ; Starting X position
            move.w  #SCORE_Y,d5         ; Y position

            ; We'll draw 6 digits (max 999999)
            move.w  #5,d7               ; Loop counter

            ; Divide by powers of 10, largest first
            lea     powers_of_10,a2

.digit_loop:
            move.l  (a2)+,d2            ; Get divisor
            moveq   #0,d1               ; Digit counter

.div_loop:
            cmp.l   d2,d0
            blt.s   .div_done
            sub.l   d2,d0
            addq.w  #1,d1
            bra.s   .div_loop

.div_done:
            ; d1 = digit value
            movem.l d0/d4-d7/a2,-(sp)
            move.w  d1,d0               ; Digit to draw
            move.w  d4,d1               ; X position
            move.w  d5,d2               ; Y position
            bsr     draw_digit
            movem.l (sp)+,d0/d4-d7/a2

            addq.w  #8,d4               ; Next X position
            dbf     d7,.digit_loop

            rts

powers_of_10:
            dc.l    100000,10000,1000,100,10,1
