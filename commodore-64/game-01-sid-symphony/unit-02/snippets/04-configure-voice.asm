                ; Configure Voice 2: Sawtooth wave, E4
                lda #FREQ_E4_LO
                sta SID_V2_FREQ_LO
                lda #FREQ_E4_HI
                sta SID_V2_FREQ_HI
                lda #$00                        ; Attack=0, Decay=0
                sta SID_V2_AD
                lda #$f0                        ; Sustain=15, Release=0
                sta SID_V2_SR
                lda #WAVE_SAW | GATE_ON         ; Sawtooth + gate on
                sta SID_V2_CTRL
