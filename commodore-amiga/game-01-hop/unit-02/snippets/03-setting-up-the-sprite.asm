; Set sprite pointer in copper list
            lea     frog_data,a0    ; A0 = address of sprite data
            lea     sprpt+2,a1      ; A1 = value field of SPR0PTH instruction
            move.l  a0,d0           ; D0 = sprite address
            swap    d0              ; Swap high/low words
            move.w  d0,(a1)         ; Write high word to SPR0PTH value
            swap    d0              ; Swap back
            move.w  d0,4(a1)        ; Write low word to SPR0PTL value
