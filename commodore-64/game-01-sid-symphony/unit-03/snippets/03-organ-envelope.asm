; "Organ" envelope - instant on, holds indefinitely, slow fade
;
; Attack=0  : Sound starts immediately
; Decay=0   : No decay (goes straight to sustain)
; Sustain=15: Holds at full volume while gate is open
; Release=9 : Slow fade when gate closes (~250ms)

lda #$00            ; Attack=0, Decay=0
sta SID_V1_AD
lda #$f9            ; Sustain=15, Release=9
sta SID_V1_SR
