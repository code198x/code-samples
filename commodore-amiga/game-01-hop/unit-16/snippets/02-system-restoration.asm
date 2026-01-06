restore_system:
            lea     CUSTOM,a5

            ; Disable all DMA and interrupts first
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)

            ; Restore saved states
            move.w  saved_intena,INTENA(a5)
            move.w  saved_dmacon,DMACON(a5)

            ; Clear our display
            ; (A proper exit would restore the system copper)

            rts
