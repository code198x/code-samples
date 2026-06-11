drawscore:
            move.w  score,d7            ; D7 = what's left to convert
            moveq   #38,d5              ; Rightmost digit's byte column
            moveq   #4-1,d6             ; Four digits
.digit:
            moveq   #0,d0
            move.w  d7,d0
            divu    #10,d0              ; Quotient low, remainder high
            move.l  d0,d1
            swap    d1                  ; D1 = this digit (0-9)
            move.w  d0,d7               ; D7 = the rest
            ; Find the digit's glyph: font + digit*8
            lea     digitfont,a2
            add.w   d1,d1
            add.w   d1,d1
            add.w   d1,d1               ; digit * 8
            adda.w  d1,a2
            move.w  d5,d0               ; Byte column
            move.w  #ROW_HUD+4,d1
            bsr     drawglyph
            subq.w  #1,d5               ; Next digit to the left
            dbf     d6,.digit
            rts
