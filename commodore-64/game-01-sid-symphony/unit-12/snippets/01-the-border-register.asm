; Border colour register
; Writing here instantly changes the border
; Values 0-15 map to the C64 colour palette
            lda #COL_RED
            sta BORDER       ; Border turns red immediately
