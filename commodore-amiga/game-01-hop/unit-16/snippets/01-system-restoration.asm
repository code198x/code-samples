save_system_state:
            ; Save DMA and interrupt state
            move.w  DMACONR(a5),d0
            ori.w   #$8000,d0           ; Set bit for restore
            move.w  d0,saved_dmacon

            move.w  INTENAR(a5),d0
            ori.w   #$8000,d0
            move.w  d0,saved_intena

            ; Save copper list pointers
            ; (System copper is in graphics.library base)
            ; For simplicity, we'll just restore safe defaults

            rts
