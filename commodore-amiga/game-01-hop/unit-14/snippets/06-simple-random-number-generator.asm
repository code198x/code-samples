random:
; Returns d0 = random 16-bit value
; Modifies: random_seed
            move.l  random_seed,d0
            mulu    #$41C6,d0
            addi.l  #$3039,d0
            move.l  d0,random_seed
            swap    d0              ; Use high word for better randomness
            rts

random_seed:    dc.l    12345       ; Initial seed
