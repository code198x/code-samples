; Binary to Decimal Conversion
; Convert 32-bit score to 6 individual digits

display_score:
            movem.l d0-d4/a0-a3,-(sp)

            ; Convert score to 6 decimal digits
            move.l  score(pc),d0        ; Load score (PC-relative)

            ; Work backwards: divide by 10 repeatedly
            lea     score_digits+12,a0  ; Point past end of buffer
            moveq   #5,d4               ; 6 digits (0-5)

.convert:
            ; DIVU divides D0 by 10
            ; Result: D0.W = quotient, D0 high word = remainder
            divu    #10,d0              ; d0 = quotient:remainder
            swap    d0                  ; Get remainder in low word
            move.w  d0,-(a0)            ; Store digit (0-9)
            clr.w   d0                  ; Clear remainder
            swap    d0                  ; Quotient back in low word
            dbf     d4,.convert

            ; score_digits now contains 6 digit values (0-9)
            ; Draw each digit using font lookup...

            ; (drawing code follows)

            movem.l (sp)+,d0-d4/a0-a3
            rts
