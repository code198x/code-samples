play_bum_note:
            ; Quick harsh envelope
            lda #$00
            sta SID_V1_AD
            lda #$08
            sta SID_V1_SR

            ; Noise waveform at low pitch
            lda #$00
            sta SID_V1_FREQ_LO
            lda #$08
            sta SID_V1_FREQ_HI
            lda #WAVE_NOISE
            sta SID_V1_CTRL

            lda #8
            sta bum_note_timer
            rts

update_bum_note:
            lda bum_note_timer
            beq +

            dec bum_note_timer
            bne +

            ; Restore voice 1 settings
            lda #FREQ_C4_LO
            sta SID_V1_FREQ_LO
            lda #FREQ_C4_HI
            sta SID_V1_FREQ_HI
            lda #$09
            sta SID_V1_AD
            lda #$52
            sta SID_V1_SR
+           rts
