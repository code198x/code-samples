draw_number_2digit:
; d0 = X, d1 = Y, d2 = number (0-99)
            movem.l d0-d4/a0-a2,-(sp)
            move.w  d0,d3
            move.w  d1,d4
            move.l  d2,d5

            ; Tens digit
            divu    #10,d5
            move.w  d5,d2
            movem.l d3-d5,-(sp)
            bsr     draw_digit
            movem.l (sp)+,d3-d5

            ; Ones digit
            swap    d5              ; Remainder
            move.w  d5,d2
            addq.w  #8,d3
            bsr     draw_digit

            movem.l (sp)+,d0-d4/a0-a2
            rts
