; "String" envelope - slow swell, sustained, gradual fade
;
; Attack=12 : Very slow swell (~1 second to reach peak)
; Decay=8   : Drops to sustain level
; Sustain=10: Holds at high volume
; Release=8 : Gradual fade when released

lda #$c8            ; Attack=12, Decay=8
sta SID_V2_AD
lda #$a8            ; Sustain=10, Release=8
sta SID_V2_SR
