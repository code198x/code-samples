; ----------------------------------------------------------------------------
; Play Voice With Note Frequency
; ----------------------------------------------------------------------------
; When a note is hit, we play its stored frequency, not a fixed pitch.
; This makes each hit sound like part of the melody.

play_voice1_note:
            lda #0
            sta SID_V1_FREQ_LO
            lda hit_note_freq   ; Use the note's actual pitch
            sta SID_V1_FREQ_HI
            lda #VOICE1_WAVE
            ora #$01            ; Gate on
            sta SID_V1_CTRL
            rts

play_voice2_note:
            lda #0
            sta SID_V2_FREQ_LO
            lda hit_note_freq
            sta SID_V2_FREQ_HI
            lda #VOICE2_WAVE
            ora #$01
            sta SID_V2_CTRL
            rts

play_voice3_note:
            lda #0
            sta SID_V3_FREQ_LO
            lda hit_note_freq
            sta SID_V3_FREQ_HI
            lda #VOICE3_WAVE
            ora #$01
            sta SID_V3_CTRL
            rts
