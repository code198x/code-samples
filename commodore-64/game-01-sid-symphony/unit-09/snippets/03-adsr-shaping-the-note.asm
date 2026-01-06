; Voice 1 - Pulse wave (punchy, responsive)
lda #$09            ; Attack=0, Decay=9
sta SID_V1_AD
lda #$52            ; Sustain=5, Release=2
sta SID_V1_SR

; Voice 2 - Sawtooth (bright, snappy)
lda #$0a            ; Attack=0, Decay=10
sta SID_V2_AD
lda #$41            ; Sustain=4, Release=1
sta SID_V2_SR

; Voice 3 - Triangle (soft, flowing)
lda #$18            ; Attack=1, Decay=8
sta SID_V3_AD
lda #$84            ; Sustain=8, Release=4
sta SID_V3_SR
