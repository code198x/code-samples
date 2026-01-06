move.w  d0,d1
            lsr.w   #1,d1           ; Shift by 1
            eor.w   d1,d0           ; XOR to decode
            btst    #0,d0           ; Down?
            btst    #8,d0           ; Up?
