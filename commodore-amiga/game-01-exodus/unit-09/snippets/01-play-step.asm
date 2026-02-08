;──────────────────────────────────────────────────────────────
; play_step — Trigger the footstep sample on Paula channel 0
;──────────────────────────────────────────────────────────────
play_step:
            lea     CUSTOM,a6
            lea     step_sample,a0
            move.l  a0,AUD0LC(a6)           ; Sample address
            move.w  #STEP_SAMPLE_LEN/2,AUD0LEN(a6)  ; Length in words
            move.w  #STEP_PERIOD,AUD0PER(a6)         ; Pitch
            move.w  #STEP_VOLUME,AUD0VOL(a6)         ; Volume (0-64)
            move.w  #$8201,DMACON(a6)       ; Enable audio DMA ch0
            rts
