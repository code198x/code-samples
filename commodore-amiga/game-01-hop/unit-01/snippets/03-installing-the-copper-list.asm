; Install copper list
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)       ; Set copper list address
            move.w  d0,COPJMP1(a5)      ; Strobe: restart copper

            ; Enable copper DMA
            move.w  #$8280,DMACON(a5)   ; Set bits: master + copper
