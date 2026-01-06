; Play sound effect on channel 0
; a0 = sample address
; d0.w = length in words
; d1.w = period
; d2.w = volume
play_sfx:
            lea     CUSTOM,a5

            ; Set sample pointer
            move.l  a0,d3
            move.w  d3,AUD0LCL(a5)
            swap    d3
            move.w  d3,AUD0LCH(a5)

            ; Set length
            move.w  d0,AUD0LEN(a5)

            ; Set period and volume
            move.w  d1,AUD0PER(a5)
            move.w  d2,AUD0VOL(a5)

            ; Trigger playback by enabling DMA
            move.w  #DMAF_SETCLR|DMAF_AUD0,DMACON(a5)

            rts
