; Indexed addressing: base address + register offset
;
; lda freq_lo,x means "load from address (freq_lo + X)"
;
; If X = 0, loads from freq_lo + 0 = C4
; If X = 4, loads from freq_lo + 4 = G4
; If X = 7, loads from freq_lo + 7 = C5
;
; This is how we select notes by number rather than hardcoding addresses.

                ldx #4              ; We want note index 4 (G4)
                lda freq_lo,x       ; Load low byte of G4's frequency
                sta SID_V1_FREQ_LO
                lda freq_hi,x       ; Load high byte of G4's frequency
                sta SID_V1_FREQ_HI
