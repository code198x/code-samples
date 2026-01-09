; ADSR is split across two registers per voice:
;
; Attack/Decay register ($D405 for voice 1):
;   Bits 4-7: Attack (0-15)
;   Bits 0-3: Decay (0-15)
;
; Sustain/Release register ($D406 for voice 1):
;   Bits 4-7: Sustain level (0-15)
;   Bits 0-3: Release (0-15)

; Example: Attack=2, Decay=4, Sustain=12, Release=6
lda #$24            ; Attack=2, Decay=4 (high nibble | low nibble)
sta SID_V1_AD
lda #$c6            ; Sustain=12, Release=6
sta SID_V1_SR
