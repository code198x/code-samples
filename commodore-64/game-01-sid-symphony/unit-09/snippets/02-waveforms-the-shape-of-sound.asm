play_voice:
            cmp #$00
            bne +
            lda #WAVE_PULSE     ; Voice 1: Pulse wave
            sta SID_V1_CTRL
            rts
+           cmp #$01
            bne +
            lda #WAVE_SAWTOOTH  ; Voice 2: Sawtooth wave
            sta SID_V2_CTRL
            rts
+           lda #WAVE_TRIANGLE  ; Voice 3: Triangle wave
            sta SID_V3_CTRL
            rts
