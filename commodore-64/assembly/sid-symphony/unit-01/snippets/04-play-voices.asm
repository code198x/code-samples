; ----------------------------------------------------------------------------
; Play Voice 1
; ----------------------------------------------------------------------------
; Triggers voice 1 (high, sawtooth)

play_voice1:
            lda #$21            ; Gate on + sawtooth waveform
            sta SID_V1_CTRL
            rts

; ----------------------------------------------------------------------------
; Play Voice 2
; ----------------------------------------------------------------------------
; Triggers voice 2 (mid, pulse)

play_voice2:
            lda #$41            ; Gate on + pulse waveform
            sta SID_V2_CTRL
            rts

; ----------------------------------------------------------------------------
; Play Voice 3
; ----------------------------------------------------------------------------
; Triggers voice 3 (low, triangle)

play_voice3:
            lda #$11            ; Gate on + triangle waveform
            sta SID_V3_CTRL
            rts
