; ----------------------------------------------------------------------------
; Initialize SID
; ----------------------------------------------------------------------------
; Sets up SID with three distinct voices ready to play

init_sid:
            ; Clear all SID registers first
            ldx #$18
            lda #0
-           sta SID,x
            dex
            bpl -

            ; Set volume to maximum
            lda #$0F
            sta SID_VOLUME

            ; Voice 1 - High pitch, sawtooth wave
            lda #$00
            sta SID_V1_FREQ_LO
            lda #$1C            ; High frequency (~523 Hz, C5)
            sta SID_V1_FREQ_HI
            lda #$09            ; Attack=0, Decay=9
            sta SID_V1_AD
            lda #$00            ; Sustain=0, Release=0
            sta SID_V1_SR

            ; Voice 2 - Mid pitch, pulse wave
            lda #$00
            sta SID_V2_FREQ_LO
            lda #$0E            ; Mid frequency (~262 Hz, C4)
            sta SID_V2_FREQ_HI
            lda #$08            ; 50% pulse width
            sta SID_V2_PWHI
            lda #$09            ; Attack=0, Decay=9
            sta SID_V2_AD
            lda #$00            ; Sustain=0, Release=0
            sta SID_V2_SR

            ; Voice 3 - Low pitch, triangle wave
            lda #$00
            sta SID_V3_FREQ_LO
            lda #$07            ; Low frequency (~131 Hz, C3)
            sta SID_V3_FREQ_HI
            lda #$09            ; Attack=0, Decay=9
            sta SID_V3_AD
            lda #$00            ; Sustain=0, Release=0
            sta SID_V3_SR

            rts
