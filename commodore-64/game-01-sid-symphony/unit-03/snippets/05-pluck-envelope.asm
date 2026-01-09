; "Pluck" envelope - instant hit, very quick fade, no sustain
;
; Attack=0  : Instant start
; Decay=3   : Fades very fast (~24ms)
; Sustain=0 : Fades to silence (doesn't sustain)
; Release=0 : No additional fade (already silent)
;
; This creates a percussive, plucked-string sound.
; The gate can stay open - the sound fades anyway because sustain=0.

lda #$03            ; Attack=0, Decay=3
sta SID_V3_AD
lda #$00            ; Sustain=0, Release=0
sta SID_V3_SR
